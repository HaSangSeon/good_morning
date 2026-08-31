import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ad_service.dart';
import '../services/theme_service.dart';

class WisdomItem {
  final String id;
  final String title;
  final String content;
  final String author;
  final String category;
  final String emoji;
  final List<String> tags;

  const WisdomItem({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.category,
    required this.emoji,
    required this.tags,
  });

  String get shareText =>
      '$emoji $title\n\n$content\n\n- $author -\n\n🌸 오늘도 당신의 하루가 봄날처럼 따뜻하길 바랍니다 🌿\n\n━━━━━━━━━━━━━━━\n🌸 감동 좋은글 & 아침카드 무료 앱\n👉 https://play.google.com/store/apps/details?id=com.sintong.good_morning';
}

class WisdomScreen extends StatefulWidget {
  final Function(String cardText)? onShareAsCard;

  const WisdomScreen({super.key, this.onShareAsCard});

  @override
  State<WisdomScreen> createState() => _WisdomScreenState();
}

class _WisdomScreenState extends State<WisdomScreen> {
  String _selectedCategory = '전체';
  final Set<String> _likedIds = {};

  final List<String> _categories = [
    '전체',
    '❤️ 찜한 명언',
    '🌅 아침·희망',
    '🌿 삶의 지혜',
    '💖 위로·응원',
    '🤝 인연·우정',
    '🧘 마음비움·평화',
    '📜 명사 명언',
  ];

  @override
  void initState() {
    super.initState();
    _loadLikedIds();
  }

