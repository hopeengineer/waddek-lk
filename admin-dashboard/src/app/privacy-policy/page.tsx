import type { Metadata } from "next";

export const metadata: Metadata = {
    title: "Privacy Policy — Waddek.lk",
    description:
        "Privacy Policy for Waddek.lk on-demand service marketplace.",
};

export default function PrivacyPolicyPage() {
    return (
        <div className="policy-page">
            <div className="policy-container">
                <a href="/" className="policy-back">← Back to Waddek.lk</a>

                <h1 className="policy-title">Privacy Policy</h1>
                <p className="policy-updated">Last updated: 18 February 2026</p>

                <section className="policy-section">
                    <h2>1. Introduction</h2>
                    <p>
                        Welcome to <strong>Waddek.lk</strong> (&quot;we&quot;, &quot;us&quot;, or &quot;our&quot;). We operate an on-demand
                        service marketplace connecting service providers with customers across Sri Lanka.
                        This Privacy Policy explains how we collect, use, disclose, and safeguard your
                        personal information when you use our mobile application and website
                        (collectively, the &quot;Platform&quot;).
                    </p>
                    <p>
                        By accessing or using the Platform, you agree to the terms of this Privacy Policy.
                        If you do not agree, please do not use the Platform.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>2. Information We Collect</h2>
                    <h3>2.1 Personal Information</h3>
                    <ul>
                        <li>Full name</li>
                        <li>Email address</li>
                        <li>Phone number</li>
                        <li>Profile photograph</li>
                        <li>Location / address details</li>
                        <li>National Identity Card (NIC) number (for service providers)</li>
                    </ul>

                    <h3>2.2 Payment Information</h3>
                    <p>
                        Payments are processed securely through our payment partner, <strong>PayHere</strong>.
                        We do not store your full credit/debit card details on our servers.
                        PayHere may collect and store payment information in accordance with their own
                        privacy policy and PCI DSS compliance requirements.
                    </p>

                    <h3>2.3 Usage Data</h3>
                    <ul>
                        <li>Device information (model, operating system, unique device identifiers)</li>
                        <li>Log data (access times, pages viewed, app crashes)</li>
                        <li>Location data (with your permission)</li>
                        <li>Service booking and transaction history</li>
                    </ul>
                </section>

                <section className="policy-section">
                    <h2>3. How We Use Your Information</h2>
                    <ul>
                        <li>To create and manage your account</li>
                        <li>To connect you with service providers or customers</li>
                        <li>To process payments and transactions</li>
                        <li>To send service-related notifications and updates</li>
                        <li>To verify the identity of service providers</li>
                        <li>To improve and personalize the Platform experience</li>
                        <li>To detect and prevent fraud or unauthorized activity</li>
                        <li>To comply with legal obligations</li>
                    </ul>
                </section>

                <section className="policy-section">
                    <h2>4. Information Sharing</h2>
                    <p>We may share your information with:</p>
                    <ul>
                        <li>
                            <strong>Service Providers / Customers:</strong> Limited profile information
                            necessary to facilitate a booking (e.g., name, phone number, location).
                        </li>
                        <li>
                            <strong>Payment Processors:</strong> PayHere, to process your transactions securely.
                        </li>
                        <li>
                            <strong>Legal Authorities:</strong> When required by law or to protect our rights.
                        </li>
                    </ul>
                    <p>We do not sell your personal information to third parties.</p>
                </section>

                <section className="policy-section">
                    <h2>5. Data Security</h2>
                    <p>
                        We implement industry-standard security measures including encryption,
                        secure server infrastructure, and access controls to protect your personal
                        information. However, no method of transmission over the internet is 100% secure,
                        and we cannot guarantee absolute security.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>6. Data Retention</h2>
                    <p>
                        We retain your personal information for as long as your account is active or as
                        needed to provide services. We may also retain data as required by applicable
                        laws and regulations in Sri Lanka.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>7. Your Rights</h2>
                    <p>You have the right to:</p>
                    <ul>
                        <li>Access the personal data we hold about you</li>
                        <li>Request correction of inaccurate information</li>
                        <li>Request deletion of your account and associated data</li>
                        <li>Withdraw consent for location tracking at any time</li>
                    </ul>
                    <p>
                        To exercise any of these rights, please contact us using the details below.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>8. Cookies &amp; Local Storage</h2>
                    <p>
                        The Platform may use cookies and local storage to maintain your session and
                        improve functionality. You can manage cookie preferences through your browser
                        settings.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>9. Children&apos;s Privacy</h2>
                    <p>
                        Our Platform is not intended for use by individuals under the age of 18.
                        We do not knowingly collect personal information from minors.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>10. Changes to This Policy</h2>
                    <p>
                        We may update this Privacy Policy from time to time. Changes will be posted on
                        this page with an updated &quot;Last updated&quot; date. Continued use of the Platform
                        after changes constitutes acceptance.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>11. Contact Us</h2>
                    <p>
                        If you have any questions about this Privacy Policy, please contact us at:
                    </p>
                    <div className="policy-contact">
                        <p><strong>Waddek.lk</strong></p>
                        <p>Email: support@waddek.lk</p>
                        <p>Sri Lanka</p>
                    </div>
                </section>
            </div>
        </div>
    );
}
