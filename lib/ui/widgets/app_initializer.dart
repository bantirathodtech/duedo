import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notification_service.dart';
import '../../repositories/obligation_repository.dart';
import '../theme/app_theme.dart';

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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Initialize Notifications
      setState(() => _loadingMessage = 'Setting up alerts...');
      final notificationService = NotificationService();
      await notificationService.init();
      
      // 2. Initialize Repository (Cloud Sync)
      setState(() => _loadingMessage = 'Syncing with cloud...');
      await ref.read(obligationRepositoryProvider).init();

      // 3. Request permissions (non-blocking in UI thread)
      setState(() => _loadingMessage = 'Ready to launch...');
      await notificationService.requestPermissions();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Initialization error (continuing...): $e');
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(ThemeData.dark()),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppTheme.primary),
                const SizedBox(height: 24),
                Text(
                  _loadingMessage,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
