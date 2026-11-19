import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppTopBar', () {
    testWidgets('뒤로 가기를 누르면 onBack이 호출된다', (tester) async {
      var backCount = 0;
      await tester.pumpApp(AppTopBar(title: '회원가입', onBack: () => backCount++));

      await tester.tap(find.bySemanticsLabel('뒤로 가기'));

      expect(backCount, 1);
    });

    testWidgets('onMore가 없으면 더보기를 숨긴다', (tester) async {
      await tester.pumpApp(const AppTopBar(title: '차곡'));

      expect(find.text('···'), findsNothing);
    });

    testWidgets('onMore가 있으면 더보기를 보여 준다', (tester) async {
      await tester.pumpApp(AppTopBar(title: '차곡', onMore: () {}));

      expect(find.text('···'), findsOneWidget);
    });

    testWidgets('뒤로 가기의 누르는 영역은 최소 48x48이다', (tester) async {
      await tester.pumpApp(AppTopBar(title: '회원가입', onBack: () {}));

      final size = tester.getSize(find.bySemanticsLabel('뒤로 가기'));

      expect(size.width, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(size.height, greaterThanOrEqualTo(kMinInteractiveDimension));
    });
  });
}
