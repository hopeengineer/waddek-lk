import type { Metadata, Viewport } from "next";
import Script from "next/script";

export const metadata: Metadata = {
    title: "Waddek.lk — Service Marketplace",
    description:
        "On-demand service marketplace for Sri Lanka. Find trusted workers or earn as a professional.",
    icons: { icon: "/favicon.png" },
    manifest: "/manifest.json",
    appleWebApp: {
        capable: true,
        statusBarStyle: "black-translucent",
        title: "Waddek",
    },
};

export const viewport: Viewport = {
    width: "device-width",
    initialScale: 1,
    maximumScale: 1,
    userScalable: false,
    themeColor: "#0F0F24",
};

export default function FlutterAppPage() {
    return (
        <>
            <link rel="apple-touch-icon" href="/icons/Icon-192.png" />
            <Script src="/flutter_bootstrap.js" strategy="afterInteractive" />
        </>
    );
}
