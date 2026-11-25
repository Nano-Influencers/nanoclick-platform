import React, { useRef, useState } from "react";
import "./v2-dashboard-extras.css";

const ASSET_BASE = "/assets/nano-v2-app/";
const assets = {
  back: `${ASSET_BASE}custom-task-arrow-left.svg`,
  share: `${ASSET_BASE}extra-share.svg`,
  eye: `${ASSET_BASE}extra-eye.svg`,
  uploadDoc: `${ASSET_BASE}extra-upload-doc.svg`,
  verify: `${ASSET_BASE}extra-verify.svg`,
  copy: `${ASSET_BASE}custom-task-copy.svg`,
  award: `${ASSET_BASE}extra-award.svg`,
  upload: `${ASSET_BASE}custom-task-upload.svg`,
  locked: `${ASSET_BASE}extra-locked.svg`,
  blender: `${ASSET_BASE}extra-blender.png`,
  carouselLeft: `${ASSET_BASE}extra-carousel-left.svg`,
  carouselRight: `${ASSET_BASE}extra-carousel-right.svg`,
  video: `${ASSET_BASE}extra-video.svg`,
  purchase: `${ASSET_BASE}extra-purchase.svg`,
  send: `${ASSET_BASE}extra-send.svg`,
  refer: `${ASSET_BASE}extra-refer.svg`,
  giveawayUpload: `${ASSET_BASE}custom-task-upload.svg`,
  accordion: `${ASSET_BASE}extra-accordion.svg`,
};

function BackHeader() {
  return (
    <div className="v2-extra-back-header">
      <a href="/dashboard" className="v2-extra-back"><img src={assets.back} alt="" /><span>Go Back</span></a>
      <div className="v2-extra-separator" />
    </div>
  );
}

function PageIntro({ title, subtitle }) {
  return <header className="v2-extra-intro"><h1>{title}</h1><p>{subtitle}</p></header>;
}

function CopyChip({ children }) {
  return <button type="button" className="v2-extra-chip"><img src={assets.copy} alt="" /><span>{children}</span></button>;
}

function RequirementCard({ number, icon, title, children, chips }) {
  return (
    <article className="v2-extra-requirement">
      <div className="v2-extra-number-column">
        <span className="v2-extra-icon"><img src={icon} alt="" /></span>
        <span className="v2-extra-number">{number}</span>
      </div>
      <div className="v2-extra-requirement-copy">
        <h3>{title}</h3>
        <p>{children}</p>
        {chips?.length ? <div className="v2-extra-chip-row">{chips.map((chip) => <CopyChip key={chip}>{chip}</CopyChip>)}</div> : null}
      </div>
    </article>
  );
}

function UploadProof({ icon = assets.upload, description }) {
  const inputRef = useRef(null);
  const [fileName, setFileName] = useState("");
  return (
    <section className="v2-extra-panel v2-extra-upload-panel">
      <div className="v2-extra-section-heading">
        <h2>Submit Proof of your Ad Post</h2>
        <p>{description}</p>
      </div>
      <input
        ref={inputRef}
        className="v2-extra-file-input"
        type="file"
        accept="image/*"
        onChange={(event) => setFileName(event.target.files?.[0]?.name || "")}
      />
      <button className="v2-extra-dropzone" type="button" onClick={() => inputRef.current?.click()}>
        <img src={icon} alt="" />
        <strong>{fileName || "Choose file"}</strong>
        <span>{fileName ? "Tap to choose another file" : "Size limit: 5mb"}</span>
      </button>
      <button className="v2-extra-primary" type="button">Submit Proof</button>
      <p className="v2-extra-review-note">Reviewed manually — usually within 30 minutes.</p>
    </section>
  );
}

const cautionItems = [
  <><strong>Backdated or manipulated proof is prohibited:</strong> Any attempt to submit edited, reused, or time-altered screenshots will result in a permanent ban from the free trial, without appeal.</>,
  <><strong>Do not delete early:</strong> Deleting the status or group message before the 8-hour requirement automatically disqualifies the submission.</>,
  <><strong>Unclear proof is not approved:</strong> Submitting incomplete proof, unclear screenshots, or evidence that cannot verify time duration will not be approved.</>,
  <><strong>One approval per account:</strong> Each account is allowed one free trial approval only. Multiple attempts using alternate accounts or recycled proofs will lead to permanent restriction.</>,
  <>Each account is allowed one free trial approval only. Multiple attempts using alternate accounts or recycled proofs will lead to permanent restriction.</>,
  <>Our system actively reviews timestamps, activity logs, and profile history to ensure fairness and transparency.</>,
];

