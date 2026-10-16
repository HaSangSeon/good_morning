import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../keep_all_text.dart';
import '../modal_header.dart';

class PhraseSelectionBottomSheet extends StatefulWidget {
  final String currentPhrase;
  final Map<String, List<String>> presetCategories;
  final void Function(String text) onPhraseSelected;
  final VoidCallback onSaveUserPreferences;

  const PhraseSelectionBottomSheet({
    super.key,
    required this.currentPhrase,
    required this.presetCategories,
    required this.onPhraseSelected,
    required this.onSaveUserPreferences,
  });

  @override
  State<PhraseSelectionBottomSheet> createState() => _PhraseSelectionBottomSheetState();
}

class _PhraseSelectionBottomSheetState extends State<PhraseSelectionBottomSheet> {
  late String selectedCategory;
  final ScrollController listScrollController = ScrollController();
  final GlobalKey selectedPhraseKey = GlobalKey();
  late Map<String, GlobalKey> chipKeys;

  final Map<String, String> categoryMap = {
    '전체': '전체',
    '🍁 가을 인사': '🍁 가을 인사 & 안부',
    '❄️ 겨울 인사': '❄️ 겨울 인사 & 안부',
    '🌸 봄 인사': '🌸 봄 인사 & 안부',
    '🍉 여름 인사': '🍉 여름 인사 & 안부',
    '🌅 아침 인사': '🌅 아침 인사 & 덕담',
    '🌙 저녁 & 안부': '🌙 저녁 & 안부 인사',
    '💖 건강 & 무병장수': '💖 건강 & 무병장수',
    '🍀 응원 & 격려': '🍀 응원 & 격려',
    '👶 손주 & 자녀': '👶 손주 & 자녀 사랑',
    '🌺 들꽃 & 풍경': '🌺 들꽃 & 풍경 감성',
    '📜 명언 & 지혜': '📜 오늘의 명언 & 지혜',
    '🎉 축하 & 감사': '🎂 축하 & 감사',
    '💍 결혼 & 축하': '💍 결혼 & 축하',
    '🕊️ 조의 & 위로': '🕊️ 조의 & 위로',
    '🌕 명절 인사': '🌕 명절 (추석·설날)',
  };

  @override
  void initState() {
    super.initState();
    chipKeys = {for (var k in categoryMap.keys) k: GlobalKey()};

    String? matchedCategory;
    for (final entry in widget.presetCategories.entries) {
      if (entry.value.any((p) => p.trim() == widget.currentPhrase)) {
        matchedCategory = entry.key;
        break;
      }
    }

    selectedCategory = '전체';
    if (matchedCategory != null) {
      selectedCategory = matchedCategory;
    } else {
      final hour = DateTime.now().hour;
      if (hour >= 6 && hour < 12) {
        selectedCategory = '🌅 아침 인사 & 덕담';
      } else if (hour >= 18) {
        selectedCategory = '🌙 저녁 & 안부 인사';
      }
    }

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
  }

  @override
  void dispose() {
    listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listItems = [];
    for (final entry in categoryMap.entries) {
      if (entry.key == '전체') continue;
      final actualKey = entry.value;

      if (selectedCategory == '전체' || selectedCategory == actualKey) {
        if (selectedCategory == '전체') {
          final count = widget.presetCategories[actualKey]?.length ?? 0;
          listItems.add(
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 10, left: 2, right: 2),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count개',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          listItems.add(const SizedBox(height: 14));
        }

        for (final text in widget.presetCategories[actualKey]!) {
          final isSelected = text.trim() == widget.currentPhrase;
          listItems.add(
            Padding(
              key: isSelected ? selectedPhraseKey : null,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                    width: isSelected ? 2 : 1.2,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF2563EB).withValues(alpha: 0.15)
                          : const Color(0x080F172A),
                      blurRadius: isSelected ? 12 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    splashColor: const Color(0xFF2563EB).withValues(alpha: 0.08),
                    highlightColor: const Color(0xFF2563EB).withValues(alpha: 0.04),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (!mounted) return;
                        
                        widget.onPhraseSelected(text);
                        widget.onSaveUserPreferences();
                        
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
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF1E293B),
                                height: 1.5,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    '현재 문구',
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '선택',
                                    style: TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(Icons.chevron_right_rounded, color: Color(0xFF2563EB), size: 16),
                                ],
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
        }
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Column(
          children: [
            const ModalHeaderWidget(
              icon: Icons.chat_bubble_rounded,
              gradientColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              title: '추천 문구 고르기',
            ),
            Container(
              height: 56,
              color: const Color(0xFFFDFBF7),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.04, 0.96, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
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
                              HapticFeedback.lightImpact();
                              setState(() {
                                selectedCategory = actualKey;
                              });
                              if (listScrollController.hasClients) {
                                listScrollController.jumpTo(0);
                              }
                              final chipContext = chipKeys[label]?.currentContext;
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
                              constraints: const BoxConstraints(minHeight: 40),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? const Color(0xFF2563EB).withValues(alpha: 0.3)
                                        : const Color(0x06000000),
                                    blurRadius: isSelected ? 8 : 4,
                                    offset: Offset(0, isSelected ? 2.5 : 1),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF475569),
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
            ),
            const Divider(thickness: 1, height: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: ListView(
                controller: listScrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18).copyWith(
                  top: 8,
                  bottom: 24 + MediaQuery.of(context).padding.bottom,
                ),
                children: listItems,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
