import 'dart:async';
import 'package:flutter/material.dart';
import 'package:click_workers/Mobile/authentication/utils/user.dart';
import 'package:click_workers/services/api_client.dart';
import 'package:click_workers/services/app_user.dart';

/// Replaces Firebase Auth + the Firestore user/wallet/leaderboard
/// bootstrapping this class used to do on every sign-up. The backend's
/// POST /auth/register already creates the user + wallet atomically in one
/// request (see app/routers/auth.py), so none of that client-side
/// bootstrapping is needed anymore — registerWithEmailAndPassword is the
/// entire signup now, not the first of five separate calls.
///
/// Method names and return-value conventions are kept identical to the old
/// Firebase-backed version wherever call sites elsewhere depend on them
/// (signInWithEmailAndPassword returning null on success / a message on
/// failure, registerWithEmailAndPassword returning a UserId on success,
/// etc.) — see docs/architecture.md for the full inventory of what calls
/// what. This kept the vast majority of the sign-in/sign-up/verify/
/// forgot-password UI files unchanged.
///
/// IMPORTANT: every screen constructs its own `AuthProvider()` directly
/// (`final _auth = AuthProvider();`), exactly like the old code did with
/// FirebaseAuth — so the "who's logged in" state and its change stream
/// have to live at the *class* level (static), not per-instance. With
/// Firebase this was invisible: every AuthProvider instance just
/// delegated to the single global FirebaseAuth.instance under the hood.
/// A naive port that stored _cachedUser/the stream controller as instance
/// fields would silently break that — a login from sign_in.dart's
/// AuthProvider instance would never reach the *different* AuthProvider
/// instance the app root's StreamProvider is listening to.
class AuthProvider with ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  static AppUser? _cachedUser;
  AppUser? get currentUser => _cachedUser;

  bool refreshFav = false;

  // Replaces Firebase's `authStateChanges()`. Static + broadcast so every
  // AuthProvider() instance anywhere in the app shares the exact same
  // stream, the same way every FirebaseAuth.instance access used to.
  static final StreamController<AppUser?> _userController = StreamController<AppUser?>.broadcast();
  Stream<AppUser?> get user_ => _userController.stream;

  static bool _sessionRestored = false;

  AuthProvider() {
    if (!_sessionRestored) {
      _sessionRestored = true;
      _restoreSession();
    }
  }

  /// Re-checks auth state against whatever tokens are currently stored.
  /// Used by main.dart right after a web OAuth login stores fresh tokens,
  /// so the StreamProvider picks up the now-logged-in user without the
  /// person needing to manually refresh the page.
  Future<void> refreshSessionSilently() => _restoreSession();

  Future<void> _restoreSession() async {
    if (!_api.isLoggedIn) {
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

  /// Returns null on success, an error message on failure — same
  /// convention as the old Firebase-backed version.
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

  /// `oobCode` is Firebase's name for the reset token that used to arrive
  /// via its emailed action link; the backend's equivalent (a plain opaque
  /// token from POST /auth/forgot-password) plays the same role here, so
  /// the parameter name is kept for the one caller (new_password.dart)
  /// that already threads a token through this exact signature.
  Future<String?> confirmPasswordReset(String oobCode, String newPassword) async {
    try {
      await _api.resetPassword(oobCode, newPassword);
      return null; // success
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return "Something went wrong";
    }
  }

  /// No-op now: AppUser has no verification flag to refresh (see its
  /// emailVerified getter). Kept so verify.dart's existing `await
  /// _auth.reload()` call doesn't need touching.
  Future<void> reload() async {}

  // ---- sign in / sign up --------------------------------------------------

  /// Returns null on success, an error message on failure.
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _api.login(email, password);
      _cachedUser = await _api.me();
      _userController.add(_cachedUser);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return "Something went wrong";
    }
  }

  /// Returns a UserId on success (so `result.toString() == "Instance of
  /// 'UserId'"` keeps matching in sign_up.dart's existing check), or a
  /// String error message on failure.
  Future<dynamic> registerWithEmailAndPassword(String email, String password, String fullName) async {
    try {
      await _api.register(email: email, password: password, fullName: fullName);
      await _api.login(email, password);
      _cachedUser = await _api.me();
      _userController.add(_cachedUser);
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

  /// Returns "" on success, an error/warning message on failure — same
  /// convention as the old Firebase-backed version (change_password.dart
  /// checks for an *empty* string, not null, on success).
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

  // Deliberately does NOT close _userController: it's a static, app-wide
  // singleton stream shared by every AuthProvider() instance, so it must
  // outlive any single instance's dispose() — closing it here would break
  // every other screen's AuthProvider the next time it's constructed.
}
