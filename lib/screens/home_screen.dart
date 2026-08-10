import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../services/ad_service.dart';
import '../services/theme_service.dart';
import '../widgets/help_dialog.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<String>? sharedTextNotifier;

  const HomeScreen({super.key, this.sharedTextNotifier});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final TextEditingController _textController = TextEditingController();

  // Background Images
  final List<String> _bgImages = [
    'assets/images/bg1.png', // Sunrise
    'assets/images/bg2.png', // Spring flowers
    'assets/images/bg3.png', // Autumn leaves
    'assets/images/bg4.png', // Red roses
    'assets/images/bg_lake.png', // Lotus lake mist
    'assets/images/bg_bamboo.png', // Bamboo forest
    'assets/images/bg5.png', // Bamboo & Lotus
    'assets/images/bg6.png', // Moonlight night
  ];

  // Presets categorized for seniors (6 Rich Categories, 38 Heart-warming Sentences)
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
    ],
    '💖 건강 & 무병장수': [
      "첫째도 건강! 둘째도 건강! 오늘 하루도 무병장수하세요 💪",
      "마음은 청춘! 기분 좋은 웃음과 건강이 함께하는 날 되세요 🌿",
      "소중한 분들과 맛있는 음식 드시고 항상 만수무강하세요 🍚🌸",
      "몸도 마음도 무탈하고 평안한 하루 되시길 기도합니다 🍵",
      "당신의 맑은 미소가 온 세상을 환하게 밝힙니다 ✨",
      "매일매일 더 건강해지시고 활기찬 날들 보내세요 🌿",
      "건강이 최고의 자산입니다. 오늘 하루도 소중히 챙기세요 💪",
    ],
    '🍀 응원 & 격려': [
      "당신이 있어 참 든든하고 좋습니다! 오늘도 힘내세요 👍",
      "꿈꾸고 바라는 모든 일들이 잘 이루어지는 축복의 날 되세요 ✨",
      "오늘 하루도 수고 많으셨습니다. 당신은 최고의 존재입니다 ⭐",
      "늘 변함없이 곁에 계셔주셔서 진심으로 감사합니다 ❤️",
      "오늘도 당신이 걷는 길마다 향기로운 꽃길만 가득하길 🌸🌼",
      "어려운 일도 슬기롭게 잘 지나갈 것입니다. 힘내세요! 🔥",
      "당신의 노력을 항상 마음 깊이 응원합니다. 파이팅! 👏",
    ],
    '📜 오늘의 명언 & 지혜': [
      "가장 보람찬 날은 웃음으로 가득 찬 날이다.",
      "행복은 멀리 있지 않고 내 마음속에 있습니다.",
      "오늘이라는 선물에 감사하며 기쁘게 살아가자.",
      "웃으며 사는 인생이 가장 성공한 인생입니다.",
      "사랑하며 사는 삶에 슬픔이란 없습니다.",
      "마음이 마음을 알아볼 때 비로소 참된 인연이 됩니다.",
      "매일 만나는 소중한 하루하루가 삶의 가장 큰 기적입니다.",
    ],
    '🌙 저녁 & 안부 인사': [
      "오늘 하루도 정말 수고 많으셨습니다. 편안한 밤 되세요 🌙",
      "별빛처럼 고운 밤, 행복하고 예쁜 꿈 꾸시고 주무세요 ⭐",
      "오늘의 지친 마음 내려놓고 따뜻하고 평안한 밤 맞이하세요 🛌",
      "내일도 기분 좋은 상쾌한 아침으로 만나요 ✨",
      "수고한 나 자신에게도 감사한 밤, 굿나잇 🌟",
    ],
    '🎂 축하 & 감사': [
      "당신의 기쁜 날을 진심으로 함께 축하드립니다 🎉",
      "베풀어주신 따뜻한 은혜와 사랑에 깊이 감사드립니다 💐",
      "늘 좋은 기운 나누어 주셔서 감사합니다 ❤️",
      "오늘처럼 특별하고 행복한 날, 축복이 가득하기를 🎂",
    ],
  };

  String _selectedCategory = '🌅 아침 인사 & 덕담';
  int _bgIndex = 0;
  double _fontSize = 32.0;
  Color _textColor = const Color(0xFFFFD700); // Golden Yellow
  Color? _borderColor = const Color(0xFFFFD700); // Border color (null = no border)
  final String _selectedFontFamily = 'Jua';

  // 5 Main Fast Text Colors
  final List<Map<String, dynamic>> _defaultColors = const [
    {'name': '황금색', 'color': Color(0xFFFFD700)},
    {'name': '순백색', 'color': Colors.white},
    {'name': '장미 빨강', 'color': Color(0xFFFF1744)},
    {'name': '코랄 핑크', 'color': Color(0xFFFF4081)},
    {'name': '에메랄드', 'color': Color(0xFF00E676)},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.sharedTextNotifier != null && widget.sharedTextNotifier!.value.isNotEmpty) {
      _textController.text = widget.sharedTextNotifier!.value;
    } else {
      final defaultList = _presetCategories[_selectedCategory] ?? _presetCategories.values.first;
      _textController.text = defaultList.first;
    }
    widget.sharedTextNotifier?.addListener(_onExternalTextChange);
    AdService().loadInterstitialAd();
  }

  void _onExternalTextChange() {
    if (widget.sharedTextNotifier != null && widget.sharedTextNotifier!.value.isNotEmpty) {
      setState(() {
        _textController.text = widget.sharedTextNotifier!.value;
      });
    }
  }

  @override
  void dispose() {
    widget.sharedTextNotifier?.removeListener(_onExternalTextChange);
    super.dispose();
  }

  void _changeBackground() {
    HapticFeedback.lightImpact();
    setState(() {
      _bgIndex = (_bgIndex + 1) % _bgImages.length;
    });
  }

  void _changeRandomQuote() {
    HapticFeedback.lightImpact();
    final list = _presetCategories[_selectedCategory] ?? _presetCategories.values.first;
    final random = Random();
    int newIndex;
    do {
      newIndex = random.nextInt(list.length);
    } while (list[newIndex] == _textController.text && list.length > 1);

    setState(() {
      _textController.text = list[newIndex];
    });
  }

  Future<void> _shareImage() async {
    HapticFeedback.mediumImpact();
    AdService().showInterstitialAd(onAdDismissed: () async {
      try {
        final imageBytes = await _screenshotController.capture();
        if (imageBytes != null) {
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = await File('${directory.path}/good_morning_card.png').create();
          await imagePath.writeAsBytes(imageBytes);

          // ignore: deprecated_member_use
          await Share.shareXFiles(
            [XFile(imagePath.path)],
            text: '소중한 분께 전달하는 아침인사 카드입니다 🌸',
          );
        }
      } catch (e) {
        debugPrint('Error sharing image: $e');
      }
    });
  }

  TextStyle _getAppliedTextStyle() {
    switch (_selectedFontFamily) {
      case 'DoHyeon':
        return GoogleFonts.doHyeon(
          fontSize: _fontSize,
          color: _textColor,
          shadows: [
            const Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black87),
            const Shadow(offset: Offset(-2, -2), blurRadius: 4, color: Colors.black87),
          ],
        );
      case 'NanumGothic':
        return GoogleFonts.nanumGothic(
          fontSize: _fontSize,
          fontWeight: FontWeight.bold,
          color: _textColor,
          shadows: [
            const Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black87),
          ],
        );
      case 'Jua':
      default:
        return GoogleFonts.jua(
          fontSize: _fontSize,
          color: _textColor,
          shadows: [
            const Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black87),
            const Shadow(offset: Offset(-2, -2), blurRadius: 4, color: Colors.black87),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF311B92), const Color(0xFF8E24AA)]
                  : [const Color(0xFFD81B60), const Color(0xFFFF8F00)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          '🌅 아침인사 & 명언 메이커',
          style: GoogleFonts.jua(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          // Theme Toggle Button (Light / Dark)
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny : Icons.nightlight_round,
              color: isDark ? const Color(0xFFFFD700) : Colors.white,
            ),
            tooltip: isDark ? '라이트 모드로 전환' : '다크 모드로 전환',
            onPressed: () {
              HapticFeedback.lightImpact();
              ThemeService().toggleTheme();
            },
          ),
          // Help Dialog Button
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            tooltip: '사용 가이드',
            onPressed: () {
              HapticFeedback.lightImpact();
              HelpDialog.show(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // FIXED STICKY TOP: Live Canvas Preview (Always visible while scrolling controls below!)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: Screenshot(
                  controller: _screenshotController,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                        image: DecorationImage(
                          image: AssetImage(_bgImages[_bgIndex]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: _borderColor != null
                              ? Border.all(
                                  color: _borderColor!,
                                  width: 5.0,
                                )
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
                            style: _getAppliedTextStyle(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // SCROLLABLE BOTTOM: Toolbars, Categories, Text Fields & Buttons
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Category Selector (Tabs)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _presetCategories.keys.map((category) {
                        final isSelected = category == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(
                              category,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.grey.shade200 : Colors.black87),
                              ),
                            ),
                            selectedColor: isDark ? const Color(0xFF8E24AA) : const Color(0xFFD81B60),
                            backgroundColor: isDark ? const Color(0xFF262636) : Colors.white,
                            elevation: 2,
                            onSelected: (selected) {
                              if (selected) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedCategory = category;
                                  final catList = _presetCategories[category] ?? [];
                                  if (catList.isNotEmpty) {
                                    _textController.text = catList.first;
                                  }
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Preset Quotes Horizontal Scroll
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (_presetCategories[_selectedCategory] ?? []).length,
                      itemBuilder: (context, index) {
                        final text = (_presetCategories[_selectedCategory] ?? [])[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: const Icon(Icons.touch_app, size: 16, color: Colors.amber),
                            label: Text(
                              text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey.shade200 : Colors.black87,
                              ),
                            ),
                            backgroundColor: isDark ? const Color(0xFF2E2E3E) : Colors.amber.shade50,
                            side: BorderSide(
                              color: isDark ? Colors.amber.shade700 : Colors.amber.shade300,
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _textController.text = text;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. Quick Toolbar: Size, Border Color, Text Color
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        children: [
                          // Size Controls
                          Row(
                            children: [
                              const Text('글자 크기: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.deepOrange),
                                onPressed: () {
                                  if (_fontSize > 20) {
                                    setState(() => _fontSize -= 2);
                                  }
                                },
                              ),
                              Text('${_fontSize.toInt()}pt', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.deepOrange),
                                onPressed: () {
                                  if (_fontSize < 50) {
                                    setState(() => _fontSize += 2);
                                  }
                                },
                              ),
                              const Spacer(),
                            ],
                          ),
                          const Divider(height: 12),
                          // Frame Style Selector (Identical to Text Color Selector)
                          Row(
                            children: [
                              const Text('테두리 장식: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      // ❌ 테두리 없음 Toggle
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() => _borderColor = null);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _borderColor == null
                                                ? (isDark ? Colors.red.withAlpha(80) : Colors.red.shade100)
                                                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: _borderColor == null ? Colors.red : Colors.grey.shade400,
                                              width: _borderColor == null ? 2 : 1,
                                            ),
                                          ),
                                          child: Text(
                                            '❌ 없음',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: _borderColor == null ? FontWeight.bold : FontWeight.normal,
                                              color: _borderColor == null ? Colors.red : (isDark ? Colors.white70 : Colors.black87),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      // 5 Main Border Color Circles
                                      ..._defaultColors.map((item) {
                                        final Color color = item['color'];
                                        final isSelected = _borderColor == color;
                                        return GestureDetector(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            setState(() => _borderColor = color);
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 4),
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected ? (isDark ? Colors.amber : Colors.black) : Colors.grey.shade400,
                                                width: isSelected ? 3.5 : 1,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(color: Colors.black12, blurRadius: 2),
                                              ],
                                            ),
                                            child: isSelected
                                                ? Icon(
                                                    Icons.check,
                                                    size: 20,
                                                    color: (color == Colors.white) ? Colors.black : Colors.white,
                                                  )
                                                : null,
                                          ),
                                        );
                                      }),
                                      const SizedBox(width: 6),
                                      // Custom RGB Frame Color Picker Button
                                      InkWell(
                                        onTap: () => _showRGBColorPicker(context, isBorder: true),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFFF1744), Color(0xFFFFD700), Color(0xFF00E676), Color(0xFF29B6F6)],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: const [
                                              BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                                child: const Icon(Icons.crop_square, size: 14, color: Colors.black87),
                                              ),
                                              const SizedBox(width: 6),
                                              const Text(
                                                '🎨 RGB 테두리 선택',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
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
                          const Divider(height: 12),
                          // Text Colors: 5 Main Colors + '🎨 RGB 글자 선택' Button
                          Row(
                            children: [
                              const Text('글자 색상: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ..._defaultColors.map((item) {
                                        final Color color = item['color'];
                                        final isSelected = _textColor == color;
                                        return GestureDetector(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            setState(() => _textColor = color);
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 4),
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected ? (isDark ? Colors.amber : Colors.black) : Colors.grey.shade400,
                                                width: isSelected ? 3.5 : 1,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(color: Colors.black12, blurRadius: 2),
                                              ],
                                            ),
                                            child: isSelected
                                                ? Icon(
                                                    Icons.check,
                                                    size: 20,
                                                    color: (color == Colors.white) ? Colors.black : Colors.white,
                                                  )
                                                : null,
                                          ),
                                        );
                                      }),
                                      const SizedBox(width: 6),
                                      // Custom RGB Text Color Picker Button
                                      InkWell(
                                        onTap: () => _showRGBColorPicker(context, isBorder: false),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFFF1744), Color(0xFFFFD700), Color(0xFF00E676), Color(0xFF29B6F6)],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: const [
                                              BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                                child: const Icon(Icons.colorize, size: 14, color: Colors.black87),
                                              ),
                                              const SizedBox(width: 6),
                                              const Text(
                                                '🎨 RGB 글자 선택',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
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
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 4. Custom Text Field
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: '✍️ 원하는 문구 직접 쓰기',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFFFD700) : Colors.deepOrange,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.amber : Colors.orange),
                      ),
                    ),
                    maxLines: 2,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // 5. Change Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _changeRandomQuote,
                          icon: Icon(Icons.casino, color: isDark ? Colors.purple.shade200 : Colors.purple),
                          label: const Text('문구 무작위', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF2D233C) : Colors.purple.shade50,
                            foregroundColor: isDark ? Colors.purple.shade100 : Colors.purple.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _changeBackground,
                          icon: const Icon(Icons.photo_library, color: Colors.teal),
                          label: const Text('배경 변경', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF1B3332) : Colors.teal.shade50,
                            foregroundColor: isDark ? Colors.teal.shade100 : Colors.teal.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 6. Main Action Button: Share / Save
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _shareImage,
                      icon: const Icon(Icons.share, size: 30, color: Colors.black87),
                      label: const Text(
                        '📲 카카오톡 공유 / 갤러리 저장',
                        style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE500), // Kakao Yellow
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFFFD700), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // RGB Color Picker (Clean Visual Palette Wheel, No Numbers or Text Inputs)
  void _showRGBColorPicker(BuildContext context, {bool isBorder = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color tempColor = isBorder ? (_borderColor ?? const Color(0xFFFFD700)) : _textColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              Icon(isBorder ? Icons.crop_square : Icons.palette, color: const Color(0xFFD81B60), size: 24),
              const SizedBox(width: 8),
              Text(
                isBorder ? '🖼️ RGB 테두리 색상 선택' : '🎨 RGB 글자 색상 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPicker(
                  pickerColor: tempColor,
                  onColorChanged: (Color color) {
                    tempColor = color;
                  },
                  colorPickerWidth: 260,
                  pickerAreaHeightPercent: 0.65,
                  enableAlpha: false,
                  displayThumbColor: true,
                  paletteType: PaletteType.hsvWithHue,
                  labelTypes: const [], // Hides all RGB / Hex numbers at the bottom!
                  pickerAreaBorderRadius: BorderRadius.circular(16),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '취소',
                style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontSize: 16),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check, size: 20),
              label: const Text('이 색상 적용', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD81B60),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
