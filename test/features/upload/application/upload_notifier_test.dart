import 'dart:async';

import 'package:chagok_mobile/features/upload/application/upload_notifier.dart';
import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/camera_permission_denied_exception.dart';
import 'package:chagok_mobile/features/upload/data/upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_upload_repository.dart';

void main() {
  late FakeUploadRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeUploadRepository();
    container = ProviderContainer(
      overrides: [uploadRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  UploadNotifier notifier() => container.read(uploadProvider.notifier);

  group('UploadNotifier', () {
    test('파일을 고르는 중에 또 고르면 무시하고 false를 돌려준다', () async {
      repository.pickGate = Completer<void>();
      final first = notifier().pick(UploadSource.pdf);

      final isSecondPicked = await notifier().pick(UploadSource.album);
      repository.pickGate?.complete();
      await first;

      expect(isSecondPicked, isFalse);
      expect(repository.pickCount, 1);
      expect(container.read(uploadProvider).document?.fileName, 'pdf.pdf');
    });

    test('파일을 고르면 보관함 목록을 불러와 첫 보관함을 골라 둔다', () async {
      final isPicked = await notifier().pick(UploadSource.pdf);

      final state = container.read(uploadProvider);
      expect(isPicked, isTrue);
      expect(state.document?.fileName, 'pdf.pdf');
      expect(state.selectedBox?.id, 'housing');
    });

    test('다시 고르면 보관함 목록을 또 불러오지 않고 고른 보관함을 유지한다', () async {
      await notifier().pick(UploadSource.pdf);
      notifier().selectBox('car');

      await notifier().pick(UploadSource.album);

      expect(repository.boxFetchCount, 1);
      expect(container.read(uploadProvider).selectedBox?.id, 'car');
    });

    test('고르기를 취소하면 false를 돌려주고 상태를 바꾸지 않는다', () async {
      repository.isCancelled = true;

      final isPicked = await notifier().pick(UploadSource.camera);

      expect(isPicked, isFalse);
      expect(container.read(uploadProvider).document, isNull);
      expect(container.read(uploadProvider).isBusy, isFalse);
    });

    test('파일을 고르기 전에 분석하면 아무것도 하지 않는다', () async {
      expect(await notifier().analyze(), isNull);
    });

    test('분석하면 결과를 상태에 담고 돌려준다', () async {
      repository.result = const AnalysisUnclear();
      await notifier().pick(UploadSource.camera);

      final result = await notifier().analyze();

      expect(result, isA<AnalysisUnclear>());
      expect(container.read(uploadProvider).result, isA<AnalysisUnclear>());
    });

    test('분석하면 고른 보관함에 올리도록 보관함 id를 넘긴다', () async {
      await notifier().pick(UploadSource.pdf);
      notifier().selectBox('car');

      await notifier().analyze();

      expect(repository.analyzedBoxIds, ['car']);
    });

    test('새 파일을 고르면 이전 분석 결과를 지운다', () async {
      await notifier().pick(UploadSource.pdf);
      await notifier().analyze();

      await notifier().pick(UploadSource.album);

      expect(container.read(uploadProvider).result, isNull);
    });

    test('분석 결과가 흐리면 저장할 수 없다', () async {
      repository.result = const AnalysisUnclear();
      await notifier().pick(UploadSource.camera);
      await notifier().analyze();

      final isSaved = await notifier().save();

      expect(isSaved, isFalse);
      expect(repository.saved, isEmpty);
    });

    test('분석에 성공하면 고른 보관함에 저장하고 상태를 비운다', () async {
      await notifier().pick(UploadSource.pdf);
      notifier().selectBox('car');
      await notifier().analyze();

      final isSaved = await notifier().save();

      expect(isSaved, isTrue);
      expect(repository.saved, ['pdf.pdf@car']);
      expect(container.read(uploadProvider).document, isNull);
    });

    test('파일을 가져오지 못하면 실패를 표시하고 작업 중 상태를 푼다', () async {
      repository.error = Exception('permission');

      final isPicked = await notifier().pick(UploadSource.camera);

      final state = container.read(uploadProvider);
      expect(isPicked, isFalse);
      expect(state.hasFailed, isTrue);
      expect(state.isBusy, isFalse);
    });

    test('카메라 권한이 꺼져 있으면 실패 대신 권한 안내를 표시한다', () async {
      repository.error = const CameraPermissionDeniedException();

      final isPicked = await notifier().pick(UploadSource.camera);

      final state = container.read(uploadProvider);
      expect(isPicked, isFalse);
      expect(state.isCameraDenied, isTrue);
      expect(state.hasFailed, isFalse);
      expect(state.isBusy, isFalse);
    });

    test('권한을 켜고 다시 찍으면 권한 안내가 사라진다', () async {
      repository.error = const CameraPermissionDeniedException();
      await notifier().pick(UploadSource.camera);
      repository.error = null;

      await notifier().pick(UploadSource.camera);

      expect(container.read(uploadProvider).isCameraDenied, isFalse);
    });

    test('분석하지 못하면 null을 돌려주고 실패를 표시한다', () async {
      await notifier().pick(UploadSource.pdf);
      repository.error = Exception('network');

      final result = await notifier().analyze();

      expect(result, isNull);
      expect(container.read(uploadProvider).hasFailed, isTrue);
      expect(container.read(uploadProvider).isBusy, isFalse);
    });

    test('보관하지 못하면 false를 돌려주고 고른 파일과 결과를 그대로 둔다', () async {
      await notifier().pick(UploadSource.pdf);
      await notifier().analyze();
      repository.error = Exception('network');

      final isSaved = await notifier().save();

      final state = container.read(uploadProvider);
      expect(isSaved, isFalse);
      expect(state.hasFailed, isTrue);
      expect(state.document, isNotNull);
      expect(state.result, isA<AnalysisSucceeded>());
    });

    test('실패한 뒤 다시 시도해 성공하면 실패 표시가 사라진다', () async {
      repository.error = Exception('permission');
      await notifier().pick(UploadSource.camera);

      repository.error = null;
      await notifier().pick(UploadSource.camera);

      expect(container.read(uploadProvider).hasFailed, isFalse);
    });

    test('실패 안내를 지우면 실패 표시가 사라지고 고른 파일은 남는다', () async {
      await notifier().pick(UploadSource.pdf);
      repository.error = Exception('network');
      await notifier().analyze();

      notifier().clearFailure();

      final state = container.read(uploadProvider);
      expect(state.hasFailed, isFalse);
      expect(state.document, isNotNull);
    });

    test('저장소가 새로 만들어지면 앞서 고른 파일과 보관함을 버린다', () async {
      final container = ProviderContainer(
        overrides: [
          uploadRepositoryProvider.overrideWith(
            (ref) => FakeUploadRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(uploadProvider.notifier).pick(UploadSource.pdf);

      container.invalidate(uploadRepositoryProvider);

      final state = container.read(uploadProvider);
      expect(state.document, isNull);
      expect(state.boxes, isEmpty);
    });
  });
}
