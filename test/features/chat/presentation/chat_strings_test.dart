import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatStrings.documentBanner', () {
    test('서류 이름이 있으면 연결된 서류와 변경 안내를 보여 준다', () {
      expect(ChatStrings.documentBanner('임대차계약서'), '연결된 서류 · 임대차계약서　변경 ›');
    });

    test('서류 이름이 없으면 연결된 서류가 없다고 보여 준다', () {
      expect(ChatStrings.documentBanner(null), '연결된 서류가 없어요　변경 ›');
    });
  });

  group('ChatStrings.updatedAt', () {
    final now = DateTime(2026, 11, 19, 15);

    test('오늘 오전이면 "오전 시:분"으로 보여 준다', () {
      expect(
        ChatStrings.updatedAt(DateTime(2026, 11, 19, 9, 41), now),
        '오전 9:41',
      );
    });

    test('오늘 오후면 12시간제로 바꿔 "오후 시:분"으로 보여 준다', () {
      expect(
        ChatStrings.updatedAt(DateTime(2026, 11, 19, 14, 5), now),
        '오후 2:05',
      );
    });

    test('자정이면 0시가 아니라 "오전 12시"로 보여 준다', () {
      expect(
        ChatStrings.updatedAt(DateTime(2026, 11, 19, 0, 5), now),
        '오전 12:05',
      );
    });

    test('정오면 "오후 12시"로 보여 준다', () {
      expect(
        ChatStrings.updatedAt(DateTime(2026, 11, 19, 12), now),
        '오후 12:00',
      );
    });

    test('오늘이 아니면 "월 일"로 보여 준다', () {
      expect(ChatStrings.updatedAt(DateTime(2026, 11, 14, 9), now), '11월 14일');
    });

    test('같은 날짜라도 해가 다르면 "월 일"로 보여 준다', () {
      expect(ChatStrings.updatedAt(DateTime(2025, 11, 19, 9), now), '11월 19일');
    });
  });
}
