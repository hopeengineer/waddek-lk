# Self-contained Flutter web build for Railway.
#
# This Dockerfile does NOT depend on the build context — it clones
# the GitHub repo itself at the exact commit Railway is deploying
# (`RAILWAY_GIT_COMMIT_SHA` is injected by Railway at build time).
# That means the web service's Root Directory setting on Railway
# doesn't matter — whether it's /, /web-deploy, or anything else,
# the build still produces the right artifact.
#
# Set these env vars on the web service so they propagate to the
# Flutter dart-defines at compile time:
#   SUPABASE_URL, SUPABASE_ANON_KEY, GOOGLE_MAPS_API_KEY,
#   ONESIGNAL_APP_ID (optional), DEV_SKIP_2FA (optional, dev-only)

# ---- Stage 1: clone + Flutter build ----
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Railway provides these at build time. Default to `main` so a
# `docker build` outside Railway still produces something useful.
ARG RAILWAY_GIT_COMMIT_SHA=main
ARG RAILWAY_GIT_REPO_URL=https://github.com/hopeengineer/waddek-lk.git

RUN git clone --filter=blob:none "${RAILWAY_GIT_REPO_URL}" . \
 && git checkout "${RAILWAY_GIT_COMMIT_SHA}"

RUN flutter pub get

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
CMD ["sh", "-c", "serve -s public -l ${PORT:-8080} --no-clipboard"]
