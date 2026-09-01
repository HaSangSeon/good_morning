import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/card_archive_service.dart';
import '../services/theme_service.dart';
import '../widgets/help_dialog.dart';

class CardArchiveScreen extends StatefulWidget {
  const CardArchiveScreen({super.key, required this.onSelectCard});

  final ValueChanged<SavedCard> onSelectCard;

  @override
  State<CardArchiveScreen> createState() => _CardArchiveScreenState();
}

class _CardArchiveScreenState extends State<CardArchiveScreen> with SingleTickerProviderStateMixin {
  final _archiveService = CardArchiveService();
  late final AnimationController _archiveAnimController;

  @override
  void initState() {
    super.initState();
    _archiveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _archiveAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF311B92), const Color(0xFF8E24AA)]
                  : [const Color(0xFFE64A19), const Color(0xFFFF7043)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          '💌 내 카드함',
          style: GoogleFonts.jua(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          // Theme Toggle Button (Light / Dark)
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny : Icons.nightlight_round,
              color: isDark ? const Color(0xFFFFD700) : Colors.white,
            ),
            tooltip: isDark ? '라이트 모드로 전환' : '다크 모드로 전환',
            onPressed: () {
              HapticFeedback.lightImpact();
              ThemeService().toggleTheme();
            },
          ),
          // Help Dialog Button
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            tooltip: '사용 가이드',
            onPressed: () {
              HapticFeedback.lightImpact();
              HelpDialog.show(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF141722), const Color(0xFF1C202E)]
                : [const Color(0xFFFAF8F5), const Color(0xFFEFE9DE)],
          ),
        ),
        child: Stack(
          children: [
            // Active Ambient Floating Sparkles in Archive Background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _archiveAnimController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ArchiveAmbientSparklePainter(
                      progress: _archiveAnimController.value,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),

            // Main Archive List
            ValueListenableBuilder<List<SavedCard>>(
              valueListenable: _archiveService.savedCardsNotifier,
              builder: (context, cards, child) {
                if (cards.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF282D4B) : Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 48,
                              color: Color(0xFFE64A19),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '아직 저장된 카드가 없어요',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '카카오톡으로 공유한 카드는\n여기에 자동으로 쏙쏙 모아드려요! 💌',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: isDark ? Colors.white70 : const Color(0xFF756A63),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.80,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    final hourStr = card.createdAt.hour.toString().padLeft(2, '0');
                    final minStr = card.createdAt.minute.toString().padLeft(2, '0');

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => widget.onSelectCard(card),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x28000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                          image: DecorationImage(
                            image: card.backgroundPath.startsWith('assets/')
                                ? AssetImage(card.backgroundPath)
                                : (File(card.backgroundPath).existsSync()
                                    ? FileImage(File(card.backgroundPath))
                                    : const AssetImage('assets/images/bg_season_spring.jpg')) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: card.borderColorValue != null
                                    ? Border.all(
                                        color: Color(card.borderColorValue!),
                                        width: 2.5,
                                      )
                                    : null,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withAlpha(40),
                                    Colors.transparent,
                                    Colors.black.withAlpha(60),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Center(
                                child: Text(
                                  card.message,
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(card.textColorValue),
                                    shadows: const [
                                      Shadow(color: Colors.black87, blurRadius: 4),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Refined Floating Delete Button (Well-spaced & Frosted Glass Aesthetic)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _archiveService.deleteCard(card.id);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(140),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withAlpha(60),
                                      width: 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            // Bottom Sent Tag with Detailed Time (e.g. 8월 17일 23:33)
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(120),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(45),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 10,
                                      color: Color(0xFFFFD700),
                                    ),
                                    const SizedBox(width: 3.5),
                                    Text(
                                      '${card.createdAt.month}월 ${card.createdAt.day}일 $hourStr:$minStr',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Lightweight Animated Sparkle Painter for Card Archive Background
class _ArchiveAmbientSparklePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _ArchiveAmbientSparklePainter({required this.progress, required this.isDark});

  static const List<Offset> _anchors = [
    Offset(0.10, 0.15),
    Offset(0.85, 0.22),
    Offset(0.20, 0.45),
    Offset(0.78, 0.55),
    Offset(0.12, 0.75),
    Offset(0.90, 0.80),
    Offset(0.48, 0.10),
    Offset(0.52, 0.68),
    Offset(0.30, 0.90),
    Offset(0.70, 0.92),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _anchors.length; i++) {
      final anchor = _anchors[i];
      final speed = 0.8 + (i % 3) * 0.4;
      final phase = (progress * speed + (i * 0.12)) % 1.0;

      final dy = size.height * (anchor.dy - (phase * 0.20));
      final dx = size.width * anchor.dx + (8 * math.sin((phase * 2 * math.pi) + i));

      final alpha = (math.sin(phase * math.pi) * 180).clamp(0, 180).toInt();
      if (alpha <= 5) continue;

      final color = isDark
          ? (i % 2 == 0 ? const Color(0xFFFFD700) : const Color(0xFF64B5F6))
          : (i % 2 == 0 ? const Color(0xFFE64A19) : const Color(0xFFFFB300));

      paint.color = color.withAlpha(alpha);

      final currentPos = Offset(dx % size.width, dy < 0 ? size.height + dy : dy);

      if (i % 2 == 0) {
        final starSize = (3.0 + (i % 2) * 1.5) * (alpha / 180);
        final path = Path()
          ..moveTo(currentPos.dx, currentPos.dy - starSize)
          ..lineTo(currentPos.dx + starSize * 0.35, currentPos.dy)
          ..lineTo(currentPos.dx, currentPos.dy + starSize)
          ..lineTo(currentPos.dx - starSize * 0.35, currentPos.dy)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        final radius = (2.2 + (i % 2)) * (alpha / 180);
        canvas.drawCircle(currentPos, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ArchiveAmbientSparklePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
