import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ad_service.dart';
import '../services/kakao_share_helper.dart';

class CardResultScreen extends StatefulWidget {
  final String imagePath;
  
  const CardResultScreen({super.key, required this.imagePath});

  @override
  State<CardResultScreen> createState() => _CardResultScreenState();
}

class _CardResultScreenState extends State<CardResultScreen> with WidgetsBindingObserver {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isSharing = false;
  bool _isSavingGallery = false;
  bool _isSharingTriggered = false; // 카카오톡 공유 진입 여부 플래그

  bool _isAdLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInterstitialAd(); // 백그라운드에서 전면 광고 사전 로드
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdService().interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd loaded in CardResultScreen.');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          // Silent Fail: 에러 팝업 띄우지 않음
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 사용자가 카카오톡에서 돌아왔을 때 (AppLifecycleState.resumed)
    if (state == AppLifecycleState.resumed) {
      if (_isSharingTriggered) {
        _isSharingTriggered = false; // 플래그 즉시 초기화 (오작동 방지)
        _showInterstitialAd();
      }
    }
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('InterstitialAd dismissed.');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd(); // 다음 사용을 위해 재로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('InterstitialAd failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        // Silent Fail
      },
    );

    _interstitialAd!.show();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null && !_isAdLoading) {
      _isAdLoading = true;
      _loadAdaptiveBannerAd();
    }
  }

  Future<void> _loadAdaptiveBannerAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      _isAdLoading = false;
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: AdService().bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isAdLoading = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
          _isAdLoading = false;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Observer 해제
    _interstitialAd?.dispose(); // 메모리 정리 누락 방지
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _shareToKakao() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      _isSharingTriggered = true; // 공유 동작 시작 플래그 세팅
      await KakaoShareHelper.share(
        filePath: widget.imagePath,
        text: '[마음카드] 소중한 분이 진심을 담아 보낸 카드입니다.',
      );
    } catch (e) {
      debugPrint('Share Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('카카오톡 공유 중 오류가 발생했습니다. 다시 시도해 주세요.', style: TextStyle(fontSize: 16)),
            backgroundColor: Color(0xFFE64A19),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _saveToGallery() async {
    if (_isSavingGallery) return;
    setState(() => _isSavingGallery = true);
    HapticFeedback.mediumImpact();
    
    try {
      final bool hasAccess = await Gal.hasAccess(toAlbum: false);
      if (!hasAccess) {
        final bool granted = await Gal.requestAccess(toAlbum: false);
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('사진을 저장하려면 사진첩 접근 권한이 필요합니다.', style: TextStyle(fontSize: 16, color: Colors.white)),
                backgroundColor: Color(0xFFE64A19),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }

      await Gal.putImage(widget.imagePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('기기 사진첩에 저장되었습니다.', style: TextStyle(fontSize: 16, color: Colors.white)),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on GalException catch (e) {
      debugPrint('GalException during save: ${e.type}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.type == GalExceptionType.accessDenied 
                  ? '사진첩 접근 권한이 허용되지 않았습니다.' 
                  : '사진첩 저장 중 오류가 발생했습니다.', 
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            backgroundColor: const Color(0xFFE64A19),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Gallery save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('사진첩 저장 중 오류가 발생했습니다.', style: TextStyle(fontSize: 16, color: Colors.white)),
            backgroundColor: Color(0xFFE64A19),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingGallery = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.80).clamp(260.0, 340.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. 프리미엄 상단 네비게이션 헤더 바 (수정하기 / 카드완성 뱃지 / 처음으로)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 수정하기 버튼 (뒤로가기)
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x08000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: Color(0xFF334155)),
                                SizedBox(width: 4),
                                Text(
                                  '수정하기',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // 중앙 완성 뱃지
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🎉', style: TextStyle(fontSize: 13)),
                            SizedBox(width: 5),
                            Text(
                              '카드 완성',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB45309),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // 우측 닫기/처음으로 버튼
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x08000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.close_rounded, size: 18, color: Color(0xFF334155)),
                                SizedBox(width: 2),
                                Text(
                                  '닫기',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 2. 메인 콘텐츠 (확대된 카드 및 전송 액션)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // 완성 축하 타이틀
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        '카드가 완성되었어요!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.gowunBatang(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        '소중한 분에게 따뜻한 마음을 선물해보세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    
                    // 프리미엄 명화 액자 프레임 뷰 (0.80 화면 폭으로 큼직하고 시원하게 확대)
                    Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.88, end: 1.0),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Container(
                          width: cardWidth,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x180F172A),
                                blurRadius: 24,
                                offset: Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Color(0x080F172A),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Image.file(
                                File(widget.imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // 고화질 카드 뱃지
                    Container(
                      margin: const EdgeInsets.only(top: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 4,
                            offset: Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                          SizedBox(width: 5),
                          Text(
                            '고화질 카드 제작 완료',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 1. 카카오톡 전송 버튼 (1순위 메인 버튼: 대형 70dp + 골든 옐로우 그라데이션)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isSharing ? null : () {
                            HapticFeedback.mediumImpact();
                            _shareToKakao();
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: double.infinity,
                            height: 70,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFEE500), Color(0xFFFFDE00)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFF5C518), width: 1.2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x35F59E0B),
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: _isSharing
                                ? const SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(color: Color(0xFF191919), strokeWidth: 3),
                                  )
                                : const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send_rounded, size: 30, color: Color(0xFF191919)),
                                        SizedBox(width: 10),
                                        Text(
                                          '카카오톡으로 전송',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF191919),
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 2. 기기 사진첩에 저장 버튼 (2순위 버튼: 70dp + 프리미엄 딥 다크 네이비 그라데이션)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isSavingGallery ? null : () {
                            HapticFeedback.lightImpact();
                            _saveToGallery();
                          },
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            width: double.infinity,
                            height: 70,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: const Color(0xFF334155), width: 1.2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x180F172A),
                                  blurRadius: 12,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: _isSavingGallery
                                ? const SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                  )
                                : const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.download_rounded, size: 28, color: Colors.white),
                                        SizedBox(width: 10),
                                        Text(
                                          '내 폰 사진첩에 저장',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    // 3. 하단 문구/배경 다시 수정하기 링크
                    Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFF64748B)),
                                SizedBox(width: 4),
                                Text(
                                  '문구나 배경 다시 수정하기',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // 최하단 배너 광고 영역 (스토어 캡처 시 임시 숨김 지원)
            if (!AdService.hideBannerAdsForScreenshots && _isAdLoaded && _bannerAd != null)
              Padding(
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: math.max(MediaQuery.of(context).padding.bottom, 6.0),
                ),
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(key: ObjectKey(_bannerAd!), ad: _bannerAd!),
                ),
              )
            else
              SizedBox(
                height: math.max(MediaQuery.of(context).padding.bottom, 8.0),
              ),
          ],
        ),
      ),
    );
  }
}
