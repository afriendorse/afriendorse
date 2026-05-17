// lib/athlete/feature/campaigns/repository/campaign_notification_service.dart
//
// Sends FCM push notifications for all campaign donation events:
//
//  • Donor   → donation confirmed (one-time & monthly setup)
//  • Donor   → monthly charge processed / failed
//  • Donor   → subscription cancelled confirmation
//  • Athlete → new donation received
//  • Athlete → monthly charge succeeded for their campaign
//  • Athlete → milestone unlocked 🎉
//
// Architecture note
// ─────────────────
// FCM v1 (HTTP API) requires a service-account OAuth2 token, which means
// the *actual* FCM send call must go through your backend / Cloud Function
// (the secret key cannot live in the Flutter app).
//
// This service therefore writes a `notification_queue` document in
// Firestore.  A lightweight Cloud Function (Node.js) watches the
// collection, sends the FCM message, then marks it delivered.
//
// This pattern keeps the client code clean and lets you retry/log
// server-side without shipping secrets to the app.
//
// Firestore schema:
//   notification_queue/{autoId}
//     recipientUid  : string   — Firestore UID or email (your FCM token lookup key)
//     recipientType : string   — 'donor' | 'athlete'
//     title         : string
//     body          : string
//     data          : map      — arbitrary k/v passed through to the app
//     status        : string   — 'pending' | 'sent' | 'failed'
//     createdAt     : timestamp
//     sentAt        : timestamp?

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CampaignNotificationService {
  static final _db = FirebaseFirestore.instance;
  static CollectionReference get _queue => _db.collection('notification_queue');

  // ─────────────────────────────────────────────
  //  Internal helper
  // ─────────────────────────────────────────────

  static Future<void> _enqueue({
    required String recipientUid,
    required String recipientType,
    required String title,
    required String body,
    Map<String, String> data = const {},
  }) async {
    try {
      await _queue.add({
        'recipientUid': recipientUid,
        'recipientType': recipientType,
        'title': title,
        'body': body,
        'data': data,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'sentAt': null,
      });
      if (kDebugMode) {
        print('[CampaignNotif] queued → $recipientType $title');
      }
    } catch (e) {
      // Notifications are best-effort — never throw
      if (kDebugMode) print('[CampaignNotif] enqueue error: $e');
    }
  }

  // ─────────────────────────────────────────────
  //  DONOR NOTIFICATIONS
  // ─────────────────────────────────────────────

  /// Sent immediately after a one-time donation completes.
  static Future<void> notifyDonorOneTimeSuccess({
    required String donorId,
    required String campaignTitle,
    required double amount,
    required String currencySymbol,
  }) async {
    await _enqueue(
      recipientUid: donorId,
      recipientType: 'donor',
      title: 'Donation Confirmed 🎉',
      body:
          'Your $currencySymbol${_fmt(amount)} donation to "$campaignTitle" was received. Thank you!',
      data: {
        'type': 'donation_confirmed',
        'campaignTitle': campaignTitle,
        'amount': amount.toString(),
      },
    );
  }

  /// Sent after the first payment of a monthly subscription.
  static Future<void> notifyDonorMonthlySetup({
    required String donorId,
    required String campaignTitle,
    required double amount,
    required String currencySymbol,
    required DateTime nextChargeDate,
  }) async {
    final next =
        '${nextChargeDate.day}/${nextChargeDate.month}/${nextChargeDate.year}';
    await _enqueue(
      recipientUid: donorId,
      recipientType: 'donor',
      title: "You're a Monthly Supporter! 🔄",
      body:
          "You're now supporting \"$campaignTitle\" with $currencySymbol${_fmt(amount)}/month. "
          'Next charge: $next.',
      data: {
        'type': 'monthly_setup',
        'campaignTitle': campaignTitle,
        'amount': amount.toString(),
        'nextChargeDate': nextChargeDate.toIso8601String(),
        'screen': 'manage_subscriptions',
      },
    );
  }

  /// Sent every month when a recurring charge succeeds.
  static Future<void> notifyDonorMonthlyCharged({
    required String donorId,
    required String campaignTitle,
    required double amount,
    required String currencySymbol,
    required DateTime nextChargeDate,
  }) async {
    final next =
        '${nextChargeDate.day}/${nextChargeDate.month}/${nextChargeDate.year}';
    await _enqueue(
      recipientUid: donorId,
      recipientType: 'donor',
      title: 'Monthly Donation Processed ✅',
      body:
          '$currencySymbol${_fmt(amount)} donated to "$campaignTitle". Next charge: $next.',
      data: {
        'type': 'monthly_charged',
        'campaignTitle': campaignTitle,
        'amount': amount.toString(),
        'screen': 'manage_subscriptions',
      },
    );
  }

  /// Sent when a monthly charge fails.
  static Future<void> notifyDonorChargeFailed({
    required String donorId,
    required String campaignTitle,
    required double amount,
    required String currencySymbol,
    required int failureCount,
  }) async {
    final pausing = failureCount >= 3;
    await _enqueue(
      recipientUid: donorId,
      recipientType: 'donor',
      title: pausing ? 'Monthly Donation Paused ⚠️' : 'Monthly Charge Failed ❌',
      body: pausing
          ? 'We couldn\'t charge your card for "$campaignTitle" after 3 attempts. '
                'Your subscription has been paused. Please update your payment method.'
          : 'We couldn\'t process your $currencySymbol${_fmt(amount)} donation to '
                '"$campaignTitle". We\'ll retry next month.',
      data: {
        'type': 'charge_failed',
        'campaignTitle': campaignTitle,
        'isPaused': pausing.toString(),
        'screen': 'manage_subscriptions',
      },
    );
  }

  /// Sent when a donor cancels their subscription.
  static Future<void> notifyDonorCancelled({
    required String donorId,
    required String campaignTitle,
    required double amount,
    required String currencySymbol,
  }) async {
    await _enqueue(
      recipientUid: donorId,
      recipientType: 'donor',
      title: 'Subscription Cancelled',
      body:
          'Your monthly $currencySymbol${_fmt(amount)} donation to "$campaignTitle" '
          'has been cancelled. Thank you for your past support!',
      data: {'type': 'subscription_cancelled', 'campaignTitle': campaignTitle},
    );
  }

  // ─────────────────────────────────────────────
  //  ATHLETE NOTIFICATIONS
  // ─────────────────────────────────────────────

  /// Sent to the athlete when any donation completes.
  static Future<void> notifyAthleteNewDonation({
    required String athleteId,
    required String campaignTitle,
    required double amount,
    required String currencySymbol,
    required String donorDisplayName,
    required bool isMonthly,
  }) async {
    await _enqueue(
      recipientUid: athleteId,
      recipientType: 'athlete',
      title: isMonthly
          ? 'New Monthly Supporter! 🔄'
          : 'New Donation Received! 💚',
      body: isMonthly
          ? '$donorDisplayName is now donating $currencySymbol${_fmt(amount)}/month '
                'to "$campaignTitle"!'
          : '$donorDisplayName donated $currencySymbol${_fmt(amount)} '
                'to "$campaignTitle"!',
      data: {
        'type': isMonthly ? 'new_monthly_donor' : 'new_donation',
        'campaignTitle': campaignTitle,
        'amount': amount.toString(),
        'donorName': donorDisplayName,
        'screen': 'campaign_detail',
      },
    );
  }

  /// Sent to the athlete every month when a recurring charge succeeds.
  static Future<void> notifyAthleteMonthlyReceived({
    required String athleteId,
    required String campaignTitle,
    required double amount,
    required String currencySymbol,
    required String donorDisplayName,
  }) async {
    await _enqueue(
      recipientUid: athleteId,
      recipientType: 'athlete',
      title: 'Monthly Donation Received 💚',
      body:
          '$donorDisplayName\'s monthly $currencySymbol${_fmt(amount)} donation '
          'to "$campaignTitle" was processed.',
      data: {
        'type': 'monthly_received',
        'campaignTitle': campaignTitle,
        'amount': amount.toString(),
        'screen': 'campaign_detail',
      },
    );
  }

  /// Sent when a campaign milestone is unlocked.
  static Future<void> notifyAthleteMilestoneUnlocked({
    required String athleteId,
    required String campaignTitle,
    required String milestoneTitle,
    required double milestoneTarget,
    required String currencySymbol,
  }) async {
    await _enqueue(
      recipientUid: athleteId,
      recipientType: 'athlete',
      title: 'Milestone Unlocked! 🏅',
      body:
          '"$campaignTitle" just hit "$milestoneTitle" — '
          '$currencySymbol${_fmt(milestoneTarget)} raised!',
      data: {
        'type': 'milestone_unlocked',
        'campaignTitle': campaignTitle,
        'milestoneTitle': milestoneTitle,
        'screen': 'campaign_detail',
      },
    );
  }

  // ─────────────────────────────────────────────
  //  HELPER
  // ─────────────────────────────────────────────
  static String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
