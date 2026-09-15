import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_http_client.dart';
import 'app_user.dart';
import 'token_storage_stub.dart'
    if (dart.library.html) 'token_storage_web.dart'
    if (dart.library.io) 'token_storage_io.dart' as storage;

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
  static const Duration requestTimeout = Duration(seconds: 20);
  final http.Client _client = createApiHttpClient();
  String? _accessToken;
  String? _refreshToken;
  bool _initialized = false;
  Future<bool>? _refreshInFlight;
  static int _requestSequence = 0;

  bool get isLoggedIn => _accessToken != null;
  String get _authPlatform => storage.isWeb ? 'web' : 'app';

  Future<void> initialize() async {
    if (_initialized) return;
    final tokens = await storage.readTokens();
    _accessToken = tokens['access'];
    _refreshToken = tokens['refresh'];
    _initialized = true;
    if (_accessToken == null) {
      final restored = await storage.restoreSession(baseUrl);
      _accessToken = restored['access'];
      _refreshToken = restored['refresh'];
    }
  }

  Future<void> setTokens({required String access, String? refresh}) async {
    _accessToken = access;
    _refreshToken = refresh;
    await storage.writeTokens(access: access, refresh: refresh);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _refreshInFlight = null;
    await storage.clearTokens();
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  String _requestId() {
    _requestSequence = (_requestSequence + 1) & 0x7fffffff;
    return 'nano-${DateTime.now().microsecondsSinceEpoch}-$_requestSequence';
  }

  String _idempotencyKey() {
    _requestSequence = (_requestSequence + 1) & 0x7fffffff;
    return 'nano-${DateTime.now().microsecondsSinceEpoch}-$_requestSequence';
  }

  String createIdempotencyKey() => _idempotencyKey();

  String _validatedIdempotencyKey(String? key) {
    final value = key?.trim();
    if (value == null || value.isEmpty) return _idempotencyKey();
    if (value.length > 100) throw ApiException('Idempotency key must be 100 characters or fewer.', 400);
    return value;
  }

  String _extractError(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      final detail = body is Map ? body['detail'] : null;
      if (detail is List) return detail.map((d) => d is Map ? d['msg']?.toString() : d.toString()).join('; ');
      if (detail is String) return detail;
    } catch (_) {}
    return 'Something went wrong (${res.statusCode})';
  }

  Future<http.Response> _send(Future<http.Response> operation) async {
    try {
      return await operation.timeout(requestTimeout);
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.', 408);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException('Unable to reach the server. Check your connection and try again.', 0);
    }
  }

  Future<dynamic> _request(String method, String path, {Map<String, dynamic>? body, bool auth = true, bool retrying = false, Map<String, String>? extraHeaders}) async {
    final headers = {'Content-Type': 'application/json', 'X-Request-ID': _requestId(), ...?extraHeaders};
    if (auth && _accessToken != null) headers['Authorization'] = 'Bearer $_accessToken';
    final uri = _uri(path);
    final encodedBody = body != null ? jsonEncode(body) : null;
    late final Future<http.Response> operation;
    switch (method) {
      case 'POST': operation = _client.post(uri, headers: headers, body: encodedBody); break;
      case 'PATCH': operation = _client.patch(uri, headers: headers, body: encodedBody); break;
      case 'DELETE': operation = _client.delete(uri, headers: headers, body: encodedBody); break;
      default: operation = _client.get(uri, headers: headers);
    }
    final res = await _send(operation);
    if (res.statusCode == 401 && auth && !retrying) {
      final refreshed = await _tryRefresh();
      if (refreshed) return _request(method, path, body: body, auth: auth, retrying: true, extraHeaders: extraHeaders);
      await clearTokens();
      throw ApiException('Session expired — please log in again.', 401);
    }
    if (res.statusCode < 200 || res.statusCode >= 300) throw ApiException(_extractError(res), res.statusCode);
    if (res.body.isEmpty) return null;
    try {
      return jsonDecode(res.body);
    } catch (_) {
      throw ApiException('The server returned an invalid response.', 502);
    }
  }

  Future<bool> _tryRefresh() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;
    final future = _performRefresh(_refreshToken);
    _refreshInFlight = future;
    return future.whenComplete(() {
      if (identical(_refreshInFlight, future)) _refreshInFlight = null;
    });
  }

  Future<bool> _performRefresh(String? refresh) async {
    try {
      if (storage.isWeb) {
        final res = await _send(_client.post(
          _uri('/auth/refresh?platform=web'),
          headers: {'Content-Type': 'application/json', 'X-Request-ID': _requestId()},
        ));
        if (res.statusCode != 200) return false;
        final data = jsonDecode(res.body);
        final access = data is Map ? data['access_token'] : null;
        if (access is! String || access.isEmpty) return false;
        await setTokens(access: access, refresh: null);
        return true;
      }

      if (refresh == null || refresh.isEmpty) {
        final restored = await storage.restoreSession(baseUrl);
        final access = restored['access'];
        if (access is! String || access.isEmpty) return false;
        await setTokens(access: access, refresh: restored['refresh']);
        return true;
      }

      final res = await _send(_client.post(
        _uri('/auth/refresh?platform=app'),
        headers: {'Content-Type': 'application/json', 'X-Request-ID': _requestId()},
        body: jsonEncode({'refresh_token': refresh}),
      ));
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body);
      final access = data['access_token'];
      final nextRefresh = data['refresh_token'];
      if (access is! String || nextRefresh is! String || access.isEmpty || nextRefresh.isEmpty) return false;
      await setTokens(access: access, refresh: nextRefresh);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> register({required String email, required String password, required String fullName, String? referralCode}) async => await _request('POST', '/auth/register', auth: false, body: {'email': email, 'password': password, 'full_name': fullName, 'role': 'worker', 'referral_code': referralCode});
  Future<void> login(String email, String password) async { final data = await _request('POST', '/auth/login?platform=$_authPlatform', auth: false, body: {'email': email, 'password': password}); await setTokens(access: data['access_token'], refresh: data['refresh_token']); }
  Future<AppUser> me() async => AppUser.fromJson(await _request('GET', '/auth/me') as Map<String, dynamic>);
  Future<void> logout() async { try { await _request('POST', '/auth/logout?platform=$_authPlatform', auth: false); } catch (_) {} await clearTokens(); }
  Future<void> changePassword(String currentPassword, String newPassword) async => await _request('POST', '/auth/change-password', body: {'current_password': currentPassword, 'new_password': newPassword});
  Future<void> forgotPassword(String email) async => await _request('POST', '/auth/forgot-password', auth: false, body: {'email': email});
  Future<void> resetPassword(String token, String newPassword) async => await _request('POST', '/auth/reset-password', auth: false, body: {'token': token, 'new_password': newPassword});
  Future<void> deleteAccount() async => await _request('DELETE', '/auth/me');
  String oauthUrl(String provider, {String platform = 'web'}) { if (platform == 'app') return '$baseUrl/auth/$provider/login?role=worker&platform=app'; final origin = storage.currentOrigin(); final redirectUri = Uri.encodeComponent('$origin/'); return '$baseUrl/auth/$provider/login?role=worker&platform=web&redirect_uri=$redirectUri'; }
  Future<void> exchangeOAuthCode(String code, {String? platform}) async { final target = platform ?? _authPlatform; final data = await _request('POST', '/auth/oauth/exchange?code=${Uri.encodeQueryComponent(code)}&platform=$target', auth: false); await setTokens(access: data['access_token'], refresh: data['refresh_token']); }
  Future<Map<String, dynamic>> getWalletBalance() async => await _request('GET', '/wallet/balance') as Map<String, dynamic>;
  Future<Map<String, dynamic>> referralStats() async => await _request('GET', '/wallet/referral-stats') as Map<String, dynamic>;
  Future<List<dynamic>> getTransactions({int limit = 50, int offset = 0}) async { final query = Uri(queryParameters: {'limit': '$limit', 'offset': '$offset'}).query; return await _request('GET', '/wallet/transactions?$query') as List<dynamic>; }
  Future<Map<String, dynamic>> initiateDeposit(double amountNgn, {String? idempotencyKey}) async => await _request('POST', '/wallet/deposit/initialize', body: {'amount_ngn': amountNgn}, extraHeaders: {'Idempotency-Key': _validatedIdempotencyKey(idempotencyKey)}) as Map<String, dynamic>;
  Future<Map<String, dynamic>> resolveAccount(String bankCode, String accountNumber) async => await _request('GET', '/wallet/resolve-account?bank_code=${Uri.encodeQueryComponent(bankCode)}&account_number=${Uri.encodeQueryComponent(accountNumber)}') as Map<String, dynamic>;
  Future<Map<String, dynamic>> withdraw({required double amountNgn, required String bankCode, required String accountNumber, String? idempotencyKey}) async => await _request('POST', '/wallet/withdraw', body: {'amount_ngn': amountNgn, 'bank_code': bankCode, 'account_number': accountNumber}, extraHeaders: {'Idempotency-Key': _validatedIdempotencyKey(idempotencyKey)}) as Map<String, dynamic>;
  Future<List<dynamic>> getWithdrawals({int limit = 50, int offset = 0}) async { final query = Uri(queryParameters: {'limit': '$limit', 'offset': '$offset'}).query; return await _request('GET', '/wallet/withdrawals?$query') as List<dynamic>; }
  Future<Map<String, dynamic>> spin() async => await _request('POST', '/wallet/spin') as Map<String, dynamic>;
  Future<Map<String, dynamic>> checkin() async => await _request('POST', '/wallet/checkin') as Map<String, dynamic>;
  Future<List<dynamic>> listTasks({String? category, String? difficulty, bool? isHighEarning, bool? isUrgent, String? platform, int limit = 50, int offset = 0}) async {
    final queryParameters = <String, String>{'limit': '$limit', 'offset': '$offset'};
    if (category != null && category.isNotEmpty) queryParameters['category'] = category;
    if (difficulty != null && difficulty.isNotEmpty) queryParameters['difficulty'] = difficulty;
    if (isHighEarning != null) queryParameters['is_high_earning'] = '$isHighEarning';
    if (isUrgent != null) queryParameters['is_urgent'] = '$isUrgent';
    if (platform != null && platform.isNotEmpty) queryParameters['platform'] = platform;
    final query = Uri(queryParameters: queryParameters).query;
    return await _request('GET', '/tasks?$query') as List<dynamic>;
  }
  Future<Map<String, dynamic>> getTask(String taskId) async => await _request('GET', '/tasks/$taskId') as Map<String, dynamic>;
  Future<Map<String, dynamic>> acceptTask(String taskId) async => await _request('POST', '/tasks/$taskId/accept') as Map<String, dynamic>;
  Future<void> cancelAcceptance(String taskId) async => await _request('POST', '/tasks/$taskId/cancel');
  Future<Map<String, dynamic>> submitTask(String taskId, List<String> proofUrls, {String? proofLink}) async => await _request('POST', '/tasks/$taskId/submit', body: {'proof_urls': proofUrls, 'proof_link': proofLink}) as Map<String, dynamic>;
  Future<void> reportTask(String taskId, String reason) async => await _request('POST', '/tasks/$taskId/report', body: {'reason': reason});
  Future<List<dynamic>> mySubmissions({String? taskId, String? status, int limit = 50, int offset = 0}) async { final queryParameters = <String, String>{'limit': '$limit', 'offset': '$offset'}; if (taskId != null) queryParameters['task_id'] = taskId; if (status != null) queryParameters['status'] = status; final query = Uri(queryParameters: queryParameters).query; return await _request('GET', '/tasks/my-submissions?$query') as List<dynamic>; }
  Future<List<dynamic>> leaderboard(String period) async => await _request('GET', '/tasks/leaderboard/${Uri.encodeComponent(period)}') as List<dynamic>;
  Future<Map<String, dynamic>> myTaskStats() async => await _request('GET', '/tasks/my-stats') as Map<String, dynamic>;
  Future<Map<String, dynamic>> requestUploadUrl(String fileExtension) async => await _request('POST', '/tasks/upload-url', body: {'file_extension': fileExtension}) as Map<String, dynamic>;
  Future<String> proofDownloadUrl(String fileKey) async { final encodedKey = Uri.encodeQueryComponent(fileKey); final data = await _request('GET', '/tasks/proof-url?file_key=$encodedKey') as Map<String, dynamic>; return data['download_url'] as String; }
  Future<void> uploadToPresignedUrl(String uploadUrl, List<int> bytes, {required String contentType}) async { final res = await _send(_client.put(Uri.parse(uploadUrl), headers: {'Content-Type': contentType, 'X-Request-ID': _requestId()}, body: bytes)); if (res.statusCode < 200 || res.statusCode >= 300) throw ApiException('File upload failed (${res.statusCode})', res.statusCode); }
  Future<Map<String, dynamic>> requestKycUploadUrl(String fileExtension) async => await _request('POST', '/kyc/upload-url?file_extension=${Uri.encodeQueryComponent(fileExtension)}') as Map<String, dynamic>;
  Future<void> submitKyc(Map<String, dynamic> fields) async => await _request('POST', '/kyc/submit', body: fields);
  Future<String> kycStatus() async => (await _request('GET', '/kyc/status') as Map<String, dynamic>)['status'] as String;
  Future<Map<String, dynamic>> rewardsProgress() async => await _request('GET', '/rewards/progress') as Map<String, dynamic>;
  Future<List<dynamic>> listNotifications({bool unreadOnly = false, int limit = 50, int offset = 0}) async { final query = Uri(queryParameters: {'unread_only': '$unreadOnly', 'limit': '$limit', 'offset': '$offset'}).query; return await _request('GET', '/notifications?$query') as List<dynamic>; }
  Future<int> unreadNotificationCount() async => (await _request('GET', '/notifications/unread-count') as Map<String, dynamic>)['count'] as int;
  Future<void> markNotificationRead(String id) async => await _request('POST', '/notifications/$id/read');
  Future<void> markAllNotificationsRead() async => await _request('POST', '/notifications/read-all');
}
