import React, { useMemo, useRef, useState } from "react";
import "./v2-word-of-mouth.css";

const ASSET_BASE = "/assets/nano-v2-app/";
const assets = {
  arrowLeft: `${ASSET_BASE}custom-task-arrow-left.svg`,
  dropdown: `${ASSET_BASE}custom-task-dropdown.svg`,
  calendar: `${ASSET_BASE}custom-task-calendar.svg`,
  clock: `${ASSET_BASE}custom-task-clock.svg`,
  upload: `${ASSET_BASE}word-of-mouth-upload.svg`,
  result: `${ASSET_BASE}word-of-mouth-result.svg`,
  creative: `${ASSET_BASE}word-of-mouth-creative.png`,
  megaphone: `${ASSET_BASE}word-of-mouth-megaphone.svg`,
  radar: `${ASSET_BASE}word-of-mouth-radar-2.svg`,
  link: `${ASSET_BASE}word-of-mouth-link.svg`,
  schedule: `${ASSET_BASE}custom-task-calendar.svg`,
  budget: `${ASSET_BASE}word-of-mouth-budget.svg`,
  reach: `${ASSET_BASE}word-of-mouth-reach.svg`,
  impressions: `${ASSET_BASE}word-of-mouth-impressions.svg`,
  wallet: `${ASSET_BASE}word-of-mouth-wallet.svg`,
};

const purposes = [
  "Product/Service or Brand Awareness",
  "Form Submission (Survey Participation, grants etc.)",
  "Content Promotion (Music, Comedy, all types)",
  "Lead generation",
  "Sales/Conversions",
  "Sign-ups",
  "Event Promotion",
  "Referral",
];

const defaultDraft = {
  campaignName: "Summer Music Promo 2026",
  purpose: "Content Promotion (Music, Comedy, all types)",
  adLink: "https://instagram.com/p/SummerMusicPromo",
  adText: "New heat dropping this August 🔥 — Follow us for early access and exclusive content!",
  fileName: "promo_banner_2026.jpg",
  targeting: {
    demographics: { enabled: true, age: "18–34", gender: "Female & Male", marital: "" },
    location: { enabled: true, country: "Nigeria", state: "Lagos State", area: "Lekki, Surulere, Victoria Island" },
    language: { enabled: false, value: "English" },
    niche: { enabled: true, value: "Entertainment, Music & Fashion" },
    profession: { enabled: false, value: "" },
    religion: { enabled: false, value: "" },
    financial: { enabled: false, value: "" },
  },
  startDate: "2026-08-05",
  endDate: "2026-08-20",
  startTime: "09:00",
  endTime: "21:00",
  budget: "5000",
};

function go(path) {
  window.location.assign(path);
}

function FieldHeading({ title, subtitle }) {
  return <div className="v2-wom-field-heading"><h2>{title}</h2>{subtitle && <p>{subtitle}</p>}</div>;
}

function SelectShell({ value, onChange, children, ariaLabel }) {
  return (
    <label className="v2-wom-select">
      <select aria-label={ariaLabel} value={value} onChange={onChange}>{children}</select>
      <img src={assets.dropdown} alt="" />
    </label>
  );
}

function TargetPanel({ id, title, enabled, onToggle, children }) {
  return (
    <section className={`v2-wom-target${enabled ? " is-open" : ""}`}>
      <button className="v2-wom-target-head" type="button" onClick={onToggle} aria-expanded={enabled}>
        <span className={`v2-wom-target-check${enabled ? " is-checked" : ""}`}>{enabled ? "✓" : ""}</span>
        <span>{title}</span>
        <img src={assets.dropdown} alt="" />
      </button>
      {enabled && <div className="v2-wom-target-body" id={`target-${id}`}>{children}</div>}
    </section>
  );
}

