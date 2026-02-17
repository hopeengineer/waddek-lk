import { supabaseAdmin } from "@/lib/supabase";

export const dynamic = "force-dynamic";

export default async function WorkersPage() {
    const { data: workers } = await supabaseAdmin
        .from("profiles")
        .select("id, full_name, phone, tier, verified, average_rating, jobs_completed_count, created_at")
        .eq("role", "worker")
        .order("created_at", { ascending: false });

    const pending = workers?.filter((w) => !w.verified) || [];
    const verified = workers?.filter((w) => w.verified) || [];

    return (
        <>
            <div className="page-header">
                <h2>Worker Management</h2>
                <p>{pending.length} pending verification · {verified.length} verified workers</p>
            </div>

            {/* Pending Verification Queue */}
            {pending.length > 0 && (
                <>
                    <h3 style={{ color: "var(--neon-amber)", marginBottom: 12, fontSize: 16 }}>
                        ⏳ Pending Verification ({pending.length})
                    </h3>
                    <div className="data-table-wrapper" style={{ marginBottom: 28 }}>
                        <table className="data-table">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Phone</th>
                                    <th>Registered</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {pending.map((w) => (
                                    <tr key={w.id}>
                                        <td style={{ fontWeight: 600 }}>{w.full_name || "—"}</td>
                                        <td style={{ fontFamily: "monospace" }}>{w.phone || "—"}</td>
                                        <td style={{ color: "var(--text-secondary)", fontSize: 13 }}>
                                            {new Date(w.created_at).toLocaleDateString()}
                                        </td>
                                        <td>
                                            <div className="action-group">
                                                <form action={`/api/workers/${w.id}/verify`} method="POST">
                                                    <button type="submit" className="btn btn-approve">✓ Verify</button>
                                                </form>
                                                <form action={`/api/workers/${w.id}/reject`} method="POST">
                                                    <button type="submit" className="btn btn-reject">✕ Reject</button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </>
            )}

            {/* Verified Workers */}
            <h3 style={{ color: "var(--neon-green)", marginBottom: 12, fontSize: 16 }}>
                ✅ Verified Workers ({verified.length})
            </h3>
            <div className="data-table-wrapper">
                {verified.length > 0 ? (
                    <table className="data-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Phone</th>
                                <th>Tier</th>
                                <th>Rating</th>
                                <th>Jobs Done</th>
                                <th>Since</th>
                            </tr>
                        </thead>
                        <tbody>
                            {verified.map((w) => (
                                <tr key={w.id}>
                                    <td style={{ fontWeight: 600 }}>{w.full_name || "—"}</td>
                                    <td style={{ fontFamily: "monospace" }}>{w.phone || "—"}</td>
                                    <td>
                                        <span className={`badge badge-${w.tier || "waddek"}`}>
                                            {w.tier || "waddek"}
                                        </span>
                                    </td>
                                    <td>
                                        <span style={{ color: "var(--neon-amber)" }}>
                                            ⭐ {w.average_rating?.toFixed(1) ?? "—"}
                                        </span>
                                    </td>
                                    <td>{w.jobs_completed_count ?? 0}</td>
                                    <td style={{ color: "var(--text-secondary)", fontSize: 13 }}>
                                        {new Date(w.created_at).toLocaleDateString()}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                ) : (
                    <div className="empty-state">
                        <div className="empty-state-icon">👷</div>
                        <h3>No verified workers yet</h3>
                    </div>
                )}
            </div>
        </>
    );
}
