import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
        text: '[마음카드] 소중한 분이 보낸 안부 인사입니다.',
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
      final bool hasAccess = await Gal.requestAccess(toAlbum: true);
      if (hasAccess) {
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('사진첩 접근 권한이 필요합니다.', style: TextStyle(fontSize: 16, color: Colors.white)),
              backgroundColor: Color(0xFFE64A19),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. 헤더 (닫기 버튼)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.close, size: 36, color: Color(0xFF424242)),
                  padding: const EdgeInsets.all(12),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            
            // 2. 메인 콘텐츠 (확대된 카드 및 카카오톡 전송 버튼)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    
                    // 완성 축하 타이틀
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🎉', style: TextStyle(fontSize: 28)),
                        SizedBox(width: 8),
                        Text(
                          '완성했어요!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2D1810),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('🎉', style: TextStyle(fontSize: 28)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // 폴라로이드 액자 뷰 (카드 결과물)
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 36),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 15,
                              offset: Offset(0, 10),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
                    
                    const SizedBox(height: 32),
                    
                    // 친절한 안내 문구
                    const Text(
                      '가족이나 지인에게 따뜻한 안부 인사를 건네보세요!',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 카카오톡 전송 버튼 (시니어 맞춤 대형 사이즈)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: InkWell(
                        onTap: _isSharing ? null : _shareToKakao,
                        borderRadius: BorderRadius.circular(38),
                        child: Container(
                          width: double.infinity,
                          height: 76,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE500),
                            borderRadius: BorderRadius.circular(38),
                            boxShadow: const [
                              BoxShadow(color: Color(0x33FEE500), blurRadius: 10, offset: Offset(0, 5)),
                            ],
                          ),
                          child: _isSharing
                              ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: Color(0xFF3E2723), strokeWidth: 3))
                              : const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.send_rounded, size: 36, color: Color(0xFF3E2723)),
                                      SizedBox(width: 12),
                                      Text(
                                        '카카오톡으로 전송',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF3E2723),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 기기 사진첩에 저장 버튼 (시니어 맞춤 대형 사이즈, 보조 버튼 스타일)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: InkWell(
                        onTap: _isSavingGallery ? null : _saveToGallery,
                        borderRadius: BorderRadius.circular(38),
                        child: Container(
                          width: double.infinity,
                          height: 76,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(38),
                            border: Border.all(color: const Color(0xFFDCDCDC), width: 2),
                            boxShadow: const [
                              BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 5)),
                            ],
                          ),
                          child: _isSavingGallery
                              ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: Color(0xFF424242), strokeWidth: 3))
                              : const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.photo_library_rounded, size: 32, color: Color(0xFF555555)),
                                      SizedBox(width: 12),
                                      Text(
                                        '내 폰 사진첩에 저장',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF555555),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 최하단 배너 광고 영역 (스토어 캡처 시 임시 숨김 지원)
            if (!AdService.hideBannerAdsForScreenshots && _isAdLoaded && _bannerAd != null)
              Padding(
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(key: ObjectKey(_bannerAd!), ad: _bannerAd!),
                ),
              )
            else
              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              ),
          ],
        ),
      ),
    );
  }
}
