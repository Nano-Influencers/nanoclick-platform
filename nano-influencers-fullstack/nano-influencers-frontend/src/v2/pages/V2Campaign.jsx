import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { api } from "../../api.js";
import { Button } from "../components/ui/Button.jsx";
import "./v2-campaign.css";
import "./v2-campaign-populated.css";

const ASSET_BASE = "/assets/nano-v2-app/";
const assets = {
  brand: `${ASSET_BASE}dashboard-brand.svg`,
  profile: `${ASSET_BASE}dashboard-profile.png`,
  notification: `${ASSET_BASE}dashboard-notification.svg`,
  dashboard: `${ASSET_BASE}dashboard-menu.svg`,
  wallet: `${ASSET_BASE}dashboard-wallet.svg`,
  campaign: `${ASSET_BASE}dashboard-campaign.svg`,
  analytics: `${ASSET_BASE}dashboard-analytics.svg`,
  settings: `${ASSET_BASE}dashboard-settings.svg`,
  help: `${ASSET_BASE}dashboard-help.svg`,
  logout: `${ASSET_BASE}dashboard-logout.svg`,
  trend: `${ASSET_BASE}campaign-trend.svg`,
  wordOfMouth: "/assets/nano-v2/service-word.svg",
  taskBolt: "/assets/nano-v2/service-single.svg",
  emptyCampaign: `${ASSET_BASE}campaign-empty-state.svg`,
  facebook: `${ASSET_BASE}social-facebook.svg`,
  youtube: `${ASSET_BASE}social-youtube.svg`,
  twitter: `${ASSET_BASE}social-x.svg`,
  whatsapp: `${ASSET_BASE}social-whatsapp.svg`,
  instagram: `${ASSET_BASE}social-instagram.svg`,
  telegram: `${ASSET_BASE}social-telegram.svg`,
  tiktok: `${ASSET_BASE}social-tiktok.svg`,
  linkedin: `${ASSET_BASE}social-linkedin.svg`,
  audiomack: `${ASSET_BASE}social-audiomack.svg`,
  spotify: `${ASSET_BASE}social-spotify.svg`,
  boomplay: `${ASSET_BASE}social-boomplay.svg`,
  ytmusic: `${ASSET_BASE}social-youtube-music.svg`,
  googleForm: `${ASSET_BASE}campaign-google-form.svg`,
  website: "/assets/nano-v2/special-website.svg",
  crypto: "/assets/nano-v2/special-crypto.svg",
  ideas: "/assets/nano-v2/special-ideas.svg",
  manageX: `${ASSET_BASE}campaign-x.svg`,
  manageLink: `${ASSET_BASE}campaign-link.svg`,
  manageEdit: `${ASSET_BASE}campaign-edit.svg`,
  manageTrash: `${ASSET_BASE}campaign-trash.svg`,
};

const platforms = [
  ["Facebook", assets.facebook], ["Youtube", assets.youtube], ["Twitter", assets.twitter], ["WhatsApp", assets.whatsapp],
  ["Instagram", assets.instagram], ["Telegram", assets.telegram], ["TikTok", assets.tiktok], ["LinkedIn", assets.linkedin],
  ["Audiomack", assets.audiomack], ["Spotify", assets.spotify], ["BoomPlay", assets.boomplay], ["YT Music", assets.ytmusic],
];

const singleTasks = [
  ["Get a Google Form", assets.googleForm],
  ["Create Website for your Business", assets.website],
  ["Buy & Sell Crypto", assets.crypto],
  ["Buy Business Plan & Ideas", assets.ideas],
];

function Brand() {
  return <a className="v2-campaign-brand" href="/" aria-label="The Nano Influencers home"><img src={assets.brand} alt="" /><span>The Nano Influencers</span></a>;
}

function SidebarItem({ href, icon, label, active = false }) {
  return <a className={`v2-campaign-sidebar-item${active ? " is-active" : ""}`} href={href}><img src={icon} alt="" /><span>{label}</span></a>;
}

