import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'app_user.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}

/// Backend API client for Click Workers.
/// OAuth web callbacks use a short-lived one-time code; bearer tokens are
/// never placed in browser URLs.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

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
      if (detail is List) return detail.map((d) => d['msg']).join('; ');
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
      if (refreshed) return _request(method, path, body: body, auth: auth, retrying: true);
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

  Future<void> register({required String email, required String password, required String fullName, String? referralCode}) async {
    await _request('POST', '/auth/register', auth: false, body: {
      'email': email, 'password': password, 'full_name': fullName,
      'role': 'worker', 'referral_code': referralCode,
    });
  }

  Future<void> login(String email, String password) async {
    final data = await _request('POST', '/auth/login', auth: false, body: {'email': email, 'password': password});
    setTokens(access: data['access_token'], refresh: data['refresh_token']);
  }

  Future<AppUser> me() async => AppUser.fromJson(await _request('GET', '/auth/me') as Map<String, dynamic>);

  Future<void> logout() async {
    final refresh = _refreshToken;
    if (refresh != null) {
      try {
        await _request('POST', '/auth/logout', auth: false, body: {'refresh_token': refresh});
      } catch (_) {}
    }
    clearTokens();
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _request('POST', '/auth/change-password', body: {'current_password': currentPassword, 'new_password': newPassword});
  }

  Future<void> forgotPassword(String email) async => await _request('POST', '/auth/forgot-password', auth: false, body: {'email': email});

  Future<void> resetPassword(String token, String newPassword) async => await _request('POST', '/auth/reset-password', auth: false, body: {'token': token, 'new_password': newPassword});

  Future<void> deleteAccount() async => await _request('DELETE', '/auth/me');

  /// Browser OAuth callback returns oauth_code, which is exchanged server-side
  /// for bearer tokens. Tokens never appear in the redirect URL.
  String oauthUrl(String provider) {
    final origin = html.window.location.origin;
    final redirectUri = Uri.encodeComponent('$origin/');
    return '$baseUrl/auth/$provider/login?role=worker&platform=web&redirect_uri=$redirectUri';
  }

  Future<void> exchangeOAuthCode(String code) async {
    final data = await _request('POST', '/auth/oauth/exchange?code=${Uri.encodeQueryComponent(code)}', auth: false);
    setTokens(access: data['access_token'], refresh: data['refresh_token']);
  }

  // ---------------- wallet ----------------
  Future<Map<String, dynamic>> getWalletBalance() async => await _request('GET', '/wallet/balance') as Map<String, dynamic>;
  Future<Map<String, dynamic>> referralStats() async => await _request('GET', '/wallet/referral-stats') as Map<String, dynamic>;
  Future<List<dynamic>> getTransactions() async => await _request('GET', '/wallet/transactions') as List<dynamic>;
  Future<Map<String, dynamic>> initiateDeposit(double amountNgn) async => await _request('POST', '/wallet/deposit/initialize', body: {'amount_ngn': amountNgn}) as Map<String, dynamic>;
  Future<Map<String, dynamic>> resolveAccount(String bankCode, String accountNumber) async => await _request('GET', '/wallet/resolve-account?bank_code=$bankCode&account_number=$accountNumber') as Map<String, dynamic>;
  Future<Map<String, dynamic>> withdraw({required double amountNgn, required String bankCode, required String accountNumber}) async => await _request('POST', '/wallet/withdraw', body: {'amount_ngn': amountNgn, 'bank_code': bankCode, 'account_number': accountNumber}) as Map<String, dynamic>;
  Future<Map<String, dynamic>> spin() async => await _request('POST', '/wallet/spin') as Map<String, dynamic>;
  Future<Map<String, dynamic>> checkin() async => await _request('POST', '/wallet/checkin') as Map<String, dynamic>;

  // ---------------- tasks ----------------
  Future<List<dynamic>> listTasks() async => await _request('GET', '/tasks') as List<dynamic>;
  Future<Map<String, dynamic>> getTask(String taskId) async => await _request('GET', '/tasks/$taskId') as Map<String, dynamic>;
  Future<Map<String, dynamic>> acceptTask(String taskId) async => await _request('POST', '/tasks/$taskId/accept') as Map<String, dynamic>;
  Future<void> cancelAcceptance(String taskId) async => await _request('POST', '/tasks/$taskId/cancel');
  Future<Map<String, dynamic>> submitTask(String taskId, List<String> proofUrls, {String? proofLink}) async => await _request('POST', '/tasks/$taskId/submit', body: {'proof_urls': proofUrls, 'proof_link': proofLink}) as Map<String, dynamic>;
  Future<void> reportTask(String taskId, String reason) async => await _request('POST', '/tasks/$taskId/report', body: {'reason': reason});
  Future<List<dynamic>> mySubmissions({String? status}) async => await _request('GET', '/tasks/my-submissions${status != null ? '?status=$status' : ''}') as List<dynamic>;
  Future<List<dynamic>> leaderboard(String period) async => await _request('GET', '/tasks/leaderboard/$period') as List<dynamic>;
  Future<Map<String, dynamic>> myTaskStats() async => await _request('GET', '/tasks/my-stats') as Map<String, dynamic>;
  Future<Map<String, dynamic>> requestUploadUrl(String fileExtension) async => await _request('POST', '/tasks/upload-url', body: {'file_extension': fileExtension}) as Map<String, dynamic>;
  Future<void> uploadToPresignedUrl(String uploadUrl, List<int> bytes) async {
    final res = await http.put(Uri.parse(uploadUrl), body: bytes);
    if (res.statusCode < 200 || res.statusCode >= 300) throw ApiException('File upload failed (${res.statusCode})', res.statusCode);
  }

  // ---------------- KYC ----------------
  Future<void> submitKyc(Map<String, dynamic> fields) async => await _request('POST', '/kyc/submit', body: fields);
  Future<String> kycStatus() async => (await _request('GET', '/kyc/status') as Map<String, dynamic>)['status'] as String;

  // ---------------- rewards ----------------
  Future<Map<String, dynamic>> rewardsProgress() async => await _request('GET', '/rewards/progress') as Map<String, dynamic>;

  // ---------------- notifications ----------------
  Future<List<dynamic>> listNotifications() async => await _request('GET', '/notifications') as List<dynamic>;
  Future<int> unreadNotificationCount() async => (await _request('GET', '/notifications/unread-count') as Map<String, dynamic>)['count'] as int;
  Future<void> markNotificationRead(String id) async => await _request('POST', '/notifications/$id/read');
  Future<void> markAllNotificationsRead() async => await _request('POST', '/notifications/read-all');
}
