import { supabaseAdmin } from "@/lib/supabase";
import { NextResponse } from "next/server";

export async function POST(
    _req: Request,
    { params }: { params: Promise<{ id: string }> }
) {
    const { id } = await params;

    // Mark rejected so the user sees the reason and can request a
    // manual re-review. We deliberately do not flip role here —
    // role and verification are independent concerns.
    const { error } = await supabaseAdmin
        .from("profiles")
        .update({
            verification_status: "rejected",
            shuftipro_decline_reason: "Manually rejected by admin.",
        })
        .eq("id", id);

    if (error) {
        return NextResponse.json({ error: error.message }, { status: 400 });
    }

    await supabaseAdmin.from("notifications").insert({
        user_id: id,
        type: "system",
        title: "Account update",
        body: "Your worker verification was not approved. Please contact support for details.",
    });

    return NextResponse.redirect(new URL("/workers", _req.url));
}
