import React, { useEffect, useRef, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../../api.js";
import "./v2-auth.css";

export default function V2OAuthCallback() {
  const code = new URLSearchParams(window.location.search).get("oauth_code") || "";
  const started = useRef(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (started.current) return;
    started.current = true;
    if (!code) {
      setError("Login did not complete because the authorization code is missing.");
      return;
    }
    api.exchangeOAuthCode(code)
      .then(() => window.location.assign("/dashboard"))
      .catch((err) => setError(err.message || "Social sign-in failed. Please try again."));
  }, [code, navigate]);

  return (
    <main className="ni-v2 v2-auth-page">
      <section className="v2-auth-card">
        <div className="v2-auth-brand">
          <img src="/assets/nano-v2/brand-mark.svg" alt="" />
          <span>The Nano Influencers</span>
        </div>
        {error ? (
          <>
            <h1>Login failed</h1>
            <p className="v2-auth-error" role="alert">{error}</p>
            <Link className="v2-auth-submit" to="/login">Back to login</Link>
          </>
        ) : (
          <>
            <h1>Completing sign-in</h1>
            <p className="v2-auth-heading-copy">Please wait while we securely finish your login.</p>
          </>
        )}
      </section>
    </main>
  );
}