function DemographicsFields({ value, onChange }) {
  return (
    <>
      <label className="v2-wom-subfield"><strong>Age</strong><input value={value.age} onChange={(e) => onChange({ ...value, age: e.target.value })} placeholder="e.g 18–35" /></label>
      <label className="v2-wom-subfield"><strong>Gender</strong><SelectShell value={value.gender} onChange={(e) => onChange({ ...value, gender: e.target.value })} ariaLabel="Gender"><option value="">Select...</option><option>Female & Male</option><option>Female</option><option>Male</option></SelectShell></label>
      <label className="v2-wom-subfield"><strong>Marital Status</strong><SelectShell value={value.marital} onChange={(e) => onChange({ ...value, marital: e.target.value })} ariaLabel="Marital status"><option value="">Select...</option><option>Any</option><option>Single</option><option>Married</option></SelectShell></label>
    </>
  );
}

function LocationFields({ value, onChange }) {
  return (
    <>
      <label className="v2-wom-subfield"><strong>Country</strong><SelectShell value={value.country} onChange={(e) => onChange({ ...value, country: e.target.value })} ariaLabel="Country"><option value="">Select...</option><option>Nigeria</option><option>Ghana</option></SelectShell></label>
      <label className="v2-wom-subfield"><strong>State</strong><SelectShell value={value.state} onChange={(e) => onChange({ ...value, state: e.target.value })} ariaLabel="State"><option value="">Select...</option><option>Lagos State</option><option>FCT Abuja</option><option>Rivers State</option><option>Greater Accra</option></SelectShell></label>
      <label className="v2-wom-subfield"><strong>Area/City</strong><input value={value.area} onChange={(e) => onChange({ ...value, area: e.target.value })} placeholder="e.g Lekki, Yaba" /></label>
    </>
  );
}

function SingleSelectTarget({ label, value, onChange, options = [] }) {
  return <label className="v2-wom-subfield"><strong>{label}</strong><SelectShell value={value} onChange={(e) => onChange(e.target.value)} ariaLabel={label}><option value="">Select...</option>{options.map((option) => <option key={option}>{option}</option>)}</SelectShell></label>;
}

function TextTarget({ label, value, onChange, placeholder }) {
  return <label className="v2-wom-subfield"><strong>{label}</strong><input value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder} /></label>;
}

