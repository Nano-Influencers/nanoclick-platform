import React, { useEffect, useMemo, useRef, useState } from "react";
import "./v2-verification.css";

const assets = {
  brandIcon: "/assets/nano-v2/brand-mark.svg",
  countryArrow: "/assets/nano-v2-app/auth-arrow-down.svg",
  confirmation: "/assets/nano-v2-app/auth-confirmation.png",
};

function Brand() {
  return (
    <a className="v2-verification-brand" href="/" aria-label="The Nano Influencers home">
      <img src={assets.brandIcon} alt="" />
      <span>The Nano Influencers</span>
    </a>
  );
}

function useResendCountdown(initialSeconds = 40) {
  const [seconds, setSeconds] = useState(initialSeconds);

  useEffect(() => {
    if (seconds <= 0) return undefined;
    const timer = window.setTimeout(() => setSeconds((value) => Math.max(0, value - 1)), 1000);
    return () => window.clearTimeout(timer);
  }, [seconds]);

  return [seconds, () => setSeconds(initialSeconds)];
}

function CodeInputs({ value, onChange, error = false }) {
  const refs = useRef([]);
  const digits = useMemo(() => Array.from({ length: 6 }, (_, index) => value[index] || ""), [value]);

  const setDigit = (index, rawValue) => {
    const digit = rawValue.replace(/\D/g, "").slice(-1);
    const next = [...digits];
    next[index] = digit;
    onChange(next.join(""));
    if (digit && index < 5) refs.current[index + 1]?.focus();
  };

  const onKeyDown = (index, event) => {
    if (event.key === "Backspace" && !digits[index] && index > 0) {
      refs.current[index - 1]?.focus();
    }
    if (event.key === "ArrowLeft" && index > 0) refs.current[index - 1]?.focus();
    if (event.key === "ArrowRight" && index < 5) refs.current[index + 1]?.focus();
  };

  const onPaste = (event) => {
    const pasted = event.clipboardData.getData("text").replace(/\D/g, "").slice(0, 6);
    if (!pasted) return;
    event.preventDefault();
    onChange(pasted);
    refs.current[Math.min(pasted.length, 6) - 1]?.focus();
  };

  return (
    <div className="v2-code-row" onPaste={onPaste}>
      {digits.map((digit, index) => (
        <input
          key={index}
          ref={(node) => { refs.current[index] = node; }}
          className={`v2-code-input${digit ? " is-filled" : ""}${error ? " is-error" : ""}`}
          aria-label={`Verification code digit ${index + 1}`}
          inputMode="numeric"
          autoComplete={index === 0 ? "one-time-code" : "off"}
          maxLength={1}
          value={digit}
          placeholder="-"
          onChange={(event) => setDigit(index, event.target.value)}
          onKeyDown={(event) => onKeyDown(index, event)}
        />
      ))}
    </div>
  );
}

function VerificationButtons({ primaryLabel, secondaryLabel, onPrimary, onSecondary }) {
  return (
    <div className="v2-verification-buttons">
      <button className="v2-verification-button is-primary" type="button" onClick={onPrimary}>{primaryLabel}</button>
      <button className="v2-verification-button is-secondary" type="button" onClick={onSecondary}>{secondaryLabel}</button>
    </div>
  );
}

function ResendRow({ seconds, onResend }) {
  return (
    <div className="v2-verification-resend">
      <span>Didn't receive a code?</span>
      {seconds > 0 ? (
        <span className="v2-verification-resend-wait">Resend in&nbsp;{seconds}s</span>
      ) : (
        <button type="button" onClick={onResend}>Resend</button>
      )}
    </div>
  );
}

export function EmailVerificationPage() {
  const params = new URLSearchParams(window.location.search);
  const previewState = params.get("state") || "";
  const email = params.get("email") || "adaeze@gmail.com";
  const [code, setCode] = useState(() => previewState === "error" ? "652027" : previewState === "filled" ? "65202" : "");
  const [error, setError] = useState(previewState === "error" ? "invalid verification code" : "");
  const [seconds, restartCountdown] = useResendCountdown(40);

  const verify = () => {
    if (code.length < 6) return;
    if (code === "123456") {
      window.location.href = "/verify-whatsapp";
      return;
    }
    setError("invalid verification code");
  };

  const resend = () => {
    setCode("");
    setError("");
    restartCountdown();
  };

  return (
    <main className="ni-v2 v2-verification-page">
      <section className="v2-verification-card">
        <header className="v2-verification-header">
          <Brand />
          <div className="v2-verification-copy">
            <h1>Enter verification code</h1>
            <p>We sent a 6-digit code to <strong>{email}</strong></p>
          </div>
        </header>

        <div className="v2-verification-code-form">
          <div className="v2-code-block">
            <CodeInputs value={code} onChange={(value) => { setCode(value); setError(""); }} error={Boolean(error)} />
            {error && <p className="v2-code-error">{error}</p>}
          </div>
          <VerificationButtons
            primaryLabel="Verify Code"
            secondaryLabel="Change Email"
            onPrimary={verify}
            onSecondary={() => { window.location.href = "/register"; }}
          />
        </div>

        <ResendRow seconds={seconds} onResend={resend} />
      </section>
    </main>
  );
}

