import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../data/home_card_data.dart';
import '../services/card_archive_service.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart';

import '../utils/constants.dart';

import '../widgets/bottom_sheets/text_editor_bottom_sheet.dart';
import '../widgets/bottom_sheets/phrase_selection_bottom_sheet.dart';
import '../widgets/bottom_sheets/background_selection_bottom_sheet.dart';
import '../widgets/bottom_sheets/font_selection_bottom_sheet.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../widgets/premium_button.dart';
import '../widgets/maum_card.dart';
import 'card_archive_screen.dart';
import 'card_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final TextEditingController _textController = TextEditingController();

  String? _customImagePath;
  int _bgIndex = 0;
  int _fontScaleStep = 0; // 0: Auto, 1~10: 수동 단계
  
  bool _isBannerAdLoaded = false;
  BannerAd? _bannerAd;
  bool _isAdLoading = false;

  String _selectedFontFamily = 'Jua';

  Color _selectedTextColor = Colors.white;

  List<Map<String, String>> get _bgList => defaultBackgroundList;
  Map<String, List<String>> get _presetCategories => defaultPresetCategories;

  // AppConstants.quickEmojis 사용

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    
    // 알림 탭(Deep Link) 시 즉시 시간 기반 기본 카드로 강제 리프레시 (백그라운드에서 복귀할 때 대비)
    NotificationService.instance.onNotificationClick = (payload) {
      if (mounted) {
        // 어디에 있든(내 카드함 등) 모든 화면을 닫고 메인 화면으로 돌아옵니다.
        Navigator.of(context).popUntil((route) => route.isFirst);

        setState(() {
          if (payload.isNotEmpty && payload != 'morning_greeting') {
            _textController.text = payload;
          } else {
            _applyTimeBasedDefault();
          }
        });
      }
    };
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
    // 화면 가로 너비를 구해 좌우 꽉 차는 얇은 Adaptive Banner 사이즈 계산 (여백 없는 슬림 배너)
    final AnchoredAdaptiveBannerAdSize? size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
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
              _isBannerAdLoaded = true;
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
    _bannerAd?.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _applyTimeBasedDefault() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 5 && hour < 12) {
      // 아침 (05:00 ~ 11:59)
      _textController.text = "좋은 아침입니다! 오늘도 희망차고 활기찬 하루 되세요 ☀️";
      final idx = _bgList.indexWhere((bg) => bg['path']!.contains('autumn_cosmos') || bg['path']!.contains('autumn_persimmon'));
      _bgIndex = idx != -1 ? idx : 0;
    } else if (hour >= 12 && hour < 18) {
      // 오후 (12:00 ~ 17:59)
      _textController.text = "건강이 최고의 자산입니다. 오늘 하루도 소중히 챙기세요 💪";
      final idx = _bgList.indexWhere((bg) => bg['path']!.contains('autumn_ginkgo') || bg['path']!.contains('season_autumn'));
      _bgIndex = idx != -1 ? idx : 0;
    } else {
      // 저녁 / 밤 (18:00 ~ 04:59)
      _textController.text = "오늘 하루도 정말 수고 많으셨습니다. 편안한 밤 되세요 🌙";
      final idx = _bgList.indexWhere((bg) => bg['path']!.contains('sunset_lake') || bg['path']!.contains('aurora') || bg['name']!.contains('호수'));
      _bgIndex = idx != -1 ? idx : 0;
    }
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFontFamily = prefs.getString('saved_card_font_family');
    final savedFontStep = prefs.getInt('saved_card_font_step');
    final savedTextColor = prefs.getInt('saved_card_text_color');

    setState(() {
      // 앱이 처음 켜질 때 무조건 현재 시간대에 맞는 스마트 기본 카드로 리셋합니다.
      // (기존의 어제 작성하던 카드를 불러오는 로직 제거)
      _applyTimeBasedDefault();
      
      if (savedFontFamily != null) {
        _selectedFontFamily = savedFontFamily;
      }
      if (savedFontStep != null) {
        _fontScaleStep = savedFontStep;
      }
      if (savedTextColor != null) {
        _selectedTextColor = Color(savedTextColor);
      }
    });
  }

  Future<void> _saveUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // 세션 중 배경/텍스트 변경은 상태(State)로만 유지하며, 
    // 로컬 디스크에는 앱을 껐다 켜도 계속 유지되어야 할 글로벌 설정(폰트 등)만 저장합니다.
    await prefs.setString('saved_card_font_family', _selectedFontFamily);
    await prefs.setInt('saved_card_font_step', _fontScaleStep);
    await prefs.setInt('saved_card_text_color', _selectedTextColor.toARGB32());
  }

  ImageProvider _getBackgroundImageProvider() {
    if (_customImagePath != null) {
      final file = File(_customImagePath!);
      if (file.existsSync()) return FileImage(file);
    }
    return AssetImage(_bgList[_bgIndex]['path']!);
  }

  TextStyle _getAppliedTextStyle({double fontSize = 30.0, double height = 1.4, FontWeight fontWeight = FontWeight.bold}) {
    final fontConfig = AppConstants.seniorFonts.firstWhere(
      (f) => f['id'] == _selectedFontFamily,
      orElse: () => AppConstants.seniorFonts.first,
    );
    return (fontConfig['font'] as TextStyle).copyWith(
      fontSize: fontSize,
      color: _selectedTextColor,
      height: height,
      fontWeight: fontWeight,
      fontFamilyFallback: const ['Apple Color Emoji', 'Segoe UI Emoji', 'Noto Color Emoji'],
    );
  }



  Future<void> _pickCustomImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _customImagePath = image.path;
      });
      _saveUserPreferences();
    }
  }

  // 자동 글자 크기(단계) 계산 헬퍼
  int _calculateAutoFontStep(String text) {
    final rawText = text.trim();
    if (rawText.isEmpty) return 8;
    final lineCount = rawText.split('\n').length;
    final len = rawText.length;
    
    if (lineCount >= 6 || len >= 60) return 1; // 20.0
    if (lineCount == 5 || len >= 50) return 2; // 24.0
    if (lineCount == 4 || len >= 40) return 4; // 32.0
    if (lineCount == 3 || len >= 30) return 5; // 36.0
    if (lineCount == 2 || len >= 20) return 7; // 44.0
    if (len >= 10) return 8;                   // 48.0
    return 10;                                 // 56.0
  }

  // 텍스트 직접 수정 모달
  void _showTextEditorDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return TextEditorBottomSheet(
          textController: _textController,
          fontScaleStep: _fontScaleStep,
          selectedTextColor: _selectedTextColor,
          backgroundImage: _getBackgroundImageProvider(),
          getTextStyle: ({double fontSize = 30.0, double height = 1.4, FontWeight fontWeight = FontWeight.bold}) {
            return _getAppliedTextStyle(fontSize: fontSize, height: height, fontWeight: fontWeight);
          },
          calculateAutoFontStep: _calculateAutoFontStep,
          onFontScaleStepChanged: (newStep) => _fontScaleStep = newStep,
          onTextColorChanged: (newColor) => _selectedTextColor = newColor,
          onStateChanged: () => setState(() {}),
          onSaveUserPreferences: _saveUserPreferences,
        );
      },
    );
  }

  void _showPhraseSelectionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return PhraseSelectionBottomSheet(
          currentPhrase: _textController.text.trim(),
          presetCategories: _presetCategories,
          onPhraseSelected: (text) {
            setState(() {
              _textController.text = text;
              _fontScaleStep = 0;
            });
          },
          onSaveUserPreferences: _saveUserPreferences,
        );
      },
    );
  }

  void _showBackgroundSelectionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return BackgroundSelectionBottomSheet(
          bgList: _bgList,
          currentBgIndex: _bgIndex,
          customImagePath: _customImagePath,
          onBgSelected: (index) {
            setState(() {
              _bgIndex = index;
              _customImagePath = null;
            });
          },
          onCustomImageRequested: () {
            Navigator.pop(context);
            _pickCustomImage();
          },
          onSaveUserPreferences: _saveUserPreferences,
        );
      },
    );
  }

  void _showFontSelectionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return FontSelectionBottomSheet(
          selectedFontFamily: _selectedFontFamily,
          onFontSelected: (fontFamily) {
            setState(() {
              _selectedFontFamily = fontFamily;
            });
          },
          onSaveUserPreferences: _saveUserPreferences,
        );
      },
    );
  }

  bool _isCompleting = false;

  Future<void> _completeCard() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    HapticFeedback.mediumImpact();

    // 시니어 사용자를 위한 큼직하고 친절하며 품격 있는 카드 제작 중(로딩) 다이얼로그
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (BuildContext dialogContext) {
        return const LoadingDialogWidget();
      },
    );

    try {
      // 심리적 성취감과 만족감을 위한 인위적 딜레이 (1.2초)
      await Future.delayed(const Duration(milliseconds: 1200));

      Uint8List? imageBytes = await _screenshotController.capture(pixelRatio: 1.5);
      if (imageBytes != null && imageBytes.isNotEmpty) {
        final directory = await getTemporaryDirectory();
        final fileName = 'good_morning_${DateTime.now().millisecondsSinceEpoch}.png';
        final imagePath = '${directory.path}/$fileName';
        final file = File(imagePath);
        await file.writeAsBytes(imageBytes);

        // Save to Archive
        final card = SavedCard(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: _textController.text,
          backgroundPath: _customImagePath ?? _bgList[_bgIndex]['path']!,
          textColorValue: _selectedTextColor.toARGB32(),
          borderColorValue: null,
          fontSize: 32.0, // Legacy support, no longer strictly used
          fontFamily: _selectedFontFamily,
          fontStep: _fontScaleStep,
          createdAt: DateTime.now(),
        );
        await CardArchiveService().saveCard(card);

        if (!mounted) return;
        
        Navigator.pop(context); // 로딩 다이얼로그 닫기

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CardResultScreen(imagePath: imagePath)),
        );
      }
    } catch (e) {
      debugPrint('Capture Error: $e');
      if (mounted) Navigator.pop(context); // 에러 발생 시 다이얼로그 닫기
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. 글자 수 기반 동적 폰트 크기(Dynamic Font Size) 로직 또는 수동 지정 로직
    final fontSizes = [20.0, 24.0, 28.0, 32.0, 36.0, 40.0, 44.0, 48.0, 52.0, 56.0];
    final lineHeights = [1.5, 1.48, 1.45, 1.42, 1.38, 1.35, 1.32, 1.28, 1.25, 1.2];
    
    int activeStep = _fontScaleStep;
    if (activeStep == 0) {
      activeStep = _calculateAutoFontStep(_textController.text);
    }
    
    int idx = (activeStep - 1).clamp(0, 9);
    double dynamicFontSize = fontSizes[idx];
    double dynamicHeight = lineHeights[idx];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. 프리미엄 커스텀 앱바 (AppBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 0.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 9.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 브랜드 로고 뱃지
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33FF5E62),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '마음카드',
                              style: GoogleFonts.gowunBatang(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.6,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CardArchiveScreen(
                            onSelectCard: (card) {
                              setState(() {
                                _textController.text = card.message;
                                if (card.backgroundPath.startsWith('/')) {
                                  _customImagePath = card.backgroundPath;
                                } else {
                                  final idx = _bgList.indexWhere((bg) => bg['path'] == card.backgroundPath);
                                  if (idx != -1) {
                                    _bgIndex = idx;
                                    _customImagePath = null;
                                  }
                                }
                                if (card.fontFamily != null) {
                                  _selectedFontFamily = card.fontFamily!;
                                }
                                if (card.fontStep != null) {
                                  _fontScaleStep = card.fontStep!;
                                }
                                _selectedTextColor = Color(card.textColorValue);
                              });
                              _saveUserPreferences();
                              
                              Navigator.pop(context); // Close archive screen
                              
                              // 보관함에서 선택한 카드를 즉시 완성 화면으로 전달
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _completeCard();
                              });
                            },
                          )));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5A2B), Color(0xFF6B4226)], // 따뜻하고 고급스러운 브라운 톤
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x2E6B4226),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFF5C3A21), width: 0.8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bookmark_rounded, color: Color(0xFFFFD700), size: 19),
                              SizedBox(width: 5),
                              Text(
                                '내카드함',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. 메인 콘텐츠 (카드 뷰 + 수정 바 + 보조 버튼 그룹 일체형 통합)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ① [동그라미 1] 앱바와 카드 사이 간격
                      const SizedBox(height: 12),

                      // 캔버스 (화면 캡처 영역) — MaumCard 위젯 import
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: GestureDetector(
                          onTap: _showTextEditorDialog,
                          child: MaumCard(
                            text: _textController.text,
                            backgroundImage: _getBackgroundImageProvider(),
                            textStyle: _getAppliedTextStyle(
                              fontSize: dynamicFontSize,
                              height: dynamicHeight,
                              fontWeight: FontWeight.bold,
                            ),
                            screenshotController: _screenshotController,
                          ),
                        ),
                      ),
                      
                      // ② [동그라미 2] 카드와 글씨 수정 바 사이 간격
                      const SizedBox(height: 12),
                      
                      // 컴팩트 수정 바
                      InkWell(
                        onTap: _showTextEditorDialog,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          height: 56, // 하단 기능 버튼(PremiumButtonWidget)과 동일한 높이로 통일
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF6ED), // 연한 웜톤(오렌지) 배경으로 터치 유도
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFE4C4)), 
                            boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_rounded, color: Color(0xFFE05220), size: 22),
                                  SizedBox(width: 8),
                                  Text('터치해서 글씨 수정하기', style: TextStyle(fontSize: 16, color: Color(0xFFE05220), fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ③ [동그라미 3] 글씨 수정 바와 추천 문구 버튼 사이 간격
                      const SizedBox(height: 12),

                      // 통일된 보조 버튼 그룹 (추천 문구, 배경 사진, 글씨체)
                      Row(
                        children: [
                          Expanded(
                            child: PremiumButtonWidget(
                              icon: Icons.auto_awesome,
                              label: '추천 문구',
                              gradient: const LinearGradient(colors: [Color(0xFFFF8A65), Color(0xFFE64A19)]), // 따뜻한 코랄/오렌지 (포근함)
                              onTap: _showPhraseSelectionDialog,
                            ),
                          ),
                        ],
                      ),

                      // ④ [동그라미 4] 추천 문구 버튼과 배경 사진/글씨체 버튼 사이 간격
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: PremiumButtonWidget(
                              icon: Icons.image,
                              label: '배경 사진',
                              gradient: const LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)]), // 화사한 포레스트 그린 (자연)
                              onTap: _showBackgroundSelectionDialog,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PremiumButtonWidget(
                              icon: Icons.font_download,
                              label: '글씨체',
                              gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1565C0)]), // 차분한 스카이블루 (신뢰/맑음)
                              onTap: _showFontSelectionDialog,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24), // 스크롤 시 버튼 아래에 충분한 공백(여백)
                    ],
                  ),
                ),
              ),
            ),
      // 💡 하단 고정 영역 (스크롤 침범 원천 차단 및 소프트키 겹침 방지 일체형 통합 독)
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
          border: const Border(
            top: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 카드 완성하기 메인 액션 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isCompleting ? null : _completeCard,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: double.infinity,
                      height: 68,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFDE00), Color(0xFFFACC15)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x38F59E0B),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 28, color: Color(0xFF2D1A0E)),
                            SizedBox(width: 10),
                            Text(
                              '카드 완성하기',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2D1A0E),
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
              // 2. 최하단 배너 광고 영역 (통합 독 내부 밀착 일체형 배치)
              if (!AdService.hideBannerAdsForScreenshots && _isBannerAdLoaded && _bannerAd != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(key: ObjectKey(_bannerAd!), ad: _bannerAd!),
                  ),
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
