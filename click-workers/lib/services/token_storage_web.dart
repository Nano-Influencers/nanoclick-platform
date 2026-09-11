import 'dart:convert';
import 'package:http/browser_client.dart';

String? _accessToken;

Future<Map<String, String?>> readTokens() async => {
      'access': _accessToken,
      'refresh': null,
    };

Future<void> writeTokens({required String access, String? refresh}) async {
  _accessToken = access;
}

Future<void> clearTokens() async {
  _accessToken = null;
}

Future<Map<String, String?>> restoreSession(String baseUrl) async {
  final client = BrowserClient()..withCredentials = true;
  try {
    final res = await client.post(Uri.parse('$baseUrl/auth/refresh?platform=web'));
    if (res.statusCode != 200) return const {'access': null, 'refresh': null};
    final body = jsonDecode(res.body);
    final access = body is Map ? body['access_token'] : null;
    if (access is! String || access.isEmpty) {
      return const {'access': null, 'refresh': null};
    }
    _accessToken = access;
    return {'access': access, 'refresh': null};
  } finally {
    client.close();
  }
}

String currentOrigin() => Uri.base.origin;

void replaceBrowserUrl(String path) {}
