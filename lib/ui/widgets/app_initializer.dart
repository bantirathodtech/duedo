import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../theme/app_theme.dart';
import '../../repositories/obligation_repository.dart';
import '../../services/supabase_service.dart';
import '../../services/sms_sync_service.dart';
import '../../services/background_service.dart';
import '../../services/ads/ad_service.dart';
import '../../services/audit_log.dart';
import '../../services/logger_service.dart';
import '../../services/notification_service.dart';
import '../../services/security_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const AppInitializer({super.key, required this.child});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _isInitialized = false;
  String _loadingMessage = 'Starting Duedo...';

  @override
  void initState() {
    super.initState();
    // IRONMAN FIX: Wait for the very first frame to be PAINTED before 
    // starting any heavy initialization. This eliminates the "Skipped N frames"
    // warning because the Impeller/Vulkan engine is fully warmed up by then.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final audit = AuditLog();
    audit.perf('App_Bootstrap', category: LogCategory.performance);

    // Short settle after first frame - engine is already warm now.
    await Future.delayed(const Duration(milliseconds: 200)); 
    
    if (!mounted) return;

    try {
      // --- PHASE 0: SYSTEM CRITICAL ---
      setState(() => _loadingMessage = 'Booting Systems...');
      audit.perf('Phase_0_System', category: LogCategory.performance);
      
      final isTest = Platform.environment.containsKey('FLUTTER_TEST');
      
      if (!isTest) {
        await Supabase.initialize(
          url: 'https://bybdomxfcrnaxbwumxkj.supabase.co',
          anonKey: 'sb_publishable_mkzr3z60CwOZyYzVm80pBA_12OC1tNo',
        );
      }
      
      // Aggressive breathing room after Supabase startup
      await Future.delayed(Duration(milliseconds: isTest ? 10 : 300));
      audit.perfComplete('Phase_0_System', category: LogCategory.performance);

      await _yieldForFrames();
      
      // Basic Security Audit (Now Deferred)
      _deferSecurityCheck();

      // --- PHASE 1: REPOSITORIES ---
      setState(() => _loadingMessage = 'Unlocking Vault...');
      audit.perf('Phase_1_Core', category: LogCategory.performance);
      
      audit.perf('Repo_Init', category: LogCategory.performance);
      ref.read(obligationRepositoryProvider);
      await Future.delayed(const Duration(milliseconds: 100)); // Yield for DB open
      audit.perfComplete('Repo_Init', category: LogCategory.performance);

      audit.perf('Supabase_Init', category: LogCategory.performance);
      await ref.read(supabaseServiceProvider).initialize();
      audit.perfComplete('Supabase_Init', category: LogCategory.performance);
      
      audit.perfComplete('Phase_1_Core', category: LogCategory.performance);

      await _yieldForFrames(ms: 200); // Longer break for UI paint

      // --- PHASE 2: COMMUNICATIONS ---
      setState(() => _loadingMessage = 'Checking Alerts...');
      audit.perf('Phase_2_Notifs', category: LogCategory.performance);
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.init();
      audit.perfComplete('Phase_2_Notifs', category: LogCategory.performance);

      await _yieldForFrames();

      // --- PHASE 3: SYSTEM STABILITY ---
      setState(() => _loadingMessage = 'Securing Environment...');
      audit.perf('Phase_3_System', category: LogCategory.performance);
      await notificationService.requestPermissions();
      // SMS Sync is now deferred
      _deferSmsSync();
      
      await Future.delayed(const Duration(milliseconds: 100));

      // 5. Workers (Non-blocking)
      await BackgroundService.init();

      if (mounted) {
        setState(() => _isInitialized = true);
        AuditLog.info('Startup Sequence Finished', tag: 'BOOT');
        _initializeAdsDeferred();
      }
    } catch (e, stack) {
      LoggerService.log('Bootstrap Failure: $e', category: LogCategory.error);
      debugPrint(stack.toString());
    } finally {
      audit.perfComplete('App_Bootstrap', category: LogCategory.performance);
    }
  }

  Future<void> _yieldForFrames({int ms = 100}) async {
    await Future.delayed(Duration(milliseconds: ms));
  }

  void _deferSecurityCheck() {
    Future.delayed(const Duration(seconds: 10), () async {
      final isCompromised = await SecurityService.isDeviceCompromised();
      if (isCompromised) {
        LoggerService.log('Running on potentially compromised hardware.', category: LogCategory.security);
      }
    });
  }

  void _deferSmsSync() {
    Future.delayed(const Duration(seconds: 15), () async {
      await ref.read(smsSyncServiceProvider).init();
    });
  }

  void _initializeAdsDeferred() {
    // We wait 3 seconds after UI is live to load heavy SDKs (Ads, Scheduling, etc.)
    Future.delayed(const Duration(seconds: 3), () async {
      AuditLog.startTimer('Deferred_Services');
      
      // 1. Ads
      await AdMobService.initialize();
      
      // 2. Notification Scheduling (Heavy processing)
      final notificationService = ref.read(notificationServiceProvider);
      await _scheduleBackgroundTasks(notificationService);
      
      AuditLog.stopTimer('Deferred_Services');
    });
  }

  Future<void> _scheduleBackgroundTasks(NotificationService notificationService) async {
    try {
      final repository = ref.read(obligationRepositoryProvider);
      final settings = await repository.getSettings().first;
      
      if (settings != null) {
        final isSavage = settings.isSavageMode;
        
        // Spread these out even more to yield to the UI thread
        await notificationService.scheduleDailyVibe(isSavage: isSavage);
        await Future.delayed(const Duration(milliseconds: 100)); // Yield
        
        await notificationService.scheduleWeeklyReview(isSavage: isSavage);
        await Future.delayed(const Duration(milliseconds: 100)); // Yield
        
        await notificationService.scheduleMonthlyReview(isSavage: isSavage);
        await Future.delayed(const Duration(milliseconds: 100)); // Yield
        
        await notificationService.schedulePaydayReminder(settings.paydayOfMonth, isSavage: isSavage);
        await Future.delayed(const Duration(milliseconds: 100)); // Yield
        
        await notificationService.scheduleGhostingReminder();
        await Future.delayed(const Duration(milliseconds: 100)); // Yield

        await repository.updateSettings(
          settings.toCompanion(true).copyWith(lastOpened: Value(DateTime.now())),
        );
      }
    } catch (e) {
      debugPrint('Background scheduling background error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.primary),
              const SizedBox(height: 24),
              Text(
                _loadingMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}
