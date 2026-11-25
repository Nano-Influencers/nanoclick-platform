import React, { useMemo, useRef, useState } from "react";
import "./v2-social-task-campaign.css";
import "./v2-whatsapp-task.css";

const ASSET_BASE = "/assets/nano-v2-app/";
const assets = {
  arrowLeft: `${ASSET_BASE}custom-task-arrow-left.svg`,
  calendar: `${ASSET_BASE}custom-task-calendar.svg`,
  clock: `${ASSET_BASE}custom-task-clock.svg`,
  joinChannel: `${ASSET_BASE}task-chat-profile-add.svg`,
  joinGroup: `${ASSET_BASE}task-chat-people.svg`,
  share: `${ASSET_BASE}task-chat-send.svg`,
  community: `${ASSET_BASE}task-chat-global-search.svg`,
  call: `${ASSET_BASE}task-chat-call-add.svg`,
  follow: `${ASSET_BASE}task-chat-heart-add.svg`,
  save: `${ASSET_BASE}task-chat-archive-tick.svg`,
  report: `${ASSET_BASE}task-chat-flag.svg`,
  telegramBot: `${ASSET_BASE}task-telegram-emoji-happy.svg`,
  telegramGroup: `${ASSET_BASE}task-chat-people.svg`,
  telegramShare: `${ASSET_BASE}task-chat-send.svg`,
  telegramCommunity: `${ASSET_BASE}task-chat-global-search.svg`,
  telegramCall: `${ASSET_BASE}task-chat-call-add.svg`,
  telegramSubscribe: `${ASSET_BASE}task-chat-heart-add.svg`,
  telegramSave: `${ASSET_BASE}task-chat-archive-tick.svg`,
  telegramReport: `${ASSET_BASE}task-chat-flag.svg`,
  copy: `${ASSET_BASE}custom-task-copy.svg`,
  download: `${ASSET_BASE}custom-task-download.svg`,
  upload: `${ASSET_BASE}custom-task-upload.svg`,
};

const whatsappTasks = [
  { id: "join-a-channel", label: "Join a Channel", icon: assets.joinChannel, tone: "blue", kind: "simple", cost: 10 },
  { id: "join-group", label: "Join Group", icon: assets.joinGroup, tone: "green", kind: "simple", cost: 10 },
  { id: "share-on-whatsapp", label: "Share on WhatsApp", icon: assets.share, tone: "green", kind: "share" },
  { id: "community-for-you", label: "Community for You", icon: assets.community, tone: "yellow", kind: "community" },
  { id: "join-whatsapp-call", label: "Join WhatsApp Call", icon: assets.call, tone: "green", kind: "call" },
  { id: "follow-my-channel", label: "Follow my Channel", icon: assets.follow, tone: "red", kind: "follow", cost: 10 },
  { id: "save-my-contact", label: "Save my Contact", icon: assets.save, tone: "green", kind: "simple", cost: 10 },
  { id: "report-account", label: "Report Account", icon: assets.report, tone: "red", kind: "report", cost: 30 },
];

const telegramTasks = [
  { id: "start-a-tg-bot", label: "Start a TG Bot", icon: assets.telegramBot, tone: "blue", kind: "bot", cost: 100 },
  { id: "join-group", label: "Join Group", icon: assets.telegramGroup, tone: "green", kind: "simple", cost: 10 },
  { id: "share-on-telegram", label: "Share on Telegram", icon: assets.telegramShare, tone: "green", kind: "share" },
  { id: "community-for-you", label: "Community for You", icon: assets.telegramCommunity, tone: "yellow", kind: "community" },
  { id: "join-telegram-call", label: "Join Telegram Call", icon: assets.telegramCall, tone: "green", kind: "call" },
  { id: "subscribe-to-my-channel", label: "Subscribe to my Channel", icon: assets.telegramSubscribe, tone: "red", kind: "follow", cost: 10 },
  { id: "save-my-contact", label: "Save my Contact", icon: assets.telegramSave, tone: "green", kind: "simple", cost: 5 },
  { id: "report-account", label: "Report Account", icon: assets.telegramReport, tone: "red", kind: "report", cost: 30 },
];

