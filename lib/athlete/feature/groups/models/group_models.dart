// lib/athlete/feature/groups/models/group_models.dart

/*
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { athlete, brand, fan, unknown }

enum GroupVisibility { public, private }

enum MemberRole { admin, moderator, member }

enum PostType { text, image, video }

enum DonationStatus { pending, completed, failed, refunded }

// ─────────────────────────────────────────────
//  GroupModel
// ─────────────────────────────────────────────
// PATCH: group_models.dart — add activeCampaignCount to GroupModel
//
// 1. Add field to class:
//      final int activeCampaignCount;
//
// 2. Add to constructor:
//      required this.activeCampaignCount,   ← or use default: this.activeCampaignCount = 0
//
// 3. Add to factory GroupModel.fromDoc:
//      activeCampaignCount: (d['activeCampaignCount'] as num?)?.toInt() ?? 0,
//
// 4. Add to toMap():
//      'activeCampaignCount': activeCampaignCount,

// Minimal drop-in — only the changed GroupModel class.
// Replace the existing GroupModel class in group_models.dart with this.

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final String creatorName;
  final String sport;
  final bool isPublic;
  final String inviteCode;
  final String coverImage;
  final int memberCount;
  final double totalDonations;
  final double pendingDonations;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? pinnedPostId;
  // ── NEW: count of campaigns with status == 'active' for this group ──────
  // Kept in sync by campaign_firestore_service: +1 on createCampaign,
  // -1 on deleteCampaign/closeCampaign.
  final int activeCampaignCount;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.creatorName,
    required this.sport,
    required this.isPublic,
    required this.inviteCode,
    required this.coverImage,
    required this.memberCount,
    required this.totalDonations,
    required this.pendingDonations,
    required this.createdAt,
    required this.updatedAt,
    this.pinnedPostId,
    this.activeCampaignCount = 0, // ← default 0, non-breaking
  });

  factory GroupModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      creatorId: d['creatorId'] ?? '',
      creatorName: d['creatorName'] ?? '',
      sport: d['sport'] ?? 'General',
      isPublic: d['isPublic'] ?? true,
      inviteCode: d['inviteCode'] ?? '',
      coverImage: d['coverImage'] ?? '',
      memberCount: d['memberCount'] ?? 1,
      totalDonations: (d['totalDonations'] ?? 0).toDouble(),
      pendingDonations: (d['pendingDonations'] ?? 0).toDouble(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pinnedPostId: d['pinnedPostId'],
      activeCampaignCount: (d['activeCampaignCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'creatorId': creatorId,
    'creatorName': creatorName,
    'sport': sport,
    'isPublic': isPublic,
    'inviteCode': inviteCode,
    'coverImage': coverImage,
    'memberCount': memberCount,
    'totalDonations': totalDonations,
    'pendingDonations': pendingDonations,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'pinnedPostId': pinnedPostId,
    'activeCampaignCount': activeCampaignCount,
  };
}

// ─────────────────────────────────────────────
//  MemberModel
// ─────────────────────────────────────────────
class MemberModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String userType;
  final double earnings;
  final DateTime joinedAt;
  final bool isBanned;
  final String? avatarUrl;

  MemberModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.userType,
    required this.earnings,
    required this.joinedAt,
    this.isBanned = false,
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName'.trim();
  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';

  factory MemberModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MemberModel(
      id: doc.id,
      email: d['email'] ?? doc.id,
      firstName: d['firstName'] ?? '',
      lastName: d['lastName'] ?? '',
      role: d['role'] ?? 'member',
      userType: d['userType'] ?? 'athlete',
      earnings: (d['earnings'] ?? 0).toDouble(),
      joinedAt: (d['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isBanned: d['isBanned'] ?? false,
      avatarUrl: d['avatarUrl'],
    );
  }
}

// ─────────────────────────────────────────────
//  PostModel
// ─────────────────────────────────────────────
class PostModel {
  final String id;
  final String groupId;
  final String authorId;
  final String authorName;
  final String authorType;
  final String? authorAvatar;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final PostType postType;
  final int likes;
  final int commentsCount;
  final bool isPinned;
  final List<String> likedBy;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.groupId,
    required this.authorId,
    required this.authorName,
    required this.authorType,
    this.authorAvatar,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    required this.postType,
    required this.likes,
    required this.commentsCount,
    required this.isPinned,
    required this.likedBy,
    required this.createdAt,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      groupId: d['groupId'] ?? '',
      authorId: d['authorId'] ?? '',
      authorName: d['authorName'] ?? '',
      authorType: d['authorType'] ?? 'athlete',
      authorAvatar: d['authorAvatar'],
      content: d['content'] ?? '',
      imageUrl: d['imageUrl'],
      videoUrl: d['videoUrl'],
      postType: PostType.values.firstWhere(
        (e) => e.name == (d['postType'] ?? 'text'),
        orElse: () => PostType.text,
      ),
      likes: d['likes'] ?? 0,
      commentsCount: d['commentsCount'] ?? 0,
      isPinned: d['isPinned'] ?? false,
      likedBy: List<String>.from(d['likedBy'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
//  CommentModel
// ─────────────────────────────────────────────
class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorType;
  final String? authorAvatar;
  final String content;
  final int likes;
  final List<String> likedBy;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorType,
    this.authorAvatar,
    required this.content,
    required this.likes,
    required this.likedBy,
    required this.createdAt,
  });

  factory CommentModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: d['postId'] ?? '',
      authorId: d['authorId'] ?? '',
      authorName: d['authorName'] ?? '',
      authorType: d['authorType'] ?? 'fan',
      authorAvatar: d['authorAvatar'],
      content: d['content'] ?? '',
      likes: d['likes'] ?? 0,
      likedBy: List<String>.from(d['likedBy'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
//  DonationModel
// ─────────────────────────────────────────────
class DonationModel {
  final String id;
  final String groupId;
  final String groupName;
  final String? donorId;
  final String donorEmail;
  final String donorName;
  final String? donorType;
  final double amount;
  final String? message;
  final bool isAnonymous;
  final DonationStatus status;
  final double splitAmount;
  final int memberCount;
  final DateTime createdAt;
  final String? transactionRef;

  DonationModel({
    required this.id,
    required this.groupId,
    required this.groupName,
    this.donorId,
    required this.donorEmail,
    required this.donorName,
    this.donorType,
    required this.amount,
    this.message,
    required this.isAnonymous,
    required this.status,
    required this.splitAmount,
    required this.memberCount,
    required this.createdAt,
    this.transactionRef,
  });

  factory DonationModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return DonationModel(
      id: doc.id,
      groupId: d['groupId'] ?? '',
      groupName: d['groupName'] ?? '',
      donorId: d['donorId'],
      donorEmail: d['donorEmail'] ?? '',
      donorName: d['donorName'] ?? '',
      donorType: d['donorType'],
      amount: (d['amount'] ?? 0).toDouble(),
      message: d['message'],
      isAnonymous: d['isAnonymous'] ?? false,
      status: DonationStatus.values.firstWhere(
        (e) => e.name == (d['status'] ?? 'pending'),
        orElse: () => DonationStatus.pending,
      ),
      splitAmount: (d['splitAmount'] ?? 0).toDouble(),
      memberCount: d['memberCount'] ?? 1,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionRef: d['transactionRef'],
    );
  }
}

// ─────────────────────────────────────────────
//  GroupAnalytics
// ─────────────────────────────────────────────
class GroupAnalytics {
  final int totalMembers;
  final int athleteMembers;
  final double totalDonations;
  final double monthlyRevenue;
  final double myEarnings;
  final int totalPosts;
  final int totalDonors;
  final List<DonationModel> recentDonations;

  GroupAnalytics({
    required this.totalMembers,
    required this.athleteMembers,
    required this.totalDonations,
    required this.monthlyRevenue,
    required this.myEarnings,
    required this.totalPosts,
    required this.totalDonors,
    required this.recentDonations,
  });
}
*/