export function WhatsAppNumberPage() {
  const params = new URLSearchParams(window.location.search);
  const [number, setNumber] = useState(() => params.get("state") === "filled" ? "+234 902 122 2026" : "");

  const submit = (event) => {
    event.preventDefault();
    const value = number.trim();
    if (!value) return;
    window.location.href = `/verify-whatsapp/code?number=${encodeURIComponent(value)}`;
  };

  return (
    <main className="ni-v2 v2-verification-page">
      <section className="v2-verification-card v2-whatsapp-number-card">
        <header className="v2-verification-header is-tall">
          <Brand />
          <div className="v2-verification-copy">
            <h1>One last step</h1>
            <p>Verify your WhatsApp number to secure your account and receive important updates.</p>
          </div>
        </header>

        <form className="v2-whatsapp-form" onSubmit={submit}>
          <label className="v2-whatsapp-field">
            <span>WhatsApp Number</span>
            <span className="v2-whatsapp-input-row">
              <button className="v2-country-select" type="button" aria-label="Country selector">
                <span>NG</span>
                <img src={assets.countryArrow} alt="" />
              </button>
              <input
                required
                type="tel"
                value={number}
                onChange={(event) => setNumber(event.target.value)}
                placeholder="234 701 234 5678"
                autoComplete="tel"
              />
            </span>
          </label>
          <p className="v2-whatsapp-private">Your number is private and only used for account verification.</p>
          <button className="v2-verification-button is-primary" type="submit">Send Verification Code</button>
        </form>

        <a className="v2-back-link" href="/register">←&nbsp; Back to sign up</a>
      </section>
    </main>
  );
}

export function WhatsAppCodePage() {
  const params = new URLSearchParams(window.location.search);
  const previewState = params.get("state") || "";
  const number = params.get("number") || "+234 902 122 2026";
  const [code, setCode] = useState(() => previewState === "error" ? "652027" : previewState === "filled" ? "65202" : "");
  const [error, setError] = useState(previewState === "error" ? "invalid verification code" : "");
  const [seconds, restartCountdown] = useResendCountdown(40);

  const verify = () => {
    if (code.length < 6) return;
    if (code === "123456") {
      window.location.href = "/verification-success";
      return;
    }
    setError("invalid verification code");
  };

  const resend = () => {
    setCode("");
    setError("");
    restartCountdown();
  };

  return (
    <main className="ni-v2 v2-verification-page">
      <section className="v2-verification-card">
        <header className="v2-verification-header">
          <Brand />
          <div className="v2-verification-copy">
            <h1>Check your WhatsApp</h1>
            <p>We sent a 6-digit code to <strong>{number}</strong></p>
          </div>
        </header>

        <div className="v2-verification-code-form">
          <div className="v2-code-block">
            <CodeInputs value={code} onChange={(value) => { setCode(value); setError(""); }} error={Boolean(error)} />
            {error && <p className="v2-code-error">{error}</p>}
          </div>
          <VerificationButtons
            primaryLabel="Verify Code"
            secondaryLabel="Change Number"
            onPrimary={verify}
            onSecondary={() => { window.location.href = "/verify-whatsapp"; }}
          />
        </div>

        <ResendRow seconds={seconds} onResend={resend} />
      </section>
    </main>
  );
}

export function VerificationSuccessPage() {
  return (
    <main className="ni-v2 v2-verification-page v2-verification-success-page">
      <section className="v2-verification-card v2-verification-success-card">
        <div className="v2-success-header">
          <img className="v2-success-image" src={assets.confirmation} alt="" />
          <div className="v2-success-copy">
            <h1>Account created!</h1>
            <p>Your WhatsApp has been verified.<br />Welcome to The Nano Influencers — you're all set to grow.</p>
          </div>
        </div>
        <a className="v2-verification-button is-primary v2-success-button" href="/app">Go to Dashboard</a>
      </section>
    </main>
  );
}