const platformConfigs = {
  whatsapp: {
    slug: "whatsapp",
    title: "I need WhatsApp:",
    linkPlaceholder: "https://whatsapp.com/...",
    tasks: whatsappTasks,
    shareDestinations: [["Friends DM", 10], ["Status", 20], ["Group Chat", 30], ["Brodcast", 75], ["Channel", 100], ["Community", 200]],
  },
  telegram: {
    slug: "telegram",
    title: "I need Telegram:",
    linkPlaceholder: "https://telegram.com/...",
    tasks: telegramTasks,
    shareDestinations: [["Friends DM", 10], ["Status", 20], ["Group Chat", 30]],
  },
};
const callDurations = [["15mins Call", 100], ["30mins Call", 200], ["45mins Call", 300], ["60mins Call", 400], ["90mins Call", 600]];
const money = (value) => `₦${Number(value || 0).toLocaleString("en-NG")}`;

function FieldHeader({ title, help }) {
  return <div className="v2-stc-field-head"><label>{title}</label>{help ? <p className="v2-stc-help">{help}</p> : null}</div>;
}

function Choice({ checked, onChange, label, cost }) {
  return (
    <label className="v2-stc-check">
      <input type="checkbox" checked={checked} onChange={onChange} />
      <span className="v2-stc-box">{checked ? "✓" : ""}</span>
      <span>{label}</span>
      {typeof cost === "number" ? <small>(Cost {money(cost)})</small> : null}
    </label>
  );
}

function RadioChoice({ active, onClick, children }) {
  return <button className={`v2-stc-choice-btn${active ? " is-active" : ""}`} type="button" onClick={onClick}>{children}</button>;
}

function Consent({ checked, onChange, children }) {
  return <label className="v2-stc-consent"><input type="checkbox" checked={checked} onChange={onChange} /><span className="v2-stc-box">{checked ? "✓" : ""}</span><span>{children}</span></label>;
}

function UploadBox({ fileName, onFile, accept = "image/*" }) {
  const inputRef = useRef(null);
  return (
    <>
      <input ref={inputRef} type="file" hidden accept={accept} onChange={(event) => onFile(event.target.files?.[0]?.name || "")} />
      <button className="v2-stc-upload" type="button" onClick={() => inputRef.current?.click()}>
        <img src={assets.upload} alt="" />
        <strong>{fileName || "Choose file"}</strong>
        <span>Size limit: 25mb</span>
      </button>
    </>
  );
}

function TaskGrid({ tasks, selected, onSelect }) {
  return (
    <section className="v2-stc-task-panel">
      <div className="v2-stc-task-grid">
        {tasks.map((item) => (
          <button key={item.id} className={`v2-stc-task-card tone-${item.tone}${selected.id === item.id ? " is-active" : ""}`} type="button" onClick={() => onSelect(item)}>
            <span className={`v2-stc-task-icon tone-${item.tone}`}><img src={item.icon} alt="" /></span>
            <span>{item.label}</span>
          </button>
        ))}
      </div>
      <button className="v2-stc-how" type="button">Click this text to know how this service works</button>
    </section>
  );
}

