import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/theme_service.dart';
import 'services/card_archive_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('AdMob Init Exception: $e');
  }
  await ThemeService().init();
  await CardArchiveService().init();
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('NotificationService Init Exception: $e');
  }
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
          title: '마음카드',
          themeMode: currentMode,

          // Light Theme (Warm Cream Ivory & Sunset Gold for Seniors)
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE64A19),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFFAF8F5),
            cardColor: Colors.white,
            useMaterial3: true,
          ),

          // Dark Theme for Seniors (Modern Carbon Slate & Gold)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFD700),
              brightness: Brightness.dark,
              surface: const Color(0xFF1C202E),
            ),
            scaffoldBackgroundColor: const Color(0xFF141722),
            cardColor: const Color(0xFF1C202E),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
