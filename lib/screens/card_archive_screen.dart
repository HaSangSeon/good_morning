import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/card_archive_service.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/keep_all_text.dart';

class CardArchiveScreen extends StatefulWidget {
  const CardArchiveScreen({super.key, required this.onSelectCard});

  final ValueChanged<SavedCard> onSelectCard;

  @override
  State<CardArchiveScreen> createState() => _CardArchiveScreenState();
}

class _CardArchiveScreenState extends State<CardArchiveScreen> with SingleTickerProviderStateMixin {
  final _archiveService = CardArchiveService();
  late final AnimationController _archiveAnimController;


  bool _isNotificationEnabled = true;
  bool _isNotifLoading = true;

  bool _isBannerAdLoaded = false;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _archiveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _loadNotificationState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadBannerAd();
    }
  }

  Future<void> _loadBannerAd() async {
    final AnchoredAdaptiveBannerAdSize? size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      debugPrint('Unable to get adaptive banner size.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: AdService().bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  Future<void> _loadNotificationState() async {
    final isEnabled = await NotificationService.instance.isNotificationEnabled();
    if (mounted) {
      setState(() {
        _isNotificationEnabled = isEnabled;
        _isNotifLoading = false;
      });
    }
  }

  Future<void> _toggleNotification(bool value) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isNotificationEnabled = value;
    });
    await NotificationService.instance.saveSettings(
      isEnabled: value,
      time: const TimeOfDay(hour: 7, minute: 15),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SavedCard card) async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C202E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE64A19).withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE64A19),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '카드 삭제',
                style: GoogleFonts.gowunBatang(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2D1810),
                ),
              ),
            ],
          ),
          content: Text(
            '보관함에서 이 카드를\n정말 삭제하시겠습니까?\n\n삭제된 카드는 복구할 수 없습니다.'.keepAll,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: isDark ? Colors.white70 : const Color(0xFF444444),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(dialogContext).pop(false);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE64A19),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                '삭제하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _archiveService.deleteCard(card.id);
      if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '카드가 보관함에서 삭제되었습니다.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF424242),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }


  @override
  void dispose() {
    _archiveAnimController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF141722) : const Color(0xFFFAF8F5),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF282D4B) : const Color(0xFFEDE8E1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? Colors.white : const Color(0xFF2D1810),
              ),
            ),
            tooltip: '뒤로가기',
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '내 카드함',
              style: GoogleFonts.gowunBatang(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF2D1810),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<List<SavedCard>>(
              valueListenable: _archiveService.savedCardsNotifier,
              builder: (context, cards, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF282D4B) : const Color(0xFFE8DFD5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${cards.length}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFFFD700) : const Color(0xFF5D4037),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        centerTitle: false,

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: isDark ? Colors.white10 : const Color(0xFFE8E2D8),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
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


            Column(
              children: [
                if (!_isNotifLoading)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF282D4B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : const Color(0x0C000000),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '매일 아침 안부 알림 받기',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '매일 오전 7시 15분에 오늘의 추천 카드를\n알려드려요',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.35,
                                  color: isDark ? Colors.white70 : const Color(0xFF777777),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Transform.scale(
                          scale: 1.2,
                          child: Switch(
                            value: _isNotificationEnabled,
                            onChanged: _toggleNotification,
                            activeThumbColor: const Color(0xFFE64A19),
                            activeTrackColor: const Color(0xFFFFCCBC),
                            inactiveThumbColor: Colors.grey.shade400,
                            inactiveTrackColor: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ValueListenableBuilder<List<SavedCard>>(

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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                                onTap: () => _confirmDelete(context, card),
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
          ),
        ],
      ),
    ],
  ),
),
),
if (!AdService.hideBannerAdsForScreenshots && _isBannerAdLoaded && _bannerAd != null)
            Padding(
              padding: EdgeInsets.only(
                top: 8,
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(key: ObjectKey(_bannerAd!), ad: _bannerAd!),
              ),
            )
          else
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
        ],
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
