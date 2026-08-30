import React, {createContext, useContext, useEffect, useState} from "react";
import {createRoot} from "react-dom/client";
import {BrowserRouter, NavLink, Route, Routes, useNavigate, useLocation, Navigate} from "react-router-dom";
import "./styles.css";
import {api, ApiError} from "./api.js";
import {AuthProvider, useAuth, ProtectedRoute, LoginPage, RegisterPage, OAuthCallbackPage} from "./auth.jsx";

const icons = {
  home: <svg viewBox="0 0 24 24"><path d="M3 10.8 12 3l9 7.8v9.2a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/></svg>,
  wallet: <svg viewBox="0 0 24 24"><path d="M4 6h14a3 3 0 0 1 3 3v9a2 2 0 0 1-2 2H5a3 3 0 0 1-3-3V6a2 2 0 0 1 2-2h14v3H4z"/><path d="M16 13h5v4h-5a2 2 0 0 1 0-4z"/></svg>,
  campaign: <svg viewBox="0 0 24 24"><path d="M4 13h4l9 5V6l-9 5H4a2 2 0 0 0 0 4z"/><path d="M8 14l2 6H7l-2-6M19 9a5 5 0 0 1 0 6"/></svg>,
  bell: <svg viewBox="0 0 24 24"><path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4"/></svg>,
  settings: <svg viewBox="0 0 24 24"><path d="m9.5 3 .5 2.1a7 7 0 0 1 4 0L14.5 3h2l.9 2 2 .9 1.9-.7 1.1 1.8-1.4 1.5a7 7 0 0 1 0 4l1.4 1.5-1.1 1.8-1.9-.7-2 .9-.9 2h-2l-.5-2.1a7 7 0 0 1-4 0L9.5 21h-2l-.9-2-2-.9-1.9.7-1.1-1.8L3 15.5a7 7 0 0 1 0-4L1.6 10l1.1-1.8 1.9.7 2-.9.9-2z"/><circle cx="12" cy="12" r="2.5"/></svg>,
  plus: <svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg>,
  arrow: <svg viewBox="0 0 24 24"><path d="m9 18 6-6-6-6"/></svg>,
  close: <svg viewBox="0 0 24 24"><path d="m6 6 12 12M18 6 6 18"/></svg>,
  check: <svg viewBox="0 0 24 24"><path d="m5 12 4 4L19 6"/></svg>,
  filter: <svg viewBox="0 0 24 24"><path d="M4 6h16M7 12h10M10 18h4"/></svg>,
  support: <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M8 15h8M9 9h.01M15 9h.01"/></svg>,
  gift: <svg viewBox="0 0 24 24"><rect x="3" y="8" width="18" height="13" rx="1"/><path d="M3 12h18M12 8v13"/><path d="M12 8c-1.5-4-6-4-6-1s3 1 6 1 6 2 6-1-4.5-3-6 1z"/></svg>,
  megaphone: <svg viewBox="0 0 24 24"><path d="M4 13h4l9 5V6l-9 5H4a2 2 0 0 0 0 4z"/><path d="M8 14l2 6H7l-2-6M19 9a5 5 0 0 1 0 6"/></svg>,
  chevronDown: <svg viewBox="0 0 24 24"><path d="m6 9 6 6 6-6"/></svg>,
  play: <svg viewBox="0 0 24 24" fill="currentColor" stroke="none"><path d="M8 5v14l11-7z"/></svg>,
  menu: <svg viewBox="0 0 24 24"><path d="M4 7h16M4 12h16M4 17h16"/></svg>,
  people: <svg viewBox="0 0 24 24"><circle cx="8" cy="8" r="3"/><circle cx="17" cy="9" r="2.5"/><path d="M2 20c0-3.5 2.7-6 6-6s6 2.5 6 6M14 20c0-2.5 1.8-4.5 4-4.5s4.5 1.6 5 4.5"/></svg>,
  chat: <svg viewBox="0 0 24 24"><path d="M4 5h16v11H8l-4 4z"/></svg>,
  sparkle: <svg viewBox="0 0 24 24"><path d="M12 2v4M12 18v4M2 12h4M18 12h4M5 5l3 3M16 16l3 3M19 5l-3 3M8 16l-3 3"/></svg>,
  swap: <svg viewBox="0 0 24 24"><path d="M4 8h13l-3-3M20 16H7l3 3"/></svg>,
  bulb: <svg viewBox="0 0 24 24"><path d="M9 18h6M10 21h4"/><path d="M12 3a6 6 0 0 0-3 11.2c.6.4 1 1.1 1 1.8h4c0-.7.4-1.4 1-1.8A6 6 0 0 0 12 3z"/></svg>,
  globe: <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c2.5 2.6 4 6 4 9s-1.5 6.4-4 9c-2.5-2.6-4-6-4-9s1.5-6.4 4-9z"/></svg>,
  facebook: <svg viewBox="0 0 24 24" fill="currentColor" stroke="none"><path d="M14 9h3V5h-3c-2.2 0-4 1.8-4 4v2H8v4h2v6h4v-6h3l1-4h-4V9c0-.6.4-1 1-1z"/></svg>,
  twitterx: <svg viewBox="0 0 24 24"><path d="m4 4 16 16M20 4 4 20"/></svg>,
  youtube: <svg viewBox="0 0 24 24"><rect x="3" y="6" width="18" height="12" rx="3"/><path d="m10 9 5 3-5 3z" fill="currentColor" stroke="none"/></svg>,
  tiktok: <svg viewBox="0 0 24 24"><path d="M14 4v10.5a3 3 0 1 1-3-3"/><path d="M14 4c0 2.5 2 4.5 4 4.5"/></svg>,
  instagram: <svg viewBox="0 0 24 24"><rect x="4" y="4" width="16" height="16" rx="4"/><circle cx="12" cy="12" r="3.5"/><circle cx="16.5" cy="7.5" r=".8" fill="currentColor" stroke="none"/></svg>
};

function Icon({name, size=20}) {
  return <span className="icon" style={{width:size,height:size}}>{icons[name]}</span>;
}

// [name, glyph, color, apiPlatformValue]
const platforms = [
  ["Facebook","f","#1877F2","facebook"],["YouTube","▶","#FF0000","youtube"],["X","X","#000000","twitter"],["WhatsApp","◉","#25D366","whatsapp"],
  ["Instagram","◎","#C1327A","instagram"],["Telegram","➤","#229ED9","telegram"],["TikTok","♪","#111111","tiktok"],["LinkedIn","in","#0A66C2","linkedin"],
  ["Audiomack","♫","#FFA200","audiomack"],["Spotify","●","#1DB954","spotify"],["BoomPlay","B","#E4405F","boomplay"],["YT Music","▶","#FF0033","youtube_music"]
];

