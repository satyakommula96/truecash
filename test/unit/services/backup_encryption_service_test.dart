import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/core/services/backup_encryption_service.dart';

void main() {
  group('BackupEncryptionService', () {
    const password = 'test_password_123';
    const plainText = '{"key": "value", "secret": "data"}';

    test('encrypts and decrypts data correctly', () {
      final encryptedBody =
          BackupEncryptionService.encryptData(plainText, password);

      // Verify format (IV:Data)
      expect(encryptedBody.contains(':'), isTrue);
      expect(encryptedBody.split(':').length, 2);

      final decryptedData =
          BackupEncryptionService.decryptData(encryptedBody, password);
      expect(decryptedData, plainText);
    });

    test('different IVs for same data and password', () {
      final enc1 = BackupEncryptionService.encryptData(plainText, password);
      final enc2 = BackupEncryptionService.encryptData(plainText, password);

      expect(enc1, isNot(enc2));

      expect(BackupEncryptionService.decryptData(enc1, password), plainText);
      expect(BackupEncryptionService.decryptData(enc2, password), plainText);
    });

    test('fails decryption with wrong password', () {
      final encryptedBody =
          BackupEncryptionService.encryptData(plainText, password);

      expect(
        () => BackupEncryptionService.decryptData(
            encryptedBody, 'wrong_password'),
        throwsException,
      );
    });

    test('fails decryption with corrupted data', () {
      final encryptedBody =
          BackupEncryptionService.encryptData(plainText, password);
      final parts = encryptedBody.split(':');
      final corruptedBody = "${parts[0]}:corrupted_base64_data";

      expect(
        () => BackupEncryptionService.decryptData(corruptedBody, password),
        throwsException,
      );
    });

    test('fails decryption with invalid format', () {
      expect(
        () => BackupEncryptionService.decryptData(
            'invalid_format_no_colon', password),
        throwsException,
      );
    });
  });
}
