Future<Map<String, String?>> readTokens() async => const {
      'access': null,
      'refresh': null,
    };

Future<void> writeTokens({required String access, String? refresh}) async {}

Future<void> clearTokens() async {}

Future<Map<String, String?>> restoreSession(String baseUrl) async => const {
      'access': null,
      'refresh': null,
    };

String currentOrigin() => Uri.base.origin;

void replaceBrowserUrl(String path) {}
