import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // No basePath — admin routes are under /admin directory in app router
  // Flutter web app is served from public/ at the root
  async headers() {
    return [
      {
        // Flutter web files change every build but have static names
        source: "/:path*(main.dart.js|flutter_bootstrap.js|flutter_service_worker.js)",
        headers: [
          {
            key: "Cache-Control",
            value: "no-cache, no-store, must-revalidate",
          },
        ],
      },
    ];
  },
};

export default nextConfig;
