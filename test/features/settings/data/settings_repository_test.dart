import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/core/network/api_exception.dart';
import 'package:chagok_mobile/core/network/device_id.dart';
import 'package:chagok_mobile/core/network/session_notifier.dart';
import 'package:chagok_mobile/core/network/token_storage.dart';
import 'package:chagok_mobile/features/settings/application/settings_notifier.dart';
import 'package:chagok_mobile/features/settings/data/settings_repository.dart';
import 'package:chagok_mobile/features/settings/data/text_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_api_server.dart';

void main() {
  late FakeApiServer server;
  late ProviderContainer container;

  /// 토큰을 붙인 요청에만 [data]를 주고, 토큰이 없으면 서버처럼 401을 줍니다.
  void onSignedInJson(String path, Map<String, Object?> data) {
    server.on('GET', path, (request) {
      if (request.headers['authorization'] == null) {
        return errorResponse(401, 'UNAUTHORIZED', '인증이 필요합니다.');
      }
      return jsonResponse(data);
    });
  }

  /// 저장한 토큰 확인과 불러오기가 끝날 때까지 기다립니다.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  setUp(() {
    server = FakeApiServer();
    onSignedInJson('/user/me', {'name': '이차곡', 'fontSize': 'LARGE'});
    onSignedInJson('/notifications/settings', {'deadlineAlertEnabled': true});
    container = ProviderContainer(
      // 실패를 바로 확인하도록 Riverpod의 자동 재시도를 끕니다.
      retry: (_, _) => null,
      overrides: [
        appEnvProvider.overrideWithValue({
          'API_BASE_URL': '${FakeApiServer.baseUrl}',
        }),
        tokenStoreProvider.overrideWithValue(server.tokenStorage),
        apiClientProvider.overrideWithValue(server.client),
        deviceIdProvider.overrideWithValue('device-1'),
      ],
    );
    addTearDown(container.dispose);
    container.listen(sessionProvider, (_, _) {});
  });

  group('settingsRepositoryProvider', () {
    test('로그인하면 저장소를 새로 만든다', () async {
      await settle();
      final before = container.read(settingsRepositoryProvider);

      await container
          .read(tokenStorageProvider)
          .save(FakeApiServer.loggedInTokens);

      expect(container.read(settingsRepositoryProvider), isNot(before));
    });

    test('로그인 전에 설정을 불러오지 못했어도 로그인하면 다시 불러온다', () async {
      container.listen(settingsProvider, (_, _) {});
      await settle();
      await expectLater(
        container.read(settingsProvider.future),
        throwsA(isA<ApiException>()),
      );

      await container
          .read(tokenStorageProvider)
          .save(FakeApiServer.loggedInTokens);
      final settings = await container.read(settingsProvider.future);

      expect(settings.textSize, TextSize.large);
    });
  });
}
