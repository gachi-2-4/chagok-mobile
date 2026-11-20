import 'package:chagok_mobile/features/archive/application/document_search_query_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DocumentSearchQueryNotifier', () {
    test('처음 열면 검색어가 비어 있다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(documentSearchQueryProvider), isEmpty);
    });

    test('검색어를 바꾸면 바꾼 검색어를 들고 있다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        documentSearchQueryProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      container.read(documentSearchQueryProvider.notifier).update('관리비');

      expect(container.read(documentSearchQueryProvider), '관리비');
    });
  });
}
