import React, { useEffect, useState } from "react";
import { api } from "../../api.js";
import "./v2-subscription-flow.css";

const ASSET_BASE = "/assets/nano-v2-app/";
const assets = {
  arrowLeft: `${ASSET_BASE}custom-task-arrow-left.svg`,
  category: `${ASSET_BASE}subscription-category.svg`,
  focus: `${ASSET_BASE}subscription-focus.svg`,
  platform: `${ASSET_BASE}subscription-platform.svg`,
  link: `${ASSET_BASE}subscription-link.svg`,
  location: `${ASSET_BASE}subscription-location.svg`,
  notes: `${ASSET_BASE}subscription-notes.svg`,
  referral: `${ASSET_BASE}subscription-referral.svg`,
  promotion: `${ASSET_BASE}subscription-promotion.svg`,
  walletTick: `${ASSET_BASE}dashboard-wallet.svg`,
  insufficient: `${ASSET_BASE}subscription-insufficient.png`,
  balanceDecor: `${ASSET_BASE}subscription-balance-decor.svg`,
  success: `${ASSET_BASE}subscription-success.png`,
  gift: `${ASSET_BASE}subscription-gift.svg`,
};

const fallbackDraft = {
  categories: ["Entertainment", "Real Estate"],
  specification: "Comedy",
  platform: "Instagram",
  pageLink: "https://www.instagram.com/p/DXwdnSQksI8/?igsh=d2...",
  state: "Lagos",
  area: "Ikeja",
  extra: "",
  referral: "",
  source: "Online Ads#",
};

function readDraft() {
  if (typeof window === "undefined") return fallbackDraft;
  try {
    const stored = JSON.parse(window.sessionStorage.getItem("v2CampaignDraft") || "null");
    return stored ? { ...fallbackDraft, ...stored } : fallbackDraft;
  } catch {
    return fallbackDraft;
  }
}

function go(path) {
  if (typeof window !== "undefined") window.location.assign(path);
}

function PreviewCard({ icon, label, description, value }) {
  return (
    <article className="v2-preview-card">
      <span className="v2-preview-card-icon"><img src={icon} alt="" /></span>
      <div className="v2-preview-card-copy">
        <span className="v2-preview-card-label">{label}</span>
        <span className="v2-preview-card-description">{description}</span>
        <strong>{value || "----"}</strong>
      </div>
    </article>
  );
}

export function V2PreviewSelections() {
  const [draft, setDraft] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const draftId = new URLSearchParams(window.location.search).get("draft");
  useEffect(() => {
    if (!draftId) { setError("No saved campaign draft was provided."); return; }
    let active = true;
    setLoading(true);
    api.getCampaignDraft(draftId)
      .then((saved) => { if (active) setDraft(saved?.payload || null); })
      .catch((err) => { if (active) setError(err.message || "Unable to load campaign draft."); })
      .finally(() => { if (active) setLoading(false); });
    return () => { active = false; };
  }, [draftId]);

  const items = draft ? [
    { icon: assets.category, label: "Platform", description: "Selected social platform", value: draft.platform || "Not provided" },
    { icon: assets.focus, label: "Task", description: "Selected service", value: draft.task || "Not provided" },
    { icon: assets.link, label: "Profile or Page Link", description: "Destination supplied in the draft", value: draft.link || "Not provided" },
    { icon: assets.location, label: "Location", description: "Selected target area", value: [draft.targetState, draft.country].filter(Boolean).join(", ") || "Not provided" },
    { icon: assets.notes, label: "Instructions", description: "Additional campaign instructions", value: draft.instruction || "Not provided" },
    { icon: assets.promotion, label: "Quantity", description: "Requested task quantity", value: draft.quantity || "Not provided" },
  ] : [];

  return (
    <main className="v2-preview-page">
      <div className="v2-preview-shell">
        <header className="v2-preview-backbar"><button type="button" onClick={() => go(draft?.platform ? `/campaigns/create/${draft.platform}` : "/campaigns")}><img src={assets.arrowLeft} alt="" /><span>Back to campaign</span></button></header>
        <section className="v2-preview-tabs" aria-label="Campaign draft steps"><span>Campaign details</span><span className="is-active">Draft review</span></section>
        <h1>Campaign Draft Review</h1>
        {loading && <p role="status">Loading saved draft…</p>}
        {error && <p role="alert">{error}</p>}
        {!loading && !error && draft && <section className="v2-preview-grid">{items.map((item) => <PreviewCard key={item.label} {...item} />)}</section>}
        {!loading && !error && draft && <section className="v2-preview-summary">
          <h2>Payment Status</h2>
          <div className="v2-preview-summary-row"><span>Pricing quote</span><strong>Unavailable</strong></div>
          <p>Campaign launch is paused until server-side pricing and wallet-debit verification are approved. No payment has been initialized and no funds have been charged.</p>
        </section>}
        <button className="v2-preview-confirm" type="button" disabled>Campaign Launch Paused</button>
      </div>
    </main>
  );
}

function OutcomeButton({ children, tone = "primary", onClick }) {
  return (
    <button className={`v2-outcome-button ${tone === "secondary" ? "is-secondary" : ""}`} type="button" onClick={onClick}>
      {children}
    </button>
  );
}

export function V2InsufficientBalance() {
  return (
    <main className="v2-outcome-page">
      <section className="v2-outcome-shell v2-insufficient-shell">
        <div className="v2-outcome-heading">
          <img className="v2-outcome-hero" src={assets.insufficient} alt="" />
          <div><h1>Campaign Launch Paused</h1><p>Campaign pricing and payment verification are not yet available. No payment has been attempted.</p></div>
        </div>
        <div className="v2-outcome-actions">
          <OutcomeButton onClick={() => go("/campaigns")}>Back to Campaigns</OutcomeButton>
          <OutcomeButton tone="secondary" onClick={() => go("/wallet")}>View Wallet</OutcomeButton>
        </div>
      </section>
    </main>
  );
}

export function V2SubscriptionSuccessful() {
  return (
    <main className="v2-outcome-page">
      <section className="v2-outcome-shell v2-success-shell">
        <div className="v2-outcome-heading">
          <img className="v2-outcome-hero" src={assets.success} alt="" />
          <div><h1>Campaign Launch Not Confirmed</h1><p>This page cannot confirm a payment or campaign. Check your campaign list and wallet for server-confirmed records.</p></div>
        </div>
        <OutcomeButton onClick={() => go("/campaigns")}>View Campaigns</OutcomeButton>
        <OutcomeButton tone="secondary" onClick={() => go("/wallet")}>View Wallet</OutcomeButton>
      </section>
    </main>
  );
}
