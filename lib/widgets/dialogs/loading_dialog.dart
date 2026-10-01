import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingDialogWidget extends StatelessWidget {
  const LoadingDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 32,
              offset: Offset(0, 12),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 프리미엄 회전 링 & 중앙 마음 뱃지
            SizedBox(
              width: 86,
              height: 86,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 86,
                    height: 86,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5E62)),
                      backgroundColor: Color(0xFFFFEDD5),
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5E62).withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 2. 따뜻한 서브 헤더
            const Text(
              '따뜻한 마음을 담아',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE11D48),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            // 3. 메인 타이틀 (고운바탕체 품격 있는 타이포)
            Text(
              '예쁜 안부 카드를\n정성껏 만들고 있어요',
              textAlign: TextAlign.center,
              style: GoogleFonts.gowunBatang(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                height: 1.42,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 18),
            // 4. 안내 캡슐 칩
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFEDD5), width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 15, color: Color(0xFFEA580C)),
                  SizedBox(width: 6),
                  Text(
                    '잠시만 기다려 주세요...',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC2410C),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
