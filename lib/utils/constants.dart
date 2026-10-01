import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {
  // 시니어 가독성 높은 폰트 9종 (인기 서체 3종 추가)
  static final List<Map<String, dynamic>> seniorFonts = [
    {'id': 'Jua', 'name': '두꺼운 고딕체', 'font': GoogleFonts.jua()},
    {'id': 'GowunBatang', 'name': '깔끔한 명조체', 'font': GoogleFonts.gowunBatang(fontWeight: FontWeight.bold)},
    {'id': 'NanumMyeongjo', 'name': '품격있는 나눔명조', 'font': GoogleFonts.nanumMyeongjo(fontWeight: FontWeight.bold)},
    {'id': 'SongMyung', 'name': '시(詩) 감성 송명체', 'font': GoogleFonts.songMyung()},
    {'id': 'DoHyeon', 'name': '굵직한 제목체', 'font': GoogleFonts.doHyeon()},
    {'id': 'NanumBrush', 'name': '정성스런 붓글씨', 'font': GoogleFonts.nanumBrushScript()},
    {'id': 'NanumPen', 'name': '따뜻한 펜글씨체', 'font': GoogleFonts.nanumPenScript()},
    {'id': 'GamjaFlower', 'name': '다정한 손글씨', 'font': GoogleFonts.gamjaFlower()},
    {'id': 'BlackHanSans', 'name': '시원시원 큰글씨', 'font': GoogleFonts.blackHanSans()},
  ];

  static const List<Color> textColors = [
    Colors.white,
    Colors.black,
    Color(0xFFE4E4E7), // 밝은 회색
    Color(0xFFFFD700), // 황금색
    Color(0xFFFFE066), // 연노랑
    Color(0xFFFFB3B3), // 연분홍
    Color(0xFFF472B6), // 진달래
    Color(0xFFEF4444), // 빨강
    Color(0xFFF97316), // 주황
    Color(0xFF99FF99), // 연두
    Color(0xFF22C55E), // 초록
    Color(0xFF99CCFF), // 연하늘
    Color(0xFF3B82F6), // 파랑
    Color(0xFFC084FC), // 연보라
    Color(0xFF8B5CF6), // 보라
  ];

  // 어르신 맞춤형 자주 쓰는 안부 이모티콘 목록 (추천 문구 포함)
  static const List<String> quickEmojis = [
    '❤️', '💖', '😊', '🙏', '🤝', '🤲', '🕊️',
    '🌸', '🌼', '🌹', '🌷', '🌺', '🍀', '🌿', '🍃', '🍁', '🍂', '🌾',
    '☀️', '⛅', '☁️', '🌊', '🌅', '🌕', '✨', '🌟',
    '☕', '🍵', '🍷', '💐', '🎁', '💌', '🕯️', '💎', '🎉'
  ];
}
