// Thin fetch wrapper around the NanoClick backend. Handles JWT storage,
// automatic access-token refresh on a 401, and consistent error shapes.

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

function getTokens() {
  return {
    access: localStorage.getItem("nano_access_token"),
    refresh: localStorage.getItem("nano_refresh_token"),
  };
}

function setTokens(access, refresh) {
  if (access) localStorage.setItem("nano_access_token", access);
  if (refresh) localStorage.setItem("nano_refresh_token", refresh);
}

function clearTokens() {
  localStorage.removeItem("nano_access_token");
  localStorage.removeItem("nano_refresh_token");
}

class ApiError extends Error {
  constructor(message, status) {
    super(message);
    this.status = status;
  }
}

async function parseError(res) {
  try {
    const body = await res.json();
    if (Array.isArray(body.detail)) {
      // FastAPI/pydantic validation error shape
      return body.detail.map((d) => d.msg).join("; ");
    }
    return body.detail || res.statusText;
  } catch {
    return res.statusText;
  }
}

// The core request function. `auth` defaults to true — nearly every call in
// this app is authenticated; pass auth:false for register/login themselves.
async function request(path, { method = "GET", body, auth = true, _retried = false } = {}) {
  const headers = { "Content-Type": "application/json" };
  if (auth) {
    const { access } = getTokens();
    if (access) headers["Authorization"] = `Bearer ${access}`;
  }
  const res = await fetch(`${API_URL}${path}`, {
    method,
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });

  if (res.status === 401 && auth && !_retried) {
    // Access token likely expired — try a single silent refresh, then retry
    // the original request once before giving up and forcing a logout.
    const refreshed = await tryRefresh();
    if (refreshed) return request(path, { method, body, auth, _retried: true });
    clearTokens();
    window.dispatchEvent(new CustomEvent("nano-auth-expired"));
    throw new ApiError("Session expired — please log in again.", 401);
  }

  if (!res.ok) {
    throw new ApiError(await parseError(res), res.status);
  }
  if (res.status === 204) return null;
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}

async function tryRefresh() {
  const { refresh } = getTokens();
  if (!refresh) return false;
  try {
    const res = await fetch(`${API_URL}/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh_token: refresh }),
    });
    if (!res.ok) return false;
    const data = await res.json();
    setTokens(data.access_token, data.refresh_token);
    return true;
  } catch {
    return false;
  }
}

export const api = {
  // ---- auth ----
  async register({ email, password, full_name, referral_code }) {
    return request("/auth/register", {
      method: "POST",
      auth: false,
      body: { email, password, full_name, role: "advertiser", referral_code: referral_code || null },
    });
  },
  async login(email, password) {
    const data = await request("/auth/login", { method: "POST", auth: false, body: { email, password } });
    setTokens(data.access_token, data.refresh_token);
    return data;
  },
  async me() {
    return request("/auth/me");
  },
  logout() {
    clearTokens();
  },
  isLoggedIn() {
    return !!getTokens().access;
  },
  setSessionTokens(access, refresh) {
    setTokens(access, refresh);
  },
  oauthUrl(provider) {
    // platform=web tells the backend to redirect back to a browser page
    // (see OAUTH_WEB_REDIRECT_URL) instead of a mobile nanoclick:// deep link.
    return `${API_URL}/auth/${provider}/login?role=advertiser&platform=web`;
  },

  // ---- wallet ----
  async getBalance() {
    return request("/wallet/balance");
  },
  async getTransactions() {
    return request("/wallet/transactions");
  },
  async initiateDeposit(amount_ngn) {
    return request("/wallet/deposit/initialize", { method: "POST", body: { amount_ngn } });
  },

  // ---- campaigns ----
  async listCampaigns() {
    return request("/campaigns");
  },
  async getCampaign(id) {
    return request(`/campaigns/${id}`);
  },
  async createCampaign(payload) {
    return request("/campaigns", { method: "POST", body: payload });
  },
  async updateCampaignStatus(id, new_status) {
    return request(`/campaigns/${id}/status?new_status=${encodeURIComponent(new_status)}`, { method: "PATCH" });
  },
  async previewAudience(id) {
    return request(`/campaigns/${id}/audience`);
  },

  // ---- notifications ----
  async listNotifications() {
    return request("/notifications");
  },
  async unreadNotificationCount() {
    return request("/notifications/unread-count");
  },
  async markNotificationRead(id) {
    return request(`/notifications/${id}/read`, { method: "POST" });
  },
  async markAllNotificationsRead() {
    return request("/notifications/read-all", { method: "POST" });
  },
};

export { ApiError, getTokens, clearTokens };