export function V2FreeTrial() {
  return (
    <main className="ni-v2 v2-extra-page">
      <div className="v2-extra-main">
        <BackHeader />
        <PageIntro
          title="Free Trial Access"
          subtitle="Only 5 trials are released each week. Complete the four requirements below and your access unlocks as soon as your proof clears review."
        />

        <section className="v2-trial-status">
          <img src={assets.award} alt="" />
          <div><p><strong>2</strong><span>of 5 trials left this week</span></p><small>Resets every Monday at 00:00 WAT · 3 already claimed</small></div>
        </section>

        <section className="v2-extra-panel">
          <div className="v2-extra-section-heading"><h2>How to Qualify</h2><p>All four steps are required. Skipping any one of them voids the submission.</p></div>
          <div className="v2-extra-requirements">
            <RequirementCard number="01" icon={assets.share} title="Share our Ad Assets" chips={["Copy Text Info", "Copy Ads Assets"]}>
              Share our official ad materials on your WhatsApp status and in at least one WhatsApp group chat. Both posts must be made using the exact ad assets provided (the Text &amp; the Image). You can rephrase the Text to fit the context of your Audience.
            </RequirementCard>
            <RequirementCard number="02" icon={assets.eye} title="Maintain Visibility for 8 Hours">
              Your WhatsApp status and the group chat message must remain visible and undeleted for a minimum of 8 hours. The proof you submit must clearly show that the posts lasted for the full 8-hour period.
            </RequirementCard>
            <RequirementCard number="03" icon={assets.uploadDoc} title="Submit Valid Proof">
              Submit clear proof showing your WhatsApp status and group post remained visible for the required period so the submission can be reviewed.
            </RequirementCard>
            <RequirementCard number="04" icon={assets.verify} title="Approval & Access">
              Once approved, “Open Free Trial” unlocks instantly and you can use every eligible feature at no cost.
            </RequirementCard>
          </div>
        </section>

        <section className="v2-extra-panel v2-extra-caution">
          <div className="v2-extra-section-heading"><h2>Important Caution</h2></div>
          <div className="v2-extra-caution-list">{cautionItems.map((item, index) => <div key={index}><i /><p>{item}</p></div>)}</div>
        </section>

        <UploadProof description="Upload the Proof of our Ad Post you made on your WhatsApp Status" />

        <section className="v2-trial-locked">
          <img src={assets.locked} alt="" />
          <div><h2>Trial Locked</h2><p>This unlocks the moment your proof is approved. Nothing else is required.</p></div>
          <button type="button" disabled>Open Free Trial</button>
        </section>
      </div>
    </main>
  );
}

const giveawayTerms = [
  {
    title: "01. Service Purchase Tracking",
    body: <>Once you make a purchase, we will automatically track and record your profile to confirm that you have met the required service purchase amount. Only verified purchases made during the giveaway period will be acknowledged.</>,
  },
  {
    title: "02. Ad Sharing Is Mandatory",
    body: <><p>Sharing our official ad assets on your WhatsApp status is compulsory to enter the giveaway.</p><p>If the ads are not shared and proof is not submitted, you will not be considered - even if you meet or exceed the minimum service purchase amount.</p></>,
  },
  {
    title: "03. Giveaway Timeline",
    body: <><p>Giveaway Timeline This giveaway runs strictly from 17th to 24th January 2026.</p><p>Any purchase or activity made before or after these dates will not count for this week's giveaway.</p></>,
  },
  {
    title: "04. Eligibility",
    body: <><p>Participation is open to:</p><p>- New accounts<br />- Existing accounts<br />- Users from any location</p><p>Everyone is welcome to participate as long as all participation requirements are met.</p></>,
  },
  {
    title: "05. Winner Selection Process",
    body: <><p>Winners will be selected in two stages.</p><p>Step 1 - Compliance Check: We confirm that all participants followed the participation instructions correctly.</p><p>Step 2 - Random Raffle Draw: Eligible participants will then be entered into a random raffle draw, where winners would be fairly selected.</p></>,
  },
  {
    title: "06. Violations & Disqualification",
    body: <><p>Any violation of our terms and conditions will result in disqualification from that week's giveaway.</p><p>This includes:<br />- False claims<br />- Incomplete participation steps<br />- Misuse of the giveaway system</p><p>Participants who violate the rules may also receive a temporary ban from that week's giveaway.</p></>,
  },
];

