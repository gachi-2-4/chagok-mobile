import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    testWidgets('logo로 만들면 로고 글꼴로 차곡을 보여 준다', (tester) async {
      await tester.pumpApp(const AppTopBar.logo());

      final logo = tester.widget<Text>(find.text('차곡'));

      expect(logo.style, AppTypography.logo);
    });

    testWidgets('action이 있으면 아이콘 버튼을 누를 때 onTap이 호출된다', (tester) async {
      var tapCount = 0;
      await tester.pumpApp(
        AppTopBar.plain(
          title: '알림',
          action: AppTopBarAction(
            icon: AppIcons.settings,
            semanticLabel: '알림 설정',
            onTap: () => tapCount++,
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('알림 설정'));

      expect(tapCount, 1);
    });

    testWidgets('plain으로 만들면 진한 제목과 디자인 높이를 쓴다', (tester) async {
      await tester.pumpApp(const AppTopBar.plain(title: '알림'));

      final title = tester.widget<Text>(find.text('알림'));
      final bar = tester.getSize(find.byType(AppTopBar));

      expect(title.style, AppTypography.topBarTitlePlain);
      expect(bar.height, AppTopBar.plainHeight);
    });

    testWidgets('plain의 아이콘은 화면 끝에서 24 떨어져 있다', (tester) async {
      await tester.pumpApp(
        AppTopBar.plain(
          title: '알림',
          action: AppTopBarAction(
            icon: AppIcons.settings,
            semanticLabel: '알림 설정',
            onTap: () {},
          ),
        ),
      );

      final icons = find.byType(SvgPicture);
      final screenWidth = tester.getSize(find.byType(AppTopBar)).width;

      expect(tester.getTopLeft(icons.first).dx, 24);
      expect(screenWidth - tester.getTopRight(icons.last).dx, 24);
    });

    testWidgets('logo로 만들면 뒤로 가기를 숨긴다', (tester) async {
      await tester.pumpApp(const AppTopBar.logo());

      expect(find.bySemanticsLabel('뒤로 가기'), findsNothing);
    });
  });
}
