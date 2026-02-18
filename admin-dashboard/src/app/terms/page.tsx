import type { Metadata } from "next";

export const metadata: Metadata = {
    title: "Terms & Conditions — Waddek.lk",
    description:
        "Business Terms and Conditions for Waddek.lk on-demand service marketplace.",
};

export default function TermsPage() {
    return (
        <div className="policy-page">
            <div className="policy-container">
                <a href="/" className="policy-back">← Back to Waddek.lk</a>

                <h1 className="policy-title">Business Terms &amp; Conditions</h1>
                <p className="policy-updated">Last updated: 18 February 2026</p>

                <section className="policy-section">
                    <h2>1. Introduction</h2>
                    <p>
                        These Terms and Conditions (&quot;Terms&quot;) govern your use of the <strong>Waddek.lk</strong> platform
                        (&quot;Platform&quot;), operated in Sri Lanka. By accessing or using the Platform, you agree
                        to be bound by these Terms. If you do not agree, please do not use the Platform.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>2. About the Platform</h2>
                    <p>
                        Waddek.lk is an on-demand service marketplace that connects customers seeking
                        services with independent service providers across Sri Lanka. We act as an
                        intermediary platform and do not directly provide the listed services.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>3. User Accounts</h2>
                    <ul>
                        <li>You must be at least 18 years old to create an account.</li>
                        <li>You are responsible for maintaining the confidentiality of your account credentials.</li>
                        <li>All information you provide must be accurate and up to date.</li>
                        <li>We reserve the right to suspend or terminate accounts that violate these Terms.</li>
                    </ul>
                </section>

                <section className="policy-section">
                    <h2>4. Service Providers</h2>
                    <ul>
                        <li>Service providers are independent contractors and not employees of Waddek.lk.</li>
                        <li>Service providers must provide valid identification (NIC) for verification.</li>
                        <li>Service providers are responsible for the quality and delivery of their services.</li>
                        <li>Waddek.lk does not guarantee the availability, quality, or reliability of any service provider.</li>
                    </ul>
                </section>

                <section className="policy-section">
                    <h2>5. Payments</h2>
                    <p>
                        All payments on the Platform are processed securely through <strong>PayHere</strong>,
                        a licensed payment gateway in Sri Lanka. By making a payment, you agree to
                        PayHere&apos;s terms and conditions.
                    </p>
                    <ul>
                        <li>Prices for services are listed in Sri Lankan Rupees (LKR).</li>
                        <li>Payment is required at the time of booking confirmation.</li>
                        <li>Waddek.lk may charge a platform/service fee, which will be clearly displayed before payment.</li>
                    </ul>
                </section>

                <section className="policy-section policy-highlight">
                    <h2>6. No Refund Policy</h2>
                    <p>
                        All payments made through the Platform are <strong>final and non-refundable</strong>.
                        Once a transaction is completed, no refunds will be issued under any circumstances.
                    </p>
                    <p>
                        By making a payment on Waddek.lk, you acknowledge and agree that:
                    </p>
                    <ul>
                        <li>All sales and service bookings are final.</li>
                        <li>No refunds, returns, or exchanges will be provided.</li>
                        <li>It is your responsibility to review service details and provider information before confirming a booking.</li>
                    </ul>
                    <p>
                        If you experience an issue with a service, please contact us at
                        <strong> support@waddek.lk</strong> and we will do our best to mediate between you
                        and the service provider.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>7. User Conduct</h2>
                    <p>You agree not to:</p>
                    <ul>
                        <li>Use the Platform for any unlawful purpose.</li>
                        <li>Provide false or misleading information.</li>
                        <li>Harass, abuse, or threaten other users or service providers.</li>
                        <li>Interfere with the proper functioning of the Platform.</li>
                        <li>Attempt to bypass payment systems or security measures.</li>
                    </ul>
                </section>

                <section className="policy-section">
                    <h2>8. Intellectual Property</h2>
                    <p>
                        All content, branding, logos, and technology on the Platform are the property
                        of Waddek.lk and are protected by applicable intellectual property laws.
                        You may not reproduce, distribute, or create derivative works without our
                        written consent.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>9. Limitation of Liability</h2>
                    <p>
                        Waddek.lk is a marketplace platform and is not liable for:
                    </p>
                    <ul>
                        <li>The quality, safety, or legality of services provided by service providers.</li>
                        <li>Any disputes between customers and service providers.</li>
                        <li>Any direct, indirect, incidental, or consequential damages arising from the use of the Platform.</li>
                        <li>Service interruptions or technical issues beyond our control.</li>
                    </ul>
                    <p>
                        Our total liability to you shall not exceed the amount you paid for the
                        specific service in question.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>10. Dispute Resolution</h2>
                    <p>
                        Any disputes arising from these Terms or your use of the Platform shall be
                        resolved through amicable negotiation first. If unresolved, disputes shall be
                        subject to the jurisdiction of the courts of Sri Lanka.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>11. Modifications</h2>
                    <p>
                        We reserve the right to modify these Terms at any time. Changes will be
                        posted on this page with an updated &quot;Last updated&quot; date. Continued use of
                        the Platform after modifications constitutes acceptance of the new Terms.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>12. Governing Law</h2>
                    <p>
                        These Terms are governed by and construed in accordance with the laws of
                        the Democratic Socialist Republic of Sri Lanka.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>13. Contact Us</h2>
                    <p>
                        If you have any questions about these Terms, please contact us at:
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