const actionTypes = [
  ["like","Like"],["follow","Follow"],["comment","Comment"],["share","Share"],
  ["subscribe","Subscribe"],["join","Join"],["repost","Repost"],["stream","Stream"],["trend","Trend / Push"]
];

const services = [
  {name:"Engaged Growth", tni:"engaged_growth", action:"follow", purpose:"Build Long-Term Community", delivery:"Assigned followers in your niche who follow permanently & continually engage with your content while sharing on WhatsApp for more audience", platform:"Instagram, Facebook, X (Twitter), YouTube, LinkedIn, and TikTok", best:"Creators, Brands, Influencers, Businesses and anyone seeking constant visibility.", tone:"blue"},
  {name:"Word of Mouth", tni:"word_of_mouth", action:"share", purpose:"Expand Reach", delivery:"Natural sharing and recommendation from people who genuinely discover your profile or campaign.", platform:"WhatsApp, Instagram, Facebook and other social channels", best:"Brands and creators seeking social proof and awareness.", tone:"red"}
];

// ---------- Landing page content (transcribed from the marketing PDF) ----------
const landingServices = [
  {tag:"Flagship Service", title:"Engaged Growth", icon:"people", heading:"How It Works:", bullets:[
    "We assign verified real people in your niche/interested in your brand/product or services to follow you permanently.",
    "They like, comment, share to real persons interested in your content, product/services every time you make a post.",
    "They push your content responsibly into WhatsApp groups, statuses & DMs for organic spread, to attract Customers & Audiences even when you sleep."
  ]},
  {tag:"Promotion/Advertising", title:"Word-of-Mouth", icon:"chat", heading:"Benefits:", bullets:[
    "Trusted recommendations — higher conversion than traditional ads.",
    "Affordable, high-impact alternative to expensive ads.",
    "Creates a viral echo effect — people hear about you from multiple friends in the same circles.",
    "Builds instant and sustains longer visibility credibility & social proof inside trusted communities."
  ]},
  {tag:"Flexible Boosts", title:"Custom & Single Tasks", icon:"sparkle", heading:"Features:", bullets:[
    "Set campaign speed — deliver results in as fast as 1hr or spread over days.",
    "Target by location, industry, or audience niche for precise impact.",
    "Create flexible one-off or multi-step actions (like + follow + join + share).",
    "Every action is verified & reported so you see real results."
  ]}
];

const landingSpecial = [
  {icon:"swap", title:"Buy & Sell Your Crypto", intro:"Fast, Secure Swap for all Digital Assets at Affordable rate on WhatsApp:", bullets:[
    "Instant NGN ↔ USDT/USDC/BTC",
    "Best-rate quotes + proof of transaction",
    "WhatsApp support for verification"
  ], link:"Start a Swap"},
  {icon:"bulb", title:"Get Business Plans & Ideas", intro:"Ready-to-use plans and fresh ideas to launch or grow:", bullets:[
    "Industry-specific templates (retail, food, tech, services)",
    "Editable financials & pitch outline",
    "Delivery in any format"
  ], link:"Get a Business Plan"},
  {icon:"globe", title:"Get a Website for Your Business", intro:"Look professional and convert more.", bullets:[
    "One-page or multi-page sites (mobile-first)",
    "Contact forms, WhatsApp chat, basic SEO",
    "7-day turnaround options"
  ], link:"Build a Website"}
];

const faqs = [
  {q:"How do I know the engagement is from real people and not bots?", a:"Every follower and engager on Nano Influencers is a verified, real profile — not an automated bot. Each action is logged and reviewed before it counts toward your campaign."},
  {q:"If I pay for Engaged Growth, do the followers remain after my subscription ends?", a:"Yes. Engaged Growth is built for permanence — the people assigned to follow you stay following after your active campaign period ends."},
  {q:"How do I know people are actually recommending my brand in real conversations?", a:"Word-of-Mouth participants submit proof of their shares and mentions, which you can review from your campaign's Proofs tab."},
  {q:"Why should I use Word-of-Mouth instead of just running Ads?", a:"Recommendations from real people convert better and cost less than paid ads, and they build lasting trust inside communities rather than a one-off impression."},
  {q:"What kind of Custom Tasks can I create?", a:"Anything from a single like or follow to a multi-step action combining likes, follows, joins and shares across any supported platform."},
  {q:"How fast can a Custom Task be completed?", a:"Depending on scope, results can start arriving in as little as an hour, or be spread over several days if you prefer a slower, more natural pace."},
  {q:"What happens if my campaign doesn't deliver as promised?", a:"Unspent balances are automatically refunded to your wallet, and our support team reviews any delivery issue you report."},
  {q:"How do I track campaign performance?", a:"Your dashboard's Campaign Analytics section shows reach, impressions and engagement for every active and completed campaign."}
];

// ==================== DATA LAYER ====================
// Replaces the old window "nano-action" event bus + local demo state with
// real backend-backed data. Fetched once the advertiser is authenticated.
const DataContext = createContext(null);
function useData(){ return useContext(DataContext); }

function DataProvider({children}) {
  const [wallet,setWallet] = useState(null);
  const [campaigns,setCampaigns] = useState([]);
  const [transactions,setTransactions] = useState([]);
  const [notifications,setNotifications] = useState([]);
  const [loading,setLoading] = useState(true);
  const [toast,setToast] = useState("");
  const notify = (m) => { setToast(m); setTimeout(()=>setToast(""),3000); };

  const refreshWallet = async () => { try { setWallet(await api.getBalance()); } catch {} };
  const refreshTransactions = async () => { try { setTransactions(await api.getTransactions()); } catch {} };
  const refreshCampaigns = async () => { try { setCampaigns(await api.listCampaigns()); } catch {} };
  const refreshNotifications = async () => { try { setNotifications(await api.listNotifications()); } catch {} };
  const refreshAll = async () => {
    setLoading(true);
    await Promise.all([refreshWallet(), refreshTransactions(), refreshCampaigns(), refreshNotifications()]);
    setLoading(false);
  };

  useEffect(()=>{ refreshAll(); },[]);

  const createCampaign = async (payload) => {
    await api.createCampaign(payload);
    await refreshCampaigns();
    await refreshWallet();
    notify("Campaign created — pending admin approval.");
  };
  const updateCampaignStatus = async (id, status) => {
    await api.updateCampaignStatus(id, status);
    await refreshCampaigns();
    if (status === "cancelled") await refreshWallet();
    notify(status==="paused"?"Campaign paused.":status==="active"?"Campaign resumed.":status==="cancelled"?"Campaign cancelled and budget refunded.":"Campaign updated.");
  };
  const markRead = async (id) => { await api.markNotificationRead(id); await refreshNotifications(); };
  const markAllRead = async () => { await api.markAllNotificationsRead(); await refreshNotifications(); };
  const fundWallet = async (amountNgn) => {
    const data = await api.initiateDeposit(amountNgn);
    window.location.href = data.authorization_url;
  };

  const unreadCount = notifications.filter(n=>!n.is_read).length;

  return <DataContext.Provider value={{
    wallet, campaigns, transactions, notifications, unreadCount, loading, notify, toast,
    refreshAll, refreshWallet, refreshCampaigns, refreshNotifications,
    createCampaign, updateCampaignStatus, markRead, markAllRead, fundWallet,
  }}>{children}</DataContext.Provider>;
}

