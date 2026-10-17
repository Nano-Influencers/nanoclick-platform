import React, { useMemo, useState } from "react";
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
  const draft = useMemo(readDraft, []);
  const [accepted, setAccepted] = useState(() => (
    typeof window !== "undefined" ? window.innerWidth <= 700 : false
  ));

  const previewItems = [
    {
      icon: assets.category,
      label: "Profile/Page Category",
      description: "How do you categorize your Profile/Page?",
      value: (draft.categories || []).join(", ") || "----",
    },
    {
      icon: assets.focus,
      label: "Profile/Page Focus",
      description: "What is your page/profile about?",
      value: draft.specification || "Comedy",
    },
    {
      icon: assets.platform,
      label: "Social Platform",
      description: "Select the Social Platform",
      value: draft.platform || "Instagram",
    },
    {
      icon: assets.link,
      label: "Profile/Page Link",
      description: "How do you categorize your Profile/Page?",
      value: draft.pageLink || fallbackDraft.pageLink,
    },
    {
      icon: assets.location,
      label: "Primary Location",
      description: "Primary Location of Business/Individual",
      value: [draft.area, draft.state].filter(Boolean).join(", ") || "Ikeja, Lagos",
    },
    {
      icon: assets.notes,
      label: "Additional Notes",
      description: "Share anything you would like us to know:",
      value: draft.extra || "----",
    },
    {
      icon: assets.referral,
      label: "Referral Code",
      description: "Who referred you?",
      value: draft.referral || "----",
    },
    {
      icon: assets.promotion,
      label: "Promotion",
      description: "How did you hear about us?",
      value: draft.source || "Online Ads#",
    },
  ];

  return (
    <main className="v2-preview-page">
      <div className="v2-preview-shell">
        <header className="v2-preview-backbar">
          <button type="button" onClick={() => go("/campaigns/social-media-details")}>
            <img src={assets.arrowLeft} alt="" />
            <span>Go Back</span>
          </button>
        </header>

        <section className="v2-preview-tabs" aria-label="Campaign details steps">
          <button type="button" onClick={() => go("/campaigns/social-media-details")}>Social Media Details</button>
          <button type="button" className="is-active">Preview Selections</button>
        </section>

        <section className="v2-preview-grid">
          {previewItems.map((item) => <PreviewCard key={item.label} {...item} />)}
        </section>

        <section className="v2-preview-summary">
          <h2>Payment Summary</h2>
          <div className="v2-preview-summary-row">
            <span>Total Cost</span>
            <strong>₦5,000</strong>
          </div>
          <div className="v2-preview-summary-row">
            <span>Charged from</span>
            <span className="v2-preview-wallet"><i><img src={assets.walletTick} alt="" /></i>Wallet</span>
          </div>
          <div className="v2-preview-summary-row is-invoice">
            <span>Invoice ID</span>
            <code>#BkSOGJuI26I15:44</code>
          </div>
        </section>

        <section className="v2-preview-terms">
          <h2>Terms &amp; Conditions</h2>
          <label>
            <input type="checkbox" checked={accepted} onChange={(event) => setAccepted(event.target.checked)} />
            <span className="v2-preview-checkbox" aria-hidden="true">{accepted ? "✓" : ""}</span>
            <span>I have read and agreed to the terms &amp; conditions of this service. Read terms and conditions here</span>
          </label>
        </section>

        <button className="v2-preview-confirm" type="button" onClick={() => go("/campaigns/insufficient-balance")}>
          Confirm Payment
        </button>
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
          <div>
            <h1>Insufficient Balance</h1>
            <p>Your wallet balance is too low to complete this payment. Please top up to proceed.</p>
          </div>
        </div>

        <article className="v2-insufficient-amount">
          <img src={assets.balanceDecor} alt="" />
          <span>Order amount</span>
          <strong>₦60,000.00</strong>
        </article>

        <article className="v2-insufficient-breakdown">
          <div><span>Wallet balance</span><strong>₦0</strong></div>
          <div><span>You need</span><strong>₦60,000 more</strong></div>
        </article>

        <div className="v2-outcome-actions">
          <OutcomeButton onClick={() => go("/wallet")}>Top Up</OutcomeButton>
          <OutcomeButton tone="secondary" onClick={() => go("/dashboard")}>Go to Dashboard</OutcomeButton>
        </div>
      </section>
    </main>
  );
}

export function V2SubscriptionSuccessful() {
  const [copied, setCopied] = useState(false);
  const referralLink = "https://nanoinfluencer.ng/ref/adaeze";

  const copyReferral = async () => {
    try {
      await navigator.clipboard.writeText(referralLink);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 1500);
    } catch {
      setCopied(false);
    }
  };

  return (
    <main className="v2-outcome-page">
      <section className="v2-outcome-shell v2-success-shell">
        <div className="v2-outcome-heading">
          <img className="v2-outcome-hero" src={assets.success} alt="" />
          <div>
            <h1>Subscription Successful!</h1>
            <p>Your social media profile has been submitted. We will review and get back to you shortly.</p>
          </div>
        </div>

        <OutcomeButton onClick={() => go("/dashboard")}>View Dashboard</OutcomeButton>

        <section className="v2-cashback-wrap">
          <div className="v2-cashback-banner">🎉 Congratulations — you qualified for an Instant 1% Cashback!</div>
          <div className="v2-cashback-card">
            <div className="v2-cashback-heading">
              <span><img src={assets.gift} alt="" /></span>
              <h2>Claim your Cashback now</h2>
            </div>
            <p>Share the link &amp; image below on your WhatsApp Status to get instant 1% cashback on this service. You also have a chance to win exciting prizes like PCs and TV sets in our weekly raffle draw, exclusively for customers who take part in cashback activities.</p>
            <button className="v2-cashback-link" type="button" onClick={copyReferral}>
              <span>{referralLink}</span>
              <strong>{copied ? "Copied" : "Copy"}</strong>
            </button>
            <OutcomeButton>Download Image</OutcomeButton>
          </div>
        </section>
      </section>
    </main>
  );
}
