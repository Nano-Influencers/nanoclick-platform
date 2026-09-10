Future<Map<String, String?>> readTokens() async => const {
      'access': null,
      'refresh': null,
    };

Future<void> writeTokens({required String access, required String refresh}) async {}

Future<void> clearTokens() async {}

String currentOrigin() => Uri.base.origin;

void replaceBrowserUrl(String path) {}
