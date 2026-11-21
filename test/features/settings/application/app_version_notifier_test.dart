import 'package:chagok_mobile/features/settings/application/app_version_notifier.dart';
import 'package:chagok_mobile/features/settings/data/app_version_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAppVersionRepository implements AppVersionRepository {
  _FakeAppVersionRepository({this.error});

  final Exception? error;

  @override
  Future<String> fetchVersion() async {
    if (error case final error?) throw error;
    return '1.2.3';
  }
}

void main() {
  ProviderContainer createContainer(AppVersionRepository repository) {
    final container = ProviderContainer(
      overrides: [appVersionRepositoryProvider.overrideWithValue(repository)],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AppVersionNotifier', () {
    test('불러오면 설치된 앱 버전을 돌려준다', () async {
      final container = createContainer(_FakeAppVersionRepository());

      expect(await container.read(appVersionProvider.future), '1.2.3');
    });

    test('버전을 읽지 못하면 에러 상태가 된다', () async {
      final container = createContainer(
        _FakeAppVersionRepository(error: Exception('플러그인 없음')),
      );

      await expectLater(
        container.read(appVersionProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(appVersionProvider).hasError, isTrue);
    });
  });
}