// campaign.status (backend) -> UI bucket used by the existing components
function uiStatus(status){
  if (status==="active") return "ongoing";
  if (status==="pending_admin") return "pending";
  return status; // paused | completed | cancelled
}
function fmtDate(iso){
  if(!iso) return "";
  const d = new Date(iso);
  return d.toLocaleDateString(undefined,{month:"numeric",day:"numeric",year:"2-digit"}) + " Time: " + d.toLocaleTimeString(undefined,{hour:"numeric",minute:"2-digit"});
}
function fmtRelative(iso){
  const diffMs = Date.now() - new Date(iso).getTime();
  const mins = Math.floor(diffMs/60000);
  if(mins < 1) return "Just now";
  if(mins < 60) return mins+"m ago";
  const hrs = Math.floor(mins/60);
  if(hrs < 24) return hrs+"h ago";
  return Math.floor(hrs/24)+"d ago";
}

// ==================== APP ====================
function App() {
  return <Routes>
    <Route path="/" element={<LandingPage/>}/>
    <Route path="/login" element={<LoginPage/>}/>
    <Route path="/register" element={<RegisterPage/>}/>
    <Route path="/oauth-callback" element={<OAuthCallbackPage/>}/>
    <Route path="/app/*" element={
      <ProtectedRoute>
        <DataProvider>
          <AuthedApp/>
        </DataProvider>
      </ProtectedRoute>
    }/>
    <Route path="*" element={<LandingPage/>}/>
  </Routes>
}

function AuthedApp(){
  const {toast} = useData();
  const [modal,setModal] = useState(null);
  return <>
    <AppShell modal={modal} setModal={setModal}>
      <Routes>
        <Route path="" element={<Dashboard setModal={setModal}/>}/>
        <Route path="campaign" element={<CampaignPage setModal={setModal}/>}/>
        <Route path="campaigns" element={<ManageCampaigns setModal={setModal}/>}/>
        <Route path="campaigns/ongoing" element={<CampaignList title="Ongoing Campaigns" status="ongoing" setModal={setModal}/>}/>
        <Route path="campaigns/pending" element={<CampaignList title="Pending Campaigns" status="pending" setModal={setModal}/>}/>
        <Route path="notifications" element={<Notifications/>}/>
        <Route path="wallet" element={<Wallet setModal={setModal}/>}/>
        <Route path="gifts" element={<Gifts/>}/>
        <Route path="referral" element={<ReferralPage/>}/>
        <Route path="*" element={<Dashboard setModal={setModal}/>}/>
      </Routes>
    </AppShell>
    {modal && <Modal modal={modal} close={()=>setModal(null)}/>}
    {toast && <div className="toast">{toast}</div>}
  </>
}

function AppShell({children,modal,setModal}) {
  const location=useLocation();
  const {user,logout} = useAuth();
  const isDashboard = location.pathname==="/app";
  const initial = (user?.full_name||"?").trim().charAt(0).toUpperCase();
  return <div className="app">
    {isDashboard && <header className="topbar">
      <div className="brand"><span className="avatar">{initial}</span><div><small>Welcome</small><strong>{user?.full_name?.split(" ")[0] || "there"}</strong></div></div>
      <div className="top-actions"><HeaderBell/><button onClick={logout} title="Log out"><Icon name="settings"/></button></div>
    </header>}
    <main>{children}</main>
    <BottomNav/>
  </div>
}

function HeaderBell(){
  const navigate=useNavigate();
  const {unreadCount} = useData();
  return <button aria-label="Notifications" onClick={()=>navigate("/app/notifications")} style={{position:"relative"}}>
    <Icon name="bell"/>
    {unreadCount>0 && <span className="notif-dot">{unreadCount>9?"9+":unreadCount}</span>}
  </button>;
}

function BottomNav() {
  const items=[["/app","home","Dashboard"],["/app/wallet","wallet","Wallet"],["/app/campaign","campaign","Campaign"],["/app/gifts","gift","Gifts"],["/app/referral","megaphone","Referral"]];
  return <nav className="bottom-nav">{items.map(([to,icon,label])=><NavLink key={to} to={to} end={to==="/app"} className={({isActive})=>isActive?"active":""}><Icon name={icon} size={22}/><span>{label}</span></NavLink>)}</nav>
}
function Gifts(){return <div className="page simple-page"><PageHeader title="Gifts" back/><div className="content-wrap"><Promo title="Win Gifts" text="Get 1% cashback + a chance to win in our weekly raffle when you create a campaign & share us on WhatsApp!" button="See Gifts" tone="red"/></div></div>}
function ReferralPage(){return <div className="page simple-page"><PageHeader title="Referral" back/><div className="content-wrap"><Referral/></div></div>}

function Dashboard({setModal}) {
  const {wallet, campaigns, loading} = useData();
  const ongoing = campaigns.filter(c=>uiStatus(c.status)==="ongoing").length;
  const balance = wallet?.balance_ngn ?? 0;
  return <div className="page dashboard">
    <section className="hero-dark">
      <div className="balance"><span>Current Balance</span><b>{loading ? "…" : "₦"+balance.toLocaleString()}</b></div>
      <div className="stat-grid">
        <StatCard title="Active Campaigns" value={loading?"…":ongoing} icon="campaign" action="See Campaign" to="/app/campaigns"/>
        <StatCard title="Spend Overview" value={loading?"…":"₦"+balance.toLocaleString()} action="View Wallet" to="/app/wallet"/>
      </div>
    </section>
    <div className="content-wrap">
      <section className="launch-card"><div><h2>Launch a Campaign</h2><p>Get real People to Promote your brand.<br/>They Engage with your Brand/Profile.</p><button className="linkish" onClick={()=>setModal({type:"campaign"})}>Manage Campaign</button></div><button className="white-cta" onClick={()=>setModal({type:"campaign"})}>Start Now</button></section>
      <section className="fund-card" onClick={()=>setModal({type:"fund"})}><div><Icon name="wallet"/><div><h2>Add Funds</h2><p>(Click on the Plus sign to fund your wallet)</p></div></div><button><Icon name="plus"/></button></section>
      <Referral/>
      <div className="promo-row"><Promo title="Win Gifts" text="Get 1% cashback + a chance to win in our weekly raffle when you create a campaign & share us on WhatsApp!" button="See Gifts" tone="red"/></div>
      <div className="promo-row"><Promo title="Try for Free" text="Try our services for free (Limited Order) – 2 free trial chances every week!" button="Try Freemium" tone="blue" onClick={()=>setModal({type:"freemium"})}/></div>
      <Analytics/>
      <Activity/>
      <Support onClick={()=>setModal({type:"support"})}/>
    </div>
  </div>
}

