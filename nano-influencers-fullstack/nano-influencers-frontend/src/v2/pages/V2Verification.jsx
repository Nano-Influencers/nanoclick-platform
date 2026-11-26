import React, { useEffect, useMemo, useRef, useState } from "react";
import "./v2-verification.css";
import { api } from "../../api.js";

const assets = {
  brandIcon: "/assets/nano-v2/brand-mark.svg",
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
  const email = params.get("email") || "";
  const deliveryFailed = params.get("delivery") === "failed";
  const [code, setCode] = useState(() => previewState === "error" ? "652027" : previewState === "filled" ? "65202" : "");
  const [error, setError] = useState(previewState === "error" ? "invalid verification code" : "");
  const [seconds, restartCountdown] = useResendCountdown(40);
  const [busy, setBusy] = useState(false);

  const verify = async () => {
    if (code.length !== 6 || busy) return;
    if (!email) { setError("Email address is missing. Please register again."); return; }
    setBusy(true);
    setError("");
    try {
      await api.verifyOTP(email, code);
      window.location.href = "/login?verified=1";
    } catch (err) {
      setError(err.message || "Invalid or expired verification code");
    } finally {
      setBusy(false);
    }
  };

  const resend = async () => {
    if (!email || busy) return;
    setBusy(true);
    setError("");
    try {
      await api.resendOTP(email);
      setCode("");
      restartCountdown();
    } catch (err) {
      setError(err.message || "Could not resend verification code");
    } finally {
      setBusy(false);
    }
  };

  return (
    <main className="ni-v2 v2-verification-page">
      <section className="v2-verification-card">
        <header className="v2-verification-header">
          <Brand />
          <div className="v2-verification-copy">
            <h1>Enter verification code</h1>
            <p>We sent a 6-digit code to <strong>{email}</strong></p>
            {deliveryFailed && <p className="v2-code-error" role="status">We could not deliver the code yet. Your registration is saved temporarily; use Resend after email delivery is available.</p>}
          </div>
        </header>

        <div className="v2-verification-code-form">
          <div className="v2-code-block">
            <CodeInputs value={code} onChange={(value) => { setCode(value); setError(""); }} error={Boolean(error)} />
            {error && <p className="v2-code-error">{error}</p>}
          </div>
          <VerificationButtons
            primaryLabel={busy ? "Please wait..." : "Verify Code"}
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

