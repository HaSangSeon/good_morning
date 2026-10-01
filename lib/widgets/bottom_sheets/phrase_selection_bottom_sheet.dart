import 'package:flutter/material.dart';
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
    '🌅 아침 인사': '🌅 아침 인사 & 덕담',
    '🌙 저녁 & 안부': '🌙 저녁 & 안부 인사',
    '💖 건강 & 무병장수': '💖 건강 & 무병장수',
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
          listItems.add(
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(entry.key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
            ),
          );
        } else {
          listItems.add(const SizedBox(height: 16));
        }

        for (final text in widget.presetCategories[actualKey]!) {
          final isSelected = text.trim() == widget.currentPhrase;
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
          const ModalHeaderWidget(
            icon: Icons.chat_bubble_rounded,
            gradientColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            title: '추천 문구 고르기',
          ),
          SizedBox(
            height: 60,
            child: Stack(
              children: [
                SingleChildScrollView(
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
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, height: 1, color: Color(0xFFF0F0F0)),
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
  }
}
