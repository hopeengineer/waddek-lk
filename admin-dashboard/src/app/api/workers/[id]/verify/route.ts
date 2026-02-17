import { supabaseAdmin } from "@/lib/supabase";
import { NextResponse } from "next/server";

export async function POST(
    _req: Request,
    { params }: { params: Promise<{ id: string }> }
) {
    const { id } = await params;

    const { error } = await supabaseAdmin
        .from("profiles")
        .update({ verified: true })
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
