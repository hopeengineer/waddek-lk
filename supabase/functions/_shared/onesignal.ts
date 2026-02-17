/// OneSignal push notification helper for Supabase Edge Functions.
/// Usage: import { sendPush } from '../_shared/onesignal.ts';

const ONESIGNAL_APP_ID = Deno.env.get('ONESIGNAL_APP_ID') ?? '';
const ONESIGNAL_REST_API_KEY = Deno.env.get('ONESIGNAL_REST_API_KEY') ?? '';

interface PushOptions {
    /** Supabase user ID (external_id in OneSignal) */
    userId: string;
    title: string;
    body: string;
    /** Arbitrary data payload for click handling */
    data?: Record<string, string>;
}

/**
 * Send a push notification to a specific user via OneSignal REST API.
 * The user is targeted by `external_id` (set via `OneSignal.login(userId)` in Flutter).
 */
export async function sendPush({ userId, title, body, data }: PushOptions): Promise<boolean> {
    if (!ONESIGNAL_APP_ID || !ONESIGNAL_REST_API_KEY) {
        console.warn('[OneSignal] Missing ONESIGNAL_APP_ID or ONESIGNAL_REST_API_KEY');
        return false;
    }

    try {
        const res = await fetch('https://api.onesignal.com/notifications', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Key ${ONESIGNAL_REST_API_KEY}`,
            },
            body: JSON.stringify({
                app_id: ONESIGNAL_APP_ID,
                target_channel: 'push',
                include_aliases: { external_id: [userId] },
                headings: { en: title },
                contents: { en: body },
                data: data ?? {},
            }),
        });

        if (!res.ok) {
            const err = await res.text();
            console.error(`[OneSignal] Push failed: ${res.status} — ${err}`);
            return false;
        }

        console.log(`[OneSignal] Push sent to ${userId}: "${title}"`);
        return true;
    } catch (e) {
        console.error(`[OneSignal] Push error: ${e}`);
        return false;
    }
}

/**
 * Send push to multiple users at once.
 */
export async function sendPushBatch(
    notifications: PushOptions[]
): Promise<void> {
    await Promise.allSettled(notifications.map(sendPush));
}
