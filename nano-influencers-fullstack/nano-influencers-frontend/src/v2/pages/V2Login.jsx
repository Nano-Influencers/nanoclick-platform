import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { api } from "../../api.js";
import "./v2-auth.css";

const assets = {
  brand: "/assets/nano-v2/brand-mark.svg",
  google: "/assets/nano-v2-app/auth-google.svg",
  facebook: "/assets/nano-v2-app/auth-facebook.svg",
  eyeSlash: "/assets/nano-v2-app/auth-eye-slash.svg",
};

function AuthBrand() {
  return (
    <Link className="v2-auth-brand" to="/" aria-label="The Nano Influencers home">
      <img src={assets.brand} alt="" />
      <span>The Nano Influencers</span>
    </Link>
  );
}

function OAuthButton({ icon, children, provider }) {
  return (
    <button className="v2-auth-oauth-button" type="button" onClick={() => { window.location.href = api.oauthUrl(provider); }}>
      <img src={icon} alt="" />
      <span>{children}</span>
    </button>
  );
}

export default function V2Login() {
  const navigate = useNavigate();
  const [passwordVisible, setPasswordVisible] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  const submit = async (event) => {
    event.preventDefault();
    setError("");
    setBusy(true);
    try {
      await api.login(email.trim(), password);
      navigate("/dashboard", { replace: true });
    } catch (err) {
      setError(err?.message || "Unable to sign in. Please check your details and try again.");
    } finally {
      setBusy(false);
    }
  };

  return (
    <main className="ni-v2 v2-auth-page v2-auth-login">
      <section className="v2-auth-card" aria-labelledby="v2-login-title">
        <header className="v2-auth-header">
          <AuthBrand />
          <div className="v2-auth-heading-copy">
            <h1 id="v2-login-title">Welcome back</h1>
            <p>Sign in to your access your account.</p>
          </div>
        </header>

        <div className="v2-auth-oauth">
          <OAuthButton icon={assets.google} provider="google">Continue with Google</OAuthButton>
          <OAuthButton icon={assets.facebook} provider="facebook">Continue with Facebook</OAuthButton>
        </div>

        <div className="v2-auth-divider" aria-hidden="true">
          <i />
          <span>or sign in with email</span>
          <i />
        </div>

        {error && <p className="v2-auth-error" role="alert">{error}</p>}
        <form className="v2-auth-form" onSubmit={submit}>
          <label className="v2-auth-field">
            <span className="v2-auth-field-label">Email</span>
            <span className="v2-auth-input-shell">
              <input type="email" placeholder="you@example.com" autoComplete="email" required value={email} onChange={(event) => setEmail(event.target.value)} />
            </span>
          </label>

          <label className="v2-auth-field">
            <span className="v2-auth-password-row">
              <span>Password</span>
              <Link to="/forgot-password">Forgot password?</Link>
            </span>
            <span className="v2-auth-input-shell">
              <input
                type={passwordVisible ? "text" : "password"}
                placeholder="Min. 8 characters"
                autoComplete="current-password"
                required
                value={password}
                onChange={(event) => setPassword(event.target.value)}
              />
              <button
                className="v2-auth-eye"
                type="button"
                aria-label={passwordVisible ? "Hide password" : "Show password"}
                onClick={() => setPasswordVisible(value => !value)}
              >
                <img src={assets.eyeSlash} alt="" />
              </button>
            </span>
          </label>

          <button className="v2-auth-submit" type="submit" disabled={busy}>{busy ? "Signing in…" : "Sign in"}</button>
        </form>

        <p className="v2-auth-switch">
          <span>Don&apos;t have an account?</span>
          <Link to="/register">Sign up</Link>
        </p>
      </section>
    </main>
  );
}
