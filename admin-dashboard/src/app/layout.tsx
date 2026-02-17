import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";

export const metadata: Metadata = {
  title: "Waddek Admin Dashboard",
  description: "Admin panel for Waddek.lk — manage workers, disputes, and users",
};

const navItems = [
  { href: "/", label: "Dashboard", icon: "📊" },
  { href: "/workers", label: "Workers", icon: "👷" },
  { href: "/disputes", label: "Disputes", icon: "⚠️" },
  { href: "/users", label: "Users", icon: "👥" },
];

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <div className="admin-layout">
          {/* Sidebar */}
          <aside className="sidebar">
            <div className="sidebar-header">
              <h1 className="brand">
                <span className="brand-icon">⚡</span>
                Waddek
              </h1>
              <span className="brand-sub">Admin Panel</span>
            </div>
            <nav className="sidebar-nav">
              {navItems.map((item) => (
                <Link key={item.href} href={item.href} className="nav-link">
                  <span className="nav-icon">{item.icon}</span>
                  {item.label}
                </Link>
              ))}
            </nav>
            <div className="sidebar-footer">
              <span className="env-badge">
                {process.env.NODE_ENV === "production" ? "🟢 LIVE" : "🟡 DEV"}
              </span>
            </div>
          </aside>

          {/* Main Content */}
          <main className="main-content">
            {children}
          </main>
        </div>
      </body>
    </html>
  );
}
