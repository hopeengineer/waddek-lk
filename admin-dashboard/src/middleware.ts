import { NextRequest, NextResponse } from "next/server";

export function middleware(request: NextRequest) {
    const { pathname } = request.nextUrl;

    // Only protect /admin routes
    if (!pathname.startsWith("/admin")) {
        return NextResponse.next();
    }

    // Allow login page and auth API without session
    if (pathname === "/admin/login" || pathname.startsWith("/api/auth")) {
        return NextResponse.next();
    }

    // Allow static assets
    if (
        pathname.startsWith("/_next") ||
        pathname.match(/\.(png|jpg|jpeg|ico|svg|css|js|json|woff|woff2|ttf|otf)$/)
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
