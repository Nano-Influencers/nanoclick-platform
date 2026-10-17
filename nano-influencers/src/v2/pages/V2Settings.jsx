import React, { useMemo, useRef, useState } from "react";
import { Button } from "../components/ui/Button.jsx";
import "./v2-settings.css";

const ASSET_BASE = "/assets/nano-v2-app/";
const assets = {
  brand: `${ASSET_BASE}dashboard-brand.svg`,
  profileSmall: `${ASSET_BASE}settings-profile-small.png`,
  profileLarge: `${ASSET_BASE}settings-profile-large.png`,
  notification: `${ASSET_BASE}dashboard-notification.svg`,
  dashboard: `${ASSET_BASE}dashboard-menu.svg`,
  wallet: `${ASSET_BASE}dashboard-wallet.svg`,
  analytics: `${ASSET_BASE}dashboard-analytics.svg`,
  settings: `${ASSET_BASE}dashboard-settings.svg`,
  help: `${ASSET_BASE}dashboard-help.svg`,
  logout: `${ASSET_BASE}dashboard-logout.svg`,
  collapse: `${ASSET_BASE}dashboard-chevron.svg`,
  dateChevron: `${ASSET_BASE}dashboard-date-chevron.svg`,
  profileTab: `${ASSET_BASE}settings-tab-profile.svg`,
  notificationTab: `${ASSET_BASE}settings-tab-notifications.svg`,
  preferencesTab: `${ASSET_BASE}settings-tab-preferences.svg`,
  edit: `${ASSET_BASE}campaign-edit.svg`,
  trash: `${ASSET_BASE}campaign-trash.svg`,
  export: `${ASSET_BASE}settings-export.svg`,
  actionChevron: "/assets/nano-v2/testimonial-right.svg",
  deleteIllustration: `${ASSET_BASE}settings-delete-account.png`,
};

const tabs = [
  { id: "profile", label: "Profile", icon: assets.profileTab },
  { id: "notifications", label: "Notifications", icon: assets.notificationTab },
  { id: "preferences", label: "Preferences", icon: assets.preferencesTab },
];

function Brand() {
  return (
    <a className="v2-settings-brand" href="/" aria-label="The Nano Influencers home">
      <img src={assets.brand} alt="" />
      <span>The Nano Influencers</span>
    </a>
  );
}

function SidebarLink({ href, icon, children, active = false }) {
  return (
    <a className={`v2-settings-sidebar-link${active ? " is-active" : ""}`} href={href}>
      <img src={icon} alt="" />
      <span>{children}</span>
    </a>
  );
}

function AppSidebar() {
  return (
    <aside className="v2-settings-sidebar">
      <div>
        <div className="v2-settings-sidebar-logo"><Brand /></div>
        <div className="v2-settings-sidebar-group">
          <p>Main Menu</p>
          <SidebarLink href="/dashboard" icon={assets.dashboard}>Dashboard</SidebarLink>
          <SidebarLink href="/wallet" icon={assets.wallet}>Wallet</SidebarLink>
          <SidebarLink href="#campaigns" icon={assets.dashboard}>Campaigns</SidebarLink>
          <SidebarLink href="#analytics" icon={assets.analytics}>Analytics</SidebarLink>
        </div>
        <div className="v2-settings-sidebar-group v2-settings-sidebar-support">
          <p>Support</p>
          <SidebarLink href="/settings" icon={assets.settings} active>Settings</SidebarLink>
          <SidebarLink href="#help" icon={assets.help}>Help &amp; Support</SidebarLink>
        </div>
      </div>
      <button className="v2-settings-logout" type="button"><span>Log Out</span><img src={assets.logout} alt="" /></button>
      <button className="v2-settings-collapse" type="button" aria-label="Collapse sidebar"><img src={assets.collapse} alt="" /></button>
    </aside>
  );
}

function TopHeader() {
  return (
    <header className="v2-settings-topbar">
      <div className="v2-settings-mobile-brand"><Brand /></div>
      <p className="v2-settings-welcome">Welcome Back 👋</p>
      <div className="v2-settings-user">
        <button className="v2-settings-notification" type="button" aria-label="Notifications"><img src={assets.notification} alt="" /></button>
        <div className="v2-settings-profile-chip"><img src={assets.profileSmall} alt="Adaeze O." /><span>Adaeze O.</span></div>
      </div>
    </header>
  );
}

