import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "../components/ui/Button.jsx";
import "./v2-wallet.css";

const ASSET_BASE = "/assets/nano-v2-app/";
const assets = {
  brand: `${ASSET_BASE}dashboard-brand.svg`,
  profile: `${ASSET_BASE}dashboard-profile.png`,
  notification: `${ASSET_BASE}dashboard-notification.svg`,
  overview: `${ASSET_BASE}dashboard-menu.svg`,
  wallet: `${ASSET_BASE}dashboard-wallet.svg`,
  analytics: `${ASSET_BASE}dashboard-analytics.svg`,
  settings: `${ASSET_BASE}dashboard-settings.svg`,
  help: `${ASSET_BASE}dashboard-help.svg`,
  minimize: `${ASSET_BASE}wallet-minimize.svg`,
  logout: `${ASSET_BASE}dashboard-logout.svg`,
  balanceDecor: `${ASSET_BASE}dashboard-balance-decor.svg`,
  balance: `${ASSET_BASE}dashboard-balance.svg`,
  spent: `${ASSET_BASE}dashboard-spend.svg`,
  referral: `${ASSET_BASE}dashboard-people.svg`,
  cashback: `${ASSET_BASE}wallet-cashback.svg`,
  gift: `${ASSET_BASE}wallet-gift.svg`,
  emptyActivity: `${ASSET_BASE}wallet-empty-activity.svg`,
  withdrawal: `${ASSET_BASE}dashboard-spend.svg`,
  payment: `${ASSET_BASE}wallet-cashback.svg`,
  deposit: `${ASSET_BASE}dashboard-wallet.svg`,
  bonus: `${ASSET_BASE}wallet-gift.svg`,
  arrowDown: `${ASSET_BASE}auth-arrow-down.svg`,
  mobileBrand: "/assets/nano-v2/brand-mobile.svg",
  mobileProfile: `${ASSET_BASE}dashboard-profile.png`,
  mobileNotification: `${ASSET_BASE}dashboard-notification.svg`,
  mobileWallet: `${ASSET_BASE}dashboard-wallet.svg`,
  mobileDashboard: `${ASSET_BASE}dashboard-menu.svg`,
  mobileCampaign: `${ASSET_BASE}dashboard-campaign.svg`,
  mobileAnalytics: `${ASSET_BASE}dashboard-analytics.svg`,
  cellular: `${ASSET_BASE}wallet-cellular.svg`,
  wifi: `${ASSET_BASE}wallet-wifi.svg`,
  batteryCap: `${ASSET_BASE}wallet-battery-cap.svg`,
  success: `${ASSET_BASE}auth-confirmation.png`,
  successDecor: `${ASSET_BASE}dashboard-balance-decor.svg`,
};

const metrics = [
  { title: "Total Spent", value: "₦0", note: "Total Amount Spent Today:  ₦0", tone: "green", icon: assets.spent },
  { title: "Referral Earnings", value: "₦0", note: "Referral Earnings Today:  ₦0", tone: "lavender", icon: assets.referral },
  { title: "Cashback Received", value: "₦0", note: "Pending Cashbacks:  ₦0", tone: "green", icon: assets.cashback },
  { title: "Gift Received", value: "₦0", note: "Pending Gifts:  ₦0", tone: "lavender", icon: assets.gift },
];

const activities = [
  { title: "Withdrawal", date: "2026-06-18", value: "₦0", status: "completed", tone: "yellow", icon: assets.withdrawal },
  { title: "Payment", date: "2026-06-18", value: "₦0", status: "completed", tone: "green", icon: assets.payment },
  { title: "Deposit", date: "2026-06-18", value: "₦0", status: "completed", tone: "orange", icon: assets.deposit },
  { title: "Bonus", date: "2026-06-18", value: "", status: "completed", tone: "lavender", icon: assets.bonus },
];

function PhoneStatusBar() {
  return (
    <div className="v2-wallet-statusbar" aria-hidden="true">
      <strong>9:41</strong>
      <div className="v2-wallet-status-icons">
        <img src={assets.cellular} alt="" />
        <img src={assets.wifi} alt="" />
        <span className="v2-wallet-battery"><i /><img src={assets.batteryCap} alt="" /></span>
      </div>
    </div>
  );
}

function Brand({ mobile = false }) {
  return (
    <a className="v2-wallet-brand" href="/" aria-label="The Nano Influencers home">
      <img src={mobile ? assets.mobileBrand : assets.brand} alt="" />
      <span>The Nano Influencers</span>
    </a>
  );
}

function SidebarItem({ icon, label, href = "#", active = false }) {
  return (
    <a className={`v2-wallet-sidebar-item${active ? " is-active" : ""}`} href={href}>
      <img src={icon} alt="" />
      <span>{label}</span>
    </a>
  );
}

