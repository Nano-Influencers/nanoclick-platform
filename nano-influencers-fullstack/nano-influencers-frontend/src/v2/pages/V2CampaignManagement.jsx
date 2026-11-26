import React, { useEffect, useRef, useState } from "react";
import { api } from "../../api.js";
import { Button } from "../components/ui/Button.jsx";
import "./v2-campaign-management.css";
import "./v2-campaign-management-live.css";

const ASSET_BASE = "/assets/nano-v2-app/";
const assets = {
  back: `${ASSET_BASE}campaign-back.svg`,
  trend: `${ASSET_BASE}campaign-trend.svg`,
  pause: `${ASSET_BASE}campaign-pause.svg`,
  edit: `${ASSET_BASE}campaign-edit.svg`,
  trash: `${ASSET_BASE}campaign-trash.svg`,
  x: `${ASSET_BASE}campaign-x.svg`,
  link: `${ASSET_BASE}campaign-link.svg`,
  music: `${ASSET_BASE}campaign-music.svg`,
  notificationTrash: `${ASSET_BASE}campaign-notification-trash.svg`,
  like: `${ASSET_BASE}campaign-notification-like.svg`,
  notificationPause: `${ASSET_BASE}campaign-notification-pause.svg`,
  dislike: `${ASSET_BASE}campaign-notification-dislike.svg`,
  filter: `${ASSET_BASE}campaign-filter-icon.svg`,
  play: `${ASSET_BASE}campaign-notification-play.svg`,
  notificationEdit: `${ASSET_BASE}campaign-notification-edit.svg`,
  cashbackDecor: `${ASSET_BASE}campaign-cashback-decor.svg`,
  upload: `${ASSET_BASE}campaign-upload.svg`,
  success: `${ASSET_BASE}auth-confirmation.png`,
};

const createdText = "Created: 7/12/25 ·  Time: 7:35pm";

function BackHeader({ history = false, filter = false }) {
  return (
    <header className="v2-cm-topbar">
      <a className="v2-cm-back" href="/campaigns"><img src={assets.back} alt="" /><span>Go Back</span></a>
      {history && <a className="v2-cm-history" href="/campaigns/notifications">History</a>}
      {filter && <button className="v2-cm-filter" type="button" aria-label="Filter campaign notifications"><img src={assets.filter} alt="" /></button>}
    </header>
  );
}

function ActionButton({ kind, children }) {
  const icon = kind === "pause" ? assets.pause : kind === "edit" ? assets.edit : assets.trash;
  return <button className={`v2-cm-action is-${kind}`} type="button"><img src={icon} alt="" /><span>{children}</span></button>;
}

function CampaignMedia({ type }) {
  if (type === "x") return <span className="v2-cm-media is-x"><img src={assets.x} alt="" /></span>;
  if (type === "music") return <span className="v2-cm-media is-music"><img src={assets.music} alt="" /></span>;
  return <span className="v2-cm-media is-link"><img src={assets.link} alt="" /></span>;
}

function CampaignRecord({
  heading = "Engaged Growth",
  title = "Twitter Repost",
  media = "x",
  pending = false,
  showLinks = false,
  onClaim,
}) {
  return (
    <article className="v2-cm-record">
      <div className="v2-cm-record-banner">
        <div className="v2-cm-record-heading"><span className="v2-cm-trend"><img src={assets.trend} alt="" /></span><h3>{heading}</h3></div>
        <p>{createdText}</p>
      </div>
      <div className="v2-cm-record-main">
        <div className="v2-cm-record-service"><CampaignMedia type={media} /><strong>{title}</strong></div>
        <div className="v2-cm-actions">
          {!pending && <ActionButton kind="pause">Pause</ActionButton>}
          <ActionButton kind="edit">Edit</ActionButton>
          <ActionButton kind="delete">Delete</ActionButton>
        </div>
      </div>
      {!pending && (
        <div className="v2-cm-proof"><span>Proof Submitted: 465</span><button type="button">See Proofs ⟶</button></div>
      )}
      {showLinks && (
        <div className="v2-cm-links-panel">
          <p><strong>Add links of New Post made on Profile</strong> <span>(5 links used 10 remaining)</span></p>
          <div><Button>Add Links to New Post</Button><Button className="v2-cm-navy" onClick={onClaim}>Claim Cashbacks</Button></div>
        </div>
      )}
    </article>
  );
}

