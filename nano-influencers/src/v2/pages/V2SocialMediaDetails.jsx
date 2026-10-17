import React, { useState } from "react";
import "./v2-social-media-details.css";

const ASSET_BASE = "/assets/nano-v2-app/";
const assets = {
  arrowLeft: `${ASSET_BASE}campaign-back.svg`,
  dropdown: `${ASSET_BASE}auth-arrow-down.svg`,
  close: `${ASSET_BASE}campaign-x.svg`,
  facebook: `${ASSET_BASE}social-facebook.svg`,
  youtube: `${ASSET_BASE}social-youtube.svg`,
  twitter: `${ASSET_BASE}social-x.svg`,
  instagram: `${ASSET_BASE}social-instagram.svg`,
  tiktok: `${ASSET_BASE}social-tiktok.svg`,
  linkedin: `${ASSET_BASE}social-linkedin.svg`,
};

const categoryOptions = [
  "Entertainment",
  "Real Estate",
  "Personal Page/Profile",
  "Social Impact",
  "Fashion",
  "Technology",
  "Finance",
  "Professional Services",
  "Transport & Logistics",
  "Telecommunication",
  "Agriculture",
  "Hospitality & Tourism",
  "Automobile",
  "Security & Defense",
  "Manufacturing/Industrial",
  "Govt. & Public Sector",
  "Beauty",
  "Food & Beverage",
  "Sports",
  "Healthcare",
  "Art & Design",
  "Education",
  "Construction",
  "Manufacturing & Industrial",
  "Energy",
  "Gaming",
  "Retail",
  "Religion",
];

const platforms = [
  ["Facebook", assets.facebook],
  ["Youtube", assets.youtube],
  ["Twitter", assets.twitter],
  ["Instagram", assets.instagram],
  ["TikTok", assets.tiktok],
  ["LinkedIn", assets.linkedin],
];

const nigerianStates = [
  "Abia", "Adamawa", "Akwa Ibom", "Anambra", "Bauchi", "Bayelsa", "Benue", "Borno", "Cross River",
  "Delta", "Ebonyi", "Edo", "Ekiti", "Enugu", "Gombe", "Imo", "Jigawa", "Kaduna", "Kano", "Katsina",
  "Kebbi", "Kogi", "Kwara", "Lagos", "Nasarawa", "Niger", "Ogun", "Ondo", "Osun", "Oyo", "Plateau",
  "Rivers", "Sokoto", "Taraba", "Yobe", "Zamfara", "FCT Abuja",
];

function go(path) {
  if (typeof window !== "undefined") window.location.assign(path);
}

function SectionHeader({ title, subtitle, helper, optional = false }) {
  return (
    <div className="v2-sm-section-header">
      <div>
        <h2>
          {title}
          {optional && <span> (Optional)</span>}
        </h2>
        {subtitle && <p>{subtitle}</p>}
      </div>
      {helper && <div className="v2-sm-helper">{helper}</div>}
    </div>
  );
}