function GiveawayAccordion() {
  const params = new URLSearchParams(window.location.search);
  const initiallyExpanded = params.get("state") === "expanded";
  const [open, setOpen] = useState(() => new Set(initiallyExpanded ? giveawayTerms.map((_, index) => index) : []));
  const toggle = (index) => setOpen((current) => {
    const next = new Set(current);
    if (next.has(index)) next.delete(index); else next.add(index);
    return next;
  });
  return (
    <section className="v2-extra-panel v2-giveaway-terms">
      <div className="v2-extra-section-heading"><h2>Terms &amp; Conditions</h2></div>
      <div className="v2-giveaway-accordion">
        {giveawayTerms.map((term, index) => {
          const expanded = open.has(index);
          return (
            <article className={`v2-giveaway-term${expanded ? " is-open" : ""}`} key={term.title}>
              <button type="button" aria-expanded={expanded} onClick={() => toggle(index)}><span>{term.title}</span><span className="v2-giveaway-term-icon"><img src={assets.accordion} alt="" /></span></button>
              {expanded ? <div className="v2-giveaway-term-body">{term.body}</div> : null}
            </article>
          );
        })}
      </div>
    </section>
  );
}

export function V2WeeklyGiveaway() {
  return (
    <main className="ni-v2 v2-extra-page">
      <div className="v2-extra-main">
        <BackHeader />
        <PageIntro title="Weekly Giveaway" subtitle="Spend, share, and win this week" />

        <section className="v2-extra-panel v2-giveaway-prize">
          <div className="v2-giveaway-image"><img src={assets.blender} alt="Multipurpose kitchen blender" /></div>
          <div className="v2-giveaway-controls" aria-label="Prize carousel controls">
            <button type="button"><img src={assets.carouselLeft} alt="Previous prize" /></button>
            <div><i className="is-active" /><i /><i /></div>
            <button type="button"><img src={assets.carouselRight} alt="Next prize" /></button>
          </div>
          <div className="v2-giveaway-prize-copy">
            <span>Grand prize</span>
            <h2>Multipurpose Kitchen Blender</h2>
            <p>Estimated value <strong>₦145,000</strong> · delivered free anywhere in Nigeria.</p>
            <a href="#walkthrough"><img src={assets.video} alt="" />Watch the 60-second walkthrough</a>
          </div>
        </section>

        <section className="v2-extra-panel">
          <div className="v2-extra-section-heading"><h2>How to Qualify</h2><p>Two required steps, one optional bonus. Everything is tracked automatically except your ad screenshot.</p></div>
          <div className="v2-extra-requirements">
            <RequirementCard number="01" icon={assets.purchase} title="Spend ₦10,000 on Any Service" chips={["Copy Text Info", "Copy Ads Assets"]}>
              Airtime, data, bills — anything counts. We track your spend automatically, so there is nothing to upload for this step.
            </RequirementCard>
            <RequirementCard number="02" icon={assets.send} title="Share our Ad on Your WhatsApp Status">
              Post the exact image and caption below, keep it live, then submit a screenshot as proof. This step is required.
            </RequirementCard>
            <RequirementCard number="03" icon={assets.refer} title="Refer a Friend for a Bonus Entry (Optional)">
              Every friend who spends ₦1,000 or more adds one extra entry to the raffle. Optional, but it stacks your odds.
            </RequirementCard>
          </div>
        </section>

        <UploadProof icon={assets.giveawayUpload} description="Upload one screenshot showing your status and the group message, with the 8-hour duration clearly visible." />
        <GiveawayAccordion />
      </div>
    </main>
  );
}
