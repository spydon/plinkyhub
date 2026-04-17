import 'package:plinkyhub/widgets/update_password_dialog.dart';
import 'package:test/test.dart';

void main() {
  group('validateNewPassword', () {
    test('rejects an empty password', () {
      expect(validateNewPassword('', ''), isNotNull);
      expect(validateNewPassword('', ''), contains('enter a new password'));
    });

    test('rejects passwords below the minimum length', () {
      final short = 'a' * (minimumPasswordLength - 1);
      final error = validateNewPassword(short, short);
      expect(error, isNotNull);
      expect(error, contains('at least $minimumPasswordLength characters'));
    });

    test('rejects mismatched confirmation', () {
      final password = 'a' * minimumPasswordLength;
      final error = validateNewPassword(password, '${password}different');
      expect(error, 'Passwords do not match.');
    });

    test('accepts a valid password at exactly the minimum length', () {
      final password = 'a' * minimumPasswordLength;
      expect(validateNewPassword(password, password), isNull);
    });

    test('accepts a longer valid password', () {
      const password = 'supersecret123';
      expect(validateNewPassword(password, password), isNull);
    });
  });
}
