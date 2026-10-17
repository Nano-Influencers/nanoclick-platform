import React, { useState } from "react";
import { Button } from "../components/ui/Button.jsx";
import "./v2-dashboard.css";

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
  chevron: `${ASSET_BASE}dashboard-chevron.svg`,
  dateChevron: `${ASSET_BASE}dashboard-date-chevron.svg`,
  balanceDecor: `${ASSET_BASE}dashboard-balance-decor.svg`,
  balance: `${ASSET_BASE}dashboard-balance.svg`,
  spend: `${ASSET_BASE}dashboard-spend.svg`,
  reach: `${ASSET_BASE}dashboard-reach.svg`,
  people: `${ASSET_BASE}dashboard-people.svg`,
  megaphone: `${ASSET_BASE}dashboard-megaphone.svg`,
  chartGrid: `${ASSET_BASE}dashboard-chart-grid.svg`,
  chartLines: `${ASSET_BASE}dashboard-chart-lines.svg`,
  emptyChartLines: `${ASSET_BASE}dashboard-empty-chart.svg`,
  emptyActivity: `${ASSET_BASE}dashboard-empty-activity.svg`,
  add: `${ASSET_BASE}dashboard-action-add.svg`,
  refer: `${ASSET_BASE}dashboard-action-refer.svg`,
  gift: `${ASSET_BASE}dashboard-action-gift.svg`,
  unlock: `${ASSET_BASE}dashboard-action-unlock.svg`,
  activityMoney: `${ASSET_BASE}dashboard-activity-money.svg`,
  activityCampaign: `${ASSET_BASE}dashboard-activity-campaign.svg`,
  activityReach: `${ASSET_BASE}dashboard-activity-reach.svg`,
  referralDecorA: `${ASSET_BASE}dashboard-referral-decor-a.svg`,
  referralDecorB: `${ASSET_BASE}dashboard-referral-decor-b.svg`,
  floatingRefer: `${ASSET_BASE}dashboard-floating-refer.svg`,
};

const metrics = [
  { title: "Active Campaigns", value: "0", note: "No campaigns running", button: "View Campaigns", tone: "blue", icon: assets.campaign },
  { title: "Total Spend", value: "₦0", note: "This month", button: "Spend Report", tone: "green", icon: assets.spend },
  { title: "Total Reach", value: "0", note: "People reached", button: "View Analytics", tone: "yellow", icon: assets.reach },
  { title: "Total Refferal", value: "0", note: "People reffered", button: "View Refferals", tone: "lavender", icon: assets.people },
];

const quickActions = [
  { title: "Add Funds", desc: "Top up your wallet", tone: "orange", icon: assets.add },
  { title: "Refer & Earn", desc: "Earn 2% per referral", tone: "green", icon: assets.refer },
  { title: "Win Gifts", desc: "1% cashback + weekly raffle", tone: "yellow", icon: assets.gift, href: "/dashboard/giveaway" },
  { title: "Try for Free", desc: "2 free trial weekly", tone: "lavender", icon: assets.unlock, href: "/dashboard/free-trial" },
];

const activities = [
  { title: "Deposit Alert", amount: "₦0", time: "Just Now", tone: "green", icon: assets.activityMoney },
  { title: "Campaign Created", subtitle: "Engaged Growth", amount: "₦0", time: "2 min ago", tone: "blue", icon: assets.activityCampaign },
  { title: "Deposit Alert", amount: "₦0", time: "5 min ago", tone: "green", icon: assets.activityMoney },
  { title: "Reach Milestone", subtitle: "+200 reach", time: "1 hr ago", tone: "yellow", icon: assets.activityReach },
  { title: "Campaign Created", amount: "₦0", time: "2 hr ago", tone: "blue", icon: assets.activityCampaign },
];

function Brand() {
  return (
    <a className="v2-dashboard-brand" href="/" aria-label="The Nano Influencers home">
      <img src={assets.brand} alt="" />
      <span>The Nano Influencers</span>
    </a>
  );
}

function SidebarItem({ icon, label, active = false }) {
  return (
    <a className={`v2-dashboard-sidebar-item${active ? " is-active" : ""}`} href="#">
      <img src={icon} alt="" />
      <span>{label}</span>
    </a>
  );
}

function Sidebar() {
  return (
    <aside className="v2-dashboard-sidebar">
      <div>
        <div className="v2-dashboard-sidebar-logo"><Brand /></div>
        <nav className="v2-dashboard-sidebar-nav" aria-label="Dashboard navigation">
          <section>
            <p className="v2-dashboard-nav-label">Main Menu</p>
            <SidebarItem icon={assets.dashboard} label="Dashboard" active />
            <SidebarItem icon={assets.wallet} label="Wallet" />
            <SidebarItem icon={assets.campaign} label="Campaigns" />
            <SidebarItem icon={assets.analytics} label="Analytics" />
          </section>
          <section className="v2-dashboard-support-nav">
            <p className="v2-dashboard-nav-label">Support</p>
            <SidebarItem icon={assets.settings} label="Settings" />
            <SidebarItem icon={assets.help} label="Help & Support" />
          </section>
        </nav>
      </div>
      <button className="v2-dashboard-logout" type="button">
        <span>Log Out</span><img src={assets.logout} alt="" />
      </button>
    </aside>
  );
}

