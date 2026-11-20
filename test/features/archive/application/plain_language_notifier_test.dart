import 'package:chagok_mobile/features/archive/application/plain_language_notifier.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_document_not_found_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_archive_repository.dart';

void main() {
  late FakeArchiveRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeArchiveRepository(
      plainLanguages: {'lease': '집주인에게 보증금을 맡기고 2년 동안 사는 계약이에요.'},
    );
    container = ProviderContainer(
      overrides: [archiveRepositoryProvider.overrideWithValue(repository)],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
  });

  group('PlainLanguageNotifier', () {
    test('불러오면 서류를 쉬운 말로 바꾼 설명을 돌려준다', () async {
      final text = await container.read(plainLanguageProvider('lease').future);

      expect(text, '집주인에게 보증금을 맡기고 2년 동안 사는 계약이에요.');
    });

    test('없는 서류를 바꾸면 BoxDocumentNotFoundException 에러 상태가 된다', () async {
      final subscription = container.listen(
        plainLanguageProvider('missing'),
        (_, _) {},
      );
      addTearDown(subscription.close);

      await expectLater(
        container.read(plainLanguageProvider('missing').future),
        throwsA(isA<BoxDocumentNotFoundException>()),
      );
      expect(
        container.read(plainLanguageProvider('missing')).error,
        isA<BoxDocumentNotFoundException>(),
      );
    });
  });
}