function SettingsTabs({ activeTab, onChange }) {
  return (
    <nav className="v2-settings-tabs" aria-label="Settings sections">
      {tabs.map((tab) => (
        <button key={tab.id} type="button" className={activeTab === tab.id ? "is-active" : ""} onClick={() => onChange(tab.id)}>
          <img src={tab.icon} alt="" />
          <span>{tab.label}</span>
        </button>
      ))}
    </nav>
  );
}

function SectionCard({ title, subtitle, children, className = "" }) {
  return (
    <section className={`v2-settings-card ${className}`.trim()}>
      <div className="v2-settings-card-heading"><h2>{title}</h2><p>{subtitle}</p></div>
      {children}
    </section>
  );
}

function Field({ label, type = "text", value, onChange, placeholder, full = false }) {
  return (
    <label className={`v2-settings-field${full ? " is-full" : ""}`}>
      <span>{label}</span>
      <input type={type} value={value} onChange={onChange} placeholder={placeholder} />
    </label>
  );
}

function PasswordField({ label, value, onChange, placeholder }) {
  const [visible, setVisible] = useState(false);
  return (
    <label className="v2-settings-field">
      <span>{label}</span>
      <span className="v2-settings-password-wrap">
        <input type={visible ? "text" : "password"} value={value} onChange={onChange} placeholder={placeholder} />
        <button type="button" aria-label={visible ? "Hide password" : "Show password"} onClick={() => setVisible((current) => !current)}>{visible ? "◉" : "◌"}</button>
      </span>
    </label>
  );
}

function ProfileSettings() {
  const uploadRef = useRef(null);
  const [avatar, setAvatar] = useState(assets.profileLarge);
  const [form, setForm] = useState({ first: "Adaeze", last: "Okafor", email: "adaeze@gmail.com", phone: "+234 803 123 4567", currentPassword: "", newPassword: "", confirmPassword: "" });
  const set = (key) => (event) => setForm((current) => ({ ...current, [key]: event.target.value }));
  const onPhoto = (event) => {
    const file = event.target.files?.[0];
    if (!file) return;
    setAvatar(URL.createObjectURL(file));
  };
  return (
    <div className="v2-settings-primary v2-settings-profile-panel">
      <SectionCard title="Profile Photo" subtitle="Update your brand avatar" className="is-profile-photo">
        <div className="v2-settings-photo-row">
          <div className="v2-settings-photo-identity">
            {avatar ? <img className="v2-settings-large-avatar" src={avatar} alt="Adaeze Okafor" /> : <div className="v2-settings-avatar-placeholder">AO</div>}
            <strong>Adaeze Okafor</strong>
          </div>
          <div className="v2-settings-photo-actions">
            <input ref={uploadRef} type="file" accept="image/*" hidden onChange={onPhoto} />
            <button type="button" className="is-change" onClick={() => uploadRef.current?.click()}><img src={assets.edit} alt="" />Change Photo</button>
            <button type="button" className="is-remove" onClick={() => setAvatar(null)}><img src={assets.trash} alt="" />Remove Photo</button>
          </div>
        </div>
      </SectionCard>

      <SectionCard title="Personal Information" subtitle="Update your account details">
        <div className="v2-settings-form-grid">
          <Field label="First Name" value={form.first} onChange={set("first")} />
          <Field label="Last Name" value={form.last} onChange={set("last")} />
          <Field label="Email" type="email" value={form.email} onChange={set("email")} />
          <Field label="Phone Number" value={form.phone} onChange={set("phone")} />
        </div>
      </SectionCard>

      <SectionCard title="Change Password" subtitle="Update your password regularly to keep your account secure">
        <div className="v2-settings-form-grid">
          <div className="is-grid-full"><PasswordField label="Current Password" value={form.currentPassword} onChange={set("currentPassword")} placeholder="Min. 8 characters" /></div>
          <PasswordField label="New Password" value={form.newPassword} onChange={set("newPassword")} placeholder="enter your password" />
          <PasswordField label="Confirm New Password" value={form.confirmPassword} onChange={set("confirmPassword")} placeholder="Re-enter your password" />
        </div>
      </SectionCard>
      <SettingsActions />
    </div>
  );
}

