export const V2_ROUTES = Object.freeze({
  landing: "/",
  login: "/login",
  register: "/register",
  forgotPassword: "/forgot-password",
  resetPassword: "/reset-password",
  oauthCallback: "/oauth-callback",

  dashboard: "/app",
  campaigns: "/app/campaigns",
  campaignDetail: "/app/campaigns/:id",
  campaignNew: "/app/campaigns/new",
  campaignPackage: "/app/campaigns/new/package",
  campaignPlatform: "/app/campaigns/new/platform",
  campaignDetails: "/app/campaigns/new/details",
  campaignAudience: "/app/campaigns/new/audience",
  campaignSetup: "/app/campaigns/new/setup",
  campaignInstructions: "/app/campaigns/new/instructions",
  campaignPreview: "/app/campaigns/new/preview",
  wallet: "/app/wallet",
  notifications: "/app/notifications",
  settings: "/app/settings",
  help: "/app/help",
});

export const CAMPAIGN_WIZARD_STEPS = Object.freeze([
  V2_ROUTES.campaignPackage,
  V2_ROUTES.campaignPlatform,
  V2_ROUTES.campaignDetails,
  V2_ROUTES.campaignAudience,
  V2_ROUTES.campaignSetup,
  V2_ROUTES.campaignInstructions,
  V2_ROUTES.campaignPreview,
]);
