import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../data/home_card_data.dart';
import '../widgets/home_effects.dart';
import '../services/ad_service.dart';
import '../services/card_archive_service.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../widgets/help_dialog.dart';
import '../widgets/share_preview_dialog.dart';
import '../widgets/notification_settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<String>? sharedTextNotifier;
  final ValueNotifier<String>? sharedBgPathNotifier;
  final ValueNotifier<SavedCard?>? sharedCardNotifier;
  final ValueNotifier<ExternalCardRequest?>? sharedCardRequestNotifier;

  const HomeScreen({
    super.key,
    this.sharedTextNotifier,
    this.sharedBgPathNotifier,
    this.sharedCardNotifier,
    this.sharedCardRequestNotifier,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  final TextEditingController _textController = TextEditingController();
  late final AnimationController _sparkleController;
  late final AnimationController _petalController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _notificationEnabled = true;
  String? _customImagePath;
  bool _hasReceivedExternalRequest = false;
  String? _lastSelectedBgCategoryTab;

  // Background Images with Categories & Titles from home_card_data.dart
  List<Map<String, String>> get _bgList => defaultBackgroundList;

  // Presets categorized for seniors from home_card_data.dart
  Map<String, List<String>> get _presetCategories => defaultPresetCategories;

  int _bgIndex = 0;
  double _fontSize = 32.0;
  Color _textColor = const Color(0xFFFFD700); // Golden Yellow
  Color? _borderColor = const Color(
    0xFFFFD700,
  ); // Border color (null = no border)
  String _selectedFontFamily = 'Jua';
  int _todayQuoteIndex = 0;

  // 5 Main Fast Text Colors
  final List<Map<String, dynamic>> _defaultColors = const [
    {'name': '황금색', 'color': Color(0xFFFFD700)},
    {'name': '순백색', 'color': Colors.white},
    {'name': '장미 빨강', 'color': Color(0xFFFF1744)},
    {'name': '코랄 핑크', 'color': Color(0xFFFF4081)},
    {'name': '에메랄드', 'color': Color(0xFF00E676)},
  ];

  static final List<Map<String, dynamic>> _koreanFontOptions = [
    {
      'id': 'Jua',
      'name': '주아체',
      'font': GoogleFonts.jua(),
    },
    {
      'id': 'DoHyeon',
      'name': '도현체',
      'font': GoogleFonts.doHyeon(),
    },
    {
      'id': 'NanumMyeongjo',
      'name': '나눔명조',
      'font': GoogleFonts.nanumMyeongjo(fontWeight: FontWeight.bold),
    },
    {
      'id': 'SongMyung',
      'name': '송명체',
      'font': GoogleFonts.songMyung(fontWeight: FontWeight.bold),
    },
    {
      'id': 'GowunBatang',
      'name': '고운바탕',
      'font': GoogleFonts.gowunBatang(fontWeight: FontWeight.bold),
    },
    {
      'id': 'YeonSung',
      'name': '연성체',
      'font': GoogleFonts.yeonSung(),
    },
    {
      'id': 'GamjaFlower',
      'name': '감자꽃',
      'font': GoogleFonts.gamjaFlower(fontSize: 15),
    },
    {
      'id': 'HiMelody',
      'name': '하이멜로디',
      'font': GoogleFonts.hiMelody(fontSize: 15),
    },
    {
      'id': 'PoorStory',
      'name': '푸어스토리',
      'font': GoogleFonts.poorStory(fontSize: 15),
    },
    {
      'id': 'Gaegu',
      'name': '개구체',
      'font': GoogleFonts.gaegu(fontWeight: FontWeight.bold),
    },
    {
      'id': 'SingleDay',
      'name': '싱글데이',
      'font': GoogleFonts.singleDay(fontSize: 15),
    },
    {
      'id': 'Dongle',
      'name': '동글체',
      'font': GoogleFonts.dongle(fontSize: 18, fontWeight: FontWeight.bold),
    },
    {
      'id': 'CuteFont',
      'name': '큐트폰트',
      'font': GoogleFonts.cuteFont(fontSize: 17, fontWeight: FontWeight.bold),
    },
    {
      'id': 'NanumPenScript',
      'name': '나눔손글씨',
      'font': GoogleFonts.nanumPenScript(fontSize: 16),
    },
    {
      'id': 'NanumBrushScript',
      'name': '붓글씨',
      'font': GoogleFonts.nanumBrushScript(fontSize: 15),
    },
    {
      'id': 'KirangHaerang',
      'name': '기랑해랑',
      'font': GoogleFonts.kirangHaerang(),
    },
    {
      'id': 'BlackHanSans',
      'name': '블랙한스',
      'font': GoogleFonts.blackHanSans(),
    },
    {
      'id': 'GowunDodum',
      'name': '고운돋움',
      'font': GoogleFonts.gowunDodum(),
    },
    {
      'id': 'Hahmlet',
      'name': '함렛체',
      'font': GoogleFonts.hahmlet(fontWeight: FontWeight.bold),
    },
    {
      'id': 'Sunflower',
      'name': '해바라기',
      'font': GoogleFonts.sunflower(fontWeight: FontWeight.bold),
    },
    {
      'id': 'NanumGothic',
      'name': '나눔고딕',
      'font': GoogleFonts.nanumGothic(fontWeight: FontWeight.bold),
    },
  ];

  bool _isDecorateExpanded = false;
  bool _isSharing = false;

  // Scroll Controller & Scroll Down Hint Indicator
  final ScrollController _bottomScrollController = ScrollController();
  late final AnimationController _bounceAnimationController;
  late final Animation<double> _bounceAnimation;
  bool _showScrollDownHint = true;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _bounceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 7).animate(
      CurvedAnimation(
        parent: _bounceAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _bottomScrollController.addListener(_onBottomScroll);

    if (widget.sharedTextNotifier != null &&
        widget.sharedTextNotifier!.value.isNotEmpty) {
      _textController.text = widget.sharedTextNotifier!.value;
    } else {
      final defaultList =
          _presetCategories['🌅 아침 인사 & 덕담'] ?? _presetCategories.values.first;
      _textController.text = defaultList.first;
    }
    widget.sharedTextNotifier?.addListener(_onExternalTextChange);
    widget.sharedBgPathNotifier?.addListener(_onExternalBgChange);
    widget.sharedCardNotifier?.addListener(_onSavedCardSelected);
    widget.sharedCardRequestNotifier?.addListener(_onExternalCardRequest);
    _checkInitialCardRequest();
    AdService().loadInterstitialAd();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('sound_enabled') ?? true;
    final notiEnabled = await NotificationService.instance.isNotificationEnabled();
    final isExpanded = prefs.getBool('decorate_expanded') ?? false;

    final savedText = prefs.getString('saved_card_text');
    final savedBgIndex = prefs.getInt('saved_card_bg_index');
    final savedFontSize = prefs.getDouble('saved_card_font_size');
    final savedTextColorVal = prefs.getInt('saved_card_text_color');
    final hasSavedBorder = prefs.containsKey('saved_card_border_color');
    final savedBorderColorVal = prefs.getInt('saved_card_border_color');
    final savedCustomImagePath = prefs.getString('saved_card_custom_image_path');
    final savedFontFamily = prefs.getString('saved_card_font_family');

    setState(() {
      _soundEnabled = enabled;
      _notificationEnabled = notiEnabled;
      _isDecorateExpanded = isExpanded;

      if (!_hasReceivedExternalRequest) {
        if (savedCustomImagePath != null && File(savedCustomImagePath).existsSync()) {
          _customImagePath = savedCustomImagePath;
        }

        if (widget.sharedTextNotifier == null ||
            widget.sharedTextNotifier!.value.isEmpty) {
          if (savedText != null && savedText.isNotEmpty) {
            _textController.text = savedText;
          }
        }
        if (savedBgIndex != null &&
            savedBgIndex >= 0 &&
            savedBgIndex < _bgList.length) {
          _bgIndex = savedBgIndex;
        }
        if (savedFontSize != null) {
          _fontSize = savedFontSize;
        }
      }
      if (savedFontFamily != null && savedFontFamily.isNotEmpty) {
        _selectedFontFamily = savedFontFamily;
      }
      if (savedTextColorVal != null) {
        _textColor = Color(savedTextColorVal);
      }
      if (hasSavedBorder && savedBorderColorVal != null) {
        _borderColor = Color(savedBorderColorVal);
      } else if (hasSavedBorder && savedBorderColorVal == null) {
        _borderColor = null;
      }
    });

    if (_soundEnabled) {
      Future.delayed(const Duration(milliseconds: 300), _startBgm);
    }
  }

  Future<void> _saveCardPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_card_text', _textController.text);
      await prefs.setInt('saved_card_bg_index', _bgIndex);
      await prefs.setDouble('saved_card_font_size', _fontSize);
      await prefs.setInt('saved_card_text_color', _textColor.toARGB32());
      await prefs.setString('saved_card_font_family', _selectedFontFamily);
      if (_customImagePath != null && File(_customImagePath!).existsSync()) {
        await prefs.setString('saved_card_custom_image_path', _customImagePath!);
      } else {
        await prefs.remove('saved_card_custom_image_path');
      }
      if (_borderColor != null) {
        await prefs.setInt('saved_card_border_color', _borderColor!.toARGB32());
      } else {
        await prefs.remove('saved_card_border_color');
      }
    } catch (e) {
      debugPrint('Error saving card preferences: $e');
    }
  }

  Future<void> _startBgm() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.55);
      await _audioPlayer.play(AssetSource('sounds/morning_bgm.mp3'));
      debugPrint('Morning BGM started playing successfully.');
    } catch (e) {
      debugPrint('BGM play error: $e');
    }
  }

  Future<void> _toggleSound() async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    final nextState = !_soundEnabled;
    setState(() {
      _soundEnabled = nextState;
    });
    await prefs.setBool('sound_enabled', nextState);
    if (nextState) {
      await _startBgm();
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '🌿 아침 새소리 힐링 배경음악이 켜졌습니다 🕊️',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2E7D32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      await _audioPlayer.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '🔇 배경음악이 꺼졌습니다',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF455A64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _openNotificationSettings() async {
    HapticFeedback.lightImpact();
    await NotificationSettingsDialog.show(context);
    final notiEnabled = await NotificationService.instance.isNotificationEnabled();
    if (mounted) {
      setState(() {
        _notificationEnabled = notiEnabled;
      });
    }
  }

  /// 텍스트 길이, 줄 수, 최장 줄 길이를 종합 고려하여 카드에 여백과 가독성이 가장 이상적인 황금비율 폰트 크기 계산
  double _calculateOptimalFontSize(String text) {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return 22.0;

    final lines = cleanText.split('\n');
    final totalChars = cleanText.replaceAll(RegExp(r'\s+'), '').length;
    final lineCount = lines.length;

    int maxLineLength = 0;
    for (final l in lines) {
      final len = l.trim().length;
      if (len > maxLineLength) maxLineLength = len;
    }

    // 글자 수, 줄 수, 최장 줄 길이에 따른 세심한 최적 폰트 스케일링
    if (totalChars <= 22 && lineCount <= 2 && maxLineLength <= 13) {
      return 23.0; // 짧은 아침 인사 (1~2줄)
    } else if (totalChars <= 42 && lineCount <= 3 && maxLineLength <= 15) {
      return 18.5; // 보통 덕담 (2~3줄)
    } else if (totalChars <= 75 && lineCount <= 5 && maxLineLength <= 14) {
      return 14.5; // 짧은 건강 꿀팁 및 명언 (4~5줄) -> 카드가 답답하지 않고 시원하게 여백 확보!
    } else if (totalChars <= 110 || lineCount <= 7 || maxLineLength >= 15) {
      return 13.0; // 건강 꿀팁(제목 포함 6~7줄) 및 명언 -> 가장 긴 제목 줄도 줄바꿈 없이 한 줄에 쏙 들어가도록!
    } else if (totalChars <= 150 || lineCount <= 9) {
      return 11.5; // 장문 시/명언 (8~9줄)
    } else {
      return 10.5; // 10줄 이상 장문
    }
  }

  void _checkInitialCardRequest() {
    if (widget.sharedCardRequestNotifier != null &&
        widget.sharedCardRequestNotifier!.value != null) {
      _onExternalCardRequest();
    }
  }

  void _onExternalCardRequest() {
    final req = widget.sharedCardRequestNotifier?.value;
    if (req == null) return;
    _hasReceivedExternalRequest = true;

    final formattedText = formatTextWithNaturalBreaks(req.text);
    final optimalFontSize = _calculateOptimalFontSize(formattedText);

    setState(() {
      _textController.text = formattedText;
      _fontSize = optimalFontSize;

      if (req.bgPath != null && req.bgPath!.isNotEmpty) {
        final index = _bgList.indexWhere((bg) => bg['path'] == req.bgPath);
        if (index >= 0) {
          _customImagePath = null;
          _bgIndex = index;
        }
      }
      if (req.category != null) {
        _lastSelectedBgCategoryTab = req.category;
      }
    });
    _saveCardPreferences();
  }

  void _onExternalTextChange() {
    if (widget.sharedTextNotifier != null &&
        widget.sharedTextNotifier!.value.isNotEmpty) {
      final newText = formatTextWithNaturalBreaks(widget.sharedTextNotifier!.value);
      setState(() {
        _textController.text = newText;
        _fontSize = _calculateOptimalFontSize(newText);
      });
      _saveCardPreferences();
    }
  }

  void _onExternalBgChange() {
    if (widget.sharedBgPathNotifier != null &&
        widget.sharedBgPathNotifier!.value.isNotEmpty) {
      final bgPath = widget.sharedBgPathNotifier!.value;
      final index = _bgList.indexWhere((bg) => bg['path'] == bgPath);
      if (index >= 0) {
        setState(() {
          _customImagePath = null;
          _bgIndex = index;
        });
        _saveCardPreferences();
      }
    }
  }

  /// 현재 날짜, 요일, 시간대, 그리고 계절/날씨(여름 폭염, 겨울 한파, 봄/가을 환절기)를 종합 인식하여
  /// 최적의 감동 추천 문구 목록을 반환하는 스마트 큐레이션 엔진 (home_card_data.dart 연동)
  List<Map<String, String>> _getDateTimeRecommendedQuotes() => getDateTimeRecommendedQuotes();

  /// 오늘의 날짜·시간 맞춤 1줄 슬림 흐르는 추천 티커 위젯
  Widget _buildTodayRecommendationTicker(bool isDark) {
    final list = _getDateTimeRecommendedQuotes();
    if (list.isEmpty) return const SizedBox.shrink();

    final currentItem = list[_todayQuoteIndex % list.length];
    final quote = currentItem['quote'] ?? '';
    final singleLineQuote = quote.replaceAll('\n', ' ').trim();

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2438) : const Color(0xFFFFF7EB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF4C3A6E) : const Color(0xFFFFCC80),
          width: 1.1,
        ),
        boxShadow: isDark
            ? []
            : const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showTodayQuotePopup(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // 1. Tag Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF6B21A8) : const Color(0xFFE65100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 11),
                      SizedBox(width: 4),
                      Text(
                        '오늘의 추천',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 2. 무조건 옆으로 부드럽게 흐르는 텍스트 (Marquee)
                Expanded(
                  child: ClipRect(
                    child: MarqueeFlowingText(
                      text: singleLineQuote,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF3E2723),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 오늘의 맞춤 추천 문구 전체보기 및 직접쓰기 란에 넣기 팝업 다이얼로그
  void _showTodayQuotePopup(BuildContext context) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final list = _getDateTimeRecommendedQuotes();
            final currentItem = list[_todayQuoteIndex % list.length];
            final tag = currentItem['tag'] ?? '오늘의 추천';
            final quote = currentItem['quote'] ?? '';

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1E2232) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF4C3A6E) : const Color(0xFFFFCC80),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. 헤더 (Sunset Gradient Bar)
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1B1B2F), const Color(0xFF2C1938), const Color(0xFF381A40)]
                              : [const Color(0xFFC0392B), const Color(0xFFD35400), const Color(0xFFE67E22)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '오늘의 맞춤 추천 문구',
                              style: GoogleFonts.jua(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                            onPressed: () => Navigator.pop(dialogContext),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                    ),

                    // 2. 본문 내용 (태그 뱃지 + 액자 프레임 전문)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 태그 및 다른 추천 버튼
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2D223B) : const Color(0xFFFFEDE0),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFFFFD700) : const Color(0xFFFF9800),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFFFD700) : const Color(0xFFBF360C),
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setDialogState(() {
                                    _todayQuoteIndex = (_todayQuoteIndex + 1) % list.length;
                                  });
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.refresh_rounded,
                                        size: 16,
                                        color: isDark ? const Color(0xFFA0AEC0) : const Color(0xFF8D6E63),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '다른 추천',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFFA0AEC0) : const Color(0xFF8D6E63),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 문구 전문 액자
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF141724) : const Color(0xFFFFFDF8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Colors.white12 : const Color(0x1F8D6E63),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              quote,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                height: 1.6,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFF7FAFC) : const Color(0xFF2D1810),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. 액션 버튼 [직접쓰기란에 넣기]
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE65100), Color(0xFFF57C00)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33E65100),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              Navigator.pop(dialogContext);
                              setState(() {
                                _textController.text = quote;
                                _fontSize = _calculateOptimalFontSize(quote);
                              });
                              _saveCardPreferences();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.style_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  '카드로 꾸미기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  /// 1080x1080 고화질 풀블리드 공유 카드 전용 위젯 (모서리 번짐/잔상 및 저해상도 완전 해결)
  Widget _buildHighResShareCard({required double cardSize}) {
    final double scale = cardSize / 220.0;
    final double fontSz = (_fontSize * 0.95 * scale).clamp(24.0, 180.0);

    return Material(
      color: Colors.black,
      child: SizedBox(
        width: cardSize,
        height: cardSize,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. 여백 없는 1:1 풀블리드 배경 이미지
            Image(
              image: _getBackgroundImageProvider(),
              fit: BoxFit.cover,
              width: cardSize,
              height: cardSize,
            ),
            // 2. 가독성을 위한 우아한 비네팅 그라데이션
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(45),
                      Colors.black.withAlpha(15),
                      Colors.black.withAlpha(75),
                    ],
                  ),
                ),
              ),
            ),
            // 3. 선택적 둥근 테두리 (모서리 바깥 여백까지 테두리 색상으로 완벽 채움)
            if (_borderColor != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: CardBorderPainter(
                    color: _borderColor!,
                    borderWidth: 4.5 * scale,
                    cornerRadius: 16.0 * scale,
                  ),
                ),
              ),
            // 4. 중앙 정렬 문구 (스크롤 뷰 제거로 잘림 없이 100% 노출)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 80.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900.0),
                    child: Text(
                      _textController.text,
                      textAlign: TextAlign.center,
                      style: _getAppliedTextStyle(customFontSize: fontSz).copyWith(
                        height: 1.44,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 5. 마음카드 워터마크 뱃지 (1080px 고화질 규격, 항시 노출)
            Positioned(
              right: 32,
              bottom: 32,
              child: _buildWatermarkBadge(
                fontSize: 22,
                iconSize: 26,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareImage() async {
    if (_isSharing) return;
    setState(() {
      _isSharing = true;
    });
    HapticFeedback.mediumImpact();

    try {
      // 1. 화면에서 사용자가 직접 꾸민 카드(폰트 크기, 스타일, 테두리 등) 100% 동일하게 초고화질 직접 캡처
      Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0,
      );

      // 화면 캡처가 불가능한 특수 상황일 경우에만 폴백
      if (imageBytes == null || imageBytes.isEmpty) {
        const double cardSize = 1080.0;
        imageBytes = await _screenshotController.captureFromWidget(
          _buildHighResShareCard(cardSize: cardSize),
          targetSize: const Size(cardSize, cardSize),
          pixelRatio: 1.0,
          delay: const Duration(milliseconds: 70),
        );
      }

      if (imageBytes.isNotEmpty) {
        final directory = await getTemporaryDirectory();
        final fileName = 'good_morning_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imageFile = File('${directory.path}/$fileName');
        await imageFile.writeAsBytes(imageBytes);

        if (!mounted) return;

        // 전송 전 완벽하고 고급스러운 카카오톡 전송 미리보기 팝업 노출
        await SharePreviewDialog.show(
          context: context,
          type: SharePreviewType.mindCard,
          title: '따뜻한 아침인사 카드',
          content: _textController.text.trim().isNotEmpty
              ? _textController.text.trim()
              : '소중한 분께 전하는 따뜻한 아침인사 카드입니다 🌸',
          emoji: '🌸',
          fullShareText: '소중한 분께 전하는 따뜻한 아침인사 카드입니다 🌸\n\n'
              '💌 나만의 감성 아침카드 만들기\n'
              '👉 https://play.google.com/store/apps/details?id=com.sintong.good_morning',
          imageBytes: imageBytes,
          imageFilePath: imageFile.path,
          onSaveCard: () async {
            HapticFeedback.mediumImpact();
            return await _saveCurrentCard();
          },
        );
      } else {
        debugPrint('Failed to capture high res card image.');
      }
    } catch (e) {
      debugPrint('Error sharing image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  TextStyle _getAppliedTextStyle({double? customFontSize}) {
    final effectiveFontSize = customFontSize ?? _fontSize;
    final shadowOffset = (effectiveFontSize * 0.05).clamp(1.5, 4.5);
    final shadowBlur = (effectiveFontSize * 0.08).clamp(2.5, 7.0);

    final shadows = [
      Shadow(
        offset: Offset(shadowOffset, shadowOffset),
        blurRadius: shadowBlur,
        color: Colors.black87,
      ),
      Shadow(
        offset: Offset(-shadowOffset, -shadowOffset),
        blurRadius: shadowBlur,
        color: Colors.black87,
      ),
    ];

    switch (_selectedFontFamily) {
      case 'DoHyeon':
        return GoogleFonts.doHyeon(
          fontSize: effectiveFontSize,
          color: _textColor,
          shadows: shadows,
        );
      case 'NanumMyeongjo':
        return GoogleFonts.nanumMyeongjo(
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.w700,
          color: _textColor,
          shadows: shadows,
        );
      case 'SongMyung':
        return GoogleFonts.songMyung(
          fontSize: (effectiveFontSize * 1.05).clamp(10.0, 75.0),
          fontWeight: FontWeight.w700,
          color: _textColor,
          shadows: shadows,
        );
      case 'GowunBatang':
        return GoogleFonts.gowunBatang(
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.bold,
          color: _textColor,
          shadows: shadows,
        );
      case 'YeonSung':
        return GoogleFonts.yeonSung(
          fontSize: (effectiveFontSize * 1.05).clamp(10.0, 75.0),
          color: _textColor,
          shadows: shadows,
        );
      case 'GamjaFlower':
        return GoogleFonts.gamjaFlower(
          fontSize: (effectiveFontSize * 1.15).clamp(10.0, 75.0),
          color: _textColor,
          shadows: shadows,
        );
      case 'HiMelody':
        return GoogleFonts.hiMelody(
          fontSize: (effectiveFontSize * 1.2).clamp(10.0, 75.0),
          color: _textColor,
          shadows: shadows,
        );
      case 'PoorStory':
        return GoogleFonts.poorStory(
          fontSize: (effectiveFontSize * 1.15).clamp(10.0, 75.0),
          color: _textColor,
          shadows: shadows,
        );
      case 'Gaegu':
        return GoogleFonts.gaegu(
          fontSize: (effectiveFontSize * 1.1).clamp(10.0, 70.0),
          fontWeight: FontWeight.bold,
          color: _textColor,
          shadows: shadows,
        );
      case 'SingleDay':
        return GoogleFonts.singleDay(
          fontSize: (effectiveFontSize * 1.2).clamp(10.0, 75.0),
          color: _textColor,
          shadows: shadows,
        );
      case 'Dongle':
        return GoogleFonts.dongle(
          fontSize: (effectiveFontSize * 1.35).clamp(12.0, 85.0),
          fontWeight: FontWeight.bold,
          color: _textColor,
          shadows: shadows,
        );
      case 'CuteFont':
        return GoogleFonts.cuteFont(
          fontSize: (effectiveFontSize * 1.35).clamp(12.0, 85.0),
          fontWeight: FontWeight.bold,
          color: _textColor,
          shadows: shadows,
        );
      case 'NanumPenScript':
        return GoogleFonts.nanumPenScript(
          fontSize: (effectiveFontSize * 1.25).clamp(10.0, 75.0),
          color: _textColor,
          shadows: shadows,
        );
      case 'NanumBrushScript':
        return GoogleFonts.nanumBrushScript(
          fontSize: (effectiveFontSize * 1.2).clamp(10.0, 75.0),
          color: _textColor,
          shadows: shadows,
        );
      case 'KirangHaerang':
        return GoogleFonts.kirangHaerang(
          fontSize: (effectiveFontSize * 1.15).clamp(10.0, 75.0),
          color: _textColor,
          shadows: shadows,
        );
      case 'BlackHanSans':
        return GoogleFonts.blackHanSans(
          fontSize: effectiveFontSize,
          color: _textColor,
          shadows: shadows,
        );
      case 'GowunDodum':
        return GoogleFonts.gowunDodum(
          fontSize: effectiveFontSize,
          color: _textColor,
          shadows: shadows,
        );
      case 'Hahmlet':
        return GoogleFonts.hahmlet(
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.w700,
          color: _textColor,
          shadows: shadows,
        );
      case 'Sunflower':
        return GoogleFonts.sunflower(
          fontSize: (effectiveFontSize * 1.05).clamp(10.0, 70.0),
          fontWeight: FontWeight.bold,
          color: _textColor,
          shadows: shadows,
        );
      case 'NanumGothic':
        return GoogleFonts.nanumGothic(
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.bold,
          color: _textColor,
          shadows: shadows,
        );
      case 'Jua':
      default:
        return GoogleFonts.jua(
          fontSize: effectiveFontSize,
          color: _textColor,
          shadows: shadows,
        );
    }
  }

  void _onSavedCardSelected() {
    final card = widget.sharedCardNotifier?.value;
    if (card == null) return;
    final backgroundIndex = _bgList.indexWhere(
      (bg) => bg['path'] == card.backgroundPath,
    );
    setState(() {
      _textController.text = card.message;
      if (card.backgroundPath.startsWith('assets/')) {
        _customImagePath = null;
        _bgIndex = backgroundIndex >= 0 ? backgroundIndex : 0;
      } else {
        _customImagePath = card.backgroundPath;
      }
      _textColor = Color(card.textColorValue);
      _borderColor = card.borderColorValue == null
          ? null
          : Color(card.borderColorValue!);
      _fontSize = card.fontSize;
    });
    _saveCardPreferences();
  }

  void _onBottomScroll() {
    if (!_bottomScrollController.hasClients) return;
    final maxScroll = _bottomScrollController.position.maxScrollExtent;
    final currentScroll = _bottomScrollController.offset;
    // 맨 아래로부터 30px 이내로 도달하면 아래 더있음 힌트 숨김, 위로 올리면 다시 표시
    final shouldShow = (maxScroll - currentScroll) > 35;
    if (_showScrollDownHint != shouldShow) {
      setState(() {
        _showScrollDownHint = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _bottomScrollController.removeListener(_onBottomScroll);
    _bottomScrollController.dispose();
    _bounceAnimationController.dispose();
    _sparkleController.dispose();
    _petalController.dispose();
    _audioPlayer.dispose();
    widget.sharedTextNotifier?.removeListener(_onExternalTextChange);
    widget.sharedBgPathNotifier?.removeListener(_onExternalBgChange);
    widget.sharedCardNotifier?.removeListener(_onSavedCardSelected);
    widget.sharedCardRequestNotifier?.removeListener(_onExternalCardRequest);
    super.dispose();
  }

  ImageProvider _getBackgroundImageProvider() {
    if (_customImagePath != null && File(_customImagePath!).existsSync()) {
      return FileImage(File(_customImagePath!));
    }
    return AssetImage(_bgList[_bgIndex]['path']!);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 92,
      );

      if (pickedFile != null) {
        HapticFeedback.mediumImpact();
        setState(() {
          _customImagePath = pickedFile.path;
        });
        await _saveCardPreferences();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('내 사진이 카드 배경으로 적용되었습니다! 🌸'),
                ],
              ),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('사진을 불러오는 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool> _saveCurrentCard() async {
    return await CardArchiveService().saveCard(
      SavedCard(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        message: _textController.text.trim(),
        backgroundPath: _customImagePath ?? _bgList[_bgIndex]['path']!,
        textColorValue: _textColor.toARGB32(),
        borderColorValue: _borderColor?.toARGB32(),
        fontSize: _fontSize,
        createdAt: DateTime.now(),
      ),
    );
  }

  Widget _buildWatermarkBadge({
    double fontSize = 11,
    double iconSize = 13,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(125),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(65),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(iconSize * 0.28),
            child: Image.asset(
              'assets/images/app_icon.png',
              width: iconSize,
              height: iconSize,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '마음카드 아침',
            style: GoogleFonts.jua(
              fontSize: fontSize,
              color: Colors.white.withAlpha(235),
              letterSpacing: 0.3,
              shadows: const [
                Shadow(
                  color: Colors.black87,
                  blurRadius: 2,
                  offset: Offset(0.5, 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1B1B2F), const Color(0xFF2C1938), const Color(0xFF381A40)]
                  : [const Color(0xFFC0392B), const Color(0xFFD35400), const Color(0xFFE67E22)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 60 : 35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_rounded, color: Color(0xFFFFD700), size: 21),
            const SizedBox(width: 7),
            Text(
              '마음카드',
              style: GoogleFonts.jua(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
                shadows: const [
                  Shadow(
                    color: Color(0x3D000000),
                    blurRadius: 4,
                    offset: Offset(0, 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          // Sound Toggle Button
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(_soundEnabled ? 35 : 18),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: const EdgeInsets.all(7),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(
                _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: _soundEnabled
                    ? const Color(0xFFFFD700)
                    : Colors.white60,
                size: 19,
              ),
              tooltip: _soundEnabled ? '소리 끄기' : '소리 켜기',
              onPressed: _toggleSound,
            ),
          ),
          // Notification Toggle Button (9:00 AM Daily)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(_notificationEnabled ? 35 : 18),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: const EdgeInsets.all(7),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(
                _notificationEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                color: _notificationEnabled
                    ? const Color(0xFFFFD700)
                    : Colors.white60,
                size: 19,
              ),
              tooltip: '아침 안부 알림 설정',
              onPressed: _openNotificationSettings,
            ),
          ),
          // Theme Toggle Button (Light / Dark)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(18),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: const EdgeInsets.all(7),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                color: isDark ? const Color(0xFFFFD700) : Colors.white,
                size: 19,
              ),
              tooltip: isDark ? '라이트 모드로 전환' : '다크 모드로 전환',
              onPressed: () {
                HapticFeedback.lightImpact();
                ThemeService().toggleTheme();
              },
            ),
          ),
          // Help Dialog Button
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(18),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: const EdgeInsets.all(7),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 19),
              tooltip: '사용 가이드',
              onPressed: () {
                HapticFeedback.lightImpact();
                HelpDialog.show(context);
              },
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF141722), // 모던 카본 슬레이트
                    const Color(0xFF1C202E), // 세련된 미드나잇 흑요석
                    const Color(0xFF161924),
                  ]
                : [
                    const Color(0xFFFFFDF9), // 따뜻한 아침 햇살 크림
                    const Color(0xFFFFF5EC), // 화사한 피치 웜 톤
                    const Color(0xFFFDEEE4), // 우아하고 포근한 살구 린넨
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Active Ambient Floating Flower Petals / Gentle Nature Breeze
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _sparkleController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: FlowerPetalPainter(
                        progress: _sparkleController.value,
                        isDark: isDark,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Foreground Interactive Content
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: Column(
                children: [
                  // ✨ 0. 오늘 날짜/시간 맞춤 1줄 슬림 티커 (배경 문구 카드 바로 위에 배치)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                    child: _buildTodayRecommendationTicker(isDark),
                  ),

                  // FIXED STICKY TOP: Live Canvas Preview with Gallery Frame Aesthetic
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          const Color(0xFF1E2333),
                          const Color(0xFF161A26),
                        ]
                      : [
                          const Color(0xFFFFFDF8),
                          const Color(0xFFF9F3EA),
                        ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.transparent : const Color(0x1F8D6E63),
                    width: 1.0,
                  ),
                ),
                boxShadow: isDark
                    ? []
                    : const [
                        BoxShadow(
                          color: Color(0x128D6E63),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Active Floating Nature Petals / Sunlight Aura behind the preview card
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _sparkleController,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: FlowerPetalPainter(
                              progress: _sparkleController.value,
                              isDark: isDark,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Foreground Preview Card (Tap to View Fullscreen)
                  Center(
                    child: Builder(
                      builder: (context) {
                        final screenHeight = MediaQuery.sizeOf(context).height;
                        final previewMaxHeight =
                            (screenHeight * 0.28).clamp(160.0, 230.0);
                        return GestureDetector(
                          onTap: () => _showFullScreenCardViewer(context),
                          child: Tooltip(
                            message: '터치하여 크게 보기',
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: previewMaxHeight),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x38000000),
                                      blurRadius: 16,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Screenshot(
                                    controller: _screenshotController,
                                    child: AspectRatio(
                                      aspectRatio: 1.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: _getBackgroundImageProvider(),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Container(
                                              clipBehavior: Clip.antiAlias,
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.black.withAlpha(30),
                                                    Colors.transparent,
                                                    Colors.black.withAlpha(50),
                                                  ],
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  _textController.text,
                                                  textAlign: TextAlign.center,
                                                  softWrap: true,
                                                  style: _getAppliedTextStyle().copyWith(
                                                    fontSize: (_fontSize * 0.95).clamp(8.0, 44.0),
                                                    height: 1.45,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // 둥근 테두리 및 4개 모서리 바깥 여백을 테두리 색상으로 완벽 밀착 채움
                                            if (_borderColor != null)
                                              Positioned.fill(
                                                child: IgnorePointer(
                                                  child: CustomPaint(
                                                    painter: CardBorderPainter(
                                                      color: _borderColor!,
                                                      borderWidth: 4.5,
                                                      cornerRadius: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Positioned(
                                              right: 8,
                                              bottom: 8,
                                              child: _buildWatermarkBadge(
                                                fontSize: 10,
                                                iconSize: 12,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2.5,
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
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // SCROLLABLE BOTTOM: Clean Step-by-Step Flow for Seniors with generous spacing
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SingleChildScrollView(
                    controller: _bottomScrollController,
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    // 1. 원하는 문구 직접 쓰기 (입력창)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isDark
                            ? []
                            : const [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          labelText: '✍️ 원하는 문구 직접 쓰기',
                          labelStyle: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFFFD700)
                                : const Color(0xFFC0392B),
                            letterSpacing: -0.3,
                          ),
                          floatingLabelStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFFFD700)
                                : const Color(0xFFD35400),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF1E2232)
                              : const Color(0xFFFFF7ED),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white12 : const Color(0xFFE5D5C5),
                              width: 1.2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white12 : const Color(0xFFE5D5C5),
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFFFFD700) : const Color(0xFFE65100),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: _textController.text.isNotEmpty
                              ? Tooltip(
                                  message: '내용 전체 지우기',
                                  child: IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE0D3C3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: isDark ? Colors.white70 : const Color(0xFF5D4037),
                                      ),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _textController.clear();
                                      });
                                      _saveCardPreferences();
                                    },
                                  ),
                                )
                              : null,
                        ),
                        minLines: 3,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 16.5,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF2C1810),
                        ),
                        onChanged: (value) {
                          setState(() {});
                          _saveCardPreferences();
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. 글씨 꾸미기 (글자 크기, 테두리, 색상, 이모티콘)
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: isDark ? 0 : 2,
                      shadowColor: const Color(0x14000000),
                      color: isDark ? const Color(0xFF232838) : const Color(0xFFFFF4EC),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isDark ? Colors.white12 : const Color(0xFFE0D8CC),
                        ),
                      ),
                      child: ExpansionTile(
                        key: ValueKey<String>('decorate_tile_$_isDecorateExpanded'),
                        initiallyExpanded: _isDecorateExpanded,
                        onExpansionChanged: (expanded) async {
                          _isDecorateExpanded = expanded;
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('decorate_expanded', expanded);
                        },
                        shape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                        collapsedShape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                        backgroundColor: Colors.transparent,
                        collapsedBackgroundColor: Colors.transparent,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        leading: Icon(
                          Icons.tune_rounded,
                          color: isDark ? const Color(0xFFFFD700) : const Color(0xFFE64A19),
                        ),
                        title: Text(
                          '글씨 꾸미기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          '크기 · 글꼴 · 테두리 · 색상',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFE0E0E0) : Colors.black54,
                          ),
                        ),
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Divider(
                                height: 1,
                                color: isDark ? Colors.white12 : const Color(0x1F8D6E63),
                              ),
                              const SizedBox(height: 10),
                              // Size Controls & Emoji button (Overflow-safe on all devices & font scales)
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '글자 크기: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.deepOrange,
                                      ),
                                      onPressed: () {
                                        if (_fontSize > 10) {
                                          setState(() => _fontSize -= 2);
                                          _saveCardPreferences();
                                        }
                                      },
                                    ),
                                    Text(
                                      '${_fontSize.toInt()}pt',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDark ? const Color(0xFFFFD700) : Colors.black87,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.deepOrange,
                                      ),
                                      onPressed: () {
                                        if (_fontSize < 50) {
                                          setState(() => _fontSize += 2);
                                          _saveCardPreferences();
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    // Emoji Picker Popup Button
                                    InkWell(
                                      onTap: () => _showEmojiPicker(context),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.orange.withAlpha(50)
                                              : Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.orangeAccent
                                                : Colors.orange.shade800,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.sentiment_satisfied_alt,
                                              size: 16,
                                              color: Colors.orange,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '😊 이모티콘',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.orangeAccent
                                                    : Colors.orange.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 14,
                                color: isDark ? Colors.transparent : const Color(0x1F8D6E63),
                              ),

                              // Font Family Selector (Horizontal scroll - No Overflow!)
                              Row(
                                children: [
                                  Text(
                                    '글꼴: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: _koreanFontOptions.map((fontItem) {
                                          final String fontId = fontItem['id'] as String;
                                          final String fontName = fontItem['name'] as String;
                                          final TextStyle fontStyle = fontItem['font'] as TextStyle;
                                          final bool isSelected = _selectedFontFamily == fontId;

                                          return Padding(
                                            padding: const EdgeInsets.only(right: 6.0),
                                            child: ChoiceChip(
                                              label: Text(
                                                fontName,
                                                style: fontStyle.copyWith(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : (isDark ? Colors.white70 : Colors.black87),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              selected: isSelected,
                                              selectedColor: Colors.deepOrange,
                                              backgroundColor: isDark
                                                  ? const Color(0xFF2D2A3E)
                                                  : const Color(0xFFFFEDE0),
                                              onSelected: (selected) {
                                                if (selected) {
                                                  HapticFeedback.selectionClick();
                                                  setState(() => _selectedFontFamily = fontId);
                                                  _saveCardPreferences();
                                                }
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                height: 14,
                                color: isDark ? Colors.transparent : const Color(0x1F8D6E63),
                              ),

                              // Frame Style Selector (Horizontal scroll - No Overflow!)
                              Row(
                                children: [
                                  Text(
                                    '테두리: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          ChoiceChip(
                                            label: const Text('없음'),
                                            selected: _borderColor == null,
                                            selectedColor: Colors.deepOrange,
                                            backgroundColor: isDark ? const Color(0xFF2D2A3E) : const Color(0xFFFFEDE0),
                                            labelStyle: TextStyle(
                                              color: _borderColor == null
                                                  ? Colors.white
                                                  : (isDark
                                                        ? Colors.white70
                                                        : Colors.black87),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            onSelected: (selected) {
                                              if (selected) {
                                                setState(() => _borderColor = null);
                                                _saveCardPreferences();
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 6),
                                          ...[
                                            {
                                              'name': '황금',
                                              'color': const Color(0xFFFFD700),
                                            },
                                            {'name': '순백', 'color': Colors.white},
                                            {
                                              'name': '장미',
                                              'color': const Color(0xFFFF1744),
                                            },
                                          ].map((frame) {
                                            final Color frameColor =
                                                frame['color'] as Color;
                                            final isSelected =
                                                _borderColor == frameColor;
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 6.0),
                                              child: ChoiceChip(
                                                label: Text(frame['name'] as String),
                                                selected: isSelected,
                                                selectedColor: Colors.deepOrange,
                                                backgroundColor: isDark ? const Color(0xFF2D2A3E) : const Color(0xFFFFEDE0),
                                                labelStyle: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : (isDark
                                                            ? Colors.white70
                                                            : Colors.black87),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                                avatar: CircleAvatar(
                                                  backgroundColor: frameColor,
                                                  radius: 6,
                                                ),
                                                onSelected: (selected) {
                                                  if (selected) {
                                                    setState(
                                                      () => _borderColor = frameColor,
                                                    );
                                                    _saveCardPreferences();
                                                  }
                                                },
                                              ),
                                            );
                                          }),
                                          // Border Palette Color Picker Button
                                          InkWell(
                                            onTap: () => _showRGBColorPicker(
                                              context,
                                              isBorder: true,
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF1744),
                                                    Color(0xFFFFD700),
                                                    Color(0xFF00E676),
                                                    Color(0xFF29B6F6),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.palette_rounded,
                                                    size: 15,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '색상표',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                height: 14,
                                color: isDark ? Colors.transparent : const Color(0x1F8D6E63),
                              ),

                              // Quick Color Selection Bar
                              Row(
                                children: [
                                  Text(
                                    '색상: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          ..._defaultColors.map((colorItem) {
                                            final Color color =
                                                colorItem['color'];
                                            final isSelected =
                                                _textColor == color;
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  HapticFeedback.selectionClick();
                                                  setState(
                                                    () => _textColor = color,
                                                  );
                                                  _saveCardPreferences();
                                                },
                                                child: Container(
                                                  width: 34,
                                                  height: 34,
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? (isDark
                                                                ? Colors
                                                                      .amberAccent
                                                                : Colors
                                                                      .deepOrange)
                                                          : Colors.grey.shade400,
                                                      width: isSelected ? 3.5 : 1,
                                                    ),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 2,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: isSelected
                                                      ? Icon(
                                                          Icons.check,
                                                          size: 18,
                                                          color:
                                                              color ==
                                                                      Colors.white
                                                                  ? Colors.black
                                                                  : Colors.white,
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            );
                                          }),
                                          // Palette Color Picker Button
                                          InkWell(
                                            onTap: () => _showRGBColorPicker(
                                              context,
                                              isBorder: false,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF1744),
                                                    Color(0xFFFFD700),
                                                    Color(0xFF00E676),
                                                    Color(0xFF29B6F6),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.palette_rounded,
                                                    size: 15,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '색상표',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. 문구 선택 & 배경 선택 버튼 (고급스러운 듀얼 그라데이션, 포커스 점선 완전 제거)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF4A148C), const Color(0xFF311B92)]
                                    : [const Color(0xFF7B1FA2), const Color(0xFF512DA8)],
                              ),
                              boxShadow: isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.purple.withAlpha(60),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Focus(
                              canRequestFocus: false,
                              skipTraversal: true,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  _showQuotePicker(context);
                                },
                                icon: const Icon(
                                  Icons.format_quote,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '문구 선택 📜',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF004D40), const Color(0xFF00695C)]
                                    : [const Color(0xFF00897B), const Color(0xFF00695C)],
                              ),
                              boxShadow: isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.teal.withAlpha(60),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Focus(
                              canRequestFocus: false,
                              skipTraversal: true,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  _showBackgroundPicker(context);
                                },
                                icon: const Icon(
                                  Icons.collections,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '배경 선택 🖼️',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 4. 맨 하단: 카카오톡 공유 / 저장 메인 버튼 (럭셔리 골드 옐로우)
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFEB3B),
                            Color(0xFFFDD835),
                            Color(0xFFFBC02D),
                          ],
                        ),
                        boxShadow: isDark
                            ? []
                            : const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Focus(
                        canRequestFocus: false,
                        skipTraversal: true,
                        child: ElevatedButton.icon(
                          onPressed: _isSharing ? null : _shareImage,
                          icon: _isSharing
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xFF371D1D),
                                  ),
                                )
                              : const Icon(
                                  Icons.share,
                                  size: 26,
                                  color: Color(0xFF371D1D),
                                ),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _isSharing
                                  ? '카카오톡 카드 전송 준비 중...'
                                  : '📲 카카오톡으로 바로 보내기',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF371D1D),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            elevation: 0,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. 하단 따뜻한 감성 장식 영역 (중장년층 취향의 정갈한 꽃잎 데코레이션)
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 1,
                                color: isDark
                                    ? Colors.white24
                                    : const Color(0x30D84315),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '🌸 소중한 분께 따뜻한 마음을 전해보세요 🌿',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFFB0BEC5)
                                        : const Color(0xFF8D6E63),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 1,
                                color: isDark
                                    ? Colors.white24
                                    : const Color(0x30D84315),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '마음카드 • 매일 아침 전하는 사랑과 안부',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFFBCAAA4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // 🔻 부드러운 아래 스크롤 안내 인디케이터 (맨 아래 도달 시 자동 페이드아웃)
              Positioned(
                bottom: 12,
                child: AnimatedOpacity(
                  opacity: _showScrollDownHint ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  child: IgnorePointer(
                    ignoring: !_showScrollDownHint,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (_bottomScrollController.hasClients) {
                          _bottomScrollController.animateTo(
                            _bottomScrollController.offset + 220,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                      child: AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _bounceAnimation.value),
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xE625293A) // 다크모드: 은은한 미드나잇 글래스
                                : const Color(0xF5FFFFFF), // 라이트모드: 산뜻한 퓨어 크림 글래스
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0x3DFFD700) // 다크 골드 은은한 테두리
                                  : const Color(0x33D84315), // 라이트 웜 오렌지 테두리
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withAlpha(110)
                                    : const Color(0x2E8D6E63),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '아래로 내려보세요',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                  color: isDark
                                      ? const Color(0xFFFFD700)
                                      : const Color(0xFFC0392B),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_double_arrow_down_rounded,
                                size: 17,
                                color: isDark
                                    ? const Color(0xFFFFD700)
                                    : const Color(0xFFC0392B),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ], // Column children
    ), // Column
  ), // GestureDetector
    ],
  ), // Stack
), // Container
  ); // Scaffold
}

  // Fullscreen Large Card Viewer with Luxury Gallery Dialog Aesthetics
  void _showFullScreenCardViewer(BuildContext context) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final screenWidth = MediaQuery.sizeOf(dialogContext).width;
        final cardSize = (screenWidth - 80).clamp(260.0, 360.0);
        bool isSavingCard = false;
        String? floatingMessage;
        bool isFloatingSuccess = true;
        Timer? toastTimer;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1B1E2E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
                side: BorderSide(
                  color: isDark ? Colors.white12 : const Color(0x1F8D6E63),
                ),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Luxury Header Banner with Close Button
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1B1B2F), const Color(0xFF2C1938), const Color(0xFF381A40)]
                            : [const Color(0xFFC0392B), const Color(0xFFD35400), const Color(0xFFE67E22)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 60 : 35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '마음카드 완성본 감상',
                                style: GoogleFonts.jua(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '소중한 분께 전달할 아름다운 완성 카드입니다',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.white70,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(35),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                          ),
                          tooltip: '닫기',
                          onPressed: () {
                            toastTimer?.cancel();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),

                  // 2. High-Definition Art Frame Card Presentation
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Container(
                      width: cardSize,
                      height: cardSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 90 : 35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        image: DecorationImage(
                          image: _getBackgroundImageProvider(),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            clipBehavior: Clip.antiAlias,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: _borderColor != null
                                  ? Border.all(color: _borderColor!, width: 5.5)
                                  : null,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withAlpha(30),
                                  Colors.transparent,
                                  Colors.black.withAlpha(50),
                                ],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                              child: Text(
                                _textController.text,
                                textAlign: TextAlign.center,
                                style: _getAppliedTextStyle().copyWith(
                                  fontSize: (_fontSize * 1.15).clamp(10.0, 48.0),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: _buildWatermarkBadge(
                              fontSize: 12,
                              iconSize: 14,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ),

                          // 플로팅 안내 메시지 (레이아웃 변형 없이 카드 위에 깔끔하게 떴다가 사라짐)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: floatingMessage != null
                                    ? Center(
                                        key: ValueKey(floatingMessage),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 20),
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                                          decoration: BoxDecoration(
                                            color: const Color(0xF2161922),
                                            borderRadius: BorderRadius.circular(30),
                                            border: Border.all(
                                              color: isFloatingSuccess
                                                  ? const Color(0x6669F0AE)
                                                  : const Color(0x66FFB74D),
                                              width: 1.2,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x66000000),
                                                blurRadius: 20,
                                                offset: Offset(0, 8),
                                              ),
                                              BoxShadow(
                                                color: Color(0x22000000),
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: isFloatingSuccess
                                                      ? const Color(0x2569F0AE)
                                                      : const Color(0x25FFB74D),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  isFloatingSuccess
                                                      ? Icons.check_circle_rounded
                                                      : Icons.bookmark_added_rounded,
                                                  color: isFloatingSuccess
                                                      ? const Color(0xFF69F0AE)
                                                      : const Color(0xFFFFB74D),
                                                  size: 19,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Flexible(
                                                child: Text(
                                                  floatingMessage!,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: -0.3,
                                                    height: 1.2,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Luxury Bottom Action Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Row(
                      children: [
                        // 1. 보관함 저장 버튼 (가로 사이즈 확장으로 여유로운 터치 영역 확보)
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 48,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: (isDark ? const Color(0xFF2B3245) : const Color(0xFFFFF0E6)),
                              border: Border.all(
                                color: (isDark ? Colors.white12 : const Color(0xFFFFCCBC)),
                                width: 1.2,
                              ),
                            ),
                            child: InkWell(
                              onTap: isSavingCard
                                  ? null
                                  : () async {
                                      HapticFeedback.mediumImpact();
                                      setDialogState(() {
                                        isSavingCard = true;
                                      });
                                      final isNew = await _saveCurrentCard();
                                      toastTimer?.cancel();
                                      if (context.mounted) {
                                        setDialogState(() {
                                          isSavingCard = false;
                                          floatingMessage = isNew
                                              ? '💌 [내 카드함]에 소중히 보관되었습니다!'
                                              : '📌 이미 보관함에 담겨있는 카드입니다';
                                          isFloatingSuccess = isNew;
                                        });
                                        toastTimer = Timer(const Duration(milliseconds: 2000), () {
                                          if (context.mounted) {
                                            try {
                                              setDialogState(() {
                                                floatingMessage = null;
                                              });
                                            } catch (_) {}
                                          }
                                        });
                                      }
                                    },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSavingCard)
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: isDark ? const Color(0xFFFFAB91) : const Color(0xFFBF360C),
                                          ),
                                        )
                                      else
                                        Icon(
                                          Icons.bookmark_add_rounded,
                                          color: isDark ? const Color(0xFFFFAB91) : const Color(0xFFD84315),
                                          size: 18,
                                        ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '보관함 저장',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? const Color(0xFFFFAB91) : const Color(0xFFBF360C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // 2. 카카오톡 바로 전송
                        Expanded(
                          flex: 4,
                          child: Container(
                            height: 48,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: const Color(0xFFFEE500),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33FEE500),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                toastTimer?.cancel();
                                Navigator.of(context).pop();
                                _shareImage();
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.share_rounded, color: Colors.black87, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        '카카오톡 보내기',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  // RGB Color Picker (Luxury Visual Palette Wheel with Live Preview & Presets)
  void _showRGBColorPicker(BuildContext context, {bool isBorder = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color tempColor = isBorder
        ? (_borderColor ?? const Color(0xFFFFD700))
        : _textColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isDark ? Colors.white12 : const Color(0x1F8D6E63),
                ),
              ),
              titlePadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262638) : const Color(0xFFFFF6EE),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.white10 : const Color(0x14000000),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isBorder ? '🖼️ 테두리 색상 맞춤' : '🎨 글자 색상 맞춤',
                          style: GoogleFonts.jua(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFFFD700) : const Color(0xFFD84315),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '원하는 색상을 터치하여 나만의 감성 카드를 완성해보세요',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : const Color(0xFF8D6E63),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. 실시간 미리보기 캡슐 (Live Preview)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF141722) : const Color(0xFFFFFDF8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isBorder ? tempColor : (isDark ? Colors.white12 : const Color(0x1F8D6E63)),
                          width: isBorder ? 3.0 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tempColor.withAlpha(isDark ? 50 : 35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: tempColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isBorder ? '🌸 액자 테두리 적용 미리보기 🌿' : '🌸 좋은 하루 보내세요 🌿',
                            style: GoogleFonts.jua(
                              fontSize: 15,
                              color: isBorder ? (isDark ? Colors.white : Colors.black87) : tempColor,
                              shadows: isBorder
                                  ? null
                                  : [const Shadow(blurRadius: 2, color: Colors.black26)],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. 메인 컬러 팔레트 휠
                    ColorPicker(
                      pickerColor: tempColor,
                      onColorChanged: (Color color) {
                        setDialogState(() {
                          tempColor = color;
                        });
                      },
                      colorPickerWidth: 275,
                      pickerAreaHeightPercent: 0.68,
                      enableAlpha: false,
                      displayThumbColor: true,
                      paletteType: PaletteType.hsvWithHue,
                      labelTypes: const [], // Hides all RGB / Hex numbers
                      pickerAreaBorderRadius: BorderRadius.circular(16),
                    ),

                    const SizedBox(height: 10),

                    // 3. 인기 추천 명품 컬러 빠른 선택 칩
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Color(0xFFFFD700), // 황금 골드
                        const Color(0xFFFF3366), // 장미 핑크
                        const Color(0xFF00E676), // 비취 그린
                        const Color(0xFF00E5FF), // 청량 하늘
                        const Color(0xFFAB47BC), // 우아 보라
                        const Color(0xFFFF9100), // 온화 살구
                        Colors.white,            // 순백
                      ].map((presetColor) {
                        final isSelected = tempColor.value == presetColor.value;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setDialogState(() => tempColor = presetColor);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: presetColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.deepOrange : Colors.grey.shade400,
                                width: isSelected ? 3.0 : 1.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: presetColor == Colors.white ? Colors.black : Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
                    ),
                    boxShadow: isDark
                        ? []
                        : const [
                            BoxShadow(
                              color: Color(0x33E65100),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 19, color: Colors.white),
                    label: const Text(
                      '이 색상으로 결정 ✨',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide.none,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (isBorder) {
                          _borderColor = tempColor;
                        } else {
                          _textColor = tempColor;
                        }
                      });
                      _saveCardPreferences();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Emoji Picker Popup Modal Bottom Sheet
  void _showEmojiPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Map<String, dynamic>> emojiCategories = const [
      {
        'title': '🌅 아침/자연',
        'emojis': [
          '🌅',
          '☀️',
          '🌸',
          '🌺',
          '🌻',
          '🍀',
          '🌿',
          '☕',
          '🍁',
          '🍃',
          '🌞',
          '🌲',
          '🌹',
          '💐',
          '🌴',
          '🌾',
          '🌊',
          '🌈',
        ],
      },
      {
        'title': '❤️ 사랑/덕담',
        'emojis': [
          '❤️',
          '💖',
          '💕',
          '💗',
          '🥰',
          '🙏',
          '🎁',
          '✨',
          '🌟',
          '💝',
          '💌',
          '🥳',
          '🎉',
          '👏',
          '🕊️',
          '👑',
          '💎',
          '🔥',
        ],
      },
      {
        'title': '😊 표정/응원',
        'emojis': [
          '😊',
          '😃',
          '👍',
          '💪',
          '✌️',
          '🎈',
          '🤩',
          '😍',
          '🤗',
          '⭐',
          '🍀',
          '🙌',
          '💯',
          '🍊',
          '🍎',
          '🍵',
          '🥂',
          '💖',
        ],
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161926) : const Color(0xFFFAF7F2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: DefaultTabController(
            length: emojiCategories.length,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. 상단 선셋 그라데이션 타이틀 헤더 바
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 14, 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1B1B2F), const Color(0xFF2C1938), const Color(0xFF381A40)]
                          : [const Color(0xFFC0392B), const Color(0xFFD35400), const Color(0xFFE67E22)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      const Text('😊', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '감성 이모티콘 선택',
                          style: GoogleFonts.jua(
                            fontSize: 19.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                        tooltip: '닫기',
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                ),

                // 2. 카테고리 탭 바
                Container(
                  color: isDark ? const Color(0xFF1E2234) : Colors.white,
                  child: TabBar(
                    labelColor: isDark ? const Color(0xFFFFD700) : const Color(0xFFD35400),
                    unselectedLabelColor: isDark ? const Color(0xFFA0AEC0) : const Color(0xFF8D6E63),
                    indicatorColor: isDark ? const Color(0xFFFFD700) : const Color(0xFFD35400),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    tabs: emojiCategories
                        .map((cat) => Tab(text: cat['title']))
                        .toList(),
                  ),
                ),

                // 3. 이모티콘 그리드
                Container(
                  height: 220,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                  child: TabBarView(
                    children: emojiCategories.map((cat) {
                      final List<String> emojis = cat['emojis'];
                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: emojis.length,
                        itemBuilder: (context, index) {
                          final emoji = emojis[index];
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _textController.text =
                                    '${_textController.text} $emoji'.trim();
                              });
                              _saveCardPreferences();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('문구에 $emoji 이모티콘이 추가되었습니다!'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFFE64A19),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF242B42) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? Colors.white10 : const Color(0x1F8D6E63),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark ? Colors.black26 : const Color(0x0A8D6E63),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Background Image Selector Popup Modal Bottom Sheet with Category Filter Tabs
  void _showBackgroundPicker(BuildContext context) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get unique categories list
    final List<String> categories = [
      '전체',
      ...{for (var item in _bgList) item['category']!},
    ];

    String selectedCategoryTab = _lastSelectedBgCategoryTab ?? '전체';
    if (!categories.contains(selectedCategoryTab)) {
      selectedCategoryTab = '전체';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final filteredList = selectedCategoryTab == '전체'
                ? _bgList
                : _bgList
                      .where((bg) => bg['category'] == selectedCategoryTab)
                      .toList();

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161926) : const Color(0xFFFAF7F2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 0.8,
                minChildSize: 0.45,
                maxChildSize: 0.94,
                expand: false,
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      // 1. 상단 선셋 그라데이션 타이틀 헤더 바
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 14, 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF1B1B2F), const Color(0xFF2C1938), const Color(0xFF381A40)]
                                : [const Color(0xFFC0392B), const Color(0xFFD35400), const Color(0xFFE67E22)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.photo_library_rounded, color: Color(0xFFFFD700), size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '아름다운 배경화면 선택',
                                style: GoogleFonts.jua(
                                  fontSize: 19.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                              tooltip: '닫기',
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ),
                      ),

                      // 2. 내 앨범 사진 및 즉석 카메라 촬영 배너 (시니어 친화적 대형 버튼)
                      Container(
                        margin: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF2D1B36), const Color(0xFF1E2238)]
                                : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.orange.withAlpha(60) : const Color(0xFFFFB74D),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, color: Color(0xFFE65100), size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '나만의 사진으로 특별한 카드 만들기',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFFFD180) : const Color(0xFFBF360C),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.photo_library_rounded, size: 20),
                                    label: const Text(
                                      '내 앨범 사진',
                                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE65100),
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _pickImage(ImageSource.gallery);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.camera_alt_rounded, size: 20),
                                    label: const Text(
                                      '직접 촬영',
                                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _pickImage(ImageSource.camera);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (_customImagePath != null && File(_customImagePath!).existsSync()) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black38 : Colors.white.withAlpha(200),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.file(
                                        File(_customImagePath!),
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '현재 내 앨범 사진 적용 중',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.refresh_rounded, size: 16),
                                      label: const Text('기본 배경으로'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFFD84315),
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _customImagePath = null;
                                        });
                                        _saveCardPreferences();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // 3. 카테고리 필터 칩 바 (가로 스크롤)
                      Container(
                        color: isDark ? const Color(0xFF1E2234) : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: categories.map((cat) {
                              final isCatSelected = cat == selectedCategoryTab;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: isCatSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isCatSelected
                                          ? Colors.white
                                          : (isDark ? const Color(0xFFC5CCE0) : const Color(0xFF5D4037)),
                                    ),
                                  ),
                                  selected: isCatSelected,
                                  selectedColor: isDark ? const Color(0xFF6B21A8) : const Color(0xFFD35400),
                                  backgroundColor: isDark ? const Color(0xFF272D45) : const Color(0xFFFFF1E6),
                                  side: BorderSide(
                                    color: isCatSelected
                                        ? Colors.transparent
                                        : (isDark ? Colors.white12 : const Color(0xFFFFCCBC)),
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      HapticFeedback.selectionClick();
                                      setModalState(() {
                                        selectedCategoryTab = cat;
                                      });
                                      _lastSelectedBgCategoryTab = cat;
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 4. 갤러리 썸네일 그리드
                      Expanded(
                        child: GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 1.0,
                              ),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final bg = filteredList[index];
                            final originalIndex = _bgList.indexOf(bg);
                            final isSelected = _customImagePath == null && _bgIndex == originalIndex;

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _customImagePath = null;
                                  _bgIndex = originalIndex;
                                });
                                _saveCardPreferences();
                                Navigator.pop(context);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDark ? const Color(0xFFFFD700) : const Color(0xFFD35400))
                                        : (isDark ? Colors.white12 : const Color(0x1F8D6E63)),
                                    width: isSelected ? 3.5 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? (isDark ? const Color(0x55FFD700) : const Color(0x44D35400))
                                          : (isDark ? Colors.black38 : const Color(0x148D6E63)),
                                      blurRadius: isSelected ? 8 : 4,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: AssetImage(bg['path']!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // 하단 이름 그라데이션 배너
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withAlpha(200),
                                            ],
                                          ),
                                        ),
                                        child: Text(
                                          bg['name']!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.2,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),

                                    // 우측 상단 선택 체크 뱃지
                                    if (isSelected)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFFFFD700) : const Color(0xFFD35400),
                                            shape: BoxShape.circle,
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black45,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 16,
                                            color: isDark ? Colors.black : Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // Preset Quote Selector Popup Modal Bottom Sheet with Category Filter Tabs
  void _showQuotePicker(BuildContext context) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<String> categories = _presetCategories.keys.toList();
    String selectedCategoryTab = categories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final quoteList = _presetCategories[selectedCategoryTab] ?? [];

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161926) : const Color(0xFFFAF7F2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 0.8,
                minChildSize: 0.45,
                maxChildSize: 0.94,
                expand: false,
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      // 1. 상단 선셋 그라데이션 타이틀 헤더 바
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 14, 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF1B1B2F), const Color(0xFF2C1938), const Color(0xFF381A40)]
                                : [const Color(0xFFC0392B), const Color(0xFFD35400), const Color(0xFFE67E22)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_stories_rounded, color: Color(0xFFFFD700), size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '마음 담은 추천 문구 선택',
                                style: GoogleFonts.jua(
                                  fontSize: 19.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                              tooltip: '닫기',
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ),
                      ),

                      // 2. 카테고리 필터 칩 바 (가로 스크롤)
                      Container(
                        color: isDark ? const Color(0xFF1E2234) : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: categories.map((cat) {
                              final isCatSelected = cat == selectedCategoryTab;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: isCatSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isCatSelected
                                          ? Colors.white
                                          : (isDark ? const Color(0xFFC5CCE0) : const Color(0xFF5D4037)),
                                    ),
                                  ),
                                  selected: isCatSelected,
                                  selectedColor: isDark ? const Color(0xFF6B21A8) : const Color(0xFFD35400),
                                  backgroundColor: isDark ? const Color(0xFF272D45) : const Color(0xFFFFF1E6),
                                  side: BorderSide(
                                    color: isCatSelected
                                        ? Colors.transparent
                                        : (isDark ? Colors.white12 : const Color(0xFFFFCCBC)),
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      HapticFeedback.selectionClick();
                                      setModalState(() {
                                        selectedCategoryTab = cat;
                                      });
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 3. 우아한 카드형 문구 리스트
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: quoteList.length,
                          itemBuilder: (context, index) {
                            final quote = quoteList[index];
                            final isSelected = _textController.text.trim() == quote.trim();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? const Color(0xFF2F243A) : const Color(0xFFFFF7ED))
                                    : (isDark ? const Color(0xFF1E2234) : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFFFFD700) : const Color(0xFFD35400))
                                      : (isDark ? Colors.white12 : const Color(0x1F8D6E63)),
                                  width: isSelected ? 1.8 : 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark ? Colors.black26 : const Color(0x0A8D6E63),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _textController.text = quote;
                                    _fontSize = _calculateOptimalFontSize(quote);
                                  });
                                  _saveCardPreferences();
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // 번호 뱃지
                                      Container(
                                        width: 28,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? (isDark ? const Color(0xFFFFD700) : const Color(0xFFD35400))
                                              : (isDark ? const Color(0xFF2C324B) : const Color(0xFFFFEDE0)),
                                        ),
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? (isDark ? Colors.black : Colors.white)
                                                : (isDark ? Colors.white70 : const Color(0xFFBF360C)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // 문구 텍스트 본문
                                      Expanded(
                                        child: Text(
                                          quote,
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            height: 1.45,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected
                                                ? (isDark ? const Color(0xFFFFD700) : const Color(0xFFBF360C))
                                                : (isDark ? const Color(0xFFE0E6ED) : const Color(0xFF2C1810)),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      // 선택/추가 액션 뱃지
                                      Container(
                                        width: 28,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? (isDark ? const Color(0xFFFFD700) : const Color(0xFFD35400))
                                              : (isDark ? const Color(0xFF2C324B).withValues(alpha: 0.5) : const Color(0xFFF5EBE6)),
                                        ),
                                        child: Icon(
                                          isSelected ? Icons.check_rounded : Icons.add_rounded,
                                          size: 17,
                                          color: isSelected
                                              ? (isDark ? Colors.black : Colors.white)
                                              : (isDark ? Colors.white54 : const Color(0xFF8D6E63)),
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
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// 카카오톡 및 공유 카드 전송 시 둥근 테두리 바깥쪽 모서리를 테두리 색상으로 완벽하게 채워주는 커스텀 페인터
class CardBorderPainter extends CustomPainter {
  final Color color;
  final double borderWidth;
  final double cornerRadius;

  const CardBorderPainter({
    required this.color,
    this.borderWidth = 4.5,
    this.cornerRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. 외곽 사각형 (전체 캔버스 끝단까지 90도 밀착)
    final Rect outerRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 2. 내부 둥근 모서리 사각형 (테두리 두께만큼 안쪽으로 인셋되고 cornerRadius만큼 라운딩)
    final double innerW = (size.width - borderWidth * 2).clamp(0.0, double.infinity);
    final double innerH = (size.height - borderWidth * 2).clamp(0.0, double.infinity);
    final Rect innerRect = Rect.fromLTWH(
      borderWidth,
      borderWidth,
      innerW,
      innerH,
    );
    final RRect innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(cornerRadius),
    );

    // 3. outerRect와 innerRRect 사이의 영역(4변 테두리 + 4개 모서리 바깥 여백)을 테두리 색상으로 빈틈없이 채움
    final Path path = Path()
      ..addRect(outerRect)
      ..addRRect(innerRRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CardBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}
