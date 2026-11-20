import 'package:chagok_mobile/features/archive/application/new_box_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewBoxForm.canSubmit', () {
    test('이름이 비어 있으면 false다', () {
      expect(const NewBoxForm().canSubmit, isFalse);
    });

    test('이름이 공백뿐이면 false다', () {
      expect(const NewBoxForm(name: '   ').canSubmit, isFalse);
    });

    test('이름을 적었으면 true다', () {
      expect(const NewBoxForm(name: '반려동물').canSubmit, isTrue);
    });

    test('만드는 중이면 이름이 있어도 false다', () {
      expect(const NewBoxForm(name: '반려동물', isSaving: true).canSubmit, isFalse);
    });
  });
}
