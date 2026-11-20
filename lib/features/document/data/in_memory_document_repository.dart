import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/document_not_found_exception.dart';
import 'package:chagok_mobile/features/document/data/document_repository.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';

/// 백엔드가 정해지기 전까지 쓰는 메모리 저장소.
///
/// 보관함 탭의 예시 서류(`SampleArchiveRepository`)를 눌러 열 수 있도록 같은
/// id로 예시 서류를 둡니다. 내용을 자세히 채운 것은 임대차계약서 하나입니다.
class InMemoryDocumentRepository implements DocumentRepository {
  /// 내용을 자세히 채운 예시 서류 id.
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
    'maintenance-fee': const DocumentDetail(
      id: 'maintenance-fee',
      boxName: '집 · 임대',
      documentType: '관리비 고지서',
      paymentDay: 25,
    ),
    'move-in-report': const DocumentDetail(
      id: 'move-in-report',
      boxName: '집 · 임대',
      documentType: '기타',
    ),
    'car-insurance': const DocumentDetail(
      id: 'car-insurance',
      boxName: '자동차',
      documentType: '보험 증권',
    ),
    'car-registration': const DocumentDetail(
      id: 'car-registration',
      boxName: '자동차',
      documentType: '기타',
    ),
    'income-tax': const DocumentDetail(
      id: 'income-tax',
      boxName: '세금',
      documentType: '기타',
    ),
    'property-tax': const DocumentDetail(
      id: 'property-tax',
      boxName: '세금',
      documentType: '기타',
    ),
    'medical-claim': const DocumentDetail(
      id: 'medical-claim',
      boxName: '병원 · 보험',
      documentType: '보험 증권',
    ),
    'health-checkup': const DocumentDetail(
      id: 'health-checkup',
      boxName: '병원 · 보험',
      documentType: '기타',
    ),
    'telecom-bill': const DocumentDetail(
      id: 'telecom-bill',
      boxName: '통신 · 구독',
      documentType: '통신 요금 청구서',
      paymentDay: 15,
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
