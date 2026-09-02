/// Mirrors the backend's UserResponse schema (app/schemas/auth.py).
/// Replaces Firebase Auth's `User` object everywhere in this app —
/// see lib/services/api_client.dart for the HTTP layer this is built from.
class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String role; // "worker" | "advertiser" | "admin"
  final String referralCode;
  final bool kycVerified;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.referralCode,
    required this.kycVerified,
  });

  // ---- Compatibility aliases -------------------------------------------
  // The app previously read these off Firebase's `User` object in ~31
  // files (currentUser.uid, .displayName, .photoURL, .emailVerified).
  // Rather than rename every call site, AppUser exposes the same surface
  // so `currentUser.uid` etc. keep working unchanged wherever they don't
  // also need edits for other reasons.
  String get uid => id;
  String get displayName => fullName;
  // No backend field/endpoint for a profile picture exists yet (see
  // lib/Mobile/Home/change_profile_picture.dart, which needs its own
  // rework once one does) — always null in the meantime.
  String? get photoURL => null;
  // The backend has no email-verification concept at all (accounts are
  // usable immediately on registration), so this is always true rather
  // than gating on a check that can never fail.
  bool get emailVerified => true;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String,
        role: json['role'] as String,
        referralCode: json['referral_code'] as String,
        kycVerified: json['kyc_verified'] as bool? ?? false,
      );
}