const notificationData = {
  deleted: {
    title: "Campaign Deleted",
    desc: "You just Deleted your Twitter Like Campaign, you would be refunded 95% of the unspent balance.",
    tone: "red",
    icon: assets.notificationTrash,
  },
  approved: {
    title: "Campaign Approved",
    desc: "Your IG Engaged Growth Campaign has been Approved by Admin",
    tone: "green",
    icon: assets.like,
    button: "View Proof",
  },
  cashback: {
    title: "Cashback Approved",
    desc: "Your evidence for Twitter Repost is now approved.",
    tone: "green",
    icon: assets.like,
  },
  paused: {
    title: "Campaign Paused",
    desc: "You have paused your YouTube subscribe Campaign.",
    tone: "yellow",
    icon: assets.notificationPause,
  },
  rejected: {
    title: "Campaign Has Been Rejected",
    desc: "Unfortunately your FB report Campaign has been rejected due to violation of T&C",
    tone: "red",
    icon: assets.dislike,
    button: "See Why",
  },
  resumed: {
    title: "Campaign Resumed",
    desc: "Your X follower Campaign has been resumed.",
    tone: "blue",
    icon: assets.play,
  },
  completed: {
    title: "Campaign has been Completed",
    desc: "Congratulations, your Word of Mouth Campaign has been Completed.",
    tone: "green",
    icon: assets.like,
    button: "View Proof",
  },
  modified: {
    title: "Campaign Modified/Edited",
    desc: "Your X follower Campaign has been modified.",
    tone: "lavender",
    icon: assets.notificationEdit,
  },
};

function NotificationCard({ type }) {
  const item = notificationData[type];
  return (
    <article className="v2-cm-notification">
      <span className={`v2-cm-notification-icon is-${item.tone}`}><img src={item.icon} alt="" /></span>
      <div className="v2-cm-notification-copy">
        <div><h3>{item.title}</h3><time>Just now</time></div>
        <p>{item.desc}</p>
        {item.button && <Button className="v2-cm-notification-button">{item.button}</Button>}
      </div>
    </article>
  );
}

function SectionPanel({ title, href, children }) {
  return (
    <section className="v2-cm-panel">
      <div className="v2-cm-panel-heading"><h2>{title}</h2>{href && <a href={href}>See All ⟶</a>}</div>
      {children}
    </section>
  );
}

function ClaimCashbackModal({ onClose }) {
  const fileRef = useRef(null);
  const [fileName, setFileName] = useState("");
  const [copied, setCopied] = useState(false);
  const campaignLink = "https://nanoinfluencer.ng/ref/adaeze";

  const copyLink = async () => {
    try {
      await navigator.clipboard.writeText(campaignLink);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 1500);
    } catch {
      setCopied(false);
    }
  };

  return (
    <div className="v2-cm-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="cashback-title">
      <div className="v2-cm-modal">
        <h2 id="cashback-title">Claim Cashback</h2>
        <div className="v2-cm-earn-card">
          <img src={assets.cashbackDecor} alt="" />
          <p>You'll earn</p><strong>₦1,000</strong><span>cashback on approval</span>
        </div>
        <div className="v2-cm-claim-step">
          <h3>1. Share your campaign link</h3>
          <p>Copy this link and share it to your audience.</p>
          <div className="v2-cm-copy-field"><span>{campaignLink}</span><button type="button" onClick={copyLink}>{copied ? "Copied" : "Copy"}</button></div>
        </div>
        <div className="v2-cm-claim-step">
          <h3>2. Upload evidence of your share</h3>
          <p>Drop a screenshot or photo showing you shared the campaign. JPG, PNG, or WebP up to 5 MB.</p>
          <input ref={fileRef} className="v2-cm-file-input" type="file" accept="image/jpeg,image/png,image/webp" onChange={(event) => setFileName(event.target.files?.[0]?.name || "")} />
          <button className="v2-cm-upload" type="button" onClick={() => fileRef.current?.click()}>
            <img src={assets.upload} alt="" />
            <strong>{fileName || "Choose file"}</strong>
            <span>{fileName ? "File selected" : "Size limit: 5mb"}</span>
          </button>
        </div>
        <p className="v2-cm-review-note">Once submitted, your claim enters review. Cashback is approved after the evidence is verified, usually within 48 hours.</p>
        <div className="v2-cm-modal-actions">
          <Button className="v2-cm-navy" onClick={onClose}>Cancel</Button>
          <Button onClick={() => { window.location.href = "/campaigns/claim-success"; }}>Submit Claim</Button>
        </div>
      </div>
    </div>
  );
}

