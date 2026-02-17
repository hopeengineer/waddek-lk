import { NextRequest, NextResponse } from "next/server";

export function middleware(request: NextRequest) {
    const { pathname } = request.nextUrl;

    // Allow login page and auth API without session
    if (pathname === "/admin/login" || pathname.startsWith("/admin/api/auth")) {
        return NextResponse.next();
    }

    // Allow static assets (images, favicon, etc.)
    if (
        pathname.startsWith("/admin/_next") ||
        pathname.match(/\.(png|jpg|jpeg|ico|svg|css|js)$/)
    ) {
        return NextResponse.next();
    }

    // Check for session cookie
    const session = request.cookies.get("admin_session");
    if (!session?.value) {
        const loginUrl = new URL("/admin/login", request.url);
        return NextResponse.redirect(loginUrl);
    }

    return NextResponse.next();
}

export const config = {
    matcher: ["/admin/:path*"],
};
