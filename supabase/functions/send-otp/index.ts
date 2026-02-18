// supabase/functions/send-otp/index.ts
// Generates a 6-digit OTP, stores SHA-256 hash in DB, sends SMS via Notify.lk
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// Notify.lk credentials
const NOTIFY_USER_ID = Deno.env.get("NOTIFY_USER_ID") ?? "31034";
const NOTIFY_API_KEY = Deno.env.get("NOTIFY_API_KEY") ?? "HkubYfywhy71W4hpm0em";
const NOTIFY_SENDER_ID = Deno.env.get("NOTIFY_SENDER_ID") ?? "NotifyDEMO";

const OTP_EXPIRY_MINUTES = 5;
const MAX_OTPS_PER_HOUR = 5;

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
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { phone } = await req.json();
    if (!phone || typeof phone !== "string") {
      return new Response(
        JSON.stringify({ success: false, error: "Phone number is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Normalize phone to +94 format
    let normalizedPhone = phone.replace(/[\s\-]/g, "");
    if (normalizedPhone.startsWith("0")) {
      normalizedPhone = "+94" + normalizedPhone.substring(1);
    } else if (normalizedPhone.startsWith("94") && !normalizedPhone.startsWith("+94")) {
      normalizedPhone = "+" + normalizedPhone;
    } else if (!normalizedPhone.startsWith("+94")) {
      normalizedPhone = "+94" + normalizedPhone;
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // ── Rate limit check ────────────────────────────────────
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();
    const { count } = await supabase
      .from("otp_codes")
      .select("*", { count: "exact", head: true })
      .eq("phone", normalizedPhone)
      .gte("created_at", oneHourAgo);

    if ((count ?? 0) >= MAX_OTPS_PER_HOUR) {
      return new Response(
        JSON.stringify({ success: false, error: "Too many OTP requests. Try again in an hour." }),
        { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── Generate OTP ────────────────────────────────────────
    const code = String(Math.floor(100000 + Math.random() * 900000)); // 6 digits
    const codeHash = await sha256(code);
    const expiresAt = new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000).toISOString();

    // ── Store in DB ─────────────────────────────────────────
    const { error: insertError } = await supabase.from("otp_codes").insert({
      phone: normalizedPhone,
      code_hash: codeHash,
      expires_at: expiresAt,
    });

    if (insertError) {
      console.error("Failed to insert OTP:", insertError);
      return new Response(
        JSON.stringify({ success: false, error: "Failed to generate OTP" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── Send SMS via Notify.lk ──────────────────────────────
    // Notify.lk expects local format (07xxxxxxxx)
    let smsPhone = normalizedPhone;
    if (smsPhone.startsWith("+94")) {
      smsPhone = "0" + smsPhone.substring(3);
    }

    const message = `Your Waddek verification code is ${code}. Valid for ${OTP_EXPIRY_MINUTES} minutes.`;

    const notifyUrl = new URL("https://app.notify.lk/api/v1/send");
    notifyUrl.searchParams.set("user_id", NOTIFY_USER_ID);
    notifyUrl.searchParams.set("api_key", NOTIFY_API_KEY);
    notifyUrl.searchParams.set("sender_id", NOTIFY_SENDER_ID);
    notifyUrl.searchParams.set("to", smsPhone);
    notifyUrl.searchParams.set("message", message);

    const smsResponse = await fetch(notifyUrl.toString());
    const smsResult = await smsResponse.json();

    if (smsResult.status !== "success" && smsResult.status !== 200) {
      console.error("Notify.lk error:", smsResult);
      // Don't fail — OTP is stored, SMS delivery is best-effort
    }

    return new Response(
      JSON.stringify({ success: true, expiresIn: OTP_EXPIRY_MINUTES * 60 }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error("send-otp error:", err);
    return new Response(
      JSON.stringify({ success: false, error: "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
