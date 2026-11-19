import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/document_repository.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';

/// 백엔드가 정해지기 전까지 쓰는 메모리 저장소. 예시 임대차계약서 하나를 둡니다.
class InMemoryDocumentRepository implements DocumentRepository {
  /// 예시 서류 id.
  static const sampleId = 'lease';

  final _details = <String, DocumentDetail>{
    sampleId: DocumentDetail(
      id: sampleId,
      boxName: '집 · 임대',
      documentType: '임대차계약서',
      monthlyRent: 500000,
      paymentDay: 25,
      contractEndDate: DateTime(2027, 1, 2),
    ),
  };
  final _reminders = <String, PaymentReminder>{};

  @override
  List<String> get documentTypes => const [
    '임대차계약서',
    '관리비 고지서',
    '통신 요금 청구서',
    '보험 증권',
    '기타',
  ];

  @override
  Future<DocumentDetail> fetchDetail(String id) async {
    return _details[id] ?? (throw DocumentNotFoundException(id));
  }

  @override
  Future<void> updateDetail(DocumentDetail detail) async {
    if (!_details.containsKey(detail.id)) {
      throw DocumentNotFoundException(detail.id);
    }
    _details[detail.id] = detail;
  }

  @override
  Future<PaymentReminder?> fetchReminder(String documentId) async =>
      _reminders[documentId];

  @override
  Future<void> saveReminder(PaymentReminder reminder) async {
    _reminders[reminder.documentId] = reminder;
  }
}
