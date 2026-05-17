// lib/athlete/feature/campaigns/repository/campaign_subscription_service.dart
//
// Handles the full lifecycle of monthly/recurring campaign donations:
//
//  ┌─────────────────────────────────────────────────────────────────────┐
//  │  FLOW OVERVIEW (Flutterwave tokenized charge)                       │
//  │                                                                     │
//  │  1. User picks "Monthly" in _DonateSheet                           │
//  │  2. startDonation() → initiateDonation() → opens payment screen    │
//  │  3. Flutterwave callback returns `flw_ref` + customer `token`      │
//  │  4. completeDonation() stores the token in:                         │
//  │       campaign_subscriptions/{donorId}_{campaignId}                 │
//  │  5. Cloud Function (scheduled monthly) calls chargeSubscription()  │
//  │     for every active subscription                                   │
//  │  6. On success  → completeDonation() as normal                     │
//  │     On failure  → markSubscriptionFailed() → notify donor          │
//  │  7. Donor can cancel via ManageSubscriptionsScreen                 │
//  └─────────────────────────────────────────────────────────────────────┘
//
//  NOTE: The Cloud Scheduler / Cloud Function that calls
//  `chargeSubscription` lives server-side (Node.js).  This file contains
//  only the Dart/Flutter side: storing tokens, querying subscriptions,
//  and cancellation.

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:afriendorse/athlete/feature/groups/repository/payment_config_service.dart';

// ─────────────────────────────────────────────
//  Model
// ─────────────────────────────────────────────

class CampaignSubscription {
  final String id; // donorId_campaignId
  final String donorId;
  final String donorName;
  final String donorEmail;
  final bool isAnonymous;
  final String campaignId;
  final String campaignTitle;
  final String athleteId;
  final double amount;
  final String status; // active | cancelled | failed | paused
  final String flwToken; // Flutterwave reusable token
  final String flwRef; // original transaction ref
  final DateTime nextChargeDate;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final DateTime? lastChargedAt;
  final int failureCount;
  final String? failureReason;

  CampaignSubscription({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.donorEmail,
    required this.isAnonymous,
    required this.campaignId,
    required this.campaignTitle,
    required this.athleteId,
    required this.amount,
    required this.status,
    required this.flwToken,
    required this.flwRef,
    required this.nextChargeDate,
    required this.createdAt,
    this.cancelledAt,
    this.lastChargedAt,
    this.failureCount = 0,
    this.failureReason,
  });

  bool get isActive => status == 'active';
  bool get isCancelled => status == 'cancelled';

  factory CampaignSubscription.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CampaignSubscription(
      id: doc.id,
      donorId: d['donorId'] ?? '',
      donorName: d['donorName'] ?? 'Anonymous',
      donorEmail: d['donorEmail'] ?? '',
      isAnonymous: d['isAnonymous'] ?? false,
      campaignId: d['campaignId'] ?? '',
      campaignTitle: d['campaignTitle'] ?? '',
      athleteId: d['athleteId'] ?? '',
      amount: (d['amount'] ?? 0).toDouble(),
      status: d['status'] ?? 'active',
      flwToken: d['flwToken'] ?? '',
      flwRef: d['flwRef'] ?? '',
      nextChargeDate:
          (d['nextChargeDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cancelledAt: (d['cancelledAt'] as Timestamp?)?.toDate(),
      lastChargedAt: (d['lastChargedAt'] as Timestamp?)?.toDate(),
      failureCount: d['failureCount'] ?? 0,
      failureReason: d['failureReason'],
    );
  }
}

// ─────────────────────────────────────────────
//  Service
// ─────────────────────────────────────────────

class CampaignSubscriptionService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference get _subs =>
      _db.collection('campaign_subscriptions');

  // ── doc ID convention ──────────────────────────────────────────────────
  static String _docId(String donorId, String campaignId) =>
      '${donorId.trim().toLowerCase()}_${campaignId.trim()}';