function Sidebar() {
  return (
    <aside className="v2-campaign-sidebar">
      <div>
        <div className="v2-campaign-sidebar-logo"><Brand /></div>
        <nav className="v2-campaign-sidebar-nav" aria-label="Campaign navigation">
          <section>
            <p className="v2-campaign-nav-label">Main Menu</p>
            <SidebarItem href="/dashboard" icon={assets.dashboard} label="Overview" />
            <SidebarItem href="/wallet" icon={assets.wallet} label="Wallet" />
            <SidebarItem href="/campaigns" icon={assets.campaign} label="Campaigns" active />
            <SidebarItem href="/analytics" icon={assets.analytics} label="Analytics" />
          </section>
          <section className="v2-campaign-support-nav">
            <p className="v2-campaign-nav-label">Support</p>
            <SidebarItem href="/settings" icon={assets.settings} label="Settings" />
            <SidebarItem href="/help-support" icon={assets.help} label="Help & Support" />
          </section>
        </nav>
      </div>
      <button className="v2-campaign-logout" type="button" onClick={async () => { await api.logout(); window.location.replace("/login"); }}><span>Log Out</span><img src={assets.logout} alt="" /></button>
    </aside>
  );
}

function TopHeader({ profileOpen, onProfileClick }) {
  const [user, setUser] = useState(null);
  useEffect(() => { let active = true; api.me().then((profile) => { if (active) setUser(profile); }).catch(() => {}); return () => { active = false; }; }, []);
  const displayName = user?.full_name || user?.email || "My Account";
  const initials = displayName.trim().split(/\s+/).slice(0, 2).map((part) => part[0]?.toUpperCase()).join("") || "U";
  return (
    <header className="v2-campaign-topbar">
      <div className="v2-campaign-mobile-brand"><Brand /></div>
      <p className="v2-campaign-welcome">Welcome Back 👋</p>
      <div className="v2-campaign-user">
        <a className="v2-campaign-notification" href="/campaigns/notifications" aria-label="Notifications"><img src={assets.notification} alt="" /></a>
        <button className={`v2-campaign-profile${profileOpen ? " is-open" : ""}`} type="button" aria-label="Open profile menu" aria-expanded={profileOpen} onClick={onProfileClick}>
          {user?.avatar_url ? <img src={user.avatar_url} alt="" /> : <span className="v2-campaign-avatar-fallback">{initials}</span>}
          <span>{displayName}</span>
        </button>
      </div>
    </header>
  );
}

function ServiceCard({ type }) {
  const wom = type === "wom";
  const rows = wom
    ? [["Purpose", "Explode awareness & Conversions on WhatsApp"], ["Delivery", "Nano-Influencers deliver your campaigns naturally through WhatsApp DMs & group chats to your targeted audiences that are most likely to convert."], ["Platform", "WhatsApp, Telegram & Messenger"], ["Best For", "Product Launch, Massive Awareness, Event Promotion etc."]]
    : [["Purpose", "Any issues with your campaigns or account? Our support team is ready to help."], ["Delivery", "Assigned followers in your niche who follow permanently & continually engage with your content while sharing on WhatsApp for more audience"], ["Platform", "Instagram, Facebook, X(Twitter), YouTube, LinkedIn, and TikTok"], ["Best For", "Creators, Brands, Influencers, Businesses and anyone seeking constant visibility."]];
  return (
    <article className={`v2-campaign-service-card${wom ? " is-wom" : " is-growth"}`}>
      <div className="v2-campaign-service-title"><span className="v2-campaign-service-icon"><img src={wom ? assets.wordOfMouth : assets.trend} alt="" /></span><h2>{wom ? "Word of Mouth" : "Engaged Growth"}</h2></div>
      <div className="v2-campaign-service-facts">{rows.map(([label, value]) => <div className="v2-campaign-service-fact" key={label}><span>{label}</span><p>{value}</p></div>)}</div>
      <Button className="v2-campaign-start" to={wom ? "/campaigns/word-of-mouth" : "/campaigns/select-package"}>Start Now</Button>
      <button className="v2-campaign-video-link" type="button" disabled>Service video guide coming soon</button>
    </article>
  );
}

function PlatformCard({ name, icon }) {
  const slug = name.toLowerCase() === "yt music" ? "youtube-music" : name.toLowerCase() === "twitter" ? "x" : name.toLowerCase();
  return <a className="v2-campaign-platform-card" href={`/campaigns/create/${slug}`}><img src={icon} alt="" /><span>{name}</span></a>;
}

