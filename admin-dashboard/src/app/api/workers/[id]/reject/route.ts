import { supabaseAdmin } from "@/lib/supabase";
import { NextResponse } from "next/server";

export async function POST(
    _req: Request,
    { params }: { params: Promise<{ id: string }> }
) {
    const { id } = await params;

    const { error } = await supabaseAdmin
        .from("profiles")
        .update({ verified: false, role: "customer" }) // Downgrade to customer
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