export function V2WordOfMouth() {
  const fileRef = useRef(null);
  const [campaignName, setCampaignName] = useState("");
  const [purpose, setPurpose] = useState("");
  const [adLink, setAdLink] = useState("");
  const [adText, setAdText] = useState("");
  const [fileName, setFileName] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [startTime, setStartTime] = useState("");
  const [endTime, setEndTime] = useState("");
  const [budget, setBudget] = useState("5000");
  const [narrowed, setNarrowed] = useState(false);
  const [targeting, setTargeting] = useState({
    demographics: { enabled: false, age: "", gender: "", marital: "" },
    location: { enabled: false, country: "", state: "", area: "" },
    language: { enabled: false, value: "" },
    niche: { enabled: false, value: "" },
    profession: { enabled: false, value: "" },
    religion: { enabled: false, value: "" },
    financial: { enabled: false, value: "" },
  });

  const toggle = (key) => setTargeting((current) => ({ ...current, [key]: { ...current[key], enabled: !current[key].enabled } }));
  const setTarget = (key, next) => setTargeting((current) => ({ ...current, [key]: { ...current[key], ...next } }));

  const submit = (event) => {
    event.preventDefault();
    const draft = { campaignName, purpose, adLink, adText, fileName, targeting, startDate, endDate, startTime, endTime, budget };
    window.sessionStorage.setItem("v2WordOfMouthDraft", JSON.stringify(draft));
    const suffix = new URLSearchParams(window.location.search).get("payment") === "success" ? "?payment=success" : "";
    go(`/campaigns/word-of-mouth/preview${suffix}`);
  };

  return (
    <main className="ni-v2 v2-wom-page">
      <div className="v2-wom-shell">
        <header className="v2-wom-backbar"><a href="/campaigns"><img src={assets.arrowLeft} alt="" /><span>Go Back</span></a></header>
        <header className="v2-wom-title"><h1>Word of Mouth</h1><p>Setup Your Ads</p></header>

        <form className="v2-wom-form" onSubmit={submit}>
          <section className="v2-wom-panel">
            <FieldHeading title="Campaign Name" subtitle="Input the name you want to give your campaign below" />
            <input className="v2-wom-input" required value={campaignName} onChange={(e) => setCampaignName(e.target.value)} placeholder="type here" />
          </section>

          <section className="v2-wom-panel">
            <FieldHeading title="Campaign Purpose" subtitle="Choose the purpose of your campaign below" />
            <div className="v2-wom-purpose-list">{purposes.map((item) => <label className={`v2-wom-purpose${purpose === item ? " is-selected" : ""}`} key={item}><input type="radio" name="purpose" value={item} checked={purpose === item} onChange={() => setPurpose(item)} /><i /><span>{item}</span></label>)}</div>
          </section>

          <section className="v2-wom-panel v2-wom-creatives">
            <div className="v2-wom-creative-block"><FieldHeading title="Ad Creatives" subtitle={<>Input any Link to your ad below <em>(Optional)</em></>} /><input className="v2-wom-input" value={adLink} onChange={(e) => setAdLink(e.target.value)} placeholder="link here" /></div>
            <div className="v2-wom-creative-block"><FieldHeading title="Upload Image or Video for this ad" /><input ref={fileRef} type="file" accept="image/*,video/*" hidden onChange={(e) => setFileName(e.target.files?.[0]?.name || "")} /><button className="v2-wom-upload" type="button" onClick={() => fileRef.current?.click()}><img src={assets.upload} alt="" /><strong>{fileName || "Choose file"}</strong><span>{fileName ? "File selected" : "Size limit: 25mb"}</span></button></div>
            <div className="v2-wom-creative-block"><div className="v2-wom-text-head"><FieldHeading title={<>Add any text <em>(Optional)</em></>} /><small>Add any message you think would support your ad below (limited to 100 chars)</small></div><textarea maxLength={100} value={adText} onChange={(e) => setAdText(e.target.value)} placeholder="type here" /></div>
          </section>

          <TargetPanel id="demographics" title="Basic Demographics Targeting" enabled={targeting.demographics.enabled} onToggle={() => toggle("demographics")}><DemographicsFields value={targeting.demographics} onChange={(next) => setTarget("demographics", next)} /></TargetPanel>
          <TargetPanel id="location" title="Location Targeting" enabled={targeting.location.enabled} onToggle={() => toggle("location")}><LocationFields value={targeting.location} onChange={(next) => setTarget("location", next)} /></TargetPanel>
          <TargetPanel id="language" title="Language" enabled={targeting.language.enabled} onToggle={() => toggle("language")}><SingleSelectTarget label="Target Audience Language" value={targeting.language.value} onChange={(value) => setTarget("language", { value })} options={["English", "Pidgin English", "Hausa", "Igbo", "Yoruba"]} /></TargetPanel>
          <TargetPanel id="niche" title="Target Niche" enabled={targeting.niche.enabled} onToggle={() => toggle("niche")}><SingleSelectTarget label="Niche" value={targeting.niche.value} onChange={(value) => setTarget("niche", { value })} options={["Entertainment, Music & Fashion", "Business", "Technology", "Beauty & Lifestyle", "Food", "Sports"]} /></TargetPanel>
          <TargetPanel id="profession" title="Profession Based Targeting" enabled={targeting.profession.enabled} onToggle={() => toggle("profession")}><TextTarget label="Profession/Industry" value={targeting.profession.value} onChange={(value) => setTarget("profession", { value })} placeholder="e.g Healthcare, Finance, Tech" /></TargetPanel>
          <TargetPanel id="religion" title="Religion Based Targeting" enabled={targeting.religion.enabled} onToggle={() => toggle("religion")}><SingleSelectTarget label="Religion" value={targeting.religion.value} onChange={(value) => setTarget("religion", { value })} options={["Christianity", "Islam", "Other"]} /></TargetPanel>
          <TargetPanel id="financial" title="Financial Targeting" enabled={targeting.financial.enabled} onToggle={() => toggle("financial")}><SingleSelectTarget label="Income Level" value={targeting.financial.value} onChange={(value) => setTarget("financial", { value })} options={["Low", "Middle", "Upper Middle", "High"]} /></TargetPanel>

          <section className={`v2-wom-narrowed${narrowed ? " is-open" : ""}`}>
            <button type="button" onClick={() => setNarrowed((value) => !value)}><span className={`v2-wom-radio${narrowed ? " is-selected" : ""}`}><i /></span><strong>Narrowed Targeting</strong><img src={assets.dropdown} alt="" /></button>
            {narrowed && <div className="v2-wom-narrowed-copy"><p>Combine multiple targeting filters above to narrow the audience that receives your campaign.</p><span>Selected targeting groups: {Object.values(targeting).filter((item) => item.enabled).length}</span></div>}
          </section>

          <section className="v2-wom-panel">
            <FieldHeading title="Schedule" subtitle="Select the time and date you want your campaign to start" />
            <div className="v2-wom-schedule-grid">
              <label><strong>Start Date</strong><span className="v2-wom-icon-input"><input type="date" value={startDate} onChange={(e) => setStartDate(e.target.value)} /><img src={assets.calendar} alt="" /></span></label>
              <label><strong>End Date</strong><span className="v2-wom-icon-input"><input type="date" value={endDate} onChange={(e) => setEndDate(e.target.value)} /><img src={assets.calendar} alt="" /></span></label>
              <label><strong>Start time</strong><span className="v2-wom-icon-input"><input type="time" value={startTime} onChange={(e) => setStartTime(e.target.value)} /><img src={assets.clock} alt="" /></span></label>
              <label><strong>End time</strong><span className="v2-wom-icon-input"><input type="time" value={endTime} onChange={(e) => setEndTime(e.target.value)} /><img src={assets.clock} alt="" /></span></label>
            </div>
          </section>

          <section className="v2-wom-panel"><FieldHeading title="Budget" subtitle="Choose your budget for this campaign" /><SelectShell value={budget} onChange={(e) => setBudget(e.target.value)} ariaLabel="Campaign budget"><option value="5000">₦5000</option><option value="10000">₦10,000</option><option value="25000">₦25,000</option><option value="50000">₦50,000</option></SelectShell></section>

          <section className="v2-wom-result"><span className="v2-wom-result-icon"><img src={assets.result} alt="" /></span><div><h2>Result:</h2><p>Reach Estimation: 1,785 – 14,252 would see this Ad</p><p>Impression Estimation: 15,820 – 28,235</p></div><button type="submit">Proceed</button></section>
        </form>
      </div>
    </main>
  );
}

