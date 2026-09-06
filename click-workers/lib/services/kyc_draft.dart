/// Accumulates KYC wizard state across its 6 working screens (UserAgreement
/// -> KycPersonal -> SocialMediaInfo -> SMAccountVerification -> SMCheck ->
/// SupportingDocuments -> Agreement) so the *last* screen can call the
/// backend's single POST /kyc/submit once, instead of each screen writing
/// straight to Firestore as it went (which is what this wizard did before —
/// each step persisted immediately to a 'kyc' Firestore doc via
/// SetOptions(merge: true), with no equivalent multi-step submit on the
/// backend, which is deliberately all-or-nothing: one submission, reviewed
/// once by an admin — see app/routers/kyc.py).
///
/// A plain static singleton rather than passing state through constructors:
/// none of these screens currently thread data through their constructors
/// (they're all built with `const ScreenName()`), so introducing that would
/// mean touching every navigation call site. This keeps that surface
/// unchanged and just changes what each "Continue" button writes into.
///
/// Fields mirror app/schemas/kyc.py's KycSubmitRequest 1:1 where the wizard
/// actually collects a matching value. Fields the wizard collects with no
/// backend equivalent (e.g. per-platform granular stats like "WhatsApp
/// groups active", bank account details in SupportingDocuments) are
/// intentionally not modeled here — see the comments in each converted
/// screen for what was dropped and why.
class KycDraft {
  KycDraft._();
  static final KycDraft instance = KycDraft._();

  // Pillar 1: Demographics
  String? gender;
  String? ageBracket;
  String? maritalStatus;

  // Pillar 2: Social / Cultural
  String? religion;
  String? ethnicityTribe;
  String? race;
  List<String> languagesSpoken = [];

  // Pillar 3: Geographic
  String? primaryCity;
  String? primaryState;
  String? primaryCountry;
  List<String> secondaryLocations = [];
  String? occupationLocation;
  String? stateOfOrigin;
  String? townOfOrigin;

  // Pillar 4: Economic
  String? monthlyIncomeRange;
  String? primaryIncomeSource;

  // Pillar 5: Occupation
  String? occupationIndustry;
  List<String> skills = [];

  // Pillar 6: Interests
  List<String> interestsHobbies = [];

  // Reach metrics
  int? followerCount;
  int? followingCount;
  int? avgStoryViews;
  double? avgEngagementRate;
  String? postingFrequency;
  List<String> followerCategories = [];
  List<String> followerIndustries = [];

  // Authority & Trust
  bool isVerifiedOnPlatform = false;
  bool usesRealName = false;
  bool usesRealPhoto = false;

  // Social handles
  String? instagramHandle;
  String? whatsappNumber;

  /// Builds the request body for POST /kyc/submit — only includes fields
  /// that were actually filled in, since every field on the backend schema
  /// is optional and there's no value in sending explicit nulls over
  /// whatever defaults it already has.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    void put(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.isEmpty) return;
      if (value is List && value.isEmpty) return;
      map[key] = value;
    }

    put('gender', gender);
    put('age_bracket', ageBracket);
    put('marital_status', maritalStatus);
    put('religion', religion);
    put('ethnicity_tribe', ethnicityTribe);
    put('race', race);
    put('languages_spoken', languagesSpoken);
    put('primary_city', primaryCity);
    put('primary_state', primaryState);
    put('primary_country', primaryCountry);
    put('secondary_locations', secondaryLocations);
    put('occupation_location', occupationLocation);
    put('state_of_origin', stateOfOrigin);
    put('town_of_origin', townOfOrigin);
    put('monthly_income_range', monthlyIncomeRange);
    put('primary_income_source', primaryIncomeSource);
    put('occupation_industry', occupationIndustry);
    put('skills', skills);
    put('interests_hobbies', interestsHobbies);
    put('follower_count', followerCount);
    put('following_count', followingCount);
    put('avg_story_views', avgStoryViews);
    put('avg_engagement_rate', avgEngagementRate);
    put('posting_frequency', postingFrequency);
    put('follower_categories', followerCategories);
    put('follower_industries', followerIndustries);
    map['is_verified_on_platform'] = isVerifiedOnPlatform;
    map['uses_real_name'] = usesRealName;
    map['uses_real_photo'] = usesRealPhoto;
    put('instagram_handle', instagramHandle);
    put('whatsapp_number', whatsappNumber);
    return map;
  }
}
