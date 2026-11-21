import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/features/document/data/api_document_repository.dart';
import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/document_not_found_exception.dart';
import 'package:chagok_mobile/features/document/data/in_memory_document_repository.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 보관한 서류의 내용과 납부일 알림을 다루는 창구.
abstract interface class DocumentRepository {
  /// 고를 수 있는 서류 종류. 예: "임대차계약서"
  List<String> get documentTypes;

  /// [id] 서류의 내용. 없으면 [DocumentNotFoundException]을 던집니다.
  Future<DocumentDetail> fetchDetail(String id);

  /// 고친 서류 내용을 저장합니다.
  Future<void> updateDetail(DocumentDetail detail);

  /// 서류에 건 알림. 아직 없으면 null.
  Future<PaymentReminder?> fetchReminder(String documentId);

  /// 납부일 알림을 저장합니다. 같은 서류의 알림이 있으면 덮어씁니다.
  Future<void> saveReminder(PaymentReminder reminder);
}

/// 앱 전역 [DocumentRepository].
///
/// API 서버 주소가 있으면 서버에, 없으면 메모리에 서류 내용을 둡니다.
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  if (!ref.watch(isApiEnabledProvider)) return InMemoryDocumentRepository();
  return ApiDocumentRepository(client: ref.watch(apiClientProvider));
});
