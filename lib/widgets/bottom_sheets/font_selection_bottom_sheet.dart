import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../modal_header.dart';

class FontSelectionBottomSheet extends StatefulWidget {
  final String selectedFontFamily;
  final ValueChanged<String> onFontSelected;
  final VoidCallback onSaveUserPreferences;

  const FontSelectionBottomSheet({
    super.key,
    required this.selectedFontFamily,
    required this.onFontSelected,
    required this.onSaveUserPreferences,
  });

  @override
  State<FontSelectionBottomSheet> createState() => _FontSelectionBottomSheetState();
}

class _FontSelectionBottomSheetState extends State<FontSelectionBottomSheet> {
  final GlobalKey selectedFontKey = GlobalKey();

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ModalHeaderWidget(
            icon: Icons.edit_note_rounded,
            gradientColors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            title: '예쁜 글씨체 고르기',
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + MediaQuery.of(context).padding.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppConstants.seniorFonts.map((fontConfig) {
                  final isSelected = widget.selectedFontFamily == fontConfig['id'];
                  return Column(
                    children: [
                      Padding(
                        key: isSelected ? selectedFontKey : null,
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            widget.onFontSelected(fontConfig['id']);
                            widget.onSaveUserPreferences();
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
  }
}