function ShareTaskPanel({ destinationOptions, destinations, setDestinations, formats, setFormats, videoCount, setVideoCount, imageCount, setImageCount, videoFile, setVideoFile, imageFile, setImageFile, videoLink, setVideoLink, imageLink, setImageLink, videoText, setVideoText, imageText, setImageText }) {
  const toggleDestination = (label) => setDestinations((current) => current.includes(label) ? current.filter((value) => value !== label) : [...current, label]);
  const toggleFormat = (label) => setFormats((current) => current.includes(label) ? current.filter((value) => value !== label) : [...current, label]);
  return (
    <>
      <section className="v2-stc-panel">
        <h2 className="v2-stc-subtitle">Where do you want us to Share your Content to?</h2>
        <div className="v2-wa-check-grid">{destinationOptions.map(([label, cost]) => <Choice key={label} label={label} cost={cost} checked={destinations.includes(label)} onChange={() => toggleDestination(label)} />)}</div>
      </section>
      <section className="v2-stc-panel">
        <div className="v2-wa-label-line"><h2>Format</h2><p>You can select one or more</p></div>
        <div className="v2-wa-format-options"><Choice label="Video" checked={formats.includes("Video")} onChange={() => toggleFormat("Video")} /><Choice label="Images" checked={formats.includes("Images")} onChange={() => toggleFormat("Images")} /></div>
        {formats.includes("Video") ? <div className="v2-wa-media-block"><p className="v2-wa-note">Videos should not exceed more than 3mins in a situation where your video exceeds 3mins you can select 2 video upload or more by breaking the video into 2 or more parts with each of the parts not exceeding 3mins.</p><div className="v2-wa-media-grid"><div className="v2-wa-media-copy"><FieldHeader title="Select the No. Videos" /><input className="v2-stc-input" type="number" min="1" value={videoCount} onChange={(e) => setVideoCount(e.target.value)} placeholder="1" /><UploadBox fileName={videoFile} onFile={setVideoFile} accept="video/*" /></div><div className="v2-wa-media-copy"><FieldHeader title="Link (Optional)" /><input className="v2-stc-input" value={videoLink} onChange={(e) => setVideoLink(e.target.value)} placeholder="type here" /><FieldHeader title="Text  (Optional)" /><textarea className="v2-stc-textarea" value={videoText} onChange={(e) => setVideoText(e.target.value)} placeholder="type here" /></div></div></div> : null}
        {formats.includes("Images") ? <div className="v2-wa-media-block"><p className="v2-wa-note">Select the number of images you want to share. The image cannot exceed 20mb</p><div className="v2-wa-media-grid"><div className="v2-wa-media-copy"><FieldHeader title="Select the No. Images" /><input className="v2-stc-input" type="number" min="1" value={imageCount} onChange={(e) => setImageCount(e.target.value)} placeholder="1" /><UploadBox fileName={imageFile} onFile={setImageFile} /></div><div className="v2-wa-media-copy"><FieldHeader title="Link (Optional)" /><input className="v2-stc-input" value={imageLink} onChange={(e) => setImageLink(e.target.value)} placeholder="type here" /><FieldHeader title="Text  (Optional)" /><textarea className="v2-stc-textarea" value={imageText} onChange={(e) => setImageText(e.target.value)} placeholder="type here" /></div></div></div> : null}
      </section>
    </>
  );
}

function CallTaskPanel({ callType, setCallType, duration, setDuration }) {
  return (
    <>
      <section className="v2-stc-panel"><h2 className="v2-stc-subtitle">I want:</h2><div className="v2-wa-radio-grid"><RadioChoice active={callType === "Participants on my Call (No Sharing)"} onClick={() => setCallType("Participants on my Call (No Sharing)")}>Participants on my Call (No Sharing)</RadioChoice><RadioChoice active={callType === "Participants on my Call (Share to Friends/Contacts)"} onClick={() => setCallType("Participants on my Call (Share to Friends/Contacts)")}>Participants on my Call (Share to Friends/Contacts)</RadioChoice></div></section>
      {callType ? <section className="v2-stc-panel"><h2 className="v2-stc-subtitle">Duration</h2><div className="v2-wa-duration-list">{callDurations.map(([label, cost]) => <Choice key={label} label={label} cost={cost} checked={duration === label} onChange={() => setDuration(duration === label ? "" : label)} />)}</div></section> : null}
    </>
  );
}

function FollowTaskPanel({ followKinds, setFollowKinds }) {
  const toggle = (label) => setFollowKinds((current) => current.includes(label) ? current.filter((value) => value !== label) : [...current, label]);
  return <section className="v2-stc-panel"><h2 className="v2-stc-subtitle">I want:</h2><div className="v2-wa-follow-options"><Choice label="Female Followers" cost={10} checked={followKinds.includes("Female Followers")} onChange={() => toggle("Female Followers")} /><Choice label="Male Followers" cost={10} checked={followKinds.includes("Male Followers")} onChange={() => toggle("Male Followers")} /></div></section>;
}


function BotTaskPanel({ token, setToken, username, setUsername, userInstruction, setUserInstruction, banner, setBanner }) {
  return (
    <section className="v2-stc-panel v2-wa-report-copy">
      <div className="v2-wa-service-title"><h2>Telegram Bot Configuration</h2><p>(Cost ₦100)</p></div>
      <div className="v2-stc-field"><FieldHeader title="Bot Token" /><input className="v2-stc-input" value={token} onChange={(e) => setToken(e.target.value)} placeholder="type here" /></div>
      <div className="v2-stc-field"><FieldHeader title="Bot Username" /><input className="v2-stc-input" value={username} onChange={(e) => setUsername(e.target.value)} placeholder="type here" /></div>
      <div className="v2-stc-field"><FieldHeader title="Instruction for users" /><textarea className="v2-stc-textarea" value={userInstruction} onChange={(e) => setUserInstruction(e.target.value)} placeholder="Drop anything you like the nano-inflencer to know about this task" /></div>
      <div className="v2-stc-field"><FieldHeader title="Bot Image / Banner" /><UploadBox fileName={banner} onFile={setBanner} /></div>
    </section>
  );
}

