import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../modal_header.dart';

class BackgroundSelectionBottomSheet extends StatefulWidget {
  final List<Map<String, String>> bgList;
  final int currentBgIndex;
  final String? customImagePath;
  final ValueChanged<int> onBgSelected;
  final VoidCallback onCustomImageRequested;
  final VoidCallback onSaveUserPreferences;

  const BackgroundSelectionBottomSheet({
    super.key,
    required this.bgList,
    required this.currentBgIndex,
    required this.customImagePath,
    required this.onBgSelected,
    required this.onCustomImageRequested,
    required this.onSaveUserPreferences,
  });

  @override
  State<BackgroundSelectionBottomSheet> createState() => _BackgroundSelectionBottomSheetState();
}

class _BackgroundSelectionBottomSheetState extends State<BackgroundSelectionBottomSheet> {
  late String selectedCategory;
  late List<String> categories;
  late Map<String, GlobalKey> bgChipKeys;
  final GlobalKey selectedBgKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final currentBg = (widget.customImagePath == null && widget.currentBgIndex >= 0 && widget.currentBgIndex < widget.bgList.length)
        ? widget.bgList[widget.currentBgIndex]
        : null;
    final currentBgCategory = currentBg != null ? (currentBg['category'] ?? '전체') : '전체';
    selectedCategory = currentBgCategory;

    categories = ['전체'];
    for (var bg in widget.bgList) {
      final cat = bg['category'] ?? '기타';
      if (!categories.contains(cat)) {
        categories.add(cat);
      }
    }

    bgChipKeys = { for (var cat in categories) cat: GlobalKey() };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chipContext = bgChipKeys[selectedCategory]?.currentContext;
      if (chipContext != null) {
        Scrollable.ensureVisible(
          chipContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
      if (selectedBgKey.currentContext != null) {
        Scrollable.ensureVisible(
          selectedBgKey.currentContext!,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.25,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCustomSelected = widget.customImagePath != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModalHeaderWidget(
              icon: Icons.image_rounded,
              gradientColors: [Color(0xFF10B981), Color(0xFF047857)],
              title: '사진 배경 고르기',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onCustomImageRequested();
                  },
                  child: Container(
                    height: 58,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isCustomSelected ? const Color(0xFFECFDF5) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isCustomSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                        width: isCustomSelected ? 2 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCustomSelected
                              ? const Color(0xFF10B981).withValues(alpha: 0.2)
                              : const Color(0x080F172A),
                          blurRadius: isCustomSelected ? 10 : 6,
                          offset: const Offset(0, 2.5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isCustomSelected ? const Color(0xFF10B981) : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCustomSelected ? Icons.check_rounded : Icons.add_photo_alternate_rounded,
                            size: 22,
                            color: isCustomSelected ? Colors.white : const Color(0xFF047857),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            isCustomSelected ? '내 앨범 사진 적용 중' : '내 앨범에서 사진 고르기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isCustomSelected ? const Color(0xFF065F46) : const Color(0xFF1E293B),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        if (isCustomSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '현재 적용 중',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '불러오기',
                                  style: TextStyle(
                                    color: Color(0xFF047857),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.chevron_right_rounded, color: Color(0xFF047857), size: 16),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 58,
              padding: const EdgeInsets.only(top: 4, bottom: 12),
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
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return Padding(
                        key: bgChipKeys[cat],
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
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
                              constraints: const BoxConstraints(minHeight: 38),
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF10B981), Color(0xFF047857)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF047857) : const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                        : const Color(0x06000000),
                                    blurRadius: isSelected ? 8 : 4,
                                    offset: Offset(0, isSelected ? 2 : 1),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 15,
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
              child: Builder(
                builder: (context) {
                  final Map<String, List<Map<String, dynamic>>> groupedBgs = {};
                  for (int i = 0; i < widget.bgList.length; i++) {
                    final bg = widget.bgList[i];
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
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: 24 + MediaQuery.of(context).padding.bottom,
                    ),
                    itemCount: groupedBgs.keys.length,
                    itemBuilder: (context, sectionIndex) {
                      final category = groupedBgs.keys.elementAt(sectionIndex);
                      final items = groupedBgs[category]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 18,
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
                                    '${items.length}장',
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
                          GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final globalIndex = items[index]['index'] as int;
                              final item = items[index]['bg'] as Map<String, String>;
                              final isSelected = widget.currentBgIndex == globalIndex && widget.customImagePath == null;
                              return GestureDetector(
                                key: isSelected ? selectedBgKey : null,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  widget.onBgSelected(globalIndex);
                                  widget.onSaveUserPreferences();
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                                      width: isSelected ? 3 : 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                            : const Color(0x0A000000),
                                        blurRadius: isSelected ? 10 : 5,
                                        offset: const Offset(0, 2.5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.asset(
                                          item['path']!,
                                          fit: BoxFit.cover,
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFF10B981), Color(0xFF047857)],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: const [
                                                  BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2)),
                                                ],
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.check_rounded, color: Colors.white, size: 15),
                                                  SizedBox(width: 3),
                                                  Text(
                                                    '현재 배경',
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
      ),
    );
  }
}