function CustomTasks() {
  return (
    <section className="v2-campaign-panel v2-campaign-custom">
      <div className="v2-campaign-panel-heading is-split"><div><h2>Custom Tasks</h2><p>Choose the right service to grow your brand and reach your audience.</p></div><button type="button" disabled>Service video guide coming soon</button></div>
      <div className="v2-campaign-label">Select Platform</div>
      <div className="v2-campaign-platform-grid">{platforms.map(([name, icon]) => <PlatformCard key={name} name={name} icon={icon} />)}</div>
    </section>
  );
}

function CustomTaskBanner() {
  return <section className="v2-campaign-task-banner"><span className="v2-campaign-task-icon"><img src={assets.taskBolt} alt="" /></span><div><h2>Great for Multiple task creation across any type of Platform.</h2><p>Build custom campaigns tailored to your exact goals.</p></div><Button className="v2-campaign-custom-button" to="/campaigns/custom-task">Create Custom Task</Button></section>;
}

function CompactManageRecord({ title, linked = false }) {
  return (
    <article className="v2-campaign-compact-record">
      <div className="v2-campaign-compact-head"><span><i><img src={assets.trend} alt="" /></i><strong>Engaged Growth</strong></span><time>Created: 7/12/25 · Time: 7:35pm</time></div>
      <div className="v2-campaign-compact-main">
        <div className={`v2-campaign-compact-service${linked ? " is-link" : ""}`}>
          {linked ? <span className="v2-campaign-compact-link"><img src={assets.manageLink} alt="" /></span> : <img src={assets.manageX} alt="" />}
          <strong>{title}</strong>
        </div>
        <div className="v2-campaign-compact-actions">
          <button className="is-edit" type="button"><img src={assets.manageEdit} alt="" />Edit</button>
          <button className="is-delete" type="button"><img src={assets.manageTrash} alt="" />Delete</button>
        </div>
      </div>
    </article>
  );
}

function ManageCampaigns() {
  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  useEffect(() => { let active = true; (async () => { try { const session = await api.restoreSession(); if (!session.ok) throw new Error("Please log in to view campaigns."); const data = await api.listCampaigns({ limit: 10, offset: 0 }); if (active) setCampaigns(Array.isArray(data) ? data : []); } catch (e) { if (active) setError(e.message || "Unable to load campaigns."); } finally { if (active) setLoading(false); } })(); return () => { active = false; }; }, []);
  return <section className="v2-campaign-panel v2-campaign-manage"><div className="v2-campaign-panel-heading"><h2>Manage Campaigns</h2></div>{loading ? <p role="status">Loading campaigns…</p> : error ? <p role="alert">{error}</p> : campaigns.length ? <div className="v2-campaign-populated-list">{campaigns.map((campaign) => <article className="v2-campaign-compact-record" key={campaign.id}><div className="v2-campaign-compact-head"><span><i><img src={assets.trend} alt="" /></i><strong>{campaign.title}</strong></span><time>{new Date(campaign.created_at).toLocaleString()}</time></div><div className="v2-campaign-compact-main"><div className="v2-campaign-compact-service"><strong>{campaign.platform} · {campaign.action_type}</strong><span>{campaign.status} · {campaign.slots_filled}/{campaign.slots_total} completed</span></div><div className="v2-campaign-compact-actions"><a href={`/campaigns/${campaign.id}`}>View details</a></div></div></article>)}<Button href="/campaigns/manage" className="v2-campaign-manage-button">Go to Campaign Management</Button></div> : <div className="v2-campaign-empty"><img src={assets.emptyCampaign} alt="" /><h3>You have no campaign available</h3><Button to="/campaigns/select-package">Create New Campaign</Button></div>}</section>;
}

function SingleTasks() {
  return (
    <section className="v2-campaign-panel v2-campaign-single">
      <div className="v2-campaign-panel-heading"><h2>Single Tasks</h2><p>Premium tools designed for specific business needs</p></div>
      <div className="v2-campaign-label">Select Service</div>
      <div className="v2-campaign-single-grid">{singleTasks.map(([name, icon]) => <a className="v2-campaign-single-card" href="/campaigns/select-services" key={name}><img src={icon} alt="" /><span>{name}</span></a>)}</div>
    </section>
  );
}

