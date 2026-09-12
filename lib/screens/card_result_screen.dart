import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../services/kakao_share_helper.dart';

class CardResultScreen extends StatefulWidget {
  final String imagePath;
  
  const CardResultScreen({super.key, required this.imagePath});

  @override
  State<CardResultScreen> createState() => _CardResultScreenState();
}

class _CardResultScreenState extends State<CardResultScreen> {
  BannerAd? _mediumRectangleAd;
  bool _isAdLoaded = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _loadMediumRectangleAd();
  }

  void _loadMediumRectangleAd() {
    _mediumRectangleAd = BannerAd(
      adUnitId: AdService().mediumRectangleAdUnitId,
      size: AdSize.mediumRectangle, // 300x250
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('MediumRectangleAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _mediumRectangleAd?.dispose();
    super.dispose();
  }

  Future<void> _shareToKakao() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
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
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    
                    // 2. 완성 축하 타이틀
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
                    
                    // 3. 폴라로이드 액자 뷰 (카드 결과물)
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
                    
                    // 4. 카카오톡 전송 버튼
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: InkWell(
                        onTap: _isSharing ? null : _shareToKakao,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE500),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(color: Color(0x33FEE500), blurRadius: 10, offset: Offset(0, 5)),
                            ],
                          ),
                          child: Center(
                            child: _isSharing
                                ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Color(0xFF3E2723), strokeWidth: 3))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.send_rounded, size: 28, color: Color(0xFF3E2723)),
                                      SizedBox(width: 10),
                                      Text(
                                        '카카오톡으로 전송',
                                        style: TextStyle(
                                          fontSize: 20,
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
                    const SizedBox(height: 40),
                    
                    // 5. 하단 인라인 광고 영역 (Medium Rectangle 300x250)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              const Text(
                                '광고',
                                style: TextStyle(fontSize: 12, color: Color(0xFFBDBDBD)),
                              ),
                              const SizedBox(height: 8),
                              if (_isAdLoaded && _mediumRectangleAd != null)
                                SizedBox(
                                  width: _mediumRectangleAd!.size.width.toDouble(),
                                  height: _mediumRectangleAd!.size.height.toDouble(),
                                  child: AdWidget(ad: _mediumRectangleAd!),
                                )
                              else
                                const SizedBox(
                                  width: 300,
                                  height: 250,
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
