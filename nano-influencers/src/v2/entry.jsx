import React from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import V2Landing from "./pages/V2Landing.jsx";
import V2Register from "./pages/V2Register.jsx";
import V2Login from "./pages/V2Login.jsx";
import V2ForgotPassword, {
  V2ForgotPasswordCode,
  V2ForgotPasswordReset,
  V2ForgotPasswordSuccess,
} from "./pages/V2ForgotPassword.jsx";
import V2Dashboard from "./pages/V2Dashboard.jsx";
import { V2FreeTrial, V2WeeklyGiveaway } from "./pages/V2DashboardExtras.jsx";
import { V2Wallet, V2WalletSuccess } from "./pages/V2Wallet.jsx";
import V2Settings from "./pages/V2Settings.jsx";
import V2HelpSupport from "./pages/V2HelpSupport.jsx";
import V2Campaign from "./pages/V2Campaign.jsx";
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
import {
  EmailVerificationPage,
  WhatsAppNumberPage,
  WhatsAppCodePage,
  VerificationSuccessPage,
} from "./pages/V2Verification.jsx";

installV2Navigation();

const pathname = window.location.pathname;
const root = document.getElementById("root");
const socialCreatorPath = /^\/campaigns\/create\/(facebook|youtube|x|twitter|instagram|tiktok|linkedin|audiomack|boomplay|spotify|youtube-music)$/;

function renderV2(component) {
  createRoot(root).render(
    <React.StrictMode>
      <V2ErrorBoundary>
        <V2ConnectivityGate>
          <BrowserRouter>{component}</BrowserRouter>
        </V2ConnectivityGate>
      </V2ErrorBoundary>
    </React.StrictMode>,
  );
}

if (pathname === "/" || pathname === "") {
  renderV2(<V2Landing />);
} else if (pathname === "/register") {
  renderV2(<V2Register />);
} else if (pathname === "/login") {
  renderV2(<V2Login />);
} else if (pathname === "/forgot-password/code") {
  renderV2(<V2ForgotPasswordCode />);
} else if (pathname === "/forgot-password/reset") {
  renderV2(<V2ForgotPasswordReset />);
} else if (pathname === "/forgot-password/success") {
  renderV2(<V2ForgotPasswordSuccess />);
} else if (pathname === "/forgot-password") {
  renderV2(<V2ForgotPassword />);
} else if (pathname === "/verify-email") {
  renderV2(<EmailVerificationPage />);
} else if (pathname === "/verify-whatsapp") {
  renderV2(<WhatsAppNumberPage />);
} else if (pathname === "/verify-whatsapp/code") {
  renderV2(<WhatsAppCodePage />);
} else if (pathname === "/verification-success") {
  renderV2(<VerificationSuccessPage />);
} else if (pathname === "/dashboard/free-trial") {
  renderV2(<V2FreeTrial />);
} else if (pathname === "/dashboard/giveaway") {
  renderV2(<V2WeeklyGiveaway />);
} else if (pathname === "/wallet/success") {
  renderV2(<V2WalletSuccess />);
} else if (pathname === "/wallet") {
  renderV2(<V2Wallet />);
} else if (pathname === "/settings") {
  renderV2(<V2Settings />);
} else if (pathname === "/help-support" || pathname === "/support") {
  renderV2(<V2HelpSupport />);
} else if (pathname === "/campaigns/create/whatsapp" || pathname === "/campaigns/create/telegram") {
  renderV2(<V2WhatsAppTaskCampaign />);
} else if (socialCreatorPath.test(pathname)) {
  renderV2(<V2SocialTaskCampaign />);
} else if (pathname === "/campaigns/word-of-mouth/insufficient-balance") {
  renderV2(<V2InsufficientBalance />);
} else if (pathname === "/campaigns/word-of-mouth/subscription-success") {
  renderV2(<V2SubscriptionSuccessful />);
} else if (pathname === "/campaigns/word-of-mouth/preview") {
  renderV2(<V2WordOfMouthPreview />);
} else if (pathname === "/campaigns/word-of-mouth") {
  renderV2(<V2WordOfMouth />);
} else if (pathname === "/campaigns/custom-task/insufficient-balance") {
  renderV2(<V2InsufficientBalance />);
} else if (pathname === "/campaigns/custom-task/subscription-success") {
  renderV2(<V2SubscriptionSuccessful />);
} else if (pathname === "/campaigns/custom-task") {
  renderV2(<V2CustomTask />);
} else if (pathname === "/campaigns/subscription-success") {
  renderV2(<V2SubscriptionSuccessful />);
} else if (pathname === "/campaigns/insufficient-balance") {
  renderV2(<V2InsufficientBalance />);
} else if (pathname === "/campaigns/preview-selections") {
  renderV2(<V2PreviewSelections />);
} else if (pathname === "/campaigns/social-media-details") {
  renderV2(<V2SocialMediaDetails />);
} else if (pathname === "/campaigns/select-package") {
  renderV2(<V2SelectPackage />);
} else if (pathname === "/campaigns/manage") {
  renderV2(<V2ManageCampaign />);
} else if (pathname === "/campaigns/ongoing") {
  renderV2(<V2OngoingCampaigns />);
} else if (pathname === "/campaigns/pending") {
  renderV2(<V2PendingCampaigns />);
} else if (pathname === "/campaigns/notifications") {
  renderV2(<V2CampaignNotifications />);
} else if (pathname === "/campaigns/claim-success") {
  renderV2(<V2ClaimSubmitted />);
} else if (pathname === "/campaigns") {
  renderV2(<V2Campaign />);
} else if (pathname === "/dashboard" || pathname === "/app") {
  renderV2(<V2Dashboard />);
} else if (pathname === "/system/error") {
  renderV2(<V2SystemState type="error" />);
} else if (pathname === "/system/offline") {
  renderV2(<V2SystemState type="offline" />);
} else if (pathname === "/404" || pathname === "/analytics") {
  renderV2(<V2SystemState type="not-found" />);
} else {
  renderV2(<V2SystemState type="not-found" />);
}
