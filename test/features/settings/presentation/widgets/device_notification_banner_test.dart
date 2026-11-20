import 'package:chagok_mobile/features/settings/presentation/widgets/device_notification_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('DeviceNotificationBanner', () {
    testWidgets('글자를 2배로 키우면 문구가 줄을 바꿔 배너를 넘치지 않는다', (tester) async {
      await tester.pumpApp(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              // 390pt 화면에서 좌우 여백을 뺀 너비.
              width: 338,
              child: DeviceNotificationBanner(onTap: () {}),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
