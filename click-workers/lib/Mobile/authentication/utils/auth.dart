import 'dart:async';
import 'package:flutter/material.dart';
import 'package:click_workers/Mobile/authentication/utils/user.dart';
import 'package:click_workers/services/api_client.dart';
import 'package:click_workers/services/app_user.dart';

/// Replaces Firebase Auth + the Firestore user/wallet/leaderboard
/// bootstrapping this class used to do on every sign-up. The backend's
/// POST /auth/register already creates the user + wallet atomically in one
/// request, so none of that client-side bootstrapping is needed anymore.
///
/// AuthProvider instances share one app-wide auth stream and cached user,
/// matching the old Firebase-backed behavior where FirebaseAuth.instance was
/// globally shared.
class AuthProvider with ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  static AppUser? _cachedUser;
  AppUser? get currentUser => _cachedUser;

  bool refreshFav = false;

  static final StreamController<AppUser?> _userController = StreamController<AppUser?>.broadcast();
  Stream<AppUser?> get user_ => _userController.stream;

  static bool _sessionRestored = false;
  static Future<void>? _restoreInFlight;

  AuthProvider() {
    if (!_sessionRestored) {
      _sessionRestored = true;
      _restoreSession();
    }
  }

  /// Re-checks auth state after login/OAuth. If an older startup restore is
  /// already running, wait for it first and then perform a fresh read so the
  /// old result cannot overwrite the newly authenticated session.
  Future<void> refreshSessionSilently() => _restoreSession(force: true);

  Future<void> _restoreSession({bool force = false}) async {
    final inFlight = _restoreInFlight;
    if (inFlight != null) {
      if (!force) return inFlight;
      try {
        await inFlight;
      } catch (_) {
        // A failed startup restore must not prevent a fresh post-login check.
      }
    }

    final next = _performRestoreSession();
    _restoreInFlight = next;
    try {
      await next;
    } finally {
      if (identical(_restoreInFlight, next)) _restoreInFlight = null;
    }
  }

  Future<void> _performRestoreSession() async {
    if (!_api.isLoggedIn) {
      _cachedUser = null;
      _userController.add(null);
      return;
    }
    try {
      _cachedUser = await _api.me();
      _userController.add(_cachedUser);
    } catch (_) {
      // Stored tokens are invalid/expired and couldn't be refreshed.
      await _api.logout();
      _cachedUser = null;
      _userController.add(null);
    }
  }

  void updateVar() {
    refreshFav = true;
    notifyListeners();
  }

  // ---- password reset ----------------------------------------------------

  Future<String?> forgotPassword(String email) async {
    try {
      await _api.forgotPassword(email);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return "Something went wrong";
    }
  }

  Future<String?> confirmPasswordReset(String oobCode, String newPassword) async {
    try {
      await _api.resetPassword(oobCode, newPassword);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return "Something went wrong";
    }
  }

  Future<void> reload() async {}

  // ---- sign in / sign up --------------------------------------------------

  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _api.login(email, password);
      await _restoreSession(force: true);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return "Something went wrong";
    }
  }

  Future<dynamic> registerWithEmailAndPassword(String email, String password, String fullName) async {
    try {
      await _api.register(email: email, password: password, fullName: fullName);
      await _api.login(email, password);
      await _restoreSession(force: true);
      return UserId();
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return "Something went wrong";
    }
  }

  // ---- sign out / delete ---------------------------------------------------

  Future<void> signOut() async {
    await _api.logout();
    _cachedUser = null;
    _userController.add(null);
  }

  Future<String?> attemptPasswordChange({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_cachedUser == null) return "User not logged in";
    try {
      await _api.changePassword(currentPassword, newPassword);
      return "";
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return "Something went wrong. Try again later.";
    }
  }

  Future<String?> deleteAccount() async {
    try {
      await _api.deleteAccount();
      await signOut();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return "Something went wrong. Try again later.";
    }
  }

  // Deliberately does NOT close _userController: it is an app-wide stream.
}
