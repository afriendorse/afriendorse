// lib/athlete/feature/groups/repository/group_firestore_service.dart

/*

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afriendorse/athlete/feature/groups/models/group_models.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'dart:math';

class GroupFirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference get _groups => _db.collection('groups');
  static CollectionReference get _donations => _db.collection('donations');
  static CollectionReference get _profiles =>
      _db.collection('athlete_profiles');
  static CollectionReference get _users => _db.collection('users');
  static CollectionReference get _athletes => _db.collection('athletes');

  // ─────────────────────────────────────────────
  //  USER ROLE
  // ─────────────────────────────────────────────

  static Future<UserRole> getUserRole(String userId) async {
    if (userId.isEmpty) return UserRole.unknown;
    try {
      final athleteDoc = await _athletes.doc(userId).get();
      if (athleteDoc.exists) return UserRole.athlete;

      final profileDoc = await _profiles.doc(userId).get();
      if (profileDoc.exists) return UserRole.athlete;

      final userDoc = await _users.doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        final type = data?['userType'] as String?;
        if (type == 'brand') return UserRole.brand;
        if (type == 'fan') return UserRole.fan;
      }
      return UserRole.unknown;
    } catch (e) {
      if (kDebugMode) print('getUserRole error: $e');
      return UserRole.unknown;
    }
  }

  static Future<Map<String, String>> getUserDisplayInfo(String userId) async {
    try {
      final athleteDoc = await _athletes.doc(userId).get();
      if (athleteDoc.exists) {
        final d = athleteDoc.data() as Map<String, dynamic>;
        return {
          'name': '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim(),
          'firstName': d['firstName'] ?? '',
          'lastName': d['lastName'] ?? '',
          'email': d['email'] ?? userId,
          'type': 'athlete',
          'avatar': d['avatar'] ?? d['profileImage'] ?? '',
        };
      }
      final userDoc = await _users.doc(userId).get();
      if (userDoc.exists) {
        final d = userDoc.data() as Map<String, dynamic>;
        return {
          'name':
              '${d['firstName'] ?? d['fName'] ?? ''} ${d['lastName'] ?? d['lName'] ?? ''}'
                  .trim(),
          'firstName': d['firstName'] ?? d['fName'] ?? '',
          'lastName': d['lastName'] ?? d['lName'] ?? '',
          'email': d['email'] ?? userId,
          'type': d['userType'] ?? 'unknown',
          'avatar': d['avatar'] ?? d['profileImage'] ?? '',
        };
      }
    } catch (e) {
      if (kDebugMode) print('getUserDisplayInfo error: $e');
    }
    return {
      'name': 'Unknown',
      'firstName': 'Unknown',
      'lastName': '',
      'email': userId,
      'type': 'unknown',
      'avatar': '',
    };
  }

  // ─────────────────────────────────────────────
  //  GROUP CRUD
  // ─────────────────────────────────────────────

  static Future<String?> createGroup({
    required String creatorEmail,
    required String creatorName,
    required String name,
    required String description,
    required String sport,
    String? coverImage,
    bool isPublic = true,
  }) async {
    try {
      final inviteCode = _generateInviteCode();
      final groupRef = _groups.doc();
      final batch = _db.batch();

      batch.set(groupRef, {
        'name': name,
        'description': description,
        'creatorId': creatorEmail,
        'creatorName': creatorName,
        'creatorType': 'athlete',
        'sport': sport,
        'isPublic': isPublic,
        'inviteCode': inviteCode,
        'coverImage': coverImage ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'memberCount': 1,
        'totalDonations': 0.0,
        'pendingDonations': 0.0,
        'pinnedPostId': null,
      });

      // ✅ FIX: explicitly set isBanned: false so Firestore range queries work
      batch.set(groupRef.collection('members').doc(creatorEmail), {
        'email': creatorEmail,
        'firstName': creatorName.split(' ').first,
        'lastName': creatorName.split(' ').length > 1
            ? creatorName.split(' ').last
            : '',
        'joinedAt': FieldValue.serverTimestamp(),
        'role': 'admin',
        'userType': 'athlete',
        'earnings': 0.0,
        'isBanned': false, // ✅ must be explicit — not missing/null
      });

      final profileDoc = await _profiles.doc(creatorEmail).get();
      if (profileDoc.exists) {
        batch.update(_profiles.doc(creatorEmail), {
          'groups': FieldValue.arrayUnion([groupRef.id]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return groupRef.id;
    } catch (e) {
      if (kDebugMode) print('createGroup error: $e');
      return null;
    }
  }

  static Future<bool> updateGroup({
    required String groupId,
    required String requesterId,
    String? name,
    String? description,
    String? coverImage,
    String? sport,
    bool? isPublic,
  }) async {
    try {
      // Verify requester is admin
      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(requesterId)
          .get();
      if (!memberDoc.exists) return false;
      final memberData = memberDoc.data() as Map<String, dynamic>;
      if (memberData['role'] != 'admin') return false;

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (coverImage != null) updates['coverImage'] = coverImage;
      if (sport != null) updates['sport'] = sport;
      if (isPublic != null) updates['isPublic'] = isPublic;

      await _groups.doc(groupId).update(updates);
      return true;
    } catch (e) {
      if (kDebugMode) print('updateGroup error: $e');
      return false;
    }
  }

  static Future<bool> deleteGroup({
    required String groupId,
    required String requesterId,
  }) async {
    try {
      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(requesterId)
          .get();
      if (!memberDoc.exists) return false;
      final memberData = memberDoc.data() as Map<String, dynamic>;
      if (memberData['role'] != 'admin') return false;

      // Get all members to clean up their profiles
      final membersSnap = await _groups
          .doc(groupId)
          .collection('members')
          .get();
      final batch = _db.batch();

      for (final m in membersSnap.docs) {
        final email = m.id;
        final profileDoc = await _profiles.doc(email).get();
        if (profileDoc.exists) {
          batch.update(_profiles.doc(email), {
            'groups': FieldValue.arrayRemove([groupId]),
          });
        }
        batch.delete(m.reference);
      }

      // Delete posts
      final postsSnap = await _groups.doc(groupId).collection('posts').get();
      for (final p in postsSnap.docs) {
        batch.delete(p.reference);
      }

      batch.delete(_groups.doc(groupId));
      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('deleteGroup error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  MEMBERSHIP
  // ─────────────────────────────────────────────

  static Future<bool> joinGroup({
    required String groupId,
    required String userId,
    required String firstName,
    required String lastName,
    required String userType,
    String? avatarUrl,
  }) async {
    try {
      final groupRef = _groups.doc(groupId);
      final groupDoc = await groupRef.get();
      if (!groupDoc.exists) return false;

      final memberDoc = await groupRef.collection('members').doc(userId).get();
      if (memberDoc.exists) {
        final d = memberDoc.data() as Map<String, dynamic>;
        if (d['isBanned'] == true) {
          showCustomSnackBar('You have been banned from this group');
          return false;
        }
        showCustomSnackBar('You are already a member of this group');
        return false;
      }

      final batch = _db.batch();
      batch.set(groupRef.collection('members').doc(userId), {
        'email': userId,
        'firstName': firstName,
        'lastName': lastName,
        'joinedAt': FieldValue.serverTimestamp(),
        'role': 'member',
        'userType': userType,
        'earnings': 0.0,
        'isBanned': false,
        'avatarUrl': avatarUrl ?? '',
      });

      batch.update(groupRef, {
        'memberCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add group to athlete profile if athlete
      if (userType == 'athlete') {
        final profileDoc = await _profiles.doc(userId).get();
        if (profileDoc.exists) {
          batch.update(_profiles.doc(userId), {
            'groups': FieldValue.arrayUnion([groupId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('joinGroup error: $e');
      return false;
    }
  }

  static Future<bool> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final groupRef = _groups.doc(groupId);
      final memberDoc = await groupRef.collection('members').doc(userId).get();
      if (!memberDoc.exists) return false;

      final memberData = memberDoc.data() as Map<String, dynamic>;
      if (memberData['role'] == 'admin') {
        showCustomSnackBar(
          'Admin cannot leave the group. Transfer ownership first.',
        );
        return false;
      }

      final batch = _db.batch();
      batch.delete(memberDoc.reference);
      batch.update(groupRef, {
        'memberCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final profileDoc = await _profiles.doc(userId).get();
      if (profileDoc.exists) {
        batch.update(_profiles.doc(userId), {
          'groups': FieldValue.arrayRemove([groupId]),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('leaveGroup error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  ADVANCED MEMBERSHIP MANAGEMENT
  // ─────────────────────────────────────────────

  /// Transfer group ownership from current admin to another athlete member
  static Future<bool> transferOwnership({
    required String groupId,
    required String currentAdminId,
    required String newAdminId,
  }) async {
    try {
      // Verify current admin
      final currentAdminDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(currentAdminId)
          .get();

      if (!currentAdminDoc.exists) return false;
      final currentData = currentAdminDoc.data() as Map<String, dynamic>;
      if (currentData['role'] != 'admin') return false;

      // Verify new admin is an athlete member (not banned)
      final newAdminDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(newAdminId)
          .get();

      if (!newAdminDoc.exists) return false;
      final newData = newAdminDoc.data() as Map<String, dynamic>;
      if (newData['isBanned'] == true || newData['userType'] != 'athlete') {
        return false;
      }

      // Atomic transfer
      final batch = _db.batch();

      // Demote current admin to regular member
      batch.update(currentAdminDoc.reference, {'role': 'member'});

      // Promote new admin
      batch.update(newAdminDoc.reference, {'role': 'admin'});

      // Update group creator metadata (optional, for analytics)
      batch.update(_groups.doc(groupId), {
        'creatorId': newAdminId,
        'creatorName': '${newData['firstName']} ${newData['lastName']}'.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('transferOwnership error: $e');
      return false;
    }
  }

  /// Promote member to moderator (or demote back to member)
  static Future<bool> toggleModeratorRole({
    required String groupId,
    required String adminId,
    required String memberId,
    required bool promote, // true = make moderator, false = demote to member
  }) async {
    try {
      // Verify requester is admin
      final adminDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(adminId)
          .get();

      if (!adminDoc.exists) return false;
      final adminData = adminDoc.data() as Map<String, dynamic>;
      if (adminData['role'] != 'admin') return false;

      // Verify target member exists and is not banned
      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(memberId)
          .get();

      if (!memberDoc.exists) return false;
      final memberData = memberDoc.data() as Map<String, dynamic>;
      if (memberData['isBanned'] == true) return false;

      // Can't change admin's role via this method
      if (memberData['role'] == 'admin') return false;

      // Update role
      await memberDoc.reference.update({
        'role': promote ? 'moderator' : 'member',
      });

      return true;
    } catch (e) {
      if (kDebugMode) print('toggleModeratorRole error: $e');
      return false;
    }
  }

  static Future<bool> removeMember({
    required String groupId,
    required String adminId,
    required String memberId,
    bool ban = false,
  }) async {
    try {
      // Verify requester is admin or moderator
      final adminDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(adminId)
          .get();
      if (!adminDoc.exists) return false;
      final adminData = adminDoc.data() as Map<String, dynamic>;
      if (!['admin', 'moderator'].contains(adminData['role'])) return false;

      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(memberId)
          .get();
      if (!memberDoc.exists) return false;

      final batch = _db.batch();

      if (ban) {
        // Keep doc but mark as banned so they can't rejoin
        batch.update(memberDoc.reference, {'isBanned': true, 'role': 'banned'});
      } else {
        batch.delete(memberDoc.reference);
      }

      batch.update(_groups.doc(groupId), {
        'memberCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final profileDoc = await _profiles.doc(memberId).get();
      if (profileDoc.exists) {
        batch.update(_profiles.doc(memberId), {
          'groups': FieldValue.arrayRemove([groupId]),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('removeMember error: $e');
      return false;
    }
  }

  static Future<bool> unbanMember({
    required String groupId,
    required String adminId,
    required String memberId,
  }) async {
    try {
      final adminDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(adminId)
          .get();
      if (!adminDoc.exists) return false;
      final adminData = adminDoc.data() as Map<String, dynamic>;
      if (adminData['role'] != 'admin') return false;

      await _groups.doc(groupId).collection('members').doc(memberId).delete();
      return true;
    } catch (e) {
      if (kDebugMode) print('unbanMember error: $e');
      return false;
    }
  }

  static Future<bool> isMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      final doc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .get();
      if (!doc.exists) return false;
      final d = doc.data() as Map<String, dynamic>;
      return d['isBanned'] != true;
    } catch (e) {
      return false;
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getMemberStream({
    required String groupId,
    required String userId,
  }) {
    return _groups.doc(groupId).collection('members').doc(userId).snapshots();
  }

  // ─────────────────────────────────────────────
  //  POSTS
  // ─────────────────────────────────────────────

  static Future<String?> createPost({
    required String groupId,
    required String authorId,
    required String authorName,
    required String authorType,
    required String content,
    String? imageUrl,
    String? videoUrl,
    PostType postType = PostType.text,
    String? authorAvatar,
  }) async {
    try {
      final ref = await _groups.doc(groupId).collection('posts').add({
        'groupId': groupId,
        'authorId': authorId,
        'authorName': authorName,
        'authorType': authorType,
        'authorAvatar': authorAvatar ?? '',
        'content': content,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'postType': postType.name,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        'commentsCount': 0,
        'isPinned': false,
      });
      return ref.id;
    } catch (e) {
      if (kDebugMode) print('createPost error: $e');
      return null;
    }
  }

  static Future<bool> deletePost({
    required String groupId,
    required String postId,
    required String requesterId,
  }) async {
    try {
      // Allow post author OR admin/moderator to delete
      final postDoc = await _groups
          .doc(groupId)
          .collection('posts')
          .doc(postId)
          .get();
      if (!postDoc.exists) return false;
      final postData = postDoc.data() as Map<String, dynamic>;

      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(requesterId)
          .get();
      final memberData = memberDoc.exists
          ? memberDoc.data() as Map<String, dynamic>
          : null;
      final isModOrAdmin = ['admin', 'moderator'].contains(memberData?['role']);
      final isAuthor = postData['authorId'] == requesterId;

      if (!isAuthor && !isModOrAdmin) return false;

      final batch = _db.batch();
      batch.delete(postDoc.reference);

      // Unpin if this was pinned post
      final groupDoc = await _groups.doc(groupId).get();
      final groupData = groupDoc.data() as Map<String, dynamic>;
      if (groupData['pinnedPostId'] == postId) {
        batch.update(_groups.doc(groupId), {'pinnedPostId': null});
      }

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('deletePost error: $e');
      return false;
    }
  }

  static Future<bool> pinPost({
    required String groupId,
    required String postId,
    required String adminId,
  }) async {
    try {
      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(adminId)
          .get();
      if (!memberDoc.exists) return false;
      final d = memberDoc.data() as Map<String, dynamic>;
      if (!['admin', 'moderator'].contains(d['role'])) return false;

      final batch = _db.batch();
      // Unpin previous if any
      final groupDoc = await _groups.doc(groupId).get();
      final groupData = groupDoc.data() as Map<String, dynamic>;
      if (groupData['pinnedPostId'] != null &&
          groupData['pinnedPostId'] != postId) {
        batch.update(
          _groups
              .doc(groupId)
              .collection('posts')
              .doc(groupData['pinnedPostId']),
          {'isPinned': false},
        );
      }

      batch.update(_groups.doc(groupId), {'pinnedPostId': postId});
      batch.update(_groups.doc(groupId).collection('posts').doc(postId), {
        'isPinned': true,
      });
      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('pinPost error: $e');
      return false;
    }
  }

  static Future<bool> unpinPost({
    required String groupId,
    required String postId,
    required String adminId,
  }) async {
    try {
      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(adminId)
          .get();
      if (!memberDoc.exists) return false;
      final d = memberDoc.data() as Map<String, dynamic>;
      if (!['admin', 'moderator'].contains(d['role'])) return false;

      final batch = _db.batch();
      batch.update(_groups.doc(groupId), {'pinnedPostId': null});
      batch.update(_groups.doc(groupId).collection('posts').doc(postId), {
        'isPinned': false,
      });
      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('unpinPost error: $e');
      return false;
    }
  }

  static Future<bool> toggleLikePost({
    required String groupId,
    required String postId,
    required String userId,
  }) async {
    try {
      final postRef = _groups.doc(groupId).collection('posts').doc(postId);
      final postDoc = await postRef.get();
      if (!postDoc.exists) return false;
      final d = postDoc.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(d['likedBy'] ?? []);

      if (likedBy.contains(userId)) {
        await postRef.update({
          'likedBy': FieldValue.arrayRemove([userId]),
          'likes': FieldValue.increment(-1),
        });
      } else {
        await postRef.update({
          'likedBy': FieldValue.arrayUnion([userId]),
          'likes': FieldValue.increment(1),
        });
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('toggleLikePost error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  COMMENTS
  // ─────────────────────────────────────────────

  static Future<bool> addComment({
    required String groupId,
    required String postId,
    required String authorId,
    required String authorName,
    required String authorType,
    required String content,
    String? authorAvatar,
  }) async {
    try {
      final postRef = _groups.doc(groupId).collection('posts').doc(postId);
      final batch = _db.batch();

      final commentRef = postRef.collection('comments').doc();
      batch.set(commentRef, {
        'postId': postId,
        'authorId': authorId,
        'authorName': authorName,
        'authorType': authorType,
        'authorAvatar': authorAvatar ?? '',
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
      });

      batch.update(postRef, {'commentsCount': FieldValue.increment(1)});
      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('addComment error: $e');
      return false;
    }
  }

  static Future<bool> deleteComment({
    required String groupId,
    required String postId,
    required String commentId,
    required String requesterId,
  }) async {
    try {
      final commentRef = _groups
          .doc(groupId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);
      final commentDoc = await commentRef.get();
      if (!commentDoc.exists) return false;
      final d = commentDoc.data() as Map<String, dynamic>;

      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(requesterId)
          .get();
      final memberData = memberDoc.exists
          ? memberDoc.data() as Map<String, dynamic>
          : null;
      final isModOrAdmin = ['admin', 'moderator'].contains(memberData?['role']);
      final isAuthor = d['authorId'] == requesterId;

      if (!isAuthor && !isModOrAdmin) return false;

      final postRef = _groups.doc(groupId).collection('posts').doc(postId);
      final batch = _db.batch();
      batch.delete(commentRef);
      batch.update(postRef, {'commentsCount': FieldValue.increment(-1)});
      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('deleteComment error: $e');
      return false;
    }
  }

  static Future<bool> toggleLikeComment({
    required String groupId,
    required String postId,
    required String commentId,
    required String userId,
  }) async {
    try {
      final commentRef = _groups
          .doc(groupId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);
      final doc = await commentRef.get();
      if (!doc.exists) return false;
      final d = doc.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(d['likedBy'] ?? []);

      if (likedBy.contains(userId)) {
        await commentRef.update({
          'likedBy': FieldValue.arrayRemove([userId]),
          'likes': FieldValue.increment(-1),
        });
      } else {
        await commentRef.update({
          'likedBy': FieldValue.arrayUnion([userId]),
          'likes': FieldValue.increment(1),
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Stream<QuerySnapshot> getComments({
    required String groupId,
    required String postId,
  }) {
    return _groups
        .doc(groupId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // ─────────────────────────────────────────────
  //  STREAMS
  // ─────────────────────────────────────────────

  static Stream<QuerySnapshot> getPublicGroups() {
    return _groups
        .where('isPublic', isEqualTo: true)
        .orderBy('memberCount', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getGroupPosts(String groupId) {
    return _groups
        .doc(groupId)
        .collection('posts')
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getGroupMembers(String groupId) {
    // Fetch all members, filter out banned ones client-side
    // This ensures the creator/admin always appears even if isBanned field is absent
    return _groups
        .doc(groupId)
        .collection('members')
        .orderBy('joinedAt')
        .snapshots();
  }

  static Stream<QuerySnapshot> getBannedMembers(String groupId) {
    return _groups
        .doc(groupId)
        .collection('members')
        .where('isBanned', isEqualTo: true)
        .snapshots();
  }

  static Future<DocumentSnapshot?> getGroupByInviteCode(String code) async {
    final q = await _groups.where('inviteCode', isEqualTo: code).limit(1).get();
    return q.docs.isNotEmpty ? q.docs.first : null;
  }

  // ─────────────────────────────────────────────
  //  DONATIONS
  // ─────────────────────────────────────────────
  static Future<String?> initiateDonation({
    required String groupId,
    required double amount,
    required String donorId,
    required String donorEmail,
    required String donorName,
    required String donorType,
    String? message,
    bool isAnonymous = false,
  }) async {
    try {
      final groupDoc = await _groups.doc(groupId).get();
      if (!groupDoc.exists) return null;
      final groupData = groupDoc.data() as Map<String, dynamic>;

      // ✅ FIX: fetch ALL members then filter client-side
      // Firestore skips docs where 'isBanned' field is absent when using ==false
      // Client-side filter handles both missing field and explicit false correctly
      final allMembersSnap = await _groups
          .doc(groupId)
          .collection('members')
          .get();

      final eligibleMembers = allMembersSnap.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final isAthlete = (data['userType'] as String?) == 'athlete';
        final isBanned = (data['isBanned'] as bool?) == true; // missing = false
        return isAthlete && !isBanned;
      }).toList();

      // Always split among at least 1 to avoid division by zero
      final athleteCount = eligibleMembers.isEmpty ? 1 : eligibleMembers.length;
      final splitAmount = amount / athleteCount;

      if (kDebugMode) {
        print(
          '[initiateDonation] eligible athletes=$athleteCount '
          'splitAmount=$splitAmount',
        );
        for (final m in eligibleMembers) {
          print('  → member: ${m.id}');
        }
      }

      final donationRef = _donations.doc();
      await donationRef.set({
        'groupId': groupId,
        'groupName': groupData['name'],
        'donorId': isAnonymous ? null : donorId,
        'donorEmail': donorEmail,
        'donorName': isAnonymous ? 'Anonymous' : donorName,
        'donorType': isAnonymous ? null : donorType,
        'amount': amount,
        'message': message,
        'isAnonymous': isAnonymous,
        'status': 'pending',
        'splitAmount': splitAmount,
        'memberCount': athleteCount,
        // ✅ Store eligible member IDs at snapshot time so completeDonation
        // pays exactly the people who were eligible when the donor paid
        'eligibleMemberIds': eligibleMembers.map((m) => m.id).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'paymentMethod': 'paystack',
        'transactionRef': null,
      });

      await _groups.doc(groupId).update({
        'pendingDonations': FieldValue.increment(amount),
      });

      return donationRef.id;
    } catch (e) {
      if (kDebugMode) print('initiateDonation error: $e');
      return null;
    }
  }

  /// Call this when a campaign goes live
  static Future<void> incrementActiveCampaignCount(String groupId) async {
    await _groups.doc(groupId).update({
      'activeCampaignCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Call this when a campaign ends or is cancelled
  static Future<void> decrementActiveCampaignCount(String groupId) async {
    await _groups.doc(groupId).update({
      'activeCampaignCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<bool> completeDonation({
    required String donationId,
    required String transactionRef,
  }) async {
    try {
      final donationRef = _donations.doc(donationId);
      final donationDoc = await donationRef.get();
      if (!donationDoc.exists) return false;

      final d = donationDoc.data() as Map<String, dynamic>;

      // Guard: don't process an already-completed donation (double-tap safety)
      if (d['status'] == 'completed') {
        if (kDebugMode) print('[completeDonation] already completed, skipping');
        return true;
      }

      final groupId = d['groupId'] as String;
      final amount = (d['amount'] as num).toDouble();
      final groupRef = _groups.doc(groupId);
      final batch = _db.batch();

      // ✅ FIX: use the member IDs that were snapshotted at payment initiation
      // so the split is consistent even if membership changed during checkout
      final snapshotMemberIds =
          (d['eligibleMemberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [];

      List<String> memberIds;
      double splitAmount;

      if (snapshotMemberIds.isNotEmpty) {
        // Happy path: use the pre-computed snapshot
        memberIds = snapshotMemberIds;
        splitAmount = amount / memberIds.length;
        if (kDebugMode) {
          print(
            '[completeDonation] using snapshot: '
            '${memberIds.length} members, split=\${Currency.symbol}splitAmount each',
          );
        }
      } else {
        // Fallback for old donations that don't have eligibleMemberIds
        // Fetch live and filter client-side (same logic as initiateDonation)
        final allMembersSnap = await groupRef.collection('members').get();
        final eligible = allMembersSnap.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final isAthlete = (data['userType'] as String?) == 'athlete';
          final isBanned = (data['isBanned'] as bool?) == true;
          return isAthlete && !isBanned;
        }).toList();

        memberIds = eligible.map((m) => m.id).toList();
        splitAmount = memberIds.isEmpty ? amount : amount / memberIds.length;

        if (kDebugMode) {
          print(
            '[completeDonation] fallback fetch: '
            '${memberIds.length} members, split=\${Currency.symbol}$splitAmount each',
          );
        }
      }

      // Mark donation complete
      batch.update(donationRef, {
        'status': 'completed',
        'transactionRef': transactionRef,
        'processedAt': FieldValue.serverTimestamp(),
        // Persist the final split for auditing
        'finalSplitAmount': splitAmount,
        'finalMemberCount': memberIds.length,
      });

      // Update group totals
      batch.update(groupRef, {
        'totalDonations': FieldValue.increment(amount),
        'pendingDonations': FieldValue.increment(-amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ✅ Credit every eligible athlete — including admin
      for (final memberId in memberIds) {
        final memberRef = groupRef.collection('members').doc(memberId);
        batch.update(memberRef, {
          'earnings': FieldValue.increment(splitAmount),
        });

        // Also update the athlete profile for cross-screen earnings display
        batch.set(_profiles.doc(memberId), {
          'totalGroupEarnings': FieldValue.increment(splitAmount),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (kDebugMode) {
          print(
            '[completeDonation] credited \${Currency.symbol}$splitAmount → $memberId',
          );
        }
      }

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('completeDonation error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getDonationDetails(
    String donationId,
  ) async {
    try {
      final doc = await _donations.doc(donationId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      return null;
    }
  }

  /// Cancel a pending donation (user dismissed payment without completing)
  static Future<void> cancelDonation({required String donationId}) async {
    try {
      final donationDoc = await _donations.doc(donationId).get();
      if (!donationDoc.exists) return;
      final d = donationDoc.data() as Map<String, dynamic>;
      final groupId = d['groupId'] as String?;
      final amount = (d['amount'] as num?)?.toDouble() ?? 0;

      final batch = _db.batch();
      batch.update(_donations.doc(donationId), {
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      if (groupId != null && amount > 0) {
        // Reverse the pendingDonations increment
        batch.update(_groups.doc(groupId), {
          'pendingDonations': FieldValue.increment(-amount),
        });
      }
      await batch.commit();
    } catch (e) {
      if (kDebugMode) print('cancelDonation error: $e');
    }
  }

  /// Get accumulated group earnings for an athlete (for profile/withdrawal)
  /// Returns a map: { totalGroupEarnings, pendingWithdrawal, withdrawn }
  static Future<Map<String, double>> getAthleteGroupEarnings(
    String athleteId,
  ) async {
    try {
      final doc = await _profiles.doc(athleteId).get();
      if (!doc.exists)
        return {
          'totalGroupEarnings': 0,
          'pendingWithdrawal': 0,
          'withdrawn': 0,
        };
      final d = doc.data() as Map<String, dynamic>;
      return {
        'totalGroupEarnings':
            (d['totalGroupEarnings'] as num?)?.toDouble() ?? 0,
        'pendingWithdrawal': (d['pendingWithdrawal'] as num?)?.toDouble() ?? 0,
        'withdrawn': (d['withdrawn'] as num?)?.toDouble() ?? 0,
      };
    } catch (e) {
      if (kDebugMode) print('getAthleteGroupEarnings error: $e');
      return {'totalGroupEarnings': 0, 'pendingWithdrawal': 0, 'withdrawn': 0};
    }
  }

  /// Stream for real-time earnings updates (for profile screen)
  static Stream<Map<String, double>> streamAthleteGroupEarnings(
    String athleteId,
  ) {
    return _profiles.doc(athleteId).snapshots().map((snap) {
      if (!snap.exists) {
        return {
          'totalGroupEarnings': 0.0,
          'pendingWithdrawal': 0.0,
          'withdrawn': 0.0,
        };
      }
      final d = snap.data() as Map<String, dynamic>;
      return {
        'totalGroupEarnings':
            (d['totalGroupEarnings'] as num?)?.toDouble() ?? 0,
        'pendingWithdrawal': (d['pendingWithdrawal'] as num?)?.toDouble() ?? 0,
        'withdrawn': (d['withdrawn'] as num?)?.toDouble() ?? 0,
      };
    });
  }

  static Stream<QuerySnapshot> getGroupDonations(String groupId) {
    return _donations
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  // ─────────────────────────────────────────────
  //  ANALYTICS
  // ─────────────────────────────────────────────

  static Future<GroupAnalytics> getGroupAnalytics({
    required String groupId,
    required String athleteId,
  }) async {
    try {
      final groupDoc = await _groups.doc(groupId).get();
      if (!groupDoc.exists) {
        if (kDebugMode) print('getGroupAnalytics: group $groupId not found');
        return _emptyAnalytics();
      }
      final groupData = groupDoc.data() as Map<String, dynamic>;

      // Total members from group doc (fast)
      final totalMembers = (groupData['memberCount'] as num?)?.toInt() ?? 0;
      final totalDonations =
          (groupData['totalDonations'] as num?)?.toDouble() ?? 0;

      // Athlete member count
      final membersSnap = await _groups
          .doc(groupId)
          .collection('members')
          .get();
      final athleteMemberDocs = membersSnap.docs.where((d) {
        final data = d.data() as Map<String, dynamic>;
        return data['userType'] == 'athlete' && data['isBanned'] != true;
      }).toList();
      final athleteMembers = athleteMemberDocs.length;

      // Post count
      final postsSnap = await _groups
          .doc(groupId)
          .collection('posts')
          .count()
          .get();

      // Monthly revenue — current calendar month
      final now = DateTime.now();
      final firstOfMonth = DateTime(now.year, now.month, 1);
      final monthlyDonationsSnap = await _donations
          .where('groupId', isEqualTo: groupId)
          .where('status', isEqualTo: 'completed')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstOfMonth),
          )
          .get();

      double monthlyRevenue = 0;
      final donorIds = <String>{};
      for (final d in monthlyDonationsSnap.docs) {
        final data = d.data() as Map<String, dynamic>;
        monthlyRevenue += (data['amount'] as num?)?.toDouble() ?? 0;
        if (data['donorId'] != null) donorIds.add(data['donorId'] as String);
      }

      // My earnings — look up by athleteId in members subcollection
      double myEarnings = 0;
      if (athleteId.isNotEmpty) {
        final myDoc = await _groups
            .doc(groupId)
            .collection('members')
            .doc(athleteId)
            .get();
        if (myDoc.exists) {
          final myData = myDoc.data() as Map<String, dynamic>;
          myEarnings = (myData['earnings'] as num?)?.toDouble() ?? 0;
          if (kDebugMode) {
            print('getGroupAnalytics: myEarnings=$myEarnings for $athleteId');
          }
        } else {
          if (kDebugMode) {
            print('getGroupAnalytics: no member doc found for $athleteId');
          }
        }
      }

      // Recent donations (last 5)
      final recentSnap = await _donations
          .where('groupId', isEqualTo: groupId)
          .where('status', isEqualTo: 'completed')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      final recentDonations = recentSnap.docs
          .map((d) => DonationModel.fromDoc(d))
          .toList();

      if (kDebugMode) {
        print(
          'getGroupAnalytics: totalMembers=$totalMembers, '
          'athletes=$athleteMembers, totalDonations=$totalDonations, '
          'monthlyRevenue=$monthlyRevenue, myEarnings=$myEarnings',
        );
      }

      return GroupAnalytics(
        totalMembers: totalMembers,
        athleteMembers: athleteMembers,
        totalDonations: totalDonations,
        monthlyRevenue: monthlyRevenue,
        myEarnings: myEarnings,
        totalPosts: postsSnap.count ?? 0,
        totalDonors: donorIds.length,
        recentDonations: recentDonations,
      );
    } catch (e, st) {
      if (kDebugMode) {
        print('getGroupAnalytics error: $e');
        print(st);
      }
      return _emptyAnalytics();
    }
  }

  static GroupAnalytics _emptyAnalytics() => GroupAnalytics(
    totalMembers: 0,
    athleteMembers: 0,
    totalDonations: 0,
    monthlyRevenue: 0,
    myEarnings: 0,
    totalPosts: 0,
    totalDonors: 0,
    recentDonations: [],
  );

  // ─────────────────────────────────────────────
  //  UTILS
  // ─────────────────────────────────────────────

  static String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}

*/

