import React, {useMemo, useState} from "react";
import {createRoot} from "react-dom/client";
import {BrowserRouter, NavLink, Route, Routes, useNavigate, useLocation} from "react-router-dom";
import "./styles.css";

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

const platforms = [
  ["Facebook","f","#1877F2"],["YouTube","▶","#FF0000"],["X","X","#000000"],["WhatsApp","◉","#25D366"],
  ["Instagram","◎","#C1327A"],["Telegram","➤","#229ED9"],["TikTok","♪","#111111"],["LinkedIn","in","#0A66C2"],
  ["Audiomack","♫","#FFA200"],["Spotify","●","#1DB954"],["BoomPlay","B","#E4405F"],["YT Music","▶","#FF0033"]
];

const notifications = [
  ["Campaign Deleted","You just deleted your Twitter Like Campaign; you would be refunded 95% of the unspent balance."],
  ["Campaign Approved","Your IG Engaged Growth Campaign has been Approved by Admin."],
  ["Campaign Paused","You have paused your YouTube subscribe Campaign."],
  ["Campaign has been Completed","Congratulations, your Word of Mouth Campaign has been Completed."],
  ["Campaign has been Rejected","Unfortunately your FB report Campaign has been rejected due to violation of T&C."],
  ["Campaign Resumed","Your X follower Campaign has been resumed."],
  ["Campaign Modified/Edited","Your X follower Campaign has been resumed."]
];

const services = [
  {name:"Engaged Growth", purpose:"Build Long-Term Community", delivery:"Assigned followers in your niche who follow permanently & continually engage with your content while sharing on WhatsApp for more audience", platform:"Instagram, Facebook, X (Twitter), YouTube, LinkedIn, and TikTok", best:"Creators, Brands, Influencers, Businesses and anyone seeking constant visibility.", tone:"blue"},
  {name:"Word of Mouth", purpose:"Expand Reach", delivery:"Natural sharing and recommendation from people who genuinely discover your profile or campaign.", platform:"WhatsApp, Instagram, Facebook and other social channels", best:"Brands and creators seeking social proof and awareness.", tone:"red"}
];

