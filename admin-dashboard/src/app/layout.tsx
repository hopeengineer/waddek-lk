import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Waddek.lk",
  description: "On-demand service marketplace for Sri Lanka",
  icons: { icon: "/favicon.png" },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <base href="/" />
      </head>
      <body>
        {children}
      </body>
    </html>
  );
}
