import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/document_not_found_exception.dart';
import 'package:chagok_mobile/features/document/data/in_memory_document_repository.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryDocumentRepository', () {
    test('예시 서류 id로 불러오면 예시 서류를 돌려준다', () async {
      final repository = InMemoryDocumentRepository();

      final detail = await repository.fetchDetail(
        InMemoryDocumentRepository.sampleId,
      );

      expect(detail.documentType, '임대차계약서');
    });

    test('없는 서류를 찾으면 DocumentNotFoundException을 던진다', () async {
      final repository = InMemoryDocumentRepository();

      await expectLater(
        repository.fetchDetail('missing'),
        throwsA(isA<DocumentNotFoundException>()),
      );
    });

    test('고친 내용을 저장하면 다시 불러올 때 반영된다', () async {
      final repository = InMemoryDocumentRepository();

      await repository.updateDetail(
        const DocumentDetail(
          id: InMemoryDocumentRepository.sampleId,
          boxName: '집 · 임대',
          documentType: '관리비 고지서',
        ),
      );

      final detail = await repository.fetchDetail(
        InMemoryDocumentRepository.sampleId,
      );
      expect(detail.documentType, '관리비 고지서');
    });

    test('알림을 저장하면 저장 전에는 null, 저장 후에는 그 알림을 돌려준다', () async {
      final repository = InMemoryDocumentRepository();
      final reminder = PaymentReminder(documentId: 'lease', paymentDay: 25);

      expect(await repository.fetchReminder('lease'), isNull);
      await repository.saveReminder(reminder);
      expect((await repository.fetchReminder('lease'))?.paymentDay, 25);
    });
  });
}
