import React, { useState } from "react";
import "./v2-landing.css";
import {
  ServicesSection,
  TestimonialsSection,
  HowItWorksSection,
  WhoItsForSection,
  SpecialOfferingsSection,
  FAQSection,
  CTASection,
  LandingFooter,
} from "./LandingSections.jsx";

const ASSET_BASE = "/assets/nano-v2/";
const assets = {
  brand: `${ASSET_BASE}brand-mark.svg`,
  brandMobile: `${ASSET_BASE}brand-mobile.svg`,
  menu: `${ASSET_BASE}menu.svg`,
  close: `${ASSET_BASE}close.svg`,
  live: `${ASSET_BASE}live.svg`,
  hero1: `${ASSET_BASE}hero-1.jpg`,
  hero2: `${ASSET_BASE}hero-2.jpg`,
  hero3: `${ASSET_BASE}hero-3.jpg`,
  hero4: `${ASSET_BASE}hero-4.jpg`,
  hero5: `${ASSET_BASE}hero-5.jpg`,
  hero6: `${ASSET_BASE}hero-6.jpg`,
  mobile1: `${ASSET_BASE}mobile-1.jpg`,
  mobile2: `${ASSET_BASE}mobile-2.jpg`,
  mobile3: `${ASSET_BASE}mobile-3.jpg`,
  mobile4: `${ASSET_BASE}hero-3.jpg`,
  mobile5: `${ASSET_BASE}hero-4.jpg`,
  statBusiness: `${ASSET_BASE}stat-business.svg`,
  statPeople: `${ASSET_BASE}stat-people.svg`,
  statFlag: `${ASSET_BASE}stat-flag.svg`,
  statRate: `${ASSET_BASE}stat-rate.svg`,
};

const navItems = [
  ["Home", "#home"],
  ["Services", "#services"],
  ["Testimonials", "#testimonials"],
  ["How It Works", "#how-it-works"],
  ["Who It's For", "#who-its-for"],
  ["Offerings", "#offerings"],
  ["FAQs", "#faqs"],
];

const stats = [
  [assets.statBusiness, "7K+", "Businesses & Clients"],
  [assets.statPeople, "200k+", "Nano-Influencers"],
  [assets.statFlag, "2", "Countries"],
  [assets.statRate, "98%", "Message Trust Rate"],
];

const mobileImages = [assets.mobile1, assets.mobile2, assets.mobile3, assets.mobile4, assets.mobile5];

function DesktopNav() {
  return (
    <header className="v2-nav v2-nav-desktop">
      <a className="v2-brand" href="#home" aria-label="The Nano Influencers home">
        <img src={assets.brand} alt="" />
        <span>The Nano Influencers</span>
      </a>
      <nav className="v2-nav-links" aria-label="Landing page navigation">
        {navItems.map(([label, href], index) => (
          <a className={index === 0 ? "active" : ""} href={href} key={label}>{label}</a>
        ))}
      </nav>
      <div className="v2-nav-actions">
        <a className="v2-btn v2-btn-white" href="/login">Log In</a>
        <a className="v2-btn v2-btn-primary" href="/register">Get Started</a>
      </div>
    </header>
  );
}

function MobileNav() {
  const [open, setOpen] = useState(false);
  const close = () => setOpen(false);
  return (
    <header className={`v2-mobile-nav ${open ? "open" : ""}`}>
      <div className="v2-mobile-nav-bar">
        <a className="v2-brand" href="#home" onClick={close}>
          <img src={assets.brandMobile} alt="" />
          <span>The Nano Influencers</span>
        </a>
        <button
          className="v2-menu-button"
          type="button"
          aria-label={open ? "Close navigation" : "Open navigation"}
          aria-expanded={open}
          onClick={() => setOpen(value => !value)}
        >
          <img className={open ? "close-icon" : ""} src={open ? assets.close : assets.menu} alt="" />
        </button>
      </div>
      {open && (
        <div className="v2-mobile-dropdown">
          <nav>
            {navItems.map(([label, href], index) => (
              <a className={index === 0 ? "active" : ""} href={href} onClick={close} key={label}>{label}</a>
            ))}
          </nav>
          <div className="v2-mobile-actions">
            <a href="/login">Log In</a>
            <a className="v2-btn v2-btn-primary" href="/register">Get Started</a>
          </div>
        </div>
      )}
    </header>
  );
}

