import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import '../services/theme_service.dart';
import '../widgets/help_dialog.dart';
import '../widgets/share_preview_dialog.dart';

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
    // 1. 혈관/혈당
    HealthTip(
      category: '혈관/혈당',
      title: '혈액순환 쑥쑥! 손발 따뜻해지는 3분 지압법',
      icon: '🖐️',
      summary: '합곡혈(엄지와 검지 사이)을 3분간 꾹 눌러주면 전신 혈액순환이 원활해집니다.',
      details: [
        '1. 엄지 손가락과 검지 손가락이 만나는 움푹 들어간 곳(합곡혈)을 찾습니다.',
        '2. 숨을 내쉬며 5초간 약간 뻐근할 정도로 지긋이 누릅니다.',
        '3. 양손을 번갈아가며 3분씩 반복하면 손발 온도가 상승하고 두통도 완화됩니다.',
      ],
      shareCardText: "🖐️ [혈액순환 3분 지압법]\n엄지와 검지 사이(합곡혈)를 3분간 눌러보세요! 손발이 따뜻해지고 전신 혈액순환에 최고입니다 🌿",
    ),
    HealthTip(
      category: '혈관/혈당',
      title: '식후 혈당 폭발 막는 15분 산책법',
      icon: '🚶‍♂️',
      summary: '식사 후 30분 이내에 15분간 가볍게 걸으면 혈당 스파이크를 막을 수 있습니다.',
      details: [
        '1. 식사를 마친 후 바로 눕지 말고 가벼운 집안일이나 산책을 시작합니다.',
        '2. 약간 땀이 날 정도의 속도로 15분간 걷습니다.',
        '3. 허벅지 근육이 포도당을 빠르게 소비하여 당뇨 위험과 중성지방이 줄어듭니다.',
      ],
      shareCardText: "🚶‍♂️ [식후 혈당 방어 산책법]\n식사 후 30분 내 15분만 걸으세요! 혈당 스파이크를 막아 당뇨 예방에 큰 도움이 됩니다 🌾",
    ),
    HealthTip(
      category: '혈관/혈당',
      title: '고혈압 잡는 제2의 심장! 발뒤꿈치 들기 운동',
      icon: '🦵',
      summary: '종아리 근육을 펌핑하면 하지에 쏠린 혈액이 심장으로 힘차게 올라갑니다.',
      details: [
        '1. 벽이나 의자 등받이를 잡고 바르게 섭니다.',
        '2. 숨을 내쉬며 발뒤꿈치를 최대한 높이 들고 3초간 멈춥니다.',
        '3. 천천히 내리며 하루 30회씩 3세트 반복합니다. 혈압 안정과 하지정맥류 예방에 탁월합니다.',
      ],
      shareCardText: "🦵 [혈압 잡는 발뒤꿈치 들기]\n하루 30번 뒤꿈치를 올려보세요! 종아리 펌프가 혈액순환을 도와 혈압을 안정시켜 줍니다 💖",
    ),
    HealthTip(
      category: '혈관/혈당',
      title: '혈관 청소부! 양파와 마늘의 알리신 200% 흡수법',
      icon: '🧄',
      summary: '양파와 마늘은 썰어서 10분간 공기 중에 두면 유효성분 알리신이 극대화됩니다.',
      details: [
        '1. 마늘과 양파를 얇게 썰거나 다집니다.',
        '2. 바로 가열하지 말고 실온에서 10~15분간 산소와 접촉시킵니다.',
        '3. 알리신 활성도가 2배 이상 높아져 혈전 예방과 콜레스테롤 감소에 큰 도움이 됩니다.',
      ],
      shareCardText: "🧄 [혈관 청소 꿀팁]\n양파·마늘은 썰어서 10분 후 조리하세요! 알리신 성분이 극대화되어 혈관이 깨끗해집니다 🧅",
    ),

    // 2. 관절/운동
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
      category: '관절/운동',
      title: '허리 통증 싹 없애는 맥켄지 허리 펴기 운동',
      icon: '🧘‍♂️',
      summary: '서서 양손으로 허리를 받치고 상체를 뒤로 젖히면 디스크 압력이 줄어듭니다.',
      details: [
        '1. 양발을 어깨너비로 벌리고 양손으로 골반 뒤쪽을 받칩니다.',
        '2. 숨을 천천히 내쉬며 상체를 뒤로 부드럽게 젖힙니다.',
        '3. 5초간 유지 후 제자리로 돌아오며, 하루 10회씩 틈틈이 실천합니다.',
      ],
      shareCardText: "🧘‍♂️ [허리 튼튼 맥켄지 운동]\n양손을 허리에 대고 뒤로 5초간 젖혀보세요! 굽은 허리가 펴지고 디스크가 건강해집니다 🌳",
    ),
    HealthTip(
      category: '관절/운동',
      title: '오십견 예방! 수건 하나로 어깨 회전근개 풀기',
      icon: '🧣',
      summary: '등 뒤로 수건을 잡고 위아래로 당겨주면 굳은 어깨 관절이 시원하게 풀립니다.',
      details: [
        '1. 수건의 양끝을 등 뒤에서 위아래로 나누어 잡습니다.',
        '2. 위의 손을 천천히 위로 당겨 아래쪽 어깨가 부드럽게 늘어나게 합니다.',
        '3. 10초간 멈춘 뒤 손을 바꾸어 반복하면 오십견과 어깨 결림이 완화됩니다.',
      ],
      shareCardText: "🧣 [오십견 예방 수건 스트레칭]\n등 뒤로 수건을 잡고 위아래로 당겨보세요! 굳었던 어깨가 날아갈 듯 가벼워집니다 ✨",
    ),

    // 3. 두뇌/치매
    HealthTip(
      category: '두뇌/치매',
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
    HealthTip(
      category: '두뇌/치매',
      title: '기억력 UP! 매일 밤 3줄 일기로 뇌세포 깨우기',
      icon: '📝',
      summary: '오늘 있었던 일 3가지를 회상하여 적으면 해마(기억 중추)가 자극됩니다.',
      details: [
        '1. 오늘 감사했던 일, 기분 좋았던 일 3가지를 떠올립니다.',
        '2. 손글씨나 휴대폰 메모로 간단히 3줄을 작성합니다.',
        '3. 하루를 되돌아보는 회상 훈련으로 뇌 노화를 늦추고 숙면을 유도합니다.',
      ],
      shareCardText: "📝 [뇌 젊어지는 3줄 일기]\n오늘 감사했던 일 3가지를 적어보세요! 해마가 활성화되어 기억력 감퇴를 막아줍니다 📖",
    ),
    HealthTip(
      category: '두뇌/치매',
      title: '불면증 안녕! 숙면을 부르는 4-7-8 마법의 호흡법',
      icon: '🌙',
      summary: '4초 들이마시고, 7초 멈추고, 8초 내쉬면 부교감신경이 안정됩니다.',
      details: [
        '1. 편안히 누워 배를 채우며 4초간 코로 숨을 깊게 들이마십니다.',
        '2. 숨을 7초 동안 가만히 참습니다.',
        '3. 8초에 걸쳐 입으로 후~ 하고 천천히 내쉽니다. 4회 반복 시 금세 잠에 듭니다.',
      ],
      shareCardText: "🌙 [꿀잠 부르는 4-7-8 호흡법]\n4초 들이마시고 7초 참고 8초 내쉬어보세요! 뇌가 편안해지며 깊은 숙면에 빠져듭니다 😴",
    ),

    // 4. 식습관/수분
    HealthTip(
      category: '식습관/수분',
      title: '아침 공복 미온수 한 잔의 놀라운 기적',
      icon: '💧',
      summary: '기상 직후 체온과 비슷한 따뜻한 물은 밤새 끈적해진 혈액을 맑게 합니다.',
      details: [
        '1. 아침에 일어나 입안을 가볍게 헹궈 밤새 생긴 세균을 뱉어냅니다.',
        '2. 미지근한 물 한 잔(200ml)을 천천히 씹듯이 마십니다.',
        '3. 위장을 깨워 배변을 돕고 뇌경색·심근경색 위험을 크게 낮춥니다.',
      ],
      shareCardText: "💧 [아침 공복 따뜻한 물 한잔]\n기상 직후 미온수 한 잔은 혈액을 맑게 하고 장을 깨워주는 가장 훌륭한 보약입니다 🫖",
    ),
    HealthTip(
      category: '식습관/수분',
      title: '면역력 쑥쑥! 당뇨 예방에 좋은 3대 건강차',
      icon: '🍵',
      summary: '생강차, 여주차, 계피차는 체온을 높이고 혈당 조절에 탁월합니다.',
      details: [
        '1. 생강차: 몸을 따뜻하게 하고 염증을 줄여 면역력을 키웁니다.',
        '2. 여주차: 식물성 인슐린이 풍부하여 식후 혈당 관리에 으뜸입니다.',
        '3. 계피차: 모세혈관 순환을 돕고 활력을 북돋아 줍니다.',
      ],
      shareCardText: "🍵 [면역력 쑥쑥 3대 건강차]\n생강차, 여주차, 계피차로 따뜻한 체온 유지하세요! 체온 1도 상승 시 면역력 5배 증가합니다 💖",
    ),
    HealthTip(
      category: '식습관/수분',
      title: '근감소증 철벽 방어! 밥상 위의 단백질 황금 비율',
      icon: '🍳',
      summary: '나이 들수록 매 끼니 손바닥 크기의 양질의 단백질 섭취가 필수입니다.',
      details: [
        '1. 계란 1~2개, 두부 반 모, 닭가슴살, 생선 중 하나를 매 끼니 꼭 챙깁니다.',
        '2. 단백질을 한 번에 몰아먹지 않고 아침/점심/저녁 3번에 골고루 나눕니다.',
        '3. 근육 손실을 막아 낙상 사고를 예방하고 활기찬 에너지를 유지합니다.',
      ],
      shareCardText: "🍳 [근육 지키는 단백질 식단]\n매 끼니 손바닥 크기 단백질을 챙기세요! 튼튼한 근육이 건강 장수의 최고의 비결입니다 🐟",
    ),
    HealthTip(
      category: '식습관/수분',
      title: '소화불량과 변비 탈출! 아침 3분 장 마사지',
      icon: '🍏',
      summary: '배꼽 주위를 시계 방향으로 쓸어주면 둔해진 장 운동이 활발해집니다.',
      details: [
        '1. 누운 상태에서 양 무릎을 가볍게 세우고 복부 긴장을 풉니다.',
        '2. 손바닥을 비벼 따뜻하게 한 뒤 배꼽 주위를 시계 방향으로 30회 둥글게 문지릅니다.',
        '3. 장내 가스가 배출되고 쾌변을 유도하여 속이 아주 편안해집니다.',
      ],
      shareCardText: "🍏 [쾌변 부르는 3분 장 마사지]\n배꼽 주위를 시계 방향으로 부드럽게 문질러보세요! 속이 편안해지고 장 건강이 튼튼해집니다 🥣",
    ),

    // 5. 생활/활력
    HealthTip(
      category: '생활/활력',
      title: '눈 피로 한 방에 날리는 20-20-20 수칙',
      icon: '👁️',
      summary: '스마트폰 화면을 보다가 20분마다 20피트(6m) 밖을 20초간 바라보세요.',
      details: [
        '1. 돋보기나 스마트폰을 사용할 때 20분을 넘기지 않도록 의식합니다.',
        '2. 20분이 지나면 창밖이나 먼 산을 20초 동안 가만히 응시합니다.',
        '3. 눈을 천천히 깜빡여 안구 건조증과 백내장 진행을 예방합니다.',
      ],
      shareCardText: "👁️ [눈 건강 20-20-20 수칙]\n20분마다 먼 곳을 20초간 바라보세요! 안구건조증 예방과 시력 보호에 참 좋습니다 👀",
    ),
    HealthTip(
      category: '생활/활력',
      title: '노안 예방! 눈동자 8자 굴리기와 손바닥 온찜질',
      icon: '👓',
      summary: '손바닥 마찰열로 눈을 감싸고 눈동자를 굴려 안구 근육을 풀어줍니다.',
      details: [
        '1. 양 손바닥을 30초간 빠르게 비벼 따뜻한 열감을 만듭니다.',
        '2. 오목하게 모아 감은 눈 위에 살포시 얹고 1분간 온기를 전달합니다.',
        '3. 눈동자를 상하좌우 및 8자 모양으로 천천히 5회 굴려 모양체 근육을 이완합니다.',
      ],
      shareCardText: "👓 [노안 예방 손바닥 온찜질]\n손바닥을 비벼 따뜻하게 눈을 감싸보세요! 침침하던 눈이 맑고 시원해집니다 🌿",
    ),
    HealthTip(
      category: '생활/활력',
      title: '골다공증 예방! 하루 햇볕 20분 쬐기와 비타민D',
      icon: '☀️',
      summary: '오전 10시~오후 2시 사이 20분간 햇볕을 쬐면 뼈가 튼튼해집니다.',
      details: [
        '1. 자외선 차단제를 바르지 않은 팔다리를 햇볕에 15~20분 노출합니다.',
        '2. 체내에서 천연 비타민D가 합성되어 칼슘 흡수율이 3배 높아집니다.',
        '3. 세로토닌 호르몬이 분비되어 우울감 해소와 활력 증진에도 최고입니다.',
      ],
      shareCardText: "☀️ [뼈 튼튼 하루 20분 햇볕 쬐기]\n따뜻한 햇살을 20분만 쬐어보세요! 천연 비타민D가 골다공증을 막고 기분을 상쾌하게 합니다 🌻",
    ),
    HealthTip(
      category: '생활/활력',
      title: '면역력 5배 쑥쑥! 림프 순환 1분 귀 마사지',
      icon: '👂',
      summary: '귀 전체를 조물조물 비벼주면 200여 개의 경혈이 자극되어 면역력이 솟아납니다.',
      details: [
        '1. 귓볼과 귓바퀴를 엄지와 검지로 잡고 위, 옆, 아래로 지긋이 당깁니다.',
        '2. 귀 전체를 손바닥으로 감싸 앞뒤로 20회 부드럽게 비벼 열을 냅니다.',
        '3. 온몸에 혈액순환이 돌며 피로가 싹 풀리고 활력이 살아납니다.',
      ],
      shareCardText: "👂 [면역력 쑥쑥 1분 귀 마사지]\n귀를 위아래로 당기고 조물조물 비벼보세요! 전신 피로가 풀리고 면역력이 쑥 올라갑니다 🌟",
    ),
  ];

  List<HealthTip> get _filteredTips {
    if (_selectedCategory == '전체') return _healthTips;
    return _healthTips.where((tip) => tip.category == _selectedCategory).toList();
  }

  Future<void> _shareTipDirectly(HealthTip tip) async {
    HapticFeedback.mediumImpact();
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
                '🌸 마음카드',
                style: GoogleFonts.jua(fontSize: 20, color: Colors.white.withAlpha(220)),
              ),
            ],
          ),
        ),
      );

      // iOS 및 안드로이드 공용 임시 파일 생성
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/health_tip.png').create();
      await imagePath.writeAsBytes(imageBytes);

      if (!mounted) return;

      // 전송 전 완벽하고 고급스러운 카카오톡 전송 미리보기 팝업 노출
      await SharePreviewDialog.show(
        context: context,
        type: SharePreviewType.health,
        title: tip.title,
        content: tip.shareCardText,
        emoji: tip.icon,
        fullShareText: '${tip.shareCardText}\n\n'
            '━━━━━━━━━━━━━━━\n'
            '🌿 매일 아침 건강정보 & 마음카드 받기\n'
            '👉 https://play.google.com/store/apps/details?id=com.sintong.good_morning',
        imageBytes: imageBytes,
        imageFilePath: imagePath.path,
        onCustomizeCard: widget.onShareAsCard != null
            ? () => widget.onShareAsCard!(tip.shareCardText)
            : null,
      );
    } catch (e) {
      debugPrint('Error sharing health tip: $e');
    }
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
        centerTitle: false,
        actions: [
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
      body: Column(
        children: [
          // Category Filter Tabs
          Container(
            color: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFFFFDF9),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['전체', '혈관/혈당', '관절/운동', '두뇌/치매', '식습관/수분', '생활/활력'].map((cat) {
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
                              : (isDark ? Colors.grey.shade200 : const Color(0xFF4E342E)),
                        ),
                      ),
                      selectedColor: const Color(0xFF2E7D32),
                      backgroundColor: isDark ? const Color(0xFF262636) : const Color(0xFFEFEBE0),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? Colors.white10 : const Color(0x1F8D6E63)),
                      ),
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
                  elevation: 2,
                  shadowColor: isDark ? Colors.black54 : const Color(0x338D6E63),
                  margin: const EdgeInsets.only(bottom: 14),
                  color: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFFFFDF9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? Colors.white12 : const Color(0x1F8D6E63),
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      shape: const RoundedRectangleBorder(
                        side: BorderSide.none,
                      ),
                      collapsedShape: const RoundedRectangleBorder(
                        side: BorderSide.none,
                      ),
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
                                      child: Container(
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(24),
                                          color: isDark ? const Color(0xFF2C2220) : const Color(0xFFFFEDE2),
                                          border: Border.all(
                                            color: isDark ? const Color(0xFF5D4037) : const Color(0xFFFFCCBC),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            widget.onShareAsCard!(tip.shareCardText);
                                          },
                                          borderRadius: BorderRadius.circular(24),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.style, color: Color(0xFFD84315), size: 18),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '카드로 꾸미기',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: isDark ? const Color(0xFFFFAB91) : const Color(0xFFBF360C),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (widget.onShareAsCard != null) const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        color: const Color(0xFFFEE500),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          _shareTipDirectly(tip);
                                        },
                                        borderRadius: BorderRadius.circular(24),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.share_rounded, color: Colors.black87, size: 18),
                                              SizedBox(width: 6),
                                              Text(
                                                '카톡 공유',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
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
                      ],
                    ),
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
