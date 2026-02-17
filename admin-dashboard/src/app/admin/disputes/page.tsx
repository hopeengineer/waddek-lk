import { supabaseAdmin } from "@/lib/supabase";

export const dynamic = "force-dynamic";

export default async function DisputesPage() {
    const { data: disputes } = await supabaseAdmin
        .from("disputes")
        .select("id, job_id, raised_by, reason, description, status, evidence_urls, resolution, created_at, resolved_at")
        .order("created_at", { ascending: false });

    const open = disputes?.filter((d) => d.status === "open" || d.status === "investigating") || [];
    const resolved = disputes?.filter((d) => d.status === "resolved" || d.status === "dismissed") || [];

    return (
        <>
            <div className="page-header">
                <h2>Dispute Review</h2>
                <p>{open.length} active · {resolved.length} resolved</p>
            </div>

            {/* Active Disputes */}
            {open.length > 0 && (
                <>
                    <h3 style={{ color: "var(--neon-red)", marginBottom: 12, fontSize: 16 }}>
                        🔥 Active Disputes ({open.length})
                    </h3>
                    <div style={{ display: "flex", flexDirection: "column", gap: 12, marginBottom: 28 }}>
                        {open.map((d) => (
                            <div key={d.id} className="stat-card" style={{ borderLeft: "3px solid var(--neon-red)" }}>
                                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "start", marginBottom: 12 }}>
                                    <div>
                                        <span className={`badge badge-${d.status}`}>{d.status}</span>
                                        <span style={{ color: "var(--text-secondary)", fontSize: 12, marginLeft: 8 }}>
                                            {new Date(d.created_at).toLocaleDateString()}
                                        </span>
                                    </div>
                                    <span style={{ fontFamily: "monospace", fontSize: 11, color: "var(--text-secondary)" }}>
                                        {d.id.slice(0, 8)}…
                                    </span>
                                </div>
                                <h4 style={{ fontSize: 15, marginBottom: 6 }}>{d.reason}</h4>
                                {d.description && (
                                    <p style={{ color: "var(--text-secondary)", fontSize: 13, marginBottom: 12, lineHeight: 1.5 }}>
                                        {d.description}
                                    </p>
                                )}
                                {d.evidence_urls && d.evidence_urls.length > 0 && (
                                    <p style={{ fontSize: 12, color: "var(--neon-cyan)", marginBottom: 12 }}>
                                        📎 {d.evidence_urls.length} evidence file(s) attached
                                    </p>
                                )}
                                <div className="action-group">
                                    <form action={`/api/disputes/${d.id}/resolve`} method="POST">
                                        <button type="submit" className="btn btn-approve">✓ Resolve</button>
                                    </form>
                                    <form action={`/api/disputes/${d.id}/dismiss`} method="POST">
                                        <button type="submit" className="btn btn-reject">✕ Dismiss</button>
                                    </form>
                                    {d.status === "open" && (
                                        <form action={`/api/disputes/${d.id}/investigate`} method="POST">
                                            <button type="submit" className="btn btn-outline">🔍 Investigate</button>
                                        </form>
                                    )}
                                </div>
                            </div>
                        ))}
                    </div>
                </>
            )}

            {/* Resolved */}
            <h3 style={{ color: "var(--neon-green)", marginBottom: 12, fontSize: 16 }}>
                ✅ Resolved ({resolved.length})
            </h3>
            <div className="data-table-wrapper">
                {resolved.length > 0 ? (
                    <table className="data-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Reason</th>
                                <th>Status</th>
                                <th>Resolution</th>
                                <th>Resolved</th>
                            </tr>
                        </thead>
                        <tbody>
                            {resolved.map((d) => (
                                <tr key={d.id}>
                                    <td style={{ fontFamily: "monospace", fontSize: 12 }}>{d.id.slice(0, 8)}…</td>
                                    <td>{d.reason}</td>
                                    <td><span className={`badge badge-${d.status}`}>{d.status}</span></td>
                                    <td style={{ color: "var(--text-secondary)", fontSize: 13 }}>{d.resolution || "—"}</td>
                                    <td style={{ color: "var(--text-secondary)", fontSize: 13 }}>
                                        {d.resolved_at ? new Date(d.resolved_at).toLocaleDateString() : "—"}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                ) : (
                    <div className="empty-state">
                        <div className="empty-state-icon">🕊️</div>
                        <h3>No resolved disputes yet</h3>
                    </div>
                )}
            </div>
        </>
    );
}
