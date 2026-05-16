// supabase/functions/recover-account-by-id/index.ts
// Account-recovery flow after a duplicate_detected verification.
//
// Scenario: A new auth user Y completes Shufti verification. The
// callback sees that the document already belongs to user X and sets
// Y.verification_status = 'duplicate_detected', Y.duplicate_target_user_id = X.id.
// The Flutter app shows the user the choice:
//   * "Log in to the existing account" — just signs out, returns to login.
//   * "Recover" — calls this function.
//
// What this does:
//   1. Confirms the caller is the duplicate Y, not someone trying to
//      hijack X. Y must currently be flagged duplicate_detected with
//      duplicate_target_user_id = the supplied target_user_id.
//   2. Transfers Y's phone (and email if present) onto X via
//      auth.admin.updateUserById.
//   3. Deletes Y's auth user (cascade deletes Y's profile row).
//   4. Returns a magic-link action_link for X so the client can
//      establish a session as X without an OTP round-trip.

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader.startsWith("Bearer ")) {
      return json({ error: "Authentication required." }, 401);
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const { data: { user: caller }, error: userErr } = await supabase.auth
      .getUser(authHeader.substring("Bearer ".length));
    if (userErr || !caller) {
      return json({ error: "Invalid session." }, 401);
    }

    // ── Verify the caller is actually in a duplicate_detected state.
    const { data: callerProfile, error: callerErr } = await supabase
      .from("profiles")
      .select("id, verification_status, duplicate_target_user_id")
      .eq("id", caller.id)
      .single();

    if (callerErr || !callerProfile) {
      return json({ error: "Profile not found." }, 404);
    }

    if (callerProfile.verification_status !== "duplicate_detected") {
      return json({
        error: "No duplicate detected for this account.",
      }, 400);
    }

    const targetUserId = callerProfile.duplicate_target_user_id;
    if (!targetUserId) {
      return json({ error: "Recovery target missing." }, 400);
    }

    // ── Pull the new phone/email from the caller's auth.users row.
    const { data: callerAuth, error: callerAuthErr } = await supabase.auth
      .admin.getUserById(caller.id);
    if (callerAuthErr || !callerAuth?.user) {
      return json({ error: "Could not load caller account." }, 500);
    }
    const newPhone = callerAuth.user.phone ?? null;
    const newEmail = callerAuth.user.email ?? null;

    // ── Pull the target's existing auth.users to remember the old
    // phone/email (used for restore if anything below fails).
    const { data: targetAuth, error: targetAuthErr } = await supabase.auth
      .admin.getUserById(targetUserId);
    if (targetAuthErr || !targetAuth?.user) {
      return json({ error: "Recovery target not found." }, 404);
    }
    const oldTargetPhone = targetAuth.user.phone ?? null;
    const oldTargetEmail = targetAuth.user.email ?? null;

    // ── Step 1: free up the caller's phone/email so they can be moved
    // onto the target without unique-constraint collisions.
    // (Setting to a sentinel; the caller account gets deleted at the
    // end anyway.)
    const sentinelPhone = newPhone ? `freed_${Date.now()}_${newPhone}` : null;
    const sentinelEmail = newEmail ? `freed_${Date.now()}_${newEmail}` : null;

    const { error: freeErr } = await supabase.auth.admin.updateUserById(
      caller.id,
      {
        phone: sentinelPhone ?? undefined,
        email: sentinelEmail ?? undefined,
      },
    );
    if (freeErr) {
      console.error("[recover] could not free caller identifiers:", freeErr);
      return json({ error: "Could not prepare recovery." }, 500);
    }

    // ── Step 2: move the caller's phone/email onto the target.
    const { error: moveErr } = await supabase.auth.admin.updateUserById(
      targetUserId,
      {
        phone: newPhone ?? undefined,
        email: newEmail ?? undefined,
        phone_confirm: !!newPhone,
        email_confirm: !!newEmail,
      },
    );
    if (moveErr) {
      console.error("[recover] phone/email move failed:", moveErr);
      // Best-effort rollback: restore caller's original phone/email.
      await supabase.auth.admin.updateUserById(caller.id, {
        phone: newPhone ?? undefined,
        email: newEmail ?? undefined,
      });
      return json({ error: "Could not transfer phone/email." }, 500);
    }

    // ── Step 3: delete the caller's auth user. The profile row is
    // wiped by ON DELETE CASCADE (see profiles.id FK in 00002_create_tables).
    const { error: delErr } = await supabase.auth.admin.deleteUser(caller.id);
    if (delErr) {
      console.error("[recover] caller delete failed:", delErr);
      // Try to roll back the phone/email move on the target.
      await supabase.auth.admin.updateUserById(targetUserId, {
        phone: oldTargetPhone ?? undefined,
        email: oldTargetEmail ?? undefined,
      });
      return json({ error: "Could not finalize recovery." }, 500);
    }

    // ── Step 4: issue a magic link so the client can sign in as the
    // recovered account without an OTP round-trip.
    const linkEmail = newEmail ??
      `phone_${(newPhone ?? "").replace("+", "")}@waddek.lk`;
    const { data: linkData, error: linkErr } = await supabase.auth.admin
      .generateLink({
        type: "magiclink",
        email: linkEmail,
      });

    if (linkErr || !linkData) {
      console.error("[recover] generateLink failed:", linkErr);
      // The recovery itself succeeded; the user can log in normally
      // with their phone/password.
      return json({
        success: true,
        target_user_id: targetUserId,
        message: "Recovery complete. Please log in with your phone.",
      }, 200);
    }

    return json({
      success: true,
      target_user_id: targetUserId,
      // The Flutter client passes this hash to auth.verifyOtp.
      action_link: linkData.properties?.action_link,
      token_hash: linkData.properties?.hashed_token,
    }, 200);
  } catch (err) {
    console.error("[recover-account-by-id] error:", err);
    return json({ error: "Internal server error." }, 500);
  }
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
