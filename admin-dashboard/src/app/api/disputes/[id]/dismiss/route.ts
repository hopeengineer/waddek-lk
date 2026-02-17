import { supabaseAdmin } from "@/lib/supabase";
import { NextResponse } from "next/server";

export async function POST(
    _req: Request,
    { params }: { params: Promise<{ id: string }> }
) {
    const { id } = await params;

    const { error } = await supabaseAdmin
        .from("disputes")
        .update({
            status: "dismissed",
            resolution: "Dismissed by admin",
            resolved_at: new Date().toISOString(),
        })
        .eq("id", id);

    if (error) {
        return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.redirect(new URL("/disputes", _req.url));
}
