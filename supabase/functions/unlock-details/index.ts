// supabase/functions/unlock-details/index.ts
// Hybrid check: subscription → else wallet → reveal contact details.
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const LEAD_FEE = 75; // Rs. 75 per lead unlock for PAYG workers

serve(async (req) => {
    if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

    try {
        const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
        const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
        const supabase = createClient(supabaseUrl, serviceRoleKey);

        const { job_id, bid_id, worker_id } = await req.json();
        if (!job_id || !bid_id || !worker_id) {
            throw new Error("job_id, bid_id, and worker_id are required");
        }

        // 1. Idempotency check
        const idempotencyKey = `unlock:${job_id}:${worker_id}`;
        const { data: existing } = await supabase
            .from("transactions")
            .select("id")
            .eq("idempotency_key", idempotencyKey)
            .maybeSingle();

        if (existing) {
            // Already unlocked — return customer details
            const { data: job } = await supabase
                .from("jobs")
                .select("*, customer:profiles!customer_id(full_name, phone)")
                .eq("id", job_id)
                .single();
            return jsonResponse({
                success: true,
                already_unlocked: true,
                customer_phone: job?.customer?.phone,
                customer_name: job?.customer?.full_name,
            });
        }

        // 2. Check for active subscription first
        let wasFree = false;
        const { data: subscription } = await supabase
            .from("subscriptions")
            .select("*, plan:subscription_plans!plan_id(unlock_cap)")
            .eq("worker_id", worker_id)
            .eq("status", "active")
            .gt("current_period_end", new Date().toISOString())
            .maybeSingle();

        if (subscription) {
            const cap = subscription.plan?.unlock_cap || 50;
            if (subscription.unlocks_used < cap) {
                // Pro Pass — free unlock
                wasFree = true;

                // Increment unlocks_used
                await supabase
                    .from("subscriptions")
                    .update({ unlocks_used: subscription.unlocks_used + 1 })
                    .eq("id", subscription.id);

                // Record as free transaction
                const { data: wallet } = await supabase
                    .from("wallets")
                    .select("id, balance")
                    .eq("user_id", worker_id)
                    .single();

                await supabase.from("transactions").insert({
                    wallet_id: wallet?.id,
                    type: "lead_fee",
                    amount: 0,
                    balance_after: wallet?.balance || 0,
                    description: "Pro Pass — free unlock",
                    job_id,
                    idempotency_key: idempotencyKey,
                });
            }
            // If cap exceeded, fall through to PAYG
        }

        // 3. PAYG path (no subscription or cap exceeded)
        if (!wasFree) {
            const { data: wallet, error: walletErr } = await supabase
                .from("wallets")
                .select("*")
                .eq("user_id", worker_id)
                .single();

            if (walletErr || !wallet) throw new Error("Wallet not found");

            if (wallet.balance < LEAD_FEE) {
                return jsonResponse(
                    { success: false, error: "insufficient_balance", balance: wallet.balance },
                    400
                );
            }

            const newBalance = wallet.balance - LEAD_FEE;

            // Deduct wallet (optimistic locking)
            const { error: updateErr } = await supabase
                .from("wallets")
                .update({ balance: newBalance, version: wallet.version + 1 })
                .eq("id", wallet.id)
                .eq("version", wallet.version);

            if (updateErr) throw new Error("Wallet deduction failed — retry");

            // Record transaction
            await supabase.from("transactions").insert({
                wallet_id: wallet.id,
                type: "lead_fee",
                amount: -LEAD_FEE,
                balance_after: newBalance,
                description: `Lead fee — Rs. ${LEAD_FEE}`,
                job_id,
                idempotency_key: idempotencyKey,
            });
        }

        // 4. Match worker to job + accept bid + reject other bids
        await supabase
            .from("jobs")
            .update({ status: "matched", matched_worker_id: worker_id })
            .eq("id", job_id);

        await supabase
            .from("bids")
            .update({ status: "accepted" })
            .eq("id", bid_id);

        await supabase
            .from("bids")
            .update({ status: "rejected" })
            .eq("job_id", job_id)
            .neq("id", bid_id)
            .eq("status", "pending");

        // 5. Fetch customer details to return
        const { data: job } = await supabase
            .from("jobs")
            .select("*, customer:profiles!customer_id(full_name, phone)")
            .eq("id", job_id)
            .single();

        // 6. Notifications
        await supabase.from("notifications").insert([
            {
                user_id: worker_id,
                type: "job_matched",
                title: "Job unlocked! 🔓",
                body: `Contact details revealed. Call ${job?.customer?.full_name} to discuss the job.`,
                data: { job_id },
            },
            {
                user_id: job?.customer_id,
                type: "job_matched",
                title: "Worker confirmed! 👷",
                body: "Your matched worker will contact you shortly.",
                data: { job_id },
            },
        ]);

        return jsonResponse({
            success: true,
            customer_phone: job?.customer?.phone,
            customer_name: job?.customer?.full_name,
            was_free: wasFree,
        });
    } catch (err) {
        console.error("Error:", err);
        return jsonResponse({ error: (err as Error).message }, 400);
    }
});

function jsonResponse(data: any, status = 200) {
    return new Response(JSON.stringify(data), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status,
    });
}
