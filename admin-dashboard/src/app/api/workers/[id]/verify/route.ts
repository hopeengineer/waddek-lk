import { supabaseAdmin } from "@/lib/supabase";
import { NextResponse } from "next/server";

export async function POST(
    _req: Request,
    { params }: { params: Promise<{ id: string }> }
) {
    const { id } = await params;

    // Manual admin override — flips verification_status and clears
    // any lock the lifetime-cap put on. The Shufti flow normally
    // does this via the webhook; this path covers edge cases (lost
    // doc, mistaken decline, etc.).
    const { error } = await supabaseAdmin
        .from("profiles")
        .update({
            verification_status: "verified",
            identity_locked: true,
            verification_locked_until: null,
            shuftipro_decline_reason: null,
        })
        .eq("id", id);

    if (error) {
        return NextResponse.json({ error: error.message }, { status: 400 });
    }

    // Notify worker
    await supabaseAdmin.from("notifications").insert({
        user_id: id,
        type: "system",
        title: "✅ You're verified!",
        body: "Your account has been verified. You can now receive job notifications.",
    });

    return NextResponse.redirect(new URL("/workers", _req.url));
}
