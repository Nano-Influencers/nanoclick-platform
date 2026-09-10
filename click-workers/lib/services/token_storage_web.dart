import 'dart:html' as html;

const _accessKey = 'nano_access_token';
const _refreshKey = 'nano_refresh_token';

Future<Map<String, String?>> readTokens() async => {
      'access': html.window.localStorage[_accessKey],
      'refresh': html.window.localStorage[_refreshKey],
    };

Future<void> writeTokens({required String access, required String refresh}) async {
  html.window.localStorage[_accessKey] = access;
  html.window.localStorage[_refreshKey] = refresh;
}

Future<void> clearTokens() async {
  html.window.localStorage.remove(_accessKey);
  html.window.localStorage.remove(_refreshKey);
}

String currentOrigin() => html.window.location.origin;

void replaceBrowserUrl(String path) {
  html.window.history.replaceState(null, '', path);
}