function MobileBottomNav() {
  return <nav className="v2-campaign-bottom-nav" aria-label="Mobile navigation"><a href="/dashboard"><img src={assets.dashboard} alt="" /></a><a href="/wallet"><img src={assets.wallet} alt="" /></a><a className="is-active" href="/campaigns"><img src={assets.campaign} alt="" /><span>Campaigns</span></a><a href="/analytics"><img src={assets.analytics} alt="" /></a></nav>;
}


function MobileProfileMenu({ open, onClose }) {
  if (!open) return null;
  return (
    <div className="v2-dashboard-profile-modal mobile-only" role="dialog" aria-modal="true" aria-label="Profile menu">
      <button className="v2-dashboard-profile-backdrop" type="button" aria-label="Close profile menu" onClick={onClose} />
      <div className="v2-dashboard-profile-dropdown">
        <a href="/settings"><img src={assets.settings} alt="" /><span>Settings</span></a>
        <button type="button" onClick={async () => { await api.logout(); window.location.replace("/login"); }}><img src={assets.logout} alt="" /><span>Log Out</span></button>
      </div>
    </div>
  );
}

export default function V2Campaign() {
  const [profileOpen, setProfileOpen] = useState(false);
  return (
    <div className="v2-campaign-page">
      <Sidebar />
      <main className="v2-campaign-main">
        <TopHeader profileOpen={profileOpen} onProfileClick={() => setProfileOpen((value) => !value)} />
        <header className="v2-campaign-page-heading"><h1>Campaign Services</h1><p>Choose the right service to grow your brand and reach your audience.</p></header>
        <section className="v2-campaign-service-grid"><ServiceCard type="growth" /><ServiceCard type="wom" /></section>
        <CustomTasks />
        <CustomTaskBanner />
        <ManageCampaigns />
        <SingleTasks />
      </main>
      <MobileBottomNav />
      <MobileProfileMenu open={profileOpen} onClose={() => setProfileOpen(false)} />
    </div>
  );
}

export function V2SelectServicesPlaceholder() {
  return (
    <div className="v2-campaign-page">
      <Sidebar />
      <main className="v2-campaign-main">
        <TopHeader profileOpen={false} onProfileClick={() => {}} />
        <header className="v2-campaign-page-heading"><h1>Select Services</h1><p>This is the service selection destination. Service links will be added here later.</p></header>
        <section className="v2-campaign-panel v2-campaign-single v2-select-services-placeholder">
          <div className="v2-campaign-panel-heading"><h2>Services coming soon</h2><p>You've reached the Select Services page. The available service destinations can be connected here when they are ready.</p></div>
          <Button to="/campaigns">Back to Campaigns</Button>
        </section>
      </main>
      <MobileBottomNav />
    </div>
  );
}

export function V2CampaignDetail() {
  const { campaignId } = useParams();
  const [campaign, setCampaign] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  useEffect(() => { let active = true; (async () => { try { const session = await api.restoreSession(); if (!session.ok) throw new Error("Please log in to view this campaign."); const data = await api.getCampaign(campaignId); if (active) setCampaign(data); } catch (e) { if (active) setError(e.message || "Unable to load campaign."); } finally { if (active) setLoading(false); } })(); return () => { active = false; }; }, [campaignId]);
  return <div className="v2-campaign-page"><Sidebar /><main className="v2-campaign-main"><TopHeader profileOpen={false} onProfileClick={() => {}} /><header className="v2-campaign-page-heading"><h1>Campaign Details</h1><p>Live campaign information</p></header>{loading ? <p role="status">Loading campaign…</p> : error ? <p role="alert">{error}</p> : campaign ? <section className="v2-campaign-panel"><h2>{campaign.title}</h2><p>{campaign.platform} · {campaign.action_type}</p><p>Status: {campaign.status}</p><p>Budget: {moneyNgn(campaign.client_budget_kobo)}</p><p>Slots: {campaign.slots_filled} of {campaign.slots_total}</p><p>Created: {new Date(campaign.created_at).toLocaleString()}</p><Button to="/analytics">View Analytics</Button></section> : null}</main><MobileBottomNav /></div>;
}
function moneyNgn(kobo) { return new Intl.NumberFormat("en-NG", { style: "currency", currency: "NGN" }).format(Number(kobo || 0) / 100); }
