import React, { useEffect, useMemo, useRef, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../../api";
import "./v2-auth.css";
import "./v2-forgot-password.css";

const assets = {
  brand: "/assets/nano-v2/brand-mark.svg",
  eyeSlash: "/assets/nano-v2-app/auth-eye-slash.svg",
  confirmation: "/assets/nano-v2-app/auth-confirmation.png",
};

function go(path) {
  window.location.assign(path);
}

function Brand() {
  return (
    <Link className="v2-forgot-brand" to="/" aria-label="The Nano Influencers home">
      <img src={assets.brand} alt="" />
      <span>The Nano Influencers</span>
    </Link>
  );
}

function ForgotShell({ children, className = "" }) {
  return <main className={`ni-v2 v2-forgot-page ${className}`.trim()}><section className="v2-forgot-card">{children}</section></main>;
}

function Heading({ title, children }) {
  return <header className="v2-forgot-header"><Brand /><div><h1>{title}</h1><p>{children}</p></div></header>;
}

function useCountdown(initial = 40) {
  const [seconds, setSeconds] = useState(initial);
  useEffect(() => {
    if (seconds <= 0) return undefined;
    const timer = window.setTimeout(() => setSeconds((value) => value - 1), 1000);
    return () => window.clearTimeout(timer);
  }, [seconds]);
  return [seconds, () => setSeconds(initial)];
}

function Resend({ seconds, onResend }) {
  return <p className="v2-forgot-resend"><span>Didn&apos;t receive a code?</span>{seconds > 0 ? <span>Resend in&nbsp;{seconds}s</span> : <button type="button" onClick={onResend}>Resend</button>}</p>;
}

function CodeInputs({ value, onChange, error }) {
  const refs = useRef([]);
  const digits = useMemo(() => Array.from({ length: 6 }, (_, i) => value[i] || ""), [value]);
  const setDigit = (index, raw) => {
    const digit = raw.replace(/\D/g, "").slice(-1);
    const next = [...digits];
    next[index] = digit;
    onChange(next.join(""));
    if (digit && index < 5) refs.current[index + 1]?.focus();
  };
  const paste = (event) => {
    const code = event.clipboardData.getData("text").replace(/\D/g, "").slice(0, 6);
    if (!code) return;
    event.preventDefault();
    onChange(code);
    refs.current[Math.max(0, code.length - 1)]?.focus();
  };
  return (
    <div className="v2-forgot-code-row" onPaste={paste}>
      {digits.map((digit, index) => <input key={index} ref={(node) => { refs.current[index] = node; }} className={error ? "is-error" : ""} inputMode="numeric" maxLength={1} value={digit} placeholder="-" aria-label={`Reset code digit ${index + 1}`} onChange={(e) => setDigit(index, e.target.value)} onKeyDown={(e) => { if (e.key === "Backspace" && !digit && index > 0) refs.current[index - 1]?.focus(); }} />)}
    </div>
  );
}

export default function V2ForgotPassword() {
  const [email, setEmail] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const submit = async (event) => {
    event.preventDefault();
    if (!email.trim()) return;
    setBusy(true); setError("");
    try { await api.forgotPassword(email.trim()); go(`/forgot-password/code?email=${encodeURIComponent(email.trim())}`); }
    catch (err) { setError(err.message || "Unable to send a reset code. Please try again."); }
    finally { setBusy(false); }
  };
  return (
    <ForgotShell>
      <Heading title="Forgot password?">Enter your email address and we&apos;ll send you a verification code.</Heading>
      <form className="v2-forgot-form" onSubmit={submit}>
        <label className="v2-forgot-field"><strong>Email</strong><input required type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="you@example.com" autoComplete="email" /></label>
        {error && <p className="v2-forgot-error">{error}</p>}<button className="v2-forgot-primary" type="submit" disabled={busy}>{busy ? "Sending..." : "Send verification code"}</button>
      </form>
      <p className="v2-forgot-switch"><span>Remember your password?</span><Link to="/login">Sign in</Link></p>
    </ForgotShell>
  );
}

export function V2ForgotPasswordCode() {
  const params = new URLSearchParams(window.location.search);
  const email = params.get("email") || "";
  const state = params.get("state") || "";
  const [code, setCode] = useState("");
  const [error, setError] = useState(state === "error" ? "Invalid verification code" : "");
  const [seconds, restart] = useCountdown();
  const verify = () => {
    if (code.length !== 6) return;
    go(`/forgot-password/reset?email=${encodeURIComponent(email)}&code=${encodeURIComponent(code)}`);
  };
  const resend = async () => { try { await api.forgotPassword(email); setCode(""); setError(""); restart(); } catch (err) { setError(err.message || "Unable to resend code."); } };
  return (
    <ForgotShell>
      <Heading title="Enter verification code">We sent a 6-digit code to <strong>{email}</strong></Heading>
      <div className="v2-forgot-form">
        <div><CodeInputs value={code} error={Boolean(error)} onChange={(next) => { setCode(next); setError(""); }} />{error && <p className="v2-forgot-error">{error}</p>}</div>
        <div className="v2-forgot-actions"><button className="v2-forgot-primary" type="button" onClick={verify}>Verify Code</button><button className="v2-forgot-secondary" type="button" onClick={() => go("/forgot-password")}>Change Email</button></div>
      </div>
      <Resend seconds={seconds} onResend={resend} />
    </ForgotShell>
  );
}

function PasswordField({ label, value, onChange }) {
  const [visible, setVisible] = useState(false);
  return <label className="v2-forgot-field"><strong>{label}</strong><span className="v2-forgot-password"><input required minLength={8} type={visible ? "text" : "password"} value={value} onChange={onChange} placeholder="Min. 8 characters" autoComplete="new-password" /><button type="button" aria-label={visible ? "Hide password" : "Show password"} onClick={() => setVisible((current) => !current)}><img src={assets.eyeSlash} alt="" /></button></span></label>;
}

export function V2ForgotPasswordReset() {
  const params = new URLSearchParams(window.location.search);
  const email = params.get("email") || "";
  const code = params.get("code") || "";
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const [seconds, restart] = useCountdown();
  const resend = async () => {
    if (!email) { setError("Please request a new reset code."); return; }
    try { await api.forgotPassword(email); setError(""); restart(); }
    catch (err) { setError(err.message || "Unable to resend code."); }
  };
  const submit = async (event) => {
    event.preventDefault();
    if (password.length < 8) { setError("Password must be at least 8 characters"); return; }
    if (password !== confirm) { setError("Passwords do not match"); return; }
    if (!code) { setError("Your reset code is missing. Please request a new code."); return; }
    setBusy(true);
    try { await api.resetPassword(code, password); go("/forgot-password/success"); }
    catch (err) { setError(err.message || "Unable to reset password. Request a new code and try again."); }
    finally { setBusy(false); }
  };
  return (
    <ForgotShell>
      <Heading title="Create new password">Enter your new password to complete the reset-code verification.</Heading>
      <form className="v2-forgot-form" onSubmit={submit}>
        <PasswordField label="New Password" value={password} onChange={(e) => { setPassword(e.target.value); setError(""); }} />
        <PasswordField label="Confirm New Password" value={confirm} onChange={(e) => { setConfirm(e.target.value); setError(""); }} />
        {error && <p className="v2-forgot-error">{error}</p>}
        <button className="v2-forgot-primary" type="submit" disabled={busy}>{busy ? "Resetting..." : "Reset Password"}</button>
      </form>
      <Resend seconds={seconds} onResend={resend} />
    </ForgotShell>
  );
}

export function V2ForgotPasswordSuccess() {
  return (
    <ForgotShell className="is-success">
      <div className="v2-forgot-success-head"><img src={assets.confirmation} alt="" /><div><h1>Password reset!</h1><p>Your password has been successfully updated. You can now sign in with your new password.</p></div></div>
      <div className="v2-forgot-actions"><button className="v2-forgot-primary" type="button" onClick={() => go("/login")}>Back to sign in</button><button className="v2-forgot-secondary" type="button" onClick={() => go("/")}>Go to homepage</button></div>
    </ForgotShell>
  );
}