function Toggle({ checked, onChange, disabled = false, label }) {
  return (
    <button type="button" role="switch" aria-checked={checked} aria-label={label} disabled={disabled} className={`v2-settings-toggle${checked ? " is-on" : ""}`} onClick={() => onChange?.(!checked)}>
      <span />
    </button>
  );
}

function ToggleRow({ title, description, checked, onChange, disabled = false }) {
  return (
    <div className={`v2-settings-toggle-row${disabled ? " is-disabled" : ""}`}>
      <div><h3>{title}</h3><p>{description}</p></div>
      <Toggle checked={checked} onChange={onChange} disabled={disabled} label={title} />
    </div>
  );
}

function NotificationSettings() {
  const [values, setValues] = useState({ emailCampaign: true, emailWallet: true, emailMarketing: false, pushCampaign: true, pushWallet: true, pushMessages: true, smsCritical: false });
  const toggle = (key) => (next) => setValues((current) => ({ ...current, [key]: next }));
  return (
    <div className="v2-settings-primary v2-settings-notification-panel">
      <SectionCard title="Email Notifications" subtitle="Manage your email notifications">
        <div className="v2-settings-toggle-list">
          <ToggleRow title="Campaign Updates" description="Get notified about campaign status changes" checked={values.emailCampaign} onChange={toggle("emailCampaign")} />
          <ToggleRow title="Wallet Transactions" description="Deposits, withdrawals, and payments" checked={values.emailWallet} onChange={toggle("emailWallet")} />
          <ToggleRow title="Marketing & Promotions" description="Tips, guides, and special offers" checked={values.emailMarketing} onChange={toggle("emailMarketing")} />
        </div>
      </SectionCard>
      <SectionCard title="Push Notifications" subtitle="Manage your push notifications">
        <div className="v2-settings-toggle-list">
          <ToggleRow title="Campaign Updates" description="Real-time campaign alerts on your device" checked={values.pushCampaign} onChange={toggle("pushCampaign")} />
          <ToggleRow title="Wallet Activity" description="Instant alerts for all wallet transactions" checked={values.pushWallet} onChange={toggle("pushWallet")} />
          <ToggleRow title="Direct Messages" description="When influencers or support message you" checked={values.pushMessages} onChange={toggle("pushMessages")} />
        </div>
      </SectionCard>
      <SectionCard title="SMS Alerts" subtitle="Manage your sms alerts">
        <div className="v2-settings-toggle-list"><ToggleRow title="Critical Alerts Only" description="Receive SMS for important account activity" checked={values.smsCritical} onChange={toggle("smsCritical")} /></div>
      </SectionCard>
      <SettingsActions />
    </div>
  );
}

