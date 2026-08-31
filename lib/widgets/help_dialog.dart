import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 8,
      backgroundColor: isDark ? const Color(0xFF1B1E2B) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 선셋 헤더
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 14, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1B1B2F), const Color(0xFF2C1938), const Color(0xFF381A40)]
                        : [const Color(0xFFC0392B), const Color(0xFFD35400), const Color(0xFFE67E22)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.help_outline_rounded, color: Color(0xFFFFD700), size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '마음카드 간단 사용법',
                        style: GoogleFonts.jua(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 24),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      tooltip: '닫기',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                child: Column(
                  children: [
                    // 핵심 1: 카드 만들기 & 카톡 전송
                    _buildSimpleHelpItem(
                      icon: Icons.send_rounded,
                      iconBgColor: const Color(0xFFFFE082),
                      iconColor: const Color(0xFFE65100),
                      title: '카톡으로 안부 카드 보내기',
                      desc: '배경과 글귀를 선택한 후, 맨 아래 [카카오톡 공유하기] 버튼을 누르면 가족·친구에게 바로 전송됩니다.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // 핵심 2: 매일 아침 9시 알림
                    _buildSimpleHelpItem(
                      icon: Icons.notifications_active_rounded,
                      iconBgColor: const Color(0xFFFFCCBC),
                      iconColor: const Color(0xFFD32F2F),
                      title: '매일 아침 9시 안부 알림',
                      desc: '상단의 [종 모양 🔔] 버튼을 누르면 매일 아침 9시에 따뜻한 안부 문구가 배달됩니다.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // 핵심 3: 배경음악 & 명언 탭
                    _buildSimpleHelpItem(
                      icon: Icons.auto_stories_rounded,
                      iconBgColor: const Color(0xFFC8E6C9),
                      iconColor: const Color(0xFF2E7D32),
                      title: '좋은글 & 새소리 배경음악',
                      desc: '하단 [좋은글 & 명언]에서 감동 글귀를 카드로 만들 수 있고, 상단 [스피커 🔊]로 힐링 음악을 켤 수 있습니다.',
                      isDark: isDark,
                    ),

                    const SizedBox(height: 18),

                    // 지인에게 앱 추천하기 버튼 (바이럴)
                    OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Share.share(
                          '매일 아침 아름다운 감성 카드와 좋은 글을 선물하세요! 🌸\n\n'
                          '💌 [마음카드] 앱 다운로드하기\n'
                          '👉 https://play.google.com/store/apps/details?id=com.sintong.good_morning',
                          subject: '마음카드 - 아침인사 & 좋은글 앱',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? const Color(0xFFFFD700) : const Color(0xFFE64A19),
                        side: BorderSide(
                          color: isDark ? const Color(0xFFFFD700) : const Color(0xFFE64A19),
                          width: 1.3,
                        ),
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text(
                        '지인에게 마음카드 앱 추천하기 💌',
                        style: GoogleFonts.jua(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 확인(닫기) 버튼
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD35400),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        '확인',
                        style: GoogleFonts.jua(fontSize: 18, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleHelpItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252A3D) : const Color(0xFFFFF8F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFFFE0B2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFFFD700) : const Color(0xFFBF360C),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: isDark ? Colors.white70 : const Color(0xFF424242),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