function ReportTaskPanel({ values, setValue, evidence, setEvidence }) {
  return (
    <section className="v2-stc-panel v2-wa-report-copy">
      <div className="v2-stc-field"><FieldHeader title="I want to report a:" /><input className="v2-stc-input" value={values.type} onChange={(e) => setValue("type", e.target.value)} placeholder="Group (Cost: ₦30)" /></div>
      <div className="v2-stc-field"><FieldHeader title="Why are you reporting this comment?" help="Choose the option that best describes the issue" /><input className="v2-stc-input" value={values.reason} onChange={(e) => setValue("reason", e.target.value)} placeholder="Select option" /></div>
      <div className="v2-stc-field"><FieldHeader title="Please write a short letter to our admin on why you are reporting this group" help="Provide as much detail as possible to help our admin review the case." /><textarea className="v2-stc-textarea" value={values.letter} onChange={(e) => setValue("letter", e.target.value)} placeholder="type here" /></div>
      <div className="v2-stc-field"><FieldHeader title="Upload Evidence to back your claims on why this group deserves to be reported" /><UploadBox fileName={evidence} onFile={setEvidence} /></div>
      <div className="v2-stc-field"><FieldHeader title="Commenter’s Handle" /><input className="v2-stc-input" value={values.handle} onChange={(e) => setValue("handle", e.target.value)} placeholder="type here" /></div>
      <div className="v2-stc-field"><FieldHeader title="Drop the comment you want us to report" /><textarea className="v2-stc-textarea" value={values.comment} onChange={(e) => setValue("comment", e.target.value)} placeholder="type here" /></div>
    </section>
  );
}

