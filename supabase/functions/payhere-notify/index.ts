// supabase/functions/payhere-notify/index.ts
// PayHere server callback — verifies payment and credits wallet.
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { crypto } from "https://deno.land/std@0.177.0/crypto/mod.ts";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
    if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

    try {
        const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
        const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
        const merchantSecret = Deno.env.get("PAYHERE_MERCHANT_SECRET")!;
        const supabase = createClient(supabaseUrl, serviceRoleKey);

        // Parse PayHere POST fields
        const formData = await req.formData();
        const merchantId = formData.get("merchant_id") as string;
        const orderId = formData.get("order_id") as string;
        const amount = formData.get("payhere_amount") as string;
        const currency = formData.get("payhere_currency") as string;
        const statusCode = formData.get("status_code") as string;
        const md5sig = formData.get("md5sig") as string;
        const paymentMethod = formData.get("method") as string || "unknown";

        // 1. Verify MD5 signature
        const secretHash = await md5(merchantSecret);
        const localSig = await md5(
            merchantId + orderId + amount + currency + statusCode + secretHash.toUpperCase()
        );
        if (localSig.toUpperCase() !== md5sig.toUpperCase()) {
            console.error("Signature mismatch!");
            return new Response("Forbidden", { status: 403 });
        }

        // 2. Only process successful payments (status_code == 2)
        if (statusCode !== "2") {
            console.log(`Payment not successful. Status: ${statusCode}, Order: ${orderId}`);
            return new Response("OK", { status: 200 });
        }

        // 3. Parse order_id: "waddek_topup_{userId}_{packageId}_{timestamp}"
        const parts = orderId.split("_");
        if (parts.length < 4 || parts[0] !== "waddek" || parts[1] !== "topup") {
            throw new Error(`Invalid order_id format: ${orderId}`);
        }
        const userId = parts[2];
        const packageId = parts[3];

        // 4. Idempotency check
        const idempotencyKey = `payhere:${orderId}`;
        const { data: existing } = await supabase
            .from("transactions")
            .select("id")
            .eq("idempotency_key", idempotencyKey)
            .maybeSingle();

        if (existing) {
            console.log(`Already processed: ${orderId}`);
            return new Response("OK", { status: 200 });
        }

        // 5. Fetch package details
        const { data: pkg, error: pkgErr } = await supabase
            .from("top_up_packages")
            .select("*")
            .eq("id", packageId)
            .single();

        if (pkgErr || !pkg) throw new Error(`Package not found: ${packageId}`);

        const creditAmount = pkg.amount + (pkg.bonus || 0);

        // 6. Credit wallet + insert transaction (atomic)
        // Fetch wallet
        const { data: wallet, error: walletErr } = await supabase
            .from("wallets")
            .select("*")
            .eq("user_id", userId)
            .single();

        if (walletErr || !wallet) throw new Error(`Wallet not found for user: ${userId}`);

        const newBalance = wallet.balance + creditAmount;

        // Update wallet
        const { error: updateErr } = await supabase
            .from("wallets")
            .update({
                balance: newBalance,
                version: wallet.version + 1,
            })
            .eq("id", wallet.id)
            .eq("version", wallet.version); // Optimistic locking

        if (updateErr) throw new Error(`Wallet update failed: ${updateErr.message}`);

        // Insert transaction
        const { error: txErr } = await supabase.from("transactions").insert({
            wallet_id: wallet.id,
            type: "top_up",
            amount: creditAmount,
            balance_after: newBalance,
            description: `Top-up Rs. ${pkg.amount}${pkg.bonus > 0 ? ` + Rs. ${pkg.bonus} bonus` : ""}`,
            payhere_order_id: orderId,
            payment_method: paymentMethod,
            idempotency_key: idempotencyKey,
        });

        if (txErr) console.error("Transaction insert error:", txErr);

        // 7. Notification
        await supabase.from("notifications").insert({
            user_id: userId,
            type: "wallet",
            title: "Top-up successful! 💰",
            body: `Rs. ${creditAmount} added to your Waddek Wallet.`,
            data: { amount: creditAmount, order_id: orderId },
        });

        console.log(`Wallet credited: ${userId} +${creditAmount} (order: ${orderId})`);
        return new Response("OK", { status: 200 });
    } catch (err) {
        console.error("Error:", err);
        return new Response("Error", { status: 500 });
    }
});

async function md5(input: string): Promise<string> {
    const data = new TextEncoder().encode(input);
    const hashBuffer = await crypto.subtle.digest("MD5", data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}
