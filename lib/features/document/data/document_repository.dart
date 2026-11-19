import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/in_memory_document_repository.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 보관한 서류의 내용과 납부일 알림을 다루는 창구.
abstract interface class DocumentRepository {
  /// 고를 수 있는 서류 종류. 예: "임대차계약서"
  List<String> get documentTypes;

  Future<DocumentDetail> fetchDetail(String id);

  Future<void> updateDetail(DocumentDetail detail);

  /// 서류에 건 알림. 아직 없으면 null.
  Future<PaymentReminder?> fetchReminder(String documentId);

  Future<void> saveReminder(PaymentReminder reminder);
}

/// 서류를 찾지 못했을 때 던지는 예외.
class DocumentNotFoundException implements Exception {
  const DocumentNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'DocumentNotFoundException: $id';
}

/// 앱 전역 [DocumentRepository].
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  // TODO: 백엔드가 정해지면 실제 구현으로 바꿉니다.
  return InMemoryDocumentRepository();
});
