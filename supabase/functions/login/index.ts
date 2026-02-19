// supabase/functions/login/index.ts
// Authenticates user with phone/email + password, then triggers 2FA OTP
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { identifier, password } = await req.json();

    if (!identifier || !password) {
      return new Response(
        JSON.stringify({ error: "Email/phone and password are required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Determine if identifier is phone or email
    const isPhone = /^(\+?94|0)\d{9}$/.test(identifier.replace(/[\s\-]/g, ""));

    let email: string;
    let phone: string;

    if (isPhone) {
      // Normalize phone to +94 format
      let normalizedPhone = identifier.replace(/[\s\-]/g, "");
      if (normalizedPhone.startsWith("0")) {
        normalizedPhone = "+94" + normalizedPhone.substring(1);
      } else if (normalizedPhone.startsWith("94") && !normalizedPhone.startsWith("+94")) {
        normalizedPhone = "+" + normalizedPhone;
      } else if (!normalizedPhone.startsWith("+94")) {
        normalizedPhone = "+94" + normalizedPhone;
      }
      phone = normalizedPhone;
      
      // Derive the fake email we use for auth
      const phoneWithoutPlus = normalizedPhone.replace("+", "");
      email = `phone_${phoneWithoutPlus}@waddek.lk`;
    } else {
      // It's an email — look up the user's phone from profile
      email = identifier.trim().toLowerCase();
      phone = ""; // Will be set after user lookup
    }

    // ── Authenticate with Supabase Auth ────────────────────
    const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (signInError) {
      console.error("Login failed:", signInError.message);
      return new Response(
        JSON.stringify({ error: "Invalid credentials. Please check your email/phone and password." }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!signInData?.user) {
      return new Response(
        JSON.stringify({ error: "User not found" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── Look up the user's phone number for 2FA ────────────
    if (!phone) {
      // User logged in with email — get phone from profile
      const { data: profile } = await supabase
        .from("profiles")
        .select("phone")
        .eq("id", signInData.user.id)
        .maybeSingle();
      
      phone = profile?.phone ?? signInData.user.phone ?? "";
    }

    if (!phone) {
      return new Response(
        JSON.stringify({ error: "No phone number associated with this account. Contact support." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── Sign out the preliminary session (2FA not yet complete) ──
    // We don't want to give a session without 2FA
    await supabase.auth.admin.signOut(signInData.session?.access_token ?? "");

    // ── Trigger 2FA OTP ──────────────────────────────────────
    // Call our own send-otp function internally
    const sendOtpResponse = await fetch(`${SUPABASE_URL}/functions/v1/send-otp`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        "apikey": SUPABASE_SERVICE_ROLE_KEY,
      },
      body: JSON.stringify({ phone, context: "login_2fa" }),
    });

    const otpResult = await sendOtpResponse.json();

    if (!otpResult.success) {
      return new Response(
        JSON.stringify({ error: otpResult.error ?? "Failed to send 2FA code" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Return success — client should now show 2FA OTP screen
    return new Response(
      JSON.stringify({
        requires_2fa: true,
        phone,
        user_id: signInData.user.id,
        message: "Credentials verified. Enter the OTP sent to your phone.",
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (err) {
    console.error("login error:", err);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
