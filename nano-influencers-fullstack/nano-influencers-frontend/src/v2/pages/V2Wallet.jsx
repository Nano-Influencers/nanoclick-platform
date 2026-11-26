import React, { useEffect, useMemo, useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { Button } from "../components/ui/Button.jsx";
import { api } from "../../api.js";
import "./v2-wallet.css";

const ASSET_BASE = "/assets/nano-v2-app/";
const assets = {
  brand: `${ASSET_BASE}dashboard-brand.svg`, profile: `${ASSET_BASE}dashboard-profile.png`,
  notification: `${ASSET_BASE}dashboard-notification.svg`, overview: `${ASSET_BASE}dashboard-menu.svg`,
  wallet: `${ASSET_BASE}dashboard-wallet.svg`, analytics: `${ASSET_BASE}dashboard-analytics.svg`,
  settings: `${ASSET_BASE}dashboard-settings.svg`, help: `${ASSET_BASE}dashboard-help.svg`,
  logout: `${ASSET_BASE}dashboard-logout.svg`, balance: `${ASSET_BASE}dashboard-balance.svg`,
  spent: `${ASSET_BASE}dashboard-spend.svg`, referral: `${ASSET_BASE}dashboard-people.svg`,
  cashback: `${ASSET_BASE}wallet-cashback.svg`, gift: `${ASSET_BASE}wallet-gift.svg`,
  empty: `${ASSET_BASE}wallet-empty-activity.svg`, deposit: `${ASSET_BASE}dashboard-wallet.svg`,
  arrow: `${ASSET_BASE}auth-arrow-down.svg`, mobileBrand: "/assets/nano-v2/brand-mobile.svg",
  mobileWallet: `${ASSET_BASE}dashboard-wallet.svg`, mobileDashboard: `${ASSET_BASE}dashboard-menu.svg`,
  mobileCampaign: `${ASSET_BASE}dashboard-campaign.svg`, mobileAnalytics: `${ASSET_BASE}dashboard-analytics.svg`,
  cellular: `${ASSET_BASE}wallet-cellular.svg`, wifi: `${ASSET_BASE}wallet-wifi.svg`,
  battery: `${ASSET_BASE}wallet-battery-cap.svg`, success: `${ASSET_BASE}auth-confirmation.png`,
  decor: `${ASSET_BASE}dashboard-balance-decor.svg`,
};
const money = (value) => new Intl.NumberFormat("en-NG", { style: "currency", currency: "NGN" }).format(Number(value || 0));
const dateText = (value) => value ? new Date(value).toLocaleString() : "—";

function PhoneStatusBar() {
  return <div className="v2-wallet-statusbar" aria-hidden="true"><strong>9:41</strong><div className="v2-wallet-status-icons"><img src={assets.cellular} alt="" /><img src={assets.wifi} alt="" /><span className="v2-wallet-battery"><i /><img src={assets.battery} alt="" /></span></div></div>;
}
function Brand({ mobile = false }) { return <a className="v2-wallet-brand" href="/" aria-label="The Nano Influencers home"><img src={mobile ? assets.mobileBrand : assets.brand} alt="" /><span>The Nano Influencers</span></a>; }
function SidebarItem({ icon, label, href, active }) { return <a className={`v2-wallet-sidebar-item${active ? " is-active" : ""}`} href={href}><img src={icon} alt="" /><span>{label}</span></a>; }
function Sidebar() {
  const logout = async () => { await api.logout(); window.location.assign("/login"); };
  return <aside className="v2-wallet-sidebar"><div><div className="v2-wallet-sidebar-logo"><Brand /></div><nav className="v2-wallet-sidebar-nav" aria-label="Main menu"><section><p className="v2-wallet-nav-label">Main Menu</p><SidebarItem icon={assets.overview} label="Overview" href="/dashboard" /><SidebarItem icon={assets.wallet} label="Wallet" href="/wallet" active /><SidebarItem icon={assets.overview} label="Campaigns" href="/campaigns" /><SidebarItem icon={assets.analytics} label="Analytics" href="/analytics" /></section><section className="v2-wallet-support-nav"><p className="v2-wallet-nav-label">Support</p><SidebarItem icon={assets.settings} label="Settings" href="/settings" /><SidebarItem icon={assets.help} label="Help & Support" href="/support" /></section></nav></div><button className="v2-wallet-logout" type="button" onClick={logout}><span>Log Out</span><img src={assets.logout} alt="" /></button></aside>;
}
function TopHeader({ profile }) {
  return <header className="v2-wallet-topbar"><div className="v2-wallet-mobile-brand"><Brand mobile /></div><p className="v2-wallet-welcome">Welcome Back 👋</p><div className="v2-wallet-user"><a className="v2-wallet-notification" href="/campaigns/notifications" aria-label="Notifications"><img src={assets.notification} alt="" /></a><a className="v2-wallet-profile" href="/settings"><img className="desktop-profile" src={profile?.avatar_url || assets.profile} alt="" /><span>{profile?.full_name || "My Account"}</span></a></div></header>;
}
function BalanceCard({ balance, onAddFunds }) {
  return <section className="v2-wallet-balance-card"><img className="v2-wallet-balance-decor" src={assets.decor} alt="" /><div className="v2-wallet-balance-copy"><div className="v2-wallet-balance-label-row"><span className="v2-wallet-balance-icon"><img src={assets.balance} alt="" /></span><p>Current Balance</p></div><strong>{money(balance?.balance_ngn)}</strong><small>{Number(balance?.escrow_ngn || 0) ? `${money(balance.escrow_ngn)} currently held in campaign escrow` : "No funds currently held in escrow"}</small></div><Button className="v2-wallet-add-funds" onClick={onAddFunds}>Add Funds</Button></section>;
}
function MetricCard({ title, value, icon, tone }) {
  return <article className="v2-wallet-metric-card"><span className={`v2-wallet-metric-icon is-${tone}`}><img src={icon} alt="" /></span><div><p>{title}</p><strong>{money(value)}</strong></div></article>;
}
function ActivityList({ rows, loading, error, onAddFunds }) {
  return <section className="v2-wallet-activity-card is-populated"><div className="v2-wallet-activity-heading"><h2>Recent Wallet Activities</h2><button type="button" onClick={() => window.location.assign("/wallet?history=all")}>Show all</button></div>{loading ? <p role="status">Loading transactions…</p> : error ? <p role="alert">{error}</p> : rows.length ? <div className="v2-wallet-activity-list">{rows.map((tx) => <div className="v2-wallet-activity-row" key={tx.id}><div className="v2-wallet-activity-main"><span className="v2-wallet-activity-icon is-orange"><img src={assets.deposit} alt="" /></span><span><strong>{(tx.type || "Wallet activity").replaceAll("_", " ")}</strong><small>{dateText(tx.created_at)}{tx.description ? ` · ${tx.description}` : ""}</small></span></div><div className="v2-wallet-activity-meta"><strong>{money(tx.amount_ngn)}</strong><small>{tx.status || "—"}</small></div></div>)}</div> : <div className="v2-wallet-empty-state"><img src={assets.empty} alt="" /><h3>You have no wallet activity</h3><Button onClick={onAddFunds}>Add Funds</Button></div>}</section>;
}
function MobileBottomNav() { return <nav className="v2-wallet-bottom-nav" aria-label="Mobile navigation"><a href="/dashboard"><img src={assets.mobileDashboard} alt="Dashboard" /></a><a className="is-active" href="/wallet"><img src={assets.mobileWallet} alt="Wallet" /><span>Wallet</span></a><a href="/campaigns"><img src={assets.mobileCampaign} alt="Campaigns" /></a><a href="/analytics"><img src={assets.mobileAnalytics} alt="Analytics" /></a><div className="v2-wallet-home-indicator" /></nav>; }

function DepositModal({ open, onClose }) {
  const [amount, setAmount] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const enabled = import.meta.env.VITE_ENABLE_REAL_PAYMENTS === "true";
  if (!open) return null;
  const submit = async () => {
    const parsed = Number(amount.replaceAll(",", "").replace(/[₦\s]/g, ""));
    if (!Number.isFinite(parsed) || parsed < 100) { setError("Enter a valid amount of at least ₦100."); return; }
    if (!enabled) { setError("Deposits are temporarily disabled while payment verification is being completed."); return; }
    setBusy(true); setError("");
    try {
      const result = await api.initiateDeposit(parsed);
      if (!result?.authorization_url || !result?.reference) throw new Error("The payment provider did not return a valid checkout session.");
      window.location.assign(result.authorization_url);
    } catch (e) { setError(e.message || "Unable to initialize payment."); setBusy(false); }
  };
  return <div className="v2-wallet-modal" role="dialog" aria-modal="true" aria-labelledby="deposit-title"><div className="v2-wallet-modal-card"><h2 id="deposit-title">Deposit Funds</h2><div className="v2-wallet-currency-tabs"><button type="button" className="is-active">Local Currency</button><button type="button" disabled>Crypto Currency · Coming Soon</button></div><div className="v2-wallet-form-field"><label htmlFor="wallet-amount">Amount to Deposit (NGN)</label><input id="wallet-amount" value={amount} onChange={(e) => setAmount(e.target.value)} placeholder="e.g. 15,000" inputMode="decimal" /><small>Minimum deposit: ₦100</small></div>{!enabled && <p role="status">Real-money deposits are currently disabled pending completion of payment testing.</p>}{error && <p role="alert">{error}</p>}<div className="v2-wallet-modal-actions"><Button variant="secondary" onClick={onClose} disabled={busy}>Cancel</Button><Button onClick={submit} loading={busy} disabled={busy || !enabled}>Make Deposit</Button></div></div></div>;
}

export function V2Wallet() {
  const [balance, setBalance] = useState(null), [transactions, setTransactions] = useState([]), [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true), [error, setError] = useState(""), [depositOpen, setDepositOpen] = useState(false);
  const [showAll, setShowAll] = useState(new URLSearchParams(window.location.search).get("history") === "all");
  const navigate = useNavigate();
  useEffect(() => { let active = true; (async () => { try { const session = await api.restoreSession(); if (!session.ok) { navigate("/login", { replace: true }); return; } const [me, wallet, txs] = await Promise.all([api.me(), api.getBalance(), api.getTransactions({ limit: 100, offset: 0 })]); if (!active) return; setProfile(me); setBalance(wallet); setTransactions(Array.isArray(txs) ? txs : []); } catch (e) { if (active) setError(e.message || "Unable to load wallet data."); } finally { if (active) setLoading(false); } })(); return () => { active = false; }; }, [navigate]);
  const totals = useMemo(() => ({ spent: Number(balance?.total_spent_kobo || 0) / 100, earned: Number(balance?.total_earned_kobo || 0) / 100, withdrawn: Number(balance?.total_withdrawn_kobo || 0) / 100, escrow: Number(balance?.escrow_ngn || 0) }), [balance]);
  const rows = showAll ? transactions : transactions.slice(0, 5);
  return <main className="ni-v2 v2-wallet-page"><PhoneStatusBar /><Sidebar /><div className="v2-wallet-main"><TopHeader profile={profile} /><section className="v2-wallet-content"><h1>My Wallet</h1>{error && <p role="alert">{error}</p>}{loading ? <p role="status">Loading wallet…</p> : <><BalanceCard balance={balance} onAddFunds={() => setDepositOpen(true)} /><div className="v2-wallet-metrics-viewport"><div className="v2-wallet-metrics"><MetricCard title="Total Spent" value={totals.spent} icon={assets.spent} tone="green" /><MetricCard title="Total Earned" value={totals.earned} icon={assets.referral} tone="lavender" /><MetricCard title="Total Withdrawn" value={totals.withdrawn} icon={assets.cashback} tone="green" /><MetricCard title="Campaign Escrow" value={totals.escrow} icon={assets.gift} tone="lavender" /></div></div><ActivityList rows={rows} loading={false} error="" onAddFunds={() => setDepositOpen(true)} />{transactions.length > 5 && <button type="button" onClick={() => setShowAll((v) => !v)}>{showAll ? "Show recent" : "Show all transactions"}</button>}</>}</section></div><MobileBottomNav /><DepositModal open={depositOpen} onClose={() => setDepositOpen(false)} /></main>;
}

export function V2WalletSuccess() {
  const [params] = useSearchParams();
  const reference = params.get("reference") || params.get("trxref");
  const [result, setResult] = useState(null), [error, setError] = useState(""), [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  useEffect(() => { let active = true; (async () => { if (!reference) { setError("No payment reference was provided."); setLoading(false); return; } try { const session = await api.restoreSession(); if (!session.ok) throw new Error("Please log in to verify this payment."); const status = await api.getDepositStatus(reference); if (active) setResult(status); } catch (e) { if (active) setError(e.message || "Unable to verify payment."); } finally { if (active) setLoading(false); } })(); return () => { active = false; }; }, [reference]);
  const completed = result?.status === "completed";
  return <main className="ni-v2 v2-wallet-success-page"><PhoneStatusBar /><div className="v2-wallet-success-content"><section className="v2-wallet-success-header"><img src={assets.success} alt="" /><div><h1>{loading ? "Verifying payment…" : completed ? "Deposit Successful!" : "Payment not confirmed"}</h1><p>{loading ? "Please wait while we verify with the payment provider." : completed ? "Your funds have been credited." : error || `Payment status: ${result?.status || "unknown"}`}</p></div></section>{completed && <><section className="v2-wallet-success-amount"><img src={assets.decor} alt="" /><p>Amount Deposited</p><strong>{money(result.amount_ngn)}</strong></section><section className="v2-wallet-success-details"><div><span>Completed</span><strong>{dateText(result.completed_at)}</strong></div><div className="is-reference"><span>Transaction Ref</span><code>{result.reference}</code></div></section></>}<div className="v2-wallet-success-actions"><Button onClick={() => navigate("/wallet")}>Go to Wallet</Button>{!completed && !loading && <Button variant="secondary" onClick={() => window.location.reload()}>Check Again</Button>}</div></div><div className="v2-wallet-success-home-indicator" /></main>;
}