function StatCard({title,value,icon,action,to}) {
  const navigate=useNavigate();
  return <div className="stat-card"><div><h2>{title}</h2><b>{value}</b></div>{icon&&<span className="round-icon"><Icon name={icon}/></span>}<button onClick={()=>navigate(to)}>{action}</button></div>
}
function Referral(){
  const {user} = useAuth();
  const [copied,setCopied] = useState(false);
  const link = user ? `https://nano-influencers.com/r/${user.referral_code}` : "";
  const copy = () => { navigator.clipboard?.writeText(link); setCopied(true); setTimeout(()=>setCopied(false),1500); };
  return <section className="referral"><small>Refer a Friend</small><p>Earn 2% on every campaign your referral starts & qualify for our bi-weekly Gadgets giveaway</p><div className="ref-input"><span>{link}</span><button onClick={copy}>{copied?"✓":"⧉"}</button></div></section>
}
function Promo({title,text,button,tone,onClick}){return <section className={"promo "+tone}><div><h2>{title}</h2><p>{text}</p></div><button onClick={onClick}>{button}</button></section>}
function Analytics(){return <section className="analytics"><div className="section-head"><h3>Last Campaign Analytics</h3><a>Performance Metrics</a></div><div className="legend"><span><i/>Reach</span><span><i/>Impression</span><span><i/>Engagement</span></div><div className="chart"><svg viewBox="0 0 800 210" preserveAspectRatio="none"><path d="M20 120 L200 125 L390 122 L560 170 L780 160"/><path d="M20 90 L200 105 L390 96 L560 135 L780 45"/><path d="M20 165 L200 160 L390 150 L560 178 L780 168"/></svg></div><div className="periods"><span>○ Hourly</span><span>○ Daily</span><span>○ Weekly</span><span>◉ Monthly</span></div><a className="center-link">View all Campaign Analytics</a></section>}
function Activity(){
  const {transactions} = useData();
  const items = transactions.slice(0,3);
  return <section className="activity"><div className="section-head"><h3>Latest Activity</h3><a>Show all ›</a></div>
    {items.length===0 && <p className="muted-empty" style={{textAlign:"left"}}>No activity yet.</p>}
    {items.map((tx)=><div className="activity-item" key={tx.id}>
      <span className="activity-dot">◌</span>
      <div><b>{txLabel(tx.type)}</b>{tx.description && <small>{tx.description}</small>}</div>
      <div className="activity-right"><b>₦{Number(tx.amount_ngn).toLocaleString()}</b><small>{fmtRelative(tx.created_at)}</small></div>
    </div>)}
  </section>
}
function txLabel(type){
  const map = {deposit:"Deposit Alert", withdrawal:"Withdrawal", escrow_lock:"Campaign Funded", escrow_release:"Budget Refunded", task_earning:"Task Earning"};
  return map[type] || type.replace(/_/g," ").replace(/\b\w/g,c=>c.toUpperCase());
}
function Support({onClick}){return <section className="support"><div className="section-head"><h3>Dispute and Support</h3></div><div className="support-row"><span><Icon name="support"/> Any Issues?</span><button onClick={onClick}>Contact Support</button></div></section>}

function CampaignPage({setModal}) {
  const [platformsExpanded,setPlatformsExpanded]=useState(false);
  const navigate=useNavigate();
  const {campaigns} = useData();
  return <div className="page campaign-page">
    <section className="campaign-hero"><div className="own-header"><h1>Campaign</h1><div className="own-header-actions"><button onClick={()=>navigate("/app/notifications")}><Icon name="bell"/></button></div></div><div className="service-label">Our Service:</div><div className="service-track">{services.map(s=><ServiceCard key={s.name} service={s} onStart={()=>setModal({type:"create",service:s})}/>)}</div><a className="video-link">Watch Video to Learn More</a></section>
    <section className="other-services"><SectionPill>Other Services</SectionPill><p>Great for single/one-time tasks</p><PlatformGrid expanded={platformsExpanded} onPick={(p)=>setModal({type:"platform",platform:p})}/><a>Watch Video for more info about this Service</a>{!platformsExpanded && <button className="red-btn" onClick={()=>setPlatformsExpanded(true)}>See More</button>}</section>
    <section className="custom-task"><p>Great for Multiple task creation<br/>across any type of Platform.</p><button onClick={()=>setModal({type:"custom"})}>Create Custom Task</button></section>
    <ManagePreview campaigns={campaigns} setModal={setModal}/>
    <section className="special-services"><SectionPill>Special Services</SectionPill><div className="special-grid">{["Get a Google form","Get Website for your Business","Buy/Sell Crypto","Buy Business Plan/Ideas"].map(x=><button key={x}>{x}</button>)}</div></section>
  </div>
}
function SectionPill({children}){return <div className="pill">{children}</div>}
function ServiceCard({service,onStart}){return <article className={"service-card "+service.tone}><h2>{service.name}</h2><div className="service-row"><b>Purpose</b><span>{service.purpose}</span></div><div className="service-row"><b>Delivery</b><span>{service.delivery}</span></div><div className="service-row"><b>Platform</b><span>{service.platform}</span></div><div className="service-row"><b>Best For</b><span>{service.best}</span></div><button onClick={onStart}>Start Now</button></article>}
function PlatformGrid({expanded,onPick}){
  const shown = expanded?platforms:platforms.slice(0,8);
  return <div className="platform-grid">{shown.map(p=><button key={p[0]} title={p[0]} onClick={()=>onPick(p)}><strong style={{background:p[2]}}>{p[1]}</strong><small>{p[0]}</small></button>)}</div>
}
function ManagePreview({campaigns,setModal}){return <section className="manage-preview"><h3>Manage Campaigns</h3>{campaigns.filter(c=>uiStatus(c.status)!=="cancelled").slice(0,2).map(c=><CampaignCard key={c.id} campaign={c} setModal={setModal}/>)}{!campaigns.length&&<p>No Campaign Available at the Moment</p>}<button className="outline-btn" onClick={()=>{}}>Go to Campaign Management</button></section>}

