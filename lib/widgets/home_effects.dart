import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Lightweight Animated Sparkle Painter for Morning Sunlight / Star Mood
class MorningSparklePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  MorningSparklePainter({required this.progress, required this.isDark});

  // 12 Pre-calculated particle anchor offsets (normalized 0.0 ~ 1.0)
  static const List<Offset> _anchors = [
    Offset(0.08, 0.25),
    Offset(0.18, 0.70),
    Offset(0.12, 0.85),
    Offset(0.85, 0.20),
    Offset(0.92, 0.65),
    Offset(0.88, 0.82),
    Offset(0.05, 0.50),
    Offset(0.95, 0.40),
    Offset(0.25, 0.15),
    Offset(0.75, 0.12),
    Offset(0.22, 0.90),
    Offset(0.78, 0.92),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Gentle Ambient Breathing Aura behind card
    final center = Offset(size.width / 2, size.height / 2);
    final pulseScale = 1.0 + 0.08 * math.sin(progress * 2 * math.pi);
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [
                const Color(0xFFFFD700).withAlpha((20 * pulseScale).toInt()),
                const Color(0xFF64B5F6).withAlpha((15 * pulseScale).toInt()),
                Colors.transparent,
              ]
            : [
                const Color(0xFFFFB300).withAlpha((28 * pulseScale).toInt()),
                const Color(0xFFFF8A80).withAlpha((18 * pulseScale).toInt()),
                Colors.transparent,
              ],
      ).createShader(
        Rect.fromCircle(center: center, radius: (size.height * 0.75) * pulseScale),
      );
    canvas.drawCircle(center, (size.height * 0.75) * pulseScale, auraPaint);

    // 2. 12 Floating Active Sparkles
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _anchors.length; i++) {
      final anchor = _anchors[i];
      final speed = 1.0 + (i % 3) * 0.5;
      final particlePhase = (progress * speed + (i * 0.13)) % 1.0;

      // Vertical floating & horizontal gentle wave
      final dy = size.height * (anchor.dy - (particlePhase * 0.25));
      final dx = size.width * anchor.dx + (6 * math.sin((particlePhase * 2 * math.pi) + i));

      // Twinkle alpha
      final alpha = (math.sin(particlePhase * math.pi) * 220).clamp(0, 220).toInt();
      if (alpha <= 5) continue;

      final color = isDark
          ? (i % 2 == 0 ? const Color(0xFFFFD700) : const Color(0xFF80D8FF))
          : (i % 3 == 0
              ? const Color(0xFFFFB300)
              : (i % 3 == 1 ? const Color(0xFFFF7043) : const Color(0xFFFF4081)));

      paint.color = color.withAlpha(alpha);

      // Draw 4-point Diamond Star for even indices, soft glowing circle for odd
      final currentPos = Offset(dx % size.width, dy < 0 ? size.height + dy : dy);

      if (i % 2 == 0) {
        final starSize = (3.5 + (i % 3) * 1.5) * (alpha / 220);
        final path = Path()
          ..moveTo(currentPos.dx, currentPos.dy - starSize)
          ..lineTo(currentPos.dx + starSize * 0.35, currentPos.dy)
          ..lineTo(currentPos.dx, currentPos.dy + starSize)
          ..lineTo(currentPos.dx - starSize * 0.35, currentPos.dy)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        final radius = (2.0 + (i % 2) * 1.2) * (alpha / 220);
        canvas.drawCircle(currentPos, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MorningSparklePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

/// 꽃잎/나비/새싹 플로팅 애니메이션 — 중장년층을 위한 따뜻한 자연 배경
class FlowerPetalPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  FlowerPetalPainter({required this.progress, required this.isDark});

  // 14개 다양한 위치의 꽃잎 & 자연 파티클 앵커 (정규화 0.0 ~ 1.0)
  static const List<Offset> _petalAnchors = [
    Offset(0.04, 0.0),
    Offset(0.14, 0.0),
    Offset(0.24, 0.0),
    Offset(0.36, 0.0),
    Offset(0.48, 0.0),
    Offset(0.58, 0.0),
    Offset(0.68, 0.0),
    Offset(0.79, 0.0),
    Offset(0.89, 0.0),
    Offset(0.96, 0.0),
    Offset(0.20, 0.0),
    Offset(0.42, 0.0),
    Offset(0.62, 0.0),
    Offset(0.82, 0.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _petalAnchors.length; i++) {
      final anchor = _petalAnchors[i];
      // 각각 다른 속도로 낙하 — 느리게, 부드러운 봄바람
      final speed = 0.35 + (i % 5) * 0.12;
      final particlePhase = (progress * speed + (i * 0.071)) % 1.0;

      // 수직 낙하 + 수평 살랑거림
      final dy = particlePhase * size.height;
      final swingX = 18.0 * math.sin((particlePhase * 2 * math.pi * 1.3) + i * 0.8);
      final dx = size.width * anchor.dx + swingX;

      // 알파 (등장 페이드인 / 퇴장 페이드아웃)
      final alpha = (math.sin(particlePhase * math.pi) * 190).clamp(0, 190).toInt();
      if (alpha <= 6) continue;

      // 꽃잎 & 자연 색상 (화사한 벚꽃 핑크, 따뜻한 살구, 연한 초록 잎사귀, 골드 햇살)
      final List<Color> colors = isDark
          ? [
              const Color(0xFFFFD700), // 골드
              const Color(0xFFCE93D8), // 은은한 라벤더
              const Color(0xFF81D4FA), // 청초한 하늘
              const Color(0xFFFFAB91), // 살구빛
            ]
          : [
              const Color(0xFFFF80AB), // 벚꽃 분홍
              const Color(0xFFFFB74D), // 따뜻한 햇살 살구
              const Color(0xFFAED581), // 어린 새싹 연두
              const Color(0xFFF48FB1), // 부드러운 코랄 핑크
            ];

      paint.color = colors[i % colors.length].withAlpha(alpha);

      final pos = Offset(dx.clamp(0, size.width), dy);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      // 천천히 회전
      final rotAngle = particlePhase * 2 * math.pi * (i % 2 == 0 ? 1.0 : -0.7);
      canvas.rotate(rotAngle);

      final shapeType = i % 3;
      if (shapeType == 0) {
        // 1. 벚꽃잎 (유선형 타원)
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: 10.0 + (i % 3) * 2.0,
          height: 6.0 + (i % 2) * 1.5,
        );
        canvas.drawOval(rect, paint);
      } else if (shapeType == 1) {
        // 2. 만개한 작은 꽃송이 (4잎)
        final petalR = 3.5 + (i % 2) * 1.0;
        canvas.drawCircle(Offset.zero, petalR * 0.4, paint);
        for (int p = 0; p < 4; p++) {
          final angle = p * (math.pi / 2);
          canvas.drawCircle(
            Offset(math.cos(angle) * petalR, math.sin(angle) * petalR),
            petalR * 0.55,
            paint,
          );
        }
      } else {
        // 3. 햇살 머금은 잎사귀 / 작은 물방울
        final path = Path()
          ..moveTo(0, -6)
          ..quadraticBezierTo(5, 0, 0, 6)
          ..quadraticBezierTo(-5, 0, 0, -6)
          ..close();
        canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant FlowerPetalPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

/// 무조건 옆으로 부드럽게 무한 자동 롤링되는 마키 텍스트 위젯
class MarqueeFlowingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const MarqueeFlowingText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<MarqueeFlowingText> createState() => _MarqueeFlowingTextState();
}

class _MarqueeFlowingTextState extends State<MarqueeFlowingText>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 35),
    )..addListener(() {
        if (_scrollController.hasClients) {
          final max = _scrollController.position.maxScrollExtent;
          if (max > 0) {
            _scrollController.jumpTo(_animController.value * max);
          }
        }
      });

    _animController.repeat();
  }

  @override
  void didUpdateWidget(covariant MarqueeFlowingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _animController.reset();
      _animController.repeat();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.text, style: widget.style),
          const SizedBox(width: 45),
          Text(widget.text, style: widget.style),
          const SizedBox(width: 45),
        ],
      ),
    );
  }
}