function readDraft() {
  try {
    const stored = JSON.parse(window.sessionStorage.getItem("v2WordOfMouthDraft") || "null");
    return stored ? { ...defaultDraft, ...stored, targeting: { ...defaultDraft.targeting, ...(stored.targeting || {}) } } : defaultDraft;
  } catch {
    return defaultDraft;
  }
}

function SummaryInfo({ icon, label, value, description }) {
  return <article className="v2-wom-summary-info"><span><img src={icon} alt="" /></span><div><small>{label}</small>{description && <em>{description}</em>}<strong>{value}</strong></div></article>;
}

export function V2WordOfMouthPreview() {
  const draft = useMemo(readDraft, []);
  const [accepted, setAccepted] = useState(() => window.innerWidth <= 700);
  const budget = Number(draft.budget || 5000);
  const total = budget + 500;
  const location = draft.targeting?.location || defaultDraft.targeting.location;
  const demographics = draft.targeting?.demographics || defaultDraft.targeting.demographics;
  const niche = draft.targeting?.niche || defaultDraft.targeting.niche;
  const schedule = draft.startDate && draft.endDate ? `${draft.startDate} · ${draft.startTime || "09:00"} → ${draft.endDate} · ${draft.endTime || "21:00"}` : "05 Aug 2026 · 09:00 → 20 Aug 2026 · 21:00";
  const purpose = draft.purpose || defaultDraft.purpose;
  const campaignName = draft.campaignName || defaultDraft.campaignName;

  const confirm = () => {
    const success = new URLSearchParams(window.location.search).get("payment") === "success";
    go(success ? "/campaigns/word-of-mouth/subscription-success" : "/campaigns/word-of-mouth/insufficient-balance");
  };

  return (
    <main className="ni-v2 v2-wom-preview-page">
      <div className="v2-wom-preview-shell">
        <header className="v2-wom-backbar"><button type="button" onClick={() => go("/campaigns/word-of-mouth")}><img src={assets.arrowLeft} alt="" /><span>Go Back</span></button></header>
        <h1 className="v2-wom-summary-title">Order Summary</h1>

        <section className="v2-wom-summary-panel v2-wom-ad-summary">
          <h2>Ad Overview</h2>
          <div className="v2-wom-summary-grid"><SummaryInfo icon={assets.megaphone} label="Campaign Name:" value={campaignName} /><SummaryInfo icon={assets.radar} label="Campaign Purpose" value={purpose} /></div>
          <div className="v2-wom-summary-section"><h2>Ad Creatives</h2><div className="v2-wom-creative-preview"><img src={assets.creative} alt="Campaign creative" /><span>📎 {draft.fileName || defaultDraft.fileName}</span></div><div className="v2-wom-link-preview"><img src={assets.link} alt="" /><span>{draft.adLink || defaultDraft.adLink}</span></div><div className="v2-wom-copy-preview"><strong>Ad Copy</strong><p>{draft.adText || defaultDraft.adText}</p></div></div>
          <div className="v2-wom-summary-section v2-wom-target-summary"><h2>Targeting</h2><p><i /> <span>LOCATION TARGETING:</span> {location.state || "Lagos State"} — {location.area || "Lekki, Surulere, Victoria Island"}</p><p><i /> <span>BASIC DEMOGRAPHICS TARGETING:</span> Age {demographics.age || "18–34"} · {demographics.gender || "Female & Male"}</p><p><i /> <span>TARGET NICHE:</span> {niche.value || "Entertainment, Music & Fashion"}</p></div>
          <div className="v2-wom-summary-section"><div className="v2-wom-summary-grid"><SummaryInfo icon={assets.schedule} label="Schedule" value={schedule} /><SummaryInfo icon={assets.budget} label="Budget" value={`₦${budget.toLocaleString("en-NG")}`} /></div></div>
        </section>

        <section className="v2-wom-summary-panel v2-wom-performance"><h2>Estimated Ads Performance</h2><div className="v2-wom-summary-grid"><SummaryInfo icon={assets.reach} label="Potential Reach" description="people would see this ad" value="1,785 – 14,252" /><SummaryInfo icon={assets.impressions} label="Impressions" description="times your ad is shown" value="15,820 – 28,235" /></div><div className="v2-wom-delivery"><h2>Delivery Mode</h2><p className="is-green"><i /> <strong>WhatsApp</strong> — DMs, Status, and Group Chats</p><p className="is-orange"><i /> <strong>Instagram</strong> — DMs, Story, Post, Comment Session and Group Chats</p><p className="is-blue"><i /> <strong>Facebook</strong> — DMs, Messenger, Story, Post, Comment Sessions &amp; Groups</p></div><div className="v2-wom-warning">⚠️ <span>If targeting is too narrow it might take longer to exhaust the ad cost. Expand your target audience a bit to get the best reach.</span></div></section>

        <section className="v2-wom-summary-panel v2-wom-payment"><h2>Payment Summary</h2><div className="v2-wom-total-mobile"><span>Total Cost</span><strong>₦{total.toLocaleString("en-NG")}</strong></div><div><span>Campaign</span><strong>{campaignName}</strong></div><div><span>Charged from</span><strong className="v2-wom-wallet"><i><img src={assets.wallet} alt="" /></i>Wallet</strong></div><div className="is-invoice"><span>Invoice ID</span><code>#Z4KF3VJG9A9Y</code></div></section>

        <section className="v2-wom-summary-panel v2-wom-terms"><h2>Terms &amp; Conditions</h2><label><input type="checkbox" checked={accepted} onChange={(e) => setAccepted(e.target.checked)} /><span>{accepted ? "✓" : ""}</span><p>I have read and agreed to the terms &amp; conditions of this service. Read terms and conditions here</p></label></section>
        <button className="v2-wom-confirm" type="button" onClick={confirm}>Confirm Payment</button>
      </div>
    </main>
  );
}