// lib/athlete/feature/groups/models/group_models.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { athlete, brand, fan, unknown }

enum GroupVisibility { public, private }

enum MemberRole { admin, moderator, member }

enum PostType { text, image, video }

enum DonationStatus { pending, completed, failed, refunded }

enum GroupStatus { pending, active, rejected }

// ─────────────────────────────────────────────
//  GroupModel
// ─────────────────────────────────────────────
class GroupModel {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final String creatorName;
  final String sport;
  final bool isPublic;
  final bool requiresApproval;
  final String inviteCode;
  final String coverImage;
  final int memberCount;
  final double totalDonations;
  final double pendingDonations;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? pinnedPostId;
  final int activeCampaignCount;
  final GroupStatus status;
  final String? rejectionReason;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.creatorName,
    required this.sport,
    required this.isPublic,
    this.requiresApproval = false,
    required this.inviteCode,
    required this.coverImage,
    required this.memberCount,
    required this.totalDonations,
    required this.pendingDonations,
    required this.createdAt,
    required this.updatedAt,
    this.pinnedPostId,
    this.activeCampaignCount = 0,
    this.status = GroupStatus.pending,
    this.rejectionReason,
  });

  factory GroupModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      creatorId: d['creatorId'] ?? '',
      creatorName: d['creatorName'] ?? '',
      sport: d['sport'] ?? 'General',
      isPublic: d['isPublic'] ?? true,
      requiresApproval: d['requiresApproval'] ?? false,
      inviteCode: d['inviteCode'] ?? '',
      coverImage: d['coverImage'] ?? '',
      memberCount: d['memberCount'] ?? 1,
      totalDonations: (d['totalDonations'] ?? 0).toDouble(),
      pendingDonations: (d['pendingDonations'] ?? 0).toDouble(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pinnedPostId: d['pinnedPostId'],
      activeCampaignCount: (d['activeCampaignCount'] as num?)?.toInt() ?? 0,
      status: GroupStatus.values.firstWhere(
        (e) => e.name == (d['status'] ?? 'pending'),
        orElse: () => GroupStatus.pending,
      ),
      rejectionReason: d['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'creatorId': creatorId,
    'creatorName': creatorName,
    'sport': sport,
    'isPublic': isPublic,
    'requiresApproval': requiresApproval,
    'inviteCode': inviteCode,
    'coverImage': coverImage,
    'memberCount': memberCount,
    'totalDonations': totalDonations,
    'pendingDonations': pendingDonations,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'pinnedPostId': pinnedPostId,
    'activeCampaignCount': activeCampaignCount,
    'status': status.name,
    'rejectionReason': rejectionReason,
  };
}

