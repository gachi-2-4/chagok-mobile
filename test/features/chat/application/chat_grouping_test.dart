import 'package:chagok_mobile/features/chat/application/chat_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_chat_repository.dart';

void main() {
  group('groupByToday', () {
    final now = DateTime(2026, 11, 19, 15);

    test('오늘 대화와 그 전 대화가 섞여 있으면 둘로 나눈다', () {
      final morning = buildThread(id: 'a', updatedAt: DateTime(2026, 11, 19));
      final yesterday = buildThread(
        id: 'b',
        updatedAt: DateTime(2026, 11, 18, 23, 59),
      );

      final groups = groupByToday([morning, yesterday], now);

      expect(groups.today, [morning]);
      expect(groups.earlier, [yesterday]);
    });

    test('같은 일이라도 달이나 해가 다르면 그 전 대화로 본다', () {
      final lastMonth = buildThread(id: 'a', updatedAt: DateTime(2026, 10, 19));
      final lastYear = buildThread(id: 'b', updatedAt: DateTime(2025, 11, 19));

      final groups = groupByToday([lastMonth, lastYear], now);

      expect(groups.today, isEmpty);
      expect(groups.earlier, [lastMonth, lastYear]);
    });

    test('대화를 나누면 묶음 안에서 원래 순서를 지킨다', () {
      final first = buildThread(id: 'a', updatedAt: DateTime(2026, 11, 19, 9));
      final second = buildThread(
        id: 'b',
        updatedAt: DateTime(2026, 11, 19, 14),
      );

      final groups = groupByToday([first, second], now);

      expect(groups.today, [first, second]);
    });
  });
}
