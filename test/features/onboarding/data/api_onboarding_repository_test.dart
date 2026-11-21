import 'package:chagok_mobile/features/onboarding/data/api_onboarding_repository.dart';
import 'package:chagok_mobile/features/onboarding/data/housing_type.dart';
import 'package:chagok_mobile/features/onboarding/data/nationality.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:chagok_mobile/features/onboarding/data/welfare_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_api_server.dart';

void main() {
  late FakeApiServer server;
  late ApiOnboardingRepository repository;

  setUp(() {
    server = FakeApiServer();
    repository = ApiOnboardingRepository(client: server.client);
  });

  group('ApiOnboardingRepository.fetch', () {
    test('설문 값이 있으면 답으로 바꿔 돌려준다', () async {
      server.onJson('GET', '/user/me', {
        'profile': {
          'nationality': 'FOREIGN',
          'region': {'sido': '서울특별시', 'sigungu': '마포구'},
          'housingType': 'WITH_PARENTS',
          'welfareType': 'NEAR_POVERTY',
        },
      });

      final answers = await repository.fetch();

      expect(answers?.nationality, Nationality.foreigner);
      expect(answers?.address, '서울특별시 마포구');
      expect(answers?.housingType, HousingType.parentsHome);
      expect(answers?.welfareStatus, WelfareStatus.nearPoverty);
    });

    test('설문을 마치지 않았으면 null을 돌려준다', () async {
      server.onJson('GET', '/user/me', {'profile': null});

      expect(await repository.fetch(), isNull);
    });
  });

  group('ApiOnboardingRepository.save', () {
    test('답을 저장하면 서버 값과 시·도·시·군·구로 바꿔 보낸다', () async {
      server.onJson('PUT', '/user/me/profile', {'onboardingCompleted': true});

      await repository.save(
        const OnboardingAnswers(
          nationality: Nationality.korean,
          address: '경기도 성남시 분당구 판교역로 166',
          housingType: HousingType.dormitory,
          welfareStatus: WelfareStatus.basicLivelihood,
        ),
      );

      expect(server.lastBody('PUT', '/user/me/profile'), {
        'nationality': 'KR',
        'region': {'sido': '경기도', 'sigungu': '성남시 분당구'},
        'housingType': 'DORMITORY',
        'welfareType': 'BASIC_LIVELIHOOD',
        'birthDate': null,
      });
    });

    test('답하지 않은 질문이 있으면 ArgumentError를 던진다', () async {
      final request = repository.save(
        const OnboardingAnswers(nationality: Nationality.korean),
      );

      await expectLater(request, throwsArgumentError);
      expect(server.requests, isEmpty);
    });
  });
}
