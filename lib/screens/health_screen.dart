import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../services/ad_service.dart';

class HealthTip {
  final String category;
  final String title;
  final String icon;
  final String summary;
  final List<String> details;
  final String shareCardText;

  HealthTip({
    required this.category,
    required this.title,
    required this.icon,
    required this.summary,
    required this.details,
    required this.shareCardText,
  });
}

class HealthScreen extends StatefulWidget {
  final Function(String cardText)? onShareAsCard;

  const HealthScreen({super.key, this.onShareAsCard});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  String _selectedCategory = '전체';

  final List<HealthTip> _healthTips = [
    HealthTip(
      category: '혈관/혈당',
      title: '혈액순환 쑥쑥! 손발 따뜻해지는 3분 지압법',
      icon: '🖐️',
      summary: '합곡혈(엄지와 검지 사이)을 3분간 꾹 눌러주면 전신 혈액순환이 원활해집니다.',
      details: [
        '1. 엄지 손가락과 검지 손가락이 만나는 움푹 들어간 곳(합곡혈)을 찾습니다.',
        '2. 숨을 내쉬며 5초간 약간 뻐근할 정도로 지긋이 누릅니다.',
        '3. 양손을 번갈아가며 3분씩 반복하면 손발 온도가 상승합니다.',
      ],
      shareCardText: "🖐️ [혈액순환 3분 지압법]\n엄지와 검지 사이(합곡혈)를 3분간 눌러보세요! 손발이 따뜻해지고 전신 혈액순환에 최고입니다 🌿",
    ),
    HealthTip(
      category: '관절/운동',
      title: '무릎 관절을 지키는 1분 의자 스트레칭',
      icon: '🪑',
      summary: '의자에 앉아 다리를 펴고 10초 멈추는 동작으로 대퇴사두근을 강화하세요.',
      details: [
        '1. 의자에 바른 자세로 앉아 한쪽 다리를 앞으로 곧게 폅니다.',
        '2. 발끝을 몸 쪽으로 당긴 상태에서 10초간 유지합니다.',
        '3. 양다리를 5회씩 반복하면 무릎 연골 부담이 현저히 줄어듭니다.',
      ],
      shareCardText: "🪑 [무릎관절 1분 스트레칭]\n의자에 앉아 다리를 펴고 10초 유지하세요! 무릎 통증 예방과 대퇴근 강화에 으뜸입니다 💪",
    ),
    HealthTip(
      category: '눈/피로',
      title: '눈 피로 한 방에 날리는 20-20-20 수칙',
      icon: '👁️',
      summary: '스마트폰 화면을 보다가 20분마다 20피트(6m) 밖을 20초간 바라보세요.',
      details: [
        '1. 돋보기나 스마트폰을 사용할 때 타이머를 맞춰둡니다.',
        '2. 20분이 지나면 창밖이나 먼 산을 20초 동안 가만히 지목합니다.',
        '3. 눈을 천천히 깜빡여 안구 건조증을 예방합니다.',
      ],
      shareCardText: "👁️ [눈 건강 20-20-20 수칙]\n20분마다 먼 곳을 20초간 바라보세요! 안구건조증 예방과 시력 보호에 참 좋습니다 👀",
    ),
    HealthTip(
      category: '식습관',
      title: '식후 혈당 폭발 막는 15분 산책법',
      icon: '🚶‍♂️',
      summary: '식사 후 30분 이내에 15분간 가볍게 걸으면 혈당 스파이크를 막을 수 있습니다.',
      details: [
        '1. 식사를 마친 후 바로 눕지 말고 가벼운 집안일이나 산책을 시작합니다.',
        '2. 약간 땀이 날 정도의 속도로 15분간 걷습니다.',
        '3. 허벅지 근육이 포도당을 빠르게 소비하여 당뇨 위험이 줄어듭니다.',
      ],
      shareCardText: "🚶‍♂️ [식후 혈당 방어 산책법]\n식사 후 30분 내 15분만 걸으세요! 혈당 스파이크를 막아 당뇨 예방에 큰 도움이 됩니다 🌾",
    ),
    HealthTip(
      category: '식습관',
      title: '면역력 쑥쑥! 당뇨 예방에 좋은 3대 따뜻한 차(茶)',
      icon: '🍵',
      summary: '생강차, 여주차, 계피차는 체온을 높이고 혈당 조절에 탁월합니다.',
      details: [
        '1. 생강차: 면역력을 높이고 몸속 염증을 줄여줍니다.',
        '2. 여주차: 식물성 인슐린이 풍부하여 혈당 관리에 으뜸입니다.',
        '3. 계피차: 혈액순환을 돕고 따뜻한 기운을 북돋아 줍니다.',
      ],
      shareCardText: "🍵 [면역력 쑥쑥 3대 건강차]\n생강차, 여주차, 계피차로 따뜻한 체온 유지하세요! 체온 1도 상승 시 면역력 5배 증가합니다 💖",
    ),
    HealthTip(
      category: '관절/운동',
      title: '치매 예방! 뇌를 젊게 만드는 하루 10분 손가락 운동',
      icon: '🧠',
      summary: '양손의 손가락 끝을 마주치거나 짝지어 움직이면 뇌세포가 활성화됩니다.',
      details: [
        '1. 양손 끝을 마주 대고 톡톡톡 30회 톡톡 칩니다.',
        '2. 한 손은 주먹, 한 손은 가위를 번갈아 바꾸는 뇌 자극 운동을 합니다.',
        '3. 뇌 혈류량이 증대되어 기억력과 집중력이 향상됩니다.',
      ],
      shareCardText: "🧠 [치매 예방 10분 손가락 운동]\n양 손가락 끝을 마주치고 톡톡 쳐보세요! 뇌 혈류량이 늘어나 기억력이 좋아집니다 ✨",
    ),
  ];