function ManageCampaigns({setModal}) {
  const navigate=useNavigate();
  const {campaigns, notifications} = useData();
  const ongoing=campaigns.filter(c=>uiStatus(c.status)==="ongoing");
  const pending=campaigns.filter(c=>uiStatus(c.status)==="pending");
  return <div className="page list-page manage-page">
    <div className="page-header"><h1>Manage Campaign</h1><a className="history-link" onClick={()=>navigate("/app/notifications")}>History</a></div>
    <div className="list-stack">
      <h3 className="section-title">Ongoing Campaigns</h3>
      {ongoing.slice(0,2).map(c=><CampaignCard key={c.id} campaign={c} setModal={setModal}/>)}
      {!ongoing.length&&<p className="muted-empty">No Ongoing Campaign at the Moment</p>}
      <button className="outline-btn" onClick={()=>navigate("/app/campaigns/ongoing")}>See All Ongoing Campaign</button>

      <h3 className="section-title">Pending Campaign</h3>
      {pending.slice(0,2).map(c=><CampaignCard key={c.id} campaign={c} setModal={setModal}/>)}
      {!pending.length&&<p className="muted-empty">No Pending Campaign at the Moment</p>}
      <button className="outline-btn" onClick={()=>navigate("/app/campaigns/pending")}>See All</button>

      <div className="section-head" style={{marginTop:20}}><h3 className="section-title" style={{margin:0}}>Campaign Notification</h3><a onClick={()=>navigate("/app/notifications")}>See All</a></div>
      {notifications.slice(0,2).map((n)=><article key={n.id} className="notification"><span className="bell-badge"><Icon name="bell"/></span><div><b>{n.title}</b><p>{n.body}</p></div><small>{fmtRelative(n.created_at)}</small></article>)}
      {!notifications.length && <p className="muted-empty">No notifications yet</p>}
    </div>
  </div>
}

function CampaignList({title,status,setModal}) {
  const {campaigns} = useData();
  const list=campaigns.filter(c=>uiStatus(c.status)===status);
  return <div className="page list-page"><PageHeader title={title} back backStyle="text"/><div className="list-stack">{list.map(c=><CampaignCard key={c.id} campaign={c} setModal={setModal}/>)}</div>{!list.length&&<Empty title={"No "+status+" campaigns"} button="Go Back" />}</div>
}

// Campaign card: matches the Figma structure — a plain header row (service type +
// created date) sits above a distinctly bordered box containing the task name and
// its action buttons; proof / link-submission content sits below that box.
function CampaignCard({campaign,setModal}) {
  const st = uiStatus(campaign.status);
  const showProof = st==="ongoing" || st==="paused";
  const label = SERVICE_LABELS[campaign.tni_service_type];
  const nameParts = label ? label.split(" ") : null;
  return <article className="campaign-card">
    <div className="card-top">
      {nameParts ? <b>{nameParts.slice(0,-1).join(" ")} <span className="hl">{nameParts[nameParts.length-1]}</span></b> : <span/>}
      <small>Created: {fmtDate(campaign.created_at)}</small>
    </div>
    <div className="card-box">
      <h4>{campaign.title}</h4>
      <div className="card-actions">
        <button onClick={()=>setModal({type:"details",campaign})}>Details</button>
        {st==="ongoing" && <button onClick={()=>setModal({type:"pause",campaign})}>Pause</button>}
        {st==="paused" && <button onClick={()=>setModal({type:"resume",campaign})}>Turn on</button>}
        {(st==="ongoing"||st==="pending"||st==="paused") && <button onClick={()=>setModal({type:"delete",campaign})}>Delete</button>}
      </div>
    </div>
    {showProof && <p>Slots filled: {campaign.slots_filled} / {campaign.slots_total}</p>}
  </article>
}
const SERVICE_LABELS = {engaged_growth:"Engaged Growth", word_of_mouth:"Word of Mouth", single_one_time:null, custom:null, try_for_free:"Try for Free", trend_on_x:"Trend on X", high_value:"High Value"};

function Notifications() {
  const navigate=useNavigate();
  const {notifications, markRead, markAllRead} = useData();
  if(!notifications.length) return <div className="page notifications"><PageHeader title="Campaign Notifications" back gradient/><div className="empty"><h2>No Notifications Available</h2><button onClick={()=>navigate("/app")}>Go Back Home</button></div></div>;
  return <div className="page notifications">
    <PageHeader title="Campaign Notifications" back gradient/>
    <button className="filter" onClick={markAllRead}>Mark all as read</button>
    <div className="notification-list">{notifications.map((n)=><NotificationRow key={n.id} n={n} onOpen={()=>!n.is_read && markRead(n.id)}/>)}</div>
  </div>
}
function NotificationRow({n,onOpen}){
  return <article className={"notification"+(n.is_read?"":" unread")} onClick={onOpen}>
    <span className="bell-badge"><Icon name="bell"/></span>
    <div><b>{n.title}</b><p>{n.body}</p></div>
    <small>{fmtRelative(n.created_at)}</small>
  </article>
}

function Wallet({setModal}) {
  const navigate=useNavigate();
  const {wallet, transactions, loading} = useData();
  const balance = wallet?.balance_ngn ?? 0;
  const totalFunded = wallet ? (wallet.total_spent_kobo + wallet.balance_kobo)/100 : 0;
  return <div className="page wallet-page">
    <div className="own-header wallet-own-header"><h1><Icon name="wallet" size={22}/> My Wallet</h1><div className="own-header-actions"><button onClick={()=>navigate("/app/notifications")}><Icon name="bell"/></button></div></div>
    <section className="wallet-head"><div><span>Available Balance</span><b>{loading?"…":"₦"+balance.toLocaleString()}</b></div><div className="wallet-total"><span>Total Amount Funded</span><b>{loading?"…":"₦"+totalFunded.toLocaleString()}</b></div></section>
    <div className="wallet-body">
      <section className="fund-card large" onClick={()=>setModal({type:"fund"})}><div><h2>Add Funds</h2><p>(Click on the Plus sign to fund your wallet)</p></div><button><Icon name="plus"/></button></section>
      <section className="recent"><h3>Recent Wallet Activity</h3>
        {transactions.slice(0,5).map(tx=><div className="wallet-activity" key={tx.id}><span>●</span><div><b>{txLabel(tx.type)} — ₦{Number(tx.amount_ngn).toLocaleString()}</b><small>{fmtRelative(tx.created_at)}</small></div></div>)}
        {!transactions.length && <p className="muted-empty">No wallet activity yet</p>}
      </section>
      <Support onClick={()=>setModal({type:"support"})}/>
    </div>
  </div>
}

