import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ad_service.dart';
import 'main_tab_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Preload Interstitial Ad
    AdService().loadInterstitialAd();

    // Navigate to MainTabScreen after 2.5 seconds
    Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainTabScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF9A9E), // Warm rose pink
              Color(0xFFFECFEF), // Gentle peach
              Color(0xFFFEF9D7), // Golden morning light
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Icon Badge
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withAlpha(80),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/app_icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 800.ms),
              const SizedBox(height: 28),

              // Title
              Text(
                '좋은아침 메이커',
                style: GoogleFonts.jua(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B0000), // Deep ruby red
                  shadows: [
                    const Shadow(
                      blurRadius: 4.0,
                      color: Colors.white,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 700.ms)
                  .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 700.ms),
              const SizedBox(height: 12),

              // Subtitle Greeting
              Text(
                '소중한 분들께 사랑과 감사를 전해보세요',
                style: GoogleFonts.dongle(
                  fontSize: 28,
                  color: Colors.brown.shade800,
                  fontWeight: FontWeight.w600,
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 700.ms),
              const Spacer(),

              // Progress Indicator & Loading Text
              Column(
                children: [
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: Color(0xFFD81B60),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '오늘도 축복 가득한 하루 되세요...',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 900.ms, duration: 600.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