function PreferenceSettings({ onDelete }) {
  const [currency, setCurrency] = useState("Nigerian Naira (₦)");
  const [timezone, setTimezone] = useState("Africa/Lagos (GMT+1)");
  const [language, setLanguage] = useState("English");
  const [autoRenew, setAutoRenew] = useState(true);
  const exportData = () => {
    const payload = { profile: { name: "Adaeze Okafor" }, preferences: { currency, timezone, language, autoRenew } };
    const url = URL.createObjectURL(new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" }));
    const link = document.createElement("a");
    link.href = url;
    link.download = "nano-influencers-account-data.json";
    link.click();
    URL.revokeObjectURL(url);
  };
  return (
    <div className="v2-settings-primary v2-settings-preferences-panel">
      <SectionCard title="Regional Settings" subtitle="Customize your locale and display preferences">
        <div className="v2-settings-form-grid">
          <label className="v2-settings-field"><span>Currency</span><select value={currency} onChange={(e) => setCurrency(e.target.value)}><option>Nigerian Naira (₦)</option><option>US Dollar ($)</option><option>British Pound (£)</option></select></label>
          <label className="v2-settings-field"><span>Timezone</span><select value={timezone} onChange={(e) => setTimezone(e.target.value)}><option>Africa/Lagos (GMT+1)</option><option>UTC</option></select></label>
          <label className="v2-settings-field is-grid-full"><span>Language</span><select value={language} onChange={(e) => setLanguage(e.target.value)}><option>English</option></select></label>
        </div>
      </SectionCard>
      <SectionCard title="Display & Campaigns" subtitle="Control how the dashboard looks and behaves">
        <div className="v2-settings-toggle-list">
          <ToggleRow title="Auto-Renew Campaigns" description="Automatically extend campaigns when they expire" checked={autoRenew} onChange={setAutoRenew} />
          <ToggleRow title="Dark Mode" description="Change UI to dark mode" checked={false} disabled />
        </div>
      </SectionCard>
      <SectionCard title="Data & Privacy" subtitle="Manage your data export and account deletion">
        <div className="v2-settings-privacy-list">
          <button className="is-export" type="button" onClick={exportData}>
            <span className="v2-settings-action-icon"><img src={assets.export} alt="" /></span><span className="v2-settings-action-copy"><strong>Export My Data</strong><small>Download a copy of your account data</small></span><img className="v2-settings-action-chevron" src={assets.actionChevron} alt="" />
          </button>
          <button className="is-delete" type="button" onClick={onDelete}>
            <span className="v2-settings-action-icon"><img src={assets.trash} alt="" /></span><span className="v2-settings-action-copy"><strong>Delete Account</strong><small>Permanently remove your account and all data</small></span><img className="v2-settings-action-chevron" src={assets.actionChevron} alt="" />
          </button>
        </div>
      </SectionCard>
      <SettingsActions />
    </div>
  );
}

function SettingsActions() {
  return <div className="v2-settings-actions"><Button variant="secondary">Cancel</Button><Button>Save Changes</Button></div>;
}

function DeleteModal({ open, onClose }) {
  if (!open) return null;
  return (
    <div className="v2-settings-modal" role="dialog" aria-modal="true" aria-labelledby="delete-title">
      <button className="v2-settings-modal-backdrop" type="button" onClick={onClose} aria-label="Close delete account dialog" />
      <div className="v2-settings-modal-card">
        <div className="v2-settings-modal-content">
          <img src={assets.deleteIllustration} alt="" />
          <div><h2 id="delete-title">Delete Account?</h2><p>Are you sure you want to delete this account?<br />This action cannot be undone.</p></div>
        </div>
        <div className="v2-settings-modal-actions"><Button variant="secondary" onClick={onClose}>Cancel</Button><button className="v2-settings-delete-confirm" type="button" onClick={onClose}>Delete</button></div>
      </div>
    </div>
  );
}

export default function V2Settings() {
  const params = useMemo(() => new URLSearchParams(window.location.search), []);
  const initialTab = tabs.some((tab) => tab.id === params.get("tab")) ? params.get("tab") : "profile";
  const [activeTab, setActiveTab] = useState(initialTab);
  const [deleteOpen, setDeleteOpen] = useState(params.get("state") === "delete");

  const changeTab = (tab) => {
    setActiveTab(tab);
    const next = new URL(window.location.href);
    next.searchParams.set("tab", tab);
    next.searchParams.delete("state");
    window.history.replaceState({}, "", `${next.pathname}${next.search}`);
  };

  const openDelete = () => {
    setDeleteOpen(true);
    const next = new URL(window.location.href);
    next.searchParams.set("tab", "preferences");
    next.searchParams.set("state", "delete");
    window.history.replaceState({}, "", `${next.pathname}${next.search}`);
  };
  const closeDelete = () => {
    setDeleteOpen(false);
    const next = new URL(window.location.href);
    next.searchParams.delete("state");
    window.history.replaceState({}, "", `${next.pathname}${next.search}`);
  };

  return (
    <main className={`ni-v2 v2-settings-page is-${activeTab}`}>
      <AppSidebar />
      <div className="v2-settings-main">
        <TopHeader />
        <div className="v2-settings-title-row">
          <div><h1>Settings</h1><p>Manage your account, security, and preferences</p></div>
          <button className="v2-settings-date" type="button">Last 30 days <img src={assets.dateChevron} alt="" /></button>
        </div>
        <div className="v2-settings-workspace">
          <SettingsTabs activeTab={activeTab} onChange={changeTab} />
          {activeTab === "profile" && <ProfileSettings />}
          {activeTab === "notifications" && <NotificationSettings />}
          {activeTab === "preferences" && <PreferenceSettings onDelete={openDelete} />}
        </div>
      </div>
      <DeleteModal open={deleteOpen} onClose={closeDelete} />
    </main>
  );
}
