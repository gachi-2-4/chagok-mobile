import 'package:chagok_mobile/features/chat/application/chat_search_query_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatSearchQueryNotifier', () {
    test('처음에는 검색어가 비어 있다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(chatSearchQueryProvider), isEmpty);
    });

    test('update를 부르면 검색어가 바뀐다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(chatSearchQueryProvider.notifier).update('관리비');

      expect(container.read(chatSearchQueryProvider), '관리비');
    });
  });
}
