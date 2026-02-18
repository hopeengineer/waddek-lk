import type { Metadata } from "next";

export const metadata: Metadata = {
    title: "Returns Policy — Waddek.lk",
    description:
        "Returns and Refund Policy for Waddek.lk on-demand service marketplace.",
};

export default function ReturnsPolicyPage() {
    return (
        <div className="policy-page">
            <div className="policy-container">
                <a href="/" className="policy-back">← Back to Waddek.lk</a>

                <h1 className="policy-title">Returns &amp; Refund Policy</h1>
                <p className="policy-updated">Last updated: 18 February 2026</p>

                <section className="policy-section policy-highlight">
                    <h2>No Returns / No Refunds</h2>
                    <p>
                        <strong>Waddek.lk</strong> is an on-demand service marketplace. As our platform
                        facilitates the provision of services (not physical goods), all transactions
                        are <strong>final and non-refundable</strong>.
                    </p>
                    <p>
                        Once a service booking is confirmed and payment is processed, no returns,
                        refunds, cancellations, or exchanges will be issued under any circumstances.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>Why We Don&apos;t Offer Refunds</h2>
                    <p>
                        Waddek.lk connects customers with independent service providers. Since services
                        are rendered in real-time by independent professionals, the nature of the
                        transaction does not allow for returns or reversals. Service providers commit
                        their time and resources upon booking confirmation.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>Service Disputes</h2>
                    <p>
                        If you are unsatisfied with a service you received, we encourage you to:
                    </p>
                    <ul>
                        <li>Contact the service provider directly through the platform to resolve the issue.</li>
                        <li>
                            If you cannot reach a resolution, contact our support team at
                            <strong> support@waddek.lk</strong> and we will do our best to mediate
                            between you and the service provider.
                        </li>
                    </ul>
                    <p>
                        Please note that mediation does not guarantee a refund or any form of
                        compensation. Resolution outcomes are handled on a case-by-case basis at
                        our sole discretion.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>Payment Processing</h2>
                    <p>
                        All payments are processed securely through <strong>PayHere</strong>. By
                        completing a payment, you acknowledge that you have reviewed the service
                        details, provider information, and pricing before confirming the transaction.
                    </p>
                </section>

                <section className="policy-section">
                    <h2>Contact Us</h2>
                    <p>
                        If you have any questions about this policy, please contact us at:
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
