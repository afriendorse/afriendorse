// lib/athlete/feature/campaigns/repository/campaign_firestore_service.dart
//
// KEY FIX in this version:
//  completeDonation() now calls AthleteWalletOverlayService.applyDonation()
//  after a successful charge so that:
//    • mergedAvailableBalance (availableBalance + donationOverlayBalance) updates
//    • mergedTotalEarned      (totalEarned     + donationOverlayBalance) updates
//
//  mysqlAthleteId is resolved from the `athletes` collection
//  (same collection AthleteFirestoreSyncService.getAthleteByEmail reads),
//  then cached in-memory so repeated donations skip the Firestore read.
//
//  Everything else is identical to the previous version.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:afriendorse/athlete/feature/campaigns/model/campaign_model.dart';
import 'package:afriendorse/athlete/feature/campaigns/repository/campaign_subscription_service.dart';
import 'package:afriendorse/athlete/feature/campaigns/repository/campaign_notification_service.dart';
import 'package:afriendorse/athlete/feature/wallet/widgets/athlete_wallet_overlay_service.dart';
import 'dart:async';

const String _kCurrencySymbol = '₦';

// ── In-memory cache: athleteEmailLower → mysqlAthleteId ───────────────────────
// Avoids repeated Firestore reads for the same athlete within one app session.
final Map<String, String> _mysqlIdCache = {};

