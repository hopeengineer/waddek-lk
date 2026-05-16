// supabase/functions/places-proxy/index.ts
//
// Server-side proxy for Google Places + Geocoding. We call Google
// from Deno (server origin) so:
//   1. The API key never ships in the Flutter bundle.
//   2. Browser CORS isn't an issue — the client only talks to
//      Supabase, which we control.
//   3. We can scope the Google key tightly to "server applications"
//      in the Cloud Console instead of needing referrer wildcards.
//
// Request body: { op: 'autocomplete' | 'details' | 'geocode' | 'reverse', ...args }
// Responses are passed through verbatim from Google, so the Flutter
// client parses the same shapes regardless of transport.

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";

const GOOGLE_MAPS_API_KEY = Deno.env.get("GOOGLE_MAPS_API_KEY") ?? "";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(status: number, body: unknown) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json(405, { error: "Method not allowed" });
  }
  if (!GOOGLE_MAPS_API_KEY) {
    return json(500, {
      error:
        "GOOGLE_MAPS_API_KEY secret is not set on the Supabase project.",
    });
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json(400, { error: "Invalid JSON" });
  }
  const op = String(body.op ?? "");

  try {
    if (op === "autocomplete") {
      const input = String(body.input ?? "").trim();
      if (!input) return json(200, { suggestions: [] });
      const res = await fetch(
        "https://places.googleapis.com/v1/places:autocomplete",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-Goog-Api-Key": GOOGLE_MAPS_API_KEY,
          },
          body: JSON.stringify({
            input,
            includedRegionCodes: ["lk"],
          }),
        }
      );
      const data = await res.json();
      return json(res.status, data);
    }

    if (op === "details") {
      const placeId = String(body.placeId ?? "").trim();
      if (!placeId) return json(400, { error: "placeId required" });
      const res = await fetch(
        `https://places.googleapis.com/v1/places/${encodeURIComponent(placeId)}`,
        {
          headers: {
            "X-Goog-Api-Key": GOOGLE_MAPS_API_KEY,
            "X-Goog-FieldMask": "location,formattedAddress",
          },
        }
      );
      const data = await res.json();
      return json(res.status, data);
    }

    if (op === "geocode") {
      const address = String(body.address ?? "").trim();
      if (!address) return json(400, { error: "address required" });
      const url = new URL("https://maps.googleapis.com/maps/api/geocode/json");
      url.searchParams.set("address", address);
      url.searchParams.set("components", "country:lk");
      url.searchParams.set("key", GOOGLE_MAPS_API_KEY);
      const res = await fetch(url.toString());
      const data = await res.json();
      return json(res.status, data);
    }

    if (op === "reverse") {
      const lat = Number(body.lat);
      const lng = Number(body.lng);
      if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
        return json(400, { error: "lat/lng required" });
      }
      const url = new URL("https://maps.googleapis.com/maps/api/geocode/json");
      url.searchParams.set("latlng", `${lat},${lng}`);
      url.searchParams.set("key", GOOGLE_MAPS_API_KEY);
      const res = await fetch(url.toString());
      const data = await res.json();
      return json(res.status, data);
    }

    return json(400, { error: `Unknown op: ${op}` });
  } catch (e) {
    return json(502, { error: `Upstream call failed: ${e}` });
  }
});