  // ─────────────────────────────────────────────
  //  CREATE  —  called by CampaignFirestoreService.completeDonation()
  //             when frequency == 'monthly' and we receive a flwToken.
  // ─────────────────────────────────────────────
  static Future<void> createSubscription({
    required String donorId,
    required String donorName,
    required String donorEmail,
    required bool isAnonymous,
    required String campaignId,
    required String campaignTitle,
    required String athleteId,
    required double amount,
    required String flwToken,
    required String flwRef,
  }) async {
    try {
      final id = _docId(donorId, campaignId);
      final nextCharge = _nextMonthSameDay();

      await _subs.doc(id).set({
        'donorId': donorId.trim().toLowerCase(),
        'donorName': donorName,
        'donorEmail': donorEmail,
        'isAnonymous': isAnonymous,
        'campaignId': campaignId,
        'campaignTitle': campaignTitle,
        'athleteId': athleteId.trim().toLowerCase(),
        'amount': amount,
        'status': 'active',
        'flwToken': flwToken,
        'flwRef': flwRef,
        'nextChargeDate': Timestamp.fromDate(nextCharge),
        'createdAt': FieldValue.serverTimestamp(),
        'lastChargedAt': FieldValue.serverTimestamp(),
        'failureCount': 0,
        'failureReason': null,
        'cancelledAt': null,
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('[SubService] subscription created: $id, next=$nextCharge');
      }
    } catch (e) {
      if (kDebugMode) print('[SubService] createSubscription error: $e');
    }
  }

  // ─────────────────────────────────────────────
  //  CANCEL  —  called from ManageSubscriptionsScreen
  // ─────────────────────────────────────────────
  static Future<bool> cancelSubscription({
    required String donorId,
    required String campaignId,
  }) async {
    try {
      final id = _docId(donorId, campaignId);
      await _subs.doc(id).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) print('[SubService] cancelled: $id');
      return true;
    } catch (e) {
      if (kDebugMode) print('[SubService] cancelSubscription error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  REACTIVATE  —  donor re-enables a cancelled sub
  //  NOTE: Flutterwave tokens do not expire unless the
  //  card itself expires, so reactivation is simply a
  //  status flip + new nextChargeDate.
  // ─────────────────────────────────────────────
  static Future<bool> reactivateSubscription({
    required String donorId,
    required String campaignId,
  }) async {
    try {
      final id = _docId(donorId, campaignId);
      await _subs.doc(id).update({
        'status': 'active',
        'cancelledAt': null,
        'failureCount': 0,
        'failureReason': null,
        'nextChargeDate': Timestamp.fromDate(_nextMonthSameDay()),
      });
      return true;
    } catch (e) {
      if (kDebugMode) print('[SubService] reactivateSubscription error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  CHARGE  —  called by Cloud Function (Node.js) monthly.
  //  Exposed here as a Dart helper so you can also trigger
  //  it manually from an admin panel if needed.
  //
  //  Flutterwave tokenized charge endpoint:
  //  POST https://api.flutterwave.com/v3/tokenized-charges
  // ─────────────────────────────────────────────
  static Future<bool> chargeSubscription({
    required CampaignSubscription sub,
  }) async {
    final config = await PaymentConfigService.getConfig();
    if (config == null || config.secretKey.isEmpty) return false;

    try {
      final ref =
          'monthly_${sub.campaignId}_${sub.donorId}_${DateTime.now().millisecondsSinceEpoch}';

      final response = await http
          .post(
            Uri.parse('https://api.flutterwave.com/v3/tokenized-charges'),
            headers: {
              'Authorization': 'Bearer ${config.secretKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'token': sub.flwToken,
              'currency': config.currency,
              'country': 'NG',
              'amount': sub.amount,
              'email': sub.donorEmail,
              'tx_ref': ref,
              'narration': 'Monthly donation to ${sub.campaignTitle}',
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final status = body['status'] as String? ?? '';
      final dataStatus =
          (body['data'] as Map<String, dynamic>?)?['status'] as String? ?? '';

      if (kDebugMode) {
        print('[SubService] charge → status=$status dataStatus=$dataStatus');
      }

      if (status == 'success' && dataStatus == 'successful') {
        // Update subscription record
        await _subs.doc(sub.id).update({
          'lastChargedAt': FieldValue.serverTimestamp(),
          'nextChargeDate': Timestamp.fromDate(_nextMonthSameDay()),
          'failureCount': 0,
          'failureReason': null,
          'status': 'active',
        });
        return true;
      } else {
        await _markFailed(
          sub.id,
          body['message'] as String? ?? 'Charge failed',
        );
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('[SubService] chargeSubscription error: $e');
      await _markFailed(sub.id, e.toString());
      return false;
    }
  }

  static Future<void> _markFailed(String docId, String reason) async {
    try {
      final snap = await _subs.doc(docId).get();
      if (!snap.exists) return;
      final d = snap.data() as Map<String, dynamic>;
      final count = (d['failureCount'] as int? ?? 0) + 1;

      // Auto-pause after 3 consecutive failures to avoid charging
      // a card that is clearly not working
      final newStatus = count >= 3 ? 'paused' : 'active';

      await _subs.doc(docId).update({
        'failureCount': count,
        'failureReason': reason,
        'status': newStatus,
      });
    } catch (_) {}
  }

  // ─────────────────────────────────────────────
  //  STREAMS & QUERIES
  // ─────────────────────────────────────────────

  /// All subscriptions for a donor (for ManageSubscriptionsScreen)
  static Stream<List<CampaignSubscription>> streamDonorSubscriptions(
    String donorId,
  ) {
    return _subs
        .where('donorId', isEqualTo: donorId.trim().toLowerCase())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => CampaignSubscription.fromDoc(d)).toList(),
        );
  }

  /// All active subscriptions for a campaign (for athlete dashboard)
  static Stream<List<CampaignSubscription>> streamCampaignSubscriptions(
    String campaignId,
  ) {
    return _subs
        .where('campaignId', isEqualTo: campaignId)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => CampaignSubscription.fromDoc(d)).toList(),
        );
  }

  /// Check if a donor already has an active sub for a campaign
  static Future<CampaignSubscription?> getSubscription({
    required String donorId,
    required String campaignId,
  }) async {
    try {
      final doc = await _subs.doc(_docId(donorId, campaignId)).get();
      if (!doc.exists) return null;
      return CampaignSubscription.fromDoc(doc);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────

  /// Returns a DateTime exactly one calendar month from now,
  /// clamped to the last day of the target month if needed.
  static DateTime _nextMonthSameDay() {
    final now = DateTime.now();
    final month = now.month == 12 ? 1 : now.month + 1;
    final year = now.month == 12 ? now.year + 1 : now.year;
    final day = now.day.clamp(1, _daysInMonth(year, month));
    return DateTime(year, month, day, now.hour, now.minute);
  }

  static int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
