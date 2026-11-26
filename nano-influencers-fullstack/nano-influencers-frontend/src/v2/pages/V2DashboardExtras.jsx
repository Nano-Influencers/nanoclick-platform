import React, { useEffect, useState } from "react";
import { api } from "../../api.js";
import "./v2-dashboard-extras.css";

const ASSET_BASE = "/assets/nano-v2-app/";
const assets = {
  back: `${ASSET_BASE}custom-task-arrow-left.svg`,
  share: `${ASSET_BASE}extra-share.svg`,
  eye: `${ASSET_BASE}extra-eye.svg`,
  uploadDoc: `${ASSET_BASE}extra-upload-doc.svg`,
  verify: `${ASSET_BASE}extra-verify.svg`,
  copy: `${ASSET_BASE}custom-task-copy.svg`,
  award: `${ASSET_BASE}extra-award.svg`,
  upload: `${ASSET_BASE}custom-task-upload.svg`,
  locked: `${ASSET_BASE}extra-locked.svg`,
  blender: `${ASSET_BASE}extra-blender.png`,
  carouselLeft: `${ASSET_BASE}extra-carousel-left.svg`,
  carouselRight: `${ASSET_BASE}extra-carousel-right.svg`,
  video: `${ASSET_BASE}extra-video.svg`,
  purchase: `${ASSET_BASE}extra-purchase.svg`,
  send: `${ASSET_BASE}extra-send.svg`,
  refer: `${ASSET_BASE}extra-refer.svg`,
  giveawayUpload: `${ASSET_BASE}custom-task-upload.svg`,
  accordion: `${ASSET_BASE}extra-accordion.svg`,
};

function BackHeader() {
  return (
    <div className="v2-extra-back-header">
      <a href="/dashboard" className="v2-extra-back"><img src={assets.back} alt="" /><span>Go Back</span></a>
      <div className="v2-extra-separator" />
    </div>
  );
}

function PageIntro({ title, subtitle }) {
  return <header className="v2-extra-intro"><h1>{title}</h1><p>{subtitle}</p></header>;
}

function CopyChip({ children }) {
  return <button type="button" className="v2-extra-chip"><img src={assets.copy} alt="" /><span>{children}</span></button>;
}

function RequirementCard({ number, icon, title, children, chips }) {
  return (
    <article className="v2-extra-requirement">
      <div className="v2-extra-number-column">
        <span className="v2-extra-icon"><img src={icon} alt="" /></span>
        <span className="v2-extra-number">{number}</span>
      </div>
      <div className="v2-extra-requirement-copy">
        <h3>{title}</h3>
        <p>{children}</p>
        {chips?.length ? <div className="v2-extra-chip-row">{chips.map((chip) => <CopyChip key={chip}>{chip}</CopyChip>)}</div> : null}
      </div>
    </article>
  );
}

function UploadProof({ icon = assets.upload, description }) {
  return (
    <section className="v2-extra-panel v2-extra-upload-panel">
      <div className="v2-extra-section-heading">
        <h2>Submit Proof of your Ad Post</h2>
        <p>{description}</p>
      </div>
      <div className="v2-extra-dropzone is-disabled" aria-disabled="true">
        <img src={icon} alt="" />
        <strong>Proof uploads are not available yet</strong>
        <span>No file has been selected or submitted.</span>
      </div>
      <button className="v2-extra-primary" type="button" disabled>Proof submission unavailable</button>
      <p className="v2-extra-review-note">Proof submission is paused until secure storage, eligibility checks and an admin review workflow are connected. No proof has been submitted.</p>
    </section>
  );
}

const cautionItems = [
  <><strong>Backdated or manipulated proof is prohibited:</strong> Any attempt to submit edited, reused, or time-altered screenshots will result in a permanent ban from the free trial, without appeal.</>,
  <><strong>Do not delete early:</strong> Deleting the status or group message before the 8-hour requirement automatically disqualifies the submission.</>,
  <><strong>Unclear proof is not approved:</strong> Submitting incomplete proof, unclear screenshots, or evidence that cannot verify time duration will not be approved.</>,
  <><strong>One approval per account:</strong> Each account is allowed one free trial approval only. Multiple attempts using alternate accounts or recycled proofs will lead to permanent restriction.</>,
  <>Each account is allowed one free trial approval only. Multiple attempts using alternate accounts or recycled proofs will lead to permanent restriction.</>,
  <>Our system actively reviews timestamps, activity logs, and profile history to ensure fairness and transparency.</>,
];

