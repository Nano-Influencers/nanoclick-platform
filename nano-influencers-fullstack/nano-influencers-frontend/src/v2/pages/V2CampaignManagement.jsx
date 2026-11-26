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


function notificationVisual(type = "") {
  const value = type.toLowerCase();
  if (value.includes("delete") || value.includes("reject") || value.includes("fail")) return { tone: "red", icon: assets.dislike };
  if (value.includes("pause")) return { tone: "yellow", icon: assets.notificationPause };
  if (value.includes("resume")) return { tone: "blue", icon: assets.play };
  if (value.includes("wallet") || value.includes("deposit") || value.includes("withdraw") || value.includes("cashback")) return { tone: "green", icon: assets.like };
  if (value.includes("edit") || value.includes("modify")) return { tone: "lavender", icon: assets.notificationEdit };
  return { tone: "green", icon: assets.like };
}

function NotificationCard({ notification, onRead }) {
  const visual = notificationVisual(notification.type);
  const date = notification.created_at ? new Date(notification.created_at) : null;
  const time = date && !Number.isNaN(date.getTime()) ? date.toLocaleString() : "";
  return (
    <article className={`v2-cm-notification${notification.is_read ? " is-read" : ""}`}>
      <span className={`v2-cm-notification-icon is-${visual.tone}`}><img src={visual.icon} alt="" /></span>
      <div className="v2-cm-notification-copy">
        <div><h3>{notification.title}</h3><time>{time}</time></div>
        <p>{notification.body}</p>
        {!notification.is_read && <button type="button" className="v2-cm-notification-button" onClick={() => onRead(notification.id)}>Mark as read</button>}
      </div>
    </article>
  );
}

export function V2CampaignNotifications() {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  useEffect(() => {
    let active = true;
    (async () => {
      try {
        const session = await api.restoreSession();
        if (!session.ok) { window.location.replace("/login"); return; }
        const rows = await api.listNotifications({ limit: 100 });
        if (active) setNotifications(Array.isArray(rows) ? rows : []);
      } catch (err) {
        if (active) setError(err.message || "Unable to load notifications.");
      } finally {
        if (active) setLoading(false);
      }
    })();
    return () => { active = false; };
  }, []);
  const markRead = async (id) => {
    try {
      await api.markNotificationRead(id);
      setNotifications((items) => items.map((item) => item.id === id ? { ...item, is_read: true } : item));
    } catch (err) {
      setError(err.message || "Unable to update notification.");
    }
  };
  return (
    <div className="v2-cm-page">
      <main className="v2-cm-main">
        <BackHeader filter />
        <h1>Notifications</h1>
        {error && <p role="alert" className="v2-cm-data-state">{error}</p>}
        {loading ? <p className="v2-cm-data-state">Loading notifications…</p> :
          notifications.length === 0 ? (
            <section className="v2-cm-notifications-panel v2-cm-data-state">
              <h3>No notifications yet</h3>
              <p>When you enable an activity in Settings and it happens, its notification will appear here.</p>
              <a href="/settings?tab=notifications">Manage notification settings</a>
            </section>
          ) : (
            <section className="v2-cm-notifications-panel">
              {notifications.map((item) => <NotificationCard key={item.id} notification={item} onRead={markRead} />)}
            </section>
          )}
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
