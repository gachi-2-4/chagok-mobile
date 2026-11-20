import 'package:chagok_mobile/features/chat/application/chat_attach_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_chat_repository.dart';

void main() {
  const documents = [leaseDocument, maintenanceDocument];

  group('ChatAttachState', () {
    test('서류 id를 고르면 selected가 그 서류가 된다', () {
      const state = ChatAttachState(
        documents: documents,
        selectedId: 'maintenance',
      );

      expect(state.selected, maintenanceDocument);
    });

    test('고른 id가 목록에 없으면 selected는 null이다', () {
      const state = ChatAttachState(documents: documents, selectedId: 'none');

      expect(state.selected, isNull);
      expect(state.canAttach, isFalse);
    });

    test('서류를 골랐고 저장 중이 아니면 추가할 수 있다', () {
      const state = ChatAttachState(documents: documents, selectedId: 'lease');

      expect(state.canAttach, isTrue);
    });

    test('저장 중이면 추가할 수 없다', () {
      const state = ChatAttachState(
        documents: documents,
        selectedId: 'lease',
        isSaving: true,
      );

      expect(state.canAttach, isFalse);
    });

    test('copyWith로 값을 넘기면 그 값만 바꾸고 서류 목록은 그대로 둔다', () {
      const state = ChatAttachState(documents: documents, selectedId: 'lease');

      final updated = state.copyWith(isSaving: true);

      expect(updated.documents, same(documents));
      expect(updated.selectedId, 'lease');
      expect(updated.isSaving, isTrue);
    });
  });
}