// ─────────────────────────────────────────────
//  JoinRequestModel
// ─────────────────────────────────────────────
class JoinRequestModel {
  final String id;
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String userType;
  final String? avatarUrl;
  final DateTime requestedAt;
  final String status; // 'pending' | 'approved' | 'rejected'

  JoinRequestModel({
    required this.id,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userType,
    this.avatarUrl,
    required this.requestedAt,
    required this.status,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory JoinRequestModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return JoinRequestModel(
      id: doc.id,
      userId: d['userId'] ?? doc.id,
      email: d['email'] ?? '',
      firstName: d['firstName'] ?? '',
      lastName: d['lastName'] ?? '',
      userType: d['userType'] ?? 'fan',
      avatarUrl: d['avatarUrl'],
      requestedAt: (d['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: d['status'] ?? 'pending',
    );
  }
}

// ─────────────────────────────────────────────
//  MemberModel
// ─────────────────────────────────────────────
class MemberModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String userType;
  final double earnings;
  final DateTime joinedAt;
  final bool isBanned;
  final String? avatarUrl;
  final String? addedBy; // 'platform' | 'admin' | 'self'

  MemberModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.userType,
    required this.earnings,
    required this.joinedAt,
    this.isBanned = false,
    this.avatarUrl,
    this.addedBy,
  });

  String get fullName => '$firstName $lastName'.trim();
  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';

  factory MemberModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MemberModel(
      id: doc.id,
      email: d['email'] ?? doc.id,
      firstName: d['firstName'] ?? '',
      lastName: d['lastName'] ?? '',
      role: d['role'] ?? 'member',
      userType: d['userType'] ?? 'athlete',
      earnings: (d['earnings'] ?? 0).toDouble(),
      joinedAt: (d['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isBanned: d['isBanned'] ?? false,
      avatarUrl: d['avatarUrl'],
      addedBy: d['addedBy'],
    );
  }
}

// ─────────────────────────────────────────────
//  PostModel
// ─────────────────────────────────────────────
class PostModel {
  final String id;
  final String groupId;
  final String authorId;
  final String authorName;
  final String authorType;
  final String? authorAvatar;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final PostType postType;
  final int likes;
  final int commentsCount;
  final bool isPinned;
  final List<String> likedBy;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.groupId,
    required this.authorId,
    required this.authorName,
    required this.authorType,
    this.authorAvatar,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    required this.postType,
    required this.likes,
    required this.commentsCount,
    required this.isPinned,
    required this.likedBy,
    required this.createdAt,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      groupId: d['groupId'] ?? '',
      authorId: d['authorId'] ?? '',
      authorName: d['authorName'] ?? '',
      authorType: d['authorType'] ?? 'athlete',
      authorAvatar: d['authorAvatar'],
      content: d['content'] ?? '',
      imageUrl: d['imageUrl'],
      videoUrl: d['videoUrl'],
      postType: PostType.values.firstWhere(
        (e) => e.name == (d['postType'] ?? 'text'),
        orElse: () => PostType.text,
      ),
      likes: d['likes'] ?? 0,
      commentsCount: d['commentsCount'] ?? 0,
      isPinned: d['isPinned'] ?? false,
      likedBy: List<String>.from(d['likedBy'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
//  CommentModel
// ─────────────────────────────────────────────
class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorType;
  final String? authorAvatar;
  final String content;
  final int likes;
  final List<String> likedBy;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorType,
    this.authorAvatar,
    required this.content,
    required this.likes,
    required this.likedBy,
    required this.createdAt,
  });

