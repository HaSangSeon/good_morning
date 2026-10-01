import 'package:flutter/material.dart';
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

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ModalHeaderWidget(
            icon: Icons.image_rounded,
            gradientColors: [Color(0xFF10B981), Color(0xFF047857)],
            title: '사진 배경 고르기',
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton.icon(
              onPressed: widget.onCustomImageRequested,
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
          const SizedBox(height: 12),
          
          Stack(
            children: [
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
          const SizedBox(height: 12),
          const Divider(thickness: 1, height: 1, color: Color(0xFFEEEEEE)),
          
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
                            final isSelected = widget.currentBgIndex == globalIndex && widget.customImagePath == null;
                            return GestureDetector(
                              key: isSelected ? selectedBgKey : null,
                              onTap: () {
                                widget.onBgSelected(globalIndex);
                                widget.onSaveUserPreferences();
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
  }
}
