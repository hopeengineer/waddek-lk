// supabase/functions/shufti-start-verification/index.ts
// Begins a Shufti Pro onsite (hosted-page) identity verification.
// Returns a `verification_url` the Flutter client opens in a browser.
// Costs money per call, so we enforce a 3-attempt lifetime cap with
// a `verification_locked_until` cooldown that only an admin can clear.

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const SHUFTIPRO_CLIENT_ID = Deno.env.get("SHUFTIPRO_CLIENT_ID")!;
const SHUFTIPRO_SECRET_KEY = Deno.env.get("SHUFTIPRO_SECRET_KEY")!;

const SHUFTI_ENDPOINT = "https://api.shuftipro.com/";
const MAX_LIFETIME_ATTEMPTS = 3;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Shufti calls these "supported_types" on the document service.
const DOC_TYPE_TO_SHUFTI: Record<string, string> = {
  nic: "id_card",
  driving_licence: "driving_license",
  passport: "passport",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ── Auth ────────────────────────────────────────────────
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader.startsWith("Bearer ")) {
      return json({ error: "Authentication required." }, 401);
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const { data: { user }, error: userErr } = await supabase.auth.getUser(
      authHeader.substring("Bearer ".length),
    );
    if (userErr || !user) return json({ error: "Invalid session." }, 401);

    // ── Input ───────────────────────────────────────────────
    const { doc_type } = await req.json();
    const shuftiDocType = DOC_TYPE_TO_SHUFTI[doc_type];
    if (!shuftiDocType) {
      return json({
        error: "doc_type must be one of: nic, driving_licence, passport.",
      }, 400);
    }

    // ── Fetch profile + check cap & cooldown ───────────────
    const { data: profile, error: profErr } = await supabase
      .from("profiles")
      .select(
        "id, verification_status, verification_attempts, verification_locked_until, identity_locked",
      )
      .eq("id", user.id)
      .maybeSingle();

    if (profErr) {
      console.error("[start-verification] profile query failed:", profErr);
      return json({
        error: `Could not load profile: ${profErr.message}`,
      }, 500);
    }
    if (!profile) {
      return json({ error: "Profile not found." }, 404);
    }

    if (profile.verification_status === "verified") {
      return json({ error: "Already verified." }, 409);
    }

    if (
      profile.verification_locked_until &&
      new Date(profile.verification_locked_until) > new Date()
    ) {
      return json({
        error:
          "Verification is temporarily locked. Contact support to reset.",
        locked_until: profile.verification_locked_until,
      }, 429);
    }

    if (profile.verification_attempts >= MAX_LIFETIME_ATTEMPTS) {
      // Lock to far future; admin-dashboard clears it.
      await supabase
        .from("profiles")
        .update({
          verification_locked_until: "2099-01-01T00:00:00Z",
        })
        .eq("id", user.id);
      return json({
        error: "Maximum verification attempts reached. Contact support.",
      }, 429);
    }

    // ── Build Shufti payload ────────────────────────────────
    // verification_mode: video_only — selfie video for liveness + match.
    // document.supported_types — restrict to the doc the user chose.
    // dob "" + document_number "" — Shufti extracts these via OCR.
    // fetch_enhanced_data "1" — return the full extracted set (gender,
    // nationality, etc.) on the verification.accepted event.
    const reference = `${user.id}-${Date.now()}`;
    const callbackUrl = `${SUPABASE_URL}/functions/v1/shuftipro-callback`;

    const shuftiBody = {
      reference,
      callback_url: callbackUrl,
      email: user.email ?? "",
      country: "LK",
      language: "EN",
      verification_mode: "video_only",
      show_consent: "1",
      show_results: "1",
      show_privacy_policy: "1",
      document: {
        supported_types: [shuftiDocType],
        name: { first_name: "", last_name: "" },
        dob: "",
        document_number: "",
        fetch_enhanced_data: "1",
      },
      face: {
        proof: "",
      },
    };

    const basicAuth = btoa(`${SHUFTIPRO_CLIENT_ID}:${SHUFTIPRO_SECRET_KEY}`);

    const shuftiRes = await fetch(SHUFTI_ENDPOINT, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Basic ${basicAuth}`,
      },
      body: JSON.stringify(shuftiBody),
    });

    const shuftiJson = await shuftiRes.json();

    if (!shuftiRes.ok || !shuftiJson?.verification_url) {
      console.error("Shufti rejected the request:", shuftiJson);
      return json({
        error: shuftiJson?.error?.message ?? "Could not start verification.",
      }, 502);
    }

    // ── Commit attempt counter + reference ─────────────────
    // verification_status flips to 'pending' so the client knows to
    // start polling. The webhook will move it from there.
    await supabase
      .from("profiles")
      .update({
        verification_status: "pending",
        verification_attempts: profile.verification_attempts + 1,
        shuftipro_reference: reference,
        id_doc_type: doc_type,
        shuftipro_decline_reason: null,
      })
      .eq("id", user.id);

    return json({
      verification_url: shuftiJson.verification_url,
      reference,
      attempts_remaining:
        MAX_LIFETIME_ATTEMPTS - (profile.verification_attempts + 1),
    }, 200);
  } catch (err) {
    console.error("shufti-start-verification error:", err);
    return json({ error: "Internal server error." }, 500);
  }
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
