import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'app_user.dart';

/// Thrown by [ApiClient] on any non-2xx response. [message] is already
/// human-readable (extracted from FastAPI's `detail` field where possible).
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}

/// Replaces Firebase Auth + direct Firestore reads/writes with calls to the
/// NanoClick backend. This is a plain, non-widget class (no BuildContext
/// dependency) so it can be used from anywhere, the same way the old
/// `FirebaseAuth.instance` / `FirebaseFirestore.instance` singletons were.
///
/// Token storage uses `dart:html`'s localStorage directly rather than a new
/// pub package: this app is web-only already (see the old
/// firebase_options.dart, which threw UnsupportedError for every other
/// platform), so there's no cross-platform storage need to plan for.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  /// Overridden at build time with --dart-define=API_BASE_URL=... for a
  /// real deployment; defaults to the local dev backend otherwise.
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');

  static const _accessKey = 'nano_access_token';
  static const _refreshKey = 'nano_refresh_token';

  String? get _accessToken => html.window.localStorage[_accessKey];
  String? get _refreshToken => html.window.localStorage[_refreshKey];

  bool get isLoggedIn => _accessToken != null;

  void setTokens({required String access, required String refresh}) {
    html.window.localStorage[_accessKey] = access;
    html.window.localStorage[_refreshKey] = refresh;
  }

  void clearTokens() {
    html.window.localStorage.remove(_accessKey);
    html.window.localStorage.remove(_refreshKey);
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  String _extractError(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      final detail = body is Map ? body['detail'] : null;
      if (detail is List) {
        // FastAPI/pydantic validation error shape
        return detail.map((d) => d['msg']).join('; ');
      }
      if (detail is String) return detail;
    } catch (_) {}
    return 'Something went wrong (${res.statusCode})';
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
    bool retrying = false,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    final uri = _uri(path);
    final encodedBody = body != null ? jsonEncode(body) : null;

    http.Response res;
    switch (method) {
      case 'POST':
        res = await http.post(uri, headers: headers, body: encodedBody);
        break;
      case 'PATCH':
        res = await http.patch(uri, headers: headers, body: encodedBody);
        break;
      case 'DELETE':
        res = await http.delete(uri, headers: headers, body: encodedBody);
        break;
      default:
        res = await http.get(uri, headers: headers);
    }

    if (res.statusCode == 401 && auth && !retrying) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        return _request(method, path, body: body, auth: auth, retrying: true);
      }
      clearTokens();
      throw ApiException('Session expired — please log in again.', 401);
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(_extractError(res), res.statusCode);
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }

  Future<bool> _tryRefresh() async {
    final refresh = _refreshToken;
    if (refresh == null) return false;
    try {
      final res = await http.post(
        _uri('/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refresh}),
      );
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body);
      setTokens(access: data['access_token'], refresh: data['refresh_token']);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------------- auth ----------------

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? referralCode,
  }) async {
    await _request('POST', '/auth/register', auth: false, body: {
      'email': email,
      'password': password,
      'full_name': fullName,
      'role': 'worker',
      'referral_code': referralCode,
    });
  }

  Future<void> login(String email, String password) async {
    final data = await _request('POST', '/auth/login', auth: false, body: {
      'email': email,
      'password': password,
    });
    setTokens(access: data['access_token'], refresh: data['refresh_token']);
  }

  Future<AppUser> me() async {
    final data = await _request('GET', '/auth/me');
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    clearTokens();
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _request('POST', '/auth/change-password', body: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  Future<void> forgotPassword(String email) async {
    await _request('POST', '/auth/forgot-password', auth: false, body: {'email': email});
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _request('POST', '/auth/reset-password', auth: false, body: {
      'token': token,
      'new_password': newPassword,
    });
  }

  Future<void> deleteAccount() async {
    await _request('DELETE', '/auth/me');
  }

  /// Builds the URL to redirect the browser to for Google/Facebook login.
  /// This app has no client-side router (main() just reads
  /// Uri.base.queryParameters once at startup — the same pattern the old
  /// Firebase password-reset oobCode flow already used), so the backend is
  /// told to send the browser straight back to this app's own root URL with
  /// the tokens as query params, rather than to a sub-route.
  String oauthUrl(String provider) {
    final origin = html.window.location.origin;
    final redirectUri = Uri.encodeComponent('$origin/');
    return '$baseUrl/auth/$provider/login?role=worker&platform=web&redirect_uri=$redirectUri';
  }

  // ---------------- wallet ----------------

  Future<Map<String, dynamic>> getWalletBalance() async =>
      await _request('GET', '/wallet/balance') as Map<String, dynamic>;

  Future<Map<String, dynamic>> referralStats() async =>
      await _request('GET', '/wallet/referral-stats') as Map<String, dynamic>;

  Future<List<dynamic>> getTransactions() async =>
      await _request('GET', '/wallet/transactions') as List<dynamic>;

  Future<Map<String, dynamic>> initiateDeposit(double amountNgn) async =>
      await _request('POST', '/wallet/deposit/initialize', body: {'amount_ngn': amountNgn})
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> resolveAccount(String bankCode, String accountNumber) async =>
      await _request('GET', '/wallet/resolve-account?bank_code=$bankCode&account_number=$accountNumber')
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> withdraw({
    required double amountNgn,
    required String bankCode,
    required String accountNumber,
  }) async =>
      await _request('POST', '/wallet/withdraw', body: {
        'amount_ngn': amountNgn,
        'bank_code': bankCode,
        'account_number': accountNumber,
      }) as Map<String, dynamic>;

  Future<Map<String, dynamic>> spin() async =>
      await _request('POST', '/wallet/spin') as Map<String, dynamic>;

  Future<Map<String, dynamic>> checkin() async =>
      await _request('POST', '/wallet/checkin') as Map<String, dynamic>;

  // ---------------- tasks ----------------

  Future<List<dynamic>> listTasks() async =>
      await _request('GET', '/tasks') as List<dynamic>;

  Future<Map<String, dynamic>> getTask(String taskId) async =>
      await _request('GET', '/tasks/$taskId') as Map<String, dynamic>;

  Future<Map<String, dynamic>> acceptTask(String taskId) async =>
      await _request('POST', '/tasks/$taskId/accept') as Map<String, dynamic>;

  Future<void> cancelAcceptance(String taskId) async {
    await _request('POST', '/tasks/$taskId/cancel');
  }

  Future<Map<String, dynamic>> submitTask(String taskId, List<String> proofUrls, {String? proofLink}) async =>
      await _request('POST', '/tasks/$taskId/submit', body: {
        'proof_urls': proofUrls,
        'proof_link': proofLink,
      }) as Map<String, dynamic>;

  Future<void> reportTask(String taskId, String reason) async {
    await _request('POST', '/tasks/$taskId/report', body: {'reason': reason});
  }

  Future<List<dynamic>> mySubmissions({String? status}) async {
    final qp = status != null ? '?status=$status' : '';
    return await _request('GET', '/tasks/my-submissions$qp') as List<dynamic>;
  }

  Future<List<dynamic>> leaderboard(String period) async =>
      await _request('GET', '/tasks/leaderboard/$period') as List<dynamic>;

  Future<Map<String, dynamic>> myTaskStats() async =>
      await _request('GET', '/tasks/my-stats') as Map<String, dynamic>;

  Future<Map<String, dynamic>> requestUploadUrl(String filename, String contentType) async =>
      await _request('POST', '/tasks/upload-url', body: {
        'filename': filename,
        'content_type': contentType,
      }) as Map<String, dynamic>;

  // ---------------- KYC ----------------

  Future<void> submitKyc(Map<String, dynamic> fields) async {
    await _request('POST', '/kyc/submit', body: fields);
  }

  Future<String> kycStatus() async {
    final data = await _request('GET', '/kyc/status') as Map<String, dynamic>;
    return data['status'] as String;
  }

  // ---------------- rewards ----------------

  Future<Map<String, dynamic>> rewardsProgress() async =>
      await _request('GET', '/rewards/progress') as Map<String, dynamic>;

  // ---------------- notifications ----------------

  Future<List<dynamic>> listNotifications() async =>
      await _request('GET', '/notifications') as List<dynamic>;

  Future<int> unreadNotificationCount() async {
    final data = await _request('GET', '/notifications/unread-count') as Map<String, dynamic>;
    return data['count'] as int;
  }

  Future<void> markNotificationRead(String id) async {
    await _request('POST', '/notifications/$id/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _request('POST', '/notifications/read-all');
  }
}