function PageHeader({title,back,backStyle="arrow",gradient}) {
  const navigate=useNavigate();
  return <div className={"page-header"+(gradient?" gradient":"")}>
    {back && backStyle==="arrow" && <button onClick={()=>navigate(-1)}>‹</button>}
    <h1>{title}</h1>
    {back && backStyle==="text" && <a className="go-back-link" onClick={()=>navigate(-1)}>Go Back</a>}
    {title.includes("Notification")&&<span className="filter-circle"><Icon name="filter"/></span>}
  </div>
}
function Empty({title,button}){const navigate=useNavigate();return <div className="empty"><h2>{title}</h2><button onClick={()=>navigate("/app")}>{button}</button></div>}

// ==================== MODALS ====================
function Modal({modal,close}) {
  const {createCampaign, updateCampaignStatus, fundWallet, notify} = useData();
  const navigate=useNavigate();

  if(modal.type==="fund") return <FundModal close={close} fundWallet={fundWallet} notify={notify}/>;
  if(modal.type==="create"||modal.type==="platform"||modal.type==="custom"||modal.type==="freemium")
    return <CampaignFormModal modal={modal} close={close} createCampaign={createCampaign} notify={notify} navigate={navigate}/>;
  if(modal.type==="support") return <SupportModal close={close}/>;
  if(modal.type==="details") return <DetailsModal close={close} campaign={modal.campaign}/>;
  if(modal.type==="pause") return <ConfirmModal close={close} lead="The Campaign would be on hold until you Turn it on again." confirmLabel="Pause Now"
    onConfirm={async()=>{await updateCampaignStatus(modal.campaign.id,"paused");close();}}/>;
  if(modal.type==="resume") return <ConfirmModal close={close} lead="Your campaign will resume and continue running." confirmLabel="Turn On"
    onConfirm={async()=>{await updateCampaignStatus(modal.campaign.id,"active");close();}}/>;
  if(modal.type==="delete") return <DeleteModal close={close} onConfirm={async()=>{await updateCampaignStatus(modal.campaign.id,"cancelled");close();}}/>;
  return null;
}
function Overlay({children,close}){return <div className="overlay" onMouseDown={e=>e.target===e.currentTarget&&close()}>{children}</div>}

function FundModal({close,fundWallet,notify}){
  const [amount,setAmount]=useState("");
  const [busy,setBusy]=useState(false);
  const [error,setError]=useState("");
  const submit = async () => {
    const n = Number(amount);
    if(!n || n < 100){ setError("Minimum deposit is ₦100"); return; }
    setBusy(true); setError("");
    try{ await fundWallet(n); }
    catch(err){ setError(err instanceof ApiError ? err.message : "Could not start the deposit — please try again."); setBusy(false); }
  };
  return <Overlay close={close}><div className="modal">
    <button className="modal-close" onClick={close}><Icon name="close"/></button>
    <h2>Add Funds</h2>
    <p>Enter the amount you want to add to your wallet. You'll be redirected to Paystack to complete payment.</p>
    {error && <div className="auth-error">{error}</div>}
    <input className="field" type="number" placeholder="Amount (₦)" value={amount} onChange={e=>setAmount(e.target.value)}/>
    <button className="primary-btn" disabled={busy} onClick={submit}>{busy?"Redirecting…":"Continue"}</button>
  </div></Overlay>;
}

function SupportModal({close}){
  const [message,setMessage]=useState("");
  return <Overlay close={close}><div className="modal">
    <button className="modal-close" onClick={close}><Icon name="close"/></button>
    <h2>Any Issues?</h2>
    <p>Email our support team and we'll get back to you.</p>
    <textarea className="field textarea" value={message} onChange={e=>setMessage(e.target.value)} placeholder="Describe your issue..."/>
    <a className="primary-btn" style={{display:"block",textAlign:"center",textDecoration:"none"}}
       href={`mailto:nanoinfluencer@gmail.com?subject=Support%20Request&body=${encodeURIComponent(message)}`}
       onClick={close}>Email Support</a>
  </div></Overlay>;
}

function ConfirmModal({close,lead,confirmLabel,onConfirm}){
  const [busy,setBusy]=useState(false);
  return <Overlay close={close}><div className="modal confirm">
    <button className="modal-close" onClick={close}><Icon name="close"/></button>
    <p className="confirm-lead">{lead}</p>
    <button className="primary-btn" disabled={busy} onClick={async()=>{setBusy(true);await onConfirm();}}>{busy?"Please wait…":confirmLabel}</button>
  </div></Overlay>;
}

function DeleteModal({close,onConfirm}){
  const [text,setText]=useState("");
  const [busy,setBusy]=useState(false);
  return <Overlay close={close}><div className="modal confirm">
    <button className="modal-close" onClick={close}><Icon name="close"/></button>
    <h2 className="danger-heading">Your Campaign Would be Deleted</h2>
    <p>Cancelling refunds any unspent budget back to your wallet.</p>
    <input className="field" placeholder='Type "Delete" to delete campaign' value={text} onChange={e=>setText(e.target.value)}/>
    <button className="danger-btn" disabled={text!=="Delete"||busy} onClick={async()=>{setBusy(true);await onConfirm();}}>OK</button>
  </div></Overlay>;
}

function DetailsModal({close,campaign}){
  const [audience,setAudience]=useState(null);
  useEffect(()=>{ api.previewAudience(campaign.id).then(setAudience).catch(()=>setAudience(null)); },[campaign.id]);
  return <Overlay close={close}><div className="modal confirm">
    <button className="modal-close" onClick={close}><Icon name="close"/></button>
    <h2>{campaign.title}</h2>
    <div className="details-grid">
      <div><small>Status</small><b>{campaign.status.replace("_"," ")}</b></div>
      <div><small>Platform</small><b>{campaign.platform}</b></div>
      <div><small>Action</small><b>{campaign.action_type}</b></div>
      <div><small>Slots</small><b>{campaign.slots_filled} / {campaign.slots_total}</b></div>
      <div><small>Budget</small><b>₦{(campaign.client_budget_kobo/100).toLocaleString()}</b></div>
      <div><small>Worker pay/action</small><b>₦{(campaign.worker_pay_per_action_kobo/100).toLocaleString()}</b></div>
    </div>
    {audience && <p style={{fontSize:12,color:"var(--muted)",marginTop:12}}>
      {audience.message || `Estimated reach: ${audience.found_quantity} of ${audience.desired_quantity} desired (${Math.round(audience.fulfillment_percentage||0)}%)`}
    </p>}
  </div></Overlay>;
}

