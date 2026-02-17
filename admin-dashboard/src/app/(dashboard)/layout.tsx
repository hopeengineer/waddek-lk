import Link from "next/link";
import Image from "next/image";

const navItems = [
    { href: "/", label: "Dashboard", icon: "📊" },
    { href: "/workers", label: "Workers", icon: "👷" },
    { href: "/disputes", label: "Disputes", icon: "⚠️" },
    { href: "/users", label: "Users", icon: "👥" },
];

export default function DashboardLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <div className="admin-layout">
            {/* Sidebar */}
            <aside className="sidebar">
                <div className="sidebar-header">
                    <h1 className="brand">
                        <Image src="/admin/logo.png" alt="Waddek" width={36} height={36} className="brand-logo" />
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
                    <form action="/admin/api/auth/logout" method="POST" style={{ marginTop: 8 }}>
                        <button type="submit" className="logout-btn">
                            🚪 Logout
                        </button>
                    </form>
                </div>
            </aside>

            {/* Main Content */}
            <main className="main-content">
                {children}
            </main>
        </div>
    );
}
