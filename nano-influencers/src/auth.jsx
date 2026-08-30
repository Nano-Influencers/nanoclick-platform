import React, { createContext, useContext, useEffect, useState } from "react";
import { Navigate, useNavigate, useSearchParams, Link } from "react-router-dom";
import { api, ApiError } from "./api.js";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const refreshUser = async () => {
    if (!api.isLoggedIn()) {
      setUser(null);
      setLoading(false);
      return;
    }
    try {
      const me = await api.me();
      setUser(me);
    } catch {
      api.logout();
      setUser(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refreshUser();
    // A request elsewhere in the app got a 401 that a silent refresh
    // couldn't fix — drop back to logged-out state everywhere.
    const onExpire = () => setUser(null);
    window.addEventListener("nano-auth-expired", onExpire);
    return () => window.removeEventListener("nano-auth-expired", onExpire);
  }, []);

  const login = async (email, password) => {
    await api.login(email, password);
    await refreshUser();
  };

  const register = async (fields) => {
    await api.register(fields);
    await login(fields.email, fields.password);
  };

  const logout = () => {
    api.logout();
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, register, logout, refreshUser }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}

export function ProtectedRoute({ children }) {
  const { user, loading } = useAuth();
  if (loading) return <AuthSplash />;
  if (!user) return <Navigate to="/login" replace />;
  return children;
}

function AuthSplash() {
  return (
    <div className="auth-page">
      <div className="auth-card"><p className="auth-loading">Loading…</p></div>
    </div>
  );
}

export function LoginPage() {
  const { login, user } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  if (user) return <Navigate to="/app" replace />;

  const submit = async (e) => {
    e.preventDefault();
    setError(""); setBusy(true);
    try {
      await login(email, password);
      navigate("/app");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Something went wrong. Please try again.");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-brand"><span className="l-dot" />The Nano Influencers</div>
        <h1>Welcome back</h1>
        <p className="auth-sub">Log in to manage your campaigns.</p>
        {error && <div className="auth-error">{error}</div>}
        <form onSubmit={submit}>
          <label>Email
            <input className="field" type="email" required value={email} onChange={(e) => setEmail(e.target.value)} placeholder="you@example.com" />
          </label>
          <label>Password
            <input className="field" type="password" required value={password} onChange={(e) => setPassword(e.target.value)} placeholder="••••••••" />
          </label>
          <button className="primary-btn" disabled={busy} type="submit">{busy ? "Logging in…" : "Log In"}</button>
        </form>
        <OAuthButtons />
        <p className="auth-switch">New here? <Link to="/register">Create an advertiser account</Link></p>
      </div>
    </div>
  );
}

export function RegisterPage() {
  const { register, user } = useAuth();
  const navigate = useNavigate();
  const [fields, setFields] = useState({ full_name: "", email: "", password: "", referral_code: "" });
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  if (user) return <Navigate to="/app" replace />;

  const set = (k) => (e) => setFields((f) => ({ ...f, [k]: e.target.value }));

  const submit = async (e) => {
    e.preventDefault();
    setError(""); setBusy(true);
    try {
      await register(fields);
      navigate("/app");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Something went wrong. Please try again.");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-brand"><span className="l-dot" />The Nano Influencers</div>
        <h1>Create your account</h1>
        <p className="auth-sub">Set up campaigns and reach real people in minutes.</p>
        {error && <div className="auth-error">{error}</div>}
        <form onSubmit={submit}>
          <label>Full name
            <input className="field" required value={fields.full_name} onChange={set("full_name")} placeholder="Jane Doe" />
          </label>
          <label>Email
            <input className="field" type="email" required value={fields.email} onChange={set("email")} placeholder="you@example.com" />
          </label>
          <label>Password
            <input className="field" type="password" required minLength={8} value={fields.password} onChange={set("password")} placeholder="At least 8 characters" />
          </label>
          <label>Referral code <small className="auth-optional">(optional)</small>
            <input className="field" value={fields.referral_code} onChange={set("referral_code")} placeholder="e.g. ABC12345" />
          </label>
          <button className="primary-btn" disabled={busy} type="submit">{busy ? "Creating account…" : "Create Account"}</button>
        </form>
        <OAuthButtons />
        <p className="auth-switch">Already have an account? <Link to="/login">Log in</Link></p>
      </div>
    </div>
  );
}

function OAuthButtons() {
  return (
    <div className="auth-oauth">
      <div className="auth-divider"><span>or continue with</span></div>
      <a className="oauth-btn" href={api.oauthUrl("google")}>Google</a>
      <a className="oauth-btn" href={api.oauthUrl("facebook")}>Facebook</a>
    </div>
  );
}

// The backend's /auth/{provider}/callback redirects here (see
// OAUTH_WEB_REDIRECT_URL) with tokens in the query string once a web OAuth
// login completes.
export function OAuthCallbackPage() {
  const [params] = useSearchParams();
  const navigate = useNavigate();
  const { refreshUser } = useAuth();
  const [error, setError] = useState("");

  useEffect(() => {
    const access = params.get("access_token");
    const refresh = params.get("refresh_token");
    if (!access || !refresh) {
      setError("Login did not complete — missing tokens from the provider redirect.");
      return;
    }
    api.setSessionTokens(access, refresh);
    refreshUser().then(() => navigate("/app", { replace: true }));
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <div className="auth-page">
      <div className="auth-card">
        {error ? (
          <>
            <h1>Login failed</h1>
            <p className="auth-error">{error}</p>
            <Link className="primary-btn" style={{ display: "block", textAlign: "center", textDecoration: "none" }} to="/login">Back to login</Link>
          </>
        ) : (
          <p className="auth-loading">Finishing sign-in…</p>
        )}
      </div>
    </div>
  );
}