function TopHeader({ profileOpen, onProfileClick }) {
  return (
    <header className="v2-dashboard-topbar">
      <Brand />
      <p className="v2-dashboard-welcome desktop-welcome">Welcome Back 👋</p>
      <div className="v2-dashboard-user">
        <button className="v2-dashboard-notification" type="button" aria-label="Notifications"><img src={assets.notification} alt="" /></button>
        <button
          className={`v2-dashboard-profile${profileOpen ? " is-open" : ""}`}
          type="button"
          aria-label="Open profile menu"
          aria-expanded={profileOpen}
          onClick={onProfileClick}
        >
          <img src={assets.profile} alt="Adaeze O." /><span>Adaeze O.</span>
        </button>
      </div>
    </header>
  );
}

function BalanceCard() {
  return (
    <section className="v2-dashboard-balance-card">
      <img className="v2-dashboard-balance-decor" src={assets.balanceDecor} alt="" />
      <div className="v2-dashboard-balance-copy">
        <div className="v2-dashboard-balance-title-row">
          <span className="v2-dashboard-icon-circle is-orange"><img src={assets.balance} alt="" /></span>
          <p>Current Balance</p>
        </div>
        <strong>₦0.00</strong>
        <small>No pending transactions</small>
      </div>
      <Button className="v2-dashboard-balance-button">Add Funds</Button>
    </section>
  );
}

function MetricCard({ metric }) {
  return (
    <article className="v2-dashboard-metric-card">
      <span className={`v2-dashboard-icon-circle is-${metric.tone}`}><img src={metric.icon} alt="" /></span>
      <div className="v2-dashboard-metric-text">
        <p>{metric.title}</p><strong>{metric.value}</strong><small>{metric.note}</small>
      </div>
      <button type="button">{metric.button}</button>
    </article>
  );
}

function LaunchBanner() {
  return (
    <section className="v2-dashboard-launch">
      <div className="v2-dashboard-launch-art mobile-only"><img src={assets.megaphone} alt="" /></div>
      <div className="v2-dashboard-launch-copy">
        <h2>Launch Your Campaign</h2>
        <p>Get real people to promote your brand. They engage with your content in DMs &amp; groups where trust lives.</p>
        <div className="v2-dashboard-launch-buttons"><Button>Start Now</Button><Button variant="nav">Manage</Button></div>
      </div>
      <div className="v2-dashboard-launch-art desktop-only"><img src={assets.megaphone} alt="" /></div>
    </section>
  );
}

function AnalyticsChart({ emptyState = false }) {
  const [period, setPeriod] = useState("Weekly");
  return (
    <section className="v2-dashboard-analytics-card desktop-only">
      <div className="v2-dashboard-section-heading">
        <h2>Campaign Analytics</h2>
        <div className="v2-dashboard-periods">
          {["Daily", "Weekly", "Monthly"].map((item) => <button key={item} type="button" className={period === item ? "is-active" : ""} onClick={() => setPeriod(item)}>{item}</button>)}
        </div>
      </div>
      <div className="v2-dashboard-chart">
        <div className="v2-dashboard-y-axis"><span>2200</span><span>1650</span><span>1100</span><span>550</span><span>0</span></div>
        <div className="v2-dashboard-chart-plot"><img className="grid" src={assets.chartGrid} alt="" /><img className={`lines${emptyState ? " is-empty" : ""}`} src={emptyState ? assets.emptyChartLines : assets.chartLines} alt="Campaign analytics lines" /></div>
        <div className="v2-dashboard-x-axis">{[1,2,3,4,5,6,7].map((day) => <span key={day}>Day {day}</span>)}</div>
      </div>
      <div className="v2-dashboard-chart-legend"><span><i className="yellow" />Engagements</span><span><i className="green" />Impressions</span><span><i className="red" />Reach</span></div>
    </section>
  );
}

function QuickActionItem({ action }) {
  const content = (
    <>
      <span className={`v2-dashboard-icon-circle is-${action.tone}`}><img src={action.icon} alt="" /></span>
      <span className="v2-dashboard-quick-copy"><strong>{action.title}</strong><small>{action.desc}</small></span>
      <img className="v2-dashboard-chevron desktop-only" src={assets.chevron} alt="" />
    </>
  );
  if (action.href) return <a className="v2-dashboard-quick-item" href={action.href}>{content}</a>;
  return <button className="v2-dashboard-quick-item" type="button">{content}</button>;
}

function QuickActions() {
  return (
    <section className="v2-dashboard-quick-card">
      <h2>Quick Actions</h2>
      <div className="v2-dashboard-quick-list">
        {quickActions.map((action) => <QuickActionItem key={action.title} action={action} />)}
      </div>
    </section>
  );
}