export function V2FreeTrial() {
  return (
    <main className="ni-v2 v2-extra-page">
      <div className="v2-extra-main">
        <BackHeader />
        <PageIntro title="Free Trial Access" subtitle="The free-trial programme is currently paused while eligibility and review rules are connected." />
        <section className="v2-extra-panel v2-trial-status">
          <h2>Programme unavailable</h2>
          <p>No active trial capacity, eligibility status or proof-review workflow is currently available. No trial access can be unlocked from this page.</p>
        </section>
        <section className="v2-trial-locked">
          <img src={assets.locked} alt="" />
          <div><h2>Trial Locked</h2><p>Trial access will become available here when the programme rules and approval workflow are live.</p></div>
          <button type="button" disabled>Open Free Trial</button>
        </section>
      </div>
    </main>
  );
}

const giveawayTerms = [
  {
    title: "01. Service Purchase Tracking",
    body: <>Once you make a purchase, we will automatically track and record your profile to confirm that you have met the required service purchase amount. Only verified purchases made during the giveaway period will be acknowledged.</>,
  },
  {
    title: "02. Ad Sharing Is Mandatory",
    body: <><p>Sharing our official ad assets on your WhatsApp status is compulsory to enter the giveaway.</p><p>If the ads are not shared and proof is not submitted, you will not be considered - even if you meet or exceed the minimum service purchase amount.</p></>,
  },
  {
    title: "03. Giveaway Timeline",
    body: <>The current giveaway schedule has not been published. Check this page for confirmed dates before making a purchase for giveaway eligibility.</>,
  },
  {
    title: "04. Eligibility",
    body: <><p>Participation is open to:</p><p>- New accounts<br />- Existing accounts<br />- Users from any location</p><p>Everyone is welcome to participate as long as all participation requirements are met.</p></>,
  },
  {
    title: "05. Winner Selection Process",
    body: <><p>Winners will be selected in two stages.</p><p>Step 1 - Compliance Check: We confirm that all participants followed the participation instructions correctly.</p><p>Step 2 - Random Raffle Draw: Eligible participants will then be entered into a random raffle draw, where winners would be fairly selected.</p></>,
  },
  {
    title: "06. Violations & Disqualification",
    body: <><p>Any violation of our terms and conditions will result in disqualification from that week's giveaway.</p><p>This includes:<br />- False claims<br />- Incomplete participation steps<br />- Misuse of the giveaway system</p><p>Participants who violate the rules may also receive a temporary ban from that week's giveaway.</p></>,
  },
];

function GiveawayAccordion() {
  const params = new URLSearchParams(window.location.search);
  const initiallyExpanded = params.get("state") === "expanded";
  const [open, setOpen] = useState(() => new Set(initiallyExpanded ? giveawayTerms.map((_, index) => index) : []));
  const toggle = (index) => setOpen((current) => {
    const next = new Set(current);
    if (next.has(index)) next.delete(index); else next.add(index);
    return next;
  });
  return (
    <section className="v2-extra-panel v2-giveaway-terms">
      <div className="v2-extra-section-heading"><h2>Terms &amp; Conditions</h2></div>
      <div className="v2-giveaway-accordion">
        {giveawayTerms.map((term, index) => {
          const expanded = open.has(index);
          return (
            <article className={`v2-giveaway-term${expanded ? " is-open" : ""}`} key={term.title}>
              <button type="button" aria-expanded={expanded} onClick={() => toggle(index)}><span>{term.title}</span><span className="v2-giveaway-term-icon"><img src={assets.accordion} alt="" /></span></button>
              {expanded ? <div className="v2-giveaway-term-body">{term.body}</div> : null}
            </article>
          );
        })}
      </div>
    </section>
  );
}


