export const EMPTY_TARGETING = Object.freeze({
  target_genders: [],
  target_age_brackets: [],
  target_marital_statuses: [],
  target_income_ranges: [],
  target_religions: [],
  target_ethnicities: [],
  target_races: [],
  target_languages: [],
  target_cities: [],
  target_states: [],
  target_countries: [],
  target_industries: [],
  target_skills: [],
  target_interests: [],
  min_follower_count: 0,
  min_avg_story_views: 0,
});

export function createEmptyCampaignDraft() {
  return {
    tni_service_type: "",
    platform: "",
    action_type: "",
    title: "",
    description: "",
    target_url: "",
    client_budget_ngn: "",
    client_price_per_action_ngn: "",
    expires_at: "",
    is_urgent: false,
    has_instructions: false,
    instructions: "",
    allocation_groups: [],
    targeting: { ...EMPTY_TARGETING },
    comment_subtype: "",
    video_subtype: "",
  };
}

export function toCampaignCreatePayload(draft) {
  return {
    title: draft.title.trim(),
    platform: draft.platform,
    action_type: draft.action_type,
    tni_service_type: draft.tni_service_type,
    description: draft.description?.trim() || null,
    target_url: draft.target_url?.trim() || null,
    client_budget_ngn: Number(draft.client_budget_ngn),
    client_price_per_action_ngn: Number(draft.client_price_per_action_ngn),
    expires_at: draft.expires_at || null,
    is_urgent: Boolean(draft.is_urgent),
    has_instructions: Boolean(draft.has_instructions && draft.instructions?.trim()),
    instructions: draft.has_instructions ? draft.instructions?.trim() || null : null,
    allocation_groups: Array.isArray(draft.allocation_groups) ? draft.allocation_groups : [],
    targeting: draft.targeting || null,
    comment_subtype: draft.comment_subtype || null,
    video_subtype: draft.video_subtype || null,
  };
}

export const CAMPAIGN_DRAFT_STORAGE_KEY = "nano-influencers:v2:campaign-draft";

export function saveCampaignDraft(draft) {
  sessionStorage.setItem(CAMPAIGN_DRAFT_STORAGE_KEY, JSON.stringify(draft));
}

export function loadCampaignDraft() {
  try {
    const stored = sessionStorage.getItem(CAMPAIGN_DRAFT_STORAGE_KEY);
    return stored ? { ...createEmptyCampaignDraft(), ...JSON.parse(stored) } : createEmptyCampaignDraft();
  } catch {
    return createEmptyCampaignDraft();
  }
}

export function clearCampaignDraft() {
  sessionStorage.removeItem(CAMPAIGN_DRAFT_STORAGE_KEY);
}