export default function V2WhatsAppTaskCampaign() {
  const params = new URLSearchParams(window.location.search);
  const slug = window.location.pathname.split("/").filter(Boolean).pop()?.toLowerCase() === "telegram" ? "telegram" : "whatsapp";
  const platform = platformConfigs[slug];
  const tasks = platform.tasks;
  const requested = params.get("task") || tasks[0].id;
  const initialTask = tasks.find((item) => item.id === requested) || tasks[0];
  const [selectedTask, setSelectedTask] = useState(initialTask);
  const [pageAbout, setPageAbout] = useState("");
  const [link, setLink] = useState("");
  const [quantity, setQuantity] = useState("");
  const [instruction, setInstruction] = useState("");
  const [instructionFile, setInstructionFile] = useState("");
  const [country, setCountry] = useState("");
  const [targetState, setTargetState] = useState("All States");
  const [delivery, setDelivery] = useState("Default Time");
  const [startDate, setStartDate] = useState("Today");
  const [startTime, setStartTime] = useState("19:00");
  const [privacyAccepted, setPrivacyAccepted] = useState(false);
  const [termsAccepted, setTermsAccepted] = useState(false);
  const [cashbackEvidence, setCashbackEvidence] = useState("");
  const [copied, setCopied] = useState(false);
  const [shareDest, setShareDest] = useState([]);
  const [formats, setFormats] = useState([]);
  const [videoCount, setVideoCount] = useState("");
  const [imageCount, setImageCount] = useState("");
  const [videoFile, setVideoFile] = useState("");
  const [imageFile, setImageFile] = useState("");
  const [videoLink, setVideoLink] = useState("");
  const [imageLink, setImageLink] = useState("");
  const [videoText, setVideoText] = useState("");
  const [imageText, setImageText] = useState("");
  const [callType, setCallType] = useState("");
  const [duration, setDuration] = useState("");
  const [followKinds, setFollowKinds] = useState([]);
  const [reportValues, setReportValues] = useState({ type: "", reason: "", letter: "", handle: "", comment: "" });
  const [reportEvidence, setReportEvidence] = useState("");
  const [botToken, setBotToken] = useState("");
  const [botUsername, setBotUsername] = useState("");
  const [botInstruction, setBotInstruction] = useState("");
  const [botBanner, setBotBanner] = useState("");

  const setReportValue = (key, value) => setReportValues((current) => ({ ...current, [key]: value }));
  const durationCost = callDurations.find(([label]) => label === duration)?.[1] || 0;
  const selectedShareCost = platform.shareDestinations.filter(([label]) => shareDest.includes(label)).reduce((sum, [, cost]) => sum + cost, 0);
  const unitCost = selectedTask.kind === "share" ? selectedShareCost : selectedTask.kind === "call" ? durationCost : selectedTask.kind === "follow" ? (followKinds.length ? 10 : 0) : selectedTask.cost || 0;
  const totalCost = useMemo(() => Number(quantity || 0) * unitCost, [quantity, unitCost]);

  const chooseTask = (task) => {
    setSelectedTask(task);
    const next = new URL(window.location.href);
    next.searchParams.set("task", task.id);
    window.history.replaceState({}, "", `${next.pathname}${next.search}`);
  };

  const copyCashback = async () => {
    try {
      await navigator.clipboard.writeText("https://nanoinfluencer.ng/ref/adaeze");
      setCopied(true);
      window.setTimeout(() => setCopied(false), 1200);
    } catch { setCopied(false); }
  };

  const submit = (event) => {
    event.preventDefault();
    sessionStorage.setItem(`v2${platform.slug === "telegram" ? "Telegram" : "WhatsApp"}TaskCampaignDraft`, JSON.stringify({ platform: platform.slug, selectedTask: selectedTask.id, pageAbout, link, quantity, instruction, country, targetState, delivery, startDate, startTime, shareDest, formats, videoCount, imageCount, callType, duration, followKinds, reportValues, botToken, botUsername, botInstruction, totalCost, privacyAccepted, termsAccepted }));
    window.location.assign(params.get("payment") === "success" ? "/campaigns/subscription-success" : "/campaigns/insufficient-balance");
  };

  const showLink = selectedTask.kind !== "share" && selectedTask.kind !== "community" && selectedTask.kind !== "bot";
  const showInstructions = selectedTask.kind !== "report" && selectedTask.kind !== "community";

  return (
    <main className="v2-stc-page v2-wa-page">
      <div className="v2-stc-shell">
        <header className="v2-stc-backbar"><a href="/campaigns"><img src={assets.arrowLeft} alt="" width="24" height="24" /><span>Go Back</span></a></header>
        <header className="v2-stc-heading"><h1>{platform.title}</h1></header>
        <TaskGrid tasks={tasks} selected={selectedTask} onSelect={chooseTask} />

        <form className="v2-stc-fields" onSubmit={submit}>
          {selectedTask.kind === "share" ? <ShareTaskPanel destinationOptions={platform.shareDestinations} destinations={shareDest} setDestinations={setShareDest} formats={formats} setFormats={setFormats} videoCount={videoCount} setVideoCount={setVideoCount} imageCount={imageCount} setImageCount={setImageCount} videoFile={videoFile} setVideoFile={setVideoFile} imageFile={imageFile} setImageFile={setImageFile} videoLink={videoLink} setVideoLink={setVideoLink} imageLink={imageLink} setImageLink={setImageLink} videoText={videoText} setVideoText={setVideoText} imageText={imageText} setImageText={setImageText} /> : null}
          {selectedTask.kind === "call" ? <CallTaskPanel callType={callType} setCallType={setCallType} duration={duration} setDuration={setDuration} /> : null}
          {selectedTask.kind === "follow" ? <FollowTaskPanel followKinds={followKinds} setFollowKinds={setFollowKinds} /> : null}
          {selectedTask.kind === "report" ? <ReportTaskPanel values={reportValues} setValue={setReportValue} evidence={reportEvidence} setEvidence={setReportEvidence} /> : null}
          {selectedTask.kind === "bot" ? <BotTaskPanel token={botToken} setToken={setBotToken} username={botUsername} setUsername={setBotUsername} userInstruction={botInstruction} setUserInstruction={setBotInstruction} banner={botBanner} setBanner={setBotBanner} /> : null}

          {selectedTask.kind !== "community" ? <section className="v2-stc-panel v2-wa-common-panel">
            {selectedTask.kind === "simple" ? <div className="v2-wa-service-title"><h2>{selectedTask.label}</h2><p>(Cost {money(selectedTask.cost)})</p></div> : null}
            <div className="v2-stc-field"><FieldHeader title="What is your page/profile about" /><input className="v2-stc-input" value={pageAbout} onChange={(e) => setPageAbout(e.target.value)} placeholder="type here" maxLength={50} /><p className="v2-stc-meta">{pageAbout.length}/50</p></div>
            {showLink ? <div className="v2-stc-field"><FieldHeader title="Link" help="Ensure that you drop the correct link here." /><p className="v2-stc-inline-note">Drop the link to the post here.</p><input className="v2-stc-input" value={link} onChange={(e) => setLink(e.target.value)} placeholder={platform.linkPlaceholder} /></div> : null}
            <div className="v2-stc-field"><FieldHeader title="Total Quantity" help="Total quantity based on the addition of all individual quantities." /><input className="v2-stc-input" type="number" min="0" value={quantity} onChange={(e) => setQuantity(e.target.value)} placeholder="0" /></div>
            <div className="v2-stc-field"><FieldHeader title="Cost" help="Total cost based on the addition of all individual costs." /><input className="v2-stc-input" value={money(totalCost)} readOnly /></div>
          </section> : null}

          {showInstructions ? <section className="v2-stc-panel"><div className="v2-stc-field"><FieldHeader title="Any Instruction for the Nano-Influencer (Optional)" help="Drop anything you like the nano-inflencer to know about this task" /><textarea className="v2-stc-textarea" value={instruction} onChange={(e) => setInstruction(e.target.value)} placeholder="type here" /></div><div className="v2-stc-field"><FieldHeader title="Upload any image sample for the instruction." /><UploadBox fileName={instructionFile} onFile={setInstructionFile} /></div></section> : null}

          {selectedTask.kind !== "community" ? <>
            <section className="v2-stc-panel"><div className="v2-stc-field"><FieldHeader title="Country of Target" help="Select the country or countries you want to get this service from." /><select className="v2-stc-select" value={country} onChange={(e) => setCountry(e.target.value)}><option value="">Select Country</option><option>Nigeria</option></select></div><div className="v2-stc-field"><FieldHeader title="State of Target" help="Select the State you want to get the engagement from. Note that this affects and reduces the maximum number of nano-influencers that would perform the task if you select fewer states." /><select className="v2-stc-select" value={targetState} onChange={(e) => setTargetState(e.target.value)}><option>All States</option><option>Lagos</option><option>FCT Abuja</option><option>Rivers</option><option>Ogun</option><option>Oyo</option></select></div></section>
            <section className="v2-stc-panel"><div className="v2-stc-field"><FieldHeader title="How Fast do you want the job to be delivered. I want the job delivered in:" help={'Only apply if your order is time bound. Just Select "Default Time" if your campaign is not time bound.'} /><select className="v2-stc-select" value={delivery} onChange={(e) => setDelivery(e.target.value)}><option>Default Time</option><option>24 Hours</option><option>48 Hours</option><option>3 Days</option><option>7 Days</option></select></div><div className="v2-stc-two"><div className="v2-stc-field"><FieldHeader title="Start Date" /><div className="v2-wa-icon-input"><input className="v2-stc-input" value={startDate} onChange={(e) => setStartDate(e.target.value)} /><img src={assets.calendar} alt="" /></div></div><div className="v2-stc-field"><FieldHeader title="Start time" /><div className="v2-wa-icon-input"><input className="v2-stc-input" value={startTime} onChange={(e) => setStartTime(e.target.value)} /><img src={assets.clock} alt="" /></div></div></div><p className="v2-stc-total-line">Total Cost (Cost × Delivery Speed) × 1 <strong>= {money(totalCost)}</strong></p></section>
            <section className="v2-stc-panel"><div className="v2-stc-cashback"><div className="v2-stc-section-head"><div><h2>(Optional)</h2><p>Share the link and image below on your whatsapp status to get 1% cash back on your payment = {money(totalCost * .01)} money back.</p></div></div><div className="v2-stc-cashback-actions"><button type="button" onClick={copyCashback}><i><img src={assets.copy} alt="" /></i><span>{copied ? "link copied" : "click on the icon\nto copy link"}</span></button><button type="button"><i><img src={assets.download} alt="" /></i><span>click on the icon to\ndownload image</span></button></div></div><div className="v2-stc-upload-block"><h2>Upload the Evidence (Screen Shot) of Image and link shared on your whatsapp status</h2><UploadBox fileName={cashbackEvidence} onFile={setCashbackEvidence} /></div></section>
            <section className="v2-stc-panel v2-stc-terms"><h2>Terms & Conditions</h2><Consent checked={privacyAccepted} onChange={(e) => setPrivacyAccepted(e.target.checked)}>I have read and agreed to privacy policy for all tasks.</Consent><Consent checked={termsAccepted} onChange={(e) => setTermsAccepted(e.target.checked)}>I have read and agreed to terms and condition.</Consent></section>
            <button className="v2-stc-proceed" type="submit">Proceed</button>
          </> : null}
        </form>
      </div>
    </main>
  );
}
