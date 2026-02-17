import { NextRequest, NextResponse } from "next/server";
import { cookies } from "next/headers";

export async function POST(_request: NextRequest) {
    const cookieStore = await cookies();
    cookieStore.delete("admin_session");

    return NextResponse.redirect(new URL("/admin/login", _request.url));
}
