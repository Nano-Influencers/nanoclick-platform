const sidebarRoutes = {
  Dashboard: "/dashboard",
  Overview: "/dashboard",
  Wallet: "/wallet",
  Campaigns: "/campaigns",
  Analytics: "/analytics",
  Settings: "/settings",
  "Help & Support": "/help-support",
};

const socialCampaignRoutes = {
  Facebook: "/campaigns/create/facebook",
  Youtube: "/campaigns/create/youtube",
  Twitter: "/campaigns/create/x",
  WhatsApp: "/campaigns/create/whatsapp",
  Instagram: "/campaigns/create/instagram",
  TikTok: "/campaigns/create/tiktok",
  LinkedIn: "/campaigns/create/linkedin",
  Telegram: "/campaigns/create/telegram",
  Audiomack: "/campaigns/create/audiomack",
  Spotify: "/campaigns/create/spotify",
  BoomPlay: "/campaigns/create/boomplay",
  "YT Music": "/campaigns/create/youtube-music",
};

function textOf(element) {
  return (element?.textContent || "").replace(/\s+/g, " ").trim();
}

function go(path) {
  if (!path || typeof window === "undefined") return;
  window.location.assign(path);
}


const authenticatedBrandSelector = [
  ".v2-dashboard-brand",
  ".v2-wallet-brand",
  ".v2-campaign-brand",
  ".v2-settings-brand",
  ".v2-help-brand",
].join(",");

const logoutSelector = [
  ".v2-dashboard-logout",
  ".v2-wallet-logout",
  ".v2-campaign-logout",
  ".v2-settings-logout",
  ".v2-help-logout",
].join(",");

function isLogoutIntent(control) {
  if (control.matches(logoutSelector)) return true;
  if (control.matches(authenticatedBrandSelector)) return true;
  if (control.closest(".v2-dashboard-profile-dropdown") && textOf(control) === "Log Out") return true;
  return false;
}

function ensureLogoutDialog() {
  let dialog = document.querySelector(".v2-logout-confirm");
  if (dialog) return dialog;

  dialog = document.createElement("div");
  dialog.className = "v2-logout-confirm";
  dialog.hidden = true;
  dialog.innerHTML = `
    <button class="v2-logout-confirm__backdrop" type="button" aria-label="Cancel logout"></button>
    <section class="v2-logout-confirm__card" role="dialog" aria-modal="true" aria-labelledby="v2-logout-title" aria-describedby="v2-logout-copy">
      <div class="v2-logout-confirm__icon" aria-hidden="true"><img src="" alt="" /></div>
      <h2 id="v2-logout-title">Log out?</h2>
      <p id="v2-logout-copy">Are you sure you want to log out of your Nano Influencers account?</p>
      <div class="v2-logout-confirm__actions">
        <button class="v2-logout-confirm__cancel" type="button">Cancel</button>
        <button class="v2-logout-confirm__submit" type="button">Log Out</button>
      </div>
    </section>
  `;

  const close = () => {
    dialog.hidden = true;
    document.body.style.removeProperty("overflow");
  };

  dialog.querySelector(".v2-logout-confirm__backdrop").addEventListener("click", close);
  dialog.querySelector(".v2-logout-confirm__cancel").addEventListener("click", close);
  dialog.querySelector(".v2-logout-confirm__submit").addEventListener("click", () => go("/login"));
  document.body.appendChild(dialog);
  return dialog;
}

function askToLogout(control) {
  const dialog = ensureLogoutDialog();
  const page = control?.closest?.(".v2-dashboard-page, .v2-wallet-page, .v2-campaign-page, .v2-settings-page, .v2-help-page");
  const pageIcon = page?.querySelector?.([
    ".v2-dashboard-logout img",
    ".v2-wallet-logout img",
    ".v2-campaign-logout img",
    ".v2-settings-logout img",
    ".v2-help-logout img",
  ].join(","));
  const icon = dialog.querySelector(".v2-logout-confirm__icon img");
  if (icon) icon.src = pageIcon?.getAttribute("src") || "/assets/nano-v2-app/dashboard-logout.svg";
  dialog.hidden = false;
  document.body.style.overflow = "hidden";
  window.setTimeout(() => dialog.querySelector(".v2-logout-confirm__cancel")?.focus(), 0);
}

function routeForSidebar(control) {
  if (!control.matches([
    ".v2-dashboard-sidebar-item",
    ".v2-wallet-sidebar-item",
    ".v2-campaign-sidebar-item",
    ".v2-settings-sidebar-link",
    ".v2-help-sidebar-link",
  ].join(","))) return null;

  return sidebarRoutes[textOf(control)] || null;
}

