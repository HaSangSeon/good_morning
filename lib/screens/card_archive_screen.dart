import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/home_card_data.dart';

import '../services/card_archive_service.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart';
import '../widgets/maum_card.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1B1E2B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          elevation: 12,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B1E2B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white.withAlpha(25) : const Color(0xFFEBE5DF),
                width: 1.2,
              ),
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. 세련된 원형 삭제 아이콘 뱃지
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2E1B22) : const Color(0xFFFFF0EE),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF5A2530) : const Color(0xFFFFD8D3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE53935).withAlpha(isDark ? 40 : 25),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 28,
                        color: isDark ? const Color(0xFFFF8A80) : const Color(0xFFE53935),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 2. 제목 문구
                  Text(
                    '카드를 삭제할까요?',
                    style: GoogleFonts.gowunBatang(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF231C18),
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // 3. 안내 설명
                  Text(
                    '보관함에서 카드를 삭제합니다.\n삭제된 카드는 다시 복구할 수 없어요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? Colors.white70 : const Color(0xFF6B5E57),
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. 시니어 맞춤 큼직한 액션 버튼들 (취소 / 삭제하기)
                  Row(
                    children: [
                      // [ 취소 ] 버튼
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(dialogContext).pop(false);
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: Ink(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF282C3D) : const Color(0xFFF1EFEA),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isDark ? Colors.white12 : const Color(0xFFDDD8D1),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '취소',
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white70 : const Color(0xFF5C544E),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // [ 삭제하기 ] 버튼 (고급스러운 크림슨 레드 그라데이션)
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(dialogContext).pop(true);
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: Ink(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE53935), Color(0xFFC62828)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFC62828).withAlpha(65),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '삭제하기',
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      await _archiveService.deleteCard(card.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_outline_rounded, color: Color(0xFFFF8A80), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '카드가 보관함에서 삭제되었습니다.',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2C2F3E),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(milliseconds: 2200),
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

  int _calculateAutoFontStep(String text) {
    final rawText = text.trim();
    if (rawText.isEmpty) return 8;
    final lineCount = rawText.split('\n').length;
    final len = rawText.length;
    
    if (lineCount >= 6 || len >= 60) return 1;
    if (lineCount == 5 || len >= 50) return 2;
    if (lineCount == 4 || len >= 40) return 4;
    if (lineCount == 3 || len >= 30) return 5;
    if (lineCount == 2 || len >= 20) return 7;
    if (len >= 10) return 8;
    return 10;
  }

  TextStyle _getCardTextStyle(
    String? fontFamily,
    int textColorValue, {
    int? fontStep,
    required String message,
  }) {
    TextStyle baseStyle;
    if (fontFamily == 'GowunBatang') {
      baseStyle = GoogleFonts.gowunBatang(fontWeight: FontWeight.bold);
    } else if (fontFamily == 'NanumMyeongjo') {
      baseStyle = GoogleFonts.nanumMyeongjo(fontWeight: FontWeight.bold);
    } else if (fontFamily == 'SongMyung') {
      baseStyle = GoogleFonts.songMyung();
    } else if (fontFamily == 'DoHyeon') {
      baseStyle = GoogleFonts.doHyeon();
    } else if (fontFamily == 'NanumBrush') {
      baseStyle = GoogleFonts.nanumBrushScript();
    } else if (fontFamily == 'NanumPen') {
      baseStyle = GoogleFonts.nanumPenScript();
    } else if (fontFamily == 'GamjaFlower') {
      baseStyle = GoogleFonts.gamjaFlower();
    } else if (fontFamily == 'BlackHanSans') {
      baseStyle = GoogleFonts.blackHanSans();
    } else {
      baseStyle = GoogleFonts.jua();
    }

    final fontSizes = [20.0, 24.0, 28.0, 32.0, 36.0, 40.0, 44.0, 48.0, 52.0, 56.0];
    final lineHeights = [1.5, 1.48, 1.45, 1.42, 1.38, 1.35, 1.32, 1.28, 1.25, 1.2];

    int activeStep = fontStep ?? 0;
    if (activeStep <= 0) {
      activeStep = _calculateAutoFontStep(message);
    }
    int idx = (activeStep - 1).clamp(0, 9);
    double fontSize = fontSizes[idx];
    double height = lineHeights[idx];

    return baseStyle.copyWith(
      fontSize: fontSize,
      height: height,
      fontWeight: FontWeight.bold,
      color: Color(textColorValue),
      fontFamilyFallback: const ['Apple Color Emoji', 'Segoe UI Emoji', 'Noto Color Emoji'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF141722) : const Color(0xFFFAF8F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 🌟 시니어 친화적 프리미엄 플로팅 헤더 (홈 화면과 완벽한 패밀리 룩)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 6.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2333) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black38 : const Color(0x0C000000),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E344B) : const Color(0xFFF1F5F9),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 왼쪽: 뒤로가기 버튼 + 소중한 보관함 뱃지 + 타이틀/서브문구
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 시니어용 큼직하고 뚜렷한 뒤로가기 터치 버튼
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF282D4B) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF3B4268) : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 19,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 내카드함 브랜드 뱃지 (따뜻하고 고급스러운 골드/브라운 톤)
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5A2B), Color(0xFF6B4226)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x336B4226),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.bookmark_rounded,
                              color: Color(0xFFFFD700),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 타이틀 & 감성 서브타이틀
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '내 카드함',
                              style: GoogleFonts.gowunBatang(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // 오른쪽: 명확하고 품격 있는 보관 개수 뱃지 (총 N장)
                    ValueListenableBuilder<List<SavedCard>>(
                      valueListenable: _archiveService.savedCardsNotifier,
                      builder: (context, cards, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [const Color(0xFF2E334D), const Color(0xFF1F243A)]
                                  : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? const Color(0xFF4A5580) : const Color(0xFFFDE68A),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 13,
                                color: isDark ? const Color(0xFFFFD700) : const Color(0xFFD97706),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '총 ${cards.length}장',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? const Color(0xFFFFD700) : const Color(0xFF92400E),
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
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
                if (kDebugMode && !_isNotifLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          NotificationService.instance.showTestNotification(delaySeconds: 5);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('5초 뒤에 테스트 알림이 발송됩니다. 앱을 백그라운드로 내려보세요!'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bug_report, color: Colors.grey, size: 16),
                        label: const Text(
                          '알림 테스트 (5초 후 발송)',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
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
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    final hourStr = card.createdAt.hour.toString().padLeft(2, '0');
                    final minStr = card.createdAt.minute.toString().padLeft(2, '0');
                    final double cardCanvasWidth = (MediaQuery.of(context).size.width - 80.0).clamp(0.0, 400.0);

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => widget.onSelectCard(card),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. 실제 완성 카드와 100% 동일한 1:1 정사각형 카드
                          AspectRatio(
                            aspectRatio: 1.0,
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
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // 홈 화면과 100% 동일한 MaumCard를 기준 캔버스로 렌더링 후 비율 축소
                                    FittedBox(
                                      fit: BoxFit.contain,
                                      child: SizedBox(
                                        width: cardCanvasWidth,
                                        height: cardCanvasWidth,
                                        child: MaumCard(
                                          text: card.message,
                                          backgroundImage: card.backgroundPath.startsWith('assets/')
                                              ? (defaultBackgroundList.any((bg) => bg['path'] == card.backgroundPath)
                                                  ? AssetImage(card.backgroundPath)
                                                  : const AssetImage('assets/images/bg_season_spring.webp'))
                                              : (File(card.backgroundPath).existsSync()
                                                  ? FileImage(File(card.backgroundPath))
                                                  : const AssetImage('assets/images/bg_season_spring.webp')) as ImageProvider,
                                          textStyle: _getCardTextStyle(
                                            card.fontFamily,
                                            card.textColorValue,
                                            fontStep: card.fontStep,
                                            message: card.message,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // 테두리 (border)가 저장되어 있는 경우 표시
                                    if (card.borderColorValue != null)
                                      IgnorePointer(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Color(card.borderColorValue!),
                                              width: 2.5,
                                            ),
                                          ),
                                        ),
                                      ),

                                    // 우측 상단 플로팅 삭제 버튼
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
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 2. 카드 아래 분리된 등록일자 영역
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${card.createdAt.month}월 ${card.createdAt.day}일 $hourStr:$minStr',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                bottom: math.max(MediaQuery.of(context).padding.bottom, 6.0),
              ),
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(key: ObjectKey(_bannerAd!), ad: _bannerAd!),
              ),
            )
          else
            SizedBox(
              height: math.max(MediaQuery.of(context).padding.bottom, 8.0),
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
