import 'package:chagok_mobile/core/network/api_exception.dart';
import 'package:chagok_mobile/features/settings/data/api_settings_repository.dart';
import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/text_size.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../../../helpers/fake_api_server.dart';

void main() {
  late FakeApiServer server;
  late ApiSettingsRepository repository;

  setUp(() async {
    server = FakeApiServer();
    await server.tokenStorage.save(FakeApiServer.loggedInTokens);
    repository = ApiSettingsRepository(
      client: server.client,
      tokenStorage: server.tokenStorage,
      deviceId: 'device-1',
    );
    server
      ..onJson('GET', '/user/me', {
        'name': '이차곡',
        'phoneNumber': '01041845036',
        'fontSize': 'LARGE',
      })
      ..onJson('GET', '/notifications/settings', {
        'deadlineAlertEnabled': false,
        'marketingAgreed': true,
        'defaultAlertTime': '08:30',
      })
      ..onJson('PATCH', '/user/me/preferences', {})
      ..onJson('PATCH', '/notifications/settings', {})
      ..onJson('POST', '/user/me/consents', {});
  });

  group('ApiSettingsRepository.fetchSettings', () {
    test('설정을 불러오면 내 정보와 알림 설정을 합쳐 앱 설정으로 돌려준다', () async {
      final settings = await repository.fetchSettings();

      expect(settings.textSize, TextSize.large);
      expect(settings.isPaymentReminderOn, isFalse);
      expect(settings.isMarketingOn, isTrue);
      expect(settings.reminderMinuteOfDay, 8 * 60 + 30);
    });
  });

  group('ApiSettingsRepository.saveSettings', () {
    test('불러온 뒤 글자 크기만 바꾸면 글자 크기 API만 부른다', () async {
      final settings = await repository.fetchSettings();

      await repository.saveSettings(
        settings.copyWith(textSize: TextSize.extraLarge),
      );

      expect(server.lastBody('PATCH', '/user/me/preferences'), {
        'fontSize': 'EXTRA_LARGE',
      });
      expect(server.requestsTo('PATCH', '/notifications/settings'), isEmpty);
      expect(server.requestsTo('POST', '/user/me/consents'), isEmpty);
    });

    test('마케팅 수신을 바꾸면 약관 동의 기록 API로 보낸다', () async {
      final settings = await repository.fetchSettings();

      await repository.saveSettings(settings.copyWith(isMarketingOn: false));

      expect(server.lastBody('POST', '/user/me/consents'), {
        'marketing': false,
      });
    });

    test('불러오기 전에 저장하면 세 곳에 모두 보낸다', () async {
      await repository.saveSettings(const AppSettings());

      expect(server.lastBody('PATCH', '/notifications/settings'), {
        'deadlineAlertEnabled': true,
        'defaultAlertTime': '09:00',
      });
      expect(server.requestsTo('PATCH', '/user/me/preferences'), hasLength(1));
      expect(server.requestsTo('POST', '/user/me/consents'), hasLength(1));
    });
  });

  group('ApiSettingsRepository.saveSettings 실패', () {
    test('일부만 저장하고 실패하면 다음 저장 때 모두 다시 보낸다', () async {
      final settings = await repository.fetchSettings();
      server.on(
        'PATCH',
        '/notifications/settings',
        (_) => errorResponse(500, 'INTERNAL_SERVER_ERROR'),
      );
      final changed = settings.copyWith(
        textSize: TextSize.normal,
        isPaymentReminderOn: true,
      );
      await expectLater(
        repository.saveSettings(changed),
        throwsA(isA<ApiException>()),
      );
      server.onJson('PATCH', '/notifications/settings', {});

      await repository.saveSettings(settings);

      expect(server.requestsTo('PATCH', '/user/me/preferences'), hasLength(2));
      expect(server.requestsTo('POST', '/user/me/consents'), hasLength(1));
    });
  });

  group('ApiSettingsRepository.fetchProfile', () {
    test('전화번호가 없는 소셜 계정이면 빈 전화번호로 돌려준다', () async {
      server.onJson('GET', '/user/me', {'name': '구글 사용자', 'phoneNumber': null});

      final profile = await repository.fetchProfile();

      expect(profile.phoneNumber, isEmpty);
    });
  });

  group('ApiSettingsRepository.logOut', () {
    test('로그아웃하면 Refresh Token과 기기 ID를 보내고 토큰을 지운다', () async {
      server.on('POST', '/auth/logout', (_) => emptyResponse());

      await repository.logOut();

      expect(server.lastBody('POST', '/auth/logout'), {
        'refreshToken': 'refresh-1',
        'deviceId': 'device-1',
      });
      expect(await server.tokenStorage.read(), isNull);
    });

    test('로그아웃 성공 응답의 본문이 잘못됐으면 이 기기의 토큰을 지우고 로그아웃을 마친다', () async {
      server.on('POST', '/auth/logout', (_) => http.Response('not json', 200));

      await expectLater(repository.logOut(), completes);
      expect(await server.tokenStorage.read(), isNull);
    });

    test('서버에 로그아웃을 알리지 못하면 이 기기의 토큰을 지우고 로그아웃을 마친다', () async {
      server.on(
        'POST',
        '/auth/logout',
        (_) => errorResponse(500, 'INTERNAL_SERVER_ERROR'),
      );

      await expectLater(repository.logOut(), completes);
      expect(await server.tokenStorage.read(), isNull);
    });
  });

  group('ApiSettingsRepository.deleteAccount', () {
    test('탈퇴하면 회원 탈퇴 API를 부르고 토큰을 지운다', () async {
      server.on('DELETE', '/user/me', (_) => emptyResponse());

      await repository.deleteAccount();

      expect(server.requestsTo('DELETE', '/user/me'), hasLength(1));
      expect(await server.tokenStorage.read(), isNull);
    });
  });
}