function CampaignsData({ mode = "all" }) {
  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [busyId, setBusyId] = useState("");
  const load = async () => {
    setLoading(true); setError("");
    try { setCampaigns(await api.listCampaigns({ limit: 100 })); }
    catch (err) { setError(err.message || "Unable to load campaigns."); }
    finally { setLoading(false); }
  };
  useEffect(() => { load(); }, []);
  const pending = campaigns.filter((item) => ["draft", "pending_admin", "reported"].includes(item.status));
  const ongoing = campaigns.filter((item) => ["active", "awaiting_workers", "paused"].includes(item.status));
  const visible = mode === "pending" ? pending : mode === "ongoing" ? ongoing : campaigns;
  const changeStatus = async (campaign, status) => {
    setBusyId(campaign.id);
    try { await api.updateCampaignStatus(campaign.id, status); await load(); }
    catch (err) { setError(err.message || "Unable to update campaign."); }
    finally { setBusyId(""); }
  };
  if (loading) return <p className="v2-cm-data-state">Loading your campaigns…</p>;
  if (error && campaigns.length === 0) return <div className="v2-cm-data-state" role="alert">{error} <button type="button" onClick={load}>Try again</button></div>;
  return <>
    {error && <p className="v2-cm-data-error" role="alert">{error}</p>}
    {visible.length === 0 ? <div className="v2-cm-data-state"><h3>No {mode === "pending" ? "pending" : mode === "ongoing" ? "ongoing" : ""} campaigns yet</h3><p>Your campaigns will appear here after you create them.</p><a href="/campaigns">Create a campaign</a></div> :
      visible.map((campaign) => <article className="v2-cm-record" key={campaign.id}>
        <div className="v2-cm-record-banner"><div className="v2-cm-record-heading"><span className="v2-cm-trend"><img src={assets.trend} alt="" /></span><h3>{campaign.tni_service_type.replaceAll("_", " ")}</h3></div><p>{new Date(campaign.created_at).toLocaleString()}</p></div>
        <div className="v2-cm-record-main"><div className="v2-cm-record-service"><CampaignMedia type={campaign.platform === "x" || campaign.platform === "twitter" ? "x" : "link"} /><strong>{campaign.title}</strong></div>
          <div className="v2-cm-status-actions"><span className={`v2-cm-status is-${campaign.status}`}>{campaign.status.replaceAll("_", " ")}</span>
            {["active", "awaiting_workers"].includes(campaign.status) && <button disabled={busyId === campaign.id} onClick={() => changeStatus(campaign, "paused")}>Pause</button>}
            {campaign.status === "paused" && <button disabled={busyId === campaign.id} onClick={() => changeStatus(campaign, "active")}>Resume</button>}
            {!["completed", "cancelled"].includes(campaign.status) && <button disabled={busyId === campaign.id} onClick={() => { if (window.confirm("Cancel this campaign? Any refundable escrow will be returned to your wallet.")) changeStatus(campaign, "cancelled"); }}>Cancel</button>}
          </div>
        </div>
        <div className="v2-cm-proof"><span>Status: {campaign.status.replaceAll("_", " ")}</span><span>{Number(campaign.slots_filled || 0)} / {Number(campaign.slots_total || 0)} slots filled</span><span>Budget: ₦{(Number(campaign.client_budget_kobo || 0) / 100).toLocaleString("en-NG", {minimumFractionDigits:2})}</span></div>
      </article>)}
  </>;
}

export function V2ManageCampaign() {
  return <div className="v2-cm-page"><main className="v2-cm-main"><BackHeader history /><h1>Manage Campaign</h1><SectionPanel title="Your Campaigns"><CampaignsData /></SectionPanel></main></div>;
}

export function V2OngoingCampaigns() {
  return <div className="v2-cm-page"><main className="v2-cm-main"><BackHeader /><h1>Ongoing Campaigns</h1><section className="v2-cm-list-panel"><CampaignsData mode="ongoing" /></section></div>;
}

export function V2PendingCampaigns() {
  return <div className="v2-cm-page"><main className="v2-cm-main"><BackHeader /><h1>Pending Campaigns</h1><section className="v2-cm-list-panel"><CampaignsData mode="pending" /></section></div>;
}

export function V2CampaignNotifications() {
  return (
    <div className="v2-cm-page">
      <main className="v2-cm-main">
        <BackHeader filter />
        <h1>Campaign Notifications</h1>
        <section className="v2-cm-notifications-panel">
          <NotificationCard type="deleted" />
          <NotificationCard type="cashback" />
          <NotificationCard type="paused" />
          <NotificationCard type="rejected" />
          <NotificationCard type="resumed" />
          <NotificationCard type="completed" />
          <NotificationCard type="modified" />
        </section>
      </main>
    </div>
  );
}

export function V2ClaimSubmitted() {
  return (
    <div className="v2-cm-success-page">
      <div className="v2-cm-success-card">
        <img src={assets.success} alt="" />
        <div className="v2-cm-success-copy">
          <h1>Claim Submitted!</h1>
          <p>Your evidence for <strong>Twitter Repost</strong> is now under review. We'll notify you once the ₦1,000 cashback is approved.</p>
        </div>
        <div className="v2-cm-success-actions">
          <Button href="/campaigns/manage">Done</Button>
          <Button className="v2-cm-navy" href="/dashboard">View Dashboard</Button>
        </div>
      </div>
    </div>
  );
}
