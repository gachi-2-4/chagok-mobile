import 'package:chagok_mobile/features/calendar/data/deadline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Deadline', () {
    test('생성자에 넘긴 분류 목록을 나중에 바꾸면 기한은 그대로다', () {
      final tags = ['집'];
      final deadline = Deadline(
        id: 'a',
        title: '관리비',
        dueDate: DateTime(2026, 11, 25),
        tags: tags,
      );

      tags.add('임대');

      expect(deadline.tags, ['집']);
    });

    test('등록 여부만 바꾸면 나머지 값은 그대로 둔다', () {
      final deadline = Deadline(
        id: 'a',
        title: '관리비',
        dueDate: DateTime(2026, 11, 25),
        tags: const ['집'],
      );

      final registered = deadline.copyWith(isRegistered: true);

      expect(registered.isRegistered, isTrue);
      expect(registered.title, '관리비');
      expect(registered.dueDate, DateTime(2026, 11, 25));
    });
  });
}
