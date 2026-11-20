import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_repository.dart';

/// 백엔드가 정해지기 전까지 쓰는 메모리 저장소. 앱을 끄면 사라집니다.
class InMemoryOnboardingRepository implements OnboardingRepository {
  Map<String, Object?>? _saved;

  @override
  Future<OnboardingAnswers?> fetch() async {
    final saved = _saved;
    return saved == null ? null : OnboardingAnswers.fromJson(saved);
  }

  @override
  Future<void> save(OnboardingAnswers answers) async {
    _saved = answers.toJson();
  }
}