class CampaignFirestoreService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference get _campaigns => _db.collection('campaigns');
  static CollectionReference get _donations =>
      _db.collection('campaign_donations');
  static CollectionReference get _profiles =>
      _db.collection('athlete_profiles');

  // ─────────────────────────────────────────────
  //  WALLET OVERLAY HELPER
  //
  //  1. Looks up mysqlAthleteId from athletes/{emailLower}
  //     — same doc that AthleteFirestoreSyncService.getAthleteByEmail() reads.
  //     AthleteFirestoreSyncService first tries the lowercase doc then the
  //     raw-case doc; we replicate that here via _resolveAthleteDocId().
  //
  //  2. Calls AthleteWalletOverlayService.applyDonation() which:
  //       • Increments donationBalance in
  //         athlete_wallet_overlays/{mysqlAthleteId}
  //       • Is idempotent — uses transactionRef as a dedup key, so calling
  //         it twice with the same ref is safe.
  //
  //  3. WalletController._overlaySub fires immediately →
  //     donationOverlayBalance updates →
  //     mergedAvailableBalance & mergedTotalEarned rebuild on the balance card
  //     without requiring a manual refresh.
  // ─────────────────────────────────────────────

  /// Mirrors AthleteFirestoreSyncService._resolveAthleteDocId():
  /// tries lowercase first, then raw-case, falls back to lowercase.
  static Future<String> _resolveAthleteDocId(String email) async {
    final raw = email.trim();
    final lower = raw.toLowerCase();

    final lowerSnap = await _db.collection('athletes').doc(lower).get();
    if (lowerSnap.exists) return lower;

    final rawSnap = await _db.collection('athletes').doc(raw).get();
    if (rawSnap.exists) return raw;

    return lower; // fallback — doc will be created on next sync
  }

  static Future<void> _creditWalletOverlay({
    required String athleteEmailLower,
    required String transactionRef,
    required double amount,
  }) async {
    try {
      // 1. Resolve mysqlAthleteId — use cache to avoid repeated Firestore reads
      String? mysqlId = _mysqlIdCache[athleteEmailLower];

      if (mysqlId == null || mysqlId.isEmpty) {
        final docId = await _resolveAthleteDocId(athleteEmailLower);
        final snap = await _db.collection('athletes').doc(docId).get();

        if (!snap.exists) {
          if (kDebugMode) {
            print(
              '[CampaignFS] _creditWalletOverlay: '
              'no athletes doc for $athleteEmailLower',
            );
          }
          return;
        }

        mysqlId = ((snap.data()?['mysqlAthleteId'] ?? '') as Object)
            .toString()
            .trim();

        if (mysqlId.isEmpty) {
          if (kDebugMode) {
            print(
              '[CampaignFS] _creditWalletOverlay: '
              'mysqlAthleteId is empty for $athleteEmailLower — '
              'athlete may not have completed profile sync yet',
            );
          }
          return;
        }

        // Cache for this app session
        _mysqlIdCache[athleteEmailLower] = mysqlId;
      }

      // 2. Credit the overlay — idempotent via transactionRef dedup key
      await AthleteWalletOverlayService.applyDonation(
        mysqlAthleteId: mysqlId,
        paystackRef: transactionRef, // field name is generic; works for FLW
        amount: amount,
        athleteEmailLower: athleteEmailLower,
      );

      if (kDebugMode) {
        print(
          '[CampaignFS] ✓ wallet overlay credited | '
          'athlete=$athleteEmailLower | mysqlId=$mysqlId | '
          'amount=$amount | ref=$transactionRef',
        );
      }
    } catch (e) {
      // Non-fatal — the campaign_donations + wallet_transactions records are
      // already written. The overlay self-heals next time the athlete opens
      // their wallet and WalletController.refresh() re-runs _initDonationOverlay().
      if (kDebugMode) print('[CampaignFS] _creditWalletOverlay error: $e');
    }
  }

  // ─────────────────────────────────────────────
  //  CREATE CAMPAIGN  (unchanged)
  // ─────────────────────────────────────────────
  static Future<String?> createCampaign({
    required String creatorId,
    required String creatorName,
    String? creatorAvatar,
    required String title,
    required String description,
    required String story,
    required double goalAmount,
    required DateTime endDate,
    required CampaignType type,
    String? groupId,
    String? groupName,
    String? coverImage,
    List<String> tags = const [],
    bool allowAnonymous = true,
    double minimumDonation = 500,
    List<CampaignMilestone>? customMilestones,
  }) async {
    try {
      final creatorIdLower = creatorId.trim().toLowerCase();
      final milestones =
          customMilestones ?? CampaignModel.autoMilestones(goalAmount);

      final ref = _campaigns.doc();
      await ref.set({
        'title': title,
        'description': description,
        'story': story,
        'type': type.name,
        'status': CampaignStatus.active.name,
        'creatorId': creatorIdLower,
        'creatorIdLower': creatorIdLower,
        'creatorName': creatorName,
        'creatorAvatar': creatorAvatar,
        'groupId': groupId,
        'groupName': groupName,
        'goalAmount': goalAmount,
        'raisedAmount': 0.0,
        'donorCount': 0,
        'recurringDonorCount': 0,
        'coverImage': coverImage,
        'mediaUrls': <String>[],
        'startDate': FieldValue.serverTimestamp(),
        'endDate': Timestamp.fromDate(endDate),
        'createdAt': FieldValue.serverTimestamp(),
        'milestones': milestones.map((m) => m.toMap()).toList(),
        'viewCount': 0,
        'tags': tags,
        'allowAnonymous': allowAnonymous,
        'minimumDonation': minimumDonation,
      });

      await _profiles.doc(creatorIdLower).set({
        'campaigns': FieldValue.arrayUnion([ref.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (groupId != null && groupId.isNotEmpty) {
        await _db.collection('groups').doc(groupId).set({
          'campaigns': FieldValue.arrayUnion([ref.id]),
          'activeCampaignCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return ref.id;
    } catch (e) {
      if (kDebugMode) print('[CampaignService] createCampaign error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  //  INITIATE DONATION  (unchanged)
  // ─────────────────────────────────────────────
  static Future<String?> initiateDonation({
    required String campaignId,
    required String campaignTitle,
    required String athleteId,
    required String athleteName,
    String? groupId,
    required String donorId,
    required String donorName,
    required String donorEmail,
    required double amount,
    required DonationFrequency frequency,
    bool isAnonymous = false,
    String? message,
  }) async {
    try {
      final athleteIdLower = athleteId.trim().toLowerCase();

      final ref = _donations.doc();
      await ref.set({
        'campaignId': campaignId,
        'campaignTitle': campaignTitle,
        'athleteId': athleteIdLower,
        'athleteIdLower': athleteIdLower,
        'athleteName': athleteName,
        'groupId': groupId,
        'donorId': isAnonymous ? null : donorId,
        'donorName': isAnonymous ? 'Anonymous' : donorName,
        'donorEmail': donorEmail,
        'isAnonymous': isAnonymous,
        'amount': amount,
        'frequency': frequency.name,
        'status': 'pending',
        'transactionRef': null,
        'flwToken': null,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      if (kDebugMode) print('[CampaignService] initiateDonation error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  //  COMPLETE DONATION
  //
  //  Step 6 — _creditWalletOverlay() — is the fix.
  //  All other steps are unchanged from the previous version.
  // ─────────────────────────────────────────────
  static Future<bool> completeDonation({
    required String donationId,
    required String transactionRef,
    String? flwToken,
  }) async {
    try {
      final donRef = _donations.doc(donationId);
      final donDoc = await donRef.get();
      if (!donDoc.exists) return false;

      final d = donDoc.data() as Map<String, dynamic>;
      if (d['status'] == 'completed') return true;

      final campaignId = (d['campaignId'] as String?) ?? '';
      final amount = (d['amount'] as num?)?.toDouble() ?? 0.0;

      final athleteIdLower =
          ((d['athleteIdLower'] ?? d['athleteId'] ?? '') as String)
              .trim()
              .toLowerCase();

      final groupId = d['groupId'] as String?;
      final donorId = d['donorId'] as String? ?? '';
      final donorName = d['donorName'] as String? ?? 'Anonymous';
      final donorEmail = d['donorEmail'] as String? ?? '';
      final isAnonymous = d['isAnonymous'] as bool? ?? false;
      final frequency = d['frequency'] as String? ?? 'oneTime';
      final campaignTitle = d['campaignTitle'] as String? ?? '';
      final isRecurring = frequency == 'monthly';
      final isGroupCampaign = groupId != null && groupId.isNotEmpty;

      if (campaignId.isEmpty || athleteIdLower.isEmpty || amount <= 0) {
        if (kDebugMode) {
          print(
            '[CampaignService] completeDonation invalid: '
            'campaignId=$campaignId athleteIdLower=$athleteIdLower '
            'amount=$amount',
          );
        }
        return false;
      }

      final batch = _db.batch();

      // 1) Mark donation complete
      batch.update(donRef, {
        'status': 'completed',
        'transactionRef': transactionRef,
        'processedAt': FieldValue.serverTimestamp(),
        'athleteId': athleteIdLower,
        'athleteIdLower': athleteIdLower,
        if (flwToken != null && flwToken.isNotEmpty) 'flwToken': flwToken,
      });

      // 2) Increment campaign totals
      final campaignRef = _campaigns.doc(campaignId);
      batch.update(campaignRef, {
        'raisedAmount': FieldValue.increment(amount),
        'donorCount': FieldValue.increment(1),
        if (isRecurring) 'recurringDonorCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3) Update donor leaderboard sub-collection
      if (donorId.isNotEmpty) {
        final donorRef = campaignRef.collection('donors').doc(donorId);
        batch.set(donorRef, {
          'donorName': donorName,
          'isAnonymous': isAnonymous,
          'totalAmount': FieldValue.increment(amount),
          'donationCount': FieldValue.increment(1),
          'lastFrequency': frequency,
          'lastDonatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // 4a) Credit athlete_profiles (data integrity record — not used for
      //     balance display, but kept for reporting / admin queries)
      batch.set(_profiles.doc(athleteIdLower), {
        'totalCampaignEarnings': FieldValue.increment(amount),
        'pendingCampaignWithdrawal': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 4b) Credit group totals
      if (isGroupCampaign) {
        batch.set(_db.collection('groups').doc(groupId), {
          'totalCampaignEarnings': FieldValue.increment(amount),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();

      // ── POST-COMMIT STEPS ──────────────────────────────────────────────

      // 5) Milestone unlock check + milestone notifications
      final unlocked = await _checkAndUnlockMilestones(
        campaignId,
        amount,
        athleteIdLower,
        campaignTitle,
      );
      // _ = unlocked;

      // 6) ── WALLET OVERLAY ← THE FIX ─────────────────────────────────────
      //
      //  Without this call:
      //    • athlete_wallet_overlays/{mysqlAthleteId}.donationBalance stays 0
      //    • WalletController.donationOverlayBalance never fires
      //    • mergedAvailableBalance = availableBalance + 0  (no change)
      //    • mergedTotalEarned      = totalEarned + 0       (no change)
      //
      //  With this call:
      //    • donationBalance increments immediately
      //    • _overlaySub stream fires → donationOverlayBalance updates
      //    • GetBuilder rebuilds WalletBalanceCard in real-time
      //    • Idempotent: calling twice with the same ref is a no-op
      await _creditWalletOverlay(
        athleteEmailLower: athleteIdLower,
        transactionRef: transactionRef,
        amount: amount,
      );

      // 7) Monthly subscription record (Flutterwave tokenized charge setup)
      if (isRecurring &&
          donorId.isNotEmpty &&
          flwToken != null &&
          flwToken.isNotEmpty) {
        await CampaignSubscriptionService.createSubscription(
          donorId: donorId,
          donorName: donorName,
          donorEmail: donorEmail,
          isAnonymous: isAnonymous,
          campaignId: campaignId,
          campaignTitle: campaignTitle,
          athleteId: athleteIdLower,
          amount: amount,
          flwToken: flwToken,
          flwRef: transactionRef,
        );
      }

      // 8) Write to wallet_transactions so it appears in history list
      await _syncToWalletTransactions(
        athleteId: athleteIdLower,
        donationId: donationId,
        campaignId: campaignId,
        campaignTitle: campaignTitle,
        groupId: groupId,
        amount: amount,
        donorName: donorName,
        isAnonymous: isAnonymous,
        transactionRef: transactionRef,
        message: d['message'] as String?,
        isRecurring: isRecurring,
      );

      // 9) Push notifications
      final donorDisplay = isAnonymous ? 'Anonymous Hero' : donorName;

      if (donorId.isNotEmpty) {
        if (isRecurring) {
          await CampaignNotificationService.notifyDonorMonthlySetup(
            donorId: donorId,
            campaignTitle: campaignTitle,
            amount: amount,
            currencySymbol: _kCurrencySymbol,
            nextChargeDate: DateTime.now().add(const Duration(days: 30)),
          );
        } else {
          await CampaignNotificationService.notifyDonorOneTimeSuccess(
            donorId: donorId,
            campaignTitle: campaignTitle,
            amount: amount,
            currencySymbol: _kCurrencySymbol,
          );
        }
      }

      if (athleteIdLower.isNotEmpty) {
        await CampaignNotificationService.notifyAthleteNewDonation(
          athleteId: athleteIdLower,
          campaignTitle: campaignTitle,
          amount: amount,
          currencySymbol: _kCurrencySymbol,
          donorDisplayName: donorDisplay,
          isMonthly: isRecurring,
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('[CampaignService] completeDonation error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  SYNC TO WALLET TRANSACTIONS  (unchanged)
  // ─────────────────────────────────────────────
  static Future<void> _syncToWalletTransactions({
    required String athleteId,
    required String donationId,
    required String campaignId,
    required String campaignTitle,
    String? groupId,
    required double amount,
    required String donorName,
    required bool isAnonymous,
    required String transactionRef,
    String? message,
    bool isRecurring = false,
  }) async {
    try {
      final athleteIdLower = athleteId.trim().toLowerCase();
      final isGroupCampaign = groupId != null && groupId.isNotEmpty;

      final walletRef = _db
          .collection('wallet_transactions')
          .doc(athleteIdLower)
          .collection('transactions')
          .doc('campaign_$donationId');

      await walletRef.set({
        'type': 'individualDonation',
        'amount': amount,
        'status': 'completed',
        'isCredit': true,
        'title': campaignTitle,
        'subtitle': isAnonymous ? 'Anonymous Donor' : donorName,
        'reference': transactionRef,
        'metadata': {
          'campaignId': campaignId,
          'donationId': donationId,
          'groupId': groupId,
          'isGroupCampaign': isGroupCampaign,
          'isRecurring': isRecurring,
          'donorName': donorName,
          'isAnonymous': isAnonymous,
          'message': message,
        },
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('[CampaignService] wallet sync error: $e');
    }
  }

  // ─────────────────────────────────────────────
  //  MILESTONE UNLOCK  (unchanged)
  // ─────────────────────────────────────────────
  static Future<List<CampaignMilestone>> _checkAndUnlockMilestones(
    String campaignId,
    double newAmount,
    String athleteId,
    String campaignTitle,
  ) async {
    try {
      final snap = await _campaigns.doc(campaignId).get();
      if (!snap.exists) return [];
      final d = snap.data() as Map<String, dynamic>;
      final raised = (d['raisedAmount'] as num).toDouble();
      final rawMilestones = d['milestones'] as List<dynamic>? ?? [];

      final milestones = rawMilestones
          .map((m) => CampaignMilestone.fromMap(m as Map<String, dynamic>))
          .toList();

      final newlyUnlocked = <CampaignMilestone>[];
      bool anyChanged = false;

      for (int i = 0; i < milestones.length; i++) {
        final m = milestones[i];
        if (!m.isUnlocked && raised >= m.targetAmount) {
          milestones[i] = m.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
          newlyUnlocked.add(milestones[i]);
          anyChanged = true;
        }
      }

      if (anyChanged) {
        await _campaigns.doc(campaignId).update({
          'milestones': milestones.map((m) => m.toMap()).toList(),
        });

        for (final m in newlyUnlocked) {
          await CampaignNotificationService.notifyAthleteMilestoneUnlocked(
            athleteId: athleteId,
            campaignTitle: campaignTitle,
            milestoneTitle: m.title,
            milestoneTarget: m.targetAmount,
            currencySymbol: _kCurrencySymbol,
          );
        }

        if (milestones.every((m) => m.isUnlocked)) {
          await _campaigns.doc(campaignId).update({
            'status': CampaignStatus.completed.name,
          });
        }
      }

      return newlyUnlocked;
    } catch (e) {
      if (kDebugMode) print('[CampaignService] milestone error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  //  AUTO-EXPIRE  (unchanged)
  // ─────────────────────────────────────────────
  static Future<void> expireOverdueCampaigns() async {
    try {
      final now = Timestamp.now();
      final snap = await _campaigns
          .where('status', isEqualTo: CampaignStatus.active.name)
          .where('endDate', isLessThan: now)
          .get();

      if (snap.docs.isEmpty) return;

      const chunkSize = 400;
      for (int i = 0; i < snap.docs.length; i += chunkSize) {
        final chunk = snap.docs.skip(i).take(chunkSize).toList();
        final batch = _db.batch();

        for (final doc in chunk) {
          batch.update(doc.reference, {
            'status': CampaignStatus.expired.name,
            'expiredAt': FieldValue.serverTimestamp(),
          });

          final d = doc.data() as Map<String, dynamic>;
          final gId = d['groupId'] as String?;
          if (gId != null && gId.isNotEmpty) {
            batch.update(_db.collection('groups').doc(gId), {
              'activeCampaignCount': FieldValue.increment(-1),
            });
          }
        }

        await batch.commit();
        if (kDebugMode) {
          print(
            '[CampaignService] expired ${chunk.length} overdue campaign(s)',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CampaignService] expireOverdueCampaigns error: $e');
      }
    }
  }

  // ─────────────────────────────────────────────
  //  CANCEL DONATION  (unchanged)
  // ─────────────────────────────────────────────
  static Future<void> cancelDonation(String donationId) async {
    try {
      await _donations.doc(donationId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) print('[CampaignService] cancelDonation error: $e');
    }
  }

  // ─────────────────────────────────────────────
  //  STREAMS & QUERIES  (all unchanged)
  // ─────────────────────────────────────────────

  static Stream<List<CampaignModel>> streamActiveCampaigns() {
    return _campaigns
        .where('status', isEqualTo: CampaignStatus.active.name)
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => CampaignModel.fromDoc(d))
              .where((c) => c.isActive)
              .toList(),
        );
  }

  static Stream<List<CampaignModel>> streamAthleteCampaigns(String athleteId) {
    final raw = athleteId.trim();
    final lower = raw.toLowerCase();

    final controller = StreamController<List<CampaignModel>>.broadcast();

    List<CampaignModel> listLowerField = [];
    List<CampaignModel> listCreatorLower = [];
    List<CampaignModel> listCreatorRaw = [];

    StreamSubscription? sub1;
    StreamSubscription? sub2;
    StreamSubscription? sub3;

    void emitMerged() {
      final byId = <String, CampaignModel>{};
      for (final c in listLowerField) byId[c.id] = c;
      for (final c in listCreatorLower) byId[c.id] = c;
      for (final c in listCreatorRaw) byId[c.id] = c;
      controller.add(byId.values.toList());
    }

    sub1 = _campaigns
        .where('creatorIdLower', isEqualTo: lower)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
          listLowerField = s.docs.map((d) => CampaignModel.fromDoc(d)).toList();
          emitMerged();
        }, onError: controller.addError);

    sub2 = _campaigns
        .where('creatorId', isEqualTo: lower)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
          listCreatorLower = s.docs
              .map((d) => CampaignModel.fromDoc(d))
              .toList();
          emitMerged();
        }, onError: controller.addError);

    if (raw != lower) {
      sub3 = _campaigns
          .where('creatorId', isEqualTo: raw)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((s) {
            listCreatorRaw = s.docs
                .map((d) => CampaignModel.fromDoc(d))
                .toList();
            emitMerged();
          }, onError: controller.addError);
    }

    controller.onCancel = () async {
      await sub1?.cancel();
      await sub2?.cancel();
      await sub3?.cancel();
    };

    return controller.stream;
  }

  static Stream<List<CampaignModel>> streamGroupCampaigns(String groupId) {
    return _campaigns
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => CampaignModel.fromDoc(d)).toList());
  }

  static Stream<List<CampaignDonor>> streamDonorLeaderboard(String campaignId) {
    return _campaigns
        .doc(campaignId)
        .collection('donors')
        .orderBy('totalAmount', descending: true)
        .limit(20)
        .snapshots()
        .map((s) => s.docs.map((d) => CampaignDonor.fromDoc(d)).toList());
  }

  static Future<void> incrementViewCount(String campaignId) async {
    try {
      await _campaigns.doc(campaignId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  static Future<Map<String, double>> getAthleteEarnings(
    String athleteId,
  ) async {
    try {
      final id = athleteId.trim().toLowerCase();
      final doc = await _profiles.doc(id).get();
      if (!doc.exists) {
        return {'totalCampaignEarnings': 0, 'pendingCampaignWithdrawal': 0};
      }
      final d = doc.data() as Map<String, dynamic>;
      return {
        'totalCampaignEarnings':
            (d['totalCampaignEarnings'] as num?)?.toDouble() ?? 0,
        'pendingCampaignWithdrawal':
            (d['pendingCampaignWithdrawal'] as num?)?.toDouble() ?? 0,
      };
    } catch (_) {
      return {'totalCampaignEarnings': 0, 'pendingCampaignWithdrawal': 0};
    }
  }

  static Future<bool> closeCampaign(
    String campaignId,
    String requesterId,
  ) async {
    try {
      final req = requesterId.trim().toLowerCase();
      final doc = await _campaigns.doc(campaignId).get();
      if (!doc.exists) return false;
      final d = doc.data() as Map<String, dynamic>;

      final creatorId =
          ((d['creatorIdLower'] ?? d['creatorId'] ?? '') as String)
              .trim()
              .toLowerCase();

      if (creatorId != req) return false;

      final gId = d['groupId'] as String?;
      final batch = _db.batch();
      batch.update(_campaigns.doc(campaignId), {
        'status': CampaignStatus.cancelled.name,
      });
      if (gId != null && gId.isNotEmpty) {
        batch.update(_db.collection('groups').doc(gId), {
          'activeCampaignCount': FieldValue.increment(-1),
        });
      }
      await batch.commit();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> updateCampaignFields({
    required String campaignId,
    required Map<String, dynamic> fields,
  }) async {
    await _campaigns.doc(campaignId).update(fields);
  }

  static Future<bool> deleteCampaign(String campaignId) async {
    try {
      final doc = await _campaigns.doc(campaignId).get();
      String? groupId;
      if (doc.exists) {
        final d = doc.data() as Map<String, dynamic>;
        groupId = d['groupId'] as String?;
      }

      final donorsSnap = await _campaigns
          .doc(campaignId)
          .collection('donors')
          .get();
      final batch = _db.batch();
      for (final d in donorsSnap.docs) batch.delete(d.reference);
      batch.delete(_campaigns.doc(campaignId));

      if (groupId != null && groupId.isNotEmpty) {
        batch.update(_db.collection('groups').doc(groupId), {
          'activeCampaignCount': FieldValue.increment(-1),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('[CampaignFS] deleteCampaign error: $e');
      return false;
    }
  }
}
