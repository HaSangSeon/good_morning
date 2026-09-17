import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
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
  String? _floatingToastMessage;
  bool _isToastSuccess = true;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleSaveCard() async {
    if (_isSavingCard) return;
    setState(() => _isSavingCard = true);
    HapticFeedback.mediumImpact();

    bool? isNew;
    try {
      if (widget.onSaveCard != null) {
        isNew = await widget.onSaveCard!();
      }
    } catch (e) {
      debugPrint('SharePreviewDialog save error: $e');
      isNew = false;
    }

    _toastTimer?.cancel();
    if (mounted) {
      setState(() {
        _isSavingCard = false;
        _isToastSuccess = isNew ?? true;
        _floatingToastMessage = (isNew == false)
            ? '📌 이미 보관함에 담겨있는 카드입니다'
            : '💌 [내 카드함]에 소중히 보관되었습니다!';
      });

      _toastTimer = Timer(const Duration(milliseconds: 2200), () {
        if (mounted) {
          setState(() {
            _floatingToastMessage = null;
          });
        }
      });
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('카카오톡 공유 중 오류가 발생했습니다. 다시 시도해 주세요.', style: TextStyle(fontSize: 16)),
            backgroundColor: Color(0xFFE64A19),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _handleSaveGallery() async {
    if (_isSavingCard) return;
    if (widget.imageBytes == null && widget.imageFilePath == null) return;
    
    setState(() => _isSavingCard = true);
    HapticFeedback.mediumImpact();
    try {
      final bool hasAccess = await Gal.requestAccess(toAlbum: true);
      if (hasAccess) {
        if (widget.imageBytes != null) {
          await Gal.putImageBytes(widget.imageBytes!);
        } else if (widget.imageFilePath != null) {
          await Gal.putImage(widget.imageFilePath!);
        }
        _showToast('기기 사진첩에 저장되었습니다.', true);
      } else {
        _showToast('사진첩 접근 권한이 필요합니다.', false);
      }
    } catch (e) {
      debugPrint('Save gallery error: $e');
      _showToast('사진첩 저장 중 오류가 발생했습니다.', false);
    } finally {
      if (mounted) setState(() => _isSavingCard = false);
    }
  }

  void _showToast(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 15, color: Colors.white)),
        backgroundColor: isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFE64A19),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        child: Stack(
          children: [
            Column(
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

                                // 카카오톡 피드 카드 버블 (실제 카카오톡 전송 피드와 100% 동일)
                                Flexible(
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 255),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(4),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // 1. 카드 이미지 (상단 라운딩)
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(4),
                                          ),
                                          child: Image.memory(
                                            widget.imageBytes!,
                                            fit: BoxFit.contain,
                                          ),
                                        ),

                                        // 2. 카카오톡 피드 버튼 및 푸터 영역
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // [나도 카드 만들기] 카카오 공식 스타일 버튼
                                              Container(
                                                width: double.infinity,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF2F3F5),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '나도 카드 만들기',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF191919),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 7),

                                              // 카카오 앱 푸터: (APP) 마음카드 | 설정
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 3,
                                                            vertical: 1.5,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFB0B8C1),
                                                            borderRadius: BorderRadius.circular(3),
                                                          ),
                                                          child: const Text(
                                                            'APP',
                                                            style: TextStyle(
                                                              fontSize: 7.5,
                                                              fontWeight: FontWeight.w800,
                                                              color: Colors.white,
                                                              letterSpacing: -0.2,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        const Text(
                                                          '마음카드',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Color(0xFF888888),
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Text(
                                                      '설정',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Color(0xFF888888),
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
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
                          onTap: _isSavingCard ? null : _handleSaveCard,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: (isDark ? const Color(0xFF2C271E) : const Color(0xFFFFF9E6)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: (isDark ? const Color(0xFF5D4A22) : const Color(0xFFFFE082)),
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
                                      Icons.bookmark_add_rounded,
                                      size: 19,
                                      color: (isDark ? const Color(0xFFFFD54F) : const Color(0xFFB76E00)),
                                    ),
                                  const SizedBox(width: 7),
                                  Text(
                                    '내 카드함에 보관하기',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: (isDark ? const Color(0xFFFFD54F) : const Color(0xFF8D4F00)),
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
                  
                  // [신규] 기기 사진첩에 저장하기 버튼
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: double.infinity,
                      minHeight: 46,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isSavingCard ? null : _handleSaveGallery,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: (isDark ? const Color(0xFF1E282C) : const Color(0xFFE8F4F8)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (isDark ? const Color(0xFF324C56) : const Color(0xFF9FD6E6)),
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
                                      color: isDark ? const Color(0xFF81D4FA) : const Color(0xFF0288D1),
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.photo_library_rounded,
                                    size: 19,
                                    color: (isDark ? const Color(0xFF81D4FA) : const Color(0xFF0288D1)),
                                  ),
                                const SizedBox(width: 7),
                                Text(
                                  '내 폰 사진첩에 저장하기',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: (isDark ? const Color(0xFF81D4FA) : const Color(0xFF01579B)),
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
              ),
            ),
          ],
        ),

        // 최고급 플로팅 알림 토스트 (다이얼로그 레이아웃 변형 없이 전면에 우아하게 노출)
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _floatingToastMessage != null
                  ? Center(
                      key: ValueKey(_floatingToastMessage),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xF2161922),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _isToastSuccess
                                ? const Color(0x6669F0AE)
                                : const Color(0x66FFB74D),
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66000000),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: _isToastSuccess
                                    ? const Color(0x2569F0AE)
                                    : const Color(0x25FFB74D),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isToastSuccess
                                    ? Icons.check_circle_rounded
                                    : Icons.bookmark_added_rounded,
                                color: _isToastSuccess
                                    ? const Color(0xFF69F0AE)
                                    : const Color(0xFFFFB74D),
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                _floatingToastMessage!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    ),
  ),
);
  }
}
