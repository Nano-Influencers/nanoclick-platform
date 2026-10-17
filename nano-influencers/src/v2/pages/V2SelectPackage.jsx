import React, { useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "../components/ui/Button.jsx";
import "./v2-select-package.css";

const ASSET_BASE = "/assets/nano-v2-app/";
const assets = {
  bronze: `${ASSET_BASE}package-bronze.png`,
  silver: `${ASSET_BASE}package-silver.png`,
  gold: `${ASSET_BASE}package-gold.png`,
  megaphone: `${ASSET_BASE}package-megaphone.svg`,
  arrowLeft: `${ASSET_BASE}package-arrow-left.svg`,
  check: `${ASSET_BASE}package-check.svg`,
};

const packageData = {
  bronze: {
    label: "Bronze Package",
    image: assets.bronze,
    tiers: [
      { name: "NewBie", price: 5000 },
      { name: "Beginner", price: 8000 },
      { name: "Starter", price: 12000 },
    ],
  },
  silver: {
    label: "Silver Package",
    image: assets.silver,
    tiers: [
      { name: "Entry", price: 22500 },
      { name: "Basic", price: 32500 },
      { name: "Intermediate", price: 57500 },
    ],
  },
  gold: {
    label: "Gold Package",
    image: assets.gold,
    tiers: [
      { name: "Advanced", price: 100000 },
      { name: "Expert", price: 210000 },
      { name: "Mastery", price: 310000 },
    ],
  },
};

const goals = {
  post: {
    title: "Post More",
    bullets: [
      "Make more post per month",
      "Dedicated followers in your Niche",
      "Best for pages/profiles that post often",
    ],
  },
  engagement: {
    title: "More Engagement",
    bullets: [
      "Get more engagements",
      "Dedicated followers in your Niche",
      "Best for high visibility pages/profiles",
    ],
  },
};

const baseFeatures = [
  "8 Post Per Month",
  "100 Dedicated Followers (Permanent)",
  "7-11 Likes/Reactions/Post",
  "2-4 tailored Comments/Post",
  "2-4 unique targeted share across 2 Platforms/Post",
  "42-72 Post Views/Post",
  "8-22 mins Watch time or Listen time/Post",
  "₦4,850 on Renewal",
];

const bronzeAllPlans = [
  { price: 5000, unit: "/month", features: baseFeatures },
  {
    price: 14500,
    unit: "3 months",
    features: [
      "24 Post for 3-Months", "100 Dedicated Followers", "7-11 Likes/Reactions/Post", "2-4 tailored Comments/Post",
      "2-4 unique targeted share across 2 Platforms/Post", "42-72 Post Views/Post", "8-22 mins Watch time or Listen time/Post", "₦14,250 on Renewal",
    ],
  },
  {
    price: 29000,
    unit: "6 months",
    features: [
      "48 Post/6-Months", "100 Dedicated Followers", "7-11 Likes/Reactions/Post", "2-4 tailored Comments/Post",
      "2-4 unique targeted share across 2 Platforms/Post", "42-72 Post Views/Post", "8-22 mins Watch time or Listen time/Post", "₦28,500 on Renewal",
    ],
  },
  {
    price: 57000,
    unit: "per year",
    features: [
      "96 Post/12-Months", "100 Dedicated Followers", "7-11 Likes/Reactions/Post", "2-4 tailored Comments/Post",
      "2-4 unique targeted share across 2 Platforms/Post", "42-72 Post Views/Post", "8-22 mins Watch time or Listen time/Post", "₦55,000 on Renewal",
    ],
  },
];

function currency(value) {
  return `₦${Number(value).toLocaleString("en-NG")}`;
}

function PageHeader({ allPlans, onBack }) {
  return (
    <>
      <header className="v2-package-backbar">
        <button type="button" onClick={onBack}>
          <img src={assets.arrowLeft} alt="" />
          <span>Go Back</span>
        </button>
      </header>
      <div className="v2-package-heading">
        <h1>{allPlans ? "All Plans" : "Select Your Package"}</h1>
        <p>Choose the right package to grow your brand and reach your audience.</p>
      </div>
    </>
  );
}

function PackageCard({ id, data, active, onClick }) {
  return (
    <button className={`v2-package-medal-card${active ? " is-active" : ""}`} type="button" onClick={() => onClick(id)}>
      <img src={data.image} alt="" />
      <span>{data.label}</span>
    </button>
  );
}

function TierRow({ tier, active, onClick }) {
  return (
    <button className={`v2-package-tier${active ? " is-active" : ""}`} type="button" onClick={onClick}>
      <span className="v2-package-radio" aria-hidden="true"><i /></span>
      <strong>{tier.name}</strong>
      {active && <span className="v2-package-tier-price">{currency(tier.price)}/mo</span>}
    </button>
  );
}

function GoalCard({ goalKey, selected, anySelected, onSelect }) {
  const goal = goals[goalKey];
  return (
    <article className={`v2-package-goal${selected ? " is-selected" : ""}`}>
      <div className="v2-package-goal-title">
        <span><img src={assets.megaphone} alt="" /></span>
        <h2>{goal.title}</h2>
      </div>
      <ul>{goal.bullets.map((item) => <li key={item}>{item}</li>)}</ul>
      {(!anySelected || selected) && (
        <button className="v2-package-goal-action" type="button" onClick={() => onSelect(goalKey)}>
          {selected ? "Deselect" : "Select"}
        </button>
      )}
    </article>
  );
}

function PricingCard({ planLabel, price, unit, features, highlighted = false, showSubscribe = false }) {
  return (
    <article className={`v2-package-pricing-card${highlighted ? " is-highlighted" : ""}`}>
      <div className="v2-package-pricing-head">
        <div><span>Your Plan</span><strong>{planLabel}</strong></div>
        <div className="v2-package-price"><strong>{currency(price)}</strong><span>{unit}</span></div>
      </div>
      <div className="v2-package-feature-grid">
        {features.map((feature) => (
          <div className="v2-package-feature" key={feature}><img src={assets.check} alt="" /><span>{feature}</span></div>
        ))}
      </div>
      {showSubscribe && <Button to="/campaigns/social-media-details" className="v2-package-plan-subscribe">Subscribe</Button>}
    </article>
  );
}

export default function V2SelectPackage() {
  const navigate = useNavigate();
  const [packageKey, setPackageKey] = useState("bronze");
  const [tierName, setTierName] = useState(null);
  const [goalKey, setGoalKey] = useState(null);
  const [allPlans, setAllPlans] = useState(false);

  const currentPackage = packageData[packageKey];
  const selectedTier = useMemo(
    () => currentPackage.tiers.find((tier) => tier.name === tierName) || null,
    [currentPackage, tierName],
  );

  const selectPackage = (nextKey) => {
    setPackageKey(nextKey);
    setTierName(null);
    setGoalKey(null);
    setAllPlans(false);
  };

  const selectGoal = (nextGoal) => {
    if (!selectedTier) return;
    setGoalKey((current) => current === nextGoal ? null : nextGoal);
  };

  const handleBack = () => {
    if (allPlans) {
      setAllPlans(false);
      return;
    }
    navigate("/campaigns");
  };

  const planLabel = `${currentPackage.label} · ${selectedTier?.name || currentPackage.tiers[0].name}`;
  const allPlanCards = bronzeAllPlans.map((plan, index) => index === 0 && selectedTier ? { ...plan, price: selectedTier.price } : plan);

  return (
    <main className="v2-package-page">
      <PageHeader allPlans={allPlans} onBack={handleBack} />

      {allPlans ? (
        <section className="v2-package-all-plans">
          {allPlanCards.map((plan, index) => (
            <PricingCard
              key={`${plan.price}-${plan.unit}`}
              planLabel={planLabel}
              price={plan.price}
              unit={plan.unit}
              features={plan.features}
              highlighted={index === 0}
              showSubscribe
            />
          ))}
        </section>
      ) : (
        <>
          <section className="v2-package-medals" aria-label="Package type">
            {Object.entries(packageData).map(([id, data]) => (
              <PackageCard key={id} id={id} data={data} active={id === packageKey} onClick={selectPackage} />
            ))}
          </section>

          <section className="v2-package-tier-panel" aria-label={`${currentPackage.label} tiers`}>
            {currentPackage.tiers.map((tier) => (
              <TierRow key={tier.name} tier={tier} active={tier.name === tierName} onClick={() => { setTierName(tier.name); setGoalKey(null); }} />
            ))}
          </section>

          <section className="v2-package-goals">
            <GoalCard goalKey="post" selected={goalKey === "post"} anySelected={Boolean(goalKey)} onSelect={selectGoal} />
            <GoalCard goalKey="engagement" selected={goalKey === "engagement"} anySelected={Boolean(goalKey)} onSelect={selectGoal} />
          </section>

          {selectedTier && goalKey && (
            <section className="v2-package-summary">
              <PricingCard planLabel={planLabel} price={selectedTier.price} unit="/month" features={baseFeatures} />
              <div className="v2-package-summary-actions">
                <Button to="/campaigns/social-media-details">Subscribe</Button>
                <Button variant="secondary" onClick={() => setAllPlans(true)}>See All Plans</Button>
              </div>
            </section>
          )}
        </>
      )}
    </main>
  );
}