function Sidebar() {
  return (
    <aside className="v2-wallet-sidebar">
      <div>
        <div className="v2-wallet-sidebar-logo"><Brand /></div>
        <nav className="v2-wallet-sidebar-nav" aria-label="Main menu">
          <section>
            <p className="v2-wallet-nav-label">Main Menu</p>
            <SidebarItem icon={assets.overview} label="Overview" href="/dashboard" />
            <SidebarItem icon={assets.wallet} label="Wallet" href="/wallet" active />
            <SidebarItem icon={assets.overview} label="Campaigns" href="/campaigns" />
            <SidebarItem icon={assets.analytics} label="Analytics" href="/analytics" />
          </section>
          <section className="v2-wallet-support-nav">
            <p className="v2-wallet-nav-label">Support</p>
            <SidebarItem icon={assets.settings} label="Settings" href="/settings" />
            <SidebarItem icon={assets.help} label="Help & Support" href="/support" />
          </section>
        </nav>
      </div>
      <button className="v2-wallet-logout" type="button"><span>Log Out</span><img src={assets.logout} alt="" /></button>
      <span className="v2-wallet-minimize"><img src={assets.minimize} alt="" /></span>
    </aside>
  );
}

function TopHeader({ profileOpen, onProfileClick }) {
  return (
    <header className="v2-wallet-topbar">
      <div className="v2-wallet-mobile-brand"><Brand mobile /></div>
      <p className="v2-wallet-welcome">Welcome Back 👋</p>
      <div className="v2-wallet-user">
        <button className="v2-wallet-notification" type="button" aria-label="Notifications"><img className="desktop-notification" src={assets.notification} alt="" /><img className="mobile-notification" src={assets.mobileNotification} alt="" /></button>
        <button className={`v2-wallet-profile${profileOpen ? " is-open" : ""}`} type="button" aria-label="Open profile menu" aria-expanded={profileOpen} onClick={onProfileClick}><img className="desktop-profile" src={assets.profile} alt="Adaeze O." /><img className="mobile-profile" src={assets.mobileProfile} alt="Adaeze O." /><span>Adaeze O.</span></button>
      </div>
    </header>
  );
}

function BalanceCard({ populated, onAddFunds }) {
  return (
    <section className="v2-wallet-balance-card">
      <img className="v2-wallet-balance-decor" src={assets.balanceDecor} alt="" />
      <div className="v2-wallet-balance-copy">
        <div className="v2-wallet-balance-label-row">
          <span className="v2-wallet-balance-icon"><img src={assets.balance} alt="" /></span>
          <p>Current Balance</p>
        </div>
        <strong>{populated ? "₦53,009.89" : "₦0.00"}</strong>
        <small>No pending transactions</small>
      </div>
      <Button className="v2-wallet-add-funds" onClick={onAddFunds}>Add Funds</Button>
    </section>
  );
}

function MetricCard({ metric }) {
  return (
    <article className="v2-wallet-metric-card">
      <span className={`v2-wallet-metric-icon is-${metric.tone}`}><img src={metric.icon} alt="" /></span>
      <div><p>{metric.title}</p><strong>{metric.value}</strong><small>{metric.note}</small></div>
    </article>
  );
}

function RecentActivity({ populated, onAddFunds }) {
  return (
    <section className={`v2-wallet-activity-card${populated ? " is-populated" : " is-empty"}`}>
      <div className="v2-wallet-activity-heading"><h2>Recent&nbsp; Wallet Activities</h2><button type="button" className={populated ? "" : "is-muted"}>Show all</button></div>
      {populated ? (
        <div className="v2-wallet-activity-list">
          {activities.map((activity) => (
            <div className="v2-wallet-activity-row" key={activity.title}>
              <div className="v2-wallet-activity-main">
                <span className={`v2-wallet-activity-icon is-${activity.tone}`}><img src={activity.icon} alt="" /></span>
                <span><strong>{activity.title}</strong><small>{activity.date}</small></span>
              </div>
              <div className="v2-wallet-activity-meta">{activity.value && <strong>{activity.value}</strong>}<small>{activity.status}</small></div>
            </div>
          ))}
        </div>
      ) : (
        <div className="v2-wallet-empty-state">
          <img src={assets.emptyActivity} alt="" />
          <h3>You have no wallet activity</h3>
          <Button onClick={onAddFunds}>Add Funds</Button>
        </div>
      )}
    </section>
  );
}

function MobileBottomNav() {
  return (
    <nav className="v2-wallet-bottom-nav" aria-label="Mobile navigation">
      <a href="/dashboard"><img src={assets.mobileDashboard} alt="Dashboard" /></a>
      <a className="is-active" href="/wallet"><img src={assets.mobileWallet} alt="" /><span>Wallet</span></a>
      <a href="/campaigns"><img src={assets.mobileCampaign} alt="Campaigns" /></a>
      <a href="/analytics"><img src={assets.mobileAnalytics} alt="Analytics" /></a>
      <div className="v2-wallet-home-indicator" />
    </nav>
  );
}