  Future<void> _loadLikedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('liked_wisdom_ids');
      if (list != null) {
        setState(() {
          _likedIds.addAll(list);
        });
      }
    } catch (e) {
      debugPrint('Error loading liked wisdoms: $e');
    }
  }

  Future<void> _saveLikedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('liked_wisdom_ids', _likedIds.toList());
    } catch (e) {
      debugPrint('Error saving liked wisdoms: $e');
    }
  }

  static const List<WisdomItem> _wisdomList = [
    // 🌅 아침·희망
    WisdomItem(
      id: 'w1',
      title: '오늘이라는 눈부신 선물',
      content: '어제는 지나간 역사이고,\n내일은 알 수 없는 신비이며,\n오늘은 우리에게 주어진 가장 눈부신 선물입니다.\n\n오늘 하루를 온 마음으로 감사하며\n활짝 웃는 하루 보내세요.',
      author: '엘리너 루스벨트',
      category: '🌅 아침·희망',
      emoji: '🎁',
      tags: ['#아침인사', '#감사', '#오늘의선물'],
    ),
    WisdomItem(
      id: 'w2',
      title: '행복의 문을 여는 아침',
      content: '행복은 거창한 곳에 있지 않습니다.\n아침에 눈을 떴을 때 반겨주는 햇살,\n따뜻한 차 한 잔의 온기,\n사랑하는 이의 다정한 안부 속에 있습니다.\n\n오늘도 소소한 행복이 가득하시길 바랍니다.',
      author: '좋은 생각',
      category: '🌅 아침·희망',
      emoji: '☀️',
      tags: ['#소소한행복', '#아침햇살', '#희망'],
    ),
    WisdomItem(
      id: 'w3',
      title: '자세히 보아야 예쁘다',
      content: '자세히 보아야 예쁘다\n오래 보아야 사랑스럽다\n너도 그렇다.\n\n오늘 하루도 당신 스스로를\n세상에서 가장 귀하게 여겨주세요.',
      author: '나태주 시인 - 풀꽃',
      category: '🌅 아침·희망',
      emoji: '🌸',
      tags: ['#풀꽃', '#나태주', '#자존감'],
    ),
    WisdomItem(
      id: 'w4',
      title: '아침의 첫 생각',
      content: '아침에 눈을 뜨며 하는 첫 생각이\n그날 하루 전체의 향기를 결정합니다.\n\n"오늘도 참 좋은 날이다!"라는\n긍정의 주문으로 활기차게 시작해 보세요.',
      author: '마음의 숲',
      category: '🌅 아침·희망',
      emoji: '🕊️',
      tags: ['#긍정', '#좋은하루', '#활기찬아침'],
    ),
    WisdomItem(
      id: 'w5',
      title: '봄날 같은 당신에게',
      content: '겨울이 지나면 반드시 봄이 오듯,\n어려운 시간 뒤에는 반드시 따뜻한 날이 찾아옵니다.\n\n당신의 발걸음 닿는 곳마다\n향기로운 꽃길만 펼쳐지길 축복합니다.',
      author: '따뜻한 하루',
      category: '🌅 아침·희망',
      emoji: '🌷',
      tags: ['#꽃길', '#축복', '#응원'],
    ),

    // 🌿 삶의 지혜
    WisdomItem(
      id: 'w6',
      title: '나이 듦의 아름다움',
      content: '젊음은 자연의 선물이지만,\n아름다운 노년은 예술 작품입니다.\n\n세월이 새겨놓은 주름 속에\n온화한 미소와 너그러운 지혜를 담아가는\n멋진 당신을 응원합니다.',
      author: '괴테',
      category: '🌿 삶의 지혜',
      emoji: '🍁',
      tags: ['#인생지혜', '#품격', '#아름다운노년'],
    ),
    WisdomItem(
      id: 'w7',
      title: '흘러가는 강물처럼',
      content: '강물은 바위에 부딪혀도 결코 다투지 않고\n스스로 굽이쳐 돌아 바다로 향합니다.\n\n삶의 고난 앞에서도 유연하게 흐르는\n지혜롭고 평온한 하루가 되기를 소망합니다.',
      author: '노자 (도덕경)',
      category: '🌿 삶의 지혜',
      emoji: '🌊',
      tags: ['#상선약수', '#지혜', '#평온'],
    ),
    WisdomItem(
      id: 'w8',
      title: '가장 소중한 세 가지',
      content: '인생에서 다시 돌아오지 않는 세 가지는\n흘러간 시간, 내뱉은 말, 놓쳐버린 기회입니다.\n\n그리고 가장 소중한 세 가지는\n정직, 건강, 그리고 내 곁의 사람입니다.',
      author: '인생 명언',
      category: '🌿 삶의 지혜',
      emoji: '⏳',
      tags: ['#인생훈', '#소중한것', '#시간'],
    ),
    WisdomItem(
      id: 'w9',
      title: '작은 것에 감사할 때',
      content: '작은 것에 감사하지 않는 사람은\n큰 것을 얻어도 결코 행복할 수 없습니다.\n\n오늘 숨 쉬는 공기, 걷는 건강,\n함께 나눌 이웃이 있음에 감사하는 부유한 마음이 되세요.',
      author: '탈무드',
      category: '🌿 삶의 지혜',
      emoji: '🌾',
      tags: ['#감사', '#탈무드', '#풍요'],
    ),
    WisdomItem(
      id: 'w10',
      title: '비교하지 않는 삶',
      content: '장미꽃은 들꽃을 부러워하지 않고,\n소나무는 대나무의 곧음을 질투하지 않습니다.\n\n각자의 계절에 저마다의 모습으로 피어나는 것,\n그것이 바로 참된 인생의 멋입니다.',
      author: '법정 스님',
      category: '🌿 삶의 지혜',
      emoji: '🌲',
      tags: ['#법정스님', '#무소유', '#자존감'],
    ),

    // 💖 위로·응원
    WisdomItem(
      id: 'w11',
      title: '수고 많았습니다, 내 마음',
      content: '남을 챙기느라 정작 나 자신은\n돌보지 못하고 살아오진 않았나요?\n\n오늘만큼은 "그동안 참 애썼다, 고맙다"며\n따뜻하게 내 어깨를 토닥여 주세요.',
      author: '힐링 에세이',
      category: '💖 위로·응원',
      emoji: '☕',
      tags: ['#위로', '#토닥토닥', '#힐링'],
    ),
    WisdomItem(
      id: 'w12',
      title: '잠시 쉬어가도 괜찮습니다',
      content: '숨이 찰 때는 잠시 멈추어 서서\n푸른 하늘을 바라보세요.\n\n쉬어가는 것은 멈추는 것이 아니라,\n더 멀리 나아가기 위한 아름다운 쉼표입니다.',
      author: '혜민 스님',
      category: '💖 위로·응원',
      emoji: '🌤️',
      tags: ['#쉼표', '#혜민스님', '#여유'],
    ),
    WisdomItem(
      id: 'w13',
      title: '흔들리지 않고 피는 꽃이 어디 있으랴',
      content: '흔들리지 않고 피는 꽃이 어디 있으랴\n이 세상 그 어떤 아름다운 꽃들도\n다 흔들리면서 피었나니...\n\n지금의 시련도 더 아름답게 피어나기 위한 과정입니다.',
      author: '도종환 시인',
      category: '💖 위로·응원',
      emoji: '🌼',
      tags: ['#도종환', '#희망', '#시련극복'],
    ),
    WisdomItem(
      id: 'w14',
      title: '당신은 생각보다 강한 사람',
      content: '우리는 지나온 수많은 비바람을\n이미 꿋꿋하게 이겨내고 이 자리에 있습니다.\n\n어떤 파도가 밀려와도\n당신은 슬기롭게 헤쳐 나갈 수 있습니다.',
      author: '마음 편지',
      category: '💖 위로·응원',
      emoji: '💪',
      tags: ['#용기', '#응원', '#자신감'],
    ),
    WisdomItem(
      id: 'w15',
      title: '따뜻한 말 한마디의 힘',
      content: '추운 겨울날 피어오르는 온기처럼,\n진심 어린 따뜻한 말 한마디는\n지친 누군가의 하루를 살리는 보약이 됩니다.\n\n"오늘도 힘내세요, 늘 고맙습니다."',
      author: '사랑의 편지',
      category: '💖 위로·응원',
      emoji: '💌',
      tags: ['#다정한말', '#따뜻한위로', '#안부'],
    ),

    // 🤝 인연·우정
    WisdomItem(
      id: 'w16',
      title: '익어가는 인연의 향기',
      content: '좋은 사람은 오래될수록\n잘 익은 포도주처럼 깊은 향기를 냅니다.\n\n바쁜 세상 속에서도 서로의 안부를 묻고\n늘 건강을 빌어주는 당신이 있어 참 고맙습니다.',
      author: '우정 에세이',
      category: '🤝 인연·우정',
      emoji: '🍷',
      tags: ['#좋은인연', '#오랜친구', '#감사'],
    ),
    WisdomItem(
      id: 'w17',
      title: '마주 보는 거울처럼',
      content: '내가 먼저 미소를 지으면\n상대방도 미소를 짓고,\n내가 먼저 베풀면 따뜻함이 돌아옵니다.\n\n오늘 만나는 모든 인연들에게\n먼저 다정한 미소를 건네보세요.',
      author: '인간관계의 지혜',
      category: '🤝 인연·우정',
      emoji: '🪞',
      tags: ['#미소', '#배려', '#좋은관계'],
    ),
    WisdomItem(
      id: 'w18',
      title: '함께 걷는 길',
      content: '빨리 가려면 혼자 가고,\n멀리 가려면 함께 가라.\n\n인생이라는 긴 여정 속에서\n함께 발맞추어 걸어갈 수 있는\n소중한 벗이 있음에 진심으로 감사합니다.',
      author: '아프리카 속담',
      category: '🤝 인연·우정',
      emoji: '👣',
      tags: ['#동행', '#친구', '#소중한사람'],
    ),
    WisdomItem(
      id: 'w19',
      title: '말없이 통하는 마음',
      content: '굳이 많은 말을 하지 않아도\n눈빛 하나, 손짓 하나로\n서로의 마음을 알아주는 친구가 있다면\n그 인생은 참으로 성공한 인생입니다.',
      author: '우정의 길',
      category: '🤝 인연·우정',
      emoji: '🤝',
      tags: ['#진정한친구', '#이심전심', '#우정'],
    ),
    WisdomItem(
      id: 'w20',
      title: '인연을 대하는 태도',
      content: '스쳐 지나가는 인연에도 감사하고,\n곁에 머무는 인연에는 정성을 다해야 합니다.\n\n한 번 맺은 소중한 인연의 끈을\n따뜻한 마음으로 곱게 이어가시길 바랍니다.',
      author: '이해인 수녀',
      category: '🤝 인연·우정',
      emoji: '🌿',
      tags: ['#이해인', '#소중한인연', '#정성'],
    ),

    // 🧘 마음비움·평화
    WisdomItem(
      id: 'w21',
      title: '비워야 비로소 채워진다',
      content: '가득 찬 찻잔에는\n새로운 차를 따를 수 없듯이,\n욕심과 집착을 내려놓아야\n비로소 참된 평화와 행복이 깃듭니다.',
      author: '법륜 스님',
      category: '🧘 마음비움·평화',
      emoji: '🍵',
      tags: ['#법륜스님', '#마음비움', '#행복'],
    ),
    WisdomItem(
      id: 'w22',
      title: '바람이 분다고 흔들리지 마라',
      content: '바람이 불어 나무가 흔들려도\n뿌리가 깊은 나무는 결코 뽑히지 않습니다.\n\n세상의 시끄러운 소리에 흔들리지 말고\n내 마음의 고요한 평화를 지켜내세요.',
      author: '명상록',
      category: '🧘 마음비움·평화',
      emoji: '🌳',
      tags: ['#평정심', '#내면의평화', '#뿌리깊은나무'],
    ),
    WisdomItem(
      id: 'w23',
      title: '용서라는 가장 큰 선물',
      content: '누군가를 미워하는 마음은\n내 가슴속에 뜨거운 숯을 품고 있는 것과 같습니다.\n\n상대를 위해서가 아니라\n내 자신의 평화로운 삶을 위해\n너그럽게 용서하고 훌훌 털어버리세요.',
      author: '달라이 라마',
      category: '🧘 마음비움·평화',
      emoji: '🕊️',
      tags: ['#용서', '#마음치유', '#달라이라마'],
    ),
    WisdomItem(
      id: 'w24',
      title: '흘러가는 구름을 보며',
      content: '하늘의 흰 구름은 모양을 고집하지 않고\n바람 부는 대로 흘러가며 온 하늘을 품습니다.\n\n내 생각과 고집을 조금만 내려놓으면\n세상 모든 것이 한결 편안해집니다.',
      author: '선묵혜자 스님',
      category: '🧘 마음비움·평화',
      emoji: '☁️',
      tags: ['#무심', '#자유', '#편안함'],
    ),
    WisdomItem(
      id: 'w25',
      title: '가장 고요한 순간',
      content: '하루에 단 5분만이라도\n모든 걱정과 스마트폰을 내려놓고\n조용히 눈을 감고 깊은 숨을 쉬어보세요.\n\n내 안의 맑은 샘물이 다시 솟아오릅니다.',
      author: '마음 쉼터',
      category: '🧘 마음비움·평화',
      emoji: '🕯️',
      tags: ['#명상', '#심호흡', '#휴식'],
    ),

    // 📜 명사 명언
    WisdomItem(
      id: 'w26',
      title: '빛을 퍼뜨리는 두 가지 방법',
      content: '어둠 속에서 빛을 퍼뜨리는 방법은 두 가지가 있다.\n촛불 자체가 되거나,\n그 빛을 반사하는 거울이 되는 것이다.',
      author: '이디스 워튼',
      category: '📜 명사 명언',
      emoji: '✨',
      tags: ['#명언', '#선한영향력', '#희망'],
    ),
    WisdomItem(
      id: 'w27',
      title: '가장 아름다운 날',
      content: '당신의 인생에서 가장 아름다운 날들은\n아직 살지 않은 날들 속에 있습니다.\n\n나이와 상관없이 매일 새로운 꿈을 품고\n설레는 가슴으로 오늘을 살아가세요.',
      author: '나짐 히크메트',
      category: '📜 명사 명언',
      emoji: '🌟',
      tags: ['#꿈', '#설렘', '#아름다운날'],
    ),
    WisdomItem(
      id: 'w28',
      title: '감사의 기적',
      content: '감사는 과거를 풍요롭게 하고,\n오늘에 평화를 가져다주며,\n내일을 위한 밝은 비전을 창조합니다.',
      author: '멜로디 비티',
      category: '📜 명사 명언',
      emoji: '💖',
      tags: ['#감사', '#기적', '#평화'],
    ),
    WisdomItem(
      id: 'w29',
      title: '미소는 가장 위대한 언어',
      content: '우리가 웃을 때 세상도 함께 웃고,\n우리가 울 때 세상은 나 혼자 울게 내버려 둔다.\n\n주변을 밝히는 따뜻한 미소 하나로\n오늘 하루를 환하게 채워보세요.',
      author: '엘라 휠러 윌콕스',
      category: '📜 명사 명언',
      emoji: '😊',
      tags: ['#미소', '#웃음', '#긍정의힘'],
    ),
    WisdomItem(
      id: 'w30',
      title: '행복의 비밀',
      content: '행복이란 내가 원하는 것을 갖는 것이 아니라,\n내가 이미 가지고 있는 것을 진심으로 사랑하는 것이다.',
      author: '하이먼 스카트',
      category: '📜 명사 명언',
      emoji: '🏡',
      tags: ['#행복의비밀', '#만족', '#사랑'],
    ),

    // 🌅 아침·희망 (추가)
    WisdomItem(
      id: 'w31',
      title: '오늘이라는 하얀 도화지',
      content: '오늘 아침 눈을 뜬 당신에게\n새하얀 도화지 한 장이 선물로 주어졌습니다.\n\n근심과 걱정은 지우고,\n기쁨과 미소로 가장 아름다운 하루를 그려보세요.',
      author: '희망 편지',
      category: '🌅 아침·희망',
      emoji: '🎨',
      tags: ['#새아침', '#기쁨', '#하루시작'],
    ),
    WisdomItem(
      id: 'w32',
      title: '맑은 아침 공기처럼',
      content: '새벽을 깨우는 상쾌한 아침 공기처럼\n오늘 당신의 마음에도 맑고 향기로운 바람이 불어오길 바랍니다.\n\n건강하고 활기찬 발걸음으로 시작하세요.',
      author: '아침의 묵상',
      category: '🌅 아침·희망',
      emoji: '🍃',
      tags: ['#상쾌한아침', '#건강', '#활기'],
    ),
    WisdomItem(
      id: 'w33',
      title: '빛나는 당신의 하루',
      content: '태양이 온 세상을 따뜻하게 비추듯,\n당신의 온화한 미소는 주변을 환하게 밝힙니다.\n\n오늘도 당신은 세상에서 가장 소중하고 빛나는 존재입니다.',
      author: '따뜻한 하루',
      category: '🌅 아침·희망',
      emoji: '☀️',
      tags: ['#소중한존재', '#자존감', '#축복'],
    ),
    WisdomItem(
      id: 'w34',
      title: '마음의 꽃길',
      content: '아름다운 생각을 품으면 마음에 꽃이 피고,\n고운 말을 건네면 세상에 향기가 번집니다.\n\n오늘 하루도 고운 꽃길만 밟고 걸어가세요.',
      author: '마음의 정원',
      category: '🌅 아침·희망',
      emoji: '🌺',
      tags: ['#꽃길', '#고운말', '#마음정원'],
    ),
    WisdomItem(
      id: 'w35',
      title: '기적 같은 매일',
      content: '살아 숨 쉬며 사랑하는 사람들과\n안부를 나눌 수 있는 오늘 하루가\n인생에서 가장 큰 기적이자 축복입니다.',
      author: '감사 묵상집',
      category: '🌅 아침·희망',
      emoji: '✨',
      tags: ['#기적', '#감사', '#하루의축복'],
    ),

    // 🌿 삶의 지혜 (추가)
    WisdomItem(
      id: 'w36',
      title: '물처럼 살아가는 삶 (상선약수)',
      content: '가장 좋은 삶은 물과 같습니다.\n물은 만물을 이롭게 하면서도 다투지 않고,\n모두가 싫어하는 가장 낮은 곳으로 흐릅니다.\n\n겸손과 배려가 깃든 지혜로운 하루 되세요.',
      author: '노자 (도덕경)',
      category: '🌿 삶의 지혜',
      emoji: '💧',
      tags: ['#상선약수', '#겸손', '#도덕경'],
    ),
    WisdomItem(
      id: 'w37',
      title: '우리는 늙어가는 것이 아니라',
      content: '우리는 늙어가는 것이 아니라,\n조금씩 곱게 익어가는 것입니다.\n\n세월의 깊이만큼 더 너그럽고 아름다워지는\n당신의 오늘을 진심으로 축복합니다.',
      author: '김종환 - 바램',
      category: '🌿 삶의 지혜',
      emoji: '🍇',
      tags: ['#익어가는것', '#아름다운황혼', '#품격'],
    ),
    WisdomItem(
      id: 'w38',
      title: '말 한마디의 무게',
      content: '말은 마음의 거울이며 인격의 향기입니다.\n칼로 입은 상처는 아물지만,\n말로 입은 상처는 평생을 갑니다.\n\n오늘도 다정하고 부드러운 말로 온기를 나누세요.',
      author: '명심보감',
      category: '🌿 삶의 지혜',
      emoji: '🗣️',
      tags: ['#명심보감', '#고운말', '#인격'],
    ),
    WisdomItem(
      id: 'w39',
      title: '진정한 마음의 부자',
      content: '많이 가진 사람이 부자가 아니라,\n가진 것에 만족하고 남에게 베풀 줄 아는 사람이\n세상에서 가장 큰 부자입니다.',
      author: '에리히 프롬',
      category: '🌿 삶의 지혜',
      emoji: '💎',
      tags: ['#만족', '#베풂', '#마음부자'],
    ),
    WisdomItem(
      id: 'w40',
      title: '천천히 걸어가는 여유',
      content: '인생은 속도가 아니라 방향입니다.\n남들과 비교하며 조급해하지 말고,\n내 발걸음에 맞추어 주변의 풍경을 즐기며 걸어가세요.',
      author: '인생의 나침반',
      category: '🌿 삶의 지혜',
      emoji: '🚶',
      tags: ['#느림의미학', '#여유', '#인생나침반'],
    ),

    // 💖 위로·응원 (추가)
    WisdomItem(
      id: 'w41',
      title: '먹구름 뒤의 푸른 하늘',
      content: '아무리 짙은 먹구름이 하늘을 가려도\n그 뒤에는 여전히 눈부신 태양과 푸른 하늘이 기다리고 있습니다.\n\n힘든 순간도 곧 지나갈 테니 힘내세요!',
      author: '희망의 노래',
      category: '💖 위로·응원',
      emoji: '⛅',
      tags: ['#위로', '#희망', '#시련극복'],
    ),
    WisdomItem(
      id: 'w42',
      title: '당신이 걸어온 고귀한 길',
      content: '가족을 위해, 자식을 위해\n평생 묵묵히 헌신해 오신 당신의 거친 손과 발은\n이 세상 그 무엇보다 숭고하고 아름답습니다.',
      author: '부모님의 은혜',
      category: '💖 위로·응원',
      emoji: '🤲',
      tags: ['#부모님', '#헌신', '#존경'],
    ),
    WisdomItem(
      id: 'w43',
      title: '괜찮아요, 다 잘될 겁니다',
      content: '마음이 지치고 무거울 때는\n억지로 힘내려 애쓰지 마세요.\n\n"지금까지도 잘해왔으니, 앞으로도 다 잘될 거야"\n스스로에게 따뜻한 위로를 건네주세요.',
      author: '마음의 쉼터',
      category: '💖 위로·응원',
      emoji: '🌸',
      tags: ['#토닥토닥', '#다잘될거야', '#마음치유'],
    ),
    WisdomItem(
      id: 'w44',
      title: '마음속 꺼지지 않는 촛불',
      content: '희망이란 어두운 밤길을 밝혀주는 작은 촛불과 같습니다.\n바람이 불어도 믿음과 사랑이 있다면\n희망의 불꽃은 결코 꺼지지 않습니다.',
      author: '희망 에세이',
      category: '💖 위로·응원',
      emoji: '🕯️',
      tags: ['#희망촛불', '#용기', '#믿음'],
    ),
    WisdomItem(
      id: 'w45',
      title: '오늘 하루도 참 애썼습니다',
      content: '하루의 끝자락, 고단했던 몸과 마음을\n따뜻한 차 한 잔으로 포근하게 감싸주세요.\n\n당신이 보낸 오늘의 수고는 결코 헛되지 않습니다.',
      author: '포근한 저녁',
      category: '💖 위로·응원',
      emoji: '🍵',
      tags: ['#수고했어오늘도', '#안식', '#평안한밤'],
    ),

    // 🤝 인연·우정 (추가)
    WisdomItem(
      id: 'w46',
      title: '참 좋은 당신을 만났습니다',
      content: '나무가 숲을 이루고 꽃이 피어나듯,\n내 인생에 그늘이 되어주고 향기가 되어준\n참 좋은 당신을 만나 참 행복합니다.',
      author: '김용택 시인',
      category: '🤝 인연·우정',
      emoji: '🌳',
      tags: ['#김용택', '#참좋은당신', '#소중한사람'],
    ),
    WisdomItem(
      id: 'w47',
      title: '마음으로 전하는 다정한 안부',
      content: '돈이 드는 것도 아닌데\n가끔 전하는 "건강하시죠? 밥은 챙겨 드셨나요?"라는\n안부 한마디가 평생의 큰 힘과 위로가 됩니다.',
      author: '다정한 편지',
      category: '🤝 인연·우정',
      emoji: '💌',
      tags: ['#안부인사', '#다정함', '#마음나눔'],
    ),
    WisdomItem(
      id: 'w48',
      title: '오래된 벗의 따스함',
      content: '말하지 않아도 눈빛만으로 통하고,\n오랜만에 만나도 어제 만난 듯 편안한 친구.\n\n그런 벗이 내 곁에 단 한 사람이라도 있다면\n세상 가장 큰 복을 받은 사람입니다.',
      author: '벗에게 부치는 글',
      category: '🤝 인연·우정',
      emoji: '🤝',
      tags: ['#오랜벗', '#진정한우정', '#동행'],
    ),
    WisdomItem(
      id: 'w49',
      title: '베푸는 기쁨',
      content: '꽃을 건네는 손에는 언제나 꽃향기가 남듯이,\n남에게 사랑과 친절을 베풀면\n내 마음속에 먼저 행복의 꽃이 피어납니다.',
      author: '동양 격언',
      category: '🤝 인연·우정',
      emoji: '💐',
      tags: ['#꽃향기', '#친절', '#베풂의기쁨'],
    ),
    WisdomItem(
      id: 'w50',
      title: '귀한 인연의 끈',
      content: '수많은 사람들 중에 만나 서로를 아끼고 사랑하는 것은\n참으로 경이롭고 소중한 인연입니다.\n\n오늘도 곁에 있는 소중한 인연들에게 감사함을 전하세요.',
      author: '인연의 숲',
      category: '🤝 인연·우정',
      emoji: '🎗️',
      tags: ['#귀한인연', '#감사', '#사랑'],
    ),

    // 🧘 마음비움·평화 (추가)
    WisdomItem(
      id: 'w51',
      title: '내려놓으면 비로소 자유롭다',
      content: '움켜쥐고 있는 모래는 손가락 사이로 다 빠져나가지만,\n손바닥을 활짝 펴면 온 세상을 담을 수 있습니다.\n\n욕심을 내려놓을 때 마음은 새처럼 자유로워집니다.',
      author: '무소유의 지혜',
      category: '🧘 마음비움·평화',
      emoji: '🕊️',
      tags: ['#내려놓음', '#자유', '#평화'],
    ),
    WisdomItem(
      id: 'w52',
      title: '내 마음의 거울 닦기',
      content: '남의 허물을 탓하기 전에\n내 마음의 거울을 먼저 맑게 닦아보세요.\n\n내 마음이 맑고 고요하면\n비치는 온 세상도 아름답고 평화로워집니다.',
      author: '선가의 가르침',
      category: '🧘 마음비움·평화',
      emoji: '🪞',
      tags: ['#마음거울', '#성찰', '#내면의평화'],
    ),
    WisdomItem(
      id: 'w53',
      title: '단순하게 사는 지혜',
      content: '생각이 많으면 걱정이 늘어나고,\n마음이 복잡하면 삶이 무거워집니다.\n\n단순하게 생각하고, 단순하게 살 때\n비로소 진정한 평화와 웃음이 찾아옵니다.',
      author: '소박한 삶',
      category: '🧘 마음비움·평화',
      emoji: '🍃',
      tags: ['#단순한삶', '#마음정리', '#소박함'],
    ),
    WisdomItem(
      id: 'w54',
      title: '지금 이 순간을 살자',
      content: '어제의 후회에 얽매이지 말고,\n내일의 불안에 흔들리지 마세요.\n\n우리가 온전히 누릴 수 있는 유일한 시간은\n바로 "지금, 여기, 이 순간"뿐입니다.',
      author: '틱낫한 스님',
      category: '🧘 마음비움·평화',
      emoji: '🌿',
      tags: ['#지금이순간', '#틱낫한', '#마음챙김'],
    ),
    WisdomItem(
      id: 'w55',
      title: '바람처럼 머무름 없이',
      content: '바람은 그물을 뚫고 지나가고,\n소리는 허공에 걸리지 않습니다.\n\n세상의 온갖 시비와 분노에 걸림 없이\n바람처럼 걸림 없는 평온한 마음을 지니세요.',
      author: '숫타니파타',
      category: '🧘 마음비움·평화',
      emoji: '🌬️',
      tags: ['#숫타니파타', '#걸림없는삶', '#자유'],
    ),

    // 📜 명사 명언 (추가)
    WisdomItem(
      id: 'w56',
      title: '가슴으로 느끼는 세상',
      content: '세상에서 가장 아름답고 소중한 것은\n보이거나 만져지지 않는다.\n그것은 오직 가슴으로만 느낄 수 있다.',
      author: '헬렌 켈러',
      category: '📜 명사 명언',
      emoji: '💖',
      tags: ['#헬렌켈러', '#사랑', '#가슴으로느끼는것'],
    ),
    WisdomItem(
      id: 'w57',
      title: '사랑이 있는 곳에',
      content: '사랑이 있는 곳에 삶이 있고,\n용서가 있는 곳에 평화가 깃든다.\n\n오늘도 사랑과 친절로 세상을 따뜻하게 밝히세요.',
      author: '마하트마 간디',
      category: '📜 명사 명언',
      emoji: '🕊️',
      tags: ['#간디', '#사랑', '#평화'],
    ),
    WisdomItem(
      id: 'w58',
      title: '가장 위대한 승리',
      content: '남을 이기는 사람은 힘이 있는 자이지만,\n자기 자신을 이기는 사람은 진정으로 강한 자이다.',
      author: '노자',
      category: '📜 명사 명언',
      emoji: '🏆',
      tags: ['#자기극복', '#승리', '#노자'],
    ),
    WisdomItem(
      id: 'w59',
      title: '삶의 진정한 보람',
      content: '우리가 이 세상에 태어나 남길 수 있는 가장 큰 유산은\n내가 머물다 간 자리로 인해\n누군가의 삶이 조금이라도 더 따뜻해지는 것이다.',
      author: '랠프 월도 에머슨',
      category: '📜 명사 명언',
      emoji: '🌟',
      tags: ['#에머슨', '#보람', '#선한영향력'],
    ),
    WisdomItem(
      id: 'w60',
      title: '새로운 문이 열리리라',
      content: '하나의 문이 닫히면 다른 문이 열린다.\n하지만 우리는 닫힌 문을 너무 오래 슬퍼하느라\n우리를 위해 열려 있는 새 문을 보지 못하곤 한다.',
      author: '알렉산더 그레이엄 벨',
      category: '📜 명사 명언',
      emoji: '🚪',
      tags: ['#희망', '#새로운시작', '#긍정'],
    ),

    // 🌅 아침·희망 (확장)
    WisdomItem(
      id: 'w61',
      title: '아침의 미소',
      content: '미소는 상대방의 마음을 여는\n가장 따뜻하고 아름다운 열쇠입니다.\n\n오늘 아침 거울을 보며 활짝 웃어보세요.\n온 세상이 당신을 향해 미소 지을 것입니다.',
      author: '마음의 창',
      category: '🌅 아침·희망',
      emoji: '😊',
      tags: ['#미소', '#행복한아침', '#기쁨'],
    ),
    WisdomItem(
      id: 'w62',
      title: '오늘이라는 소중한 하루',
      content: '어제는 이미 지나간 과거이고,\n내일은 아직 오지 않은 미지의 시간입니다.\n\n오직 오늘 하루만을 온 마음으로 기뻐하며\n보람차고 후회 없는 날을 보내세요.',
      author: '하루의 소중함',
      category: '🌅 아침·희망',
      emoji: '⏳',
      tags: ['#오늘하루', '#감사', '#소중한시간'],
    ),
    WisdomItem(
      id: 'w63',
      title: '마르지 않는 기쁨의 샘',
      content: '아침에 감사하는 마음을 품으면\n하루 종일 기쁨의 샘물이 마르지 않습니다.\n\n작은 일에도 고마워하는 풍요로운 마음으로\n상쾌한 하루를 열어가세요.',
      author: '감사의 지혜',
      category: '🌅 아침·희망',
      emoji: '⛲',
      tags: ['#기쁨', '#감사기도', '#풍요'],
    ),
    WisdomItem(
      id: 'w64',
      title: '새로운 용기를 주는 태양',
      content: '매일 아침 떠오르는 붉은 태양은\n어제의 슬픔을 지우고 새로운 용기를 불어넣어 줍니다.\n\n어깨를 활짝 펴고 힘찬 하루를 시작하세요.',
      author: '희망의 아침',
      category: '🌅 아침·희망',
      emoji: '🌅',
      tags: ['#용기', '#새출발', '#활기찬아침'],
    ),
    WisdomItem(
      id: 'w65',
      title: '축복의 아침',
      content: '오늘 아침 건강하게 눈을 떠\n맑은 공기를 마실 수 있다는 것만으로도\n우리는 세상에서 가장 큰 축복을 받았습니다.',
      author: '아침 묵상',
      category: '🌅 아침·희망',
      emoji: '🕊️',
      tags: ['#축복', '#건강', '#평안'],
    ),
    WisdomItem(
      id: 'w66',
      title: '향기 나는 사람',
      content: '말씨가 고운 사람은 꽃보다 더 짙은 향기를 품고,\n마음이 따뜻한 사람은 맑은 샘물처럼 곁을 편안하게 합니다.\n\n오늘도 향기로운 하루 보내세요.',
      author: '꽃과 향기',
      category: '🌅 아침·희망',
      emoji: '🌸',
      tags: ['#인품', '#고운말', '#마음향기'],
    ),
    WisdomItem(
      id: 'w67',
      title: '아침의 다정한 기도',
      content: '오늘 하루 내가 만나는 모든 이들에게\n평안과 기쁨이 함께하기를...\n\n나의 작은 온기가 누군가에게 큰 힘이 되기를 소망합니다.',
      author: '다정한 마음',
      category: '🌅 아침·희망',
      emoji: '🙏',
      tags: ['#기도', '#평안', '#온기'],
    ),
    WisdomItem(
      id: 'w68',
      title: '웃으면 복이 옵니다',
      content: '행복해서 웃는 것이 아니라,\n웃기 때문에 행복해지는 것입니다.\n\n얼굴 가득 밝은 웃음꽃을 피우며\n기분 좋은 하루를 만들어가세요.',
      author: '소문만복래',
      category: '🌅 아침·희망',
      emoji: '😄',
      tags: ['#웃음', '#복', '#행복'],
    ),

    // 🌿 삶의 지혜 (확장)
    WisdomItem(
      id: 'w69',
      title: '역지사지(易地思之)의 지혜',
      content: '상대방의 입장에서 한 번 더 생각해보면\n이해하지 못할 일도, 용서하지 못할 사람도 없습니다.\n\n너그러운 이해와 배려가 참된 평화를 만듭니다.',
      author: '동양의 지혜',
      category: '🌿 삶의 지혜',
      emoji: '🤝',
      tags: ['#역지사지', '#배려', '#지혜'],
    ),
    WisdomItem(
      id: 'w70',
      title: '세 번 생각하고 말하라',
      content: '생각 없이 뱉은 한마디는 남의 가슴에 비수가 되고,\n정성 어린 따뜻한 한마디는 지친 영혼의 보약이 됩니다.\n\n말 한마디에도 온기를 담으세요.',
      author: '명심보감',
      category: '🌿 삶의 지혜',
      emoji: '💬',
      tags: ['#언어의온도', '#말조심', '#명심보감'],
    ),
    WisdomItem(
      id: 'w71',
      title: '바다처럼 너른 마음',
      content: '바다는 모든 강물을 마다하지 않고 다 받아들여\n비로소 깊고 푸른 바다가 되었습니다.\n\n모든 것을 포용하는 너그러운 가슴으로 살아가세요.',
      author: '장자',
      category: '🌿 삶의 지혜',
      emoji: '🌊',
      tags: ['#포용', '#바다', '#너그러움'],
    ),
    WisdomItem(
      id: 'w72',
      title: '근심을 내려놓는 법',
      content: '어차피 지나갈 일이라면 미리 걱정하지 말고,\n내가 바꿀 수 없는 일이라면 담담하게 받아들이세요.\n\n마음이 편안해야 몸도 건강해집니다.',
      author: '달라이 라마',
      category: '🌿 삶의 지혜',
      emoji: '🍃',
      tags: ['#마음편안', '#걱정비우기', '#평정심'],
    ),
    WisdomItem(
      id: 'w73',
      title: '마음의 여백',
      content: '동양화에 여백이 있어야 명화가 되듯,\n인생에도 적당한 빈틈과 쉼이 있어야 여유가 생깁니다.\n\n너무 빽빽하게 살지 말고 여유를 누리세요.',
      author: '인생 에세이',
      category: '🌿 삶의 지혜',
      emoji: '🖼️',
      tags: ['#여백의미', '#쉼', '#여유'],
    ),
    WisdomItem(
      id: 'w74',
      title: '진정한 효도와 사랑',
      content: '자식이 건강하고 바르게 살아가는 것이 부모의 기쁨이요,\n부모님이 아프지 않고 평안하신 것이 자식의 큰 복입니다.\n\n서로에게 늘 건강을 빌어주세요.',
      author: '가족의 소중함',
      category: '🌿 삶의 지혜',
      emoji: '👨‍👩‍👧‍👦',
      tags: ['#효도', '#가족사랑', '#건강'],
    ),
    WisdomItem(
      id: 'w75',
      title: '세월이 남겨준 선물',
      content: '젊음은 열정과 패기를 남겨주고,\n나이 듦은 온화한 미소와 깊은 지혜를 선물합니다.\n\n세월을 아름답게 품어 안는 당신이 참 멋집니다.',
      author: '세월의 노래',
      category: '🌿 삶의 지혜',
      emoji: '🍂',
      tags: ['#인생의멋', '#품격', '#아름다운황혼'],
    ),
    WisdomItem(
      id: 'w76',
      title: '가장 값진 인생의 보물',
      content: '세상 그 어떤 부귀영화도\n아침에 아프지 않고 일어나는 건강과 바꿀 수 없습니다.\n\n건강이 곧 최고의 재산이자 축복입니다.',
      author: '건강 명언',
      category: '🌿 삶의 지혜',
      emoji: '💪',
      tags: ['#건강최고', '#무병장수', '#행복'],
    ),

    // 💖 위로·응원 (확장)
    WisdomItem(
      id: 'w77',
      title: '당신은 언제나 최고입니다',
      content: '비록 남들이 다 알아주지 않아도,\n가족과 세상을 위해 평생을 묵묵히 헌신해 온 당신은\n세상에서 가장 존경스러운 영웅입니다.',
      author: '응원의 글',
      category: '💖 위로·응원',
      emoji: '👑',
      tags: ['#존경', '#영웅', '#최고의당신'],
    ),
    WisdomItem(
      id: 'w78',
      title: '잠시 내려놓아도 괜찮아요',
      content: '모든 짐을 혼자 짊어지려 하지 마세요.\n지치고 힘들 때는 잠시 내려놓고 깊은 숨을 쉬어보세요.\n\n당신은 충분히 잘해왔습니다.',
      author: '마음의 쉼터',
      category: '💖 위로·응원',
      emoji: '🛋️',
      tags: ['#휴식', '#토닥토닥', '#쉼'],
    ),
    WisdomItem(
      id: 'w79',
      title: '마음의 따뜻한 온돌방',
      content: '차가운 바람 부는 세상 속에서도\n가슴속 따뜻한 온돌방 하나 품고 살아가는 사람은\n어떤 시련도 넉넉히 이겨낼 수 있습니다.',
      author: '따뜻한 하루',
      category: '💖 위로·응원',
      emoji: '🔥',
      tags: ['#온기', '#시련극복', '#위로'],
    ),
    WisdomItem(
      id: 'w80',
      title: '겨울 뒤의 봄날',
      content: '매서운 칼바람이 부는 겨울도\n때가 되면 반드시 향기로운 꽃피는 봄날에 자리를 양보합니다.\n\n당신의 삶에도 곧 따스한 봄빛이 가득할 것입니다.',
      author: '봄의 희망',
      category: '💖 위로·응원',
      emoji: '🌷',
      tags: ['#봄날', '#희망', '#새봄'],
    ),
    WisdomItem(
      id: 'w81',
      title: '토닥토닥 내 하루',
      content: '오늘 하루도 수고 많았던 내 어깨를 다독이며\n"참 고생했다, 잘했다" 칭찬해 주세요.\n\n나 자신을 사랑할 때 세상도 아름다워집니다.',
      author: '나를 사랑하는 법',
      category: '💖 위로·응원',
      emoji: '🥰',
      tags: ['#자존감', '#위로', '#칭찬'],
    ),
    WisdomItem(
      id: 'w82',
      title: '작은 불씨 하나의 힘',
      content: '작은 성냥불 하나가 캄캄한 어둠을 환하게 밝히듯,\n당신의 따뜻한 온기 하나가\n주변 사람들의 마음을 따뜻하게 녹여줍니다.',
      author: '선한 영향력',
      category: '💖 위로·응원',
      emoji: '🕯️',
      tags: ['#희망', '#빛', '#따뜻함'],
    ),
    WisdomItem(
      id: 'w83',
      title: '세상에 단 하나뿐인 당신',
      content: '우주 수천억 개의 별들 중에서도\n당신이라는 별은 오직 하나뿐인 귀하고 특별한 존재입니다.\n\n오늘도 당신의 빛을 잃지 마세요.',
      author: '소중한 당신에게',
      category: '💖 위로·응원',
      emoji: '⭐',
      tags: ['#특별한존재', '#소중함', '#빛나는별'],
    ),
    WisdomItem(
      id: 'w84',
      title: '내일의 밝은 태양',
      content: '오늘의 아쉬움과 실수는 저무는 노을에 실어 보내고,\n내일 아침 떠오를 눈부신 새 태양을 기쁨으로 맞이하세요.',
      author: '새날의 희망',
      category: '💖 위로·응원',
      emoji: '🌄',
      tags: ['#새날', '#노을', '#희망'],
    ),

    // 🤝 인연·우정 (확장)
    WisdomItem(
      id: 'w85',
      title: '아름다운 동행',
      content: '혼자 가면 외롭지만 함께 가면 정답고,\n손을 잡고 발맞추어 걸어갈 때 인생길은 꽃길이 됩니다.\n\n당신과 함께 걷는 이 길이 참 행복합니다.',
      author: '동행의 기쁨',
      category: '🤝 인연·우정',
      emoji: '👫',
      tags: ['#동행', '#함께하는길', '#행복'],
    ),
    WisdomItem(
      id: 'w86',
      title: '가슴에 남는 인연',
      content: '스쳐 지나가는 수많은 만남 속에서도\n오래도록 가슴에 은은한 국화 향처럼 남는 사람이 있습니다.\n\n당신이 바로 그런 사람입니다.',
      author: '인연의 향기',
      category: '🤝 인연·우정',
      emoji: '🌼',
      tags: ['#국화향', '#은은한인연', '#고마운사람'],
    ),
    WisdomItem(
      id: 'w87',
      title: '다정한 눈빛 하나',
      content: '백 마디 화려한 말보다\n가만히 손을 잡아주는 온기,\n따뜻하게 바라보는 눈빛 하나가 영혼을 치유합니다.',
      author: '마음의 대화',
      category: '🤝 인연·우정',
      emoji: '👀',
      tags: ['#눈빛', '#온기', '#치유'],
    ),
    WisdomItem(
      id: 'w88',
      title: '오래된 벗과 차 한 잔',
      content: '오랜 세월을 함께 나눈 벗과 마주 앉아\n따뜻한 차 한 잔 나누며 웃을 수 있는 삶,\n이것이 바로 인생의 가장 큰 복입니다.',
      author: '벗과의 차 한 잔',
      category: '🤝 인연·우정',
      emoji: '🍵',
      tags: ['#차한잔', '#오랜벗', '#행복한시간'],
    ),
    WisdomItem(
      id: 'w89',
      title: '마음의 고향 같은 사람',
      content: '언제 찾아가도 반갑게 문을 열어주고,\n아무런 조건 없이 내 편이 되어주는 사람.\n\n서로에게 그런 포근한 고향이 되어줍시다.',
      author: '마음의 고향',
      category: '🤝 인연·우정',
      emoji: '🏡',
      tags: ['#내편', '#포근한고향', '#인연'],
    ),
    WisdomItem(
      id: 'w90',
      title: '은혜를 돌에 새기라',
      content: '남에게 베푼 은혜는 흐르는 강물에 흘려보내고,\n남에게 받은 은혜는 가슴속 깊은 돌에 새기세요.\n\n감사하는 마음에 행복이 깃듭니다.',
      author: '동양 격언',
      category: '🤝 인연·우정',
      emoji: '🪨',
      tags: ['#은혜', '#감사', '#인격'],
    ),
    WisdomItem(
      id: 'w91',
      title: '인연을 가꾸는 정성',
      content: '화분에 정성껏 물을 주어야 꽃이 피듯,\n인연에도 따뜻한 안부와 관심을 기울여야 사랑이 자랍니다.\n\n오늘도 다정한 안부를 건네보세요.',
      author: '사랑의 정원',
      category: '🤝 인연·우정',
      emoji: '🌱',
      tags: ['#안부전하기', '#정성', '#인연가꾸기'],
    ),
    WisdomItem(
      id: 'w92',
      title: '참된 친구의 조건',
      content: '기쁠 때 함께 기뻐해 주는 친구도 좋지만,\n내가 힘들고 슬플 때 곁을 묵묵히 지켜주는 친구야말로\n하늘이 보내준 보물입니다.',
      author: '우정 묵상',
      category: '🤝 인연·우정',
      emoji: '💎',
      tags: ['#진정한친구', '#보물', '#우정'],
    ),

    // 🧘 마음비움·평화 & 📜 명사 명언 (확장)
    WisdomItem(
      id: 'w93',
      title: '비워야 채워지는 평화',
      content: '마음의 욕심과 집착을 비워내면\n그 빈자리에 고요한 평화와 감사함이 차오릅니다.\n\n단순하고 맑은 마음으로 오늘을 살아가세요.',
      author: '법정 스님',
      category: '🧘 마음비움·평화',
      emoji: '🕊️',
      tags: ['#법정스님', '#무소유', '#마음비움'],
    ),
    WisdomItem(
      id: 'w94',
      title: '자연을 닮아가는 삶',
      content: '봄에 싹트고 여름에 무성하며 가을에 낙엽을 떨구는 나무처럼,\n자연의 순리에 순응하며 흘러가는 삶이\n가장 평화롭고 아름다운 삶입니다.',
      author: '자연의 섭리',
      category: '🧘 마음비움·평화',
      emoji: '🌲',
      tags: ['#순리', '#자연', '#평화로운삶'],
    ),
    WisdomItem(
      id: 'w95',
      title: '고요함 속의 맑은 지혜',
      content: '물이 맑고 고요해야 강바닥의 조약돌이 보이듯,\n마음이 번뇌 없이 고요해야 지혜의 눈이 열립니다.\n\n마음의 호수를 잔잔하게 가꾸세요.',
      author: '선가의 지혜',
      category: '🧘 마음비움·평화',
      emoji: '🧘',
      tags: ['#명상', '#고요함', '#지혜'],
    ),
    WisdomItem(
      id: 'w96',
      title: '행복은 내 안에 있다',
      content: '행복은 외부의 환경에 있는 것이 아니라\n내 마음이 세상을 어떻게 바라보느냐에 달려 있습니다.',
      author: '아리스토텔레스',
      category: '📜 명사 명언',
      emoji: '🏛️',
      tags: ['#아리스토텔레스', '#행복의조건', '#철학'],
    ),
    WisdomItem(
      id: 'w97',
      title: '가장 소중한 세 가지',
      content: '가장 소중한 시간은 바로 "지금"이고,\n가장 소중한 사람은 "지금 내 곁에 있는 사람"이며,\n가장 중요한 일은 "그 사람에게 선을 베푸는 것"이다.',
      author: '레프 톨스토이',
      category: '📜 명사 명언',
      emoji: '📖',
      tags: ['#톨스토이', '#인생의세가지', '#지금이순간'],
    ),
    WisdomItem(
      id: 'w98',
      title: '삶이 있는 한 희망은 있다',
      content: '숨을 쉬고 살아있는 한\n우리의 가슴속에 희망은 결코 잠들지 않는다.\n\n어떤 순간에도 용기를 잃지 마세요.',
      author: '키케로',
      category: '📜 명사 명언',
      emoji: '🔥',
      tags: ['#키케로', '#영원한희망', '#용기'],
    ),
    WisdomItem(
      id: 'w99',
      title: '위대한 사랑으로 작은 일을',
      content: '우리가 세상에서 위대한 일을 다 할 수는 없지만,\n위대한 사랑을 담아 작은 일들을 실천할 수는 있습니다.',
      author: '마더 테레사',
      category: '📜 명사 명언',
      emoji: '💖',
      tags: ['#테레사수녀', '#사랑의실천', '#친절'],
    ),
    WisdomItem(
      id: 'w100',
      title: '인생의 참맛',
      content: '눈물 젖은 빵을 먹어보지 않은 사람은 인생의 참맛을 알지 못하고,\n고난의 밤을 지새워보지 않은 사람은 새벽의 눈부심을 알지 못한다.',
      author: '요한 볼프강 폰 괴테',
      category: '📜 명사 명언',
      emoji: '🏆',
      tags: ['#괴테', '#인생의참맛', '#시련의가치'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredList = _selectedCategory == '전체'
        ? _wisdomList
        : _selectedCategory == '❤️ 찜한 명언'
            ? _wisdomList.where((item) => _likedIds.contains(item.id)).toList()
            : _wisdomList.where((item) => item.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF141724) : const Color(0xFFFAF7F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1B1B2F), const Color(0xFF2C1938), const Color(0xFF381A40)]
                  : [const Color(0xFFC0392B), const Color(0xFFD35400), const Color(0xFFE67E22)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_stories_rounded, color: Color(0xFFFFD700), size: 24),
            const SizedBox(width: 8),
            Text(
              '좋은글 & 명언',
              style: GoogleFonts.jua(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          // 내가 찜한 명언 모아보기 바로가기 버튼
          IconButton(
            icon: Icon(
              _selectedCategory == '❤️ 찜한 명언'
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _selectedCategory == '❤️ 찜한 명언'
                  ? const Color(0xFFFF4081)
                  : const Color(0xFFFFD700),
              size: 24,
            ),
            tooltip: _selectedCategory == '❤️ 찜한 명언' ? '전체 명언 보기' : '내가 찜한 명언 모아보기',
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (_selectedCategory == '❤️ 찜한 명언') {
                  _selectedCategory = '전체';
                } else {
                  _selectedCategory = '❤️ 찜한 명언';
                }
              });
            },
          ),
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
        ],
      ),
      body: Column(
        children: [
          // 1. Category Filter Chips (Horizontal Scroll)
          Container(
            color: isDark ? const Color(0xFF1E2234) : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFFC5CCE0) : const Color(0xFF5D4037)),
                        ),
                      ),
                      selectedColor: isDark ? const Color(0xFF6B21A8) : const Color(0xFFD35400),
                      backgroundColor: isDark ? const Color(0xFF272D45) : const Color(0xFFFFF1E6),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? Colors.white12 : const Color(0xFFFFCCBC)),
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

          // 2. Wisdom Cards List or Empty State
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF2C1938) : const Color(0xFFFFEBEE),
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 48,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '아직 찜한 좋은글이 없습니다',
                            style: GoogleFonts.jua(
                              fontSize: 20,
                              color: isDark ? Colors.white : const Color(0xFF2C1810),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '마음에 드는 명언 카드의 하트(❤️)를 누르면\n나만의 찜 목록에 쏙 모아집니다 ✨',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.5,
                              color: isDark ? const Color(0xFFA0AEC0) : const Color(0xFF8D6E63),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCategory = '전체');
                            },
                            icon: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 18),
                            label: const Text(
                              '전체 명언 보러가기',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD35400),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final isLiked = _likedIds.contains(item.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2234) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white12 : const Color(0x1F8D6E63),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black38 : const Color(0x0F8D6E63),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header: Category Badge & Like Button
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF2B324D) : const Color(0xFFFFF0E6),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isDark ? const Color(0x44FFD700) : const Color(0xFFFFCCBC),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(item.emoji, style: const TextStyle(fontSize: 14)),
                                        const SizedBox(width: 5),
                                        Text(
                                          item.category,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? const Color(0xFFFFD700) : const Color(0xFFD35400),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: isLiked ? const Color(0xFFE91E63) : Colors.grey,
                                      size: 22,
                                    ),
                                    tooltip: isLiked ? '좋아요 취소' : '마음 담기',
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        if (isLiked) {
                                          _likedIds.remove(item.id);
                                        } else {
                                          _likedIds.add(item.id);
                                        }
                                      });
                                      _saveLikedIds();
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Title
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: Text(
                                item.title,
                                style: GoogleFonts.jua(
                                  fontSize: 20,
                                  color: isDark ? const Color(0xFFFFD700) : const Color(0xFF2C1810),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),

                            // Content Box (Papyrus Style Frame)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF141724) : const Color(0xFFFFFDF8),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : const Color(0x1F8D6E63),
                                    width: 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      item.content,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.6,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? const Color(0xFFE0E6ED) : const Color(0xFF3E2723),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '- ${item.author} -',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? const Color(0xFFA0AEC0) : const Color(0xFF8D6E63),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Tags Row
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: item.tags.map((tag) {
                                  return Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF718096) : const Color(0xFFA1887F),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            // Action Buttons (카드로 꾸미기 & 카카오톡 공유)
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                              child: Row(
                                children: [
                                  // 1. 카드로 꾸미기
                                  if (widget.onShareAsCard != null)
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 44,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(22),
                                          color: isDark ? const Color(0xFF2C2220) : const Color(0xFFFFEDE2),
                                          border: Border.all(
                                            color: isDark ? const Color(0xFF5D4037) : const Color(0xFFFFCCBC),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            widget.onShareAsCard!(item.content);
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.brush_rounded,
                                                size: 16,
                                                color: isDark ? const Color(0xFFFFAB91) : const Color(0xFFBF360C),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                '카드로 꾸미기',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.5,
                                                  color: isDark ? const Color(0xFFFFAB91) : const Color(0xFFBF360C),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (widget.onShareAsCard != null) const SizedBox(width: 10),

                                  // 2. 카카오톡 공유
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      height: 44,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        color: const Color(0xFFFEE500),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x33FEE500),
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          HapticFeedback.selectionClick();
                                          final result = await Share.share(
                                            item.shareText,
                                            subject: item.title,
                                          );
                                          if (result.status == ShareResultStatus.success) {
                                            AdService().showInterstitialAdOnShare();
                                          }
                                        },
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.share_rounded, color: Colors.black87, size: 17),
                                            SizedBox(width: 5),
                                            Text(
                                              '카톡 공유',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.5,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
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
                  ),
          ),
        ],
      ),
    );
  }
}