function routeForDashboard(control) {
  if (!control.closest(".v2-dashboard-page")) return null;

  if (control.matches(".v2-dashboard-logout")) return "/login";
  if (control.matches(".v2-dashboard-notification")) return "/campaigns/notifications";
  if (control.matches(".v2-dashboard-balance-button")) return "/wallet?state=deposit";

  if (control.closest(".v2-dashboard-launch-buttons")) {
    const text = textOf(control);
    if (text === "Start Now") return "/campaigns";
    if (text === "Manage") return "/campaigns/manage";
  }

  if (control.matches(".v2-dashboard-quick-item")) {
    const text = textOf(control);
    if (text.startsWith("Add Funds")) return "/wallet?state=deposit";
  }

  if (control.closest(".v2-dashboard-empty-activity") && textOf(control) === "Start a Campaign") return "/campaigns";
  if (control.closest(".v2-dashboard-support-card") && textOf(control) === "Contact Support") return "/help-support";

  if (control.matches(".v2-dashboard-metric-card button")) {
    const text = textOf(control);
    if (text === "View Campaigns") return "/campaigns/manage";
    if (text === "Spend Report") return "/wallet?state=activity";
    if (text === "View Analytics") return "/analytics";
  }

  if (control.closest(".v2-dashboard-bottom-nav")) {
    const links = [...control.closest(".v2-dashboard-bottom-nav").querySelectorAll("a")];
    const index = links.indexOf(control.closest("a"));
    return ["/dashboard", "/wallet", "/campaigns", "/analytics"][index] || null;
  }

  if (control.closest(".v2-dashboard-profile-dropdown")) {
    const text = textOf(control);
    if (text === "Settings") return "/settings";
    if (text === "Log Out") return "/login";
  }

  if (control.matches(".v2-dashboard-floating .is-help")) return "/help-support";
  return null;
}

function routeForWallet(control) {
  if (!control.closest(".v2-wallet-page") && !control.closest(".v2-wallet-success-page")) return null;
  if (control.matches(".v2-wallet-logout")) return "/login";
  if (control.matches(".v2-wallet-notification")) return "/campaigns/notifications";
  return null;
}

function routeForCampaign(control) {
  if (!control.closest(".v2-campaign-page")) return null;
  if (control.matches(".v2-campaign-logout")) return "/login";
  if (control.matches(".v2-campaign-notification")) return "/campaigns/notifications";
  if (control.matches(".v2-campaign-platform-card")) return socialCampaignRoutes[textOf(control)] || "/campaigns/custom-task";
  return null;
}

function routeForSettings(control) {
  if (!control.closest(".v2-settings-page")) return null;
  if (control.matches(".v2-settings-logout")) return "/login";
  if (control.matches(".v2-settings-notification")) return "/campaigns/notifications";
  return null;
}

function routeForHelp(control) {
  if (!control.closest(".v2-help-page")) return null;
  if (control.matches(".v2-help-logout")) return "/login";
  if (control.matches(".v2-help-notification")) return "/campaigns/notifications";
  return null;
}

function routeForOutcome(control) {
  if (!control.closest(".v2-outcome-page")) return null;
  if (textOf(control) === "Top Up") return "/wallet?state=deposit";
  return null;
}

function routeForKnownPlaceholder(control) {
  if (!(control instanceof HTMLAnchorElement)) return null;
  const href = control.getAttribute("href") || "";
  if (href === "/support" || href === "#help") return "/help-support";
  if (href === "#campaigns") return "/campaigns";
  if (href === "#settings") return "/settings";
  if (href === "#analytics") return "/analytics";
  return null;
}

export function installV2Navigation() {
  if (typeof window === "undefined" || window.__nanoV2NavigationInstalled) return;
  window.__nanoV2NavigationInstalled = true;

  document.addEventListener("submit", (event) => {
    const form = event.target;

    if (form?.matches?.(".v2-auth-login .v2-auth-form")) {
      event.preventDefault();
      event.stopImmediatePropagation();
      go("/dashboard");
      return;
    }

    if (form?.matches?.(".v2-ct-form")) {
      const params = new URLSearchParams(window.location.search);
      if (params.get("payment") === "success") {
        event.preventDefault();
        event.stopImmediatePropagation();
        go("/campaigns/custom-task/subscription-success");
      }
    }
  }, true);

  document.addEventListener("keydown", (event) => {
    if (event.key !== "Escape") return;
    const dialog = document.querySelector(".v2-logout-confirm");
    if (!dialog || dialog.hidden) return;
    dialog.hidden = true;
    document.body.style.removeProperty("overflow");
  }, true);

  document.addEventListener("click", (event) => {
    const control = event.target.closest("a,button");
    if (!control) return;


    if (isLogoutIntent(control)) {
      event.preventDefault();
      event.stopImmediatePropagation();
      askToLogout(control);
      return;
    }

    if (
      control.closest(".v2-preview-page") &&
      control.matches(".v2-preview-confirm") &&
      new URLSearchParams(window.location.search).get("payment") === "success"
    ) {
      event.preventDefault();
      event.stopImmediatePropagation();
      go("/campaigns/subscription-success");
      return;
    }

    const route =
      routeForSidebar(control) ||
      routeForDashboard(control) ||
      routeForWallet(control) ||
      routeForCampaign(control) ||
      routeForSettings(control) ||
      routeForHelp(control) ||
      routeForOutcome(control) ||
      routeForKnownPlaceholder(control);

    if (!route) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    go(route);
  }, true);
}
