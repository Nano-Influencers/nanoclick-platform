import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _accessKey = 'nano_access_token';
const _refreshKey = 'nano_refresh_token';

const _storage = FlutterSecureStorage();

Future<Map<String, String?>> readTokens() async => {
      'access': await _storage.read(key: _accessKey),
      'refresh': await _storage.read(key: _refreshKey),
    };

Future<void> writeTokens({required String access, required String refresh}) async {
  await _storage.write(key: _accessKey, value: access);
  await _storage.write(key: _refreshKey, value: refresh);
}

Future<void> clearTokens() async {
  await _storage.delete(key: _accessKey);
  await _storage.delete(key: _refreshKey);
}

String currentOrigin() => Uri.base.origin;

void replaceBrowserUrl(String path) {}
