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
  final List<String> _blessings = const [
    "“오늘 하루도 기쁨과 행복이 넘치시길 🌿”",
    "“늘 건강하시고 미소 가득한 날 되세요 🌸”",
    "“소중한 분들께 따뜻한 마음을 전해보세요 ❤️”",
    "“당신의 앞날에 언제나 꽃길만 가득하길 ✨”",
  ];

  int _blessingIndex = 0;
  Timer? _blessingTimer;

  @override
  void initState() {
    super.initState();
    // Preload Interstitial Ad
    AdService().loadInterstitialAd();

    // Rotate blessings
    _blessingTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (mounted) {
        setState(() {
          _blessingIndex = (_blessingIndex + 1) % _blessings.length;
        });
      }
    });

    // Navigate to MainTabScreen after 2.8 seconds
    Timer(const Duration(milliseconds: 2800), () {
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
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _blessingTimer?.cancel();
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
              Color(0xFF8B005D), // Deep Mulberry Rose
              Color(0xFFD81B60), // Ruby Pink
              Color(0xFFFF758C), // Morning Coral
              Color(0xFFFFC3A0), // Gentle Warm Sunrise
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 1. Luxury Gold Ring App Icon Badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700), width: 3), // Gold Ring
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withAlpha(120),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/app_icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(duration: 900.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 900.ms),

              const SizedBox(height: 32),

              // 2. Title & Subtitle Badge
              Text(
                '좋은아침 메이커',
                style: GoogleFonts.jua(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      blurRadius: 10.0,
                      color: Color(0xFFFFD700),
                      offset: Offset(0, 2),
                    ),
                    const Shadow(
                      blurRadius: 4.0,
                      color: Colors.black45,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 800.ms)
                  .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 800.ms),

              const SizedBox(height: 14),

              // Subtitle Tag Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(45),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white38),
                ),
                child: Text(
                  '매일 아침, 소중한 분께 띄우는 사랑과 축복',
                  style: GoogleFonts.dongle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 800.ms),

              const Spacer(flex: 2),

              // 3. Rotating Blessing Quote Card
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Container(
                  key: ValueKey<int>(_blessingIndex),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD700).withAlpha(160), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _blessings[_blessingIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFFFF9C4), // Warm Light Gold
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 4. Luxury Golden Loading Indicator
              Column(
                children: [
                  SizedBox(
                    width: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        minHeight: 5,
                        backgroundColor: Colors.white24,
                        color: Color(0xFFFFD700), // Golden bar
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '상쾌한 아침 기운을 담아 오는 중...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withAlpha(220),
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(blurRadius: 4, color: Colors.black45),
                      ],
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 800.ms),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
