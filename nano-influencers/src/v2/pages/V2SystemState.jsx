import React, { useEffect, useState } from "react";
import "./v2-system-state.css";

const stateCopy = {
  "not-found": {
    eyebrow: "404",
    symbol: "404",
    title: "Page not found",
    description: "The page you’re looking for doesn’t exist, may have moved, or isn’t available yet.",
    primary: "Go to Dashboard",
    secondary: "Go Home",
  },
  error: {
    eyebrow: "Something broke",
    symbol: "!",
    title: "Something went wrong",
    description: "We couldn’t load this page correctly. Try again, or return to the dashboard.",
    primary: "Try Again",
    secondary: "Go to Dashboard",
  },
  offline: {
    eyebrow: "Connection lost",
    symbol: "⌁",
    title: "You’re offline",
    description: "Check your internet connection and try again. This page will recover automatically when you reconnect.",
    primary: "Try Again",
    secondary: "Go Home",
  },
};

function go(path) {
  window.location.assign(path);
}

export function V2SystemState({ type = "not-found", title, description }) {
  const copy = stateCopy[type] || stateCopy["not-found"];

  const primaryAction = () => {
    if (type === "error" || type === "offline") {
      window.location.reload();
      return;
    }
    go("/dashboard");
  };

  const secondaryAction = () => {
    if (type === "error") go("/dashboard");
    else go("/");
  };

  return (
    <main className={`ni-v2 v2-system-page is-${type}`}>
      <section className="v2-system-card" aria-labelledby="v2-system-title">
        <a className="v2-system-brand" href="/" aria-label="The Nano Influencers home">
          <span className="v2-system-brand-mark"><i /></span>
          <strong>The Nano Influencers</strong>
        </a>

        <div className="v2-system-visual" aria-hidden="true">
          <span>{copy.symbol}</span>
          <i className="v2-system-orbit is-a" />
          <i className="v2-system-orbit is-b" />
        </div>

        <div className="v2-system-copy">
          <span className="v2-system-eyebrow">{copy.eyebrow}</span>
          <h1 id="v2-system-title">{title || copy.title}</h1>
          <p>{description || copy.description}</p>
        </div>

        <div className="v2-system-actions">
          <button className="v2-system-primary" type="button" onClick={primaryAction}>{copy.primary}</button>
          <button className="v2-system-secondary" type="button" onClick={secondaryAction}>{copy.secondary}</button>
        </div>

        {type === "offline" && (
          <p className="v2-system-status"><i /> Waiting for a network connection</p>
        )}
      </section>
    </main>
  );
}

export class V2ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { failed: false };
  }

  static getDerivedStateFromError() {
    return { failed: true };
  }

  componentDidCatch(error, info) {
    console.error("Nano Influencers V2 render error", error, info);
  }

  render() {
    if (this.state.failed) return <V2SystemState type="error" />;
    return this.props.children;
  }
}

export function V2ConnectivityGate({ children }) {
  const [online, setOnline] = useState(() => (
    typeof navigator === "undefined" ? true : navigator.onLine
  ));

  useEffect(() => {
    const markOnline = () => setOnline(true);
    const markOffline = () => setOnline(false);
    window.addEventListener("online", markOnline);
    window.addEventListener("offline", markOffline);
    return () => {
      window.removeEventListener("online", markOnline);
      window.removeEventListener("offline", markOffline);
    };
  }, []);

  if (!online) return <V2SystemState type="offline" />;
  return children;
}
