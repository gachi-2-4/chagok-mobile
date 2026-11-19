import 'package:chagok_mobile/features/document/application/document_edit_notifier.dart';
import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/document_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_document_repository.dart';

void main() {
  final provider = documentEditProvider('lease');
  late FakeDocumentRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeDocumentRepository(
      detail: DocumentDetail(
        id: 'lease',
        boxName: '집 · 임대',
        documentType: '임대차계약서',
        monthlyRent: 500000,
        paymentDay: 25,
        contractEndDate: DateTime(2027, 1, 2),
      ),
    );
    container = ProviderContainer(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(provider, (_, _) {});
  });

  DocumentEditNotifier notifier() => container.read(provider.notifier);

  group('DocumentEditNotifier', () {
    test('저장된 서류 내용으로 입력값을 채운다', () async {
      final form = await container.read(provider.future);

      expect(form.documentType, '임대차계약서');
      expect(form.monthlyRentText, '500000');
      expect(form.paymentDay, 25);
    });

    test('쉼표가 들어간 월 임대료도 숫자로 읽는다', () async {
      await container.read(provider.future);

      notifier().updateMonthlyRent('550,000');

      expect(container.read(provider).value?.monthlyRent, 550000);
    });

    test('월 임대료에 숫자가 아닌 글자가 있으면 저장할 수 없다', () async {
      await container.read(provider.future);

      notifier().updateMonthlyRent('오십만');

      final form = container.read(provider).value;
      expect(form?.hasInvalidMonthlyRent, isTrue);
      expect(form?.canSave, isFalse);
    });

    test('범위를 벗어난 납부일은 받지 않는다', () async {
      await container.read(provider.future);

      expect(() => notifier().updatePaymentDay(32), throwsRangeError);
    });

    test('저장하면 고친 내용을 저장소에 넘긴다', () async {
      await container.read(provider.future);
      notifier()
        ..updateDocumentType('관리비 고지서')
        ..updateMonthlyRent('550,000')
        ..updatePaymentDay(10)
        ..updatePenalty('  남은 기간 월세의 10%  ');

      final isSaved = await notifier().save();

      final saved = repository.updatedDetails.single;
      expect(isSaved, isTrue);
      expect(saved.documentType, '관리비 고지서');
      expect(saved.monthlyRent, 550000);
      expect(saved.paymentDay, 10);
      expect(saved.earlyTerminationPenalty, '남은 기간 월세의 10%');
      expect(saved.boxName, '집 · 임대');
    });

    test('위약금 칸을 비우면 값 없이 저장한다', () async {
      await container.read(provider.future);
      notifier().updatePenalty('   ');

      await notifier().save();

      expect(repository.updatedDetails.single.earlyTerminationPenalty, isNull);
    });
  });
}
