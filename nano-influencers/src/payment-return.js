const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";
const message = document.getElementById("message");
const back = document.getElementById("back");

function show(text, showBack = true) {
  message.textContent = text;
  if (showBack) back.style.display = "inline-block";
}

async function refreshAccessToken() {
  const response = await fetch(`${API_URL}/auth/refresh?platform=web`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    credentials: "include",
  });
  if (!response.ok) throw new Error("Your session could not be restored.");
  const data = await response.json();
  if (!data.access_token) throw new Error("Your session could not be restored.");
  return data.access_token;
}

async function reconcile() {
  const params = new URLSearchParams(window.location.search);
  const reference = params.get("reference") || params.get("trxref");
  if (!reference) throw new Error("No payment reference was supplied.");

  const accessToken = await refreshAccessToken();
  const response = await fetch(`${API_URL}/wallet/deposits/${encodeURIComponent(reference)}`, {
    headers: { Authorization: `Bearer ${accessToken}` },
    credentials: "include",
  });
  if (!response.ok) {
    let detail = "We could not confirm this payment yet.";
    try {
      const body = await response.json();
      detail = body.detail || detail;
    } catch {}
    throw new Error(detail);
  }

  const deposit = await response.json();
  if (deposit.status === "completed") {
    show(`${new Intl.NumberFormat("en-NG", { style: "currency", currency: "NGN" }).format(deposit.amount_ngn)} has been added to your wallet. Redirecting…`, false);
    window.setTimeout(() => { window.location.assign("/app/wallet"); }, 900);
    return;
  }
  if (deposit.status === "failed") {
    show("The payment was not completed. Your wallet has not been credited.");
    return;
  }
  show("The payment is still being confirmed. You can return to your wallet and refresh it in a moment.");
}

reconcile().catch((error) => show(error.message || "We could not confirm this payment."));
