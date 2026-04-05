import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/main_screen.dart';
import 'ui/widgets/app_initializer.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bybdomxfcrnaxbwumxkj.supabase.co',
    anonKey: 'sb_publishable_mkzr3z60CwOZyYzVm80pBA_12OC1tNo',
  );

  runApp(
    const ProviderScope(
      child: AppInitializer(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duedo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(ThemeData.light()),
      darkTheme: AppTheme.darkTheme(ThemeData.dark()),
      themeMode: ThemeMode.system,
      home: const MainScreen(),
    );
  }
}
