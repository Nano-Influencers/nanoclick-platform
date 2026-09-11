import 'package:http/browser_client.dart';

String? _accessToken;

Future<Map<String, String?>> readTokens() async => {
      'access': _accessToken,
      // Refresh tokens are HttpOnly cookies on web and are intentionally
      // never exposed to Dart/JavaScript.
      'refresh': null,
    };

Future<void> writeTokens({required String access, required String refresh}) async {
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
    // Avoid importing JSON parsing into the storage abstraction's public API.
    final body = res.body;
    final marker = '"access_token":"';
    final start = body.indexOf(marker);
    if (start < 0) return const {'access': null, 'refresh': null};
    final valueStart = start + marker.length;
    final valueEnd = body.indexOf('"', valueStart);
    if (valueEnd <= valueStart) return const {'access': null, 'refresh': null};
    _accessToken = body.substring(valueStart, valueEnd);
    return {'access': _accessToken, 'refresh': null};
  } finally {
    client.close();
  }
}

String currentOrigin() => Uri.base.origin;

void replaceBrowserUrl(String path) {
  // OAuth callback URL cleanup is handled by the existing browser history path.
}
