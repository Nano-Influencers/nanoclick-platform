import React, { useEffect, useMemo, useState } from "react";
import { api } from "../../api.js";
import "./v2-analytics.css";

const money = (kobo) => "₦" + (Number(kobo || 0) / 100).toLocaleString("en-NG", { maximumFractionDigits: 2 });
const label = (value) => String(value || "").replaceAll("_", " ");

export default function V2Analytics() {
  const [campaigns, setCampaigns] = useState([]);
  const [reports, setReports] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  useEffect(() => {
    let live = true;
    (async () => {
      try {
        const rows = await api.listCampaigns({ limit: 100 });
        const pairs = await Promise.all(rows.map(async (campaign) => {
          try { return [campaign.id, await api.getCampaignReport(campaign.id)]; }
          catch { return [campaign.id, null]; }
        }));
        if (live) { setCampaigns(rows); setReports(Object.fromEntries(pairs)); }
      } catch (err) { if (live) setError(err.message || "Unable to load analytics."); }
      finally { if (live) setLoading(false); }
    })();
    return () => { live = false; };
  }, []);
  const totals = useMemo(() => campaigns.reduce((a, c) => {
    const r = reports[c.id] || {};
    a.budget += Number(c.client_budget_kobo || 0);
    a.spent += Number(r.spent_kobo || 0);
    a.slots += Number(c.slots_total || 0);
    a.filled += Number(c.slots_filled || 0);
    a.accepted += Number(r.accepted || 0);
    a.submissions += Number(r.submissions?.total || 0);
    return a;
  }, {budget:0, spent:0, slots:0, filled:0, accepted:0, submissions:0}), [campaigns,reports]);
  const active = campaigns.filter(c => ["active","awaiting_workers"].includes(c.status)).length;
  if (loading) return <main className="v2-analytics-page"><p>Loading your analytics…</p></main>;
  return <main className="v2-analytics-page">
    <header><a href="/dashboard">← Dashboard</a><h1>Campaign Analytics</h1><p>Performance from campaigns belonging to your account.</p></header>
    {error && <p className="v2-analytics-error" role="alert">{error}</p>}
    {!error && <><section className="v2-analytics-metrics">
      <article><span>Total campaigns</span><strong>{campaigns.length}</strong></article>
      <article><span>Active campaigns</span><strong>{active}</strong></article>
      <article><span>Campaign spend</span><strong>{money(totals.spent)}</strong></article>
      <article><span>Budget allocated</span><strong>{money(totals.budget)}</strong></article>
      <article><span>Workers accepted</span><strong>{totals.accepted.toLocaleString()}</strong></article>
      <article><span>Submissions received</span><strong>{totals.submissions.toLocaleString()}</strong></article>
      <article><span>Slots filled</span><strong>{totals.filled.toLocaleString()} / {totals.slots.toLocaleString()}</strong></article>
    </section>
    <section className="v2-analytics-table"><h2>Campaign performance</h2>
      {campaigns.length === 0 ? <div className="v2-analytics-empty"><h3>No campaign data yet</h3><p>Create your first campaign to see its performance here.</p><a href="/campaigns">Create campaign</a></div> :
      <div className="v2-analytics-scroll"><table><thead><tr><th>Campaign</th><th>Platform</th><th>Status</th><th>Workers</th><th>Submissions</th><th>Spend</th><th></th></tr></thead><tbody>
        {campaigns.map(c => { const r=reports[c.id] || {}; return <tr key={c.id}><td>{c.title}</td><td>{label(c.platform)}</td><td>{label(c.status)}</td><td>{Number(r.accepted||0)}</td><td>{Number(r.submissions?.total||0)}</td><td>{money(r.spent_kobo||0)}</td><td><a href={`/campaigns/${c.id}`}>Details</a></td></tr>; })}
      </tbody></table></div>}
    </section></>}
  </main>;
}
