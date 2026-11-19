import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/document_repository.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';

/// 서류 하나를 메모리에 두고 저장 요청을 기록하는 가짜 [DocumentRepository].
class FakeDocumentRepository implements DocumentRepository {
  FakeDocumentRepository({required this.detail, this.reminder});

  DocumentDetail detail;
  PaymentReminder? reminder;
  final updatedDetails = <DocumentDetail>[];
  final savedReminders = <PaymentReminder>[];

  @override
  List<String> get documentTypes => const ['임대차계약서', '관리비 고지서'];

  @override
  Future<DocumentDetail> fetchDetail(String id) async {
    if (id != detail.id) throw DocumentNotFoundException(id);
    return detail;
  }

  @override
  Future<void> updateDetail(DocumentDetail detail) async {
    updatedDetails.add(detail);
    this.detail = detail;
  }

  @override
  Future<PaymentReminder?> fetchReminder(String documentId) async => reminder;

  @override
  Future<void> saveReminder(PaymentReminder reminder) async {
    savedReminders.add(reminder);
    this.reminder = reminder;
  }
}
