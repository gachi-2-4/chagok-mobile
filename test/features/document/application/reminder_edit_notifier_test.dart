import 'package:chagok_mobile/features/document/application/reminder_edit_notifier.dart';
import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/document_repository.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_document_repository.dart';

void main() {
  final provider = reminderEditProvider('lease');
  late FakeDocumentRepository repository;
  late ProviderContainer container;

  void setUpContainer({PaymentReminder? reminder}) {
    repository = FakeDocumentRepository(
      detail: const DocumentDetail(
        id: 'lease',
        boxName: '집 · 임대',
        documentType: '임대차계약서',
        paymentDay: 25,
      ),
      reminder: reminder,
    );
    container = ProviderContainer(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(provider, (_, _) {});
  }

  ReminderEditNotifier notifier() => container.read(provider.notifier);

  group('ReminderEditNotifier', () {
    test('건 알림이 없으면 서류 납부일로 기본 알림을 채운다', () async {
      setUpContainer();

      final state = await container.read(provider.future);

      expect(state.reminder.paymentDay, 25);
      expect(state.reminder.minuteOfDay, 9 * 60);
      expect(state.reminder.advanceDays, {0, 1});
    });

    test('이미 건 알림이 있으면 그 알림을 불러온다', () async {
      setUpContainer(
        reminder: const PaymentReminder(
          documentId: 'lease',
          paymentDay: 10,
          advanceDays: {7},
        ),
      );

      final state = await container.read(provider.future);

      expect(state.reminder.paymentDay, 10);
      expect(state.reminder.advanceDays, {7});
    });

    test('미리 알림을 누를 때마다 켜고 끈다', () async {
      setUpContainer();
      await container.read(provider.future);

      notifier()
        ..toggleAdvanceDay(3)
        ..toggleAdvanceDay(0);

      expect(container.read(provider).value?.reminder.advanceDays, {1, 3});
    });

    test('미리 알림을 모두 끄면 등록할 수 없다', () async {
      setUpContainer();
      await container.read(provider.future);

      notifier()
        ..toggleAdvanceDay(0)
        ..toggleAdvanceDay(1);

      expect(container.read(provider).value?.canSave, isFalse);
      expect(await notifier().save(), isFalse);
    });

    test('등록하면 고친 알림을 저장소에 넘긴다', () async {
      setUpContainer();
      await container.read(provider.future);
      notifier()
        ..setTime(hour: 20, minute: 30)
        ..setMonthly(isMonthly: false);

      final isSaved = await notifier().save();

      final saved = repository.savedReminders.single;
      expect(isSaved, isTrue);
      expect(saved.minuteOfDay, 20 * 60 + 30);
      expect(saved.isMonthly, isFalse);
    });
  });
}
