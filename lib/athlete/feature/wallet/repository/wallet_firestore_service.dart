// lib/athlete/feature/wallet/repository/wallet_firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:afriendorse/athlete/feature/wallet/model/wallet_transaction_model.dart';

class WalletFirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Root collection: wallet_transactions/{athleteId}/transactions
  static CollectionReference _txCol(String athleteId) => _db
      .collection('wallet_transactions')
      .doc(athleteId)
      .collection('transactions');

  // ─────────────────────────────────────────────
  //  SYNC — Write a transaction if not already present
  // ─────────────────────────────────────────────

  /// Upserts a transaction into Firestore (idempotent via deterministic doc ID)
  static Future<void> syncTransaction({
    required String athleteId,
    required WalletTransactionModel tx,
  }) async {
    try {
      final ref = _txCol(athleteId).doc(tx.id);
      final existing = await ref.get();
      if (!existing.exists) {
        await ref.set(tx.toFirestoreMap());
        if (kDebugMode) print('[WalletSync] synced tx: ${tx.id}');
      }
    } catch (e) {
      if (kDebugMode) print('[WalletSync] syncTransaction error: $e');
    }
  }

  /// Sync a batch of transactions (deals + withdrawals from SQL)
  static Future<void> syncBatch({
    required String athleteId,
    required List<WalletTransactionModel> transactions,
  }) async {
    try {
      final batch = _db.batch();

      for (final tx in transactions) {
        final ref = _txCol(athleteId).doc(tx.id);
        batch.set(ref, tx.toFirestoreMap(), SetOptions(merge: true));
      }

      await batch.commit();
      if (kDebugMode)
        print('[WalletSync] synced ${transactions.length} transactions');
    } catch (e) {
      if (kDebugMode) print('[WalletSync] syncBatch error: $e');
    }
  }

  // ─────────────────────────────────────────────
  //  READ — Real-time stream of all transactions
  // ─────────────────────────────────────────────

  /// Stream all transactions ordered by date (newest first)
  static Stream<List<WalletTransactionModel>> streamTransactions(
    String athleteId, {
    int limit = 50,
  }) {
    return _txCol(athleteId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => WalletTransactionModel.fromDoc(d)).toList(),
        );
  }

  /// Stream filtered by type
  static Stream<List<WalletTransactionModel>> streamByType(
    String athleteId,
    WalletTransactionType type,
  ) {
    return _txCol(athleteId)
        .where('type', isEqualTo: type.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => WalletTransactionModel.fromDoc(d)).toList(),
        );
  }

  // ─────────────────────────────────────────────
  //  SYNC GROUP DONATIONS for an athlete
  // ─────────────────────────────────────────────

  /// Fetch completed donations for an athlete from the donations collection
  /// and sync them into their wallet_transactions
  static Future<void> syncGroupDonationsForAthlete({
    required String athleteId,
  }) async {
    try {
      // Query donations where this athlete is in eligibleMemberIds
      final snap = await _db
          .collection('donations')
          .where('status', isEqualTo: 'completed')
          .where('eligibleMemberIds', arrayContains: athleteId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      if (snap.docs.isEmpty) return;

      final List<WalletTransactionModel> txList = [];

      for (final doc in snap.docs) {
        final d = doc.data() as Map<String, dynamic>;
        final splitAmount = (d['splitAmount'] ?? d['finalSplitAmount'] ?? 0)
            .toDouble();
        final donorName = d['donorName'] as String? ?? 'Donor';
        final isAnonymous = d['isAnonymous'] as bool? ?? false;
        final createdAt =
            (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

        txList.add(
          WalletTransactionModel.fromGroupDonation(
            donationId: doc.id,
            groupName: d['groupName'] as String? ?? 'Group',
            splitAmount: splitAmount,
            donorName: donorName,
            isAnonymous: isAnonymous,
            createdAt: createdAt,
            transactionRef: d['transactionRef'] as String?,
            message: d['message'] as String?,
          ),
        );
      }

      await syncBatch(athleteId: athleteId, transactions: txList);
    } catch (e) {
      if (kDebugMode) print('[WalletSync] syncGroupDonations error: $e');
    }
  }
}
