import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Badge & Title
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD81B60), Color(0xFFFF8F00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withAlpha(100),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.wb_sunny, size: 36, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                '🌅 사용 가이드 및 도움말',
                style: GoogleFonts.jua(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFFFD700) : const Color(0xFF8B0000),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '소중한 분들께 사랑과 축복을 전하세요',
                style: GoogleFonts.dongle(
                  fontSize: 20,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
              const Divider(height: 24, thickness: 1),

              // Guide Sections
              _buildGuideTile(
                context,
                icon: Icons.palette,
                iconColor: Colors.pink,
                title: '1️⃣ 예쁜 아침 카드 제작',
                description: '배경 변경 버튼으로 풍경을 바꾸고, 글자 크기[+]와 황금색/흰색 등 색상을 원하는 대로 꾸며보세요.',
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              _buildGuideTile(
                context,
                icon: Icons.eco,
                iconColor: Colors.green,
                title: '2️⃣ 매일 건강상식 꿀팁',
                description: '하단 [매일 건강상식] 탭에서 실생활 지압/스트레칭 팁을 읽고 \'카드로 꾸미기\'를 누르면 바로 카드로 합성됩니다.',
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              _buildGuideTile(
                context,
                icon: Icons.share,
                iconColor: Colors.amber.shade800,
                title: '3️⃣ 카카오톡 공유 & 저장',
                description: '[카카오톡 공유 / 저장] 버튼을 누르면 안심 전면 광고 시청 후, 단톡방이나 갤러리로 저장됩니다.',
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // Warm Blessing Box
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D3F) : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFFFFD700).withAlpha(100) : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.redAccent, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '어르신들의 매일매일이 건강하고 행복하시길 진심으로 응원합니다! ❤️',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.brown.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD81B60),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    '확인 (닫기)',
                    style: GoogleFonts.jua(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262636) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withAlpha(30),
            radius: 20,
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.jua(
                    fontSize: 16,
                    color: isDark ? const Color(0xFFFFD700) : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
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
