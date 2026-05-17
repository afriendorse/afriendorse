import 'package:cloud_firestore/cloud_firestore.dart';

enum WalletTransactionType {
  dealPayment,
  groupDonation,
  individualDonation,
  withdrawal,
  pointsRedeemed, // Renamed for clarity: points → cash conversion (credit)
}

enum WalletTransactionStatus { completed, pending, failed, approved, denied }

class WalletTransactionModel {
  final String id;
  final WalletTransactionType type;
  final double amount;
  final String title;
  final String subtitle;
  final String? reference;
  final WalletTransactionStatus status;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  WalletTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.subtitle,
    this.reference,
    required this.status,
    required this.createdAt,
    this.metadata = const {},
  });

  String get typeLabel {
    switch (type) {
      case WalletTransactionType.dealPayment:
        return 'Deal Payment';
      case WalletTransactionType.groupDonation:
        return 'Group Donation';
      case WalletTransactionType.individualDonation:
        return 'Individual Donation';
      case WalletTransactionType.withdrawal:
        return 'Withdrawal';
      case WalletTransactionType.pointsRedeemed:
        return 'Points Redeemed';
    }
  }

  /// Credits increase balance (payments, donations, points redeemed)
  /// Only withdrawals decrease balance
  bool get isCredit => type != WalletTransactionType.withdrawal;

  Map<String, dynamic> toFirestoreMap() {
    return {
      'type': type.name,
      'amount': amount,
      'title': title,
      'subtitle': subtitle,
      'reference': reference,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }

  factory WalletTransactionModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    // Handle backward compatibility for old 'pointsWithdrawal' records
    String typeString = d['type'] ?? 'dealPayment';
    if (typeString == 'pointsWithdrawal') {
      typeString = 'pointsRedeemed';
    }

    return WalletTransactionModel(
      id: doc.id,
      type: WalletTransactionType.values.firstWhere(
        (e) => e.name == typeString,
        orElse: () => WalletTransactionType.dealPayment,
      ),
      amount: (d['amount'] ?? 0).toDouble(),
      title: d['title'] ?? '',
      subtitle: d['subtitle'] ?? '',
      reference: d['reference'],
      status: WalletTransactionStatus.values.firstWhere(
        (e) => e.name == (d['status'] ?? 'completed'),
        orElse: () => WalletTransactionStatus.completed,
      ),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(d['metadata'] ?? {}),
    );
  }

  factory WalletTransactionModel.fromDeal({
    required String bookingId,
    required String readableId,
    required double amount,
    required String serviceName,
    required DateTime createdAt,
    String? paymentMethod,
  }) {
    return WalletTransactionModel(
      id: 'deal_$bookingId',
      type: WalletTransactionType.dealPayment,
      amount: amount,
      title: serviceName.isNotEmpty ? serviceName : 'Brand Deal',
      subtitle: 'Deal #$readableId',
      reference: readableId,
      status: WalletTransactionStatus.completed,
      createdAt: createdAt,
      metadata: {
        'bookingId': bookingId,
        'paymentMethod': paymentMethod ?? '',
        'serviceName': serviceName,
      },
    );
  }

  factory WalletTransactionModel.fromGroupDonation({
    required String donationId,
    required String groupName,
    required double splitAmount,
    required String donorName,
    required bool isAnonymous,
    required DateTime createdAt,
    String? transactionRef,
    String? message,
  }) {
    return WalletTransactionModel(
      id: 'donation_$donationId',
      type: WalletTransactionType.groupDonation,
      amount: splitAmount,
      title: groupName,
      subtitle: isAnonymous ? 'Anonymous Donor' : 'From $donorName',
      reference: transactionRef,
      status: WalletTransactionStatus.completed,
      createdAt: createdAt,
      metadata: {
        'donationId': donationId,
        'groupName': groupName,
        'donorName': isAnonymous ? 'Anonymous' : donorName,
        'message': message ?? '',
        'isAnonymous': isAnonymous,
      },
    );
  }

  factory WalletTransactionModel.fromIndividualDonation({
    required String donationId,
    required String campaignTitle,
    required double amount,
    required String donorName,
    required bool isAnonymous,
    required DateTime createdAt,
    String? transactionRef,
    String? message,
    String? campaignId,
  }) {
    return WalletTransactionModel(
      id: 'campaign_$donationId',
      type: WalletTransactionType.individualDonation,
      amount: amount,
      title: campaignTitle.isNotEmpty ? campaignTitle : 'Campaign Donation',
      subtitle: isAnonymous ? 'Anonymous Donor' : 'From $donorName',
      reference: transactionRef,
      status: WalletTransactionStatus.completed,
      createdAt: createdAt,
      metadata: {
        'donationId': donationId,
        'campaignId': campaignId ?? '',
        'campaignTitle': campaignTitle,
        'donorName': isAnonymous ? 'Anonymous' : donorName,
        'message': message ?? '',
        'isAnonymous': isAnonymous,
      },
    );
  }

  factory WalletTransactionModel.fromWithdrawal({
    required String withdrawalId,
    required double amount,
    required String requestStatus,
    required int isPaid,
    required DateTime createdAt,
    String? providerNote,
    String? adminNote,
  }) {
    WalletTransactionStatus status;
    switch (requestStatus.toLowerCase()) {
      case 'approved':
        status = WalletTransactionStatus.approved;
        break;
      case 'denied':
        status = WalletTransactionStatus.denied;
        break;
      case 'pending':
        status = WalletTransactionStatus.pending;
        break;
      default:
        status = WalletTransactionStatus.pending;
    }

    return WalletTransactionModel(
      id: 'withdrawal_$withdrawalId',
      type: WalletTransactionType.withdrawal,
      amount: amount,
      title: 'Withdrawal Request',
      subtitle: isPaid == 1 ? 'Paid' : requestStatus,
      reference: withdrawalId,
      status: status,
      createdAt: createdAt,
      metadata: {
        'withdrawalId': withdrawalId,
        'isPaid': isPaid,
        'requestStatus': requestStatus,
        'providerNote': providerNote ?? '',
        'adminNote': adminNote ?? '',
      },
    );
  }

  factory WalletTransactionModel.fromPointsRedemption({
    required String redemptionId,
    required double cashAmount,
    required int pointsUsed,
    required DateTime createdAt,
  }) {
    return WalletTransactionModel(
      id: 'points_$redemptionId',
      type: WalletTransactionType.pointsRedeemed,
      amount: cashAmount,
      title: 'Points Redeemed',
      subtitle: '$pointsUsed points converted to cash',
      reference: redemptionId,
      status: WalletTransactionStatus.completed,
      createdAt: createdAt,
      metadata: {
        'redemptionId': redemptionId,
        'pointsUsed': pointsUsed,
        'conversionRate': pointsUsed > 0 ? cashAmount / pointsUsed : 0,
      },
    );
  }
}
