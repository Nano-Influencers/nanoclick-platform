// Thin fetch wrapper around the NanoClick backend.
// Browser refresh sessions use an HttpOnly cookie; access tokens stay in memory.
const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";
const REQUEST_TIMEOUT_MS = 20000;
let accessToken = null;
let refreshInFlight = null;

function getTokens() { return { access: accessToken, refresh: null }; }
function setTokens(access) { accessToken = access || null; }
function clearTokens() { accessToken = null; }

class ApiError extends Error {
  constructor(message, status) { super(message); this.status = status; }
}

async function parseError(res) {
  try {
    const body = await res.json();
    if (Array.isArray(body.detail)) return body.detail.map((d) => d?.msg || String(d)).join("; ");
    if (typeof body.detail === "string") return body.detail;
    return res.statusText || `Request failed (${res.status})`;
  } catch { return res.statusText || `Request failed (${res.status})`; }
}

function requestId() {
  if (globalThis.crypto?.randomUUID) return globalThis.crypto.randomUUID();
  return `nano-${Date.now()}-${Math.random().toString(36).slice(2)}`;
}

function idempotencyKey() {
  if (globalThis.crypto?.randomUUID) return globalThis.crypto.randomUUID();
  return `nano-${Date.now()}-${Math.random().toString(36).slice(2)}-${Math.random().toString(36).slice(2)}`;
}

async function fetchWithTimeout(url, options = {}) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
  try {
    return await fetch(url, { ...options, signal: controller.signal });
  } catch (error) {
    if (error?.name === "AbortError") throw new ApiError("The request timed out. Please try again.", 408);
    throw error;
  } finally { clearTimeout(timeout); }
}

async function request(path, { method = "GET", body, auth = true, headers: extraHeaders = {}, _retried = false } = {}) {
  const headers = { "Content-Type": "application/json", "X-Request-ID": requestId(), ...extraHeaders };
  if (auth && accessToken) headers["Authorization"] = `Bearer ${accessToken}`;
  let res;
  try { res = await fetchWithTimeout(`${API_URL}${path}`, { method, headers, body: body !== undefined ? JSON.stringify(body) : undefined, credentials: "include" }); }
  catch (error) { if (error instanceof ApiError) throw error; throw new ApiError("Unable to reach the server. Check your connection and try again.", 0); }
  if (res.status === 401 && auth && !_retried && res.headers.get("www-authenticate")?.toLowerCase().includes("bearer")) {
    const refreshed = await tryRefresh();
    if (refreshed.ok) return request(path, { method, body, auth, headers: extraHeaders, _retried: true });
    if (refreshed.reason === "expired" || (refreshed.reason === "anonymous" && accessToken)) {
      clearTokens();
      window.dispatchEvent(new CustomEvent("nano-auth-expired"));
      throw new ApiError("Your session has expired. Please log in again.", 401);
    }
    if (refreshed.reason === "anonymous") {
      throw new ApiError("Please log in to continue.", 401);
    }
    // A network/5xx/429 refresh failure is not proof that the session expired.
    // Keep the access token so a transient outage does not force a logout.
    throw new ApiError("Unable to verify your session right now. Please check your connection and try again.", 503);
  }
  if (!res.ok) throw new ApiError(await parseError(res), res.status);
  if (res.status === 204) return null;
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}

async function performRefresh() {
  try {
    const res = await fetchWithTimeout(`${API_URL}/auth/refresh?platform=web`, { method: "POST", headers: { "Content-Type": "application/json", "X-Request-ID": requestId() }, credentials: "include" });
    if (!res.ok) {
      if (res.status === 401) {
        let detail = "";
        try { detail = (await res.json()).detail || ""; } catch {}
        return { ok: false, reason: /refresh token required/i.test(detail) ? "anonymous" : "expired" };
      }
      return { ok: false, reason: "unavailable" };
    }
    const data = await res.json();
    if (!data.access_token) return { ok: false, reason: "unavailable" };
    setTokens(data.access_token);
    return { ok: true, reason: "refreshed" };
  } catch {
    return { ok: false, reason: "unavailable" };
  }
}

