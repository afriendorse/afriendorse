import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
//  Enums
// ─────────────────────────────────────────────

enum CampaignType { individual, group }

enum CampaignStatus { draft, active, completed, cancelled, expired }

enum DonationFrequency { oneTime, monthly }

enum SupporterTier { fan, supporter, champion, legend }

// ─────────────────────────────────────────────
//  Tier logic
// ─────────────────────────────────────────────

extension SupporterTierX on SupporterTier {
  String get label {
    switch (this) {
      case SupporterTier.fan:
        return 'Fan';
      case SupporterTier.supporter:
        return 'Supporter';
      case SupporterTier.champion:
        return 'Champion';
      case SupporterTier.legend:
        return 'Legend';
    }
  }

  String get emoji {
    switch (this) {
      case SupporterTier.fan:
        return '🥉';
      case SupporterTier.supporter:
        return '🥈';
      case SupporterTier.champion:
        return '🥇';
      case SupporterTier.legend:
        return '👑';
    }
  }

  String get badge {
    switch (this) {
      case SupporterTier.fan:
        return 'Bronze';
      case SupporterTier.supporter:
        return 'Silver';
      case SupporterTier.champion:
        return 'Gold';
      case SupporterTier.legend:
        return 'Legend';
    }
  }

  static SupporterTier fromAmount(double amount) {
    if (amount >= 50000) return SupporterTier.legend;
    if (amount >= 10000) return SupporterTier.champion;
    if (amount >= 2000) return SupporterTier.supporter;
    return SupporterTier.fan;
  }
}

// ─────────────────────────────────────────────
//  Milestone
// ─────────────────────────────────────────────