  List<HealthTip> get _filteredTips {
    if (_selectedCategory == '전체') return _healthTips;
    return _healthTips.where((tip) => tip.category == _selectedCategory).toList();
  }

  Future<void> _shareTipDirectly(HealthTip tip) async {
    HapticFeedback.mediumImpact();
    AdService().showInterstitialAd(onAdDismissed: () async {
      try {
        final imageBytes = await _screenshotController.captureFromWidget(
          Container(
            width: 400,
            height: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${tip.icon} 매일 건강 꿀팁',
                  style: GoogleFonts.jua(fontSize: 28, color: Colors.yellowAccent),
                ),
                const SizedBox(height: 16),
                Text(
                  tip.shareCardText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jua(fontSize: 22, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  '🌅 좋은아침 메이커',
                  style: GoogleFonts.dongle(fontSize: 24, color: Colors.white70),
                ),
              ],
            ),
          ),
        );

        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/health_tip.png').create();
        await imagePath.writeAsBytes(imageBytes);

        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: tip.shareCardText,
        );
      } catch (e) {
        debugPrint('Error sharing health tip: $e');
      }
    });
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
                  ? [const Color(0xFF1B5E20), const Color(0xFF388E3C)]
                  : [const Color(0xFF2E7D32), const Color(0xFF66BB6A)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          '🌿 매일 건강상식 & 꿀팁',
          style: GoogleFonts.jua(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category Filter Tabs
          Container(
            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['전체', '혈관/혈당', '관절/운동', '눈/피로', '식습관'].map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.grey.shade200 : Colors.black87),
                        ),
                      ),
                      selectedColor: const Color(0xFF2E7D32),
                      backgroundColor: isDark ? const Color(0xFF262636) : Colors.grey.shade100,
                      onSelected: (selected) {
                        if (selected) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = cat);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Tips List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filteredTips.length,
              itemBuilder: (context, index) {
                final tip = _filteredTips[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 14),
                  color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: isDark ? const Color(0xFF264028) : Colors.green.shade100,
                      radius: 24,
                      child: Text(tip.icon, style: const TextStyle(fontSize: 22)),
                    ),
                    title: Text(
                      tip.title,
                      style: GoogleFonts.jua(
                        fontSize: 18,
                        color: isDark ? const Color(0xFF81C784) : const Color(0xFF1B5E20),
                      ),
                    ),
                    subtitle: Text(
                      tip.summary,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade300 : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📌 실천 방법',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF81C784) : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...tip.details.map((detail) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                detail,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                  color: isDark ? Colors.grey.shade200 : Colors.black87,
                                ),
                              ),
                            )),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                if (widget.onShareAsCard != null)
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        widget.onShareAsCard!(tip.shareCardText);
                                      },
                                      icon: const Icon(Icons.style, color: Colors.deepOrange),
                                      label: const Text('카드로 꾸미기', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                if (widget.onShareAsCard != null) const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _shareTipDirectly(tip),
                                    icon: const Icon(Icons.share, color: Colors.black87),
                                    label: const Text('카톡 공유', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFEE500),
                                      foregroundColor: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
