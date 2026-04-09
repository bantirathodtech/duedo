import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/main_screen.dart';
import 'ui/widgets/app_initializer.dart';
import 'ui/widgets/vault_gate.dart';
import 'services/app_open_ad_manager.dart';
import 'services/logger_service.dart';


Future<void> main() async {
  // Capture all Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    LoggerService.log(
      'Flutter Error caught by Global Handler',
      category: LogCategory.error,
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  WidgetsFlutterBinding.ensureInitialized();
  
  // No blocking awaits here - everything is moved to the staggered AppInitializer
  // for an Ironman-level smooth startup experience.
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppOpenAdManager _appOpenAdManager;

  @override
  void initState() {
    super.initState();
    _appOpenAdManager = AppOpenAdManager();
    // Ironman: Defer ad loading to prevent startup main-thread congestion
    Future.delayed(const Duration(seconds: 5), () {
      _appOpenAdManager.loadAd();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _appOpenAdManager.showAdIfAvailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duedo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(ThemeData.light()),
      darkTheme: AppTheme.darkTheme(ThemeData.dark()),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        // Global Error Boundary Widget - Only set if not in test
        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, color: AppTheme.primary, size: 64),
                      const SizedBox(height: 24),
                      const Text(
                        'Vault Protection Active',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'An unexpected error occurred. Your data is safe in the vault, but we need to restart the engine.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 32),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const MyApp()), 
                          (route) => false,
                        ),
                        child: const Text('Restart Duedo', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          };
        }
        return child!;
      },
      home: AppInitializer(
        child: const VaultGate(
          child: MainScreen(),
        ),
      ),
    );
  }
}