class CampaignMilestone {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  CampaignMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory CampaignMilestone.fromMap(Map<String, dynamic> d) {
    return CampaignMilestone(
      id: d['id'] ?? '',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      targetAmount: (d['targetAmount'] ?? 0).toDouble(),
      isUnlocked: d['isUnlocked'] ?? false,
      unlockedAt: (d['unlockedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'targetAmount': targetAmount,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
  };

  CampaignMilestone copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return CampaignMilestone(
      id: id,
      title: title,
      description: description,
      targetAmount: targetAmount,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

// ─────────────────────────────────────────────
//  Campaign Donor
// ─────────────────────────────────────────────

class CampaignDonor {
  final String donorId;
  final String donorName;
  final String? donorAvatar;
  final double totalAmount;
  final int donationCount;
  final DonationFrequency lastFrequency;
  final DateTime lastDonatedAt;
  final bool isAnonymous;

  CampaignDonor({
    required this.donorId,
    required this.donorName,
    this.donorAvatar,
    required this.totalAmount,
    required this.donationCount,
    required this.lastFrequency,
    required this.lastDonatedAt,
    this.isAnonymous = false,
  });

  SupporterTier get tier => SupporterTierX.fromAmount(totalAmount);

  String get displayName => isAnonymous ? 'Anonymous Hero' : donorName;

  factory CampaignDonor.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CampaignDonor(
      donorId: doc.id,
      donorName: d['donorName'] ?? 'Anonymous',
      donorAvatar: d['donorAvatar'],
      totalAmount: (d['totalAmount'] ?? 0).toDouble(),
      donationCount: d['donationCount'] ?? 1,
      lastFrequency: DonationFrequency.values.firstWhere(
        (e) => e.name == (d['lastFrequency'] ?? 'oneTime'),
        orElse: () => DonationFrequency.oneTime,
      ),
      lastDonatedAt:
          (d['lastDonatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAnonymous: d['isAnonymous'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'donorName': donorName,
    'donorAvatar': donorAvatar,
    'totalAmount': totalAmount,
    'donationCount': donationCount,
    'lastFrequency': lastFrequency.name,
    'lastDonatedAt': FieldValue.serverTimestamp(),
    'isAnonymous': isAnonymous,
  };
}

// ─────────────────────────────────────────────
//  Individual Donation record
// ─────────────────────────────────────────────

class CampaignDonationRecord {
  final String id;
  final String campaignId;
  final String campaignTitle;

  /// canonical athlete email (lowercase)
  final String athleteId;

  final String athleteName;
  final String donorId;
  final String donorName;
  final String donorEmail;
  final bool isAnonymous;
  final double amount;
  final DonationFrequency frequency;
  final String status; // pending | completed | failed | cancelled
  final String? transactionRef;
  final String? message;
  final DateTime createdAt;

  CampaignDonationRecord({
    required this.id,
    required this.campaignId,
    required this.campaignTitle,
    required this.athleteId,
    required this.athleteName,
    required this.donorId,
    required this.donorName,
    required this.donorEmail,
    this.isAnonymous = false,
    required this.amount,
    required this.frequency,
    required this.status,
    this.transactionRef,
    this.message,
    required this.createdAt,
  });

  factory CampaignDonationRecord.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    final athleteIdLower =
        ((d['athleteIdLower'] ?? d['athleteId'] ?? '') as String)
            .trim()
            .toLowerCase();

    return CampaignDonationRecord(
      id: doc.id,
      campaignId: d['campaignId'] ?? '',
      campaignTitle: d['campaignTitle'] ?? '',
      athleteId: athleteIdLower,
      athleteName: d['athleteName'] ?? '',
      donorId: d['donorId'] ?? '',
      donorName: d['donorName'] ?? '',
      donorEmail: d['donorEmail'] ?? '',
      isAnonymous: d['isAnonymous'] ?? false,
      amount: (d['amount'] ?? 0).toDouble(),
      frequency: DonationFrequency.values.firstWhere(
        (e) => e.name == (d['frequency'] ?? 'oneTime'),
        orElse: () => DonationFrequency.oneTime,
      ),
      status: d['status'] ?? 'pending',
      transactionRef: d['transactionRef'],
      message: d['message'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
//  Campaign Model
// ─────────────────────────────────────────────

class CampaignModel {
  final String id;
  final String title;
  final String description;
  final String story;
  final CampaignType type;
  final CampaignStatus status;

  /// canonical creator athlete email (lowercase)
  final String creatorId;

  final String creatorName;
  final String? creatorAvatar;

  final String? groupId;
  final String? groupName;

  final double goalAmount;
  final double raisedAmount;
  final int donorCount;
  final int recurringDonorCount;

  final String? coverImage;
  final List<String> mediaUrls;

  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  final List<CampaignMilestone> milestones;
  final int viewCount;

  final List<String> tags;
  final bool allowAnonymous;
  final double minimumDonation;

  CampaignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.story,
    required this.type,
    required this.status,
    required this.creatorId,
    required this.creatorName,
    this.creatorAvatar,
    this.groupId,
    this.groupName,
    required this.goalAmount,
    required this.raisedAmount,
    required this.donorCount,
    required this.recurringDonorCount,
    this.coverImage,
    required this.mediaUrls,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.milestones,
    required this.viewCount,
    required this.tags,
    required this.allowAnonymous,
    required this.minimumDonation,
  });

  double get progressPercent =>
      goalAmount > 0 ? (raisedAmount / goalAmount).clamp(0.0, 1.0) : 0.0;

  bool get isGoalReached => raisedAmount >= goalAmount;

  bool get isExpired => DateTime.now().isAfter(endDate);

  /// IMPORTANT: "Active" should mean status active AND not expired
  bool get isActive => status == CampaignStatus.active && !isExpired;

  int get daysLeft => endDate.difference(DateTime.now()).inDays.clamp(0, 9999);

  double get remainingAmount =>
      (goalAmount - raisedAmount).clamp(0, goalAmount);

  int get nextMilestoneIndex {
    for (int i = 0; i < milestones.length; i++) {
      if (!milestones[i].isUnlocked) return i;
    }
    return -1;
  }

  CampaignMilestone? get nextMilestone {
    final idx = nextMilestoneIndex;
    return idx >= 0 ? milestones[idx] : null;
  }

  factory CampaignModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    final rawMilestones = d['milestones'] as List<dynamic>? ?? [];
    final milestones = rawMilestones
        .map((m) => CampaignMilestone.fromMap(m as Map<String, dynamic>))
        .toList();

    final creatorIdLower =
        ((d['creatorIdLower'] ?? d['creatorId'] ?? '') as String)
            .trim()
            .toLowerCase();

    return CampaignModel(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      story: d['story'] ?? '',
      type: CampaignType.values.firstWhere(
        (e) => e.name == (d['type'] ?? 'individual'),
        orElse: () => CampaignType.individual,
      ),
      status: CampaignStatus.values.firstWhere(
        (e) => e.name == (d['status'] ?? 'active'),
        orElse: () => CampaignStatus.active,
      ),
      creatorId: creatorIdLower,
      creatorName: d['creatorName'] ?? '',
      creatorAvatar: d['creatorAvatar'],
      groupId: d['groupId'],
      groupName: d['groupName'],
      goalAmount: (d['goalAmount'] ?? 0).toDouble(),
      raisedAmount: (d['raisedAmount'] ?? 0).toDouble(),
      donorCount: d['donorCount'] ?? 0,
      recurringDonorCount: d['recurringDonorCount'] ?? 0,
      coverImage: d['coverImage'],
      mediaUrls: List<String>.from(d['mediaUrls'] ?? []),
      startDate: (d['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate:
          (d['endDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30)),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      milestones: milestones,
      viewCount: d['viewCount'] ?? 0,
      tags: List<String>.from(d['tags'] ?? []),
      allowAnonymous: d['allowAnonymous'] ?? true,
      minimumDonation: (d['minimumDonation'] ?? 500).toDouble(),
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    final creatorLower = creatorId.trim().toLowerCase();

    return {
      'title': title,
      'description': description,
      'story': story,
      'type': type.name,
      'status': status.name,

      // Canonical creator ID fields
      'creatorId': creatorLower,
      'creatorIdLower': creatorLower,

      'creatorName': creatorName,
      'creatorAvatar': creatorAvatar,
      'groupId': groupId,
      'groupName': groupName,
      'goalAmount': goalAmount,
      'raisedAmount': raisedAmount,
      'donorCount': donorCount,
      'recurringDonorCount': recurringDonorCount,
      'coverImage': coverImage,
      'mediaUrls': mediaUrls,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdAt': FieldValue.serverTimestamp(),
      'milestones': milestones.map((m) => m.toMap()).toList(),
      'viewCount': viewCount,
      'tags': tags,
      'allowAnonymous': allowAnonymous,
      'minimumDonation': minimumDonation,
    };
  }

  static List<CampaignMilestone> autoMilestones(double goal) {
    return [
      CampaignMilestone(
        id: 'milestone_25',
        title: 'First Quarter! 🚀',
        description: '25% of the goal reached — momentum is building!',
        targetAmount: goal * 0.25,
      ),
      CampaignMilestone(
        id: 'milestone_50',
        title: 'Halfway Hero! ⚡',
        description: 'Halfway there — the community is rallying behind you!',
        targetAmount: goal * 0.50,
      ),
      CampaignMilestone(
        id: 'milestone_75',
        title: 'Three-Quarter Champion! 🔥',
        description: '75% achieved — the finish line is in sight!',
        targetAmount: goal * 0.75,
      ),
      CampaignMilestone(
        id: 'milestone_100',
        title: 'GOAL REACHED! 🏆',
        description: 'You did it! The entire community made this possible!',
        targetAmount: goal,
      ),
    ];
  }
}
