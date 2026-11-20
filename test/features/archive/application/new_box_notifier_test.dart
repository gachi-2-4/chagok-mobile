import 'dart:async';

import 'package:chagok_mobile/features/archive/application/archive_clock.dart';
import 'package:chagok_mobile/features/archive/application/box_list_notifier.dart';
import 'package:chagok_mobile/features/archive/application/new_box_notifier.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_archive_repository.dart';

void main() {
  late FakeArchiveRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeArchiveRepository();
    container = ProviderContainer(
      overrides: [
        archiveRepositoryProvider.overrideWithValue(repository),
        archiveClockProvider.overrideWithValue(() => DateTime(2026, 11, 20)),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    // 시트가 열려 있는 동안처럼 입력값을 계속 듣습니다.
    final subscription = container.listen(newBoxProvider, (_, _) {});
    addTearDown(subscription.close);
  });

  NewBoxNotifier notifier() => container.read(newBoxProvider.notifier);

  group('NewBoxNotifier', () {
    test('처음 열면 이름 없이 살구색과 기타 아이콘을 고른 상태다', () {
      final form = container.read(newBoxProvider);

      expect(form.name, isEmpty);
      expect(form.color, BoxColor.peach);
      expect(form.icon, BoxIcon.package);
    });

    test('색과 아이콘을 고르면 입력값에 반영한다', () {
      notifier()
        ..selectColor(BoxColor.green)
        ..selectIcon(BoxIcon.pet);

      final form = container.read(newBoxProvider);
      expect(form.color, BoxColor.green);
      expect(form.icon, BoxIcon.pet);
    });

    test('만들면 앞뒤 공백을 뺀 이름과 고른 색·아이콘으로 저장한다', () async {
      notifier()
        ..updateName('  반려동물 ')
        ..selectColor(BoxColor.green)
        ..selectIcon(BoxIcon.pet);

      final isCreated = await notifier().submit();

      expect(isCreated, isTrue);
      expect(repository.created, [('반려동물', BoxColor.green, BoxIcon.pet)]);
    });

    test('만들면 보관함 목록을 다시 불러와 새 보관함을 보여 준다', () async {
      await container.read(boxListProvider.future);
      notifier().updateName('반려동물');

      await notifier().submit();

      final items = await container.read(boxListProvider.future);
      expect(items.map((item) => item.box.name), ['반려동물']);
    });

    test('이름이 비어 있으면 만들지 않고 false를 돌려준다', () async {
      final isCreated = await notifier().submit();

      expect(isCreated, isFalse);
      expect(repository.created, isEmpty);
    });

    test('만드는 중이면 만드는 중으로 표시하고 다시 누를 수 없게 한다', () async {
      final gate = Completer<void>();
      repository.createGate = gate;
      notifier().updateName('반려동물');

      final submitting = notifier().submit();

      expect(container.read(newBoxProvider).isSaving, isTrue);
      expect(container.read(newBoxProvider).canSubmit, isFalse);
      gate.complete();
      await submitting;
      expect(container.read(newBoxProvider).isSaving, isFalse);
    });

    test('저장소가 실패하면 입력값을 두고 실패를 표시한다', () async {
      repository.createError = Exception('네트워크 오류');
      notifier().updateName('반려동물');

      final isCreated = await notifier().submit();

      expect(isCreated, isFalse);
      final form = container.read(newBoxProvider);
      expect(form.hasSaveFailed, isTrue);
      expect(form.isSaving, isFalse);
      expect(form.name, '반려동물');
    });
  });
}
