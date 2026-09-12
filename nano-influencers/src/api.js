// Thin fetch wrapper around the NanoClick backend.
// Browser refresh sessions use an HttpOnly cookie; access tokens stay in memory.
const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";
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
    if (Array.isArray(body.detail)) return body.detail.map((d) => d.msg).join("; ");
    return body.detail || res.statusText;
  } catch { return res.statusText; }
}

function idempotencyKey() {
  if (globalThis.crypto?.randomUUID) return globalThis.crypto.randomUUID();
  return `nano-${Date.now()}-${Math.random().toString(36).slice(2)}-${Math.random().toString(36).slice(2)}`;
}

async function request(path, { method = "GET", body, auth = true, headers: extraHeaders = {}, _retried = false } = {}) {
  const headers = { "Content-Type": "application/json", ...extraHeaders };
  if (auth && accessToken) headers["Authorization"] = `Bearer ${accessToken}`;
  const res = await fetch(`${API_URL}${path}`, { method, headers, body: body !== undefined ? JSON.stringify(body) : undefined, credentials: "include" });
  if (res.status === 401 && auth && !_retried) {
    const refreshed = await tryRefresh();
    if (refreshed) return request(path, { method, body, auth, headers: extraHeaders, _retried: true });
    clearTokens();
    window.dispatchEvent(new CustomEvent("nano-auth-expired"));
    throw new ApiError("Session expired — please log in again.", 401);
  }
  if (!res.ok) throw new ApiError(await parseError(res), res.status);
  if (res.status === 204) return null;
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}

async function tryRefresh() {
  if (refreshInFlight) return refreshInFlight;
  refreshInFlight = (async () => {
    try {
      const res = await fetch(`${API_URL}/auth/refresh?platform=web`, { method: "POST", headers: { "Content-Type": "application/json" }, credentials: "include" });
      if (!res.ok) return false;
      const data = await res.json();
      if (!data.access_token) return false;
      setTokens(data.access_token);
      return true;
    } catch { return false; }
  })();
  try { return await refreshInFlight; } finally { refreshInFlight = null; }
}

export const api = {
  async register({ email, password, full_name, referral_code }) { return request("/auth/register", { method: "POST", auth: false, body: { email, password, full_name, role: "advertiser", referral_code: referral_code || null } }); },
  async login(email, password) { const data = await request("/auth/login?platform=web", { method: "POST", auth: false, body: { email, password } }); setTokens(data.access_token); return data; },
  async exchangeOAuthCode(code) { const data = await request(`/auth/oauth/exchange?code=${encodeURIComponent(code)}&platform=web`, { method: "POST", auth: false }); setTokens(data.access_token); return data; },
  async restoreSession() { return tryRefresh(); },
  async me() { return request("/auth/me"); },
  async changePassword(current_password, new_password) { return request("/auth/change-password", { method: "POST", body: { current_password, new_password } }); },
  async forgotPassword(email) { return request("/auth/forgot-password", { method: "POST", auth: false, body: { email } }); },
  async resetPassword(token, new_password) { return request("/auth/reset-password", { method: "POST", auth: false, body: { token, new_password } }); },
  async deleteAccount() { return request("/auth/me", { method: "DELETE" }); },
  async logout() { try { await request("/auth/logout?platform=web", { method: "POST", auth: false }); } catch {} clearTokens(); },
  isLoggedIn() { return !!accessToken; },
  setSessionTokens(access) { setTokens(access); },
  oauthUrl(provider) { return `${API_URL}/auth/${provider}/login?role=advertiser&platform=web`; },
  async getBalance() { return request("/wallet/balance"); },
  async getTransactions() { return request("/wallet/transactions"); },
  async getDepositStatus(reference) { return request(`/wallet/deposits/${encodeURIComponent(reference)}`); },
  async initiateDeposit(amount_ngn) { return request("/wallet/deposit/initialize", { method: "POST", body: { amount_ngn }, headers: { "Idempotency-Key": idempotencyKey() } }); },
  async listCampaigns() { return request("/campaigns"); },
  async getCampaign(id) { return request(`/campaigns/${id}`); },
  async getCampaignReport(id) { return request(`/campaigns/${id}/report`); },
  async createCampaign(payload) { return request("/campaigns", { method: "POST", body: payload }); },
  async updateCampaignStatus(id, new_status) { return request(`/campaigns/${id}/status?new_status=${encodeURIComponent(new_status)}`, { method: "PATCH" }); },
  async previewAudience(id) { return request(`/campaigns/${id}/audience`); },
  async listNotifications() { return request("/notifications"); },
  async unreadNotificationCount() { return request("/notifications/unread-count"); },
  async markNotificationRead(id) { return request(`/notifications/${id}/read`, { method: "POST" }); },
  async markAllNotificationsRead() { return request(`/notifications/read-all`, { method: "POST" }); },
};

export { ApiError, getTokens, clearTokens };
