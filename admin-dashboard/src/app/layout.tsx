import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Waddek Admin Dashboard",
  description: "Admin panel for Waddek.lk — manage workers, disputes, and users",
  icons: { icon: "/admin/logo.png" },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        {children}
      </body>
    </html>
  );
}
