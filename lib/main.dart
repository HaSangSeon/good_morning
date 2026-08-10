import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/theme_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('AdMob Init Exception: $e');
  }
  await ThemeService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeModeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: '아침인사 메이커',
          themeMode: currentMode,

          // Light Theme
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD81B60),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF9F6F0),
            useMaterial3: true,
          ),

          // Dark Theme for Seniors (Deep Slate & Gold)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFD700),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E2C),
            ),
            scaffoldBackgroundColor: const Color(0xFF121218),
            cardColor: const Color(0xFF1E1E2C),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
