import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AthleteWalletOverlayService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Keyed by mysqlAthleteId
  static DocumentReference<Map<String, dynamic>> _doc(String mysqlAthleteId) =>
      _db.collection('athlete_wallet_overlays').doc(mysqlAthleteId);

  static DocumentReference<Map<String, dynamic>> _appliedRef(
    String mysqlAthleteId,
    String ref,
  ) => _doc(mysqlAthleteId).collection('applied_refs').doc(ref);

  static Stream<double> watchDonationBalance(String mysqlAthleteId) {
    return _doc(mysqlAthleteId).snapshots().map((snap) {
      final d = snap.data();
      final v = d?['donationBalance'] ?? 0;
      return (v is int) ? v.toDouble() : (v as num).toDouble();
    });
  }

  /// Idempotent increment: only applies once per paystack reference
  static Future<void> applyDonation({
    required String mysqlAthleteId,
    required String paystackRef,
    required double amount,
    required String athleteEmailLower,
  }) async {
    await _db.runTransaction((tx) async {
      final appliedSnap = await tx.get(
        _appliedRef(mysqlAthleteId, paystackRef),
      );
      if (appliedSnap.exists) return;

      tx.set(_doc(mysqlAthleteId), {
        'mysqlAthleteId': mysqlAthleteId,
        'athleteEmailLower': athleteEmailLower,
        'donationBalance': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      tx.set(_appliedRef(mysqlAthleteId, paystackRef), {
        'ref': paystackRef,
        'amount': amount,
        'appliedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ── NEW: Track wallet spends (campaign donations paid via wallet) ──
  static DocumentReference<Map<String, dynamic>> _spendRef(
    String mysqlAthleteId,
    String spendRef,
  ) => _doc(mysqlAthleteId).collection('spent_refs').doc(spendRef);

  // ── NEW: Watch total spent via wallet ──
  static Stream<double> watchTotalSpent(String mysqlAthleteId) {
    return _doc(mysqlAthleteId).snapshots().map((snap) {
      final d = snap.data();
      final v = d?['totalSpent'] ?? 0;
      return (v is int) ? v.toDouble() : (v as num).toDouble();
    });
  }

  // ── NEW: Record a wallet spend (idempotent) ──
  static Future<bool> recordSpend({
    required String mysqlAthleteId,
    required String spendRef,
    required double amount,
    required String athleteEmailLower,
    required String reason,
  }) async {
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final spentSnap = await tx.get(_spendRef(mysqlAthleteId, spendRef));
        if (spentSnap.exists) return; // already recorded

        tx.set(_doc(mysqlAthleteId), {
          'mysqlAthleteId': mysqlAthleteId,
          'athleteEmailLower': athleteEmailLower,
          'totalSpent': FieldValue.increment(amount),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        tx.set(_spendRef(mysqlAthleteId, spendRef), {
          'ref': spendRef,
          'amount': amount,
          'reason': reason,
          'spentAt': FieldValue.serverTimestamp(),
        });
      });
      return true;
    } catch (e) {
      if (kDebugMode) print('[WalletOverlay] recordSpend error: $e');
      return false;
    }
  }
}
