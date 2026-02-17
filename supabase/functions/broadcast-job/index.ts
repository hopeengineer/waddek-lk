// supabase/functions/broadcast-job/index.ts
// Finds nearest verified workers in the job's category and broadcasts the job.
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

        const { job_id } = await req.json();
        if (!job_id) throw new Error("job_id is required");

        // 1. Fetch job details
        const { data: job, error: jobErr } = await supabase
            .from("jobs")
            .select("*")
            .eq("id", job_id)
            .single();

        if (jobErr || !job) throw new Error(`Job not found: ${jobErr?.message}`);

        // 2. Find nearest verified workers in the job's category
        // PostGIS query: workers within broadcast radius, in the right category,
        // online, verified — prioritize Pro Pass subscribers
        const radiusMeters = (job.broadcast_radius_km || 5) * 1000;

        const { data: workers, error: workersErr } = await supabase.rpc(
            "find_nearby_workers",
            {
                p_job_location: job.location,
                p_category_id: job.category_id,
                p_radius_meters: radiusMeters,
                p_limit: 10,
            }
        );

        if (workersErr) {
            console.error("Worker query error:", workersErr);
            // Fall back to basic query without PostGIS RPC
        }

        const matchedWorkers = workers || [];
        console.log(`Found ${matchedWorkers.length} workers for job ${job_id}`);

        // 3. Create notifications for each matched worker
        if (matchedWorkers.length > 0) {
            const notifications = matchedWorkers.map((w: any) => ({
                user_id: w.id,
                type: "new_job",
                title: `New job: ${job.title}`,
                body: `A customer nearby needs help with ${job.title}. Tap to view and bid.`,
                data: { job_id: job.id, category_id: job.category_id },
            }));

            const { error: notifErr } = await supabase
                .from("notifications")
                .insert(notifications);

            if (notifErr) console.error("Notification insert error:", notifErr);

            // TODO: Send FCM push notifications to each worker's fcm_token
        }

        // 4. Update job status to 'bidding'
        const { error: updateErr } = await supabase
            .from("jobs")
            .update({ status: "bidding" })
            .eq("id", job_id);

        if (updateErr) console.error("Status update error:", updateErr);

        return new Response(
            JSON.stringify({
                success: true,
                workers_notified: matchedWorkers.length,
            }),
            { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
        );
    } catch (err) {
        console.error("Error:", err);
        return new Response(
            JSON.stringify({ error: err.message }),
            { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
        );
    }
});
