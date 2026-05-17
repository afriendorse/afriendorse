// lib/athlete/feature/donations/individual_donation_recorder.dart

import 'package:afriendorse/athlete/feature/wallet/widgets/athlete_wallet_overlay_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IndividualDonationRecorder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Writes a WalletTransactionModel-compatible doc into:
  /// wallet_transactions/{athleteEmailLower}/transactions/{docId}
  static Future<void> record({
    required String athleteEmailLower,
    required String mysqlAthleteId,
    required String flutterwaveRef,
    required String transactionId, // Flutterwave's numeric transaction_id
    required double amount,
    required String athleteNameOrTitle,
    required String donorName,
    required bool isAnonymous,
    String? message,
  }) async {
    final txDocId = 'campaign_$flutterwaveRef';
    final nowTs = Timestamp.now();

    // 1) Write wallet transaction (for history UI)
    final txRef = _db
        .collection('wallet_transactions')
        .doc(athleteEmailLower)
        .collection('transactions')
        .doc(txDocId);

    await txRef.set({
      'type': 'individualDonation',
      'amount': amount,
      'title': athleteNameOrTitle.isNotEmpty ? athleteNameOrTitle : 'Donation',
      'subtitle': isAnonymous ? 'Anonymous Donor' : 'From $donorName',
      'reference': flutterwaveRef,
      'transactionId': transactionId, // Flutterwave's id for audit trail
      'status': 'completed',
      'createdAt': nowTs,
      'metadata': {
        'donationId': flutterwaveRef,
        'campaignId': mysqlAthleteId,
        'campaignTitle': athleteNameOrTitle,
        'donorName': isAnonymous ? 'Anonymous' : donorName,
        'message': message ?? '',
        'isAnonymous': isAnonymous,
        'mysqlAthleteId': mysqlAthleteId,
        'flutterwaveRef': flutterwaveRef,
        'transactionId': transactionId,
        'currency': 'USD',
      },
    }, SetOptions(merge: true));

    // 2) Increment overlay balance (for merged display)
    await AthleteWalletOverlayService.applyDonation(
      mysqlAthleteId: mysqlAthleteId,
      paystackRef: flutterwaveRef, // field name kept for backward compat
      amount: amount,
      athleteEmailLower: athleteEmailLower,
    );
  }
}
