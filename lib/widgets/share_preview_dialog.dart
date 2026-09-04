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
  final VoidCallback? onSaveCard;

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
    VoidCallback? onSaveCard,
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

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? '오후' : '오전';
    final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$period $formattedHour:$minute';
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
                            // 💬 2. 텍스트 전송 (좋은글·명언 등 이미지가 없는 경우 카카오 노란 말풍선)
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

                                // 노란 말풍선 본체
                                Flexible(
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 270),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE500), // 카카오 노란색
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(4),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(25),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 타이틀
                                        Row(
                                          children: [
                                            Text(
                                              widget.emoji,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                widget.title,
                                                style: const TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF191919),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 6),
                                        Container(
                                          height: 1,
                                          color: Colors.black.withAlpha(25),
                                        ),
                                        const SizedBox(height: 6),

                                        // 본문 내용
                                        Text(
                                          widget.content,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            height: 1.45,
                                            color: Color(0xFF2B2B2B),
                                          ),
                                        ),

                                        // 작가/출처 (있는 경우)
                                        if (widget.author != null && widget.author!.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '- ${widget.author} -',
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontStyle: FontStyle.italic,
                                                color: Color(0xFF555555),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],

                                        // 하단 앱 링크 배지
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withAlpha(160),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '🌸 마음카드 무료 앱',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF424242),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                  // 메인 전송 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _executeShare,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE500),
                        foregroundColor: const Color(0xFF191919),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                            )
                          : const Icon(Icons.share_rounded, size: 20, color: Colors.black87),
                      label: Text(
                        _isSending ? '카카오톡 전송 준비 중...' : '📲 카카오톡으로 바로 전송',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  // 보관하기 버튼 (마음카드 탭 전용)
                  if (widget.onSaveCard != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          widget.onSaveCard!();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFFFFB300) : const Color(0xFFE65100),
                          side: BorderSide(
                            color: isDark ? const Color(0xFFFFB300) : const Color(0xFFE65100),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                        label: const Text(
                          '💾 내 카드함에 보관하기',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // 카드로 직접 꾸며서 보내기 버튼 (명언/건강 탭 전용)
                  if (widget.onCustomizeCard != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onCustomizeCard!();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFFFFB300) : const Color(0xFFE65100),
                          side: BorderSide(
                            color: isDark ? const Color(0xFFFFB300) : const Color(0xFFE65100),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.palette_outlined, size: 18),
                        label: const Text(
                          '🎨 배경 사진 골라 예쁜 카드로 꾸미기',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
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
