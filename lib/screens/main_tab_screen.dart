import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'home_screen.dart';
import 'wisdom_screen.dart';
import 'health_screen.dart';
import 'card_archive_screen.dart';
import '../data/home_card_data.dart';
import '../services/ad_service.dart';
import '../services/card_archive_service.dart';
import '../services/notification_service.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  final ValueNotifier<String> _sharedTextNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _sharedBgPathNotifier = ValueNotifier<String>('');
  final ValueNotifier<SavedCard?> _sharedCardNotifier =
      ValueNotifier<SavedCard?>(null);
  final ValueNotifier<ExternalCardRequest?> _sharedCardRequestNotifier =
      ValueNotifier<ExternalCardRequest?>(null);

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  bool _adLoadStarted = false;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.onNotificationClick = (quoteText) {
      if (quoteText.isNotEmpty) {
        _switchToCardMakerWithText(quoteText, sourceName: '아침알림');
      }
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_adLoadStarted) {
      _adLoadStarted = true;
      _loadBannerAd();
    }
  }

  Future<void> _loadBannerAd() async {
    final width = MediaQuery.of(context).size.width.truncate();
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    if (size == null) {
      debugPrint('Unable to get width of anchored banner.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: AdService().bannerAdUnitId,
      size: size,
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
    await _bannerAd?.load();
  }

  @override
  void dispose() {
    NotificationService.instance.onNotificationClick = null;
    _sharedTextNotifier.dispose();
    _sharedBgPathNotifier.dispose();
    _sharedCardNotifier.dispose();
    _sharedCardRequestNotifier.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _switchToCardMakerWithText(
    String text, {
    String? sourceName,
  }) {
    _sharedCardRequestNotifier.value = ExternalCardRequest(
      text: text,
      bgPath: null, // 기존 마음카드 배경 100% 보존 (배경 바꾸지 않음)
      category: null,
      sourceName: sourceName,
      requestId: DateTime.now().microsecondsSinceEpoch,
    );
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
        sharedBgPathNotifier: _sharedBgPathNotifier,
        sharedCardNotifier: _sharedCardNotifier,
        sharedCardRequestNotifier: _sharedCardRequestNotifier,
      ),
      WisdomScreen(
        onShareAsCard: (cardText, {bgPath, category, sourceName}) {
          _switchToCardMakerWithText(
            cardText,
            sourceName: sourceName ?? '명언',
          );
        },
      ),
      HealthScreen(
        onShareAsCard: (cardText, {bgPath, category, sourceName}) {
          _switchToCardMakerWithText(
            cardText,
            sourceName: sourceName ?? '건강',
          );
        },
      ),
      CardArchiveScreen(onSelectCard: _openSavedCard),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFFFFDF9),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : const Color(0x148D6E63),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // 모든 탭 공통 하단 AdMob 배너 광고 (여백 없이 밀착 & 정돈된 구분선)
            if (_isBannerLoaded && _bannerAd != null)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withAlpha(25)
                          : const Color(0xFFE8E0D5),
                      width: 0.8,
                    ),
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withAlpha(15)
                          : const Color(0xFFEFE8DE),
                      width: 0.6,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: Center(
                    child: AdWidget(
                      key: ValueKey(_bannerAd!),
                      ad: _bannerAd!,
                    ),
                  ),
                ),
              ),
            BottomNavigationBar(
              currentIndex: _currentIndex,
              elevation: 0,
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
              backgroundColor: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFFFFDF9),
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
          ],
        ),
      ),
      ),
    );
  }
}
