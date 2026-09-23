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
import '../widgets/keep_all_text.dart';
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

  // 시니어 가독성 높은 폰트 9종 (인기 서체 3종 추가)
  final List<Map<String, dynamic>> _seniorFonts = [
    {'id': 'Jua', 'name': '두꺼운 고딕체', 'font': GoogleFonts.jua()},
    {'id': 'GowunBatang', 'name': '깔끔한 명조체', 'font': GoogleFonts.gowunBatang(fontWeight: FontWeight.bold)},
    {'id': 'NanumMyeongjo', 'name': '품격있는 나눔명조', 'font': GoogleFonts.nanumMyeongjo(fontWeight: FontWeight.bold)},
    {'id': 'SongMyung', 'name': '시(詩) 감성 송명체', 'font': GoogleFonts.songMyung()},
    {'id': 'DoHyeon', 'name': '굵직한 제목체', 'font': GoogleFonts.doHyeon()},
    {'id': 'NanumBrush', 'name': '정성스런 붓글씨', 'font': GoogleFonts.nanumBrushScript()},
    {'id': 'NanumPen', 'name': '따뜻한 펜글씨체', 'font': GoogleFonts.nanumPenScript()},
    {'id': 'GamjaFlower', 'name': '다정한 손글씨', 'font': GoogleFonts.gamjaFlower()},
    {'id': 'BlackHanSans', 'name': '시원시원 큰글씨', 'font': GoogleFonts.blackHanSans()},
  ];
  String _selectedFontFamily = 'Jua';

  List<Map<String, String>> get _bgList => defaultBackgroundList;
  Map<String, List<String>> get _presetCategories => defaultPresetCategories;

  // 어르신 맞춤형 자주 쓰는 안부 이모티콘 목록
  static const List<String> _quickEmojis = [
    '🌸', '☀️', '☕', '❤️', '✨', '🍀', '🙏', '🌿', '🌼', '🍁', '🌹', '😊', '🎉', '💖', '🕊️'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    
    // 알림 탭(Deep Link) 시 즉시 시간 기반 기본 카드로 강제 리프레시 (백그라운드에서 복귀할 때 대비)
    NotificationService.instance.onNotificationClick = (payload) {
      if (mounted) {
        setState(() {
          _applyTimeBasedDefault();
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
    
    // 이번 주(2026년 9월 27일 일요일 자정)까지는 무조건 추석 명절 테마 기본 세팅 적용
    if (now.isBefore(DateTime(2026, 9, 28))) {
      _textController.text = "둥근 보름달처럼 마음까지 넉넉하고 풍요로운 행복한 한가위 보내시길 바랍니다 🌕";
      final idx = _bgList.indexWhere((bg) => bg['path']!.contains('chuseok_moon') || bg['path']!.contains('chuseok'));
      _bgIndex = idx != -1 ? idx : 0;
      return;
    }

    final hour = now.hour;
    if (hour >= 5 && hour < 12) {
      // 아침 (05:00 ~ 11:59)
      _textController.text = "좋은 아침입니다! 오늘도 희망차고 활기찬 하루 되세요 ☀️";
      final idx = _bgList.indexWhere((bg) => bg['path']!.contains('hydrangea') || bg['path']!.contains('wildflowers'));
      _bgIndex = idx != -1 ? idx : 0;
    } else if (hour >= 12 && hour < 18) {
      // 오후 (12:00 ~ 17:59)
      _textController.text = "건강이 최고의 자산입니다. 오늘 하루도 소중히 챙기세요 💪";
      final idx = _bgList.indexWhere((bg) => bg['path']!.contains('green_forest') || bg['path']!.contains('meadow'));
      _bgIndex = idx != -1 ? idx : 0;
    } else {
      // 저녁 / 밤 (18:00 ~ 04:59)
      _textController.text = "오늘 하루도 정말 수고 많으셨습니다. 편안한 밤 되세요 🌙";
      final idx = _bgList.indexWhere((bg) => bg['path']!.contains('sunset_lake') || bg['path']!.contains('moonlight') || bg['name']!.contains('호수'));
      _bgIndex = idx != -1 ? idx : 0;
    }
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFontFamily = prefs.getString('saved_card_font_family');
    final savedFontStep = prefs.getInt('saved_card_font_step');

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
    });
  }

  Future<void> _saveUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // 세션 중 배경/텍스트 변경은 상태(State)로만 유지하며, 
    // 로컬 디스크에는 앱을 껐다 켜도 계속 유지되어야 할 글로벌 설정(폰트 등)만 저장합니다.
    await prefs.setString('saved_card_font_family', _selectedFontFamily);
    await prefs.setInt('saved_card_font_step', _fontScaleStep);
  }

  ImageProvider _getBackgroundImageProvider() {
    if (_customImagePath != null) {
      final file = File(_customImagePath!);
      if (file.existsSync()) return FileImage(file);
    }
    return AssetImage(_bgList[_bgIndex]['path']!);
  }

  TextStyle _getAppliedTextStyle({double fontSize = 30.0, double height = 1.4, FontWeight fontWeight = FontWeight.bold}) {
    final fontConfig = _seniorFonts.firstWhere(
      (f) => f['id'] == _selectedFontFamily,
      orElse: () => _seniorFonts.first,
    );
    return (fontConfig['font'] as TextStyle).copyWith(
      fontSize: fontSize,
      color: Colors.white,
      height: height,
      fontWeight: fontWeight,
      shadows: [
        const Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(2, 2)),
      ],
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
    int effectiveStep = _fontScaleStep;
    if (effectiveStep == 0) {
      effectiveStep = _calculateAutoFontStep(_textController.text);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModalHeader(
                      context: context,
                      icon: Icons.edit_rounded,
                      gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      title: '문구 직접 수정하기',
                      subtitle: '전하고 싶은 따뜻한 마음을 직접 적어보세요',
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 16,
                        bottom: 24 + MediaQuery.of(context).padding.bottom,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _textController,
                            maxLines: 4,
                            autofocus: false,
                            style: const TextStyle(fontSize: 20, height: 1.6, color: Color(0xFF3E2723), fontWeight: FontWeight.w500),
                            onChanged: (_) {
                              setState(() {});
                              _saveUserPreferences();
                            },
                            decoration: InputDecoration(
                              hintText: '여기에 따뜻한 마음을 듬뿍 담아 적어보세요.',
                              hintStyle: const TextStyle(fontSize: 18, color: Color(0xFF999999)),
                              filled: true,
                              fillColor: const Color(0xFFF7F8FA),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEAEAEA))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEAEAEA))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
                              contentPadding: const EdgeInsets.all(20),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // 자주 쓰는 안부 이모티콘 퀵 바
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.sentiment_satisfied_alt_rounded, size: 16, color: Color(0xFF6366F1)),
                                  SizedBox(width: 5),
                                  Text(
                                    '자주 쓰는 안부 이모티콘 (누르면 입력돼요)',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF475569),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 50,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _quickEmojis.length,
                                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    final emoji = _quickEmojis[index];
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          final text = _textController.text;
                                          final selection = _textController.selection;
                                          if (selection.isValid && selection.start >= 0) {
                                            final newText = text.replaceRange(selection.start, selection.end, emoji);
                                            _textController.value = TextEditingValue(
                                              text: newText,
                                              selection: TextSelection.collapsed(offset: selection.start + emoji.length),
                                            );
                                          } else {
                                            _textController.text = '$text$emoji';
                                            _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
                                          }
                                          setState(() {});
                                          setModalState(() {});
                                          _saveUserPreferences();
                                        },
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x08000000),
                                                blurRadius: 4,
                                                offset: Offset(0, 1.5),
                                              ),
                                            ],
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            emoji,
                                            style: const TextStyle(fontSize: 22),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // 스텝형 글자 크기 조절기
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('글자 크기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                              Row(
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: effectiveStep > 1 ? () {
                                      FocusScope.of(context).unfocus(); // 💡 글자 크기 조절 시 키보드 내리기
                                      HapticFeedback.lightImpact();
                                      setModalState(() => effectiveStep--);
                                      setState(() => _fontScaleStep = effectiveStep);
                                      _saveUserPreferences();
                                    } : null,
                                    child: Opacity(
                                      opacity: effectiveStep > 1 ? 1.0 : 0.35,
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F2F5),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: const Color(0xFFEAEAEA)),
                                        ),
                                        child: const Center(child: Icon(Icons.remove_rounded, color: Color(0xFF2A2D34), size: 28)),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 80,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$effectiveStep단계',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                                    ),
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: effectiveStep < 10 ? () {
                                      FocusScope.of(context).unfocus(); // 💡 글자 크기 조절 시 키보드 내리기
                                      HapticFeedback.lightImpact();
                                      setModalState(() => effectiveStep++);
                                      setState(() => _fontScaleStep = effectiveStep);
                                      _saveUserPreferences();
                                    } : null,
                                    child: Opacity(
                                      opacity: effectiveStep < 10 ? 1.0 : 0.35,
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F2F5),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: const Color(0xFFEAEAEA)),
                                        ),
                                        child: const Center(child: Icon(Icons.add_rounded, color: Color(0xFF2A2D34), size: 28)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF334155),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 2,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('수정 완료', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _showPhraseSelectionDialog() {
    // 현재 메인에 적용된 문구가 속한 카테고리 자동 탐색
    final currentPhrase = _textController.text.trim();
    String? matchedCategory;
    for (final entry in _presetCategories.entries) {
      if (entry.value.any((p) => p.trim() == currentPhrase)) {
        matchedCategory = entry.key;
        break;
      }
    }

    String selectedCategory = '전체';
    if (matchedCategory != null) {
      selectedCategory = matchedCategory;
    } else {
      // 매칭되는 프리셋이 없을 경우 시간대별 스마트 타겟팅
      final hour = DateTime.now().hour;
      if (hour >= 6 && hour < 12) {
        selectedCategory = '🌅 아침 인사 & 덕담';
      } else if (hour >= 18) {
        selectedCategory = '🌙 저녁 & 안부 인사';
      }
    }

    final ScrollController listScrollController = ScrollController();
    final GlobalKey selectedPhraseKey = GlobalKey();
    
    // 시니어 가독성을 위한 필터용 짧은 라벨 매핑
    final categoryMap = {
      '전체': '전체',
      '🌕 명절 인사': '🌕 명절 (추석·설날)',
      '🌅 아침 인사': '🌅 아침 인사 & 덕담',
      '💖 건강 & 무병장수': '💖 건강 & 무병장수',
      '🌙 저녁 & 안부': '🌙 저녁 & 안부 인사',
      '📜 명언 & 지혜': '📜 오늘의 명언 & 지혜',
      '🎉 축하 & 감사': '🎂 축하 & 감사',
    };
    
    // 칩 스크롤 연동을 위한 글로벌 키 맵
    final chipKeys = { for (var k in categoryMap.keys) k: GlobalKey() };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        // 다이얼로그 진입 시 선택된 카테고리 칩 및 문구 카드로 스크롤 자동 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final matchingEntry = categoryMap.entries.firstWhere(
            (e) => e.value == selectedCategory,
            orElse: () => const MapEntry('전체', '전체'),
          );
          final chipContext = chipKeys[matchingEntry.key]?.currentContext;
          if (chipContext != null) {
            Scrollable.ensureVisible(
              chipContext,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.5,
            );
          }

          if (selectedPhraseKey.currentContext != null) {
            Scrollable.ensureVisible(
              selectedPhraseKey.currentContext!,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              alignment: 0.25,
            );
          }
        });

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            
            // 선택된 카테고리에 맞춰 하단 카드 리스트 동적 구성
            List<Widget> listItems = [];
            for (final entry in categoryMap.entries) {
              if (entry.key == '전체') continue;
              final actualKey = entry.value;
              
              if (selectedCategory == '전체' || selectedCategory == actualKey) {
                // 전체 모드일 때는 각 카테고리 헤더를 노출
                if (selectedCategory == '전체') {
                  listItems.add(
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 8),
                      child: Text(entry.key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                    ),
                  );
                } else {
                  listItems.add(const SizedBox(height: 16));
                }
                
                // 해당 카테고리의 문구들을 독립형 카드로 렌더링
                for (final text in _presetCategories[actualKey]!) {
                  final isSelected = text.trim() == currentPhrase;
                  listItems.add(
                    Padding(
                      key: isSelected ? selectedPhraseKey : null,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFEAEAEA),
                            width: isSelected ? 2.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected ? const Color(0x242563EB) : const Color(0x08000000),
                              blurRadius: isSelected ? 10 : 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            highlightColor: const Color(0xFFEAECEF),
                            splashColor: const Color(0xFFEAECEF).withValues(alpha: 0.5),
                            onTap: () {
                              Future.delayed(const Duration(milliseconds: 150), () {
                                if (!mounted) return;
                                setState(() {
                                  _textController.text = text;
                                  _fontScaleStep = 0; // 새 문구 선택 시 동적 폰트 크기로 리셋
                                  if (actualKey == '🌙 저녁 & 안부 인사') {
                                    _customImagePath = null;
                                    final nightIdx = _bgList.indexWhere((bg) => bg['name']!.contains('호수') || bg['name']!.contains('커피'));
                                    if (nightIdx != -1) _bgIndex = nightIdx;
                                  } else if (actualKey == '🌅 아침 인사 & 덕담') {
                                    _customImagePath = null;
                                    _bgIndex = 0;
                                  }
                                });
                                _saveUserPreferences();
                                if (!context.mounted) return;
                                Navigator.pop(context);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: KeepAllText(
                                      text, 
                                      style: TextStyle(
                                        fontSize: 20, 
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF333333), 
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2563EB),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(color: Color(0x292563EB), blurRadius: 4, offset: Offset(0, 2)),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            '선택됨',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    const Icon(Icons.chevron_right_rounded, color: Color(0xFFBDBDBD), size: 28),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                }
              }

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  // 1. 공통 헤더 (그랩 핸들, 타이틀, 닫기 버튼)
                  _buildModalHeader(
                    context: context,
                    icon: Icons.chat_bubble_rounded,
                    gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    title: '추천 문구 고르기',
                    subtitle: '상황에 맞는 따뜻한 안부 문구를 골라보세요',
                  ),
                  
                  // 2. 상단 가로 스크롤 칩 필터 영역
                  SizedBox(
                    height: 60, // 여백 포함 칩 영역 높이
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: categoryMap.entries.map((entry) {
                          final label = entry.key;
                          final actualKey = entry.value;
                          final isSelected = selectedCategory == actualKey;
                          
                          return Padding(
                            key: chipKeys[label],
                            padding: const EdgeInsets.only(right: 8),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: () {
                                  setModalState(() {
                                    selectedCategory = actualKey;
                                  });
                                  // 카테고리 변경 시 즉시 상단 리셋
                                  if (listScrollController.hasClients) {
                                    listScrollController.jumpTo(0);
                                  }
                                  // 화면 밖의 칩을 눌렀을 때 부드럽게 가운데로 포커스 이동
                                  final chipContext = chipKeys[label]?.currentContext;
                                  if (chipContext != null) {
                                    Scrollable.ensureVisible(
                                      chipContext, 
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      alignment: 0.5, // 칩을 가운데 위치로
                                    );
                                  }
                                },
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 44),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF2A2D34) : const Color(0xFFF0F2F5),
                                    borderRadius: BorderRadius.circular(22),
                                    border: isSelected ? null : Border.all(color: const Color(0xFFE2E5EA), width: 1),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: isSelected ? 16 : 15,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? Colors.white : const Color(0xFF555555),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  // 미세 구분선
                  const Divider(thickness: 1, height: 1, color: Color(0xFFF0F0F0)),
                  
                  // 3. 필터링된 문구 리스트 영역
                  Expanded(
                    child: ListView(
                      controller: listScrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 24 + MediaQuery.of(context).padding.bottom),
                      children: listItems,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBackgroundSelectionDialog() {
    final currentBg = (_customImagePath == null && _bgIndex >= 0 && _bgIndex < _bgList.length)
        ? _bgList[_bgIndex]
        : null;
    final currentBgCategory = currentBg != null ? (currentBg['category'] ?? '전체') : '전체';
    String selectedCategory = currentBgCategory;

    final List<String> categories = ['전체'];
    for (var bg in _bgList) {
      final cat = bg['category'] ?? '기타';
      if (!categories.contains(cat)) {
        categories.add(cat);
      }
    }

    final bgChipKeys = { for (var cat in categories) cat: GlobalKey() };
    final GlobalKey selectedBgKey = GlobalKey();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 1. 카테고리 칩 자동 스크롤
          final chipContext = bgChipKeys[selectedCategory]?.currentContext;
          if (chipContext != null) {
            Scrollable.ensureVisible(
              chipContext,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.5,
            );
          }
          // 2. 선택된 배경 이미지 카드로 자동 스크롤
          if (selectedBgKey.currentContext != null) {
            Scrollable.ensureVisible(
              selectedBgKey.currentContext!,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              alignment: 0.25,
            );
          }
        });

        final isCustomSelected = _customImagePath != null;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModalHeader(
                    context: context,
                    icon: Icons.image_rounded,
                    gradientColors: const [Color(0xFF10B981), Color(0xFF047857)],
                    title: '사진 배경 고르기',
                    subtitle: '카드에 어울리는 아름다운 배경 사진을 골라보세요',
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickCustomImage();
                      },
                      icon: Icon(
                        isCustomSelected ? Icons.check_circle_rounded : Icons.photo_library_rounded,
                        size: 28,
                        color: isCustomSelected ? const Color(0xFF60A5FA) : Colors.white,
                      ),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isCustomSelected ? '내 앨범 사진 적용 중' : '내 앨범에서 사진 고르기',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          if (isCustomSelected) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('선택됨', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: isCustomSelected ? const Color(0xFF1E293B) : const Color(0xFF333333),
                        side: isCustomSelected ? const BorderSide(color: Color(0xFF2563EB), width: 2) : null,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 카테고리 필터 칩 목록
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = selectedCategory == cat;
                        return Padding(
                          key: bgChipKeys[cat],
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedCategory = cat;
                              });
                              final chipContext = bgChipKeys[cat]?.currentContext;
                              if (chipContext != null) {
                                Scrollable.ensureVisible(
                                  chipContext,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  alignment: 0.5,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1, height: 1, color: Color(0xFFEEEEEE)),
                  
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final Map<String, List<Map<String, dynamic>>> groupedBgs = {};
                        for (int i = 0; i < _bgList.length; i++) {
                          final bg = _bgList[i];
                          final category = bg['category'] ?? '기타';
                          
                          if (selectedCategory != '전체' && category != selectedCategory) {
                            continue;
                          }
                          
                          if (!groupedBgs.containsKey(category)) {
                            groupedBgs[category] = [];
                          }
                          groupedBgs[category]!.add({
                            'index': i,
                            'bg': bg,
                          });
                        }

                        return ListView.builder(
                          padding: EdgeInsets.only(
                            bottom: 20 + MediaQuery.of(context).padding.bottom
                          ),
                          itemCount: groupedBgs.keys.length,
                          itemBuilder: (context, sectionIndex) {
                            final category = groupedBgs.keys.elementAt(sectionIndex);
                            final items = groupedBgs[category]!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 19, 
                                      fontWeight: FontWeight.w700, 
                                      color: Color(0xFF333333)
                                    ),
                                  ),
                                ),
                                GridView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final globalIndex = items[index]['index'] as int;
                                    final item = items[index]['bg'] as Map<String, String>;
                                    final isSelected = _bgIndex == globalIndex && _customImagePath == null;
                                    return GestureDetector(
                                      key: isSelected ? selectedBgKey : null,
                                      onTap: () {
                                        setState(() {
                                          _bgIndex = globalIndex;
                                          _customImagePath = null;
                                        });
                                        _saveUserPreferences();
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          border: isSelected
                                              ? Border.all(color: const Color(0xFF2563EB), width: 3.5)
                                              : Border.all(color: const Color(0xFFEEEEEE), width: 1.2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isSelected ? const Color(0x332563EB) : const Color(0x0D000000),
                                              blurRadius: isSelected ? 8 : 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(13),
                                              child: Image.asset(
                                                item['path']!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            if (isSelected)
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF2563EB),
                                                    borderRadius: BorderRadius.circular(12),
                                                    boxShadow: const [
                                                      BoxShadow(color: Color(0x4D000000), blurRadius: 4, offset: Offset(0, 2)),
                                                    ],
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        '선택됨',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
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
                                  },
                                ),
                                if (sectionIndex < groupedBgs.keys.length - 1)
                                  const SizedBox(height: 16),
                              ],
                            );
                          },
                        );
                      }
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFontSelectionDialog() {
    final GlobalKey selectedFontKey = GlobalKey();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (selectedFontKey.currentContext != null) {
            Scrollable.ensureVisible(
              selectedFontKey.currentContext!,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.5,
            );
          }
        });

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModalHeader(
                context: context,
                icon: Icons.edit_note_rounded,
                gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                title: '예쁜 글씨체 고르기',
                subtitle: '읽기 편하고 정갈한 글씨체를 골라보세요',
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + MediaQuery.of(context).padding.bottom),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _seniorFonts.map((fontConfig) {
                        final isSelected = _selectedFontFamily == fontConfig['id'];
                        return Column(
                          children: [
                            Padding(
                              key: isSelected ? selectedFontKey : null,
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  setState(() {
                                    _selectedFontFamily = fontConfig['id'];
                                  });
                                  _saveUserPreferences();
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 64,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
                                      width: isSelected ? 2.5 : 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected ? const Color(0x1A2563EB) : const Color(0x06000000),
                                        blurRadius: isSelected ? 8 : 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          fontConfig['name'],
                                          style: (fontConfig['font'] as TextStyle).copyWith(
                                            fontSize: 22,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF222222),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2563EB),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                '선택됨',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ] else ...[
                                        const Icon(Icons.chevron_right_rounded, color: Color(0xFFBDBDBD), size: 28),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
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
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 36),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x29000000),
                  blurRadius: 32,
                  offset: Offset(0, 12),
                ),
              ],
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. 프리미엄 회전 링 & 중앙 마음 뱃지
                SizedBox(
                  width: 86,
                  height: 86,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 86,
                        height: 86,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5E62)),
                          backgroundColor: Color(0xFFFFEDD5),
                        ),
                      ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5E62).withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 2. 따뜻한 서브 헤더
                const Text(
                  '따뜻한 마음을 담아',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE11D48),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                // 3. 메인 타이틀 (고운바탕체 품격 있는 타이포)
                Text(
                  '예쁜 안부 카드를\n정성껏 만들고 있어요',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.gowunBatang(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    height: 1.42,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 18),
                // 4. 안내 캡슐 칩
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFEDD5), width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 15, color: Color(0xFFEA580C)),
                      SizedBox(width: 6),
                      Text(
                        '잠시만 기다려 주세요...',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC2410C),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // 심리적 성취감과 만족감을 위한 인위적 딜레이 (1.2초)
      await Future.delayed(const Duration(milliseconds: 1200));

      Uint8List? imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes != null && imageBytes.isNotEmpty) {
        final directory = await getTemporaryDirectory();
        final fileName = 'good_morning_${DateTime.now().millisecondsSinceEpoch}.webp';
        final imagePath = '${directory.path}/$fileName';
        final file = File(imagePath);
        await file.writeAsBytes(imageBytes);

        // Save to Archive
        final card = SavedCard(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: _textController.text,
          backgroundPath: _customImagePath ?? _bgList[_bgIndex]['path']!,
          textColorValue: Colors.white.toARGB32(),
          borderColorValue: null,
          fontSize: 32.0,
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

    // 2. 자동 줄바꿈 포맷팅 적용 (폰트 크기를 전달하여 동적으로 개행 기준 글자수 계산)
    final displayFormattedText = formatTextWithNaturalBreaks(_textController.text, fontSize: dynamicFontSize);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
            // 1. 프리미엄 커스텀 앱바 (AppBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 6.0),
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
                            const Text(
                              '따뜻한 아침 안부',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                                letterSpacing: -0.2,
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
                              });
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
                              colors: [Color(0xFF334155), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x2E1E293B),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFF475569), width: 0.8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bookmark_rounded, color: Color(0xFFFBBF24), size: 19),
                              SizedBox(width: 5),
                              Text(
                                '보관함',
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
              child: Align(
                alignment: const Alignment(0.0, -0.2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 캔버스 (화면 캡처 영역)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: GestureDetector(
                          onTap: _showTextEditorDialog,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 10)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Screenshot(
                                controller: _screenshotController,
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image(
                                        image: _getBackgroundImageProvider(),
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned.fill(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black.withValues(alpha: 0.35),
                                                Colors.black.withValues(alpha: 0.35),
                                                Colors.black.withValues(alpha: 0.35),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 3. 안전 영역 래핑 (Overflow 방지)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                                        child: Center(
                                          child: SingleChildScrollView(
                                            physics: const NeverScrollableScrollPhysics(),
                                            child: Text(
                                              displayFormattedText.keepAll,
                                              textAlign: TextAlign.center,
                                              style: _getAppliedTextStyle(
                                                fontSize: dynamicFontSize, 
                                                height: dynamicHeight,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 컴팩트 수정 바
                      InkWell(
                        onTap: _showTextEditorDialog,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_note, color: Color(0xFF757575), size: 24),
                                  SizedBox(width: 8),
                                  Text('여기를 눌러 문구와 글자 크기를 수정하세요', style: TextStyle(fontSize: 16, color: Color(0xFF757575), fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 통일된 보조 버튼 그룹 (추천 문구, 배경 사진, 글씨체)
                      Row(
                        children: [
                          Expanded(
                            child: _buildPremiumButton(
                              icon: Icons.auto_awesome,
                              label: '추천 문구',
                              gradient: const LinearGradient(colors: [Color(0xFF78716C), Color(0xFF57534E)]),
                              onTap: _showPhraseSelectionDialog,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPremiumButton(
                              icon: Icons.image,
                              label: '배경 사진',
                              gradient: const LinearGradient(colors: [Color(0xFF2F4F4F), Color(0xFF1A3636)]),
                              onTap: _showBackgroundSelectionDialog,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPremiumButton(
                              icon: Icons.font_download,
                              label: '글씨체',
                              gradient: const LinearGradient(colors: [Color(0xFF374151), Color(0xFF1F2937)]),
                              onTap: _showFontSelectionDialog,
                            ),
                          ),
                        ],
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
            );
          },
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

  // 프리미엄 바텀시트 공통 헤더
  Widget _buildModalHeader({
    required BuildContext context,
    required IconData icon,
    required List<Color> gradientColors,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. 그랩 핸들 (상단 중앙 바)
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        // 2. 타이틀 & 아이콘 뱃지 & 닫기 버튼 행
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 18, 12),
          child: Row(
            children: [
              // 세련된 아이콘 뱃지
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withAlpha(70),
                      blurRadius: 7,
                      offset: const Offset(0, 2.5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 타이틀 + 서브타이틀
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 프리미엄 닫기 버튼
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }

  // 통일된 56dp 이상 높이의 고대비 서브 버튼
  Widget _buildPremiumButton({required IconData icon, required String label, required Gradient gradient, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56, // 명확히 56dp 보장
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withAlpha(60),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