function StatCard({ icon, value, label }) {
  return (
    <article className="v2-stat-card">
      <div className="v2-stat-value"><img src={icon} alt="" /><span>{value}</span></div>
      <p>{label}</p>
    </article>
  );
}

function MobileImageMarquee() {
  return (
    <div className="v2-mobile-image-strip" aria-label="Nano influencer community">
      <div className="v2-mobile-image-track">
        {[0, 1].map(copy => (
          <div className="v2-mobile-image-group" aria-hidden={copy === 1 ? "true" : undefined} key={copy}>
            {mobileImages.map((src, index) => <img src={src} alt="" key={`${copy}-${index}`} />)}
          </div>
        ))}
      </div>
    </div>
  );
}

function MobileStatsMarquee() {
  return (
    <div className="v2-mobile-stats" aria-label="Nano Influencers statistics">
      <div className="v2-mobile-stats-track">
        {[0, 1].map(copy => (
          <div className="v2-mobile-stats-group" aria-hidden={copy === 1 ? "true" : undefined} key={copy}>
            {stats.map(([icon, value, label]) => <StatCard icon={icon} value={value} label={label} key={`${copy}-${label}`} />)}
          </div>
        ))}
      </div>
    </div>
  );
}

function Hero() {
  return (
    <section className="v2-hero" id="home">
      <DesktopNav />
      <MobileNav />

      <div className="v2-hero-content">
        <div className="v2-live-pill"><img src={assets.live} alt="" /><span>Now live across Nigeria &amp; Ghana</span></div>

        <h1 className="v2-hero-heading v2-desktop-heading">
          <span>Stop Going for</span>
          <strong className="navy">Empty Clicks.</strong>
          <span>Turn Everyday People</span>
          <span>into <strong className="orange">Your Brand&apos;s Most Powerful</strong></span>
          <strong className="orange">Advertisers</strong>
        </h1>

        <h1 className="v2-hero-heading v2-mobile-heading">
          <span>Stop Going for <strong className="navy">Empty Clicks.</strong></span>
          <span>Turn Everyday People into</span>
          <strong className="orange">Powerful Advertisers</strong>
        </h1>

        <p className="v2-hero-description">
          Advertise across Nigeria &amp; Ghana with millions of nano-influencers who will share,
          engage, and recommend your brand, content or business in DMs and Groups where people
          actually trust the message.
        </p>

        <div className="v2-hero-actions">
          <a className="v2-btn v2-btn-primary" href="/register">Get Started</a>
          <a className="v2-btn v2-btn-secondary" href="#how-it-works">See How it Works</a>
        </div>

        <p className="v2-trusted">Trusted by <strong>7k+ Businesses &amp; Clients</strong> across West Africa</p>
      </div>

      <div className="v2-hero-images v2-hero-images-desktop" aria-hidden="true">
        <figure className="hero-img hero-img-1"><img src={assets.hero1} alt="" /></figure>
        <figure className="hero-img hero-img-2"><img src={assets.hero2} alt="" /></figure>
        <figure className="hero-img hero-img-3"><img src={assets.hero3} alt="" /></figure>
        <figure className="hero-img hero-img-4"><img src={assets.hero4} alt="" /></figure>
        <figure className="hero-img hero-img-5"><img src={assets.hero5} alt="" /></figure>
        <figure className="hero-img hero-img-6"><img src={assets.hero6} alt="" /></figure>
      </div>

      <MobileImageMarquee />

      <div className="v2-stats v2-stats-desktop">
        {stats.map(([icon, value, label]) => <StatCard icon={icon} value={value} label={label} key={label} />)}
      </div>

      <MobileStatsMarquee />
    </section>
  );
}

export default function V2Landing() {
  return (
    <div className="v2-landing">
      <Hero />
      <ServicesSection />
      <TestimonialsSection />
      <HowItWorksSection />
      <WhoItsForSection />
      <SpecialOfferingsSection />
      <FAQSection />
      <CTASection />
      <LandingFooter />
    </div>
  );
}