// Campaign type shown as the two-tone header label above the bordered task box
// (matches Figma). Tasks created from "Other Services" (single platform reposts)
// carry no type label, matching the design.
const initialCampaigns = [
  {id:1,type:"Engaged Growth",name:"Engaged Growth",task:"Chisom's Page Link 1",status:"ongoing",created:"7/12/25 Time: 7:35pm",proof:"485",linksUsed:5,linksRemaining:10,showLinksFeature:true},
  {id:2,type:"Word of Mouth",name:"Word of Mouth",task:"My Music Promotion",status:"ongoing",created:"7/12/25 Time: 7:35pm",proof:"465"},
  {id:3,type:null,name:"Facebook Repost",task:"Facebook Repost",status:"ongoing",created:"7/12/25 Time: 7:35pm",proof:"465"},
  {id:4,type:null,name:"Twitter Repost",task:"Twitter Repost",status:"pending",created:"7/12/25 Time: 7:20pm",proof:""},
  {id:5,type:null,name:"Twitter Repost",task:"Twitter Repost",status:"pending",created:"7/12/25 Time: 7:05pm",proof:""}
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

function App({balance,setBalance,totalFunded,campaigns,setCampaigns}) {
  const [modal,setModal] = useState(null);
  const [toast,setToast] = useState("");
  const notify = (m) => { setToast(m); setTimeout(()=>setToast(""),2500); };
  const updateCampaign = (id,status) => {
    setCampaigns(c=>c.map(x=>x.id===id?{...x,status}:x).filter(x=>x.status!=="deleted"));
    setModal(null);
    notify(status==="paused"?"Campaign paused.":status==="deleted"?"Campaign deleted.":"Campaign updated.");
  };
  const addCampaign = (data) => {
    setCampaigns(c=>[{id:Date.now(),type:null,name:data.service,task:data.task||"New Campaign",status:"pending",created:"Just now",proof:""},...c]);
    setModal(null); notify("Campaign created successfully.");
  };
  return <>
    <Routes>
      <Route path="/" element={<LandingPage/>}/>
      <Route path="/app/*" element={
        <AppShell balance={balance} modal={modal} setModal={setModal}>
          <Routes>
            <Route path="" element={<Dashboard balance={balance} setModal={setModal} notify={notify} campaigns={campaigns}/>}/>
            <Route path="campaign" element={<CampaignPage setModal={setModal} addCampaign={addCampaign} campaigns={campaigns}/>}/>
            <Route path="campaigns" element={<ManageCampaigns campaigns={campaigns} setModal={setModal} updateCampaign={updateCampaign}/>}/>
            <Route path="campaigns/ongoing" element={<CampaignList title="Ongoing Campaigns" status="ongoing" campaigns={campaigns} setModal={setModal} updateCampaign={updateCampaign}/>}/>
            <Route path="campaigns/pending" element={<CampaignList title="Pending Campaigns" status="pending" campaigns={campaigns} setModal={setModal} updateCampaign={updateCampaign}/>}/>
            <Route path="notifications" element={<Notifications/>}/>
            <Route path="wallet" element={<Wallet balance={balance} totalFunded={totalFunded} setModal={setModal} setBalance={setBalance}/>}/>
            <Route path="gifts" element={<Gifts/>}/>
            <Route path="referral" element={<ReferralPage/>}/>
            <Route path="*" element={<Dashboard balance={balance} setModal={setModal} notify={notify} campaigns={campaigns}/>}/>
          </Routes>
        </AppShell>
      }/>
      <Route path="*" element={<LandingPage/>}/>
    </Routes>
    {toast && <div className="toast">{toast}</div>}
  </>
}

function AppShell({children,balance,modal,setModal}) {
  const location=useLocation();
  const isDashboard = location.pathname==="/app";
  return <div className="app">
    {isDashboard && <header className="topbar">
      <div className="brand"><span className="avatar">Z</span><div><small>Welcome</small><strong>Zeal</strong></div></div>
      <div className="top-actions"><HeaderBell/><button><Icon name="settings"/></button></div>
    </header>}
    <main>{children}</main>
    <BottomNav/>
    {modal && <Modal modal={modal} close={()=>setModal(null)}/>}
  </div>
}

function HeaderBell(){
  const navigate=useNavigate();
  return <button aria-label="Notifications" onClick={()=>navigate("/app/notifications")}><Icon name="bell"/></button>;
}

function BottomNav() {
  const items=[["/app","home","Dashboard"],["/app/wallet","wallet","Wallet"],["/app/campaign","campaign","Campaign"],["/app/gifts","gift","Gifts"],["/app/referral","megaphone","Referral"]];
  return <nav className="bottom-nav">{items.map(([to,icon,label])=><NavLink key={to} to={to} end={to==="/app"} className={({isActive})=>isActive?"active":""}><Icon name={icon} size={22}/><span>{label}</span></NavLink>)}</nav>
}
function Gifts(){return <div className="page simple-page"><PageHeader title="Gifts" back/><div className="content-wrap"><Promo title="Win Gifts" text="Get 1% cashback + a chance to win in our weekly raffle when you create a campaign & share us on WhatsApp!" button="See Gifts" tone="red"/></div></div>}
function ReferralPage(){return <div className="page simple-page"><PageHeader title="Referral" back/><div className="content-wrap"><Referral/></div></div>}

function Dashboard({balance,setModal,campaigns}) {
  const ongoing=campaigns.filter(c=>c.status==="ongoing").length;
  return <div className="page dashboard">
    <section className="hero-dark">
      <div className="balance"><span>Current Balance</span><b>₦{balance.toLocaleString()}</b></div>
      <div className="stat-grid">
        <StatCard title="Active Campaigns" value={ongoing} icon="campaign" action="See Campaign" to="/app/campaigns"/>
        <StatCard title="Spend Overview" value={"₦"+balance.toLocaleString()} action="View Wallet" to="/app/wallet"/>
      </div>
    </section>
    <div className="content-wrap">
      <section className="launch-card"><div><h2>Launch a Campaign</h2><p>Get real People to Promote your brand.<br/>They Engage with your Brand/Profile.</p><button className="linkish" onClick={()=>setModal({type:"campaign"})}>Manage Campaign</button></div><button className="white-cta" onClick={()=>setModal({type:"campaign"})}>Start Now</button></section>
      <section className="fund-card" onClick={()=>setModal({type:"fund"})}><div><Icon name="wallet"/><div><h2>Add Funds</h2><p>(Click on the Plus sign to fund your wallet)</p></div></div><button><Icon name="plus"/></button></section>
      <Referral/>
      <div className="promo-row"><Promo title="Win Gifts" text="Get 1% cashback + a chance to win in our weekly raffle when you create a campaign & share us on WhatsApp!" button="See Gifts" tone="red"/></div>
      <div className="promo-row"><Promo title="Try for Free" text="Try our services for free (Limited Order) – 2 free trial chances every week!" button="Try Freemium" tone="blue"/></div>
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
function Referral(){return <section className="referral"><small>Refer a Friend</small><p>Earn 2% on every campaign your referral starts & qualify for our bi-weekly Gadgets giveaway</p><div className="ref-input"><span>https://nano-influencers.com/kddk2l0s</span><button>✓</button></div></section>}
function Promo({title,text,button,tone}){return <section className={"promo "+tone}><div><h2>{title}</h2><p>{text}</p></div><button>{button}</button></section>}
function Analytics(){return <section className="analytics"><div className="section-head"><h3>Last Campaign Analytics</h3><a>Performance Metrics</a></div><div className="legend"><span><i/>Reach</span><span><i/>Impression</span><span><i/>Engagement</span></div><div className="chart"><svg viewBox="0 0 800 210" preserveAspectRatio="none"><path d="M20 120 L200 125 L390 122 L560 170 L780 160"/><path d="M20 90 L200 105 L390 96 L560 135 L780 45"/><path d="M20 165 L200 160 L390 150 L560 178 L780 168"/></svg></div><div className="periods"><span>○ Hourly</span><span>○ Daily</span><span>○ Weekly</span><span>◉ Monthly</span></div><a className="center-link">View all Campaign Analytics</a></section>}
function Activity(){return <section className="activity"><div className="section-head"><h3>Latest Activity</h3><a>Show all ›</a></div>{["Deposit Alert","New Campaign Created","Deposit Alert"].map((x,i)=><div className="activity-item" key={i}><span className="activity-dot">◌</span><div><b>{x}</b>{i===1&&<small>(Engaged Growth)</small>}</div><div className="activity-right"><b>₦0</b><small>Just Now</small></div></div>)}</section>}
function Support({onClick}){return <section className="support"><div className="section-head"><h3>Dispute and Support</h3></div><div className="support-row"><span><Icon name="support"/> Any Issues?</span><button onClick={onClick}>Contact Support</button></div></section>}

function CampaignPage({setModal,addCampaign,campaigns}) {
  const [platformsExpanded,setPlatformsExpanded]=useState(false);
  const navigate=useNavigate();
  return <div className="page campaign-page">
    <section className="campaign-hero"><div className="own-header"><h1>Campaign</h1><div className="own-header-actions"><button><Icon name="settings"/></button><button onClick={()=>navigate("/app/notifications")}><Icon name="bell"/></button></div></div><div className="service-label">Our Service:</div><div className="service-track">{services.map(s=><ServiceCard key={s.name} service={s} onStart={()=>setModal({type:"create",service:s.name})}/>)}</div><a className="video-link">Watch Video to Learn More</a></section>
    <section className="other-services"><SectionPill>Other Services</SectionPill><p>Great for single/one-time tasks</p><PlatformGrid expanded={platformsExpanded}/><a>Watch Video for more info about this Service</a>{!platformsExpanded && <button className="red-btn" onClick={()=>setPlatformsExpanded(true)}>See More</button>}</section>
    <section className="custom-task"><p>Great for Multiple task creation<br/>across any type of Platform.</p><button onClick={()=>setModal({type:"custom"})}>Create Custom Task</button></section>
    <ManagePreview campaigns={campaigns} setModal={setModal}/>
    <section className="special-services"><SectionPill>Special Services</SectionPill><div className="special-grid">{["Get a Google form","Get Website for your Business","Buy/Sell Crypto","Buy Business Plan/Ideas"].map(x=><button key={x}>{x}</button>)}</div></section>
  </div>
}
function SectionPill({children}){return <div className="pill">{children}</div>}
function ServiceCard({service,onStart}){return <article className={"service-card "+service.tone}><h2>{service.name}</h2><div className="service-row"><b>Purpose</b><span>{service.purpose}</span></div><div className="service-row"><b>Delivery</b><span>{service.delivery}</span></div><div className="service-row"><b>Platform</b><span>{service.platform}</span></div><div className="service-row"><b>Best For</b><span>{service.best}</span></div><button onClick={onStart}>Start Now</button></article>}
function PlatformGrid({expanded}){
  const shown = expanded?platforms:platforms.slice(0,8);
  return <div className="platform-grid">{shown.map(([n,i,color])=><button key={n} title={n}><strong style={{background:color}}>{i}</strong><small>{n}</small></button>)}</div>
}
function ManagePreview({campaigns,setModal}){return <section className="manage-preview"><h3>Manage Campaigns</h3>{campaigns.slice(0,2).map(c=><CampaignCard key={c.id} campaign={c} setModal={setModal}/>)}{!campaigns.length&&<p>No Campaign Available at the Moment</p>}<button className="outline-btn">Go to Campaign Management</button></section>}

function ManageCampaigns({campaigns,setModal,updateCampaign}) {
  const navigate=useNavigate();
  const ongoing=campaigns.filter(c=>c.status==="ongoing");
  const pending=campaigns.filter(c=>c.status==="pending");
  return <div className="page list-page manage-page">
    <div className="page-header"><h1>Manage Campaign</h1><a className="history-link" onClick={()=>navigate("/app/notifications")}>History</a></div>
    <div className="list-stack">
      <h3 className="section-title">Ongoing Campaigns</h3>
      {ongoing.slice(0,2).map(c=><CampaignCard key={c.id} campaign={c} setModal={setModal} updateCampaign={updateCampaign}/>)}
      {!ongoing.length&&<p className="muted-empty">No Ongoing Campaign at the Moment</p>}
      <button className="outline-btn" onClick={()=>navigate("/app/campaigns/ongoing")}>See All Ongoing Campaign</button>

      <h3 className="section-title">Pending Campaign</h3>
      {pending.slice(0,2).map(c=><CampaignCard key={c.id} campaign={c} setModal={setModal} updateCampaign={updateCampaign}/>)}
      {!pending.length&&<p className="muted-empty">No Pending Campaign at the Moment</p>}
      <button className="outline-btn" onClick={()=>navigate("/app/campaigns/pending")}>See All</button>

      <div className="section-head" style={{marginTop:20}}><h3 className="section-title" style={{margin:0}}>Campaign Notification</h3><a onClick={()=>navigate("/app/notifications")}>See All</a></div>
      {notifications.slice(2,4).map((n,i)=><article key={i} className="notification"><span className="bell-badge"><Icon name="bell"/></span><div><b>{n[0]}</b><p>{n[1]}</p></div><small>Just now</small></article>)}
    </div>
  </div>
}

function CampaignList({title,status,campaigns,setModal,updateCampaign}) {
  const list=campaigns.filter(c=>c.status===status);
  return <div className="page list-page"><PageHeader title={title} back backStyle="text"/><div className="list-stack">{list.map(c=><CampaignCard key={c.id} campaign={c} setModal={setModal} updateCampaign={updateCampaign}/>)}</div>{!list.length&&<Empty title={"No "+status+" campaigns"} button="Go Back" />}</div>
}

// Campaign card: matches the Figma structure — a plain header row (service type +
// created date) sits above a distinctly bordered box containing the task name and
// its action buttons; proof / link-submission content sits below that box.
function CampaignCard({campaign,setModal,updateCampaign}) {
  const showProof = campaign.status==="ongoing" || campaign.status==="paused";
  const nameParts = campaign.type ? campaign.type.split(" ") : null;
  return <article className="campaign-card">
    <div className="card-top">
      {nameParts ? <b>{nameParts.slice(0,-1).join(" ")} <span className="hl">{nameParts[nameParts.length-1]}</span></b> : <span/>}
      <small>Created: {campaign.created}</small>
    </div>
    <div className="card-box">
      <h4>{campaign.task}</h4>
      <div className="card-actions">
        {campaign.status==="pending" && <><button onClick={()=>setModal({type:"edit",campaign})}>Edit</button><button onClick={()=>setModal({type:"delete",campaign})}>Delete</button></>}
        {campaign.status==="ongoing" && <><button onClick={()=>setModal({type:"edit",campaign})}>Modify</button><button onClick={()=>setModal({type:"pause",campaign})}>Pause</button><button onClick={()=>setModal({type:"delete",campaign})}>Delete</button></>}
        {campaign.status==="paused" && <><button onClick={()=>setModal({type:"edit",campaign})}>Edit</button><button onClick={()=>setModal({type:"resume",campaign})}>Turn on</button><button onClick={()=>setModal({type:"delete",campaign})}>Delete</button></>}
      </div>
    </div>
    {showProof && <><p>Proof Submitted: {campaign.proof}</p><button className="proof-btn">See Proofs</button></>}
    {showProof && campaign.showLinksFeature && <>
      <p>Add links of New Post made on Profile<br/><b>({campaign.linksUsed} links used {campaign.linksRemaining} remaining)</b></p>
      <button className="orange-btn">Add Links to New Post</button>
    </>}
  </article>
}

function Notifications() {
  const navigate=useNavigate();
  const notes=notifications;
  if(!notes.length) return <div className="page notifications"><PageHeader title="Campaign Notifications" back gradient/><div className="empty"><h2>No Notifications Available</h2><button onClick={()=>navigate("/app")}>Go Back Home</button></div></div>;
  return <div className="page notifications"><PageHeader title="Campaign Notifications" back gradient/><div className="notification-list">{notes.map((n,i)=><NotificationRow key={i} n={n} i={i}/>)}</div></div>
}
function NotificationRow({n,i}){
  const [modal,setModal]=useState(null);
  return <><article className="notification"><span className="bell-badge"><Icon name="bell"/></span><div><b>{n[0]}</b><p>{n[1]}</p></div><small>Just now</small>{(i===1||i===3||i===4)&&<button onClick={()=>setModal({type:i===4?"reject":"proof",title:n[0]})}>{i===4?"See Why":"View Proof"}</button>}</article>{modal && <Modal modal={modal} close={()=>setModal(null)}/>}</>
}

function Wallet({balance,totalFunded,setModal,setBalance}) {
  const navigate=useNavigate();
  return <div className="page wallet-page">
    <div className="own-header wallet-own-header"><h1><Icon name="wallet" size={22}/> My Wallet</h1><div className="own-header-actions"><button onClick={()=>navigate("/app/notifications")}><Icon name="bell"/></button></div></div>
    <section className="wallet-head"><div><span>Available Balance</span><b>₦{balance.toLocaleString()}</b><small className="paid-today">Amount Paid Today: ₦0</small></div><div className="wallet-total"><span>Total Amount</span><b>₦{totalFunded.toLocaleString()}</b></div></section>
    <div className="wallet-body"><section className="fund-card large" onClick={()=>setModal({type:"fund"})}><div><h2>Add Funds</h2><p>(Click on the Plus sign to fund your wallet)</p></div><button><Icon name="plus"/></button></section><section className="recent"><h3>Recent Wallet Activity</h3><div className="wallet-activity"><span>●</span><div><small>Just now</small></div></div><button>View all Details</button></section><Support onClick={()=>setModal({type:"support"})}/></div>
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

function Modal({modal,close}) {
  const [amount,setAmount]=useState("");
  const [task,setTask]=useState("");
  const [service,setService]=useState(modal.service||"Engaged Growth");
  const [message,setMessage]=useState("");
  const navigate=useNavigate();
  const dispatch = (type,payload={}) => {
    window.dispatchEvent(new CustomEvent("nano-action",{detail:{type,...payload}}));
  };
  if(modal.type==="fund") return <Overlay close={close}><div className="modal"><button className="modal-close" onClick={close}><Icon name="close"/></button><h2>Add Funds</h2><p>Enter the amount you want to add to your wallet.</p><input className="field" type="number" placeholder="Amount (₦)" value={amount} onChange={e=>setAmount(e.target.value)}/><button className="primary-btn" onClick={()=>{dispatch("fund",{amount});close();}}>Continue</button></div></Overlay>;
  if(modal.type==="campaign"||modal.type==="create"||modal.type==="custom") return <Overlay close={close}><div className="modal"><button className="modal-close" onClick={close}><Icon name="close"/></button><h2>{modal.type==="campaign"?"Launch a Campaign":"Create Campaign"}</h2><label>Service<select className="field" value={service} onChange={e=>setService(e.target.value)}>{services.map(s=><option key={s.name}>{s.name}</option>)}<option>Social Promotion</option></select></label><label>Campaign / profile link<input className="field" value={task} onChange={e=>setTask(e.target.value)} placeholder="https://..."/></label><button className="primary-btn" onClick={()=>{dispatch("create",{service,task});close();navigate("/app/campaigns")}}>Create Campaign</button></div></Overlay>;
  if(modal.type==="support") return <Overlay close={close}><div className="modal"><button className="modal-close" onClick={close}><Icon name="close"/></button><h2>Any Issues?</h2><p>Send a message to our support team and we'll get back to you.</p><textarea className="field textarea" value={message} onChange={e=>setMessage(e.target.value)} placeholder="Describe your issue..."/><button className="primary-btn" onClick={close}>Contact Support</button></div></Overlay>;
  if(modal.type==="pause") return <Overlay close={close}><div className="modal confirm"><button className="modal-close" onClick={close}><Icon name="close"/></button><p className="confirm-lead">The Campaign would be on hold until you Turn it on again.</p><button className="primary-btn" onClick={()=>{dispatch("pause",{id:modal.campaign?.id});close();}}>Pause Now</button></div></Overlay>;
  if(modal.type==="resume") return <Overlay close={close}><div className="modal confirm"><button className="modal-close" onClick={close}><Icon name="close"/></button><p className="confirm-lead">Your campaign will resume and continue running.</p><button className="primary-btn" onClick={()=>{dispatch("resume",{id:modal.campaign?.id});close();}}>Turn On</button></div></Overlay>;
  if(modal.type==="delete") return <Overlay close={close}><div className="modal confirm"><button className="modal-close" onClick={close}><Icon name="close"/></button><h2 className="danger-heading">Your Campaign Would be Deleted</h2><input className="field" placeholder='Type "Delete" to delete campaign'/><button className="danger-btn" onClick={()=>{dispatch("delete",{id:modal.campaign?.id});close();}}>OK</button></div></Overlay>;
  if(modal.type==="edit") return <Overlay close={close}><div className="modal confirm"><button className="modal-close" onClick={close}><Icon name="close"/></button><h2>Modify Campaign</h2><p>Update your campaign settings and submit changes.</p><button className="primary-btn" onClick={()=>{dispatch("edit",{id:modal.campaign?.id});close();}}>Save Changes</button></div></Overlay>;
  if(modal.type==="reject") return <Overlay close={close}><div className="modal confirm"><button className="modal-close" onClick={close}><Icon name="close"/></button><h2 className="danger-heading">Violation of our Terms and Condition.</h2><p>Send an appeal<br/><a className="appeal-email" href="mailto:nanoinfluencer@gmail.com">nanoinfluencer@gmail.com</a></p><button className="danger-btn" onClick={close}>View Terms &amp; Condition</button></div></Overlay>;
  if(modal.type==="proof") return <Overlay close={close}><div className="modal confirm"><button className="modal-close" onClick={close}><Icon name="close"/></button><h2>{modal.title}</h2><p>Proof submitted for this campaign is under review.</p><button className="primary-btn" onClick={close}>Close</button></div></Overlay>;
  return null;
}
function Overlay({children,close}){return <div className="overlay" onMouseDown={e=>e.target===e.currentTarget&&close()}>{children}</div>}

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
          <button className="l-btn l-btn-white" onClick={()=>navigate("/app")}>Get Started</button>
          <button className="l-btn l-btn-navy" onClick={()=>navigate("/app")}>Login</button>
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
        <button className="l-btn l-btn-white" onClick={()=>navigate("/app")}>Sign-up Now</button>
        <button className="l-btn l-btn-white" onClick={()=>navigate("/app")}>Login Now</button>
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

function Root() {
  const [campaigns,setCampaigns]=useState(initialCampaigns);
  const [balance,setBalance]=useState(0);
  const [totalFunded,setTotalFunded]=useState(0);
  React.useEffect(()=>{
    const handler=e=>{
      const d=e.detail;
      if(d.type==="fund"){const n=Number(d.amount||0);if(n>0){setBalance(b=>b+n);setTotalFunded(t=>t+n);}}
      if(d.type==="create")setCampaigns(c=>[{id:Date.now(),type:null,name:d.service,task:d.task||"New Campaign",status:"pending",created:"Just now",proof:""},...c]);
      if(["pause","delete","resume"].includes(d.type))setCampaigns(c=>c.map(x=>x.id===d.id?{...x,status:d.type==="pause"?"paused":d.type==="resume"?"ongoing":"deleted"}:x).filter(x=>x.status!=="deleted"));
    };
    window.addEventListener("nano-action",handler);return()=>window.removeEventListener("nano-action",handler);
  },[]);
  return <App balance={balance} setBalance={setBalance} totalFunded={totalFunded} campaigns={campaigns} setCampaigns={setCampaigns}/>;
}
createRoot(document.getElementById("root")).render(<BrowserRouter><Root/></BrowserRouter>);
