import { supabaseAdmin } from "@/lib/supabase";

export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  // Fetch stats
  const [
    { count: totalUsers },
    { count: totalWorkers },
    { count: pendingWorkers },
    { count: openDisputes },
    { count: activeJobs },
    { count: completedJobs },
  ] = await Promise.all([
    supabaseAdmin.from("profiles").select("*", { count: "exact", head: true }),
    supabaseAdmin.from("profiles").select("*", { count: "exact", head: true }).eq("role", "worker"),
    supabaseAdmin.from("profiles").select("*", { count: "exact", head: true }).eq("role", "worker").eq("verified", false),
    supabaseAdmin.from("disputes").select("*", { count: "exact", head: true }).eq("status", "open"),
    supabaseAdmin.from("jobs").select("*", { count: "exact", head: true }).in("status", ["posted", "bidding", "matched"]),
    supabaseAdmin.from("jobs").select("*", { count: "exact", head: true }).eq("status", "completed"),
  ]);

  // Recent disputes
  const { data: recentDisputes } = await supabaseAdmin
    .from("disputes")
    .select("id, reason, status, created_at")
    .order("created_at", { ascending: false })
    .limit(5);

  return (
    <>
      <div className="page-header">
        <h2>Dashboard</h2>
        <p>Overview of Waddek platform metrics</p>
      </div>

      {/* Stats Grid */}
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-label">Total Users</div>
          <div className="stat-value">{totalUsers ?? 0}</div>
        </div>
        <div className="stat-card">
          <div className="stat-label">Workers</div>
          <div className="stat-value green">{totalWorkers ?? 0}</div>
        </div>
        <div className="stat-card">
          <div className="stat-label">Pending Verification</div>
          <div className="stat-value amber">{pendingWorkers ?? 0}</div>
        </div>
        <div className="stat-card">
          <div className="stat-label">Open Disputes</div>
          <div className="stat-value red">{openDisputes ?? 0}</div>
        </div>
        <div className="stat-card">
          <div className="stat-label">Active Jobs</div>
          <div className="stat-value purple">{activeJobs ?? 0}</div>
        </div>
        <div className="stat-card">
          <div className="stat-label">Completed Jobs</div>
          <div className="stat-value green">{completedJobs ?? 0}</div>
        </div>
      </div>

      {/* Recent Disputes */}
      <div className="page-header">
        <h2>Recent Disputes</h2>
      </div>
      <div className="data-table-wrapper">
        {recentDisputes && recentDisputes.length > 0 ? (
          <table className="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Reason</th>
                <th>Status</th>
                <th>Created</th>
              </tr>
            </thead>
            <tbody>
              {recentDisputes.map((d) => (
                <tr key={d.id}>
                  <td style={{ fontFamily: "monospace", fontSize: 12 }}>
                    {d.id.slice(0, 8)}…
                  </td>
                  <td>{d.reason}</td>
                  <td>
                    <span className={`badge badge-${d.status}`}>
                      {d.status}
                    </span>
                  </td>
                  <td style={{ color: "var(--text-secondary)", fontSize: 13 }}>
                    {new Date(d.created_at).toLocaleDateString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <div className="empty-state">
            <div className="empty-state-icon">✅</div>
            <h3>No disputes</h3>
            <p>Everything looks good!</p>
          </div>
        )}
      </div>
    </>
  );
}
