// supabase/functions/manage-subscription/index.ts
// Handles Pro Pass subscription lifecycle: activate, renew, fail, cancel.
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
    if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

    try {
        const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
        const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
        const supabase = createClient(supabaseUrl, serviceRoleKey);

        const body = await req.json();
        const { action, worker_id, plan_id, payhere_subscription_id, status_code } = body;

        switch (action) {
            case "activate": {
                // New subscription — first payment successful
                const { data: plan } = await supabase
                    .from("subscription_plans")
                    .select("*")
                    .eq("id", plan_id)
                    .single();

                if (!plan) throw new Error("Plan not found");

                const now = new Date();
                const periodEnd = new Date(now);
                periodEnd.setDate(periodEnd.getDate() + plan.period_days);

                // Deactivate any existing subscription
                await supabase
                    .from("subscriptions")
                    .update({ status: "expired" })
                    .eq("worker_id", worker_id)
                    .eq("status", "active");

                // Create new subscription
                const { error: subErr } = await supabase.from("subscriptions").insert({
                    worker_id,
                    plan_id,
                    status: "active",
                    payhere_subscription_id,
                    current_period_start: now.toISOString(),
                    current_period_end: periodEnd.toISOString(),
                    unlocks_used: 0,
                });

                if (subErr) throw new Error(`Subscription insert error: ${subErr.message}`);

                // Transaction record
                const { data: wallet } = await supabase
                    .from("wallets")
                    .select("id")
                    .eq("user_id", worker_id)
                    .single();

                if (wallet) {
                    await supabase.from("transactions").insert({
                        wallet_id: wallet.id,
                        type: "subscription",
                        amount: -plan.price,
                        description: `Waddek Pro Pass — ${plan.name}`,
                        idempotency_key: `sub_activate:${worker_id}:${now.getTime()}`,
                    });
                }

                // Notification
                await supabase.from("notifications").insert({
                    user_id: worker_id,
                    type: "subscription",
                    title: "Pro Pass Activated! 🔷",
                    body: `Welcome to Waddek Pro! Enjoy zero lead fees for the next ${plan.period_days} days.`,
                    data: { plan_id },
                });

                return jsonResponse({ success: true, status: "active" });
            }

            case "renew": {
                // Auto-renewal — monthly charge successful
                const { data: sub } = await supabase
                    .from("subscriptions")
                    .select("*, plan:subscription_plans!plan_id(*)")
                    .eq("worker_id", worker_id)
                    .eq("payhere_subscription_id", payhere_subscription_id)
                    .single();

                if (!sub) throw new Error("Subscription not found");

                const newPeriodEnd = new Date(sub.current_period_end);
                newPeriodEnd.setDate(newPeriodEnd.getDate() + (sub.plan?.period_days || 30));

                await supabase
                    .from("subscriptions")
                    .update({
                        status: "active",
                        current_period_end: newPeriodEnd.toISOString(),
                        unlocks_used: 0, // Reset monthly counter
                    })
                    .eq("id", sub.id);

                await supabase.from("notifications").insert({
                    user_id: worker_id,
                    type: "subscription",
                    title: "Pro Pass Renewed ✅",
                    body: "Your Waddek Pro Pass has been renewed for another month.",
                });

                return jsonResponse({ success: true, status: "renewed" });
            }

            case "failed": {
                // Payment failed — set to past_due (3-day grace period)
                await supabase
                    .from("subscriptions")
                    .update({ status: "past_due" })
                    .eq("worker_id", worker_id)
                    .eq("payhere_subscription_id", payhere_subscription_id);

                await supabase.from("notifications").insert({
                    user_id: worker_id,
                    type: "subscription",
                    title: "Payment Failed ⚠️",
                    body: "Your Pro Pass payment failed. You have 3 days to resolve this before your subscription expires.",
                });

                return jsonResponse({ success: true, status: "past_due" });
            }

            case "cancel": {
                // Worker-initiated cancellation — stays active until period end
                await supabase
                    .from("subscriptions")
                    .update({ cancelled_at: new Date().toISOString() })
                    .eq("worker_id", worker_id)
                    .eq("status", "active");

                await supabase.from("notifications").insert({
                    user_id: worker_id,
                    type: "subscription",
                    title: "Pro Pass Cancellation",
                    body: "Your Pro Pass won't renew. You'll keep your benefits until the current period ends.",
                });

                return jsonResponse({ success: true, status: "cancelled" });
            }

            default:
                throw new Error(`Unknown action: ${action}`);
        }
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
