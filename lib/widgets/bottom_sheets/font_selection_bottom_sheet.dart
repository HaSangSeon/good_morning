import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ModalHeaderWidget(
              icon: Icons.edit_note_rounded,
              gradientColors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              title: '예쁜 글씨체 고르기',
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18, 14, 18, 24 + MediaQuery.of(context).padding.bottom),
                itemCount: AppConstants.seniorFonts.length,
                itemBuilder: (context, index) {
                  final fontConfig = AppConstants.seniorFonts[index];
                  final isSelected = widget.selectedFontFamily == fontConfig['id'];
                  final fontStyle = fontConfig['font'] as TextStyle;

                  return Padding(
                    key: isSelected ? selectedFontKey : null,
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color(0xFF7C3AED).withValues(alpha: 0.18)
                                : const Color(0x080F172A),
                            blurRadius: isSelected ? 10 : 6,
                            offset: const Offset(0, 2.5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          splashColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                          highlightColor: const Color(0xFF7C3AED).withValues(alpha: 0.05),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onFontSelected(fontConfig['id']);
                            widget.onSaveUserPreferences();
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                // 폰트 미리보기 미니 배지 ('가')
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF7C3AED).withValues(alpha: 0.12)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF7C3AED).withValues(alpha: 0.25)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '가',
                                    style: fontStyle.copyWith(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? const Color(0xFF7C3AED)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // 글씨체 명칭
                                Expanded(
                                  child: Text(
                                    fontConfig['name'],
                                    style: fontStyle.copyWith(
                                      fontSize: 21,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF5B21B6)
                                          : const Color(0xFF1E293B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // 상태/액션 뱃지
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7C3AED),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
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
                                          '현재 글씨체',
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
                                            color: Color(0xFF7C3AED),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        Icon(Icons.chevron_right_rounded, color: Color(0xFF7C3AED), size: 16),
                                      ],
                                    ),
                                  ),
                              ],
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
    );
  }
}
