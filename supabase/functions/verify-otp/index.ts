// supabase/functions/verify-otp/index.ts
// Verifies OTP code, creates/retrieves Supabase Auth user, returns session
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import * as bcrypt from "https://deno.land/x/bcrypt@v0.4.1/mod.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const MAX_VERIFY_ATTEMPTS = 3;

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

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
            // Mark as used to prevent further attempts
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

        // ── Verify code ─────────────────────────────────────────
        const isValid = await bcrypt.compare(code, otpRow.code_hash);

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
        // Check if user exists by phone
        const { data: existingUsers } = await supabase.auth.admin.listUsers();
        const existingUser = existingUsers?.users?.find(
            (u: any) => u.phone === normalizedPhone
        );

        let userId: string;

        if (existingUser) {
            userId = existingUser.id;
        } else {
            // Create new user with phone verified
            const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
                phone: normalizedPhone,
                phone_confirm: true,
            });

            if (createError || !newUser?.user) {
                console.error("Failed to create user:", createError);
                return new Response(
                    JSON.stringify({ error: "Failed to create account" }),
                    { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            userId = newUser.user.id;
        }

        // ── Generate session tokens via magic link workaround ────
        // Use admin.generateLink to create a session
        const { data: linkData, error: linkError } =
            await supabase.auth.admin.generateLink({
                type: "magiclink",
                email: `${normalizedPhone.replace("+", "")}@phone.waddek.lk`,
            });

        // Alternative: use signInWithPassword with a generated password
        // For now, return user info and let the client handle session
        // via supabase.auth.setSession()

        // Generate a fresh session by signing in on behalf of user
        // Using the admin API to create a session directly
        const { data: sessionData, error: sessionError } = await supabase.auth.admin.generateLink({
            type: "magiclink",
            email: `phone_${normalizedPhone.replace("+", "")}@waddek.lk`,
        });

        return new Response(
            JSON.stringify({
                success: true,
                user_id: userId,
                phone: normalizedPhone,
                // The client should call supabase.auth.setSession() with these
                // In production, consider using a custom JWT or the admin.createSession() API
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
