import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
  
  // Diverse Frame Styles
  int _selectedFrameIndex = 0;
  final List<Map<String, dynamic>> _frameStyles = const [
    {'name': '✨ 럭셔리 금빛', 'color': Color(0xFFFFD700), 'width': 5.0},
    {'name': '💎 엘레강스 은빛', 'color': Color(0xFFE0E0E0), 'width': 5.0},
    {'name': '💖 로맨틱 로즈골드', 'color': Color(0xFFB76E79), 'width': 5.0},
    {'name': '🌿 청정 에메랄드', 'color': Color(0xFF00E676), 'width': 5.0},
    {'name': '🍷 정열 루비레드', 'color': Color(0xFFFF1744), 'width': 5.0},
    {'name': '🔮 신비 보라빛', 'color': Color(0xFFE040FB), 'width': 5.0},
    {'name': '🍊 따스한 귤색', 'color': Color(0xFFFF9800), 'width': 5.0},
    {'name': '❌ 테두리 없음', 'color': null, 'width': 0.0},
  ];
  final String _selectedFontFamily = 'Jua';

  // 5 Main Fast Text Colors
  final List<Map<String, dynamic>> _defaultColors = const [
    {'name': '황금색', 'color': Color(0xFFFFD700)},
    {'name': '순백색', 'color': Colors.white},
    {'name': '장미 빨강', 'color': Color(0xFFFF1744)},
    {'name': '코랄 핑크', 'color': Color(0xFFFF4081)},
    {'name': '에메랄드', 'color': Color(0xFF00E676)},
  ];

  // All 16 Simple Senior Color Palette
  final List<Map<String, dynamic>> _allColors = const [
    {'name': '황금색', 'color': Color(0xFFFFD700)},
    {'name': '순백색', 'color': Colors.white},
    {'name': '햇살 노랑', 'color': Color(0xFFFFFF00)},
    {'name': '샴페인 골드', 'color': Color(0xFFFFE082)},
    {'name': '장미 빨강', 'color': Color(0xFFFF1744)},
    {'name': '코랄 핑크', 'color': Color(0xFFFF4081)},
    {'name': '정열 주황', 'color': Color(0xFFFF5722)},
    {'name': '은은한 살구', 'color': Color(0xFFFFB74D)},
    {'name': '싱싱 에메랄드', 'color': Color(0xFF00E676)},
    {'name': '연두 새싹', 'color': Color(0xFFAEEA00)},
    {'name': '청량 하늘', 'color': Color(0xFF00E5FF)},
    {'name': '딥 오션 블루', 'color': Color(0xFF2979FF)},
    {'name': '고급 보라', 'color': Color(0xFFE040FB)},
    {'name': '라벤더 퍼플', 'color': Color(0xFFB388FF)},
    {'name': '칠흑 검정', 'color': Color(0xFF111111)},
    {'name': '딥 브라운', 'color': Color(0xFF3E2723)},
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
              const SizedBox(height: 14),

              // 3. Canvas Preview (Screenshot Widget - Responsive AspectRatio)
              Screenshot(
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: _frameStyles[_selectedFrameIndex]['color'] != null
                            ? Border.all(
                                color: _frameStyles[_selectedFrameIndex]['color'],
                                width: _frameStyles[_selectedFrameIndex]['width'],
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
              const SizedBox(height: 14),

              // 4. Quick Toolbar: Size, Color, Frame, Random
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
                      // Frame Style Selector: 4 Main Chips + '🖼️ 테두리 모양 고르기' Button
                      Row(
                        children: [
                          const Text('테두리 장식: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...List.generate(4, (index) {
                                    final frame = _frameStyles[index];
                                    final isSelected = _selectedFrameIndex == index;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 3),
                                      child: ChoiceChip(
                                        label: Text(frame['name']),
                                        selected: isSelected,
                                        selectedColor: isDark ? Colors.amber.withAlpha(80) : const Color(0xFFFEE500),
                                        labelStyle: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected
                                              ? (isDark ? const Color(0xFFFFD700) : const Color(0xFF8B0000))
                                              : (isDark ? Colors.white70 : Colors.black87),
                                        ),
                                        onSelected: (selected) {
                                          if (selected) {
                                            HapticFeedback.selectionClick();
                                            setState(() => _selectedFrameIndex = index);
                                          }
                                        },
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  // Frame Picker Modal Button
                                  InkWell(
                                    onTap: () => _showSimpleFramePicker(context),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.amber.withAlpha(40) : Colors.amber.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: isDark ? const Color(0xFFFFD700) : Colors.amber.shade800),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.crop_square, size: 16, color: isDark ? const Color(0xFFFFD700) : Colors.amber.shade900),
                                          const SizedBox(width: 4),
                                          Text(
                                            '🖼️ 테두리 모양 고르기',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? const Color(0xFFFFD700) : Colors.amber.shade900,
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
                      // Text Colors: 5 Main Colors + '🎨 더 많은 색상 보기' Button
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
                                  // Simple Text Color Modal Picker Button
                                  InkWell(
                                    onTap: () => _showSimpleColorPicker(context),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.pink.withAlpha(50) : Colors.pink.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: isDark ? Colors.pinkAccent : const Color(0xFFD81B60)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.palette, size: 16, color: isDark ? Colors.pinkAccent : const Color(0xFFD81B60)),
                                          const SizedBox(width: 4),
                                          Text(
                                            '🎨 더 많은 색상 보기',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.pinkAccent : const Color(0xFFD81B60),
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

              // 5. Custom Text Field
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

              // 6. Change Buttons
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

              // 7. Main Action Button: Share / Save
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
    );
  }

  // 1. Simple Senior-friendly Text Color Bottom Sheet
  void _showSimpleColorPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.palette, color: Color(0xFFD81B60), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '마음에 드는 글자 색상 선택',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _allColors.length,
                  itemBuilder: (context, index) {
                    final item = _allColors[index];
                    final Color color = item['color'];
                    final String name = item['name'];
                    final isSelected = _textColor == color;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _textColor = color);
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? (isDark ? Colors.amber : Colors.black) : Colors.grey.shade300,
                                width: isSelected ? 4 : 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 24,
                                    color: (color == Colors.white || color == const Color(0xFFFFFF00) || color == const Color(0xFFFFE082))
                                        ? Colors.black
                                        : Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? (isDark ? const Color(0xFFFFD700) : const Color(0xFFD81B60))
                                  : (isDark ? Colors.grey.shade300 : Colors.black87),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // 2. Simple Senior-friendly Frame / Border Style Bottom Sheet
  void _showSimpleFramePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.crop_square, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '액자 테두리 모양 선택',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _frameStyles.length,
                  itemBuilder: (context, index) {
                    final frame = _frameStyles[index];
                    final String name = frame['name'];
                    final Color? color = frame['color'];
                    final isSelected = _selectedFrameIndex == index;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedFrameIndex = index);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? Colors.amber.withAlpha(40) : Colors.amber.shade50)
                              : (isDark ? const Color(0xFF2B2B3D) : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? const Color(0xFFFFD700) : Colors.amber.shade900)
                                : (color ?? Colors.grey.shade400),
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: color ?? Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color != null ? Colors.white : Colors.grey.shade500,
                                  width: color != null ? 1.5 : 1,
                                ),
                              ),
                              child: color == null
                                  ? const Icon(Icons.close, size: 14, color: Colors.red)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? (isDark ? const Color(0xFFFFD700) : Colors.amber.shade900)
                                      : (isDark ? Colors.white : Colors.black87),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
