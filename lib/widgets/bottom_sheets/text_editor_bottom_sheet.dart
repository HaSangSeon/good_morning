import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants.dart';
import '../modal_header.dart';
import '../maum_card.dart';

class TextEditorBottomSheet extends StatefulWidget {
  final TextEditingController textController;
  final int fontScaleStep;
  final Color selectedTextColor;
  final ImageProvider backgroundImage;
  final TextStyle Function({required double fontSize, required double height, required FontWeight fontWeight}) getTextStyle;
  final int Function(String) calculateAutoFontStep;
  final ValueChanged<int> onFontScaleStepChanged;
  final ValueChanged<Color> onTextColorChanged;
  final VoidCallback onStateChanged;
  final VoidCallback onSaveUserPreferences;

  const TextEditorBottomSheet({
    super.key,
    required this.textController,
    required this.fontScaleStep,
    required this.selectedTextColor,
    required this.backgroundImage,
    required this.getTextStyle,
    required this.calculateAutoFontStep,
    required this.onFontScaleStepChanged,
    required this.onTextColorChanged,
    required this.onStateChanged,
    required this.onSaveUserPreferences,
  });

  @override
  State<TextEditorBottomSheet> createState() => _TextEditorBottomSheetState();
}

class _TextEditorBottomSheetState extends State<TextEditorBottomSheet> {
  late int effectiveStep;
  final FocusNode editFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.fontScaleStep == 0) {
      effectiveStep = widget.calculateAutoFontStep(widget.textController.text);
    } else {
      effectiveStep = widget.fontScaleStep;
    }
  }

  @override
  void dispose() {
    editFocusNode.dispose();
    super.dispose();
  }

  void _triggerUpdate() {
    setState(() {});
    widget.onStateChanged();
    widget.onSaveUserPreferences();
  }

  @override
  Widget build(BuildContext context) {
    final fontSizes = [20.0, 24.0, 28.0, 32.0, 36.0, 40.0, 44.0, 48.0, 52.0, 56.0];
    final lineHeights = [1.5, 1.48, 1.45, 1.42, 1.38, 1.35, 1.32, 1.28, 1.25, 1.2];
    int idx = (effectiveStep - 1).clamp(0, 9);
    double dynamicFontSize = fontSizes[idx];
    double dynamicHeight = lineHeights[idx];

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            const ModalHeaderWidget(
              icon: Icons.edit_rounded,
              gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              title: '문구 직접 수정하기',
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 16,
                    bottom: 24 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        // 카드 영역
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                editFocusNode.requestFocus();
                              });
                            },
                            child: MaumCard(
                              text: widget.textController.text,
                              backgroundImage: widget.backgroundImage,
                              textStyle: widget.getTextStyle(
                                fontSize: dynamicFontSize,
                                height: dynamicHeight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // 새 텍스트 입력창
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4), width: 1.5),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: TextField(
                                  focusNode: editFocusNode,
                                  controller: widget.textController,
                                  maxLength: 150,
                                  maxLines: 4,
                                  minLines: 1,
                                  keyboardType: TextInputType.multiline,
                                  autofocus: true,
                                  style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
                                  onChanged: (_) {
                                    if (widget.fontScaleStep == 0) {
                                      effectiveStep = widget.calculateAutoFontStep(widget.textController.text);
                                    }
                                    _triggerUpdate();
                                  },
                                  decoration: InputDecoration(
                                    hintText: '여기에 따뜻한 마음을 적어주세요.',
                                    hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                                    border: InputBorder.none,
                                    counterText: '',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6, right: 4),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${widget.textController.text.length}/150',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 36, color: Colors.grey.shade200, thickness: 1.5),
                        // 글자 색상 선택 바
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 44,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: AppConstants.textColors.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final color = AppConstants.textColors[index];
                                  final isSelected = widget.selectedTextColor.toARGB32() == color.toARGB32();
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      widget.onTextColorChanged(color);
                                      _triggerUpdate();
                                    },
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF6366F1) : (color == Colors.white ? Colors.grey.shade300 : Colors.transparent),
                                          width: isSelected ? 3 : 1,
                                        ),
                                        boxShadow: isSelected ? [
                                          BoxShadow(
                                            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          )
                                        ] : null,
                                      ),
                                      child: isSelected
                                          ? Icon(Icons.check_rounded, color: color == Colors.white || color == const Color(0xFFFFE066) ? Colors.black87 : Colors.white, size: 22)
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 36, color: Colors.grey.shade200, thickness: 1.5),
                        // 자주 쓰는 안부 이모티콘 퀵 바
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 50,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: AppConstants.quickEmojis.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final emoji = AppConstants.quickEmojis[index];
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(15),
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        final text = widget.textController.text;
                                        final selection = widget.textController.selection;
                                        if (selection.isValid && selection.start >= 0) {
                                          final newText = text.replaceRange(selection.start, selection.end, emoji);
                                          widget.textController.value = TextEditingValue(
                                            text: newText,
                                            selection: TextSelection.collapsed(offset: selection.start + emoji.length),
                                          );
                                        } else {
                                          widget.textController.text = '$text$emoji';
                                          widget.textController.selection = TextSelection.collapsed(offset: widget.textController.text.length);
                                        }
                                        if (widget.fontScaleStep == 0) {
                                          effectiveStep = widget.calculateAutoFontStep(widget.textController.text);
                                        }
                                        _triggerUpdate();
                                      },
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x08000000),
                                              blurRadius: 4,
                                              offset: Offset(0, 1.5),
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          emoji,
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 36, color: Colors.grey.shade200, thickness: 1.5),
                        // 스텝형 글자 크기 조절기
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('글자 크기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: widget.fontScaleStep == 0 ? null : () {
                                    FocusScope.of(context).unfocus();
                                    HapticFeedback.lightImpact();
                                    widget.onFontScaleStepChanged(0);
                                    effectiveStep = widget.calculateAutoFontStep(widget.textController.text);
                                    _triggerUpdate();
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: widget.fontScaleStep == 0 ? const Color(0xFFE0E7FF) : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: widget.fontScaleStep == 0 ? const Color(0xFF818CF8) : const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 16,
                                      color: widget.fontScaleStep == 0 ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: effectiveStep > 1 ? () {
                                    FocusScope.of(context).unfocus();
                                    HapticFeedback.lightImpact();
                                    effectiveStep--;
                                    widget.onFontScaleStepChanged(effectiveStep);
                                    _triggerUpdate();
                                  } : null,
                                  child: Opacity(
                                    opacity: effectiveStep > 1 ? 1.0 : 0.35,
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F2F5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFEAEAEA)),
                                      ),
                                      child: const Center(child: Icon(Icons.remove_rounded, color: Color(0xFF2A2D34), size: 28)),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 64,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$effectiveStep단계',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: effectiveStep < 10 ? () {
                                    FocusScope.of(context).unfocus();
                                    HapticFeedback.lightImpact();
                                    effectiveStep++;
                                    widget.onFontScaleStepChanged(effectiveStep);
                                    _triggerUpdate();
                                  } : null,
                                  child: Opacity(
                                    opacity: effectiveStep < 10 ? 1.0 : 0.35,
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F2F5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFEAEAEA)),
                                      ),
                                      child: const Center(child: Icon(Icons.add_rounded, color: Color(0xFF2A2D34), size: 28)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, -4)),
                  ],
                ),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF334155),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('수정 완료', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
