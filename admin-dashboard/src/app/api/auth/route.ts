import { NextRequest, NextResponse } from "next/server";
import { cookies } from "next/headers";
import crypto from "crypto";

const ADMIN_USERNAME = process.env.ADMIN_USERNAME || "admin";
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || "WaddekAdmin";
const SESSION_SECRET = process.env.SESSION_SECRET || "waddek-admin-secret-key-change-me";

function createSessionToken(): string {
    return crypto.randomBytes(32).toString("hex");
}

export async function POST(request: NextRequest) {
    try {
        const { username, password } = await request.json();

        if (username === ADMIN_USERNAME && password === ADMIN_PASSWORD) {
            const token = createSessionToken();
            const cookieStore = await cookies();

            cookieStore.set("admin_session", token, {
                httpOnly: true,
                secure: process.env.NODE_ENV === "production",
                sameSite: "lax",
                path: "/",
                maxAge: 60 * 60 * 24, // 24 hours
            });

            return NextResponse.json({ success: true });
        }

        return NextResponse.json(
            { error: "Invalid username or password" },
            { status: 401 }
        );
    } catch {
        return NextResponse.json(
            { error: "Bad request" },
            { status: 400 }
        );
    }
}
