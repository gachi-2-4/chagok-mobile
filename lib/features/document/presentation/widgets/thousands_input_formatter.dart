import 'package:chagok_mobile/features/document/presentation/document_strings.dart';
import 'package:flutter/services.dart';

/// 숫자만 남기고 세 자리마다 쉼표를 넣는 입력 규칙. 예: "500000" → "500,000"
///
/// 쉼표를 다시 찍어도 커서는 사용자가 고친 숫자 바로 뒤에 둡니다. 중간을
/// 고칠 때 커서가 끝으로 튀지 않게 하기 위해서입니다.
class ThousandsInputFormatter extends TextInputFormatter {
  const ThousandsInputFormatter();

  static final _nonDigit = RegExp(r'\D');

  /// [text]에서 숫자만 남겨 세 자리마다 쉼표를 넣습니다. 숫자가 없으면 빈 글.
  static String format(String text) {
    final value = int.tryParse(text.replaceAll(_nonDigit, ''));
    return value == null ? '' : DocumentStrings.amount(value);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = format(newValue.text);
    final cursor = newValue.selection.isValid
        ? newValue.selection.baseOffset.clamp(0, newValue.text.length)
        : newValue.text.length;
    final digitsBeforeCursor = newValue.text
        .substring(0, cursor)
        .replaceAll(_nonDigit, '')
        .length;

    // 바꾼 글에서 커서 앞 숫자 개수만큼 지난 자리에 커서를 둡니다.
    var offset = 0;
    var seenDigits = 0;
    while (offset < text.length && seenDigits < digitsBeforeCursor) {
      if (!_nonDigit.hasMatch(text[offset])) seenDigits++;
      offset++;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
