// supabase/functions/shuftipro-callback/index.ts
// Server-to-server webhook for Shufti Pro. Validates the `Signature`
// header, then applies the verification result to the user's profile.
//
// Signature scheme (per Shufti docs):
//   signature = hex( SHA256( body + hex( SHA256(secret_key) ) ) )
//
// On verification.accepted we:
//   1. Compute id_doc_hash = sha256(doc_type || '|' || document_number)
//   2. Look for any OTHER profile already holding that hash
//      → if found, mark this profile 'duplicate_detected' with
//        duplicate_target_user_id pointing at the original; identity
//        is NOT locked yet — the recovery flow handles that.
//      → if not found, write name/gender/dob/nationality, set
//        verification_status='verified' and identity_locked=true.
//
// On verification.declined we record the reason and leave status
// at 'unverified' so the user can retry (subject to the lifetime cap
// enforced by shufti-start-verification).

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const SHUFTIPRO_SECRET_KEY = Deno.env.get("SHUFTIPRO_SECRET_KEY")!;

async function sha256Hex(input: string): Promise<string> {
  const buf = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(input),
  );
  return Array.from(new Uint8Array(buf))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

async function expectedSignature(body: string): Promise<string> {
  const hashedSecret = await sha256Hex(SHUFTIPRO_SECRET_KEY);
  return sha256Hex(body + hashedSecret);
}

// Shufti sends DOB in `yyyy-mm-dd` per their schema, but document
// quality can yield variants — try a few formats before giving up.
function parseDob(raw: unknown): string | null {
  if (typeof raw !== "string" || !raw.trim()) return null;
  const s = raw.trim();
  // yyyy-mm-dd (ISO)
  if (/^\d{4}-\d{2}-\d{2}$/.test(s)) return s;
  // dd-mm-yyyy or dd/mm/yyyy
  const m = s.match(/^(\d{2})[-/](\d{2})[-/](\d{4})$/);
  if (m) return `${m[3]}-${m[2]}-${m[1]}`;
  return null;
}

function combineName(doc: any): string | null {
  const first = (doc?.name?.first_name ?? "").trim();
  const middle = (doc?.name?.middle_name ?? "").trim();
  const last = (doc?.name?.last_name ?? "").trim();
  const full = [first, middle, last].filter((s) => s.length > 0).join(" ");
  return full.length > 0 ? full : null;
}

function normaliseDocNumber(raw: unknown): string | null {
  if (typeof raw !== "string") return null;
  // Strip whitespace, dashes, dots; uppercase for stability.
  const cleaned = raw.replace(/[\s\-\.]/g, "").toUpperCase();
  return cleaned.length >= 4 ? cleaned : null;
}

serve(async (req: Request) => {
  try {
    const body = await req.text();
    const sigHeader = req.headers.get("Signature") ??
      req.headers.get("signature") ?? "";

    const expected = await expectedSignature(body);
    if (sigHeader.toLowerCase() !== expected.toLowerCase()) {
      console.error("[shuftipro-callback] signature mismatch");
      return new Response("invalid signature", { status: 401 });
    }

    const payload = JSON.parse(body);
    const event = payload.event as string | undefined;
    const reference = payload.reference as string | undefined;

    if (!event || !reference) {
      return new Response("missing event/reference", { status: 400 });
    }

    // reference shape: "<user_id>-<timestamp>" — see start-verification.
    const userId = reference.split("-").slice(0, 5).join("-");

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // We only ack non-terminal events; verification will be retried
    // by the user if Shufti times out.
    if (event !== "verification.accepted" && event !== "verification.declined") {
      console.log(`[shuftipro-callback] ${event} for ${reference} — ignored`);
      return new Response("ok", { status: 200 });
    }

    // Fetch current profile for the user this reference belongs to.
    const { data: profile, error: profErr } = await supabase
      .from("profiles")
      .select("id, id_doc_type, identity_locked, shuftipro_reference")
      .eq("id", userId)
      .maybeSingle();

    if (profErr) {
      console.error("[shuftipro-callback] profile query error:", profErr);
      return new Response(`profile query error: ${profErr.message}`, {
        status: 500,
      });
    }
    if (!profile) {
      console.error("[shuftipro-callback] profile not found for", userId);
      return new Response("profile not found", { status: 404 });
    }

    // Ignore stale callbacks (older reference than the current one).
    if (profile.shuftipro_reference && profile.shuftipro_reference !== reference) {
      console.log(
        `[shuftipro-callback] stale reference ${reference} (current: ${profile.shuftipro_reference}) — ignored`,
      );
      return new Response("stale reference", { status: 200 });
    }

    if (event === "verification.declined") {
      const reason = (payload.declined_reason as string | undefined) ??
        (payload.decline_reason as string | undefined) ??
        "Verification was not accepted.";
      await supabase
        .from("profiles")
        .update({
          verification_status: "unverified",
          shuftipro_decline_reason: reason,
        })
        .eq("id", userId);

      await supabase.from("notifications").insert({
        user_id: userId,
        type: "system",
        title: "Verification declined",
        body: reason,
      });

      return new Response("ok", { status: 200 });
    }

    // ── verification.accepted ─────────────────────────────────
    const doc = payload?.verification_data?.document ?? {};
    const docNumber = normaliseDocNumber(doc.document_number);
    const docType = profile.id_doc_type as string | null;

    if (!docNumber || !docType) {
      // Shufti accepted but didn't return a usable document number.
      // Mark unverified with a clear reason; let the user retry.
      await supabase
        .from("profiles")
        .update({
          verification_status: "unverified",
          shuftipro_decline_reason:
            "Could not read document number — please retry with a clearer image.",
        })
        .eq("id", userId);
      return new Response("ok", { status: 200 });
    }

    const idDocHash = await sha256Hex(`${docType}|${docNumber}`);

    // Dedup check: does any OTHER profile already hold this hash?
    const { data: existing } = await supabase
      .from("profiles")
      .select("id")
      .eq("id_doc_hash", idDocHash)
      .neq("id", userId)
      .maybeSingle();

    const dob = parseDob(doc.dob);
    const fullName = combineName(doc);
    const gender = typeof doc.gender === "string" ? doc.gender : null;
    const nationality = typeof doc.nationality === "string"
      ? doc.nationality
      : null;

    if (existing) {
      // Duplicate — route the user to the recovery flow. We do NOT
      // lock identity or commit the doc hash to this profile; the
      // dedup target keeps its hash, this user gets a recovery
      // pointer to the target.
      await supabase
        .from("profiles")
        .update({
          verification_status: "duplicate_detected",
          duplicate_target_user_id: existing.id,
        })
        .eq("id", userId);

      await supabase.from("notifications").insert({
        user_id: userId,
        type: "system",
        title: "Existing account detected",
        body:
          "This ID is already linked to another account. Open the verification screen to log in or recover it.",
      });

      return new Response("ok", { status: 200 });
    }

    // Clean record — commit verified state and lock identity.
    await supabase
      .from("profiles")
      .update({
        verification_status: "verified",
        identity_locked: true,
        id_doc_hash: idDocHash,
        date_of_birth: dob,
        gender,
        nationality,
        full_name: fullName ?? undefined,
        shuftipro_decline_reason: null,
      })
      .eq("id", userId);

    await supabase.from("notifications").insert({
      user_id: userId,
      type: "system",
      title: "You're verified",
      body: "Your identity has been verified. The verified badge is now visible on your profile.",
    });

    return new Response("ok", { status: 200 });
  } catch (err) {
    console.error("[shuftipro-callback] error:", err);
    return new Response("internal error", { status: 500 });
  }
});
