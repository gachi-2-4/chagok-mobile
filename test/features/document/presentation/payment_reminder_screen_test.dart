import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/document/application/document_clock.dart';
import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/document_repository.dart';
import 'package:chagok_mobile/features/document/presentation/payment_reminder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_document_repository.dart';

void main() {
  group('PaymentReminderScreen', () {
    testWidgets('다음 알림 시각이 지나면 표시를 그다음 알림으로 갱신한다', (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var now = DateTime(2026, 11, 24, 8, 59);
      final repository = FakeDocumentRepository(
        detail: const DocumentDetail(
          id: 'lease',
          boxName: '집 · 임대',
          documentType: '임대차계약서',
          paymentDay: 25,
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentRepositoryProvider.overrideWithValue(repository),
            documentClockProvider.overrideWithValue(() => now),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const PaymentReminderScreen(documentId: 'lease'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('11월 24일 오전 9:00'), findsOneWidget);

      now = DateTime(2026, 11, 24, 9, 0, 1);
      await tester.pump(const Duration(minutes: 1, seconds: 1));

      expect(find.textContaining('11월 25일 오전 9:00'), findsOneWidget);
    });
  });
}
