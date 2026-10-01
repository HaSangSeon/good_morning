import 'package:flutter/material.dart';

class ModalHeaderWidget extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String? subtitle;

  const ModalHeaderWidget({
    super.key,
    required this.icon,
    required this.gradientColors,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFBF7), // 고급스러운 웜 아이보리 배경
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        // 1. 그랩 핸들 (상단 중앙 바)
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        // 2. 타이틀 & 아이콘 뱃지 & 닫기 버튼 행
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 18, 12),
          child: Row(
            children: [
              // 세련된 아이콘 뱃지
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // 둥글고 부드러운 닫기 버튼
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF475569)),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 3. 은은한 구분선
        Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0x00E2E8F0),
                Color(0xFFE2E8F0),
                Color(0xFFE2E8F0),
                Color(0x00E2E8F0),
              ],
              stops: [0.0, 0.15, 0.85, 1.0],
            ),
          ),
        ),
        ],
      ),
    );
  }
}
