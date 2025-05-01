import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';

class CredentialManager {
  static const _storage = FlutterSecureStorage();
  static const _encryptionKeyAlias = 'encryption_key';
  static const _ivAlias = 'encryption_iv';

  static Future<(Encrypter, IV)> _getEncrypterAndIV() async {
    final key = await _getOrCreateEncryptionKey();
    final iv = await _getOrCreateIV();
    return (
      Encrypter(AES(Key.fromBase64(key), mode: AESMode.cbc)),
      IV.fromBase64(iv)
    );
  }

  static Future<String> _getOrCreateEncryptionKey() async {
    String? key = await _storage.read(key: _encryptionKeyAlias);
    if (key == null) {
      key = Key.fromSecureRandom(32).base64;
      await _storage.write(key: _encryptionKeyAlias, value: key);
    }
    return key;
  }

  static Future<String> _getOrCreateIV() async {
    String? iv = await _storage.read(key: _ivAlias);
    if (iv == null) {
      iv = IV.fromSecureRandom(16).base64;
      await _storage.write(key: _ivAlias, value: iv);
    }
    return iv;
  }

  static Future<void> storeCredentials({
    required String clientId,
    required String clientSecret,
    required String refreshToken,
  }) async {
    try {
      final (encrypter, iv) = await _getEncrypterAndIV();

      await Future.wait([
        _storage.write(
          key: 'client_id',
          value: encrypter.encrypt(clientId, iv: iv).base64,
        ),
        _storage.write(
          key: 'client_secret',
          value: encrypter.encrypt(clientSecret, iv: iv).base64,
        ),
        _storage.write(
          key: 'refresh_token',
          value: encrypter.encrypt(refreshToken, iv: iv).base64,
        ),
      ]);
    } on PlatformException catch (e) {
      throw Exception('Secure storage error: ${e.message}');
    }
  }

  static Future<Map<String, String>> getCredentials() async {
    try {
      final (encrypter, iv) = await _getEncrypterAndIV();
      final values = await _storage.readAll();

      if (values.isEmpty) {
        throw Exception('No credentials stored');
      }

      return {
        'clientId': encrypter.decrypt64(values['client_id']!, iv: iv),
        'clientSecret': encrypter.decrypt64(values['client_secret']!, iv: iv),
        'refreshToken': encrypter.decrypt64(values['refresh_token']!, iv: iv),
      };
    } on PlatformException catch (e) {
      throw Exception('Failed to read credentials: ${e.message}');
    }
  }

  static Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }
}