// lib/athlete/feature/groups/repository/group_firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afriendorse/athlete/feature/groups/models/group_models.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'dart:math';

class GroupFirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference get _groups => _db.collection('groups');
  static CollectionReference get _donations => _db.collection('donations');
  static CollectionReference get _profiles =>
      _db.collection('athlete_profiles');
  static CollectionReference get _users => _db.collection('users');
  static CollectionReference get _athletes => _db.collection('athletes');

  // ─────────────────────────────────────────────
  //  USER ROLE
  // ─────────────────────────────────────────────

  static Future<UserRole> getUserRole(String userId) async {
    if (userId.isEmpty) return UserRole.unknown;
    try {
      final athleteDoc = await _athletes.doc(userId).get();
      if (athleteDoc.exists) return UserRole.athlete;

      final profileDoc = await _profiles.doc(userId).get();
      if (profileDoc.exists) return UserRole.athlete;

      final userDoc = await _users.doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        final type = data?['userType'] as String?;
        if (type == 'brand') return UserRole.brand;
        if (type == 'fan') return UserRole.fan;
      }
      return UserRole.unknown;
    } catch (e) {
      if (kDebugMode) print('getUserRole error: $e');
      return UserRole.unknown;
    }
  }

  static Future<Map<String, String>> getUserDisplayInfo(String userId) async {
    try {
      final athleteDoc = await _athletes.doc(userId).get();
      if (athleteDoc.exists) {
        final d = athleteDoc.data() as Map<String, dynamic>;
        return {
          'name': '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim(),
          'firstName': d['firstName'] ?? '',
          'lastName': d['lastName'] ?? '',
          'email': d['email'] ?? userId,
          'type': 'athlete',
          'avatar': d['avatar'] ?? d['profileImage'] ?? '',
        };
      }
      final userDoc = await _users.doc(userId).get();
      if (userDoc.exists) {
        final d = userDoc.data() as Map<String, dynamic>;
        return {
          'name':
              '${d['firstName'] ?? d['fName'] ?? ''} ${d['lastName'] ?? d['lName'] ?? ''}'
                  .trim(),
          'firstName': d['firstName'] ?? d['fName'] ?? '',
          'lastName': d['lastName'] ?? d['lName'] ?? '',
          'email': d['email'] ?? userId,
          'type': d['userType'] ?? 'unknown',
          'avatar': d['avatar'] ?? d['profileImage'] ?? '',
        };
      }
    } catch (e) {
      if (kDebugMode) print('getUserDisplayInfo error: $e');
    }
    return {
      'name': 'Unknown',
      'firstName': 'Unknown',
      'lastName': '',
      'email': userId,
      'type': 'unknown',
      'avatar': '',
    };
  }

  // ─────────────────────────────────────────────
  //  USER LOOKUP BY EMAIL (for add-by-email flow)
  // ─────────────────────────────────────────────

  /// Looks up a user by email across athlete_profiles and users collections.
  /// Returns a map of display info, or null if not found.
  static Future<Map<String, String>?> lookupUserByEmail(String email) async {
    if (email.trim().isEmpty) return null;
    final normalizedEmail = email.trim().toLowerCase();

    try {
      // Check athlete_profiles first (keyed by email)
      final profileDoc = await _profiles.doc(normalizedEmail).get();
      if (profileDoc.exists) {
        final d = profileDoc.data() as Map<String, dynamic>;
        // Try to get name from providerInfo structure
        final providerInfo =
            d['content']?['providerInfo'] as Map<String, dynamic>?;
        final contactName = providerInfo?['contactPersonName'] as String? ?? '';
        final ownerEmail =
            providerInfo?['owner']?['email'] as String? ?? normalizedEmail;

        return {
          'userId': normalizedEmail,
          'email': ownerEmail,
          'firstName': contactName.split(' ').first,
          'lastName': contactName.split(' ').length > 1
              ? contactName.split(' ').last
              : '',
          'name': contactName.isNotEmpty ? contactName : normalizedEmail,
          'type': 'athlete',
          'avatar': '',
        };
      }

      // Check athletes collection
      final athletesQuery = await _athletes
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();
      if (athletesQuery.docs.isNotEmpty) {
        final d = athletesQuery.docs.first.data() as Map<String, dynamic>;
        return {
          'userId': normalizedEmail,
          'email': d['email'] ?? normalizedEmail,
          'firstName': d['firstName'] ?? '',
          'lastName': d['lastName'] ?? '',
          'name': '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim(),
          'type': 'athlete',
          'avatar': d['avatar'] ?? d['profileImage'] ?? '',
        };
      }

      // Check users collection
      final usersQuery = await _users
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();
      if (usersQuery.docs.isNotEmpty) {
        final d = usersQuery.docs.first.data() as Map<String, dynamic>;
        final firstName = d['firstName'] ?? d['fName'] ?? '';
        final lastName = d['lastName'] ?? d['lName'] ?? '';
        return {
          'userId': d['id'] ?? usersQuery.docs.first.id,
          'email': d['email'] ?? normalizedEmail,
          'firstName': firstName,
          'lastName': lastName,
          'name': '$firstName $lastName'.trim(),
          'type': d['userType'] ?? 'fan',
          'avatar': d['avatar'] ?? d['profileImage'] ?? '',
        };
      }

      return null; // Not found
    } catch (e) {
      if (kDebugMode) print('lookupUserByEmail error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  //  PLATFORM APPROVAL (AfriEndorse admin via Firestore)
  // ─────────────────────────────────────────────

  /// Called by AfriEndorse admin directly via Firestore console,
  /// or can be wired to a future admin panel.
  /// Sets group status to 'active' so it appears in public listings.
  static Future<bool> approveGroup({required String groupId}) async {
    try {
      await _groups.doc(groupId).update({
        'status': 'active',
        'rejectionReason': null,
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify the group creator
      final groupDoc = await _groups.doc(groupId).get();
      if (groupDoc.exists) {
        final d = groupDoc.data() as Map<String, dynamic>;
        final creatorId = d['creatorId'] as String?;
        final groupName = d['name'] as String? ?? 'your group';
        if (creatorId != null && creatorId.isNotEmpty) {
          await _writeNotification(
            userId: creatorId,
            type: 'group_approved',
            groupId: groupId,
            groupName: groupName,
            message:
                'Your group "$groupName" has been approved and is now live!',
          );
        }
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('approveGroup error: $e');
      return false;
    }
  }

  /// Sets group status to 'rejected' with a reason.
  static Future<bool> rejectGroup({
    required String groupId,
    required String reason,
  }) async {
    try {
      final groupDoc = await _groups.doc(groupId).get();
      if (!groupDoc.exists) return false;
      final d = groupDoc.data() as Map<String, dynamic>;
      final creatorId = d['creatorId'] as String?;
      final groupName = d['name'] as String? ?? 'your group';

      await _groups.doc(groupId).update({
        'status': 'rejected',
        'rejectionReason': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (creatorId != null && creatorId.isNotEmpty) {
        await _writeNotification(
          userId: creatorId,
          type: 'group_rejected',
          groupId: groupId,
          groupName: groupName,
          message: 'Your group "$groupName" was not approved. Reason: $reason',
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('rejectGroup error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  GROUP CRUD
  // ─────────────────────────────────────────────

  /// ONE-TIME migration: stamps all groups that are missing
  /// the 'status' field with status='active' so they remain visible.
  /// Call this once from a temporary button or from initState, then remove it.
  static Future<void> migrateExistingGroups() async {
    try {
      final snap = await _groups.get();
      final batch = _db.batch();
      int count = 0;

      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Only touch docs that are missing the status field
        if (!data.containsKey('status')) {
          batch.update(doc.reference, {
            'status': 'active', // approve existing groups
            'requiresApproval': true, // enable approval for new members
            'rejectionReason': null,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          count++;
        }
      }

      await batch.commit();
      if (kDebugMode) print('Migrated $count existing groups to active status');
    } catch (e) {
      if (kDebugMode) print('migrateExistingGroups error: $e');
    }
  }

  static Future<String?> createGroup({
    required String creatorEmail,
    required String creatorName,
    required String name,
    required String description,
    required String sport,
    String? coverImage,
    bool isPublic = true,
    bool requiresApproval = true,
  }) async {
    try {
      final inviteCode = _generateInviteCode();
      final groupRef = _groups.doc();
      final batch = _db.batch();

      batch.set(groupRef, {
        'name': name,
        'description': description,
        'creatorId': creatorEmail,
        'creatorName': creatorName,
        'creatorType': 'athlete',
        'sport': sport,
        'isPublic': isPublic,
        'requiresApproval': requiresApproval,
        'inviteCode': inviteCode,
        'coverImage': coverImage ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'memberCount': 1,
        'totalDonations': 0.0,
        'pendingDonations': 0.0,
        'pinnedPostId': null,
        'activeCampaignCount': 0,
        // ── Platform approval: starts as pending ──
        'status': 'pending',
        'rejectionReason': null,
      });

      batch.set(groupRef.collection('members').doc(creatorEmail), {
        'email': creatorEmail,
        'firstName': creatorName.split(' ').first,
        'lastName': creatorName.split(' ').length > 1
            ? creatorName.split(' ').last
            : '',
        'joinedAt': FieldValue.serverTimestamp(),
        'role': 'admin',
        'userType': 'athlete',
        'earnings': 0.0,
        'isBanned': false,
        'addedBy': 'self',
      });

      final profileDoc = await _profiles.doc(creatorEmail).get();
      if (profileDoc.exists) {
        batch.update(_profiles.doc(creatorEmail), {
          'groups': FieldValue.arrayUnion([groupRef.id]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return groupRef.id;
    } catch (e) {
      if (kDebugMode) print('createGroup error: $e');
      return null;
    }
  }

  static Future<bool> updateGroup({
    required String groupId,
    required String requesterId,
    String? name,
    String? description,
    String? coverImage,
    String? sport,
    bool? isPublic,
    bool? requiresApproval,
  }) async {
    try {
      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(requesterId)
          .get();
      if (!memberDoc.exists) return false;
      final memberData = memberDoc.data() as Map<String, dynamic>;
      if (memberData['role'] != 'admin') return false;

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (coverImage != null) updates['coverImage'] = coverImage;
      if (sport != null) updates['sport'] = sport;
      if (isPublic != null) updates['isPublic'] = isPublic;
      if (requiresApproval != null) {
        updates['requiresApproval'] = requiresApproval;
      }

      await _groups.doc(groupId).update(updates);
      return true;
    } catch (e) {
      if (kDebugMode) print('updateGroup error: $e');
      return false;
    }
  }

  static Future<bool> deleteGroup({
    required String groupId,
    required String requesterId,
  }) async {
    try {
      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(requesterId)
          .get();
      if (!memberDoc.exists) return false;
      final memberData = memberDoc.data() as Map<String, dynamic>;
      if (memberData['role'] != 'admin') return false;

      final membersSnap = await _groups
          .doc(groupId)
          .collection('members')
          .get();
      final batch = _db.batch();

      for (final m in membersSnap.docs) {
        final email = m.id;
        final profileDoc = await _profiles.doc(email).get();
        if (profileDoc.exists) {
          batch.update(_profiles.doc(email), {
            'groups': FieldValue.arrayRemove([groupId]),
          });
        }
        batch.delete(m.reference);
      }

      final postsSnap = await _groups.doc(groupId).collection('posts').get();
      for (final p in postsSnap.docs) {
        batch.delete(p.reference);
      }

      // Also delete join requests
      final requestsSnap = await _groups
          .doc(groupId)
          .collection('joinRequests')
          .get();
      for (final r in requestsSnap.docs) {
        batch.delete(r.reference);
      }

      batch.delete(_groups.doc(groupId));
      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('deleteGroup error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  MEMBERSHIP
  // ─────────────────────────────────────────────

  /// Direct join — used when group does NOT require approval.
  /// Routes to requestJoinGroup() automatically when approval is required.
  static Future<bool> joinGroup({
    required String groupId,
    required String userId,
    required String firstName,
    required String lastName,
    required String userType,
    String? avatarUrl,
  }) async {
    try {
      final groupRef = _groups.doc(groupId);
      final groupDoc = await groupRef.get();
      if (!groupDoc.exists) return false;

      final groupData = groupDoc.data() as Map<String, dynamic>;

      // Guard: group must be active
      if ((groupData['status'] as String?) != 'active') {
        showCustomSnackBar('This group is not currently accepting members');
        return false;
      }

      // Guard: check if requiresApproval — route to request flow
      final requiresApproval =
          (groupData['requiresApproval'] as bool?) ?? false;
      if (requiresApproval) {
        return await requestJoinGroup(
          groupId: groupId,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          userType: userType,
          avatarUrl: avatarUrl,
        );
      }

      // Check existing membership
      final memberDoc = await groupRef.collection('members').doc(userId).get();
      if (memberDoc.exists) {
        final d = memberDoc.data() as Map<String, dynamic>;
        if (d['isBanned'] == true) {
          showCustomSnackBar('You have been banned from this group');
          return false;
        }
        showCustomSnackBar('You are already a member of this group');
        return false;
      }

      // Check if already has a pending request
      final existingRequest = await groupRef
          .collection('joinRequests')
          .doc(userId)
          .get();
      if (existingRequest.exists) {
        final d = existingRequest.data() as Map<String, dynamic>;
        if (d['status'] == 'pending') {
          showCustomSnackBar('Your join request is already pending');
          return false;
        }
      }

      final batch = _db.batch();
      batch.set(groupRef.collection('members').doc(userId), {
        'email': userId,
        'firstName': firstName,
        'lastName': lastName,
        'joinedAt': FieldValue.serverTimestamp(),
        'role': 'member',
        'userType': userType,
        'earnings': 0.0,
        'isBanned': false,
        'avatarUrl': avatarUrl ?? '',
        'addedBy': 'self',
      });

      batch.update(groupRef, {
        'memberCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (userType == 'athlete') {
        final profileDoc = await _profiles.doc(userId).get();
        if (profileDoc.exists) {
          batch.update(_profiles.doc(userId), {
            'groups': FieldValue.arrayUnion([groupId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('joinGroup error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  JOIN REQUESTS
  // ─────────────────────────────────────────────

  /// Writes a join request to groups/{groupId}/joinRequests/{userId}.
  /// Used when group requiresApproval == true.
  static Future<bool> requestJoinGroup({
    required String groupId,
    required String userId,
    required String firstName,
    required String lastName,
    required String userType,
    String? avatarUrl,
  }) async {
    try {
      final groupRef = _groups.doc(groupId);
      final groupDoc = await groupRef.get();
      if (!groupDoc.exists) return false;

      final groupData = groupDoc.data() as Map<String, dynamic>;

      // Guard: group must be active
      if ((groupData['status'] as String?) != 'active') {
        showCustomSnackBar('This group is not currently accepting members');
        return false;
      }

      // Guard: already a member?
      final memberDoc = await groupRef.collection('members').doc(userId).get();
      if (memberDoc.exists) {
        final d = memberDoc.data() as Map<String, dynamic>;
        if (d['isBanned'] == true) {
          showCustomSnackBar('You have been banned from this group');
          return false;
        }
        showCustomSnackBar('You are already a member of this group');
        return false;
      }

      // Guard: already has pending request?
      final existingRequest = await groupRef
          .collection('joinRequests')
          .doc(userId)
          .get();
      if (existingRequest.exists) {
        final d = existingRequest.data() as Map<String, dynamic>;
        if (d['status'] == 'pending') {
          showCustomSnackBar(
            'You already have a pending request for this group',
          );
          return false;
        }
      }

      // Write request — use userId as doc ID so we can check duplicates easily
      await groupRef.collection('joinRequests').doc(userId).set({
        'userId': userId,
        'email': userId, // userId is email in this app
        'firstName': firstName,
        'lastName': lastName,
        'userType': userType,
        'avatarUrl': avatarUrl ?? '',
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // Notify group admin
      final creatorId = groupData['creatorId'] as String?;
      final groupName = groupData['name'] as String? ?? 'your group';
      if (creatorId != null && creatorId.isNotEmpty) {
        await _writeNotification(
          userId: creatorId,
          type: 'join_request',
          groupId: groupId,
          groupName: groupName,
          message: '$firstName $lastName has requested to join "$groupName".',
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('requestJoinGroup error: $e');
      return false;
    }
  }

  /// Approve a pending join request.
  /// Can be called by admin or moderator.
  static Future<bool> approveJoinRequest({
    required String groupId,
    required String approverId,
    required String requestId, // same as userId
  }) async {
    try {
      // Verify approver is admin or moderator
      final approverDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(approverId)
          .get();
      if (!approverDoc.exists) return false;
      final approverData = approverDoc.data() as Map<String, dynamic>;
      if (!['admin', 'moderator'].contains(approverData['role'])) {
        return false;
      }

      final groupRef = _groups.doc(groupId);
      final requestRef = groupRef.collection('joinRequests').doc(requestId);
      final requestDoc = await requestRef.get();
      if (!requestDoc.exists) return false;

      final requestData = requestDoc.data() as Map<String, dynamic>;
      if ((requestData['status'] as String?) != 'pending') return false;

      final groupDoc = await groupRef.get();
      final groupData = groupDoc.data() as Map<String, dynamic>;
      final groupName = groupData['name'] as String? ?? 'the group';

      final batch = _db.batch();

      // Add to members
      batch.set(groupRef.collection('members').doc(requestId), {
        'email': requestData['email'] ?? requestId,
        'firstName': requestData['firstName'] ?? '',
        'lastName': requestData['lastName'] ?? '',
        'joinedAt': FieldValue.serverTimestamp(),
        'role': 'member',
        'userType': requestData['userType'] ?? 'fan',
        'earnings': 0.0,
        'isBanned': false,
        'avatarUrl': requestData['avatarUrl'] ?? '',
        'addedBy': 'approved',
      });

      // Increment member count
      batch.update(groupRef, {
        'memberCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mark request as approved
      batch.update(requestRef, {
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': approverId,
      });

      // If athlete, add group to their profile
      final userType = requestData['userType'] as String?;
      if (userType == 'athlete') {
        final profileDoc = await _profiles.doc(requestId).get();
        if (profileDoc.exists) {
          batch.update(_profiles.doc(requestId), {
            'groups': FieldValue.arrayUnion([groupId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();

      // Notify the requester
      final firstName = requestData['firstName'] as String? ?? '';
      await _writeNotification(
        userId: requestId,
        type: 'join_approved',
        groupId: groupId,
        groupName: groupName,
        message:
            'Your request to join "$groupName" has been approved. Welcome!',
      );

      return true;
    } catch (e) {
      if (kDebugMode) print('approveJoinRequest error: $e');
      return false;
    }
  }

  /// Reject a pending join request.
  /// Can be called by admin or moderator.
  static Future<bool> rejectJoinRequest({
    required String groupId,
    required String rejecterId,
    required String requestId,
  }) async {
    try {
      // Verify rejecter is admin or moderator
      final rejecterDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(rejecterId)
          .get();
      if (!rejecterDoc.exists) return false;
      final rejecterData = rejecterDoc.data() as Map<String, dynamic>;
      if (!['admin', 'moderator'].contains(rejecterData['role'])) {
        return false;
      }

      final groupRef = _groups.doc(groupId);
      final requestRef = groupRef.collection('joinRequests').doc(requestId);
      final requestDoc = await requestRef.get();
      if (!requestDoc.exists) return false;

      final requestData = requestDoc.data() as Map<String, dynamic>;
      if ((requestData['status'] as String?) != 'pending') return false;

      final groupDoc = await groupRef.get();
      final groupData = groupDoc.data() as Map<String, dynamic>;
      final groupName = groupData['name'] as String? ?? 'the group';

      await requestRef.update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': rejecterId,
      });

      // Notify the requester
      await _writeNotification(
        userId: requestId,
        type: 'join_rejected',
        groupId: groupId,
        groupName: groupName,
        message:
            'Your request to join "$groupName" was not approved at this time.',
      );

      return true;
    } catch (e) {
      if (kDebugMode) print('rejectJoinRequest error: $e');
      return false;
    }
  }

  /// Stream of pending join requests for a group.
  /// Visible to admin and moderators.
  static Stream<QuerySnapshot> getJoinRequests(String groupId) {
    return _groups
        .doc(groupId)
        .collection('joinRequests')
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: false)
        .snapshots();
  }

  // ─────────────────────────────────────────────
  //  ADD MEMBER BY EMAIL
  // ─────────────────────────────────────────────

  /// Add a specific user directly to a group by email.
  /// Available to: group admin (for their group), platform (any group).
  /// [addedBy]: 'admin' or 'platform'
  static Future<bool> addMemberByEmail({
    required String groupId,
    required String requesterId,
    required String targetEmail,
    required String addedBy, // 'admin' | 'platform'
  }) async {
    try {
      final normalizedEmail = targetEmail.trim().toLowerCase();

      // If called by group admin, verify they are admin
      if (addedBy == 'admin') {
        final requesterDoc = await _groups
            .doc(groupId)
            .collection('members')
            .doc(requesterId)
            .get();
        if (!requesterDoc.exists) return false;
        final requesterData = requesterDoc.data() as Map<String, dynamic>;
        if (requesterData['role'] != 'admin') return false;
      }

      final groupRef = _groups.doc(groupId);
      final groupDoc = await groupRef.get();
      if (!groupDoc.exists) return false;
      final groupData = groupDoc.data() as Map<String, dynamic>;
      final groupName = groupData['name'] as String? ?? 'the group';

      // Guard: group must be active
      if ((groupData['status'] as String?) != 'active') {
        showCustomSnackBar('Group is not active');
        return false;
      }

      // Check existing membership
      final memberDoc = await groupRef
          .collection('members')
          .doc(normalizedEmail)
          .get();
      if (memberDoc.exists) {
        final d = memberDoc.data() as Map<String, dynamic>;
        if (d['isBanned'] == true) {
          showCustomSnackBar('This user is banned from the group');
          return false;
        }
        showCustomSnackBar('This user is already a member');
        return false;
      }

      // Lookup user details
      final userInfo = await lookupUserByEmail(normalizedEmail);
      if (userInfo == null) {
        showCustomSnackBar('No user found with that email');
        return false;
      }

      final batch = _db.batch();

      batch.set(groupRef.collection('members').doc(normalizedEmail), {
        'email': userInfo['email'] ?? normalizedEmail,
        'firstName': userInfo['firstName'] ?? '',
        'lastName': userInfo['lastName'] ?? '',
        'joinedAt': FieldValue.serverTimestamp(),
        'role': 'member',
        'userType': userInfo['type'] ?? 'fan',
        'earnings': 0.0,
        'isBanned': false,
        'avatarUrl': userInfo['avatar'] ?? '',
        'addedBy': addedBy,
      });

      batch.update(groupRef, {
        'memberCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If athlete, update their profile groups array
      if (userInfo['type'] == 'athlete') {
        final profileDoc = await _profiles.doc(normalizedEmail).get();
        if (profileDoc.exists) {
          batch.update(_profiles.doc(normalizedEmail), {
            'groups': FieldValue.arrayUnion([groupId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Also cancel any pending request from this user
      final requestDoc = await groupRef
          .collection('joinRequests')
          .doc(normalizedEmail)
          .get();
      if (requestDoc.exists) {
        batch.update(requestDoc.reference, {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': requesterId,
        });
      }

      await batch.commit();

      // Notify the added user
      await _writeNotification(
        userId: normalizedEmail,
        type: 'added_to_group',
        groupId: groupId,
        groupName: groupName,
        message: addedBy == 'platform'
            ? 'You have been added to "$groupName" by AfriEndorse.'
            : 'You have been added to "$groupName" by the group admin.',
      );

      return true;
    } catch (e) {
      if (kDebugMode) print('addMemberByEmail error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  NOTIFICATIONS
  // ─────────────────────────────────────────────

  static Future<void> _writeNotification({
    required String userId,
    required String type,
    required String groupId,
    required String groupName,
    String? message,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('groupNotifications')
          .add({
            'type': type,
            'groupId': groupId,
            'groupName': groupName,
            'message': message ?? '',
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      // Non-critical — don't throw
      if (kDebugMode) print('_writeNotification error: $e');
    }
  }

  /// Stream of unread group notifications for a user.
  static Stream<QuerySnapshot> getGroupNotifications(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('groupNotifications')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  static Future<void> markNotificationRead({
    required String userId,
    required String notificationId,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('groupNotifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      if (kDebugMode) print('markNotificationRead error: $e');
    }
  }

  // ─────────────────────────────────────────────
  //  EXISTING MEMBERSHIP METHODS (updated)
  // ─────────────────────────────────────────────

  static Future<bool> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final groupRef = _groups.doc(groupId);
      final memberDoc = await groupRef.collection('members').doc(userId).get();
      if (!memberDoc.exists) return false;

      final memberData = memberDoc.data() as Map<String, dynamic>;
      if (memberData['role'] == 'admin') {
        showCustomSnackBar(
          'Admin cannot leave the group. Transfer ownership first.',
        );
        return false;
      }

      final batch = _db.batch();
      batch.delete(memberDoc.reference);
      batch.update(groupRef, {
        'memberCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final profileDoc = await _profiles.doc(userId).get();
      if (profileDoc.exists) {
        batch.update(_profiles.doc(userId), {
          'groups': FieldValue.arrayRemove([groupId]),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('leaveGroup error: $e');
      return false;
    }
  }

  static Future<bool> transferOwnership({
    required String groupId,
    required String currentAdminId,
    required String newAdminId,
  }) async {
    try {
      final currentAdminDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(currentAdminId)
          .get();
      if (!currentAdminDoc.exists) return false;
      final currentData = currentAdminDoc.data() as Map<String, dynamic>;
      if (currentData['role'] != 'admin') return false;

      final newAdminDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(newAdminId)
          .get();
      if (!newAdminDoc.exists) return false;
      final newData = newAdminDoc.data() as Map<String, dynamic>;
      if (newData['isBanned'] == true || newData['userType'] != 'athlete') {
        return false;
      }

      final batch = _db.batch();
      batch.update(currentAdminDoc.reference, {'role': 'member'});
      batch.update(newAdminDoc.reference, {'role': 'admin'});
      batch.update(_groups.doc(groupId), {
        'creatorId': newAdminId,
        'creatorName': '${newData['firstName']} ${newData['lastName']}'.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('transferOwnership error: $e');
      return false;
    }
  }

  static Future<bool> toggleModeratorRole({
    required String groupId,
    required String adminId,
    required String memberId,
    required bool promote,
  }) async {
    try {
      final adminDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(adminId)
          .get();
      if (!adminDoc.exists) return false;
      final adminData = adminDoc.data() as Map<String, dynamic>;
      if (adminData['role'] != 'admin') return false;

      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(memberId)
          .get();
      if (!memberDoc.exists) return false;
      final memberData = memberDoc.data() as Map<String, dynamic>;
      if (memberData['isBanned'] == true) return false;
      if (memberData['role'] == 'admin') return false;

      await memberDoc.reference.update({
        'role': promote ? 'moderator' : 'member',
      });
      return true;
    } catch (e) {
      if (kDebugMode) print('toggleModeratorRole error: $e');
      return false;
    }
  }

  static Future<bool> removeMember({
    required String groupId,
    required String adminId,
    required String memberId,
    bool ban = false,
  }) async {
    try {
      final adminDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(adminId)
          .get();
      if (!adminDoc.exists) return false;
      final adminData = adminDoc.data() as Map<String, dynamic>;
      if (!['admin', 'moderator'].contains(adminData['role'])) return false;

      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(memberId)
          .get();
      if (!memberDoc.exists) return false;

      final batch = _db.batch();

      if (ban) {
        batch.update(memberDoc.reference, {'isBanned': true, 'role': 'banned'});
      } else {
        batch.delete(memberDoc.reference);
      }

      batch.update(_groups.doc(groupId), {
        'memberCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final profileDoc = await _profiles.doc(memberId).get();
      if (profileDoc.exists) {
        batch.update(_profiles.doc(memberId), {
          'groups': FieldValue.arrayRemove([groupId]),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('removeMember error: $e');
      return false;
    }
  }

  static Future<bool> unbanMember({
    required String groupId,
    required String adminId,
    required String memberId,
  }) async {
    try {
      final adminDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(adminId)
          .get();
      if (!adminDoc.exists) return false;
      final adminData = adminDoc.data() as Map<String, dynamic>;
      if (adminData['role'] != 'admin') return false;

      await _groups.doc(groupId).collection('members').doc(memberId).delete();
      return true;
    } catch (e) {
      if (kDebugMode) print('unbanMember error: $e');
      return false;
    }
  }

  static Future<bool> isMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      final doc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .get();
      if (!doc.exists) return false;
      final d = doc.data() as Map<String, dynamic>;
      return d['isBanned'] != true;
    } catch (e) {
      return false;
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getMemberStream({
    required String groupId,
    required String userId,
  }) {
    return _groups.doc(groupId).collection('members').doc(userId).snapshots();
  }

  // ─────────────────────────────────────────────
  //  STREAMS
  // ─────────────────────────────────────────────

  /// Only returns AfriEndorse-approved active public groups
  static Stream<QuerySnapshot> getPublicGroups() {
    return _groups
        .where('isPublic', isEqualTo: true)
        .where('status', isEqualTo: 'active')
        .orderBy('memberCount', descending: true)
        .snapshots();
  }

  /// Returns all groups created by this athlete (any status)
  /// so they can see pending/rejected alongside active ones.
  static Stream<QuerySnapshot> getCreatorGroups(String creatorEmail) {
    return _groups
        .where('creatorId', isEqualTo: creatorEmail)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getGroupPosts(String groupId) {
    return _groups
        .doc(groupId)
        .collection('posts')
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getGroupMembers(String groupId) {
    return _groups
        .doc(groupId)
        .collection('members')
        .orderBy('joinedAt')
        .snapshots();
  }

  static Stream<QuerySnapshot> getBannedMembers(String groupId) {
    return _groups
        .doc(groupId)
        .collection('members')
        .where('isBanned', isEqualTo: true)
        .snapshots();
  }

  static Future<DocumentSnapshot?> getGroupByInviteCode(String code) async {
    final q = await _groups
        .where('inviteCode', isEqualTo: code)
        .where('status', isEqualTo: 'active') // only active groups
        .limit(1)
        .get();
    return q.docs.isNotEmpty ? q.docs.first : null;
  }

  // ─────────────────────────────────────────────
  //  POSTS (unchanged)
  // ─────────────────────────────────────────────

  static Future<String?> createPost({
    required String groupId,
    required String authorId,
    required String authorName,
    required String authorType,
    required String content,
    String? imageUrl,
    String? videoUrl,
    PostType postType = PostType.text,
    String? authorAvatar,
  }) async {
    try {
      final ref = await _groups.doc(groupId).collection('posts').add({
        'groupId': groupId,
        'authorId': authorId,
        'authorName': authorName,
        'authorType': authorType,
        'authorAvatar': authorAvatar ?? '',
        'content': content,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'postType': postType.name,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        'commentsCount': 0,
        'isPinned': false,
      });
      return ref.id;
    } catch (e) {
      if (kDebugMode) print('createPost error: $e');
      return null;
    }
  }

  static Future<bool> deletePost({
    required String groupId,
    required String postId,
    required String requesterId,
  }) async {
    try {
      final postDoc = await _groups
          .doc(groupId)
          .collection('posts')
          .doc(postId)
          .get();
      if (!postDoc.exists) return false;
      final postData = postDoc.data() as Map<String, dynamic>;

      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(requesterId)
          .get();
      final memberData = memberDoc.exists
          ? memberDoc.data() as Map<String, dynamic>
          : null;
      final isModOrAdmin = ['admin', 'moderator'].contains(memberData?['role']);
      final isAuthor = postData['authorId'] == requesterId;

      if (!isAuthor && !isModOrAdmin) return false;

      final batch = _db.batch();
      batch.delete(postDoc.reference);

      final groupDoc = await _groups.doc(groupId).get();
      final groupData = groupDoc.data() as Map<String, dynamic>;
      if (groupData['pinnedPostId'] == postId) {
        batch.update(_groups.doc(groupId), {'pinnedPostId': null});
      }

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('deletePost error: $e');
      return false;
    }
  }

  static Future<bool> pinPost({
    required String groupId,
    required String postId,
    required String adminId,
  }) async {
    try {
      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(adminId)
          .get();
      if (!memberDoc.exists) return false;
      final d = memberDoc.data() as Map<String, dynamic>;
      if (!['admin', 'moderator'].contains(d['role'])) return false;

      final batch = _db.batch();
      final groupDoc = await _groups.doc(groupId).get();
      final groupData = groupDoc.data() as Map<String, dynamic>;
      if (groupData['pinnedPostId'] != null &&
          groupData['pinnedPostId'] != postId) {
        batch.update(
          _groups
              .doc(groupId)
              .collection('posts')
              .doc(groupData['pinnedPostId']),
          {'isPinned': false},
        );
      }

      batch.update(_groups.doc(groupId), {'pinnedPostId': postId});
      batch.update(_groups.doc(groupId).collection('posts').doc(postId), {
        'isPinned': true,
      });
      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('pinPost error: $e');
      return false;
    }
  }

  static Future<bool> unpinPost({
    required String groupId,
    required String postId,
    required String adminId,
  }) async {
    try {
      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(adminId)
          .get();
      if (!memberDoc.exists) return false;
      final d = memberDoc.data() as Map<String, dynamic>;
      if (!['admin', 'moderator'].contains(d['role'])) return false;

      final batch = _db.batch();
      batch.update(_groups.doc(groupId), {'pinnedPostId': null});
      batch.update(_groups.doc(groupId).collection('posts').doc(postId), {
        'isPinned': false,
      });
      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('unpinPost error: $e');
      return false;
    }
  }

  static Future<bool> toggleLikePost({
    required String groupId,
    required String postId,
    required String userId,
  }) async {
    try {
      final postRef = _groups.doc(groupId).collection('posts').doc(postId);
      final postDoc = await postRef.get();
      if (!postDoc.exists) return false;
      final d = postDoc.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(d['likedBy'] ?? []);

      if (likedBy.contains(userId)) {
        await postRef.update({
          'likedBy': FieldValue.arrayRemove([userId]),
          'likes': FieldValue.increment(-1),
        });
      } else {
        await postRef.update({
          'likedBy': FieldValue.arrayUnion([userId]),
          'likes': FieldValue.increment(1),
        });
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('toggleLikePost error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  COMMENTS (unchanged)
  // ─────────────────────────────────────────────

  static Future<bool> addComment({
    required String groupId,
    required String postId,
    required String authorId,
    required String authorName,
    required String authorType,
    required String content,
    String? authorAvatar,
  }) async {
    try {
      final postRef = _groups.doc(groupId).collection('posts').doc(postId);
      final batch = _db.batch();

      final commentRef = postRef.collection('comments').doc();
      batch.set(commentRef, {
        'postId': postId,
        'authorId': authorId,
        'authorName': authorName,
        'authorType': authorType,
        'authorAvatar': authorAvatar ?? '',
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
      });

      batch.update(postRef, {'commentsCount': FieldValue.increment(1)});
      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('addComment error: $e');
      return false;
    }
  }

  static Future<bool> deleteComment({
    required String groupId,
    required String postId,
    required String commentId,
    required String requesterId,
  }) async {
    try {
      final commentRef = _groups
          .doc(groupId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);
      final commentDoc = await commentRef.get();
      if (!commentDoc.exists) return false;
      final d = commentDoc.data() as Map<String, dynamic>;

      final memberDoc = await _groups
          .doc(groupId)
          .collection('members')
          .doc(requesterId)
          .get();
      final memberData = memberDoc.exists
          ? memberDoc.data() as Map<String, dynamic>
          : null;
      final isModOrAdmin = ['admin', 'moderator'].contains(memberData?['role']);
      final isAuthor = d['authorId'] == requesterId;

      if (!isAuthor && !isModOrAdmin) return false;

      final postRef = _groups.doc(groupId).collection('posts').doc(postId);
      final batch = _db.batch();
      batch.delete(commentRef);
      batch.update(postRef, {'commentsCount': FieldValue.increment(-1)});
      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('deleteComment error: $e');
      return false;
    }
  }

  static Future<bool> toggleLikeComment({
    required String groupId,
    required String postId,
    required String commentId,
    required String userId,
  }) async {
    try {
      final commentRef = _groups
          .doc(groupId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);
      final doc = await commentRef.get();
      if (!doc.exists) return false;
      final d = doc.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(d['likedBy'] ?? []);

      if (likedBy.contains(userId)) {
        await commentRef.update({
          'likedBy': FieldValue.arrayRemove([userId]),
          'likes': FieldValue.increment(-1),
        });
      } else {
        await commentRef.update({
          'likedBy': FieldValue.arrayUnion([userId]),
          'likes': FieldValue.increment(1),
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Stream<QuerySnapshot> getComments({
    required String groupId,
    required String postId,
  }) {
    return _groups
        .doc(groupId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // ─────────────────────────────────────────────
  //  DONATIONS (unchanged)
  // ─────────────────────────────────────────────

  static Future<String?> initiateDonation({
    required String groupId,
    required double amount,
    required String donorId,
    required String donorEmail,
    required String donorName,
    required String donorType,
    String? message,
    bool isAnonymous = false,
  }) async {
    try {
      final groupDoc = await _groups.doc(groupId).get();
      if (!groupDoc.exists) return null;
      final groupData = groupDoc.data() as Map<String, dynamic>;

      final allMembersSnap = await _groups
          .doc(groupId)
          .collection('members')
          .get();

      final eligibleMembers = allMembersSnap.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final isAthlete = (data['userType'] as String?) == 'athlete';
        final isBanned = (data['isBanned'] as bool?) == true;
        return isAthlete && !isBanned;
      }).toList();

      final athleteCount = eligibleMembers.isEmpty ? 1 : eligibleMembers.length;
      final splitAmount = amount / athleteCount;

      final donationRef = _donations.doc();
      await donationRef.set({
        'groupId': groupId,
        'groupName': groupData['name'],
        'donorId': isAnonymous ? null : donorId,
        'donorEmail': donorEmail,
        'donorName': isAnonymous ? 'Anonymous' : donorName,
        'donorType': isAnonymous ? null : donorType,
        'amount': amount,
        'message': message,
        'isAnonymous': isAnonymous,
        'status': 'pending',
        'splitAmount': splitAmount,
        'memberCount': athleteCount,
        'eligibleMemberIds': eligibleMembers.map((m) => m.id).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'paymentMethod': 'paystack',
        'transactionRef': null,
      });

      await _groups.doc(groupId).update({
        'pendingDonations': FieldValue.increment(amount),
      });

      return donationRef.id;
    } catch (e) {
      if (kDebugMode) print('initiateDonation error: $e');
      return null;
    }
  }

  static Future<void> incrementActiveCampaignCount(String groupId) async {
    await _groups.doc(groupId).update({
      'activeCampaignCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> decrementActiveCampaignCount(String groupId) async {
    await _groups.doc(groupId).update({
      'activeCampaignCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<bool> completeDonation({
    required String donationId,
    required String transactionRef,
  }) async {
    try {
      final donationRef = _donations.doc(donationId);
      final donationDoc = await donationRef.get();
      if (!donationDoc.exists) return false;

      final d = donationDoc.data() as Map<String, dynamic>;
      if (d['status'] == 'completed') return true;

      final groupId = d['groupId'] as String;
      final amount = (d['amount'] as num).toDouble();
      final groupRef = _groups.doc(groupId);
      final batch = _db.batch();

      final snapshotMemberIds =
          (d['eligibleMemberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [];

      List<String> memberIds;
      double splitAmount;

      if (snapshotMemberIds.isNotEmpty) {
        memberIds = snapshotMemberIds;
        splitAmount = amount / memberIds.length;
      } else {
        final allMembersSnap = await groupRef.collection('members').get();
        final eligible = allMembersSnap.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final isAthlete = (data['userType'] as String?) == 'athlete';
          final isBanned = (data['isBanned'] as bool?) == true;
          return isAthlete && !isBanned;
        }).toList();

        memberIds = eligible.map((m) => m.id).toList();
        splitAmount = memberIds.isEmpty ? amount : amount / memberIds.length;
      }

      batch.update(donationRef, {
        'status': 'completed',
        'transactionRef': transactionRef,
        'processedAt': FieldValue.serverTimestamp(),
        'finalSplitAmount': splitAmount,
        'finalMemberCount': memberIds.length,
      });

      batch.update(groupRef, {
        'totalDonations': FieldValue.increment(amount),
        'pendingDonations': FieldValue.increment(-amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      for (final memberId in memberIds) {
        final memberRef = groupRef.collection('members').doc(memberId);
        batch.update(memberRef, {
          'earnings': FieldValue.increment(splitAmount),
        });
        batch.set(_profiles.doc(memberId), {
          'totalGroupEarnings': FieldValue.increment(splitAmount),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('completeDonation error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getDonationDetails(
    String donationId,
  ) async {
    try {
      final doc = await _donations.doc(donationId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> cancelDonation({required String donationId}) async {
    try {
      final donationDoc = await _donations.doc(donationId).get();
      if (!donationDoc.exists) return;
      final d = donationDoc.data() as Map<String, dynamic>;
      final groupId = d['groupId'] as String?;
      final amount = (d['amount'] as num?)?.toDouble() ?? 0;

      final batch = _db.batch();
      batch.update(_donations.doc(donationId), {
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      if (groupId != null && amount > 0) {
        batch.update(_groups.doc(groupId), {
          'pendingDonations': FieldValue.increment(-amount),
        });
      }
      await batch.commit();
    } catch (e) {
      if (kDebugMode) print('cancelDonation error: $e');
    }
  }

  static Future<Map<String, double>> getAthleteGroupEarnings(
    String athleteId,
  ) async {
    try {
      final doc = await _profiles.doc(athleteId).get();
      if (!doc.exists) {
        return {
          'totalGroupEarnings': 0,
          'pendingWithdrawal': 0,
          'withdrawn': 0,
        };
      }
      final d = doc.data() as Map<String, dynamic>;
      return {
        'totalGroupEarnings':
            (d['totalGroupEarnings'] as num?)?.toDouble() ?? 0,
        'pendingWithdrawal': (d['pendingWithdrawal'] as num?)?.toDouble() ?? 0,
        'withdrawn': (d['withdrawn'] as num?)?.toDouble() ?? 0,
      };
    } catch (e) {
      if (kDebugMode) print('getAthleteGroupEarnings error: $e');
      return {'totalGroupEarnings': 0, 'pendingWithdrawal': 0, 'withdrawn': 0};
    }
  }

  static Stream<Map<String, double>> streamAthleteGroupEarnings(
    String athleteId,
  ) {
    return _profiles.doc(athleteId).snapshots().map((snap) {
      if (!snap.exists) {
        return {
          'totalGroupEarnings': 0.0,
          'pendingWithdrawal': 0.0,
          'withdrawn': 0.0,
        };
      }
      final d = snap.data() as Map<String, dynamic>;
      return {
        'totalGroupEarnings':
            (d['totalGroupEarnings'] as num?)?.toDouble() ?? 0,
        'pendingWithdrawal': (d['pendingWithdrawal'] as num?)?.toDouble() ?? 0,
        'withdrawn': (d['withdrawn'] as num?)?.toDouble() ?? 0,
      };
    });
  }

  static Stream<QuerySnapshot> getGroupDonations(String groupId) {
    return _donations
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  // ─────────────────────────────────────────────
  //  ANALYTICS (unchanged)
  // ─────────────────────────────────────────────

  static Future<GroupAnalytics> getGroupAnalytics({
    required String groupId,
    required String athleteId,
  }) async {
    try {
      final groupDoc = await _groups.doc(groupId).get();
      if (!groupDoc.exists) return _emptyAnalytics();
      final groupData = groupDoc.data() as Map<String, dynamic>;

      final totalMembers = (groupData['memberCount'] as num?)?.toInt() ?? 0;
      final totalDonations =
          (groupData['totalDonations'] as num?)?.toDouble() ?? 0;

      final membersSnap = await _groups
          .doc(groupId)
          .collection('members')
          .get();
      final athleteMemberDocs = membersSnap.docs.where((d) {
        final data = d.data() as Map<String, dynamic>;
        return data['userType'] == 'athlete' && data['isBanned'] != true;
      }).toList();
      final athleteMembers = athleteMemberDocs.length;

      final postsSnap = await _groups
          .doc(groupId)
          .collection('posts')
          .count()
          .get();

      final now = DateTime.now();
      final firstOfMonth = DateTime(now.year, now.month, 1);
      final monthlyDonationsSnap = await _donations
          .where('groupId', isEqualTo: groupId)
          .where('status', isEqualTo: 'completed')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstOfMonth),
          )
          .get();

      double monthlyRevenue = 0;
      final donorIds = <String>{};
      for (final d in monthlyDonationsSnap.docs) {
        final data = d.data() as Map<String, dynamic>;
        monthlyRevenue += (data['amount'] as num?)?.toDouble() ?? 0;
        if (data['donorId'] != null) donorIds.add(data['donorId'] as String);
      }

      double myEarnings = 0;
      if (athleteId.isNotEmpty) {
        final myDoc = await _groups
            .doc(groupId)
            .collection('members')
            .doc(athleteId)
            .get();
        if (myDoc.exists) {
          final myData = myDoc.data() as Map<String, dynamic>;
          myEarnings = (myData['earnings'] as num?)?.toDouble() ?? 0;
        }
      }

      final recentSnap = await _donations
          .where('groupId', isEqualTo: groupId)
          .where('status', isEqualTo: 'completed')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      final recentDonations = recentSnap.docs
          .map((d) => DonationModel.fromDoc(d))
          .toList();

      return GroupAnalytics(
        totalMembers: totalMembers,
        athleteMembers: athleteMembers,
        totalDonations: totalDonations,
        monthlyRevenue: monthlyRevenue,
        myEarnings: myEarnings,
        totalPosts: postsSnap.count ?? 0,
        totalDonors: donorIds.length,
        recentDonations: recentDonations,
      );
    } catch (e, st) {
      if (kDebugMode) {
        print('getGroupAnalytics error: $e');
        print(st);
      }
      return _emptyAnalytics();
    }
  }

  static GroupAnalytics _emptyAnalytics() => GroupAnalytics(
    totalMembers: 0,
    athleteMembers: 0,
    totalDonations: 0,
    monthlyRevenue: 0,
    myEarnings: 0,
    totalPosts: 0,
    totalDonors: 0,
    recentDonations: [],
  );

  // ─────────────────────────────────────────────
  //  UTILS
  // ─────────────────────────────────────────────

  static String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
