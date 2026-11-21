import 'dart:typed_data';

import 'package:chagok_mobile/app/app.dart';
import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/features/document/presentation/document_edit_screen.dart';
import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/camera_permission_denied_exception.dart';
import 'package:chagok_mobile/features/upload/data/extracted_field.dart';
import 'package:chagok_mobile/features/upload/data/picked_document.dart';
import 'package:chagok_mobile/features/upload/data/upload_file.dart';
import 'package:chagok_mobile/features/upload/data/upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_retake_screen.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_review_screen.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_source_screen.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_upload_repository.dart';

void main() {
  late FakeUploadRepository repository;

  Future<ProviderContainer> pumpUpload(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repository = FakeUploadRepository();
    // 위젯 트리와 함께 정리되도록 ProviderScope를 씁니다. 홈 화면의 자정
    // Timer 같은 것이 testWidgets의 Timer 검사 전에 함께 취소됩니다.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [uploadRepositoryProvider.overrideWithValue(repository)],
        child: const ChagokApp(),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ChagokApp)),
    );
    container.read(routerProvider).go(AppRoute.upload);
    await tester.pumpAndSettle();
    return container;
  }

  group('서류 올리기 흐름', () {
    for (final route in [AppRoute.uploadConfirm, AppRoute.uploadReview]) {
      testWidgets('고른 파일·분석 결과 없이 $route로 들어오면 첫 화면으로 돌려보낸다', (tester) async {
        final container = await pumpUpload(tester);

        container.read(routerProvider).go(route);
        await tester.pumpAndSettle();

        expect(find.byType(UploadSourceScreen), findsOneWidget);
      });
    }

    testWidgets('읽어 낸 값이 표보다 길면 넘치지 않고 줄을 바꿔 보여 준다', (tester) async {
      await pumpUpload(tester);
      repository.result = AnalysisSucceeded(
        documentType: '임대차계약서',
        pageCount: 1,
        fields: const [
          ExtractedField(
            label: '특약',
            value: '임차인은 계약 기간 중 반려동물을 기를 수 없으며, 위반하면 원상 복구 비용을 부담한다',
          ),
        ],
      );

      await tester.tap(find.text('PDF 파일 고르기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('분석 시작'));
      await tester.pumpAndSettle();

      expect(find.byType(UploadReviewScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('PDF를 고르고 분석하면 결과 확인 화면으로 간다', (tester) async {
      await pumpUpload(tester);

      await tester.tap(find.text('PDF 파일 고르기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('분석 시작'));
      await tester.pumpAndSettle();

      expect(find.byType(UploadReviewScreen), findsOneWidget);
    });

    testWidgets('분석 결과가 흐리면 다시 찍기 안내 화면으로 간다', (tester) async {
      await pumpUpload(tester);
      repository.result = const AnalysisUnclear();

      await tester.tap(find.text('사진 촬영'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('분석 시작'));
      await tester.pumpAndSettle();

      expect(find.byType(UploadRetakeScreen), findsOneWidget);
    });

    testWidgets('파일을 가져오지 못하면 실패 안내를 보여 주고 같은 화면에 남는다', (tester) async {
      await pumpUpload(tester);
      repository.error = Exception('permission');

      await tester.tap(find.text('PDF 파일 고르기'));
      await tester.pumpAndSettle();

      expect(find.text(UploadStrings.failed), findsOneWidget);
      expect(find.text(UploadStrings.sourceTitle), findsOneWidget);
    });

    testWidgets('분석 결과에서 내용 수정하기를 누르면 그 서류의 내용 수정 화면으로 간다', (tester) async {
      await pumpUpload(tester);
      repository.result = AnalysisSucceeded(
        documentId: 'lease',
        documentType: '임대차계약서',
        pageCount: 1,
        fields: const [ExtractedField(label: '납부일', value: '매월 25일')],
      );
      await tester.tap(find.text('PDF 파일 고르기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('분석 시작'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(UploadStrings.editDocument));
      await tester.tap(find.text(UploadStrings.editDocument));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentEditScreen), findsOneWidget);
    });

    testWidgets('카메라 권한이 꺼져 있으면 설정에서 허용해 달라고 안내한다', (tester) async {
      await pumpUpload(tester);
      repository.error = const CameraPermissionDeniedException();

      await tester.tap(find.text(UploadStrings.cameraTitle));
      await tester.pumpAndSettle();

      expect(find.text(UploadStrings.cameraDenied), findsOneWidget);
      expect(find.text(UploadStrings.failed), findsNothing);
      expect(find.text(UploadStrings.sourceTitle), findsOneWidget);
    });

    testWidgets('찍은 서류를 고르면 첫 쪽 사진과 쪽수를 미리 보여 준다', (tester) async {
      await pumpUpload(tester);
      repository.pickedDocument = PickedDocument(
        fileName: 'scan-1.png',
        source: UploadSource.camera,
        pageCount: 2,
        files: [
          UploadFile(fileName: 'scan-1.png', bytes: _onePixelPng),
          UploadFile(fileName: 'scan-2.png', bytes: _onePixelPng),
        ],
      );

      await tester.tap(find.text(UploadStrings.cameraTitle));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(UploadStrings.scannedPageLabel),
        findsOneWidget,
      );
      expect(find.text(UploadStrings.pageCount(2)), findsOneWidget);
      expect(find.text(UploadStrings.previewPage(1, 2)), findsOneWidget);
    });

    testWidgets('기기에서 고른 PDF면 쪽수 대신 분석하며 읽는다고 안내한다', (tester) async {
      await pumpUpload(tester);
      repository.pickedDocument = PickedDocument(
        fileName: '임대차계약서.pdf',
        source: UploadSource.pdf,
        files: [UploadFile(fileName: '임대차계약서.pdf', bytes: Uint8List(4))],
      );

      await tester.tap(find.text('PDF 파일 고르기'));
      await tester.pumpAndSettle();

      expect(find.text(UploadStrings.pdfPreviewNote), findsOneWidget);
      expect(find.textContaining('페이지'), findsNothing);
    });

    testWidgets('분석하지 못하면 확인 화면에 실패 안내를 보여 준다', (tester) async {
      await pumpUpload(tester);
      await tester.tap(find.text('PDF 파일 고르기'));
      await tester.pumpAndSettle();
      repository.error = Exception('network');

      await tester.tap(find.text('분석 시작'));
      await tester.pumpAndSettle();

      expect(find.text(UploadStrings.failed), findsOneWidget);
      expect(find.byType(UploadReviewScreen), findsNothing);
    });
  });
}

/// 미리 보기 테스트에 쓰는 1×1 투명 PNG.
final _onePixelPng = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);
