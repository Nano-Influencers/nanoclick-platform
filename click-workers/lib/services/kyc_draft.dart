/// Accumulates KYC wizard state across its working screens so the final
/// Agreement screen can make one authoritative POST /kyc/submit.
class KycDraft {
  KycDraft._();
  static final KycDraft instance = KycDraft._();

  String? gender;
  String? ageBracket;
  String? maritalStatus;
  String? religion;
  String? ethnicityTribe;
  String? race;
  List<String> languagesSpoken = [];
  String? primaryCity;
  String? primaryState;
  String? primaryCountry;
  List<String> secondaryLocations = [];
  String? occupationLocation;
  String? stateOfOrigin;
  String? townOfOrigin;
  String? monthlyIncomeRange;
  String? primaryIncomeSource;
  String? occupationIndustry;
  List<String> skills = [];
  List<String> interestsHobbies = [];

  int? followerCount;
  int? followingCount;
  int? avgStoryViews;
  double? avgEngagementRate;
  String? postingFrequency;
  List<String> followerCategories = [];
  List<String> followerIndustries = [];

  bool isVerifiedOnPlatform = false;
  bool usesRealName = false;
  bool usesRealPhoto = false;

  String? instagramHandle;
  String? whatsappNumber;

  /// Private R2/S3 object key returned by the backend's KYC upload endpoint.
  String? documentUrl;

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
    put('document_url', documentUrl);
    return map;
  }
}
