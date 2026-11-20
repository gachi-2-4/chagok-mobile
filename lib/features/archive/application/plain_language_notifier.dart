import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서류 하나를 AI로 쉬운 말로 바꾼 설명. 설명 시트를 닫으면 버립니다.
final plainLanguageProvider = AsyncNotifierProvider.autoDispose
    .family<PlainLanguageNotifier, String, String>(PlainLanguageNotifier.new);

/// 서류 [documentId]의 내용을 쉬운 말로 바꿔 옵니다.
class PlainLanguageNotifier extends AsyncNotifier<String> {
  PlainLanguageNotifier(this.documentId);

  final String documentId;

  @override
  Future<String> build() {
    return ref
        .watch(archiveRepositoryProvider)
        .translateToPlainLanguage(documentId);
  }
}
