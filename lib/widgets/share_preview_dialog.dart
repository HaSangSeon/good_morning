import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ad_service.dart';
import '../services/kakao_share_helper.dart';

enum SharePreviewType {
  mindCard,
  wisdom,
  health,
}

class SharePreviewDialog extends StatefulWidget {
  final SharePreviewType type;
  final String title;
  final String content;
  final String? author;
  final String emoji;
  final String fullShareText;
  final Uint8List? imageBytes;
  final String? imageFilePath;
  final VoidCallback? onCustomizeCard;
  final Future<bool> Function()? onSaveCard;

  const SharePreviewDialog({
    super.key,
    required this.type,
    required this.title,
    required this.content,
    this.author,
    this.emoji = '🌸',
    required this.fullShareText,
    this.imageBytes,
    this.imageFilePath,
    this.onCustomizeCard,
    this.onSaveCard,
  });

  /// 팝업 편리 호출 메서드
  static Future<void> show({
    required BuildContext context,
    required SharePreviewType type,
    required String title,
    required String content,
    String? author,
    String emoji = '🌸',
    required String fullShareText,
    Uint8List? imageBytes,
    String? imageFilePath,
    VoidCallback? onCustomizeCard,
    Future<bool> Function()? onSaveCard,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => SharePreviewDialog(
        type: type,
        title: title,
        content: content,
        author: author,
        emoji: emoji,
        fullShareText: fullShareText,
        imageBytes: imageBytes,
        imageFilePath: imageFilePath,
        onCustomizeCard: onCustomizeCard,
        onSaveCard: onSaveCard,
      ),
    );
  }

  @override
  State<SharePreviewDialog> createState() => _SharePreviewDialogState();
}

class _SharePreviewDialogState extends State<SharePreviewDialog> {
  bool _isSending = false;
  bool _isSavingCard = false;
  bool? _saveResult; // null: 미저장, true: 신규 보관, false: 이미 보관됨

  Future<void> _handleSaveCard() async {
    if (_isSavingCard || _saveResult != null) return;
    setState(() => _isSavingCard = true);
    HapticFeedback.mediumImpact();

    bool? isNew;
    if (widget.onSaveCard != null) {
      isNew = await widget.onSaveCard!();
    }

    if (mounted) {
      setState(() {
        _isSavingCard = false;
        _saveResult = isNew ?? true;
      });
    }

    // 보관 완료 시각적 확인 후 팝업 자동 종료
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? '오후' : '오전';
    final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$period $formattedHour:$minute';
  }

