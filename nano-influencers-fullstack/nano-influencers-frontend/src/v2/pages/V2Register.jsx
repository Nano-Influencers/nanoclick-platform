import React, { useState } from "react";
import "./v2-register.css";

const assets = {
  brandIcon: "/assets/nano-v2/brand-mark.svg",
  google: "/assets/nano-v2-app/auth-google.svg",
  facebook: "/assets/nano-v2-app/auth-facebook.svg",
  eyeSlash: "/assets/nano-v2-app/auth-eye-slash.svg",
};

function Brand() {
  return (
    <a className="v2-register-brand" href="/" aria-label="The Nano Influencers home">
      <img src={assets.brandIcon} alt="" />
      <span>The Nano Influencers</span>
    </a>
  );
}

function OAuthButton({ provider, icon }) {
  return (
    <button className="v2-register-oauth-button" type="button" onClick={() => { window.location.href = "/dashboard"; }}>
      <img src={icon} alt="" />
      <span>Continue with {provider}</span>
    </button>
  );
}

function RegisterField({ label, placeholder, type = "text", autoComplete, password = false, name }) {
  const [visible, setVisible] = useState(false);
  const inputType = password ? (visible ? "text" : "password") : type;

  return (
    <label className="v2-register-field">
      <span>{label}</span>
      <span className="v2-register-input-shell">
        <input required name={name} type={inputType} placeholder={placeholder} autoComplete={autoComplete} />
        {password && (
          <button
            className="v2-register-eye"
            type="button"
            aria-label={visible ? "Hide password" : "Show password"}
            onClick={() => setVisible(value => !value)}
          >
            <img src={assets.eyeSlash} alt="" />
          </button>
        )}
      </span>
    </label>
  );
}

export default function V2Register() {
  const [accepted, setAccepted] = useState(false);

  const submit = (event) => {
    event.preventDefault();
    if (!accepted) return;
    const formData = new FormData(event.currentTarget);
    const email = String(formData.get("email") || "adaeze@gmail.com").trim();
    window.location.href = `/verify-email?email=${encodeURIComponent(email)}`;
  };

  return (
    <main className="ni-v2 v2-register-page">
      <div className="v2-register-container">
        <header className="v2-register-header">
          <Brand />
          <div className="v2-register-heading-copy">
            <h1>Create your account</h1>
            <p>Start growing your business today — free forever.</p>
          </div>
        </header>

        <div className="v2-register-oauth">
          <OAuthButton provider="Google" icon={assets.google} />
          <OAuthButton provider="Facebook" icon={assets.facebook} />
        </div>

        <div className="v2-register-divider" aria-hidden="true">
          <i />
          <span>or sign up with email</span>
          <i />
        </div>

        <form className="v2-register-form" onSubmit={submit}>
          <div className="v2-register-name-row">
            <RegisterField name="first_name" label="First Name" placeholder="First Name" autoComplete="given-name" />
            <RegisterField name="last_name" label="Last Name" placeholder="Last Name" autoComplete="family-name" />
          </div>

          <RegisterField name="email" label="Email" placeholder="you@example.com" type="email" autoComplete="email" />
          <RegisterField name="password" label="Password" placeholder="Min. 8 characters" autoComplete="new-password" password />
          <RegisterField name="confirm_password" label="Confirm Password" placeholder="Re-enter your password" autoComplete="new-password" password />

          <label className="v2-register-terms">
            <input required type="checkbox" checked={accepted} onChange={(event) => setAccepted(event.target.checked)} />
            <span className="v2-register-checkbox" aria-hidden="true">{accepted ? "✓" : ""}</span>
            <span>
              I agree to the <a href="#privacy">Privacy Policy</a> and <a href="#terms">Terms of Service</a>
            </span>
          </label>

          <button className="v2-register-submit" type="submit">Create Account</button>
        </form>

        <p className="v2-register-signin">
          Already have an account? <a href="/login">Sign in</a>
        </p>
      </div>
    </main>
  );
}