async function tryRefresh() {
  if (refreshInFlight) return refreshInFlight;
  refreshInFlight = (async () => {
    // Coordinate refresh-token rotation across tabs where the browser supports
    // Web Locks. A waiting tab then reads the replacement cookie, avoiding a
    // second request with the token that the first tab just rotated.
    if (globalThis.navigator?.locks?.request) {
      try {
        return await globalThis.navigator.locks.request("nanoclick-refresh-session", performRefresh);
      } catch {
        return performRefresh();
      }
    }
    return performRefresh();
  })();
  try { return await refreshInFlight; } finally { refreshInFlight = null; }
}

export const api = {
  async register({ email, password, full_name, referral_code }) { return request("/auth/register", { method: "POST", auth: false, body: { email, password, full_name, role: "advertiser", referral_code: referral_code || null } }); },
  async sendOTP(email) { return request("/auth/otp/send", { method: "POST", auth: false, body: { email } }); },
  async verifyOTP(email, code) { return request("/auth/otp/verify", { method: "POST", auth: false, body: { email, code } }); },
  async resendOTP(email) { return request("/auth/otp/resend", { method: "POST", auth: false, body: { email } }); },
  async login(email, password) { const data = await request("/auth/login?platform=web", { method: "POST", auth: false, body: { email, password } }); setTokens(data.access_token); return data; },
  async exchangeOAuthCode(code) { const data = await request(`/auth/oauth/exchange?code=${encodeURIComponent(code)}&platform=web`, { method: "POST", auth: false }); setTokens(data.access_token); return data; },
  async restoreSession() { return accessToken ? { ok: true, reason: "access_token" } : tryRefresh(); },
  async me() { return request("/auth/me"); },
  async updateProfile(payload) { return request("/auth/me/profile", { method: "PATCH", body: payload }); },
  async changePassword(current_password, new_password) { return request("/auth/change-password", { method: "POST", body: { current_password, new_password } }); },
  async forgotPassword(email) { return request("/auth/forgot-password", { method: "POST", auth: false, body: { email } }); },
  async resetPassword(token, new_password) { return request("/auth/reset-password", { method: "POST", auth: false, body: { token, new_password } }); },
  async deleteAccount() { return request("/auth/me", { method: "DELETE" }); },
  async logout() { try { await request("/auth/logout?platform=web", { method: "POST", auth: false }); } catch {} clearTokens(); },
  isLoggedIn() { return !!accessToken; }, setSessionTokens(access) { setTokens(access); },
  oauthUrl(provider) { return `${API_URL}/auth/${provider}/login?role=advertiser&platform=web`; },
  async getBalance() { return request("/wallet/balance"); },
  async getTransactions({ limit = 100, offset = 0 } = {}) { return request(`/wallet/transactions?limit=${encodeURIComponent(limit)}&offset=${encodeURIComponent(offset)}`); },
  async getDepositStatus(reference) { return request(`/wallet/deposits/${encodeURIComponent(reference)}`); },
  async initiateDeposit(amount_ngn, options = {}) { return request("/wallet/deposit/initialize", { method: "POST", body: { amount_ngn }, headers: { "Idempotency-Key": options.idempotencyKey || idempotencyKey() } }); },
  async listCampaigns({ limit = 50, offset = 0 } = {}) { return request(`/campaigns?limit=${encodeURIComponent(limit)}&offset=${encodeURIComponent(offset)}`); },
  async getCampaign(id) { return request(`/campaigns/${id}`); }, async getCampaignReport(id) { return request(`/campaigns/${id}/report`); },
  async createCampaign(payload) { return request("/campaigns", { method: "POST", body: payload }); },
  async updateCampaignStatus(id, new_status) { return request(`/campaigns/${id}/status?new_status=${encodeURIComponent(new_status)}`, { method: "PATCH" }); },
  async previewAudience(id) { return request(`/campaigns/${id}/audience`); },
  async listNotifications({ unreadOnly = false, limit = 50, offset = 0 } = {}) { return request(`/notifications?unread_only=${unreadOnly ? "true" : "false"}&limit=${encodeURIComponent(limit)}&offset=${encodeURIComponent(offset)}`); },
  async unreadNotificationCount() { return request("/notifications/unread-count"); },
  async markNotificationRead(id) { return request(`/notifications/${id}/read`, { method: "POST" }); },
  async markAllNotificationsRead() { return request(`/notifications/read-all`, { method: "POST" }); },
};

export { ApiError, getTokens, clearTokens, idempotencyKey };