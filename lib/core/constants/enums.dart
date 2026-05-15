import 'package:flutter/material.dart';

/// Enums used across the Waddek.lk application.
/// Mirror the Postgres enums defined in the database schema.

enum UserRole {
  customer,
  worker,
  admin;

  bool get isWorker => this == UserRole.worker;
  bool get isCustomer => this == UserRole.customer;
  bool get isAdmin => this == UserRole.admin;
}

enum TierLevel {
  waddek,
  professional,
  supiri;

  String get displayName {
    switch (this) {
      case TierLevel.waddek:
        return 'Waddek';
      case TierLevel.professional:
        return 'Professional';
      case TierLevel.supiri:
        return 'Supiri';
    }
  }

  /// Material icon representing this tier. Replaces the older emoji
  /// glyph in UI; emoji rendering varied wildly across devices/fonts.
  IconData get icon {
    switch (this) {
      case TierLevel.waddek:
        return Icons.bolt;
      case TierLevel.professional:
        return Icons.verified_user;
      case TierLevel.supiri:
        return Icons.workspace_premium;
    }
  }
}

enum JobStatus {
  draft,
  broadcast,
  bidding,
  matched,
  inProgress('in_progress'),
  completed,
  cancelled,
  disputed;

  const JobStatus([this._value]);
  final String? _value;

  String get value => _value ?? name;

  static JobStatus fromString(String s) {
    return JobStatus.values.firstWhere(
      (e) => e.value == s || e.name == s,
      orElse: () => JobStatus.draft,
    );
  }
}

enum BidStatus {
  pending,
  accepted,
  rejected,
  expired;
}

enum TransactionType {
  topUp('top_up'),
  leadFee('lead_fee'),
  refund,
  bonus,
  withdrawal,
  subscription;

  const TransactionType([this._value]);
  final String? _value;

  String get value => _value ?? name;
}

enum SubscriptionStatus {
  none,
  active,
  pastDue('past_due'),
  cancelled,
  expired;

  const SubscriptionStatus([this._value]);
  final String? _value;

  String get value => _value ?? name;

  bool get isActive => this == SubscriptionStatus.active;

  static SubscriptionStatus fromString(String s) {
    return SubscriptionStatus.values.firstWhere(
      (e) => e.value == s || e.name == s,
      orElse: () => SubscriptionStatus.none,
    );
  }
}

enum VerificationStatus {
  unverified,
  pending,
  verified,
  rejected;

  bool get isVerified => this == VerificationStatus.verified;
  bool get isPending => this == VerificationStatus.pending;
}

enum DisputeStatus {
  open,
  underReview('under_review'),
  resolvedCustomer('resolved_customer'),
  resolvedWorker('resolved_worker'),
  closed;

  const DisputeStatus([this._value]);
  final String? _value;

  String get value => _value ?? name;
}

enum NotificationType {
  newJob('new_job'),
  newBid('new_bid'),
  bidAccepted('bid_accepted'),
  bidRejected('bid_rejected'),
  jobMatched('job_matched'),
  jobCompleted('job_completed'),
  reviewReceived('review_received'),
  tierChanged('tier_changed'),
  walletCredited('wallet_credited'),
  subscriptionChanged('subscription_changed'),
  disputeUpdate('dispute_update'),
  system;

  const NotificationType([this._value]);
  final String? _value;

  String get value => _value ?? name;
}
