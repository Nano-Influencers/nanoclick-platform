import React, { useState } from "react";
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
            <SidebarItem href="#analytics" icon={assets.analytics} label="Analytics" />
          </section>
          <section className="v2-campaign-support-nav">
            <p className="v2-campaign-nav-label">Support</p>
            <SidebarItem href="/settings" icon={assets.settings} label="Settings" />
            <SidebarItem href="/help-support" icon={assets.help} label="Help & Support" />
          </section>
        </nav>
      </div>
      <button className="v2-campaign-logout" type="button"><span>Log Out</span><img src={assets.logout} alt="" /></button>
    </aside>
  );
}

function TopHeader({ profileOpen, onProfileClick }) {
  return (
    <header className="v2-campaign-topbar">
      <div className="v2-campaign-mobile-brand"><Brand /></div>
      <p className="v2-campaign-welcome">Welcome Back 👋</p>
      <div className="v2-campaign-user">
        <button className="v2-campaign-notification" type="button" aria-label="Notifications"><img src={assets.notification} alt="" /></button>
        <button className={`v2-campaign-profile${profileOpen ? " is-open" : ""}`} type="button" aria-label="Open profile menu" aria-expanded={profileOpen} onClick={onProfileClick}><img src={assets.profile} alt="Adaeze O." /><span>Adaeze O.</span></button>
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
      <button className="v2-campaign-video-link" type="button">Watch Video for more info about this Service</button>
    </article>
  );
}

function PlatformCard({ name, icon }) {
  return <button className="v2-campaign-platform-card" type="button"><img src={icon} alt="" /><span>{name}</span></button>;
}

function CustomTasks() {
  return (
    <section className="v2-campaign-panel v2-campaign-custom">
      <div className="v2-campaign-panel-heading is-split"><div><h2>Custom Tasks</h2><p>Choose the right service to grow your brand and reach your audience.</p></div><button type="button">Watch Video for more info about this Service</button></div>
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

function ManageCampaigns({ active }) {
  return (
    <section className={`v2-campaign-panel v2-campaign-manage${active ? " is-populated" : ""}`}>
      <div className="v2-campaign-panel-heading"><h2>Manage Campaigns</h2></div>
      {active ? (
        <div className="v2-campaign-populated-list">
          <CompactManageRecord title="Twitter Repost" />
          <CompactManageRecord title="Chisom's Page Link 1" linked />
          <Button href="/campaigns/manage" className="v2-campaign-manage-button">Go to Campaign Management</Button>
        </div>
      ) : (
        <div className="v2-campaign-empty"><img src={assets.emptyCampaign} alt="" /><h3>You have no campaign available</h3><Button>Create New Campaign</Button></div>
      )}
    </section>
  );
}

function SingleTasks() {
  return (
    <section className="v2-campaign-panel v2-campaign-single">
      <div className="v2-campaign-panel-heading"><h2>Single Tasks</h2><p>Premium tools designed for specific business needs</p></div>
      <div className="v2-campaign-label">Select Service</div>
      <div className="v2-campaign-single-grid">{singleTasks.map(([name, icon]) => <button className="v2-campaign-single-card" type="button" key={name}><img src={icon} alt="" /><span>{name}</span></button>)}</div>
    </section>
  );
}

function MobileBottomNav() {
  return <nav className="v2-campaign-bottom-nav" aria-label="Mobile navigation"><a href="/dashboard"><img src={assets.dashboard} alt="" /></a><a href="/wallet"><img src={assets.wallet} alt="" /></a><a className="is-active" href="/campaigns"><img src={assets.campaign} alt="" /><span>Campaigns</span></a><a href="#analytics"><img src={assets.analytics} alt="" /></a></nav>;
}


function MobileProfileMenu({ open, onClose }) {
  if (!open) return null;
  return (
    <div className="v2-dashboard-profile-modal mobile-only" role="dialog" aria-modal="true" aria-label="Profile menu">
      <button className="v2-dashboard-profile-backdrop" type="button" aria-label="Close profile menu" onClick={onClose} />
      <div className="v2-dashboard-profile-dropdown">
        <a href="/settings"><img src={assets.settings} alt="" /><span>Settings</span></a>
        <button type="button"><img src={assets.logout} alt="" /><span>Log Out</span></button>
      </div>
    </div>
  );
}

export default function V2Campaign() {
  const activeState = new URLSearchParams(window.location.search).get("state") === "active";
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
        <ManageCampaigns active={activeState} />
        <SingleTasks />
      </main>
      <MobileBottomNav />
      <MobileProfileMenu open={profileOpen} onClose={() => setProfileOpen(false)} />
    </div>
  );
}