function LatestActivity({ emptyState = false }) {
  return (
    <section className={`v2-dashboard-activity-card${emptyState ? " is-empty" : ""}`}>
      <div className="v2-dashboard-section-heading"><h2>Latest Activity</h2><button className={emptyState ? "is-muted" : ""} type="button">Show all</button></div>
      {emptyState ? (
        <div className="v2-dashboard-empty-activity">
          <img src={assets.emptyActivity} alt="" />
          <h3>You have no activity</h3>
          <Button>Start a Campaign</Button>
        </div>
      ) : (
        <div className="v2-dashboard-activity-list">
          {activities.map((activity, index) => (
            <div className="v2-dashboard-activity-row" key={`${activity.title}-${index}`}>
              <div className="v2-dashboard-activity-main"><span className={`v2-dashboard-activity-icon is-${activity.tone}`}><img src={activity.icon} alt="" /></span><span><strong>{activity.title}</strong>{activity.subtitle && <small>{activity.subtitle}</small>}</span></div>
              <div className="v2-dashboard-activity-meta">{activity.amount && <strong>{activity.amount}</strong>}<small>{activity.time}</small></div>
            </div>
          ))}
        </div>
      )}
    </section>
  );
}

function ReferralSupport() {
  const [copied, setCopied] = useState(false);
  const referral = "https://nanoinfluencer.ng/ref/adaeze";
  const copy = async () => {
    try { await navigator.clipboard.writeText(referral); setCopied(true); window.setTimeout(() => setCopied(false), 1400); } catch { setCopied(false); }
  };
  return (
    <div className="v2-dashboard-side-cards desktop-only">
      <section className="v2-dashboard-referral-card">
        <img className="decor-a" src={assets.referralDecorA} alt="" /><img className="decor-b" src={assets.referralDecorB} alt="" />
        <span className="v2-dashboard-icon-circle is-orange"><img src={assets.floatingRefer} alt="" /></span>
        <h2>Refer a Friend</h2>
        <p>Earn 2% on every campaign your referral starts and qualify for bi-weekly gadget giveaways.</p>
        <button type="button" onClick={copy}><span>{referral}</span><strong>{copied ? "Copied" : "Copy"}</strong></button>
      </section>
      <section className="v2-dashboard-support-card"><span className="v2-dashboard-icon-circle is-white"><img src={assets.help} alt="" /></span><h2>Dispute &amp; Support</h2><p>Any issues with your campaigns or account? Our support team is ready to help.</p><Button variant="nav">Contact Support</Button></section>
    </div>
  );
}

function MobileBottomNav() {
  return (
    <nav className="v2-dashboard-bottom-nav" aria-label="Mobile dashboard navigation">
      <a className="is-active" href="/dashboard"><img src={assets.dashboard} alt="" /><span>Dashboard</span></a>
      <a href="#"><img src={assets.wallet} alt="" /></a>
      <a href="#"><img src={assets.campaign} alt="" /></a>
      <a href="#"><img src={assets.analytics} alt="" /></a>
    </nav>
  );
}

function MobileProfileMenu({ open, onClose }) {
  if (!open) return null;
  return (
    <div className="v2-dashboard-profile-modal mobile-only" role="dialog" aria-modal="true" aria-label="Profile menu">
      <button className="v2-dashboard-profile-backdrop" type="button" aria-label="Close profile menu" onClick={onClose} />
      <div className="v2-dashboard-profile-dropdown">
        <a href="#settings"><img src={assets.settings} alt="" /><span>Settings</span></a>
        <button type="button"><img src={assets.logout} alt="" /><span>Log Out</span></button>
      </div>
    </div>
  );
}

export default function V2Dashboard() {
  const params = new URLSearchParams(window.location.search);
  const previewState = params.get("state") || "";
  const emptyState = previewState === "empty";
  const [profileOpen, setProfileOpen] = useState(previewState === "profile");

  return (
    <main className="ni-v2 v2-dashboard-page">
      <Sidebar />
      <div className="v2-dashboard-main">
        <TopHeader profileOpen={profileOpen} onProfileClick={() => setProfileOpen((value) => !value)} />
        <p className="v2-dashboard-welcome mobile-only">Welcome Back 👋</p>
        <div className="v2-dashboard-title-row desktop-only"><h1>Dashboard</h1><button className="v2-dashboard-date" type="button">Last 30 days <img src={assets.dateChevron} alt="" /></button></div>
        <BalanceCard />
        <div className="v2-dashboard-metrics-scroll">{metrics.map((metric) => <MetricCard key={metric.title} metric={metric} />)}</div>
        <LaunchBanner />
        <div className="v2-dashboard-insights"><AnalyticsChart emptyState={emptyState} /><QuickActions /></div>
        <div className="v2-dashboard-lower"><LatestActivity emptyState={emptyState} /><ReferralSupport /></div>
      </div>
      <div className="v2-dashboard-floating mobile-only"><button className="is-refer" type="button"><img src={assets.floatingRefer} alt="" /></button><button className="is-help" type="button"><img src={assets.help} alt="" /></button></div>
      <MobileBottomNav />
      <MobileProfileMenu open={profileOpen} onClose={() => setProfileOpen(false)} />
    </main>
  );
}
