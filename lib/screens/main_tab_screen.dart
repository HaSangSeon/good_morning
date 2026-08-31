import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'home_screen.dart';
import 'wisdom_screen.dart';
import 'health_screen.dart';
import 'card_archive_screen.dart';
import '../services/ad_service.dart';
import '../services/card_archive_service.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  final ValueNotifier<String> _sharedTextNotifier = ValueNotifier<String>('');
  final ValueNotifier<SavedCard?> _sharedCardNotifier =
      ValueNotifier<SavedCard?>(null);

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService().bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isBannerLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('MainTabScreen BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _sharedTextNotifier.dispose();
    _sharedCardNotifier.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _switchToCardMakerWithText(String text) {
    _sharedTextNotifier.value = text;
    setState(() {
      _currentIndex = 0;
    });
  }

  void _openSavedCard(SavedCard card) {
    _sharedCardNotifier.value = card;
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      HomeScreen(
        sharedTextNotifier: _sharedTextNotifier,
        sharedCardNotifier: _sharedCardNotifier,
      ),
      WisdomScreen(
        onShareAsCard: (cardText) {
          _switchToCardMakerWithText(cardText);
        },
      ),
      HealthScreen(
        onShareAsCard: (cardText) {
          _switchToCardMakerWithText(cardText);
        },
      ),
      CardArchiveScreen(onSelectCard: _openSavedCard),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 모든 탭 공통 하단 AdMob 배너 광고
          if (_isBannerLoaded && _bannerAd != null)
            SafeArea(
              top: false,
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFFFFDF9),
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: Center(child: AdWidget(ad: _bannerAd!)),
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF232742) : const Color(0xFFFFFDF9),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black45 : const Color(0x1A8D6E63),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: isDark
                  ? const Color(0xFFFFD700)
                  : const Color(0xFFE64A19),
              unselectedItemColor: isDark
                  ? const Color(0xFFB0B7D6)
                  : const Color(0xFF8D6E63),
              selectedFontSize: 13,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? const Color(0xFF232742) : const Color(0xFFFFFDF9),
              onTap: (index) {
                HapticFeedback.selectionClick();
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.image_outlined, size: 26),
                  activeIcon: Icon(
                    Icons.image,
                    size: 28,
                    color: isDark
                        ? const Color(0xFFFFD700)
                        : const Color(0xFFE64A19),
                  ),
                  label: '마음카드',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.auto_stories_outlined, size: 26),
                  activeIcon: Icon(
                    Icons.auto_stories,
                    size: 28,
                    color: isDark
                        ? const Color(0xFFFFD700)
                        : const Color(0xFFD35400),
                  ),
                  label: '좋은글·명언',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.eco_outlined, size: 26),
                  activeIcon: Icon(
                    Icons.eco,
                    size: 28,
                    color: isDark
                        ? const Color(0xFFFFD700)
                        : const Color(0xFF2E7D32),
                  ),
                  label: '매일건강',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.collections_bookmark_outlined, size: 26),
                  activeIcon: Icon(
                    Icons.collections_bookmark,
                    size: 28,
                    color: isDark
                        ? const Color(0xFFFFD700)
                        : const Color(0xFFE64A19),
                  ),
                  label: '내 카드함',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
