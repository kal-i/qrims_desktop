import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionUtils {
  static final encrypt.Key key = encrypt.Key.fromLength(32);
  static final encrypt.IV iv = encrypt.IV.fromLength(16);
  static final encrypt.Encrypter encrypter = encrypt.Encrypter(encrypt.AES(key));

  static String encryptId(String id) {
    return encrypter.encrypt(id, iv: iv).base64;
  }

  static String decryptId(String encryptedId) {
    return encrypter.decrypt64(encryptedId, iv: iv);
  }
}