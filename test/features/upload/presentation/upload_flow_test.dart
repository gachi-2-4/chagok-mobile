import 'package:chagok_mobile/app/app.dart';
import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/upload_repository.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_retake_screen.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_review_screen.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_upload_repository.dart';

void main() {
  late FakeUploadRepository repository;

  Future<void> pumpUpload(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repository = FakeUploadRepository();
    final container = ProviderContainer(
      overrides: [uploadRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const ChagokApp()),
    );
    container.read(routerProvider).go(AppRoute.upload);
    await tester.pumpAndSettle();
  }

  group('서류 올리기 흐름', () {
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
