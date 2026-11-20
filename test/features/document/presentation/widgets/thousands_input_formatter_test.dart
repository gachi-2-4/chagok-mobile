import 'package:chagok_mobile/features/document/presentation/widgets/thousands_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = ThousandsInputFormatter();

  TextEditingValue type(String text, int cursor) => formatter.formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursor),
    ),
  );

  group('ThousandsInputFormatter', () {
    test('끝에 숫자를 넣으면 쉼표를 다시 찍고 커서를 끝에 둔다', () {
      final value = type('500,0001', 8);

      expect(value.text, '5,000,001');
      expect(value.selection.baseOffset, 9);
    });

    test('중간에 숫자를 넣으면 넣은 숫자 바로 뒤에 커서를 둔다', () {
      // "500,000"의 첫 5 뒤에 1을 넣은 상태: "5100,000", 커서는 1 뒤(2)
      final value = type('5100,000', 2);

      expect(value.text, '5,100,000');
      expect(value.selection.baseOffset, 3);
    });

    test('중간 숫자를 지우면 지운 자리에 커서를 둔다', () {
      // "5,100,000"에서 1을 지운 상태: "5,00,000", 커서는 5 뒤 쉼표 다음(2)
      final value = type('5,00,000', 2);

      expect(value.text, '500,000');
      expect(value.selection.baseOffset, 1);
    });

    test('숫자를 모두 지우면 빈 글로 둔다', () {
      final value = type('', 0);

      expect(value.text, isEmpty);
      expect(value.selection.baseOffset, 0);
    });
  });
}
