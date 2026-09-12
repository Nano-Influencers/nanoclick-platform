const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";
const message = document.getElementById("message");
const back = document.getElementById("back");

const sleep = (ms) => new Promise((resolve) => window.setTimeout(resolve, ms));

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

async function getDeposit(reference, accessToken) {
  return fetch(`${API_URL}/wallet/deposits/${encodeURIComponent(reference)}`, {
    headers: { Authorization: `Bearer ${accessToken}` },
    credentials: "include",
  });
}

async function parseError(response) {
  let detail = "We could not confirm this payment yet.";
  try {
    const body = await response.json();
    detail = body.detail || detail;
  } catch {}
  return detail;
}

async function reconcile() {
  const params = new URLSearchParams(window.location.search);
  const reference = params.get("reference") || params.get("trxref");
  if (!reference || reference.length > 255) throw new Error("No valid payment reference was supplied.");

  let accessToken = await refreshAccessToken();
  const attempts = 10;

  for (let attempt = 0; attempt < attempts; attempt += 1) {
    const response = await getDeposit(reference, accessToken);

    if (response.status === 401) {
      accessToken = await refreshAccessToken();
      continue;
    }

    if (!response.ok) throw new Error(await parseError(response));

    const deposit = await response.json();
    if (deposit.status === "completed") {
      const amount = new Intl.NumberFormat("en-NG", { style: "currency", currency: "NGN" }).format(deposit.amount_ngn);
      show(`${amount} has been added to your wallet. Redirecting…`, false);
      window.setTimeout(() => { window.location.assign("/app/wallet"); }, 900);
      return;
    }

    if (deposit.status === "failed") {
      show("The payment was not completed. Your wallet has not been credited.");
      return;
    }

    if (attempt < attempts - 1) {
      show("Payment received. We are waiting for final confirmation…", false);
      await sleep(3000);
    }
  }

  show("Your payment is still being confirmed. Return to your wallet and refresh it shortly.");
}

reconcile().catch((error) => show(error.message || "We could not confirm this payment."));
