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
  final double cardWidth;

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
    required this.cardWidth,
  });

  @override
  State<TextEditorBottomSheet> createState() => _TextEditorBottomSheetState();
}

class _TextEditorBottomSheetState extends State<TextEditorBottomSheet> {
  late int effectiveStep;
  late Color currentTextColor;
  final FocusNode editFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    currentTextColor = widget.selectedTextColor;
    if (widget.fontScaleStep == 0) {
      effectiveStep = widget.calculateAutoFontStep(widget.textController.text);
    } else {
      effectiveStep = widget.fontScaleStep;
    }
    editFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    editFocusNode.removeListener(_onFocusChange);
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

    final screenHeight = MediaQuery.of(context).size.height;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final previewCardHeight = isKeyboardVisible
        ? 125.0
        : (screenHeight * 0.28).clamp(205.0, 260.0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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

              // ★ 상단 고정 카드 미리보기 영역 (더 크고 시원하게 표시)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    height: previewCardHeight,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: widget.cardWidth,
                          height: widget.cardWidth,
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
                              ).copyWith(color: currentTextColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ★ 하단 조작 영역 (텍스트 입력창, 글자 색상, 안부 이모티콘, 글자 크기 스크롤)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. 텍스트 입력창 카드
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x060F172A),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 3.5,
                                        height: 15,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4F46E5),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '문구 내용 작성',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${widget.textController.text.length} / 150자',
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: editFocusNode.hasFocus
                                        ? const Color(0xFF6366F1)
                                        : const Color(0xFFE2E8F0),
                                    width: editFocusNode.hasFocus ? 1.6 : 1.2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: TextField(
                                  focusNode: editFocusNode,
                                  controller: widget.textController,
                                  maxLength: 150,
                                  maxLines: 4,
                                  minLines: 2,
                                  keyboardType: TextInputType.multiline,
                                  autofocus: false,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                    height: 1.45,
                                  ),
                                  onChanged: (_) {
                                    if (widget.fontScaleStep == 0) {
                                      effectiveStep = widget.calculateAutoFontStep(widget.textController.text);
                                    }
                                    _triggerUpdate();
                                  },
                                  decoration: const InputDecoration(
                                    hintText: '여기에 전하고 싶은 따뜻한 마음을 적어주세요.',
                                    hintStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    border: InputBorder.none,
                                    counterText: '',
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. 글자 색상 선택 카드
                        Container(
                          margin: const EdgeInsets.only(top: 14),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x060F172A),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 3.5,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4F46E5),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '글자 색상',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // 좌우 끝이 부드럽게 희미해지는 그라데이션 ShaderMask
                              ShaderMask(
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
                                    stops: [0.0, 0.08, 0.92, 1.0],
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.dstIn,
                                child: SizedBox(
                                  height: 52,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: AppConstants.textColors.length,
                                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final color = AppConstants.textColors[index];
                                      final isSelected = currentTextColor.toARGB32() == color.toARGB32();
                                      return GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            currentTextColor = color;
                                          });
                                          widget.onTextColorChanged(color);
                                          _triggerUpdate();
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF4F46E5)
                                                  : (color == Colors.white ? const Color(0xFFCBD5E1) : Colors.black12),
                                              width: isSelected ? 3.5 : 1.2,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                                                      blurRadius: 8,
                                                      spreadRadius: 1,
                                                    )
                                                  ]
                                                : const [
                                                    BoxShadow(
                                                      color: Color(0x0D000000),
                                                      blurRadius: 4,
                                                      offset: Offset(0, 1.5),
                                                    ),
                                                  ],
                                          ),
                                          child: isSelected
                                              ? Icon(
                                                  Icons.check_rounded,
                                                  color: color == Colors.white || color == const Color(0xFFFFE066)
                                                      ? Colors.black87
                                                      : Colors.white,
                                                  size: 22,
                                                )
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 3. 자주 쓰는 안부 이모티콘 카드
                        Container(
                          margin: const EdgeInsets.only(top: 14),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x060F172A),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 3.5,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4F46E5),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '자주 쓰는 안부 이모티콘',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Text(
                                      '누르면 바로 추가',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // 좌우 끝이 부드럽게 희미해지는 그라데이션 ShaderMask
                              ShaderMask(
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
                                    stops: [0.0, 0.08, 0.92, 1.0],
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.dstIn,
                                child: SizedBox(
                                  height: 50,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: AppConstants.quickEmojis.length,
                                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final emoji = AppConstants.quickEmojis[index];
                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(14),
                                          splashColor: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            final text = widget.textController.text;
                                            // 150자 초과 방어
                                            if (text.length + emoji.length > 150) {
                                              return;
                                            }
                                            final selection = widget.textController.selection;
                                            if (selection.isValid && selection.start >= 0) {
                                              final start = selection.start.clamp(0, text.length);
                                              final end = selection.end.clamp(0, text.length);
                                              final newText = text.replaceRange(start, end, emoji);
                                              widget.textController.value = TextEditingValue(
                                                text: newText,
                                                selection: TextSelection.collapsed(offset: start + emoji.length),
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
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0x06000000),
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
                              ),
                            ],
                          ),
                        ),

                        // 4. 글자 크기 조절 카드
                        Container(
                          margin: const EdgeInsets.only(top: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x060F172A),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 3.5,
                                        height: 15,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4F46E5),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '글자 크기 조절',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: widget.fontScaleStep == 0
                                          ? null
                                          : () {
                                              FocusScope.of(context).unfocus();
                                              HapticFeedback.lightImpact();
                                              widget.onFontScaleStepChanged(0);
                                              effectiveStep = widget.calculateAutoFontStep(widget.textController.text);
                                              _triggerUpdate();
                                            },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          gradient: widget.fontScaleStep == 0
                                              ? const LinearGradient(
                                                  colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                                                )
                                              : null,
                                          color: widget.fontScaleStep == 0 ? null : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: widget.fontScaleStep == 0
                                                ? const Color(0xFF818CF8)
                                                : const Color(0xFFE2E8F0),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.auto_awesome_rounded,
                                              size: 14,
                                              color: widget.fontScaleStep == 0
                                                  ? const Color(0xFF4F46E5)
                                                  : const Color(0xFF94A3B8),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '자동 맞춤',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: widget.fontScaleStep == 0
                                                    ? const Color(0xFF4338CA)
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  // [-] 작게 버튼
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: effectiveStep > 1
                                            ? () {
                                                FocusScope.of(context).unfocus();
                                                HapticFeedback.lightImpact();
                                                effectiveStep--;
                                                widget.onFontScaleStepChanged(effectiveStep);
                                                _triggerUpdate();
                                              }
                                            : null,
                                        child: Opacity(
                                          opacity: effectiveStep > 1 ? 1.0 : 0.35,
                                          child: Container(
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0x06000000),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 1.5),
                                                ),
                                              ],
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.remove_rounded, color: Color(0xFF1E293B), size: 24),
                                                SizedBox(width: 4),
                                                Text(
                                                  '작게',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // N단계 알약 배지
                                  Container(
                                    width: 82,
                                    height: 52,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
                                    ),
                                    child: Text(
                                      '$effectiveStep단계',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF4338CA),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // [+] 크게 버튼
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: effectiveStep < 10
                                            ? () {
                                                FocusScope.of(context).unfocus();
                                                HapticFeedback.lightImpact();
                                                effectiveStep++;
                                                widget.onFontScaleStepChanged(effectiveStep);
                                                _triggerUpdate();
                                              }
                                            : null,
                                        child: Opacity(
                                          opacity: effectiveStep < 10 ? 1.0 : 0.35,
                                          child: Container(
                                            height: 52,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0x06000000),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 1.5),
                                                ),
                                              ],
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_rounded, color: Color(0xFF4338CA), size: 24),
                                                SizedBox(width: 4),
                                                Text(
                                                  '크게',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF4338CA),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 하단 '수정 완료' 고정 액션 버튼
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 14,
                  bottom: 16 + (isKeyboardVisible ? 0 : MediaQuery.of(context).padding.bottom),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              '수정 완료',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
