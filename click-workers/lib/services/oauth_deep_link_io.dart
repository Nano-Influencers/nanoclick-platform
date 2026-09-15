import 'package:app_links/app_links.dart';

import 'api_client.dart';

final Map<String, Future<void>> _oauthInFlight = <String, Future<void>>{};
final Set<String> _oauthHandled = <String>{};

Future<void> initializeNativeOAuthDeepLinks({
  Future<void> Function()? onAuthenticated,
}) async {
  final appLinks = AppLinks();

  Future<void> handle(Uri uri) async {
    if (uri.scheme != 'nanoclick' || uri.host != 'oauth') return;
    final code = uri.queryParameters['oauth_code']?.trim();
    if (code == null || code.isEmpty || _oauthHandled.contains(code)) return;

    final existing = _oauthInFlight[code];
    if (existing != null) {
      await existing;
      return;
    }

    final future = () async {
      try {
        await ApiClient.instance.exchangeOAuthCode(code, platform: 'app');
        _oauthHandled.add(code);
        await onAuthenticated?.call();
      } catch (_) {
        // Invalid/expired callbacks remain retryable, but are never exchanged
        // concurrently when the OS delivers the same deep link more than once.
      }
    }();

    _oauthInFlight[code] = future;
    try {
      await future;
    } finally {
      if (identical(_oauthInFlight[code], future)) {
        _oauthInFlight.remove(code);
      }
    }
  }

  final initial = await appLinks.getInitialLink();
  if (initial != null) {
    await handle(initial);
  }

  appLinks.uriLinkStream.listen(handle, onError: (_) {});
}
