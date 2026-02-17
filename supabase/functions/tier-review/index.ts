// supabase/functions/tier-review/index.ts
// Called by QStash daily cron — reviews all workers and upgrades/downgrades tiers.
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Tier thresholds (must match app_constants.dart)
const TIERS = {
    supiri: { minJobs: 50, minRating: 4.8 },
    professional: { minJobs: 20, minRating: 4.0 },
    waddek: { minJobs: 0, minRating: 0 }, // default
};

serve(async (req) => {
    if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

    try {
        const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
        const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
        const supabase = createClient(supabaseUrl, serviceRoleKey);

        // Fetch all workers with their current stats
        const { data: workers, error } = await supabase
            .from("profiles")
            .select("id, tier, jobs_completed_count, average_rating")
            .eq("role", "worker");

        if (error) throw new Error(`Query error: ${error.message}`);

        let promoted = 0;
        let demoted = 0;

        for (const worker of workers || []) {
            const jobs = worker.jobs_completed_count || 0;
            const rating = worker.average_rating || 0;
            let newTier: string;

            if (jobs >= TIERS.supiri.minJobs && rating >= TIERS.supiri.minRating) {
                newTier = "supiri";
            } else if (jobs >= TIERS.professional.minJobs && rating >= TIERS.professional.minRating) {
                newTier = "professional";
            } else {
                newTier = "waddek";
            }

            if (newTier !== worker.tier) {
                // Update tier
                await supabase
                    .from("profiles")
                    .update({ tier: newTier })
                    .eq("id", worker.id);

                // Notify worker
                const isPromotion = tierRank(newTier) > tierRank(worker.tier);
                await supabase.from("notifications").insert({
                    user_id: worker.id,
                    type: "system",
                    title: isPromotion
                        ? `🎉 Congratulations! You're now ${newTier.charAt(0).toUpperCase() + newTier.slice(1)} tier!`
                        : `Tier update: You're now ${newTier.charAt(0).toUpperCase() + newTier.slice(1)} tier`,
                    body: isPromotion
                        ? "Keep up the great work! Higher tiers unlock more benefits."
                        : "Complete more jobs and maintain great ratings to level up.",
                });

                if (isPromotion) promoted++;
                else demoted++;
            }
        }

        console.log(`Tier review complete: ${promoted} promoted, ${demoted} demoted, ${(workers || []).length} total workers`);

        return new Response(
            JSON.stringify({
                success: true,
                workers_reviewed: (workers || []).length,
                promoted,
                demoted,
            }),
            { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
        );
    } catch (err) {
        console.error("Error:", err);
        return new Response(
            JSON.stringify({ error: (err as Error).message }),
            { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
        );
    }
});

function tierRank(tier: string): number {
    switch (tier) {
        case "supiri": return 3;
        case "professional": return 2;
        case "waddek": return 1;
        default: return 0;
    }
}