  Widget _buildRealisticKakaoBubble() {
    final text = widget.fullShareText;
    final urlIndex = text.indexOf('https://');
    final String bodyText;
    final String urlText;
    if (urlIndex != -1) {
      bodyText = text.substring(0, urlIndex);
      urlText = text.substring(urlIndex).trim();
    } else {
      bodyText = text;
      urlText = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 1. 카카오톡 노란색 텍스트 말풍선 (실제 전송 텍스트와 100% 동일)
        Container(
          constraints: const BoxConstraints(maxWidth: 270),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE500), // 카카오톡 공식 옐로우
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(2),
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 3,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: bodyText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: Color(0xFF191919),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (urlText.isNotEmpty)
                  TextSpan(
                    text: urlText,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: Color(0xFF0055FB),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF0055FB),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 2. 카카오톡 링크 미리보기 박스 (URL이 있을 때 카카오톡이 아래에 띄우는 실제 박스 형태)
        if (urlText.isNotEmpty) ...[
          const SizedBox(height: 3),
          Container(
            constraints: const BoxConstraints(maxWidth: 270),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD6D6D6), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 3,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '미리보기가 없습니다.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '여기를 눌러 링크를 확인하세요.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF666666),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'play.google.com',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.north_east_rounded,
                    size: 15,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _executeShare() async {
    if (_isSending) return;
    setState(() => _isSending = true);
    HapticFeedback.mediumImpact();

    try {
      if (widget.imageFilePath != null && widget.imageFilePath!.isNotEmpty) {
        await KakaoShareHelper.share(
          filePath: widget.imageFilePath,
          text: widget.fullShareText,
          subject: widget.title,
        );
      } else {
        await KakaoShareHelper.share(
          text: widget.fullShareText,
          subject: widget.title,
        );
      }

      // 광고 연동
      AdService().showInterstitialAdOnShare();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('SharePreviewDialog share error: $e');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMindCard = widget.type == SharePreviewType.mindCard;
    final isHealth = widget.type == SharePreviewType.health;

    // 헤더 그라디언트 테마
    final LinearGradient headerGradient;
    final IconData headerIcon;
    final String headerTitle;
    final String headerSubtitle;

    if (isMindCard) {
      headerGradient = const LinearGradient(
        colors: [Color(0xFFE64A19), Color(0xFFF57C00), Color(0xFFFFB300)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      headerIcon = Icons.favorite_rounded;
      headerTitle = '마음카드 전송 미리보기';
      headerSubtitle = '받는 분의 카카오톡에 도착할 고화질 아침카드입니다 🌸';
    } else if (isHealth) {
      headerGradient = const LinearGradient(
        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      headerIcon = Icons.health_and_safety_rounded;
      headerTitle = '건강 꿀팁 전송 미리보기';
      headerSubtitle = '받는 분의 카카오톡에 도착할 건강 카드입니다 🌿';
    } else {
      headerGradient = const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFF673AB7), Color(0xFF3F51B5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      headerIcon = Icons.auto_awesome_rounded;
      headerTitle = '좋은글·명언 전송 미리보기';
      headerSubtitle = '받는 분의 카카오톡에 도착할 감동 메시지입니다 💌';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      elevation: 16,
      backgroundColor: isDark ? const Color(0xFF1E2230) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 프리미엄 헤더
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
              decoration: BoxDecoration(gradient: headerGradient),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(headerIcon, color: const Color(0xFFFFD700), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          headerTitle,
                          style: GoogleFonts.jua(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          headerSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha(220),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // 2. 카카오톡 화면 실시간 미리보기 프레임
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  children: [
                    // 카카오톡 채팅방 캔버스 (하늘색 배경)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBACEE0), // 카카오톡 공식 채팅창 배경색
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? Colors.white12 : const Color(0xFFA0B4C8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 상단 날짜 뱃지
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF708FA6).withAlpha(180),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              '오늘의 따뜻한 배달 💌',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // 카카오톡 메시지 영역 (이미지 카드는 사진 전송 버블, 텍스트는 노란 말풍선)
                          if (widget.imageBytes != null)
                            // 📸 1. 이미지 카드 전송 (카카오톡 실제 사진 전송 버블 스타일: 불필요한 텍스트 중복 제거)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // 전송 시간 및 1 안읽음 뱃지
                                Padding(
                                  padding: const EdgeInsets.only(right: 6, bottom: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        '1',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFEE500),
                                        ),
                                      ),
                                      Text(
                                        _formatCurrentTime(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF556677),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 카카오톡 사진 버블 (카드 본체 1:1 완본)
                                Flexible(
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 260),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(4),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(4),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                      child: Image.memory(
                                        widget.imageBytes!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            // 💬 2. 텍스트 전송 (명언, 건강 등 실제 카카오톡 수신 화면과 100% 동일한 뷰)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // 시간 및 읽음 뱃지
                                Padding(
                                  padding: const EdgeInsets.only(right: 6, bottom: 2),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        '1',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFEE500),
                                        ),
                                      ),
                                      Text(
                                        _formatCurrentTime(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF556677),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 실제 카카오톡 말풍선 + 링크 박스 영역
                                Flexible(
                                  child: _buildRealisticKakaoBubble(),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 안내 텍스트
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '보내기를 누르면 카카오톡 친구/채팅방 선택창으로 직행합니다.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 3. 하단 액션 버튼부
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B1E2B) : const Color(0xFFFAFAFA),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
              ),
              child: Column(
                children: [
                  // 메인 카카오톡 전송 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _executeShare,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE500), // 카카오 공식 옐로우
                        foregroundColor: const Color(0xFF191600),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Color(0xFF191600),
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF191600).withAlpha(18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.chat_bubble_rounded,
                                      size: 16,
                                      color: Color(0xFF191600),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '카카오톡으로 바로 전송',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF191600),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),

                  // 내 카드함에 보관하기 버튼 (마음카드 탭 전용 - 은은하고 고급스러운 소프트 필 스타일)
                  if (widget.onSaveCard != null) ...[
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: double.infinity,
                        minHeight: 46,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: (_isSavingCard || _saveResult != null) ? null : _handleSaveCard,
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _saveResult == true
                                  ? (isDark ? const Color(0xFF1B3B22) : const Color(0xFFE8F5E9))
                                  : _saveResult == false
                                      ? (isDark ? const Color(0xFF382914) : const Color(0xFFFFF3E0))
                                      : (isDark ? const Color(0xFF2C271E) : const Color(0xFFFFF9E6)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _saveResult == true
                                    ? (isDark ? const Color(0xFF2E7D32) : const Color(0xFF81C784))
                                    : _saveResult == false
                                        ? (isDark ? const Color(0xFF8D4F00) : const Color(0xFFFFB74D))
                                        : (isDark ? const Color(0xFF5D4A22) : const Color(0xFFFFE082)),
                                width: 1,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isSavingCard)
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: isDark ? const Color(0xFFFFD54F) : const Color(0xFFB76E00),
                                      ),
                                    )
                                  else
                                    Icon(
                                      _saveResult == true
                                          ? Icons.check_circle_rounded
                                          : _saveResult == false
                                              ? Icons.bookmark_added_rounded
                                              : Icons.bookmark_add_rounded,
                                      size: 19,
                                      color: _saveResult == true
                                          ? const Color(0xFF2E7D32)
                                          : _saveResult == false
                                              ? const Color(0xFFE65100)
                                              : (isDark ? const Color(0xFFFFD54F) : const Color(0xFFB76E00)),
                                    ),
                                  const SizedBox(width: 7),
                                  Text(
                                    _saveResult == true
                                        ? '✅ 내 카드함에 보관되었습니다!'
                                        : _saveResult == false
                                            ? '📌 이미 보관함에 담겨있는 카드입니다'
                                            : '내 카드함에 보관하기',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: _saveResult == true
                                          ? const Color(0xFF1B5E20)
                                          : _saveResult == false
                                              ? (isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100))
                                              : (isDark ? const Color(0xFFFFD54F) : const Color(0xFF8D4F00)),
                                      letterSpacing: -0.2,
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


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
