import React, { useEffect, useMemo, useRef, useState } from "react";
import { Link } from "react-router-dom";
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
  const submit = (event) => {
    event.preventDefault();
    if (!email.trim()) return;
    go(`/forgot-password/code?email=${encodeURIComponent(email.trim())}`);
  };
  return (
    <ForgotShell>
      <Heading title="Forgot password?">Enter your email address and we&apos;ll send you a verification code.</Heading>
      <form className="v2-forgot-form" onSubmit={submit}>
        <label className="v2-forgot-field"><strong>Email</strong><input required type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="you@example.com" autoComplete="email" /></label>
        <button className="v2-forgot-primary" type="submit">Send verification code</button>
      </form>
      <p className="v2-forgot-switch"><span>Remember your password?</span><Link to="/login">Sign in</Link></p>
    </ForgotShell>
  );
}

export function V2ForgotPasswordCode() {
  const params = new URLSearchParams(window.location.search);
  const email = params.get("email") || "adaeze@gmail.com";
  const state = params.get("state") || "";
  const [code, setCode] = useState(state === "error" ? "652027" : state === "filled" ? "65202" : "");
  const [error, setError] = useState(state === "error" ? "Invalid verification code" : "");
  const [seconds, restart] = useCountdown();
  const verify = () => {
    if (code.length !== 6) return;
    if (code !== "123456") { setError("Invalid verification code"); return; }
    go(`/forgot-password/reset?email=${encodeURIComponent(email)}`);
  };
  const resend = () => { setCode(""); setError(""); restart(); };
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
  const previewError = params.get("state") === "error";
  const [password, setPassword] = useState(previewError ? "password123" : "");
  const [confirm, setConfirm] = useState(previewError ? "different123" : "");
  const [error, setError] = useState(previewError ? "Passwords do not match" : "");
  const [seconds, restart] = useCountdown();
  const submit = (event) => {
    event.preventDefault();
    if (password.length < 8) { setError("Password must be at least 8 characters"); return; }
    if (password !== confirm) { setError("Passwords do not match"); return; }
    go("/forgot-password/success");
  };
  return (
    <ForgotShell>
      <Heading title="Create new password">Your identity has been verified. Set a new secure password.</Heading>
      <form className="v2-forgot-form" onSubmit={submit}>
        <PasswordField label="New Password" value={password} onChange={(e) => { setPassword(e.target.value); setError(""); }} />
        <PasswordField label="Confirm New Password" value={confirm} onChange={(e) => { setConfirm(e.target.value); setError(""); }} />
        {error && <p className="v2-forgot-error">{error}</p>}
        <button className="v2-forgot-primary" type="submit">Reset Password</button>
      </form>
      <Resend seconds={seconds} onResend={restart} />
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