export function V2ReferAndEarn() {
  const [user, setUser] = useState(null);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [copied, setCopied] = useState(false);
  const [error, setError] = useState("");
  useEffect(() => {
    let active = true;
    (async () => {
      try {
        const session = await api.restoreSession();
        if (!session.ok) { window.location.replace("/login"); return; }
        const [profile, referralStats] = await Promise.all([api.me(), api.getReferralStats()]);
        if (active) { setUser(profile); setStats(referralStats); }
      } catch (err) {
        if (active) setError(err.message || "Unable to load your referral details.");
      } finally {
        if (active) setLoading(false);
      }
    })();
    return () => { active = false; };
  }, []);
  const referralLink = user?.referral_code
    ? new URL(`/ref/${encodeURIComponent(user.referral_code)}`, window.location.origin).toString()
    : "";
  const copy = async () => {
    if (!referralLink) return;
    try {
      await navigator.clipboard.writeText(referralLink);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 1600);
    } catch {
      setError("Unable to copy the referral link. Please copy it manually.");
    }
  };
  return (
    <main className="ni-v2 v2-extra-page v2-refer-page">
      <div className="v2-extra-main">
        <BackHeader />
        <PageIntro title="Refer & Earn" subtitle="Invite friends to Nano Influencers and earn a referral bonus when they complete their first approved task." />
        <section className="v2-extra-panel v2-refer-hero">
          <span className="v2-extra-icon"><img src={assets.refer} alt="" /></span>
          <h2>Share Nano Influencers</h2>
          <p>Share your personal link. You receive the configured referral bonus after your referred worker completes their first approved task.</p>
          {loading ? <p>Loading your referral link…</p> : error ? <p role="alert">{error}</p> : (
            <div className="v2-refer-link-row">
              <input aria-label="Your referral link" readOnly value={referralLink || "Referral link unavailable"} />
              <button type="button" onClick={copy} disabled={!referralLink}>{copied ? "Copied" : "Copy link"}</button>
            </div>
          )}
          {user?.referral_code && <p className="v2-refer-code">Your referral code: <strong>{user.referral_code}</strong></p>}
          {!loading && stats && <p className="v2-refer-stats">People referred: <strong>{Number(stats.referral_count || 0).toLocaleString()}</strong> · Referral earnings: <strong>₦{Number(stats.total_referral_earnings_ngn || 0).toLocaleString("en-NG", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</strong></p> }
          {!loading && stats && <p className="v2-refer-stats">People referred: <strong>{Number(stats.referral_count || 0).toLocaleString()}</strong> · Referral earnings: <strong>₦{Number(stats.total_referral_earnings_ngn || 0).toLocaleString("en-NG", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</strong></p>}
        </section>
        <section className="v2-extra-panel v2-refer-steps">
          <div className="v2-extra-section-heading"><h2>How it works</h2><p>Three simple steps to earn referral rewards.</p></div>
          <div className="v2-extra-requirements">
            <RequirementCard number="01" icon={assets.share} title="Share your link">Send your personal referral link to friends, clients, and your business network.</RequirementCard>
            <RequirementCard number="02" icon={assets.eye} title="Your friend joins">Your friend creates an account using your referral link.</RequirementCard>
            <RequirementCard number="03" icon={assets.award} title="Earn rewards">Receive the configured referral bonus after your referred worker completes their first approved task.</RequirementCard>
          </div>
        </section>
      </div>
    </main>
  );
}

export function V2WeeklyGiveaway() {
  return (
    <main className="ni-v2 v2-extra-page">
      <div className="v2-extra-main">
        <BackHeader />
        <PageIntro title="Weekly Giveaway" subtitle="There is no active giveaway at this time." />
        <section className="v2-extra-panel v2-giveaway-prize">
          <div className="v2-giveaway-prize-copy">
            <span>Programme status</span>
            <h2>No active giveaway</h2>
            <p>Prize details, dates, eligibility requirements and winner-selection rules have not been published. Purchases and proof uploads will not create giveaway entries while the programme is paused.</p>
          </div>
        </section>
      </div>
    </main>
  );
}
