import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ad_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Navigate to MainTabScreen after 1.8 seconds cleanly
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
              Color(0xFFFFFDF9), // 부드러운 웜 아이보리
              Color(0xFFFFF4EB), // 은은한 연살구/피치 크림
              Color(0xFFFBEFE3), // 차분한 웜 베이지
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. 감성 심볼 (볼륨감 있는 둥근 컨테이너)
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFFFEAD8), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.mail_rounded,
                              size: 42,
                              color: Color(0xFFFF9E44), // 웜 앰버
                            ),
                            Positioned(
                              top: 0,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  size: 18,
                                  color: Color(0xFFFF6B4A), // 딥 코랄
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 800.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 28),

                    // 2. 앱 타이틀
                    const Text(
                      '마음카드',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2C2523), // 딥 에스프레소 먹색
                        letterSpacing: -0.5,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms),

                    const SizedBox(height: 8),

                    // 3. 서브 슬로건
                    const Text(
                      '소중한 분께 전하는 따뜻한 안부',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500, // Medium
                        color: Color(0xFF7C726E), // 웜 토프 그레이
                        letterSpacing: -0.3,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 600.ms),
                  ],
                ),
              ),
              
              // 4. 하단 감성 로딩 인디케이터
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7A59)), // 딥 코랄
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 500.ms),

                    const SizedBox(height: 10),

                    const Text(
                      '따뜻한 마음을 준비하고 있어요...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A817C),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 500.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
