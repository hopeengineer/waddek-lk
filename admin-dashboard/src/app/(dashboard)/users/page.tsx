import { supabaseAdmin } from "@/lib/supabase";

export const dynamic = "force-dynamic";

export default async function UsersPage() {
    const { data: users } = await supabaseAdmin
        .from("profiles")
        .select("id, full_name, phone, role, tier, verified, average_rating, jobs_completed_count, created_at")
        .order("created_at", { ascending: false })
        .limit(100);

    const customers = users?.filter((u) => u.role === "customer") || [];
    const workers = users?.filter((u) => u.role === "worker") || [];

    return (
        <>
            <div className="page-header">
                <h2>User Management</h2>
                <p>{customers.length} customers · {workers.length} workers</p>
            </div>

            <div className="stats-grid" style={{ marginBottom: 28 }}>
                <div className="stat-card">
                    <div className="stat-label">Customers</div>
                    <div className="stat-value">{customers.length}</div>
                </div>
                <div className="stat-card">
                    <div className="stat-label">Workers</div>
                    <div className="stat-value green">{workers.length}</div>
                </div>
                <div className="stat-card">
                    <div className="stat-label">Total Users</div>
                    <div className="stat-value purple">{(users || []).length}</div>
                </div>
            </div>

            <div className="data-table-wrapper">
                {users && users.length > 0 ? (
                    <table className="data-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Phone</th>
                                <th>Role</th>
                                <th>Tier</th>
                                <th>Verified</th>
                                <th>Rating</th>
                                <th>Jobs</th>
                                <th>Joined</th>
                            </tr>
                        </thead>
                        <tbody>
                            {users.map((u) => (
                                <tr key={u.id}>
                                    <td style={{ fontWeight: 600 }}>{u.full_name || "—"}</td>
                                    <td style={{ fontFamily: "monospace", fontSize: 13 }}>{u.phone || "—"}</td>
                                    <td>
                                        <span className={`badge ${u.role === "worker" ? "badge-active" : "badge-open"}`}>
                                            {u.role}
                                        </span>
                                    </td>
                                    <td>
                                        {u.role === "worker" ? (
                                            <span className={`badge badge-${u.tier || "waddek"}`}>
                                                {u.tier || "waddek"}
                                            </span>
                                        ) : (
                                            <span style={{ color: "var(--text-secondary)" }}>—</span>
                                        )}
                                    </td>
                                    <td>
                                        {u.role === "worker" ? (
                                            u.verified ? (
                                                <span style={{ color: "var(--neon-green)" }}>✓</span>
                                            ) : (
                                                <span style={{ color: "var(--neon-amber)" }}>⏳</span>
                                            )
                                        ) : (
                                            "—"
                                        )}
                                    </td>
                                    <td>
                                        {u.average_rating ? (
                                            <span style={{ color: "var(--neon-amber)" }}>
                                                ⭐ {u.average_rating.toFixed(1)}
                                            </span>
                                        ) : "—"}
                                    </td>
                                    <td>{u.jobs_completed_count ?? "—"}</td>
                                    <td style={{ color: "var(--text-secondary)", fontSize: 13 }}>
                                        {new Date(u.created_at).toLocaleDateString()}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                ) : (
                    <div className="empty-state">
                        <div className="empty-state-icon">👥</div>
                        <h3>No users yet</h3>
                    </div>
                )}
            </div>
        </>
    );
}
