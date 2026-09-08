import 'package:flutter_test/flutter_test.dart';
import 'package:good_morning/data/home_card_data.dart';

void main() {
  group('formatTextWithNaturalBreaks tests', () {
    test('bracketed title should never be split across lines', () {
      const sample = '🚶‍♂️ [식후 혈당 방어 산책법]\n\n식사 후 30분 내에\n15분만 가볍게 걸으세요!\n혈당 스파이크를 막아주어\n당뇨 예방에 큰 도움이 됩니다 🌾';
      final formatted = formatTextWithNaturalBreaks(sample);
      final lines = formatted.split('\n');

      expect(lines[0], equals('🚶‍♂️ [식후 혈당 방어 산책법]'));
      expect(lines.length, equals(6));
    });

    test('bracket title [식후혈당방어 산책법] preserves single line', () {
      const sample = '[식후혈당방어 산책법]\n\n15분만 걸으세요!';
      final formatted = formatTextWithNaturalBreaks(sample);
      final lines = formatted.split('\n');

      expect(lines[0], equals('[식후혈당방어 산책법]'));
    });

    test('all 34 health titles are preserved on a single line', () {
      final titles = [
        '🖐️ [혈액순환 3분 지압법]',
        '🚶‍♂️ [식후 혈당 방어 산책법]',
        '🦵 [혈압 잡는 발뒤꿈치 들기]',
        '🧄 [혈관 청소 꿀팁]',
        '🥗 [식후 혈당 잡는 거꾸로 식사법]',
        '🫁 [혈관 넓히는 3분 복식호흡]',
        '🍅 [혈관 청소부 익힌 토마토]',
        '🥛 [새벽 혈전 막는 물 반 잔]',
        '🪑 [무릎관절 1분 스트레칭]',
        '🧘‍♂️ [허리 튼튼 맥켄지 운동]',
        '🧣 [오십견 예방 수건 스트레칭]',
        '🛌 [허리 살리는 1분 엉덩이 브릿지]',
        '⛳ [발바닥 통증 잡는 골프공 롤링]',
        '🧱 [다리 쥐내림 막는 벽 스트레칭]',
        '🪶 [굽은 등 펴는 W자 날개뼈 운동]',
        '🧠 [치매 예방 10분 손가락 운동]',
        '📝 [뇌 젊어지는 3줄 일기]',
        '🌙 [꿀잠 부르는 4-7-8 호흡법]',
        '🛌 [치매 찌꺼기 청소하는 옆누움]',
        '🪥 [전두엽 깨우는 반대 손 양치]',
        '🫐 [기억력 지키는 브레인 푸드]',
        '📖 [뇌를 깨우는 10분 소리 내어 읽기]',
        '💧 [아침 공복 따뜻한 물 한잔]',
        '🍵 [면역력 쑥쑥 3대 건강차]',
        '🍳 [근육 지키는 단백질 식단]',
        '🍏 [쾌변 부르는 3분 장 마사지]',
        '🍎 [식전 식초물 한 잔의 마법]',
        '🍲 [장 면역력 살리는 발효 식단]',
        '🥦 [항암 성분 살리는 브로콜리 찜]',
        '🍌 [나트륨 배출 돕는 칼륨 충전]',
        '👁️ [눈 건강 20-20-20 수칙]',
        '👓 [노안 예방 손바닥 온찜질]',
        '☀️ [뼈 튼튼 하루 20분 햇볕 쬐기]',
        '👂 [면역력 쑥쑥 1분 귀 마사지]',
        '🌅 [숙면 부르는 아침 햇빛 샤워]',
        '🛋️ [위산 역류 막는 식후 2시간]',
        '🦷 [혈관 질환 막는 치간칫솔 습관]',
        '♨️ [피로 싹 푸는 15분 족욕]',
      ];

      for (final title in titles) {
        final formatted = formatTextWithNaturalBreaks(title);
        expect(formatted, equals(title), reason: 'Title "$title" should not be broken!');
      }
    });
  });
}