function CategorySelector({ selected, onAdd, onRemove }) {
  const [open, setOpen] = useState(false);
  const available = categoryOptions.filter((item) => !selected.includes(item));

  return (
    <div className="v2-sm-category-wrap">
      <button
        type="button"
        className={`v2-sm-category-field${open ? " is-open" : ""}`}
        onClick={() => setOpen((value) => !value)}
        aria-expanded={open}
      >
        {selected.map((item) => (
          <span className="v2-sm-chip" key={item}>
            {item}
            <span
              className="v2-sm-chip-close"
              role="button"
              tabIndex={0}
              aria-label={`Remove ${item}`}
              onClick={(event) => {
                event.stopPropagation();
                onRemove(item);
              }}
              onKeyDown={(event) => {
                if (event.key === "Enter" || event.key === " ") {
                  event.preventDefault();
                  event.stopPropagation();
                  onRemove(item);
                }
              }}
            >
              <img src={assets.close} alt="" />
            </span>
          </span>
        ))}
        {selected.length < 3 && <span className="v2-sm-category-placeholder">Add another…</span>}
      </button>

      {open && (
        <div className="v2-sm-category-menu">
          {available.map((item, index) => (
            <button
              type="button"
              key={`${item}-${index}`}
              onClick={() => {
                if (selected.length < 3) onAdd(item);
                if (selected.length >= 2) setOpen(false);
              }}
            >
              {item}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

function PlatformGrid({ selected, onSelect }) {
  return (
    <div className="v2-sm-platform-grid">
      {platforms.map(([name, icon]) => (
        <button
          type="button"
          className={`v2-sm-platform-card${selected === name ? " is-selected" : ""}`}
          key={name}
          onClick={() => onSelect(name)}
          aria-pressed={selected === name}
        >
          <img src={icon} alt="" />
          <span>{name}</span>
        </button>
      ))}
    </div>
  );
}

export default function V2SocialMediaDetails() {
  const [categories, setCategories] = useState(() => (
    typeof window !== "undefined" && window.innerWidth <= 700
      ? ["Entertainment", "Real Estate"]
      : ["Entertainment", "Real Estate", "Fashion"]
  ));
  const [specification, setSpecification] = useState("");
  const [platform, setPlatform] = useState("");
  const [pageLink, setPageLink] = useState("");
  const [state, setState] = useState("");
  const [area, setArea] = useState("");
  const [extra, setExtra] = useState("");
  const [referral, setReferral] = useState("");
  const [source, setSource] = useState("Online Ads");

  const addCategory = (item) => {
    setCategories((current) => current.length < 3 && !current.includes(item) ? [...current, item] : current);
  };

  const removeCategory = (item) => {
    setCategories((current) => current.filter((value) => value !== item));
  };

  const handleSubmit = (event) => {
    event.preventDefault();
    if (typeof window !== "undefined") {
      window.sessionStorage.setItem("v2CampaignDraft", JSON.stringify({
        categories,
        specification,
        platform,
        pageLink,
        state,
        area,
        extra,
        referral,
        source,
      }));
    }
    go("/campaigns/preview-selections");
  };

  return (
    <main className="v2-sm-page">
      <div className="v2-sm-shell">
        <header className="v2-sm-backbar">
          <button type="button" onClick={() => go("/campaigns/select-package")}>
            <img src={assets.arrowLeft} alt="" />
            <span>Go Back</span>
          </button>
        </header>

        <section className="v2-sm-tabs" aria-label="Campaign details steps">
          <button type="button" className="is-active">Social Media Details</button>
          <button type="button" onClick={() => go("/campaigns/preview-selections")}>Preview Selections</button>
        </section>

        <form className="v2-sm-form" onSubmit={handleSubmit}>
          <section className="v2-sm-panel v2-sm-category-panel">
            <SectionHeader
              title="Social Media Details"
              subtitle="How do you categorize your profile/page"
              helper={<><span>(Select at most 3 options</span><span>within your profile/page niche)</span></>}
            />
            <CategorySelector selected={categories} onAdd={addCategory} onRemove={removeCategory} />
          </section>

          <section className="v2-sm-panel">
            <SectionHeader
              title="Specification for Page/Profile"
              subtitle="What is your page/profile about"
              helper="(specify e.g. Comedy, Sales of cosmetic products etc. Limited to 50 character)"
            />
            <div className="v2-sm-input-stack">
              <input
                className="v2-sm-input"
                type="text"
                placeholder="type here"
                maxLength={50}
                value={specification}
                onChange={(event) => setSpecification(event.target.value)}
              />
              <span className="v2-sm-counter">{specification.length}/50</span>
            </div>
          </section>

          <section className="v2-sm-platform-section">
            <SectionHeader title="Select the Social Platform" subtitle="Kindly select the social platform below:" />
            <PlatformGrid selected={platform} onSelect={setPlatform} />
          </section>

          <section className="v2-sm-panel v2-sm-desktop-link">
            <SectionHeader title="Link to your Page/Profile" subtitle="Paste the link to your page below" />
            <input className="v2-sm-input" type="url" placeholder="paste here" value={pageLink} onChange={(event) => setPageLink(event.target.value)} />
          </section>

          <section className="v2-sm-panel">
            <SectionHeader
              title="Primary Location of Business/Individual"
              subtitle="Select the primary location of your business or where you need to establish visibility."
            />
            <div className="v2-sm-location-content">
              <label className="v2-sm-select-wrap">
                <select value={state} onChange={(event) => setState(event.target.value)}>
                  <option value="">Select by State</option>
                  {nigerianStates.map((item) => <option value={item} key={item}>{item}</option>)}
                </select>
                <img src={assets.dropdown} alt="" />
              </label>
              <label className="v2-sm-area-field">
                <span>Type in the Area you need followers from:</span>
                <textarea placeholder="type here" value={area} onChange={(event) => setArea(event.target.value)} />
              </label>
            </div>
          </section>

          <section className="v2-sm-panel">
            <SectionHeader title="Share Anything Here" subtitle="Share anything you would like us to know below:" optional />
            <textarea className="v2-sm-textarea" placeholder="type here" value={extra} onChange={(event) => setExtra(event.target.value)} />
          </section>

          <section className="v2-sm-panel">
            <SectionHeader title="Who Referred You?" subtitle="Enter their code below:" optional />
            <input className="v2-sm-input" type="text" placeholder="type here" value={referral} onChange={(event) => setReferral(event.target.value)} />
          </section>

          <section className="v2-sm-panel">
            <SectionHeader title="How Did You Hear About Us?" optional />
            <label className="v2-sm-select-wrap">
              <select value={source} onChange={(event) => setSource(event.target.value)}>
                <option>Online Ads</option>
                <option>Referral</option>
                <option>Social Media</option>
                <option>Search Engine</option>
                <option>Other</option>
              </select>
              <img src={assets.dropdown} alt="" />
            </label>
          </section>

          <button className="v2-sm-proceed" type="submit">Proceed</button>
        </form>
      </div>
    </main>
  );
}
