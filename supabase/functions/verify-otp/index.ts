// supabase/functions/verify-otp/index.ts
// Verifies OTP code, creates/retrieves Supabase Auth user, returns session
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const MAX_VERIFY_ATTEMPTS = 3;

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Use Web Crypto API (works everywhere on Deno Deploy / Supabase Edge)
async function sha256(input: string): Promise<string> {
    const encoder = new TextEncoder();
    const data = encoder.encode(input);
    const hash = await crypto.subtle.digest("SHA-256", data);
    return Array.from(new Uint8Array(hash))
        .map((b) => b.toString(16).padStart(2, "0"))
        .join("");
}

serve(async (req: Request) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const { phone, code } = await req.json();

        if (!phone || !code) {
            return new Response(
                JSON.stringify({ error: "Phone and code are required" }),
                { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Normalize phone
        let normalizedPhone = phone.replace(/[\s\-]/g, "");
        if (normalizedPhone.startsWith("0")) {
            normalizedPhone = "+94" + normalizedPhone.substring(1);
        } else if (normalizedPhone.startsWith("94") && !normalizedPhone.startsWith("+94")) {
            normalizedPhone = "+" + normalizedPhone;
        } else if (!normalizedPhone.startsWith("+94")) {
            normalizedPhone = "+94" + normalizedPhone;
        }

        const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

        // ── Find latest unexpired, unused OTP for this phone ────
        const { data: otpRows, error: fetchError } = await supabase
            .from("otp_codes")
            .select("*")
            .eq("phone", normalizedPhone)
            .eq("used", false)
            .gt("expires_at", new Date().toISOString())
            .order("created_at", { ascending: false })
            .limit(1);

        if (fetchError || !otpRows || otpRows.length === 0) {
            return new Response(
                JSON.stringify({ error: "No valid OTP found. Request a new code." }),
                { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        const otpRow = otpRows[0];

        // ── Check attempt limit ─────────────────────────────────
        if (otpRow.attempts >= MAX_VERIFY_ATTEMPTS) {
            await supabase
                .from("otp_codes")
                .update({ used: true })
                .eq("id", otpRow.id);

            return new Response(
                JSON.stringify({ error: "Too many attempts. Request a new code." }),
                { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // ── Increment attempt counter ───────────────────────────
        await supabase
            .from("otp_codes")
            .update({ attempts: otpRow.attempts + 1 })
            .eq("id", otpRow.id);

        // ── Verify code (SHA-256 comparison) ────────────────────
        const codeHash = await sha256(code);
        const isValid = codeHash === otpRow.code_hash;

        if (!isValid) {
            const attemptsLeft = MAX_VERIFY_ATTEMPTS - (otpRow.attempts + 1);
            return new Response(
                JSON.stringify({
                    error: `Invalid code. ${attemptsLeft} attempt${attemptsLeft !== 1 ? "s" : ""} remaining.`,
                }),
                { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // ── Mark OTP as used ────────────────────────────────────
        await supabase
            .from("otp_codes")
            .update({ used: true })
            .eq("id", otpRow.id);

        // ── Find or create Supabase Auth user ───────────────────
        const phoneWithoutPlus = normalizedPhone.replace("+", "");
        const fakeEmail = `phone_${phoneWithoutPlus}@waddek.lk`;

        let userId: string;
        let isNewUser = false;

        // Search auth users — phone might be stored with or without '+'
        const { data: allUsers } = await supabase.auth.admin.listUsers({
            page: 1,
            perPage: 50,
        });

        const existingUser = allUsers?.users?.find(
            (u: any) => u.phone === normalizedPhone ||
                u.phone === phoneWithoutPlus ||
                u.email === fakeEmail
        );

        if (existingUser) {
            userId = existingUser.id;
        } else {
            // Create new user
            isNewUser = true;
            const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
                phone: normalizedPhone,
                email: fakeEmail,
                phone_confirm: true,
                email_confirm: true,
            });

            if (createError) {
                // Handle phone_exists — user exists but phone format didn't match
                if (createError.message?.includes("phone_exists") ||
                    createError.message?.includes("already registered")) {
                    const { data: retryUsers } = await supabase.auth.admin.listUsers({
                        page: 1,
                        perPage: 200,
                    });
                    const retryUser = retryUsers?.users?.find(
                        (u: any) => u.phone?.replace("+", "") === phoneWithoutPlus
                    );
                    if (retryUser) {
                        userId = retryUser.id;
                        isNewUser = false;
                    } else {
                        console.error("Phone exists but user not found:", createError);
                        return new Response(
                            JSON.stringify({ error: "Account conflict. Contact support." }),
                            { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                        );
                    }
                } else {
                    console.error("Failed to create user:", createError);
                    return new Response(
                        JSON.stringify({ error: "Failed to create account" }),
                        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                    );
                }
            } else if (newUser?.user) {
                userId = newUser.user.id;
            } else {
                return new Response(
                    JSON.stringify({ error: "Failed to create account" }),
                    { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }
        }

        // ── Generate session via magic link ──────────────────────
        // Ensure user has the fake email for magic link generation
        const { error: updateErr } = await supabase.auth.admin.updateUserById(userId, {
            email: fakeEmail,
            email_confirm: true,
        });

        if (updateErr) {
            console.error("Failed to update user email:", updateErr);
        }

        const { data: linkData, error: linkError } =
            await supabase.auth.admin.generateLink({
                type: "magiclink",
                email: fakeEmail,
            });

        if (linkError) {
            console.error("Failed to generate link:", linkError);
            // Still return success — the user is verified, just can't auto-login
            return new Response(
                JSON.stringify({
                    success: true,
                    user_id: userId,
                    phone: normalizedPhone,
                    is_new_user: isNewUser,
                    message: "OTP verified successfully",
                }),
                { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Extract token from the action link  
        const actionLink = linkData?.properties?.action_link ?? "";
        const tokenHash = new URL(actionLink).searchParams.get("token") ??
            actionLink.split("token=")[1]?.split("&")[0] ?? "";

        // Verify the token to get a real session
        const { data: sessionData, error: sessionError } = await supabase.auth.verifyOtp({
            token_hash: tokenHash,
            type: "magiclink",
        });

        if (sessionError || !sessionData?.session) {
            console.error("Failed to verify magic link:", sessionError);
            return new Response(
                JSON.stringify({
                    success: true,
                    user_id: userId,
                    phone: normalizedPhone,
                    is_new_user: isNewUser,
                    message: "OTP verified successfully",
                }),
                { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        return new Response(
            JSON.stringify({
                success: true,
                user_id: userId,
                phone: normalizedPhone,
                is_new_user: isNewUser,
                access_token: sessionData.session.access_token,
                refresh_token: sessionData.session.refresh_token,
                message: "OTP verified successfully",
            }),
            { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    } catch (err) {
        console.error("verify-otp error:", err);
        return new Response(
            JSON.stringify({ error: "Internal server error" }),
            { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    }
});
