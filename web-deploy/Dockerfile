# Multi-stage build for the Flutter web app, served as static files.
# Build context is the repo root (so the Dockerfile can see lib/,
# pubspec.yaml, web/, assets/, l10n.yaml). On Railway, set:
#   - Build → Builder: Dockerfile
#   - Build → Dockerfile Path: web-deploy/Dockerfile
#   - Build → Root Directory: / (or leave blank)
# Dart-defines come from build-time ARGs; Railway exposes service
# env vars to the build automatically when using Dockerfile mode,
# so set SUPABASE_URL, SUPABASE_ANON_KEY, GOOGLE_MAPS_API_KEY,
# ONESIGNAL_APP_ID on the web service.

# ---- Stage 1: Flutter build ----
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Resolve dependencies first so this layer caches as long as
# pubspec.yaml/lock haven't changed.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Bring in the rest of the source. We deliberately avoid `COPY . .`
# so admin-dashboard/node_modules and other heavy unrelated paths
# don't blow up the build context.
COPY lib ./lib
COPY web ./web
COPY assets ./assets
COPY l10n.yaml ./l10n.yaml
COPY analysis_options.yaml ./analysis_options.yaml

# Dart-define args — Railway maps service env vars onto these.
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG GOOGLE_MAPS_API_KEY
ARG ONESIGNAL_APP_ID=""
ARG DEV_SKIP_2FA=""

RUN flutter build web --release \
    --dart-define=SUPABASE_URL=${SUPABASE_URL} \
    --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
    --dart-define=GOOGLE_MAPS_API_KEY=${GOOGLE_MAPS_API_KEY} \
    --dart-define=ONESIGNAL_APP_ID=${ONESIGNAL_APP_ID} \
    --dart-define=DEV_SKIP_2FA=${DEV_SKIP_2FA}

# ---- Stage 2: static server ----
FROM node:20-alpine

WORKDIR /app
RUN npm install --global serve@14

COPY --from=build /app/build/web /app/public

EXPOSE 8080
# Railway injects PORT at runtime; default to 8080 for local docker run.
CMD ["sh", "-c", "serve -s public -l ${PORT:-8080} --no-clipboard"]
