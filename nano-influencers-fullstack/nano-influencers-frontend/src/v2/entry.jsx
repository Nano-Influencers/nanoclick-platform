import React from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter, useLocation } from "react-router-dom";
import V2Landing from "./pages/V2Landing.jsx";
import V2Register from "./pages/V2Register.jsx";
import V2Login from "./pages/V2Login.jsx";
import V2OAuthCallback from "./pages/V2OAuthCallback.jsx";
import V2ForgotPassword, {
  V2ForgotPasswordCode,
  V2ForgotPasswordReset,
  V2ForgotPasswordSuccess,
} from "./pages/V2ForgotPassword.jsx";
import V2Dashboard from "./pages/V2Dashboard.jsx";
import V2Analytics from "./pages/V2Analytics.jsx";
import { V2FreeTrial, V2WeeklyGiveaway, V2ReferAndEarn } from "./pages/V2DashboardExtras.jsx";
import { V2Wallet, V2WalletSuccess } from "./pages/V2Wallet.jsx";
import V2Settings from "./pages/V2Settings.jsx";
import V2HelpSupport from "./pages/V2HelpSupport.jsx";
import V2Campaign, { V2SelectServicesPlaceholder } from "./pages/V2Campaign.jsx";
import V2SelectPackage from "./pages/V2SelectPackage.jsx";
import V2SocialMediaDetails from "./pages/V2SocialMediaDetails.jsx";
import V2CustomTask from "./pages/V2CustomTask.jsx";
import V2SocialTaskCampaign from "./pages/V2SocialTaskCampaign.jsx";
import V2WhatsAppTaskCampaign from "./pages/V2WhatsAppTaskCampaign.jsx";
import { V2WordOfMouth, V2WordOfMouthPreview } from "./pages/V2WordOfMouth.jsx";
import { V2ConnectivityGate, V2ErrorBoundary, V2SystemState } from "./pages/V2SystemState.jsx";
import { installV2Navigation } from "./navigation.js";
import {
  V2PreviewSelections,
  V2InsufficientBalance,
  V2SubscriptionSuccessful,
} from "./pages/V2SubscriptionFlow.jsx";
import {
  V2ManageCampaign,
  V2OngoingCampaigns,
  V2PendingCampaigns,
  V2CampaignNotifications,
  V2ClaimSubmitted,
} from "./pages/V2CampaignManagement.jsx";
// Keep the comparison fixes in the V2 bundle so preview deployments always include them.
import "./pages/v2-dashboard-fixes.css";
import "./pages/v2-wallet-fixes.css";
import "./pages/v2-settings-fixes.css";
import "./pages/v2-minor-fixes.css";
import { EmailVerificationPage } from "./pages/V2Verification.jsx";

installV2Navigation();

const root = document.getElementById("root");
const socialCreatorPath = /^\/campaigns\/create\/(facebook|youtube|x|twitter|instagram|tiktok|linkedin|audiomack|boomplay|spotify|youtube-music)$/;

function V2RouteResolver() {
  const { pathname } = useLocation();
  if (pathname === "/" || pathname === "") return <V2Landing />;
  if (pathname === "/register") return <V2Register />;
  if (pathname === "/login") return <V2Login />;
  if (pathname === "/oauth-callback") return <V2OAuthCallback />;
  if (pathname === "/forgot-password/code") return <V2ForgotPasswordCode />;
  if (pathname === "/forgot-password/reset") return <V2ForgotPasswordReset />;
  if (pathname === "/forgot-password/success") return <V2ForgotPasswordSuccess />;
  if (pathname === "/forgot-password") return <V2ForgotPassword />;
  if (pathname === "/verify-email") return <EmailVerificationPage />;
  if (pathname === "/dashboard/free-trial") return <V2FreeTrial />;
  if (pathname === "/dashboard/giveaway") return <V2WeeklyGiveaway />;
  if (pathname === "/refer" || pathname === "/referrals") return <V2ReferAndEarn />;
  if (pathname === "/wallet/success") return <V2WalletSuccess />;
  if (pathname === "/wallet") return <V2Wallet />;
  if (pathname === "/settings") return <V2Settings />;
  if (pathname === "/help-support" || pathname === "/support") return <V2HelpSupport />;
  if (pathname === "/campaigns/create/whatsapp" || pathname === "/campaigns/create/telegram") return <V2WhatsAppTaskCampaign />;
  if (socialCreatorPath.test(pathname)) return <V2SocialTaskCampaign />;
  if (pathname === "/campaigns/word-of-mouth/insufficient-balance") return <V2InsufficientBalance />;
  if (pathname === "/campaigns/word-of-mouth/subscription-success") return <V2SubscriptionSuccessful />;
  if (pathname === "/campaigns/word-of-mouth/preview") return <V2WordOfMouthPreview />;
  if (pathname === "/campaigns/word-of-mouth") return <V2WordOfMouth />;
  if (pathname === "/campaigns/custom-task/insufficient-balance") return <V2InsufficientBalance />;
  if (pathname === "/campaigns/custom-task/subscription-success") return <V2SubscriptionSuccessful />;
  if (pathname === "/campaigns/custom-task") return <V2CustomTask />;
  if (pathname === "/campaigns/subscription-success") return <V2SubscriptionSuccessful />;
  if (pathname === "/campaigns/insufficient-balance") return <V2InsufficientBalance />;
  if (pathname === "/campaigns/preview-selections") return <V2PreviewSelections />;
  if (pathname === "/campaigns/social-media-details") return <V2SocialMediaDetails />;
  if (pathname === "/campaigns/select-package") return <V2SelectPackage />;
  if (pathname === "/campaigns/select-services") return <V2SelectServicesPlaceholder />;
  if (pathname === "/campaigns/manage") return <V2ManageCampaign />;
  if (pathname === "/campaigns/ongoing") return <V2OngoingCampaigns />;
  if (pathname === "/campaigns/pending") return <V2PendingCampaigns />;
  if (pathname === "/campaigns/notifications") return <V2CampaignNotifications />;
  if (pathname === "/campaigns") return <V2Campaign />;
  if (pathname === "/dashboard" || pathname === "/app") return <V2Dashboard />;
  if (pathname === "/system/error") return <V2SystemState type="error" />;
  if (pathname === "/system/offline") return <V2SystemState type="offline" />;
  if (pathname === "/analytics") return <V2Analytics />;
  if (pathname === "/404") return <V2SystemState type="not-found" />;
  return <V2SystemState type="not-found" />;
}

createRoot(root).render(
  <React.StrictMode>
    <V2ErrorBoundary>
      <V2ConnectivityGate>
        <BrowserRouter><V2RouteResolver /></BrowserRouter>
      </V2ConnectivityGate>
    </V2ErrorBoundary>
  </React.StrictMode>,
);
