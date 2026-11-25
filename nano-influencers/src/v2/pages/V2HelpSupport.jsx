import React from "react";
import "./v2-help-support.css";

const ASSET_BASE = "/assets/nano-v2-app/";
const assets = {
  brand: `${ASSET_BASE}dashboard-brand.svg`,
  profile: `${ASSET_BASE}dashboard-profile.png`,
  notification: `${ASSET_BASE}dashboard-notification.svg`,
  dashboard: `${ASSET_BASE}dashboard-menu.svg`,
  wallet: `${ASSET_BASE}dashboard-wallet.svg`,
  analytics: `${ASSET_BASE}dashboard-analytics.svg`,
  settings: `${ASSET_BASE}dashboard-settings.svg`,
  help: `${ASSET_BASE}dashboard-help.svg`,
  logout: `${ASSET_BASE}dashboard-logout.svg`,
  collapse: `${ASSET_BASE}dashboard-chevron.svg`,
  dateChevron: `${ASSET_BASE}dashboard-date-chevron.svg`,
  faqChevron: "/assets/nano-v2/faq-down.svg",
};

const faqs = [
  "How do i know the engagement is from real people and not bots?",
  "If i pay for Engaged Growth, do the followers remain after my subscription ends?",
  "How do I know people are actually recommending my brand in real conversation?",
  "Why Should I use Word-of-Mouth instead of just running Ads?",
  "What kind of Custom Tasks can i recreate?",
  "How fast can a Custom Task be completed?",
  "What happens if my Campaign doesn’t deliver as promised?",
  "How do i track campaign performance?",
];

function Brand() {
  return (
    <a className="v2-help-brand" href="/" aria-label="The Nano Influencers home">
      <img src={assets.brand} alt="" />
      <span>The Nano Influencers</span>
    </a>
  );
}

function SidebarLink({ href, icon, children, active = false }) {
  return (
    <a className={`v2-help-sidebar-link${active ? " is-active" : ""}`} href={href}>
      <img src={icon} alt="" />
      <span>{children}</span>
    </a>
  );
}

function Sidebar() {
  return (
    <aside className="v2-help-sidebar">
      <div>
        <div className="v2-help-sidebar-logo"><Brand /></div>
        <div className="v2-help-sidebar-group">
          <p>Main Menu</p>
          <SidebarLink href="/dashboard" icon={assets.dashboard}>Dashboard</SidebarLink>
          <SidebarLink href="/wallet" icon={assets.wallet}>Wallet</SidebarLink>
          <SidebarLink href="#campaigns" icon={assets.dashboard}>Campaigns</SidebarLink>
          <SidebarLink href="#analytics" icon={assets.analytics}>Analytics</SidebarLink>
        </div>
        <div className="v2-help-sidebar-group v2-help-sidebar-support">
          <p>Support</p>
          <SidebarLink href="/settings" icon={assets.settings}>Settings</SidebarLink>
          <SidebarLink href="/help-support" icon={assets.help} active>Help &amp; Support</SidebarLink>
        </div>
      </div>
      <button className="v2-help-logout" type="button"><span>Log Out</span><img src={assets.logout} alt="" /></button>
      <button className="v2-help-collapse" type="button" aria-label="Collapse sidebar"><img src={assets.collapse} alt="" /></button>
    </aside>
  );
}

function Header() {
  return (
    <>
      <header className="v2-help-topbar">
        <div className="v2-help-mobile-brand"><Brand /></div>
        <p className="v2-help-welcome">Welcome Back 👋</p>
        <div className="v2-help-user">
          <button className="v2-help-notification" type="button" aria-label="Notifications"><img src={assets.notification} alt="" /></button>
          <div className="v2-help-profile"><img src={assets.profile} alt="Adaeze O." /><span>Adaeze O.</span></div>
        </div>
      </header>
      <div className="v2-help-title-row">
        <div><h1>Help &amp; Support</h1><p>Find answers, and reach our team</p></div>
        <div className="v2-help-date">Last 30 days <img src={assets.dateChevron} alt="" /></div>
      </div>
    </>
  );
}

export default function V2HelpSupport() {
  return (
    <main className="v2-help-page">
      <Sidebar />
      <section className="v2-help-main">
        <Header />
        <div className="v2-help-grid">
          <section className="v2-help-card v2-help-email-card">
            <div className="v2-help-card-heading"><h2>Email Us</h2><p>We reply within 24h</p></div>
            <form className="v2-help-form" onSubmit={(event) => event.preventDefault()}>
              <div className="v2-help-form-row">
                <label><span>First Name</span><input type="text" placeholder="First Name" /></label>
                <label><span>Last Name</span><input type="text" placeholder="Last Name" /></label>
              </div>
              <label><span>Email</span><input type="email" placeholder="you@example.com" /></label>
              <label><span>Message</span><textarea placeholder="Enter your message here" /></label>
              <button type="submit" className="v2-help-submit">Submit</button>
            </form>
          </section>

          <section className="v2-help-card v2-help-faq-card">
            <div className="v2-help-card-heading"><h2>Frequently Asked Questions</h2><p>Browse common questions</p></div>
            <div className="v2-help-faq-scroll" aria-label="Frequently asked questions">
              {faqs.map((question) => (
                <div className="v2-help-faq-item" key={question}>
                  <h3>{question}</h3>
                  <img src={assets.faqChevron} alt="" />
                </div>
              ))}
            </div>
          </section>
        </div>
      </section>
    </main>
  );
}