function DepositModal({ open, onClose }) {
  const navigate = useNavigate();
  const [currency, setCurrency] = useState("local");
  const [gateway, setGateway] = useState("Paystack");
  const [amount, setAmount] = useState("");
  if (!open) return null;
  return (
    <div className="v2-wallet-modal" role="dialog" aria-modal="true" aria-labelledby="deposit-title">
      <div className="v2-wallet-modal-card">
        <h2 id="deposit-title">Deposit Funds</h2>
        <div className="v2-wallet-currency-tabs">
          <button type="button" className={currency === "local" ? "is-active" : ""} onClick={() => setCurrency("local")}>Local Currency</button>
          <button type="button" className={currency === "crypto" ? "is-active" : ""} onClick={() => setCurrency("crypto")}>Crypto Currency</button>
        </div>
        <div className="v2-wallet-form-field">
          <label htmlFor="wallet-gateway">Choose Preferred Payment Gateway</label>
          <div className="v2-wallet-select-wrap">
            <select id="wallet-gateway" value={gateway} onChange={(event) => setGateway(event.target.value)}>
              <option>Paystack</option>
            </select>
            <img src={assets.arrowDown} alt="" />
          </div>
        </div>
        <div className="v2-wallet-form-field">
          <label htmlFor="wallet-amount">Amount to Deposit</label>
          <input id="wallet-amount" value={amount} onChange={(event) => setAmount(event.target.value)} placeholder="e.g ₦15,000" inputMode="decimal" />
          <small>Minimum Deposit Amount = ₦500 Equivalent</small>
        </div>
        <div className="v2-wallet-modal-actions">
          <Button variant="secondary" onClick={onClose}>Cancel</Button>
          <Button onClick={() => navigate("/wallet/success")}>Make Deposit</Button>
        </div>
      </div>
    </div>
  );
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

export function V2Wallet() {
  const params = new URLSearchParams(window.location.search);
  const populated = params.get("state") === "activity";
  const initialDeposit = params.get("state") === "deposit";
  const [depositOpen, setDepositOpen] = useState(initialDeposit);
  const [profileOpen, setProfileOpen] = useState(false);
  const openDeposit = () => setDepositOpen(true);
  return (
    <main className={`ni-v2 v2-wallet-page${depositOpen ? " is-deposit-open" : ""}`}>
      <PhoneStatusBar />
      <Sidebar />
      <div className="v2-wallet-main">
        <TopHeader profileOpen={profileOpen} onProfileClick={() => setProfileOpen((value) => !value)} />
        <section className="v2-wallet-content">
          <h1>My Wallet</h1>
          <BalanceCard populated={populated} onAddFunds={openDeposit} />
          <div className="v2-wallet-metrics-viewport"><div className="v2-wallet-metrics">{metrics.map((metric) => <MetricCard key={metric.title} metric={metric} />)}</div></div>
          <RecentActivity populated={populated} onAddFunds={openDeposit} />
        </section>
      </div>
      <MobileBottomNav />
      <DepositModal open={depositOpen} onClose={() => setDepositOpen(false)} />
      <MobileProfileMenu open={profileOpen} onClose={() => setProfileOpen(false)} />
    </main>
  );
}

function SuccessAmountCard() {
  return (
    <section className="v2-wallet-success-amount">
      <img src={assets.successDecor} alt="" />
      <p>Amount Deposited</p>
      <strong>₦60,000.00</strong>
    </section>
  );
}

export function V2WalletSuccess() {
  const navigate = useNavigate();
  return (
    <main className="ni-v2 v2-wallet-success-page">
      <PhoneStatusBar />
      <div className="v2-wallet-success-content">
        <section className="v2-wallet-success-header">
          <img src={assets.success} alt="" />
          <div><h1>Deposit Successful!</h1><p>Your funds have been credited</p></div>
        </section>
        <SuccessAmountCard />
        <section className="v2-wallet-success-details">
          <div><span>Date</span><strong>17 July 2026</strong></div>
          <div><span>Time</span><strong>11:55 am</strong></div>
          <div><span>Payment Method</span><strong>Paystack</strong></div>
          <div className="is-reference"><span>Transaction Ref</span><code>TXN-20260730078</code></div>
        </section>
        <div className="v2-wallet-success-actions">
          <Button onClick={() => navigate("/wallet")}>Go to Wallet</Button>
          <Button variant="secondary" onClick={() => navigate("/campaigns")}>Launch a Campaign</Button>
        </div>
      </div>
      <div className="v2-wallet-success-home-indicator" />
    </main>
  );
}
