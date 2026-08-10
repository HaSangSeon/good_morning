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
    'assets/images/bg5.png', // Bamboo & Lotus
    'assets/images/bg6.png', // Moonlight night
  ];

  // Presets categorized for seniors
  final Map<String, List<String>> _presetCategories = {
    '🌅 아침 인사': [
      "좋은 아침입니다! 오늘도 희망차고 활기찬 하루 되세요 ☀️",
      "오늘 하루도 감사와 기쁨이 넘치시길 기도합니다 🌸",
      "상쾌한 아침! 웃음꽃 피는 행복한 하루 보내세요 😊",
      "복되고 좋은 아침, 언제나 당신을 응원합니다! 🙏",
      "오늘도 안녕한 하루, 따뜻한 마음을 전합니다 💞",
    ],
    '💖 건강 & 행복': [
      "첫째도 건강! 둘째도 건강! 오늘 하루도 무병장수하세요 💪",
      "마음은 청춘! 기분 좋은 일만 가득한 날 되세요 🌿",
      "소중한 사람들과 맛있는 음식 드시고 행복하세요 🍚🌸",
      "몸도 마음도 평안하고 따뜻한 하루 보내세요 🍵",
      "당신의 미소가 온 세상을 환하게 만듭니다 ✨",
    ],
    '🍀 응원 & 격려': [
      "당신이 있어 참 좋습니다! 오늘도 힘내세요 👍",
      "꿈꾸는 모든 일들이 이루어지는 축복의 하루 되세요 ✨",
      "오늘 하루도 수고 많으셨습니다. 당신은 최고입니다 ⭐",
      "늘 변함없이 곁에 계셔주셔서 감사합니다 ❤️",
      "오늘도 당신의 앞날에 꽃길만 가득하길 🌸🌼",
    ],
    '📜 오늘의 명언': [
      "가장 보람찬 날은 웃음으로 가득 찬 날이다.",
      "행복은 멀리 있지 않고 내 마음속에 있습니다.",
      "오늘이라는 선물에 감사하며 기쁘게 살아가자.",
      "웃으며 사는 인생이 가장 성공한 인생입니다.",
      "사랑하며 사는 삶에 슬픔이란 없습니다.",
    ],
  };

  String _selectedCategory = '🌅 아침 인사';
  int _bgIndex = 0;
  double _fontSize = 32.0;
  Color _textColor = const Color(0xFFFFD700); // Golden Yellow
  bool _showFrame = true;
  final String _selectedFontFamily = 'Jua';

  final List<Color> _colorPalette = [
    const Color(0xFFFFD700), // Gold
    Colors.white,            // White
    const Color(0xFFFFFF00), // Bright Yellow
    const Color(0xFFFF4081), // Pink Rose
    const Color(0xFF00E676), // Bright Green
    const Color(0xFFFF1744), // Bright Red
  ];

  @override
  void initState() {
    super.initState();
    if (widget.sharedTextNotifier != null && widget.sharedTextNotifier!.value.isNotEmpty) {
      _textController.text = widget.sharedTextNotifier!.value;
    } else {
      _textController.text = _presetCategories['🌅 아침 인사']![0];
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
    final list = _presetCategories[_selectedCategory]!;
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
                              _textController.text = _presetCategories[category]![0];
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
                  itemCount: _presetCategories[_selectedCategory]!.length,
                  itemBuilder: (context, index) {
                    final text = _presetCategories[_selectedCategory]![index];
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
                        border: _showFrame
                            ? Border.all(color: const Color(0xFFFFD700), width: 5)
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
                      // Size & Color Controls
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
                          // Frame Toggle
                          TextButton.icon(
                            icon: Icon(
                              _showFrame ? Icons.check_box : Icons.check_box_outline_blank,
                              color: isDark ? const Color(0xFFFFD700) : Colors.amber.shade900,
                            ),
                            label: Text(
                              '금빛 테두리',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            onPressed: () {
                              setState(() => _showFrame = !_showFrame);
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 12),
                      // Text Colors
                      Row(
                        children: [
                          const Text('글자 색상: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _colorPalette.map((color) {
                                  final isSelected = _textColor == color;
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _textColor = color);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? Colors.black : Colors.grey.shade400,
                                          width: isSelected ? 3 : 1,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(color: Colors.black12, blurRadius: 2),
                                        ],
                                      ),
                                      child: isSelected
                                          ? Icon(Icons.check, size: 18, color: color == Colors.white ? Colors.black : Colors.white)
                                          : null,
                                    ),
                                  );
                                }).toList(),
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
}

extension ColorsLight on Colors {
  static Color get purpleLight => const Color(0xFFCE93D8);
}