// Unified campaign creation form used by all four entry points (named
// service, single-platform "other services" grid, custom task, and the
// "try for free" promo) — each just pre-fills / locks a different subset of
// fields to match what the entry point already implies.
function CampaignFormModal({modal,close,createCampaign,notify,navigate}){
  const isService = modal.type==="create";
  const isPlatform = modal.type==="platform";
  const isFreemium = modal.type==="freemium";

  const initialTni = isService ? modal.service.tni : isFreemium ? "try_for_free" : "custom";
  const initialAction = isService ? modal.service.action : "follow";
  const initialPlatform = isPlatform ? modal.platform[3] : "instagram";

  const [title,setTitle] = useState(isService ? modal.service.name+" Campaign" : "");
  const [platform,setPlatform] = useState(initialPlatform);
  const [actionType,setActionType] = useState(initialAction);
  const [commentSubtype,setCommentSubtype] = useState("");
  const [targetUrl,setTargetUrl] = useState("");
  const [description,setDescription] = useState("");
  const [budget,setBudget] = useState("");
  const [price,setPrice] = useState("");
  const [urgent,setUrgent] = useState(false);
  const [hasInstructions,setHasInstructions] = useState(false);
  const [instructions,setInstructions] = useState("");
  const [error,setError] = useState("");
  const [busy,setBusy] = useState(false);

  const platformLocked = isPlatform;
  const heading = isService ? modal.service.name : isPlatform ? `${modal.platform[0]} Task` : isFreemium ? "Try for Free" : "Create Custom Task";

  const submit = async (e) => {
    e.preventDefault();
    setError("");
    if(!title.trim()) return setError("Please give this campaign a title.");
    if(!targetUrl.trim()) return setError("Please add the profile/post link.");
    const budgetN = Number(budget), priceN = Number(price);
    if(!budgetN || budgetN <= 0) return setError("Enter a total budget greater than ₦0.");
    if(!priceN || priceN <= 0) return setError("Enter a price per action greater than ₦0.");
    setBusy(true);
    try {
      await createCampaign({
        title: title.trim(),
        platform,
        action_type: actionType,
        tni_service_type: initialTni,
        description: description || null,
        target_url: targetUrl.trim(),
        client_budget_ngn: budgetN,
        client_price_per_action_ngn: priceN,
        is_urgent: urgent,
        has_instructions: hasInstructions,
        instructions: hasInstructions ? instructions : null,
        comment_subtype: actionType==="comment" ? (commentSubtype || null) : null,
      });
      close();
      navigate("/app/campaigns");
    } catch(err) {
      setError(err instanceof ApiError ? err.message : "Could not create the campaign — please try again.");
      setBusy(false);
    }
  };

  return <Overlay close={close}><div className="modal">
    <button className="modal-close" onClick={close}><Icon name="close"/></button>
    <h2>{heading}</h2>
    {error && <div className="auth-error">{error}</div>}
    <form onSubmit={submit}>
      <label>Campaign title
        <input className="field" value={title} onChange={e=>setTitle(e.target.value)} placeholder="e.g. Instagram Growth — August"/>
      </label>
      {!platformLocked && <label>Platform
        <select className="field" value={platform} onChange={e=>setPlatform(e.target.value)}>
          {platforms.map(p=><option key={p[3]} value={p[3]}>{p[0]}</option>)}
        </select>
      </label>}
      {!isService && <label>Action
        <select className="field" value={actionType} onChange={e=>setActionType(e.target.value)}>
          {actionTypes.map(([v,l])=><option key={v} value={v}>{l}</option>)}
        </select>
      </label>}
      {actionType==="comment" && <label>Comment style
        <select className="field" value={commentSubtype} onChange={e=>setCommentSubtype(e.target.value)}>
          <option value="">Standard</option>
          <option value="personalized">Personalized (higher pay)</option>
          <option value="premium">Premium</option>
          <option value="interactive">Interactive</option>
        </select>
      </label>}
      <label>Profile / post link
        <input className="field" value={targetUrl} onChange={e=>setTargetUrl(e.target.value)} placeholder="https://..."/>
      </label>
      <label>Description <small className="auth-optional">(optional)</small>
        <textarea className="field textarea" style={{minHeight:70}} value={description} onChange={e=>setDescription(e.target.value)} placeholder="What should workers know about this campaign?"/>
      </label>
      <label>Total budget (₦)
        <input className="field" type="number" min="1" value={budget} onChange={e=>setBudget(e.target.value)} placeholder="e.g. 20000"/>
      </label>
      <label>Price per action (₦)
        <input className="field" type="number" min="1" value={price} onChange={e=>setPrice(e.target.value)} placeholder="e.g. 100"/>
      </label>
      <label className="checkbox-row"><input type="checkbox" checked={urgent} onChange={e=>setUrgent(e.target.checked)}/> Mark as urgent (faster delivery)</label>
      <label className="checkbox-row"><input type="checkbox" checked={hasInstructions} onChange={e=>setHasInstructions(e.target.checked)}/> Add special instructions</label>
      {hasInstructions && <textarea className="field textarea" style={{minHeight:70}} value={instructions} onChange={e=>setInstructions(e.target.value)} placeholder="Any specific steps workers must follow..."/>}
      <button className="primary-btn" disabled={busy} type="submit">{busy?"Creating…":"Create Campaign"}</button>
    </form>
  </div></Overlay>;
}