  factory CommentModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: d['postId'] ?? '',
      authorId: d['authorId'] ?? '',
      authorName: d['authorName'] ?? '',
      authorType: d['authorType'] ?? 'fan',
      authorAvatar: d['authorAvatar'],
      content: d['content'] ?? '',
      likes: d['likes'] ?? 0,
      likedBy: List<String>.from(d['likedBy'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
//  DonationModel
// ─────────────────────────────────────────────
class DonationModel {
  final String id;
  final String groupId;
  final String groupName;
  final String? donorId;
  final String donorEmail;
  final String donorName;
  final String? donorType;
  final double amount;
  final String? message;
  final bool isAnonymous;
  final DonationStatus status;
  final double splitAmount;
  final int memberCount;
  final DateTime createdAt;
  final String? transactionRef;

  DonationModel({
    required this.id,
    required this.groupId,
    required this.groupName,
    this.donorId,
    required this.donorEmail,
    required this.donorName,
    this.donorType,
    required this.amount,
    this.message,
    required this.isAnonymous,
    required this.status,
    required this.splitAmount,
    required this.memberCount,
    required this.createdAt,
    this.transactionRef,
  });

  factory DonationModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return DonationModel(
      id: doc.id,
      groupId: d['groupId'] ?? '',
      groupName: d['groupName'] ?? '',
      donorId: d['donorId'],
      donorEmail: d['donorEmail'] ?? '',
      donorName: d['donorName'] ?? '',
      donorType: d['donorType'],
      amount: (d['amount'] ?? 0).toDouble(),
      message: d['message'],
      isAnonymous: d['isAnonymous'] ?? false,
      status: DonationStatus.values.firstWhere(
        (e) => e.name == (d['status'] ?? 'pending'),
        orElse: () => DonationStatus.pending,
      ),
      splitAmount: (d['splitAmount'] ?? 0).toDouble(),
      memberCount: d['memberCount'] ?? 1,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionRef: d['transactionRef'],
    );
  }
}

// ─────────────────────────────────────────────
//  GroupAnalytics
// ─────────────────────────────────────────────
class GroupAnalytics {
  final int totalMembers;
  final int athleteMembers;
  final double totalDonations;
  final double monthlyRevenue;
  final double myEarnings;
  final int totalPosts;
  final int totalDonors;
  final List<DonationModel> recentDonations;

  GroupAnalytics({
    required this.totalMembers,
    required this.athleteMembers,
    required this.totalDonations,
    required this.monthlyRevenue,
    required this.myEarnings,
    required this.totalPosts,
    required this.totalDonors,
    required this.recentDonations,
  });
}

// ─────────────────────────────────────────────
//  NotificationModel
// ─────────────────────────────────────────────
class GroupNotificationModel {
  final String id;
  final String type; // 'join_approved' | 'join_rejected' | 'added_to_group'
  final String groupId;
  final String groupName;
  final String? message;
  final bool isRead;
  final DateTime createdAt;

  GroupNotificationModel({
    required this.id,
    required this.type,
    required this.groupId,
    required this.groupName,
    this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory GroupNotificationModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GroupNotificationModel(
      id: doc.id,
      type: d['type'] ?? '',
      groupId: d['groupId'] ?? '',
      groupName: d['groupName'] ?? '',
      message: d['message'],
      isRead: d['isRead'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
