import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ad_service.dart';
import '../services/card_archive_service.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../widgets/help_dialog.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<String>? sharedTextNotifier;
  final ValueNotifier<SavedCard?>? sharedCardNotifier;

  const HomeScreen({
    super.key,
    this.sharedTextNotifier,
    this.sharedCardNotifier,
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

  // Background Images with Categories & Titles
  final List<Map<String, String>> _bgList = [
    // 🌸 봄
    {
      'path': 'assets/images/bg_season_spring.jpg',
      'name': '🌸 벚꽃과 개나리 마을',
      'category': '🌸 봄',
    },
    {
      'path': 'assets/images/bg_cherry_blossom.png',
      'name': '🌸 벚꽃 길과 봄날',
      'category': '🌸 봄',
    },
    {
      'path': 'assets/images/bg2.png',
      'name': '🌺 화사한 봄꽃 정원',
      'category': '🌸 봄',
    },
    {
      'path': 'assets/images/bg_garden_path.jpg',
      'name': '🌷 꽃길 따라 봄 산책',
      'category': '🌸 봄',
    },

    // 🌿 여름
    {
      'path': 'assets/images/bg_season_summer.jpg',
      'name': '🌊 청량한 여름 계곡과 산',
      'category': '🌿 여름',
    },
    {
      'path': 'assets/images/bg_sunflower.png',
      'name': '🌻 황금빛 해바라기 밭',
      'category': '🌿 여름',
    },
    {
      'path': 'assets/images/bg_green_forest.jpg',
      'name': '🍃 싱그러운 초록 숲',
      'category': '🌿 여름',
    },
    {
      'path': 'assets/images/bg_lake.png',
      'name': '🏞️ 시원한 물안개 호수',
      'category': '🌿 여름',
    },

    // 🍁 가을
    {
      'path': 'assets/images/bg_season_autumn.jpg',
      'name': '🍁 단풍과 은행나무 한옥길',
      'category': '🍁 가을',
    },
    {
      'path': 'assets/images/bg3.png',
      'name': '🍂 단풍 가득한 가을 산길',
      'category': '🍁 가을',
    },
    {
      'path': 'assets/images/bg_forest_1786333154906.png',
      'name': '🌲 깊어가는 가을 숲',
      'category': '🍁 가을',
    },

    // ❄️ 겨울
    {
      'path': 'assets/images/bg_season_winter.jpg',
      'name': '❄️ 눈부신 설경 한옥 마을',
      'category': '❄️ 겨울',
    },
    {
      'path': 'assets/images/bg_winter_camellia.jpg',
      'name': '🌺 설경 속 붉은 겨울 동백꽃',
      'category': '❄️ 겨울',
    },
    {
      'path': 'assets/images/bg_winter_snow_forest.jpg',
      'name': '🌲 환상적인 눈꽃 숲길',
      'category': '❄️ 겨울',
    },
    {
      'path': 'assets/images/bg_winter_tea_cozy.jpg',
      'name': '🍵 눈 내리는 날 따뜻한 전통차',
      'category': '❄️ 겨울',
    },
    {
      'path': 'assets/images/bg_mountain_mist.jpg',
      'name': '⛰️ 안개 낀 고요한 설산',
      'category': '❄️ 겨울',
    },

    // 🌅 일출/자연
    {
      'path': 'assets/images/bg1.png',
      'name': '🌅 화사한 일출과 햇살',
      'category': '🌅 일출/자연',
    },
    {
      'path': 'assets/images/bg_sunrise_1786333105571.png',
      'name': '🌄 은은한 아침 햇살',
      'category': '🌅 일출/자연',
    },
    {
      'path': 'assets/images/bg_sunrise_mountain.jpg',
      'name': '🏔️ 산 너머 붉은 새벽',
      'category': '🌅 일출/자연',
    },
    {
      'path': 'assets/images/bg_meadow.jpg',
      'name': '🌿 햇살 가득한 초원',
      'category': '🌅 일출/자연',
    },

    // 🌸 꽃/정원
    {
      'path': 'assets/images/bg4.png',
      'name': '🌹 정열의 붉은 장미',
      'category': '🌸 꽃/정원',
    },
    {
      'path': 'assets/images/bg_rose_1786333119291.png',
      'name': '💐 향기로운 장미 부케',
      'category': '🌸 꽃/정원',
    },
    {
      'path': 'assets/images/bg_wildflowers.jpg',
      'name': '🌼 들꽃 피는 오후',
      'category': '🌸 꽃/정원',
    },

    // 🎋 동양/전통
    {
      'path': 'assets/images/bg_bamboo.png',
      'name': '🎋 푸르른 대나무 숲',
      'category': '🎋 동양/전통',
    },
    {
      'path': 'assets/images/bg5.png',
      'name': '🪷 대나무와 단아한 연꽃',
      'category': '🎋 동양/전통',
    },
    {
      'path': 'assets/images/bg_tea.png',
      'name': '🍵 여유로운 따뜻한 차 한잔',
      'category': '🎋 동양/전통',
    },
    {
      'path': 'assets/images/bg_temple.jpg',
      'name': '⛩️ 고즈넉한 사찰 풍경',
      'category': '🎋 동양/전통',
    },
    {
      'path': 'assets/images/bg_traditional_tea.jpg',
      'name': '🫖 정갈한 전통 차 시간',
      'category': '🎋 동양/전통',
    },

    // 🌙 밤/감성
    {
      'path': 'assets/images/bg6.png',
      'name': '🌙 은은한 밤하늘과 달빛',
      'category': '🌙 밤/감성',
    },
    {
      'path': 'assets/images/bg_moonlight.jpg',
      'name': '🌕 달빛 비추는 밤',
      'category': '🌙 밤/감성',
    },
    {
      'path': 'assets/images/bg_starlit_mountains.jpg',
      'name': '✨ 별빛 아래 산책',
      'category': '🌙 밤/감성',
    },

    // ☕ 일상/힐링
    {
      'path': 'assets/images/bg_coffee_1786333143337.png',
      'name': '☕ 따뜻한 아침 커피 한잔',
      'category': '☕ 일상/힐링',
    },
    {
      'path': 'assets/images/bg_cozy_coffee.jpg',
      'name': '☕ 포근한 커피 향기',
      'category': '☕ 일상/힐링',
    },
    {
      'path': 'assets/images/bg_warm_home.jpg',
      'name': '🛋️ 편안한 집에서의 휴식',
      'category': '☕ 일상/힐링',
    },
  ];

  // Presets categorized for seniors (6 Rich Categories, 65+ Heart-warming Sentences)
  final Map<String, List<String>> _presetCategories = {
    '🌅 아침 인사 & 덕담': [
      "좋은 아침입니다! 오늘도 희망차고 활기찬 하루 되세요 ☀️",
      "오늘 하루도 감사와 기쁨이 넘치시길 기도합니다 🌸",
      "상쾌한 아침! 웃음꽃 피는 행복한 하루 보내세요 😊",
      "복되고 좋은 아침, 언제나 당신을 마음 깊이 응원합니다! 🙏",
      "오늘도 안녕하고 평안한 하루 되세요, 따뜻한 마음을 전합니다 💞",
      "새 아침이 열렸습니다. 오늘도 행복의 꽃을 피워보세요 🌸",
      "당신이 있어 세상이 더욱 따뜻합니다. 좋은 하루 보내세요 ✨",
      "아침의 맑은 공기처럼 기분 좋은 일들만 가득하길 🍃",
      "새벽을 여는 맑은 햇살처럼 찬란하고 빛나는 하루 되세요 🌞",
      "마음속에 사랑과 기쁨이 가득한 복된 아침 맞이하세요 🌷",
      "오늘 하루도 당신의 모든 발걸음마다 행운이 가득하길 응원합니다 🍀",
    ],
    '💖 건강 & 무병장수': [
      "첫째도 건강! 둘째도 건강! 오늘 하루도 무병장수하세요 💪",
      "마음은 청춘! 기분 좋은 웃음과 건강이 함께하는 날 되세요 🌿",
      "소중한 분들과 맛있는 음식 드시고 항상 만수무강하세요 🍚🌸",
      "몸도 마음도 무탈하고 평안한 하루 되시길 기도합니다 🍵",
      "당신의 맑은 미소가 온 세상을 환하게 밝힙니다 ✨",
      "매일매일 더 건강해지시고 활기찬 날들 보내세요 🌿",
      "건강이 최고의 자산입니다. 오늘 하루도 소중히 챙기세요 💪",
      "아프지 마시고 늘 웃음꽃 가득한 건강한 하루 보내세요 🌼",
      "몸은 튼튼하게, 마음은 편안하게! 무탈한 하루를 축원합니다 🫖",
      "사계절 내내 푸른 소나무처럼 늘 건강하시길 소망합니다 🌲",
    ],
    '🍀 응원 & 격려': [
      "당신이 있어 참 든든하고 좋습니다! 오늘도 힘내세요 👍",
      "꿈꾸고 바라는 모든 일들이 잘 이루어지는 축복의 날 되세요 ✨",
      "오늘 하루도 수고 많으셨습니다. 당신은 최고의 존재입니다 ⭐",
      "늘 변함없이 곁에 계셔주셔서 진심으로 감사합니다 ❤️",
      "오늘도 당신이 걷는 길마다 향기로운 꽃길만 가득하길 🌸🌼",
      "어려운 일도 슬기롭게 잘 지나갈 것입니다. 힘내세요! 🔥",
      "당신의 노력을 항상 마음 깊이 응원합니다. 파이팅! 👏",
      "비바람 뒤에는 반드시 눈부신 무지개가 뜹니다. 힘내세요 🌈",
      "당신의 땀방울과 헌신은 세상에서 가장 고귀합니다 👑",
      "어떤 순간에도 당신을 진심으로 믿고 응원합니다 파이팅! 💖",
    ],
    '📜 오늘의 명언 & 지혜': [
      "가장 보람찬 날은 웃음으로 가득 찬 날이다.",
      "행복은 멀리 있지 않고 내 마음속에 있습니다.",
      "오늘이라는 선물에 감사하며 기쁘게 살아가자.",
      "웃으며 사는 인생이 가장 성공한 인생입니다.",
      "사랑하며 사는 삶에 슬픔이란 없습니다.",
      "마음이 마음을 알아볼 때 비로소 참된 인연이 됩니다.",
      "매일 만나는 소중한 하루하루가 삶의 가장 큰 기적입니다.",
      "세상에서 가장 아름다운 것은 가슴으로 느끼는 사랑이다.",
      "물이 흐르듯 겸손하고 너그러운 마음으로 살아가자.",
      "마음을 비우면 고요한 평화와 행복이 차오릅니다.",
      "지금 내 곁에 있는 소중한 사람에게 따뜻한 온기를 전하자.",
    ],
    '🌙 저녁 & 안부 인사': [
      "오늘 하루도 정말 수고 많으셨습니다. 편안한 밤 되세요 🌙",
      "별빛처럼 고운 밤, 행복하고 예쁜 꿈 꾸시고 주무세요 ⭐",
      "오늘의 지친 마음 내려놓고 따뜻하고 평안한 밤 맞이하세요 🛌",
      "내일도 기분 좋은 상쾌한 아침으로 만나요 ✨",
      "수고한 나 자신에게도 감사한 밤, 굿나잇 🌟",
      "포근한 이불 속에서 모든 근심 잊고 꿀잠 주무세요 😴",
      "오늘 밤도 당신의 꿈자리가 꽃향기로 가득하길 바랍니다 🌸",
    ],
    '🎂 축하 & 감사': [
      "당신의 기쁜 날을 진심으로 함께 축하드립니다 🎉",
      "베풀어주신 따뜻한 은혜와 사랑에 깊이 감사드립니다 💐",
      "늘 좋은 기운 나누어 주셔서 감사합니다 ❤️",
      "오늘처럼 특별하고 행복한 날, 축복이 가득하기를 🎂",
      "당신이라는 귀한 분을 알게 되어 참으로 감사합니다 🌹",
      "보내주신 정성과 마음에 머리 숙여 깊은 감사를 전합니다 🙏",
    ],
  };

  int _bgIndex = 0;
  double _fontSize = 32.0;
  Color _textColor = const Color(0xFFFFD700); // Golden Yellow
  Color? _borderColor = const Color(
    0xFFFFD700,
  ); // Border color (null = no border)
  final String _selectedFontFamily = 'Jua';
  int _todayQuoteIndex = 0;

  // 5 Main Fast Text Colors
  final List<Map<String, dynamic>> _defaultColors = const [
    {'name': '황금색', 'color': Color(0xFFFFD700)},
    {'name': '순백색', 'color': Colors.white},
    {'name': '장미 빨강', 'color': Color(0xFFFF1744)},
    {'name': '코랄 핑크', 'color': Color(0xFFFF4081)},
    {'name': '에메랄드', 'color': Color(0xFF00E676)},
  ];

  bool _isDecorateExpanded = false;
  bool _showWatermark = true;

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

    if (widget.sharedTextNotifier != null &&
        widget.sharedTextNotifier!.value.isNotEmpty) {
      _textController.text = widget.sharedTextNotifier!.value;
    } else {
      final defaultList =
          _presetCategories['🌅 아침 인사 & 덕담'] ?? _presetCategories.values.first;
      _textController.text = defaultList.first;
    }
    widget.sharedTextNotifier?.addListener(_onExternalTextChange);
    widget.sharedCardNotifier?.addListener(_onSavedCardSelected);
    NotificationService.instance.onNotificationClick = (quoteText) {
      if (mounted) {
        setState(() {
          _textController.text = quoteText;
          _fontSize = _calculateOptimalFontSize(quoteText);
        });
        _saveCardPreferences();
      }
    };
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
    final showWatermark = prefs.getBool('show_watermark') ?? true;

    setState(() {
      _soundEnabled = enabled;
      _notificationEnabled = notiEnabled;
      _isDecorateExpanded = isExpanded;
      _showWatermark = showWatermark;

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
      await prefs.setBool('show_watermark', _showWatermark);
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

  Future<void> _toggleNotification() async {
    HapticFeedback.lightImpact();
    final nextState = !_notificationEnabled;
    setState(() {
      _notificationEnabled = nextState;
    });

    await NotificationService.instance.saveSettings(
      isEnabled: nextState,
      time: const TimeOfDay(hour: 9, minute: 0),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextState
                ? '☀️ 매일 오전 9시 아침 안부 알림이 켜졌습니다 🔔'
                : '🔕 아침 안부 알림이 꺼졌습니다',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: nextState ? const Color(0xFFD35400) : const Color(0xFF455A64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  /// 텍스트 길이 및 줄 바꿈 수에 따라 카드에 딱 맞는 황금 비율 폰트 크기 자동 계산 (명언 17~18pt 대역 최적화)
  double _calculateOptimalFontSize(String text) {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return 24.0;

    final len = cleanText.length;
    final lines = cleanText.split('\n').length;

    if (len <= 25 && lines <= 2) {
      return 28.0; // 짧은 아침 인사 (1~2줄)
    } else if (len <= 55 && lines <= 3) {
      return 23.0; // 보통 길이 덕담 (2~3줄)
    } else if (len <= 90 && lines <= 5) {
      return 18.5; // 중간 길이 명언 (4~5줄)
    } else if (len <= 140 || lines <= 8) {
      return 17.5; // 긴 명언/시 (6~8줄, 사용자 지정 17~18pt 대역)
    } else {
      return 16.5; // 장문 좋은글 (9줄 이상)
    }
  }

  void _onExternalTextChange() {
    if (widget.sharedTextNotifier != null &&
        widget.sharedTextNotifier!.value.isNotEmpty) {
      final newText = widget.sharedTextNotifier!.value;
      setState(() {
        _textController.text = newText;
        _fontSize = _calculateOptimalFontSize(newText);
      });
      _saveCardPreferences();
    }
  }

  /// 현재 날짜, 요일, 시간대, 그리고 계절/날씨(여름 폭염, 겨울 한파, 봄/가을 환절기)를 종합 인식하여
  /// 최적의 감동 추천 문구 목록을 반환하는 스마트 큐레이션 엔진
  List<Map<String, String>> _getDateTimeRecommendedQuotes() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;
    final weekday = now.weekday; // 1: 월, 2: 화, ..., 7: 일
    final hour = now.hour;

    final weekdayNames = ['', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekdayName = weekdayNames[weekday];

    // 시간대 구분
    String timeTag;
    if (hour >= 5 && hour < 11) {
      timeTag = '상쾌한 아침';
    } else if (hour >= 11 && hour < 17) {
      timeTag = '화사한 오후';
    } else if (hour >= 17 && hour < 22) {
      timeTag = '아늑한 저녁';
    } else {
      timeTag = '편안한 밤';
    }

    final List<Map<String, String>> list = [];

    // 🌊 1. [계절/날씨 특화 문구 - 폭염/무더위/계절 건강 안부 최우선 배치]
    if (month >= 6 && month <= 8) {
      // 한여름 폭염 & 무더위 시즌
      if (hour < 12) {
        list.add({
          'tag': '$month월 $day일 폭염·무더위 건강 안부 ☀️',
          'quote': '연일 계속되는 불볕더위에 건강 유의하시고,\n시원한 물과 휴식으로 활기찬 하루 보내세요 🧊💧',
        });
        list.add({
          'tag': '$month월 $day일 $weekdayName 여름 아침 인사 🌊',
          'quote': '무더운 폭염 속에서도 지치지 마시고,\n마음만은 청량하고 상쾌한 하루 되세요 🌿🎐',
        });
      } else if (hour < 18) {
        list.add({
          'tag': '$month월 $day일 한낮 더위 힐링 안부 🍉',
          'quote': '더위가 절정에 달하는 오후,\n시원한 냉차 한 잔 드시며 건강 잘 챙기세요 🍹🧊',
        });
        list.add({
          'tag': '$month월 $day일 $weekdayName 오후 무더위 응원 🏖️',
          'quote': '뜨거운 여름 햇살처럼 열정 넘치되,\n시원한 그늘 아래서 여유를 누리는 날 되세요 ⛱️🍉',
        });
      } else {
        list.add({
          'tag': '$month월 $day일 열대야 안심 숙면 안부 🌙',
          'quote': '열대야를 식혀줄 시원한 밤바람 맞으며,\n오늘 밤 시원하고 편안한 꿀잠 이루세요 🌙❄️',
        });
      }
    } else if (month >= 3 && month <= 5) {
      // 봄철 꽃샘추위 / 환절기 날씨
      list.add({
        'tag': '$month월 $day일 따스한 봄날 안부 🌸',
        'quote': '화사한 봄꽃처럼 기분 좋은 하루,\n일교차 큰 날씨에 감기 조심하시고 건강하세요 🌷☕',
      });
    } else if (month >= 9 && month <= 11) {
      // 가을철 청명한 날씨 / 환절기
      list.add({
        'tag': '$month월 $day일 청명한 가을 안부 🍁',
        'quote': '높고 푸른 가을 하늘처럼 상쾌한 날,\n선선한 바람결에 행복과 건강이 가득하시길 바랍니다 🌾🍂',
      });
    } else {
      // 겨울철 한파 / 추위 날씨
      list.add({
        'tag': '$month월 $day일 따뜻한 온기 안부 ❄️',
        'quote': '찬바람 부는 추운 날씨에 옷 따뜻하게 입으시고,\n마음만은 훈훈하고 포근한 하루 보내세요 🧣☕',
      });
    }

    // 📅 2. [요일 및 시간대별 특화 문구]
    if (weekday == 1) {
      if (hour < 12) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '새로운 한 주의 시작 월요일입니다!\n이번 주도 기쁨과 행복이 가득한 날들 되세요 🌸',
        });
        list.add({
          'tag': '$month월 $day일 $weekdayName 아침 덕담',
          'quote': '활기찬 월요일 아침!\n긍정의 에너지로 힘차게 출발하세요 ☀️💪',
        });
      } else if (hour < 18) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '월요일 오후, 따뜻한 차 한 잔과 함께\n잠시 여유를 누리는 편안한 시간 되세요 ☕🌿',
        });
      } else {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '월요일 하루 정말 수고 많으셨습니다!\n오늘 밤 따뜻하고 편안한 휴식 취하세요 🌙✨',
        });
      }
    } else if (weekday == 2) {
      if (hour < 12) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '화사하게 웃는 화요일 아침입니다!\n오늘도 당신의 하루가 봄날처럼 눈부시길 바랍니다 🌷',
        });
        list.add({
          'tag': '$month월 $day일 $weekdayName 아침 응원',
          'quote': '화통하게 웃고 활짝 피어나는 화요일!\n기분 좋은 일만 가득 생기시길 응원합니다 ✨',
        });
      } else if (hour < 18) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '나른해지기 쉬운 화요일 오후,\n맑은 미소로 활력을 채우는 행복한 시간 되세요 🍃',
        });
      } else {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '화요일 저녁, 고단했던 하루를 내려놓고\n가족들과 도란도란 따뜻한 밤 보내세요 🛋️💖',
        });
      }
    } else if (weekday == 3) {
      if (hour < 12) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '한 주의 중심, 수요일 아침입니다!\n기분 좋은 에너지로 힘차게 달려가세요 ☀️🌿',
        });
        list.add({
          'tag': '$month월 $day일 $weekdayName 아침 덕담',
          'quote': '수수하게 웃으며 서로를 배려하는 수요일!\n오늘도 마음 평안한 하루 되시길 축복합니다 🌸',
        });
      } else if (hour < 18) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '수요일 오후의 향긋한 쉼표!\n달콤한 차 한 잔으로 에너지 충전하세요 ☕🍰',
        });
      } else {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '벌써 한 주의 반이 지나간 수요일 밤,\n오늘 하루도 정말 애쓰셨습니다. 편히 쉬세요 🌟',
        });
      }
    } else if (weekday == 4) {
      if (hour < 12) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '주말이 눈앞에 다가온 목요일입니다!\n오늘도 설레는 마음으로 활기차게 시작하세요 🌼',
        });
        list.add({
          'tag': '$month월 $day일 $weekdayName 아침 인사',
          'quote': '목마른 마음에 시원한 단비 같은 날!\n풍성한 감사가 넘치는 목요일 되세요 💧🙏',
        });
      } else if (hour < 18) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '목요일 오후, 소중한 이들과 따뜻한 안부 나누며\n웃음꽃 피는 시간 보내세요 💖',
        });
      } else {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '목요일 밤, 내일의 설렘을 안고\n포근하고 안락한 단잠 이루시길 바랍니다 🛌⭐',
        });
      }
    } else if (weekday == 5) {
      if (hour < 12) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '행복 가득한 금요일 아침입니다!\n한 주 동안 수고 많으셨습니다. 멋진 하루 되세요 🎉',
        });
        list.add({
          'tag': '$month월 $day일 $weekdayName 아침 덕담',
          'quote': '금빛 햇살처럼 찬란한 금요일!\n오늘 하루 기쁨과 축복이 넘쳐나길 기도합니다 ✨',
        });
      } else if (hour < 18) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '금요일 오후, 한 주를 보람차게 마무리하며\n가벼운 발걸음으로 주말을 맞이하세요 🎈',
        });
      } else {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '한 주 동안 고생 많으셨습니다!\n맛있는 저녁과 함께 행복하고 포근한 금요일 밤 되세요 🍻🍕',
        });
      }
    } else if (weekday == 6) {
      if (hour < 12) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '여유롭고 싱그러운 토요일 주말 아침!\n사랑하는 가족과 함께 웃음 넘치는 주말 보내세요 🌷',
        });
        list.add({
          'tag': '$month월 $day일 $weekdayName 주말 인사',
          'quote': '토닥토닥 서로를 응원하는 토요일!\n자연 속에서 힐링 가득한 하루 되세요 🌲🌤️',
        });
      } else if (hour < 18) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '토요일 오후, 따스한 햇살 아래 산책하며\n마음 가득 여유와 행복을 채워보세요 🚶‍♂️🌸',
        });
      } else {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '토요일 밤, 근심 걱정 모두 잊으시고\n세상에서 가장 달콤하고 편안한 꿈 꾸세요 🌙✨',
        });
      }
    } else {
      if (hour < 12) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '마음이 평안해지는 일요일 아침입니다!\n새로운 활력을 가득 충전하는 쉼의 날 되세요 🕊️',
        });
        list.add({
          'tag': '$month월 $day일 $weekdayName 주말 덕담',
          'quote': '일요일의 축복과 평화가\n당신의 가정에 늘 가득하시기를 소망합니다 🙏🌸',
        });
      } else if (hour < 18) {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '일요일 오후, 차분하고 따뜻하게 충전하며\n다가올 한 주를 기분 좋게 준비하세요 🍵🌿',
        });
      } else {
        list.add({
          'tag': '$month월 $day일 $weekdayName $timeTag',
          'quote': '일요일 밤, 편안한 마음으로 푹 주무시고\n내일 아침 활기차게 만나요 굿나잇 🌟',
        });
      }
    }

    // 💖 3. [날짜별 보편적인 지혜 문구]
    list.add({
      'tag': '$month월 $day일 오늘의 인생 명언',
      'quote': '오늘이라는 하루는 다시 오지 않는 소중한 선물!\n내 곁의 사람들과 많이 웃는 날 되세요 💖',
    });

    return list;
  }

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
                    child: _MarqueeFlowingText(
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
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Color(0xFFFFD700), size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        '✨ 추천 문구가 직접쓰기 란에 쏙 들어갔습니다!',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF2D1B36),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_note_rounded, color: Colors.white, size: 22),
                                SizedBox(width: 6),
                                Text(
                                  '직접쓰기 란에 넣기',
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

  void _onSavedCardSelected() {
    final card = widget.sharedCardNotifier?.value;
    if (card == null) return;
    final backgroundIndex = _bgList.indexWhere(
      (bg) => bg['path'] == card.backgroundPath,
    );
    setState(() {
      _textController.text = card.message;
      _bgIndex = backgroundIndex >= 0 ? backgroundIndex : 0;
      _textColor = Color(card.textColorValue);
      _borderColor = card.borderColorValue == null
          ? null
          : Color(card.borderColorValue!);
      _fontSize = card.fontSize;
    });
    _saveCardPreferences();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _petalController.dispose();
    _audioPlayer.dispose();
    widget.sharedTextNotifier?.removeListener(_onExternalTextChange);
    widget.sharedCardNotifier?.removeListener(_onSavedCardSelected);
    super.dispose();
  }

  Future<void> _saveCurrentCard() async {
    await CardArchiveService().saveCard(
      SavedCard(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        message: _textController.text.trim(),
        backgroundPath: _bgList[_bgIndex]['path']!,
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
          Icon(Icons.spa_rounded, color: const Color(0xFFFFD54F), size: iconSize),
          const SizedBox(width: 4),
          Text(
            '마음카드',
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

  Future<void> _shareImage() async {
    HapticFeedback.mediumImpact();
    await _saveCurrentCard();
    try {
      // 1. 이미 화면에 선명하게 렌더링된 카드를 GPU 버퍼에서 초고속 3.2배수 레티나 캡처 (~0.02초)
      Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 3.2,
      );

      // 2. 만약 화면 캡처가 불가한 상황일 경우 초경량 800px 규격 폴백 렌더링
      if (imageBytes == null || imageBytes.isEmpty) {
        const cardSize = 800.0;
        imageBytes = await _screenshotController.captureFromWidget(
          MediaQuery(
            data: const MediaQueryData(),
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: cardSize,
                height: cardSize,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: DecorationImage(
                      image: AssetImage(_bgList[_bgIndex]['path']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: _borderColor != null
                              ? Border.all(color: _borderColor!, width: 6.0)
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
                        padding: const EdgeInsets.all(36),
                        child: Text(
                          _textController.text,
                          textAlign: TextAlign.center,
                          style: _getAppliedTextStyle().copyWith(
                            fontSize: _fontSize * 1.85,
                          ),
                        ),
                      ),
                      if (_showWatermark)
                        Positioned(
                          right: 24,
                          bottom: 24,
                          child: _buildWatermarkBadge(
                            fontSize: 22,
                            iconSize: 26,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          pixelRatio: 1.0,
          targetSize: const Size(cardSize, cardSize),
        );
      }

      if (imageBytes.isNotEmpty) {
        final directory = await getTemporaryDirectory();
        final fileName = 'good_morning_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imagePath = await File('${directory.path}/$fileName').create();
        await imagePath.writeAsBytes(imageBytes);

        final result = await Share.shareXFiles(
          [XFile(imagePath.path, mimeType: 'image/jpeg')],
          text: '소중한 분께 전하는 따뜻한 아침인사 카드입니다 🌸\n\n'
              '━━━━━━━━━━━━━━━\n'
              '💌 나만의 감성 아침카드 & 명언 만들기\n'
              '👉 https://play.google.com/store/apps/details?id=com.sintong.good_morning',
        );

        // 실제 공유 완료 시에만 3회당 1회 광고 노출 (취소하고 닫았을 때는 미노출)
        if (result.status == ShareResultStatus.success) {
          AdService().showInterstitialAdOnShare();
        }
      }
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  TextStyle _getAppliedTextStyle() {
    switch (_selectedFontFamily) {
      case 'DoHyeon':
        return GoogleFonts.doHyeon(
          fontSize: _fontSize,
          color: _textColor,
          shadows: [
            const Shadow(
              offset: Offset(2, 2),
              blurRadius: 4,
              color: Colors.black87,
            ),
            const Shadow(
              offset: Offset(-2, -2),
              blurRadius: 4,
              color: Colors.black87,
            ),
          ],
        );
      case 'NanumGothic':
        return GoogleFonts.nanumGothic(
          fontSize: _fontSize,
          fontWeight: FontWeight.bold,
          color: _textColor,
          shadows: [
            const Shadow(
              offset: Offset(2, 2),
              blurRadius: 4,
              color: Colors.black87,
            ),
          ],
        );
      case 'Jua':
      default:
        return GoogleFonts.jua(
          fontSize: _fontSize,
          color: _textColor,
          shadows: [
            const Shadow(
              offset: Offset(2, 2),
              blurRadius: 4,
              color: Colors.black87,
            ),
            const Shadow(
              offset: Offset(-2, -2),
              blurRadius: 4,
              color: Colors.black87,
            ),
          ],
        );
    }
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
              tooltip: _notificationEnabled ? '아침 9시 알림 끄기' : '아침 9시 알림 켜기',
              onPressed: _toggleNotification,
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
                      painter: _FlowerPetalPainter(
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
                            painter: _FlowerPetalPainter(
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
                              child: Screenshot(
                                controller: _screenshotController,
                                child: AspectRatio(
                                  aspectRatio: 1.0,
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
                                      image: DecorationImage(
                                        image: AssetImage(_bgList[_bgIndex]['path']!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          clipBehavior: Clip.antiAlias,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            border: _borderColor != null
                                                ? Border.all(color: _borderColor!, width: 4.5)
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
                                                fontSize: (_fontSize * 0.95).clamp(15.0, 44.0),
                                                height: 1.35,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (_showWatermark)
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // SCROLLABLE BOTTOM: Clean Step-by-Step Flow for Seniors with generous spacing
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                          '크기 · 색상 · 테두리 · 이모티콘',
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
                                        if (_fontSize > 20) {
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
                              Divider(
                                height: 14,
                                color: isDark ? Colors.transparent : const Color(0x1F8D6E63),
                              ),

                              // Watermark Brand Badge Toggle
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1F2333) : const Color(0xFFFFF7F0),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : const Color(0xFFFFE0B2),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.spa_rounded,
                                      size: 18,
                                      color: isDark ? const Color(0xFFFFD700) : const Color(0xFFE64A19),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '마음카드 워터마크 표시',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.5,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            '카드 우측 하단에 감성적인 출처 배지 표시',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? Colors.white70 : Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: _showWatermark,
                                      activeColor: const Color(0xFFE64A19),
                                      onChanged: (val) {
                                        HapticFeedback.selectionClick();
                                        setState(() => _showWatermark = val);
                                        _saveCardPreferences();
                                      },
                                    ),
                                  ],
                                ),
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
                          onPressed: _shareImage,
                          icon: const Icon(
                            Icons.share,
                            size: 26,
                            color: Color(0xFF371D1D),
                          ),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '📲 카카오톡으로 바로 보내기',
                              style: TextStyle(
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
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final cardSize = (screenWidth - 80).clamp(260.0, 360.0);

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
                      onPressed: () => Navigator.of(context).pop(),
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
                      image: AssetImage(_bgList[_bgIndex]['path']!),
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
                              fontSize: (_fontSize * 1.15).clamp(18.0, 48.0),
                            ),
                          ),
                        ),
                      ),
                      if (_showWatermark)
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
                    ],
                  ),
                ),
              ),

              // 3. Luxury Bottom Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    // 1. 내 카드함 보관
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 48,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: isDark ? const Color(0xFF2B3245) : const Color(0xFFFFF0E6),
                          border: Border.all(
                            color: isDark ? Colors.white12 : const Color(0xFFFFCCBC),
                            width: 1.2,
                          ),
                        ),
                        child: InkWell(
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            await _saveCurrentCard();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Color(0xFFFFD700)),
                                      SizedBox(width: 10),
                                      Text(
                                        '💌 [내 카드함]에 소중히 보관되었습니다!',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF1E2430),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bookmark_add_rounded, color: Color(0xFFD84315), size: 18),
                              const SizedBox(width: 5),
                              Text(
                                '카드 보관',
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
                    const SizedBox(width: 10),

                    // 2. 카카오톡 바로 전송
                    Expanded(
                      flex: 2,
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
                            Navigator.of(context).pop();
                            _shareImage();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                  ],
                ),
              ),
            ],
          ),
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

    String selectedCategoryTab = '전체';

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

                      // 3. 갤러리 썸네일 그리드
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
                            final isSelected = _bgIndex == originalIndex;

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
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

/// Lightweight Animated Sparkle Painter for Morning Sunlight / Star Mood
class _MorningSparklePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _MorningSparklePainter({required this.progress, required this.isDark});

  // 12 Pre-calculated particle anchor offsets (normalized 0.0 ~ 1.0)
  static const List<Offset> _anchors = [
    Offset(0.08, 0.25),
    Offset(0.18, 0.70),
    Offset(0.12, 0.85),
    Offset(0.85, 0.20),
    Offset(0.92, 0.65),
    Offset(0.88, 0.82),
    Offset(0.05, 0.50),
    Offset(0.95, 0.40),
    Offset(0.25, 0.15),
    Offset(0.75, 0.12),
    Offset(0.22, 0.90),
    Offset(0.78, 0.92),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Gentle Ambient Breathing Aura behind card
    final center = Offset(size.width / 2, size.height / 2);
    final pulseScale = 1.0 + 0.08 * math.sin(progress * 2 * math.pi);
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [
                const Color(0xFFFFD700).withAlpha((20 * pulseScale).toInt()),
                const Color(0xFF64B5F6).withAlpha((15 * pulseScale).toInt()),
                Colors.transparent,
              ]
            : [
                const Color(0xFFFFB300).withAlpha((28 * pulseScale).toInt()),
                const Color(0xFFFF8A80).withAlpha((18 * pulseScale).toInt()),
                Colors.transparent,
              ],
      ).createShader(
        Rect.fromCircle(center: center, radius: (size.height * 0.75) * pulseScale),
      );
    canvas.drawCircle(center, (size.height * 0.75) * pulseScale, auraPaint);

    // 2. 12 Floating Active Sparkles
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _anchors.length; i++) {
      final anchor = _anchors[i];
      final speed = 1.0 + (i % 3) * 0.5;
      final particlePhase = (progress * speed + (i * 0.13)) % 1.0;

      // Vertical floating & horizontal gentle wave
      final dy = size.height * (anchor.dy - (particlePhase * 0.25));
      final dx = size.width * anchor.dx + (6 * math.sin((particlePhase * 2 * math.pi) + i));

      // Twinkle alpha
      final alpha = (math.sin(particlePhase * math.pi) * 220).clamp(0, 220).toInt();
      if (alpha <= 5) continue;

      final color = isDark
          ? (i % 2 == 0 ? const Color(0xFFFFD700) : const Color(0xFF80D8FF))
          : (i % 3 == 0
              ? const Color(0xFFFFB300)
              : (i % 3 == 1 ? const Color(0xFFFF7043) : const Color(0xFFFF4081)));

      paint.color = color.withAlpha(alpha);

      // Draw 4-point Diamond Star for even indices, soft glowing circle for odd
      final currentPos = Offset(dx % size.width, dy < 0 ? size.height + dy : dy);

      if (i % 2 == 0) {
        final starSize = (3.5 + (i % 3) * 1.5) * (alpha / 220);
        final path = Path()
          ..moveTo(currentPos.dx, currentPos.dy - starSize)
          ..lineTo(currentPos.dx + starSize * 0.35, currentPos.dy)
          ..lineTo(currentPos.dx, currentPos.dy + starSize)
          ..lineTo(currentPos.dx - starSize * 0.35, currentPos.dy)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        final radius = (2.0 + (i % 2) * 1.2) * (alpha / 220);
        canvas.drawCircle(currentPos, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MorningSparklePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

/// 꽃잎/나비/새싹 플로팅 애니메이션 — 중장년층을 위한 따뜻한 자연 배경
class _FlowerPetalPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _FlowerPetalPainter({required this.progress, required this.isDark});

  // 14개 다양한 위치의 꽃잎 & 자연 파티클 앵커 (정규화 0.0 ~ 1.0)
  static const List<Offset> _petalAnchors = [
    Offset(0.04, 0.0),
    Offset(0.14, 0.0),
    Offset(0.24, 0.0),
    Offset(0.36, 0.0),
    Offset(0.48, 0.0),
    Offset(0.58, 0.0),
    Offset(0.68, 0.0),
    Offset(0.79, 0.0),
    Offset(0.89, 0.0),
    Offset(0.96, 0.0),
    Offset(0.20, 0.0),
    Offset(0.42, 0.0),
    Offset(0.62, 0.0),
    Offset(0.82, 0.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _petalAnchors.length; i++) {
      final anchor = _petalAnchors[i];
      // 각각 다른 속도로 낙하 — 느리게, 부드러운 봄바람
      final speed = 0.35 + (i % 5) * 0.12;
      final particlePhase = (progress * speed + (i * 0.071)) % 1.0;

      // 수직 낙하 + 수평 살랑거림
      final dy = particlePhase * size.height;
      final swingX = 18.0 * math.sin((particlePhase * 2 * math.pi * 1.3) + i * 0.8);
      final dx = size.width * anchor.dx + swingX;

      // 알파 (등장 페이드인 / 퇴장 페이드아웃)
      final alpha = (math.sin(particlePhase * math.pi) * 190).clamp(0, 190).toInt();
      if (alpha <= 6) continue;

      // 꽃잎 & 자연 색상 (화사한 벚꽃 핑크, 따뜻한 살구, 연한 초록 잎사귀, 골드 햇살)
      final List<Color> colors = isDark
          ? [
              const Color(0xFFFFD700), // 골드
              const Color(0xFFCE93D8), // 은은한 라벤더
              const Color(0xFF81D4FA), // 청초한 하늘
              const Color(0xFFFFAB91), // 살구빛
            ]
          : [
              const Color(0xFFFF80AB), // 벚꽃 분홍
              const Color(0xFFFFB74D), // 따뜻한 햇살 살구
              const Color(0xFFAED581), // 어린 새싹 연두
              const Color(0xFFF48FB1), // 부드러운 코랄 핑크
            ];

      paint.color = colors[i % colors.length].withAlpha(alpha);

      final pos = Offset(dx.clamp(0, size.width), dy);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      // 천천히 회전
      final rotAngle = particlePhase * 2 * math.pi * (i % 2 == 0 ? 1.0 : -0.7);
      canvas.rotate(rotAngle);

      final shapeType = i % 3;
      if (shapeType == 0) {
        // 1. 벚꽃잎 (유선형 타원)
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: 10.0 + (i % 3) * 2.0,
          height: 6.0 + (i % 2) * 1.5,
        );
        canvas.drawOval(rect, paint);
      } else if (shapeType == 1) {
        // 2. 만개한 작은 꽃송이 (4잎)
        final petalR = 3.5 + (i % 2) * 1.0;
        canvas.drawCircle(Offset.zero, petalR * 0.4, paint);
        for (int p = 0; p < 4; p++) {
          final angle = p * (math.pi / 2);
          canvas.drawCircle(
            Offset(math.cos(angle) * petalR, math.sin(angle) * petalR),
            petalR * 0.55,
            paint,
          );
        }
      } else {
        // 3. 햇살 머금은 잎사귀 / 작은 물방울
        final path = Path()
          ..moveTo(0, -6)
          ..quadraticBezierTo(5, 0, 0, 6)
          ..quadraticBezierTo(-5, 0, 0, -6)
          ..close();
        canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FlowerPetalPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

/// 무조건 옆으로 부드럽게 무한 자동 롤링되는 마키 텍스트 위젯
class _MarqueeFlowingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _MarqueeFlowingText({
    required this.text,
    required this.style,
  });

  @override
  State<_MarqueeFlowingText> createState() => _MarqueeFlowingTextState();
}

class _MarqueeFlowingTextState extends State<_MarqueeFlowingText>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 35),
    )..addListener(() {
        if (_scrollController.hasClients) {
          final max = _scrollController.position.maxScrollExtent;
          if (max > 0) {
            _scrollController.jumpTo(_animController.value * max);
          }
        }
      });

    _animController.repeat();
  }

  @override
  void didUpdateWidget(covariant _MarqueeFlowingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _animController.reset();
      _animController.repeat();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.text, style: widget.style),
          const SizedBox(width: 45),
          Text(widget.text, style: widget.style),
          const SizedBox(width: 45),
        ],
      ),
    );
  }
}