// ==================== LANDING PAGE ====================
function LandingPage(){
  const navigate=useNavigate();
  return <div className="landing">
    <header className="l-nav"><div className="l-logo"><span className="l-dot"/>The Nano Influencers</div><button className="l-menu"><Icon name="menu"/></button></header>

    <section className="l-hero">
      <div className="l-hero-bg" style={{backgroundImage:"url(https://picsum.photos/seed/nano-hero/1400/700)"}}/>
      <div className="l-hero-overlay"/>
      <div className="l-hero-content">
        <h1>Stop Going for Empty Clicks. Turn Everyday People into Your <span className="l-accent">Brand's Most Powerful Advertisers.</span></h1>
        <p>Advertise across Nigeria &amp; Ghana with Millions of nano-influencers who will share, engage, and recommend your brand, content or business in DMs, and Groups where people actually trust the message.</p>
        <div className="l-hero-actions">
          <button className="l-btn l-btn-white" onClick={()=>navigate("/register")}>Get Started</button>
          <button className="l-btn l-btn-navy" onClick={()=>navigate("/login")}>Login</button>
        </div>
      </div>
    </section>

    <div className="l-seehow-wrap"><button className="l-outline-pill">See How it Works</button></div>

    <div className="l-video-wrap">
      <div className="l-video">
        <div className="l-video-top"><span className="l-video-avatar"/><div><b>Intro video for editing free stock footage opening video ideas transitions effects download</b><small>Free Video Intros</small></div></div>
        <div className="l-video-body"><button className="l-play"><Icon name="play"/></button></div>
      </div>
    </div>

    <section className="l-section">
      <h2 className="l-h2">Our Services:</h2>
      <div className="l-cards">
        {landingServices.map(s=><article key={s.title} className="l-card">
          <small className="l-tag">({s.tag})</small>
          <div className="l-card-icon"><Icon name={s.icon} size={26}/></div>
          <h3 className="l-card-title">{s.title}</h3>
          <div className="l-card-body"><b>{s.heading}</b><ul>{s.bullets.map((b,i)=><li key={i}>{b}</li>)}</ul></div>
          <div className="l-dots"><span/><span className="on"/><span/></div>
        </article>)}
      </div>
    </section>

    <section className="l-section l-white">
      <div className="l-pill-heading"><h2 className="l-h2 l-blue">Testimonials</h2></div>
      <div className="l-testimonial">
        <img src="https://picsum.photos/seed/nano-testimonial/700/420" alt="Testimonial"/>
        <button className="l-play l-play-overlay"><Icon name="play"/></button>
      </div>
      <div className="l-dots l-dots-center"><span className="on"/><span/><span/></div>
    </section>

    <section className="l-section">
      <h2 className="l-h2">How it Works</h2>
      <p className="l-sub">Simple steps to get real people promoting your brand.</p>
      <small className="l-step-label">Step One</small>
      <div className="l-choose-service"><Icon name="check"/> Choose Your Service</div>
      <div className="l-phone-row">
        <div className="l-phone">
          <div className="l-phone-notch"/>
          <div className="l-phone-screen">
            <div className="l-phone-icons">{platforms.slice(0,8).map(([n,i,color])=><span key={n} style={{background:color}}>{i}</span>)}</div>
          </div>
        </div>
        <div className="l-phone-buttons">
          <span className="l-pbtn l-pbtn-red">Engaged Growth</span>
          <span className="l-pbtn l-pbtn-brown">Word of Mouth</span>
          <span className="l-pbtn l-pbtn-navy">Custom Tasks</span>
          <span className="l-pbtn l-pbtn-navy">Single Tasks</span>
        </div>
      </div>
      <a className="l-underline-link">See Videos on details of How it works</a>
    </section>

    <section className="l-section l-white">
      <h2 className="l-h2">Who Is It For</h2>
      <p className="l-sub l-orange">Nanoinfluencers is built for anyone who needs real visibility, trust, &amp; results.</p>
      <div className="l-whoband" style={{backgroundImage:"url(https://picsum.photos/seed/nano-whoisitfor/1400/500)"}}>
        <div className="l-whoband-overlay"/>
        <div className="l-whoband-text"><h3>Entrepreneurs, Businesses, &amp; SMEs</h3><p>Grow your business with affordable, real engagements and recommendations that drives sales, lead, visibility and awareness.</p></div>
      </div>
      <div className="l-dots l-dots-center"><span className="on"/><span/><span/><span/><span/></div>
    </section>

    <section className="l-section">
      <h2 className="l-h2">Special Offerings</h2>
      <div className="l-cards">
        {landingSpecial.map(s=><article key={s.title} className="l-card l-special-card">
          <div className="l-card-icon"><Icon name={s.icon} size={26}/></div>
          <h3 className="l-card-title">{s.title}</h3>
          <p className="l-special-intro"><b>{s.intro}</b></p>
          <ul>{s.bullets.map((b,i)=><li key={i}>{b}</li>)}</ul>
          <a className="l-underline-link l-center">{s.link}</a>
        </article>)}
      </div>
    </section>

    <FaqSection/>

    <section className="l-cta">
      <h2>Start today for free. No wasted time, only real Result that satisfies!</h2>
      <p>Over 120,000 tasks completed.. Trusted by entrepreneurs, Creators and SMEs across 10,000 Nigerian and Ghanian users.</p>
      <div className="l-cta-actions">
        <button className="l-btn l-btn-white" onClick={()=>navigate("/register")}>Sign-up Now</button>
        <button className="l-btn l-btn-white" onClick={()=>navigate("/login")}>Login Now</button>
      </div>
    </section>

    <footer className="l-footer">
      <div className="l-foot-brand"><span className="l-dot"/>NANOINFLUENCERS</div>
      <p>Turn everyday people into your brand's most powerful advertisers</p>
      <p className="l-foot-muted">Affordable, authentic, and effective — the smarter way to advertise.</p>
      <div className="l-social">
        <span><Icon name="facebook"/></span><span><Icon name="twitterx"/></span><span><Icon name="youtube"/></span><span><Icon name="tiktok"/></span><span><Icon name="instagram"/></span>
      </div>
      <div className="l-foot-cols">
        <div><h4>Quick Links</h4><a>Home</a><a>Our Services</a><a>How it Works</a><a>Testimonials</a><a>FAQs</a></div>
        <div><h4>Contact Info</h4><small>Email:</small><a href="mailto:info@nanoinfluencer.com">info@nanoinfluencer.com</a></div>
      </div>
      <div className="l-foot-bottom"><span>2025 Nanoinfluencers. All rights reserved</span><span className="l-foot-links"><a>Privacy Policy</a><a>Terms of Service</a></span></div>
    </footer>
  </div>
}

function FaqSection(){
  const [open,setOpen]=useState(null);
  return <section className="l-section l-white">
    <h2 className="l-h2">FAQs</h2>
    <div className="l-faq-list">
      {faqs.map((f,i)=><div className={"l-faq"+(open===i?" open":"")} key={i}>
        <button className="l-faq-q" onClick={()=>setOpen(open===i?null:i)}><span>{f.q}</span><span className="l-faq-chev"><Icon name="chevronDown"/></span></button>
        {open===i && <p className="l-faq-a">{f.a}</p>}
      </div>)}
    </div>
  </section>
}

createRoot(document.getElementById("root")).render(
  <BrowserRouter><AuthProvider><App/></AuthProvider></BrowserRouter>
);
