import 'package:chagok_mobile/features/settings/application/settings_notifier.dart';
import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/settings_repository.dart';
import 'package:chagok_mobile/features/settings/data/text_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  late FakeSettingsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeSettingsRepository();
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  SettingsNotifier notifier() => container.read(settingsProvider.notifier);
  Future<AppSettings> settings() => container.read(settingsProvider.future);

  group('SettingsNotifier', () {
    test('처음 읽으면 저장소에 있는 설정을 불러온다', () async {
      repository.stored = const AppSettings(textSize: TextSize.large);

      expect((await settings()).textSize, TextSize.large);
    });

    test('글자 크기를 바꾸면 상태와 저장소에 반영한다', () async {
      await settings();

      await notifier().setTextSize(TextSize.extraLarge);

      expect((await settings()).textSize, TextSize.extraLarge);
      expect(repository.stored.textSize, TextSize.extraLarge);
    });

    test('납부일 알림을 끄면 저장소에 반영한다', () async {
      await settings();

      await notifier().setPaymentReminder(isOn: false);

      expect(repository.stored.isPaymentReminderOn, isFalse);
    });

    test('마케팅 수신을 켜면 저장소에 반영한다', () async {
      await settings();

      await notifier().setMarketing(isOn: true);

      expect(repository.stored.isMarketingOn, isTrue);
    });

    test('알림 시각을 바꾸면 자정부터 지난 분으로 저장한다', () async {
      await settings();

      await notifier().setReminderTime(hour: 14, minute: 30);

      expect(repository.stored.reminderMinuteOfDay, 14 * 60 + 30);
    });

    test('범위를 벗어난 알림 시각을 넣으면 RangeError를 던진다', () async {
      await settings();

      expect(
        () => notifier().setReminderTime(hour: 24, minute: 0),
        throwsRangeError,
      );
    });

    test('불러오기 전에 설정을 바꾸면 저장하지 않는다', () async {
      await notifier().setTextSize(TextSize.large);

      expect(repository.saveCount, 0);
    });

    test('탈퇴하면 저장소에 요청하고 설정을 다시 불러온다', () async {
      await settings();
      await notifier().setTextSize(TextSize.large);

      await notifier().deleteAccount();

      expect(repository.deleteCount, 1);
      expect((await settings()).textSize, TextSize.normal);
    });

    test('로그아웃하면 저장소에 요청하고 true를 돌려준다', () async {
      final isDone = await notifier().logOut();

      expect(isDone, isTrue);
      expect(repository.logOutCount, 1);
    });

    test('로그아웃하지 못하면 예외 대신 false를 돌려준다', () async {
      repository.error = Exception('network');

      final isDone = await notifier().logOut();

      expect(isDone, isFalse);
    });

    test('탈퇴하지 못하면 예외 대신 false를 돌려주고 설정은 그대로 둔다', () async {
      await settings();
      await notifier().setTextSize(TextSize.large);
      repository.error = Exception('network');

      final isDone = await notifier().deleteAccount();

      expect(isDone, isFalse);
      expect((await settings()).textSize, TextSize.large);
    });

    test('설정을 연달아 바꾸면 요청 순서대로 저장하고 앞선 저장이 최신 설정을 덮어쓰지 않는다', () async {
      await settings();
      repository.holdSaves = true;

      final first = notifier().setPaymentReminder(isOn: false);
      final second = notifier().setMarketing(isOn: true);
      await pumpEventQueue();
      repository.pendingSaves.first.complete();
      await first;
      final afterFirst = container.read(settingsProvider).value;
      await pumpEventQueue();
      repository.pendingSaves.last.complete();
      await second;

      expect(afterFirst?.isMarketingOn, isTrue);
      expect(repository.stored.isPaymentReminderOn, isFalse);
      expect(repository.stored.isMarketingOn, isTrue);
      expect(container.read(settingsProvider).value?.isMarketingOn, isTrue);
    });
  });
}
