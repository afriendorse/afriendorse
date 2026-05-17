// lib/athlete/feature/groups/controller/group_controller.dart

/*
import 'dart:io';
import 'package:afriendorse/athlete/feature/auth/binding/sports_service.dart';
import 'package:afriendorse/athlete/feature/groups/models/group_models.dart';
import 'package:afriendorse/athlete/feature/groups/repository/group_firestore_service.dart';
import 'package:afriendorse/athlete/feature/groups/controller/group_payment_controller.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/shared/currency_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:afriendorse/athlete/feature/profile/controller/user_controller.dart'
    as athlete_controller;
import 'package:afriendorse/feature/profile/controller/user_controller.dart'
    as brandfan_controller;
import 'package:intl/intl.dart';

class GroupController extends GetxController {
  // ─── Lists ───────────────────────────────────
  final RxList<GroupModel> myGroups = <GroupModel>[].obs;
  final RxList<GroupModel> publicGroups = <GroupModel>[].obs;
  final RxList<PostModel> groupPosts = <PostModel>[].obs;
  final RxList<MemberModel> groupMembers = <MemberModel>[].obs;
  final RxList<MemberModel> bannedMembers = <MemberModel>[].obs;
  final RxList<CommentModel> currentComments = <CommentModel>[].obs;
  final RxList<SportModel> availableSports = <SportModel>[].obs;

  // ─── Current state ───────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isUploadingMedia = false.obs;
  final Rx<UserRole> currentUserRole = UserRole.unknown.obs;
  final RxString currentGroupId = ''.obs;
  final Rx<GroupModel?> currentGroup = Rx<GroupModel?>(null);
  final Rx<MemberModel?> currentMembership = Rx<MemberModel?>(null);
  final Rx<GroupAnalytics?> groupAnalytics = Rx<GroupAnalytics?>(null);
  final Rx<SportModel?> selectedSport = Rx<SportModel?>(null);

  // ─── Permissions ─────────────────────────────
  final RxBool canUserPost = false.obs;
  final RxBool canUserJoin = false.obs;
  final RxBool isCurrentUserAdmin = false.obs;
  final RxBool isCurrentUserMember = false.obs;

  // ─── Selected media ──────────────────────────
  final Rx<File?> selectedImage = Rx<File?>(null);
  final Rx<File?> selectedVideo = Rx<File?>(null);
  final RxString selectedPostType = 'text'.obs;
  // Add this to the observables section at the top of GroupController
  final RxDouble uploadProgress = 0.0.obs;

  // ─── Form controllers ─────────────────────────
  final groupNameController = TextEditingController();
  final groupDescriptionController = TextEditingController();
  final postContentController = TextEditingController();
  final commentController = TextEditingController();
  final donationAmountController = TextEditingController();
  final donationMessageController = TextEditingController();
  final inviteCodeController = TextEditingController();
  final editGroupNameController = TextEditingController();
  final editGroupDescController = TextEditingController();

  late final GroupPaymentController _paymentController;
  final ImagePicker _picker = ImagePicker();

  // ─── App-mode detection ──────────────────────

  bool get _isAthleteMode {
    try {
      Get.find<athlete_controller.UserProfileController>();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool get _isBrandFanMode {
    try {
      Get.find<brandfan_controller.UserController>();
      return true;
    } catch (e) {
      return false;
    }
  }

  String get currentUserId {
    if (_isAthleteMode) {
      final email = Get.find<athlete_controller.UserProfileController>()
          .providerModel
          ?.content
          ?.providerInfo
          ?.owner
          ?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    if (_isBrandFanMode) {
      try {
        return Get.find<brandfan_controller.UserController>()
                .userInfoModel
                ?.id ??
            '';
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  String get currentUserEmail {
    if (_isAthleteMode) {
      try {
        return Get.find<athlete_controller.UserProfileController>()
                .providerModel
                ?.content
                ?.providerInfo
                ?.owner
                ?.email ??
            '';
      } catch (e) {
        return '';
      }
    }
    if (_isBrandFanMode) {
      try {
        return Get.find<brandfan_controller.UserController>()
                .userInfoModel
                ?.email ??
            '';
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  String get currentUserName {
    if (_isAthleteMode) {
      try {
        final p = Get.find<athlete_controller.UserProfileController>()
            .providerModel
            ?.content
            ?.providerInfo;
        return '${p?.contactPersonName ?? ''}'.trim();
      } catch (e) {
        return 'Athlete';
      }
    }
    if (_isBrandFanMode) {
      try {
        final u = Get.find<brandfan_controller.UserController>().userInfoModel;
        return '${u?.fName ?? ''} ${u?.lName ?? ''}'.trim();
      } catch (e) {
        return 'User';
      }
    }
    return 'User';
  }

  // ─── Lifecycle ───────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _paymentController = Get.put(GroupPaymentController());
    _initUserRole();
    _loadSports();
  }

  Future<void> _loadSports() async {
    final sports = await SportsService.getSports();
    availableSports.value = sports;
    if (sports.isNotEmpty) selectedSport.value = sports.first;
  }

  Future<void> refresh() => _initUserRole();

  Future<void> _initUserRole() async {
    isLoading.value = true;

    UserRole role = _detectRoleFromControllers();
    if (role == UserRole.unknown && currentUserId.isNotEmpty) {
      role = await GroupFirestoreService.getUserRole(currentUserId);
    }
    if (role == UserRole.unknown && _isBrandFanMode) {
      role = UserRole.fan;
    }

    currentUserRole.value = role;
    canUserPost.value = role == UserRole.athlete;
    canUserJoin.value = role == UserRole.athlete;

    if (role == UserRole.athlete) {
      _listenToAthleteGroups();
      _listenToPublicGroups(); // ← ADD THIS: let athletes see public groups too
    } else if (role == UserRole.brand || role == UserRole.fan) {
      _listenToPublicGroups();
    }
    isLoading.value = false;
  }

  /// Detect role from already-loaded controller data without Firestore
  UserRole _detectRoleFromControllers() {
    if (_isAthleteMode) {
      final hasProfile =
          Get.find<athlete_controller.UserProfileController>()
              .providerModel
              ?.content
              ?.providerInfo !=
          null;
      if (hasProfile) return UserRole.athlete;
    }
    if (_isBrandFanMode) {
      try {
        final user =
            Get.find<brandfan_controller.UserController>().userInfoModel;
        if (user == null) return UserRole.unknown;
        // Check for userType field if available, otherwise default to fan
        final type = (user as dynamic).userType as String?;
        if (type == 'brand') return UserRole.brand;
        return UserRole.fan; // brand/fan controller present → at least fan
      } catch (_) {
        return UserRole.fan; // controller present but no userType field
      }
    }
    return UserRole.unknown;
  }

  void _listenToAthleteGroups() {
    final email = currentUserEmail;
    if (email.isEmpty) return;

    FirebaseFirestore.instance
        .collection('athlete_profiles')
        .doc(email)
        .snapshots()
        .listen((profileSnap) async {
          if (!profileSnap.exists) {
            myGroups.clear();
            return;
          }
          final data = profileSnap.data() as Map<String, dynamic>?;
          final groupIds = List<String>.from(data?['groups'] ?? []);
          if (groupIds.isEmpty) {
            myGroups.clear();
            return;
          }

          final snaps = await Future.wait(
            groupIds.map(
              (id) =>
                  FirebaseFirestore.instance.collection('groups').doc(id).get(),
            ),
          );

          myGroups.value = snaps
              .where((s) => s.exists)
              .map((s) => GroupModel.fromDoc(s))
              .toList();
        });
  }

  void _listenToPublicGroups() {
    GroupFirestoreService.getPublicGroups().listen((snap) {
      publicGroups.value = snap.docs.map((d) => GroupModel.fromDoc(d)).toList();
    });
  }

  // ─── Group Details ───────────────────────────

  void loadGroupDetails(String groupId) {
    currentGroupId.value = groupId;

    // Listen to group doc
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .listen((snap) {
          if (snap.exists) currentGroup.value = GroupModel.fromDoc(snap);
        });

    // Listen to posts
    GroupFirestoreService.getGroupPosts(groupId).listen((snap) {
      groupPosts.value = snap.docs.map((d) => PostModel.fromDoc(d)).toList();
    });

    // Listen to members
    GroupFirestoreService.getGroupMembers(groupId).listen((snap) {
      groupMembers.value = snap.docs
          .map((d) => MemberModel.fromDoc(d))
          .toList();
    });

    // Check current user's membership
    GroupFirestoreService.getMemberStream(
      groupId: groupId,
      userId: currentUserId,
    ).listen((snap) {
      if (snap.exists && snap.data() != null) {
        final m = MemberModel.fromDoc(snap);
        currentMembership.value = m;
        isCurrentUserMember.value = !m.isBanned;
        isCurrentUserAdmin.value = m.isAdmin || m.isModerator;
      } else {
        currentMembership.value = null;
        isCurrentUserMember.value = false;
        isCurrentUserAdmin.value = false;
      }
    });
  }

  Future<void> loadAnalytics(String groupId) async {
    final analytics = await GroupFirestoreService.getGroupAnalytics(
      groupId: groupId,
      athleteId: currentUserId,
    );
    groupAnalytics.value = analytics;
  }

  // ─── Create / Edit Group ─────────────────────

  Future<void> createGroup({bool isPublic = true}) async {
    if (!canUserPost.value) {
      showCustomSnackBar('Only athletes can create groups');
      return;
    }
    if (groupNameController.text.trim().isEmpty) {
      showCustomSnackBar('Please enter a group name');
      return;
    }

    // Close dialog immediately so user sees progress via snackbar
    Get.back();
    isLoading.value = true;

    String? coverImageUrl;
    if (selectedImage.value != null) {
      coverImageUrl = await _uploadFile(selectedImage.value!, 'group_covers');
    }

    final sport = selectedSport.value?.name ?? 'General';

    final groupId = await GroupFirestoreService.createGroup(
      creatorEmail: currentUserEmail,
      creatorName: currentUserName,
      name: groupNameController.text.trim(),
      description: groupDescriptionController.text.trim(),
      sport: sport,
      coverImage: coverImageUrl,
      isPublic: isPublic,
    );

    isLoading.value = false;
    selectedImage.value = null;
    groupNameController.clear();
    groupDescriptionController.clear();
    selectedSport.value = availableSports.isNotEmpty
        ? availableSports.first
        : null;

    if (groupId != null) {
      showCustomSnackBar(
        'Group created successfully!',
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar('Failed to create group');
    }
  }

  Future<void> updateGroup({required String groupId, bool? isPublic}) async {
    isLoading.value = true;

    String? coverImageUrl;
    if (selectedImage.value != null) {
      coverImageUrl = await _uploadFile(selectedImage.value!, 'group_covers');
    }

    final success = await GroupFirestoreService.updateGroup(
      groupId: groupId,
      requesterId: currentUserId,
      name: editGroupNameController.text.trim().isNotEmpty
          ? editGroupNameController.text.trim()
          : null,
      description: editGroupDescController.text.trim().isNotEmpty
          ? editGroupDescController.text.trim()
          : null,
      coverImage: coverImageUrl,
      isPublic: isPublic,
    );

    isLoading.value = false;
    selectedImage.value = null;
    editGroupNameController.clear();
    editGroupDescController.clear();

    if (success) {
      showCustomSnackBar('Group updated!', type: ToasterMessageType.success);
      Get.back();
    } else {
      showCustomSnackBar('Update failed');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Group'),
        content: Text(
          'This will permanently delete the group and all its content. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    isLoading.value = true;
    final success = await GroupFirestoreService.deleteGroup(
      groupId: groupId,
      requesterId: currentUserId,
    );
    isLoading.value = false;
    if (success) {
      showCustomSnackBar('Group deleted', type: ToasterMessageType.success);
      Get.back();
    } else {
      showCustomSnackBar('Failed to delete group');
    }
  }

  // ─── Membership ──────────────────────────────

  Future<void> joinGroupByCode() async {
    final code = inviteCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      showCustomSnackBar('Please enter invite code');
      return;
    }

    isLoading.value = true;
    final groupDoc = await GroupFirestoreService.getGroupByInviteCode(code);
    if (groupDoc == null) {
      showCustomSnackBar('Invalid invite code');
      isLoading.value = false;
      return;
    }

    final parts = currentUserName.split(' ');
    final success = await GroupFirestoreService.joinGroup(
      groupId: groupDoc.id,
      userId: currentUserId,
      firstName: parts.first,
      lastName: parts.length > 1 ? parts.last : '',
      userType: currentUserRole.value.name,
    );

    isLoading.value = false;
    if (success) {
      inviteCodeController.clear();
      Get.back(); // close dialog after success
      showCustomSnackBar(
        'Joined group successfully!',
        type: ToasterMessageType.success,
      );
    }
  }

  Future<void> joinPublicGroup(String groupId) async {
    isLoading.value = true;
    final parts = currentUserName.split(' ');
    final success = await GroupFirestoreService.joinGroup(
      groupId: groupId,
      userId: currentUserId,
      firstName: parts.first,
      lastName: parts.length > 1 ? parts.last : '',
      userType: currentUserRole.value.name,
    );
    isLoading.value = false;
    if (success) {
      showCustomSnackBar('Joined!', type: ToasterMessageType.success);
    }
  }

  Future<void> leaveGroup(String groupId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Leave Group'),
        content: Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('Leave'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    isLoading.value = true;
    final success = await GroupFirestoreService.leaveGroup(
      groupId: groupId,
      userId: currentUserId,
    );
    isLoading.value = false;
    if (success) {
      showCustomSnackBar('Left group', type: ToasterMessageType.success);
      Get.back();
    }
  }

  // ─── Admin: Member Management ─────────────────

  Future<void> removeMember(String groupId, MemberModel member) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Remove Member'),
        content: Text('Remove ${member.fullName} from the group?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final success = await GroupFirestoreService.removeMember(
      groupId: groupId,
      adminId: currentUserId,
      memberId: member.id,
      ban: false,
    );
    if (success)
      showCustomSnackBar('Member removed', type: ToasterMessageType.success);
  }

  Future<void> banMember(String groupId, MemberModel member) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Ban Member'),
        content: Text(
          'Ban ${member.fullName}? They will not be able to rejoin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Ban', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final success = await GroupFirestoreService.removeMember(
      groupId: groupId,
      adminId: currentUserId,
      memberId: member.id,
      ban: true,
    );
    if (success)
      showCustomSnackBar('Member banned', type: ToasterMessageType.success);
  }

  // ─── Posts ───────────────────────────────────

  Future<void> createPost() async {
    if (!canUserPost.value && !isCurrentUserMember.value) {
      showCustomSnackBar('Only group members can post');
      return;
    }
    if (postContentController.text.trim().isEmpty &&
        selectedImage.value == null &&
        selectedVideo.value == null) {
      showCustomSnackBar('Please add some content');
      return;
    }

    // ── CHANGED: don't close dialog yet — user needs to see upload progress
    isLoading.value = true;
    isUploadingMedia.value =
        selectedImage.value != null || selectedVideo.value != null;

    String? imageUrl;
    String? videoUrl;
    PostType postType = PostType.text;

    if (selectedImage.value != null) {
      imageUrl = await _uploadFile(selectedImage.value!, 'group_posts/images');
      postType = PostType.image;
    }
    if (selectedVideo.value != null) {
      videoUrl = await _uploadFile(selectedVideo.value!, 'group_posts/videos');
      postType = PostType.video;
    }

    isUploadingMedia.value = false;

    // ── CHANGED: only close dialog AFTER upload completes
    Get.back();

    final postId = await GroupFirestoreService.createPost(
      groupId: currentGroupId.value,
      authorId: currentUserId,
      authorName: currentUserName,
      authorType: currentUserRole.value.name,
      content: postContentController.text.trim(),
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      postType: postType,
    );

    isLoading.value = false;
    postContentController.clear();
    selectedImage.value = null;
    selectedVideo.value = null;

    if (postId != null) {
      showCustomSnackBar('Posted!', type: ToasterMessageType.success);
    } else {
      showCustomSnackBar('Failed to post');
    }
  }

  Future<void> deletePost(String postId) async {
    final success = await GroupFirestoreService.deletePost(
      groupId: currentGroupId.value,
      postId: postId,
      requesterId: currentUserId,
    );
    if (success)
      showCustomSnackBar('Post deleted', type: ToasterMessageType.success);
    else
      showCustomSnackBar('Failed to delete post');
  }

  Future<void> togglePinPost(PostModel post) async {
    if (!isCurrentUserAdmin.value) return;

    // Optimistic local update
    final idx = groupPosts.indexWhere((p) => p.id == post.id);
    if (idx != -1) {
      // Unpin any currently pinned post locally
      for (int i = 0; i < groupPosts.length; i++) {
        if (groupPosts[i].isPinned && groupPosts[i].id != post.id) {
          groupPosts[i] = _copyPostWith(groupPosts[i], isPinned: false);
        }
      }
      groupPosts[idx] = _copyPostWith(post, isPinned: !post.isPinned);
      groupPosts.refresh();
    }

    if (post.isPinned) {
      await GroupFirestoreService.unpinPost(
        groupId: currentGroupId.value,
        postId: post.id,
        adminId: currentUserId,
      );
      showCustomSnackBar('Post unpinned');
    } else {
      await GroupFirestoreService.pinPost(
        groupId: currentGroupId.value,
        postId: post.id,
        adminId: currentUserId,
      );
      showCustomSnackBar('Post pinned!', type: ToasterMessageType.success);
    }
  }

  Future<void> toggleLikePost(PostModel post) async {
    final userId = currentUserId;
    final idx = groupPosts.indexWhere((p) => p.id == post.id);
    if (idx == -1) return;

    final alreadyLiked = post.likedBy.contains(userId);

    // Optimistic local update
    final updatedLikedBy = List<String>.from(post.likedBy);
    if (alreadyLiked) {
      updatedLikedBy.remove(userId);
    } else {
      updatedLikedBy.add(userId);
    }
    groupPosts[idx] = _copyPostWith(
      post,
      likes: alreadyLiked ? post.likes - 1 : post.likes + 1,
      likedBy: updatedLikedBy,
    );
    groupPosts.refresh();

    // Persist to Firestore
    await GroupFirestoreService.toggleLikePost(
      groupId: currentGroupId.value,
      postId: post.id,
      userId: userId,
    );
  }

  // Helper: immutable post copy with selective field overrides
  PostModel _copyPostWith(
    PostModel p, {
    bool? isPinned,
    int? likes,
    List<String>? likedBy,
  }) {
    return PostModel(
      id: p.id,
      groupId: p.groupId,
      authorId: p.authorId,
      authorName: p.authorName,
      authorType: p.authorType,
      authorAvatar: p.authorAvatar,
      content: p.content,
      imageUrl: p.imageUrl,
      videoUrl: p.videoUrl,
      postType: p.postType,
      likes: likes ?? p.likes,
      commentsCount: p.commentsCount,
      isPinned: isPinned ?? p.isPinned,
      likedBy: likedBy ?? p.likedBy,
      createdAt: p.createdAt,
    );
  }

  // ─── Comments ────────────────────────────────

  void loadComments(String postId) {
    GroupFirestoreService.getComments(
      groupId: currentGroupId.value,
      postId: postId,
    ).listen((snap) {
      currentComments.value = snap.docs
          .map((d) => CommentModel.fromDoc(d))
          .toList();
    });
  }

  Future<void> addComment(String postId) async {
    if (commentController.text.trim().isEmpty) return;
    final content = commentController.text.trim();
    commentController.clear(); // Clear immediately for better UX

    // Optimistic local comment count update
    final idx = groupPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      groupPosts[idx] = _copyPostWith(
        groupPosts[idx],
        likes: groupPosts[idx].likes, // unchanged
      );
      // Update comment count locally
      final post = groupPosts[idx];
      groupPosts[idx] = PostModel(
        id: post.id,
        groupId: post.groupId,
        authorId: post.authorId,
        authorName: post.authorName,
        authorType: post.authorType,
        authorAvatar: post.authorAvatar,
        content: post.content,
        imageUrl: post.imageUrl,
        videoUrl: post.videoUrl,
        postType: post.postType,
        likes: post.likes,
        commentsCount: post.commentsCount + 1,
        isPinned: post.isPinned,
        likedBy: post.likedBy,
        createdAt: post.createdAt,
      );
      groupPosts.refresh();
    }

    await GroupFirestoreService.addComment(
      groupId: currentGroupId.value,
      postId: postId,
      authorId: currentUserId,
      authorName: currentUserName,
      authorType: currentUserRole.value.name,
      content: content,
    );
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await GroupFirestoreService.deleteComment(
      groupId: currentGroupId.value,
      postId: postId,
      commentId: commentId,
      requesterId: currentUserId,
    );
  }

  Future<void> toggleLikeComment(String postId, String commentId) async {
    await GroupFirestoreService.toggleLikeComment(
      groupId: currentGroupId.value,
      postId: postId,
      commentId: commentId,
      userId: currentUserId,
    );
  }

  // ─── Media Picking ───────────────────────────

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      selectedImage.value = File(picked.path);
      selectedVideo.value = null;
      selectedPostType.value = 'image';
    }
  }

  Future<void> pickVideo() async {
    final picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 2), // limit duration
    );
    if (picked != null) {
      // Check file size before accepting — reject anything over 50MB
      final file = File(picked.path);
      final sizeInMB = await file.length() / (1024 * 1024);
      if (sizeInMB > 50) {
        showCustomSnackBar(
          'Video is too large. Please choose a video under 50MB.',
          type: ToasterMessageType.info,
        );
        return;
      }
      selectedVideo.value = file;
      selectedImage.value = null;
      selectedPostType.value = 'video';
    }
  }

  void clearSelectedMedia() {
    selectedImage.value = null;
    selectedVideo.value = null;
    selectedPostType.value = 'text';
  }

  Future<String?> _uploadFile(File file, String folder) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
        '$folder/${DateTime.now().millisecondsSinceEpoch}_$currentUserId',
      );

      uploadProgress.value = 0.0;
      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((event) {
        uploadProgress.value = event.bytesTransferred / event.totalBytes;
      });

      final snapshot = await uploadTask.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          uploadTask.cancel();
          throw Exception('Upload timed out');
        },
      );

      uploadProgress.value = 0.0;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      uploadProgress.value = 0.0;
      if (kDebugMode) print('Upload error: $e');
      showCustomSnackBar(
        e.toString().contains('timed out')
            ? 'Upload timed out. Try a smaller video.'
            : 'Upload failed. Please try again.',
      );
      return null;
    }
  }

  // ─── Donations ───────────────────────────────

  void showDonationDialog(String groupId) {
    Get.dialog(
      _DonationDialog(groupId: groupId, controller: this),
      barrierDismissible: false,
    );
  }

  Future<void> processDonation(String groupId) async {
    final amount = double.tryParse(donationAmountController.text) ?? 0;
    if (amount <= 0) {
      showCustomSnackBar('Please enter a valid amount');
      return;
    }

    Get.back();

    await _paymentController.donateToGroup(
      groupId: groupId,
      amount: amount,
      donorId: currentUserId,
      donorEmail: currentUserEmail,
      donorName: currentUserName,
      donorType: currentUserRole.value.name,
      message: donationMessageController.text.isEmpty
          ? null
          : donationMessageController.text,
    );

    donationAmountController.clear();
    donationMessageController.clear();
  }

  // ─── Sharing ─────────────────────────────────

  Future<void> shareGroup(
    String groupId,
    String inviteCode,
    String groupName,
  ) async {
    await _paymentController.shareGroup(groupId, inviteCode, groupName);
  }

  // ─── Advanced Membership Management ───────────

  /// Leave group (non-admin members only)
  Future<void> requestLeaveGroup(String groupId) async {
    // Guard: admin cannot leave without transferring ownership first
    if (isCurrentUserAdmin.value) {
      showCustomSnackBar(
        'You must transfer ownership before leaving the group',
        type: ToasterMessageType.info,
      );
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.exit_to_app, color: Colors.orange[700], size: 22),
            SizedBox(width: 10),
            Text('Leave Group'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to leave this group?',
              style: robotoMedium.copyWith(fontSize: 14),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can rejoin later if the group is public or with an invite code.',
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: Colors.orange[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Leave Group'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;
    final success = await GroupFirestoreService.leaveGroup(
      groupId: groupId,
      userId: currentUserId,
    );
    isLoading.value = false;

    if (success) {
      showCustomSnackBar('Left group', type: ToasterMessageType.success);
      Get.back(); // Return to groups list
    } else {
      showCustomSnackBar('Failed to leave group');
    }
  }

  /// Transfer ownership to another athlete (admin only)
  Future<void> initiateOwnershipTransfer(String groupId) async {
    if (!isCurrentUserAdmin.value) {
      showCustomSnackBar('Only the admin can transfer ownership');
      return;
    }

    // Get all athlete members (excluding current admin)
    final eligibleMembers = groupMembers
        .where(
          (m) =>
              m.userType == 'athlete' && !m.isBanned && m.id != currentUserId,
        )
        .toList();

    if (eligibleMembers.isEmpty) {
      showCustomSnackBar(
        'No eligible athletes to transfer ownership to',
        type: ToasterMessageType.info,
      );
      return;
    }

    // Show member picker dialog
    final selectedMember = await Get.dialog<MemberModel>(
      _TransferOwnershipDialog(members: eligibleMembers),
    );

    if (selectedMember == null) return;

    // Final confirmation
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.transfer_within_a_station, color: Colors.amber[700]),
            SizedBox(width: 10),
            Text('Confirm Transfer'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: robotoRegular.copyWith(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(text: 'Transfer ownership to '),
                  TextSpan(
                    text: selectedMember.fullName,
                    style: robotoBold.copyWith(color: Color(0xFF045F25)),
                  ),
                  TextSpan(text: '?'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: Colors.amber[900],
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will become a regular member and lose admin privileges. This cannot be undone.',
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: Colors.amber[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Transfer Ownership'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;
    final success = await GroupFirestoreService.transferOwnership(
      groupId: groupId,
      currentAdminId: currentUserId,
      newAdminId: selectedMember.id,
    );
    isLoading.value = false;

    if (success) {
      showCustomSnackBar(
        'Ownership transferred to ${selectedMember.fullName}',
        type: ToasterMessageType.success,
      );
      Get.back(); // Return to group details (now as regular member)
    } else {
      showCustomSnackBar('Failed to transfer ownership');
    }
  }

  /// Toggle moderator role (admin only)
  Future<void> toggleModerator(String groupId, MemberModel member) async {
    if (!isCurrentUserAdmin.value) {
      showCustomSnackBar('Only admins can assign moderators');
      return;
    }

    final isMod = member.isModerator;
    final action = isMod ? 'Remove moderator status' : 'Promote to moderator';

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isMod ? Icons.remove_moderator : Icons.shield_outlined,
              color: isMod ? Colors.orange[700] : Color(0xFF045F25),
              size: 22,
            ),
            SizedBox(width: 10),
            Text(action),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMod
                  ? '${member.fullName} will lose moderator privileges.'
                  : '${member.fullName} will be able to pin posts, remove content, and manage members.',
              style: robotoRegular.copyWith(fontSize: 13, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isMod ? Colors.orange[700] : Color(0xFF045F25),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(isMod ? 'Remove' : 'Promote'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await GroupFirestoreService.toggleModeratorRole(
      groupId: groupId,
      adminId: currentUserId,
      memberId: member.id,
      promote: !isMod,
    );

    if (success) {
      showCustomSnackBar(
        isMod
            ? '${member.fullName} is no longer a moderator'
            : '${member.fullName} is now a moderator',
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar('Failed to update role');
    }
  }

  // ─── Cleanup ─────────────────────────────────

  @override
  void onClose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    postContentController.dispose();
    commentController.dispose();
    donationAmountController.dispose();
    donationMessageController.dispose();
    inviteCodeController.dispose();
    editGroupNameController.dispose();
    editGroupDescController.dispose();
    super.onClose();
  }
}

// ─────────────────────────────────────────────
//  Donation Dialog Widget (internal)
// ─────────────────────────────────────────────
// ─────────────────────────────────────────────
//  Donation Dialog Widget (internal) - WITH NUMBER FORMATTING
// ─────────────────────────────────────────────
class _DonationDialog extends StatefulWidget {
  final String groupId;
  final GroupController controller;

  const _DonationDialog({required this.groupId, required this.controller});

  @override
  State<_DonationDialog> createState() => _DonationDialogState();
}

class _DonationDialogState extends State<_DonationDialog> {
  final TextEditingController _displayController = TextEditingController();
  final NumberFormat _numberFormat = NumberFormat('#,##0.##');
  bool _isTextFieldEmpty = true;

  @override
  void initState() {
    super.initState();
    // Sync with controller's text
    _displayController.text = widget.controller.donationAmountController.text;
    _isTextFieldEmpty = _displayController.text.isEmpty;
  }

  @override
  void dispose() {
    _displayController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    // Remove all non-numeric except decimal
    String rawValue = value.replaceAll(RegExp(r'[^\d.]'), '');

    // Handle multiple decimals
    final parts = rawValue.split('.');
    if (parts.length > 2) {
      rawValue = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // Update the actual controller (raw value for API)
    widget.controller.donationAmountController.text = rawValue;

    // Format display
    if (rawValue.isEmpty) {
      _displayController.text = '';
      setState(() => _isTextFieldEmpty = true);
    } else {
      final number = double.tryParse(rawValue) ?? 0;
      final formatted = _numberFormat.format(number);
      _displayController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      setState(() => _isTextFieldEmpty = false);
    }
  }

  double? _getRawAmount() {
    final raw = widget.controller.donationAmountController.text.trim();
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              FontAwesomeIcons.heart,
              color: Colors.red[400],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Donate to Group',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.circleInfo,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your donation will be split equally among all athlete members',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Amount Input with formatting
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(
                  color: _isTextFieldEmpty
                      ? Colors.grey[300]!
                      : Theme.of(context).colorScheme.primary,
                  width: _isTextFieldEmpty ? 1 : 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    Currency.symbol,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _isTextFieldEmpty
                          ? Colors.grey[400]
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _displayController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _isTextFieldEmpty
                            ? Colors.grey[400]
                            : Theme.of(context).colorScheme.primary,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "0.00",
                        hintStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: _onAmountChanged,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Quick amount chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [500, 1000, 2000, 5000, 10000].map((amount) {
                return ActionChip(
                  avatar: FaIcon(
                    FontAwesomeIcons.bolt,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    '${Currency.symbol}${_numberFormat.format(amount)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey[300]!),
                  onPressed: () {
                    _onAmountChanged(amount.toString());
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Message field
            TextField(
              controller: widget.controller.donationMessageController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Message (optional)',
                prefixIcon: const Icon(Icons.message_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 12),

            // User badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.user,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Donating as ${widget.controller.currentUserName}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  widget.controller.donationAmountController.clear();
                  widget.controller.donationMessageController.clear();
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () =>
                    widget.controller.isLoading.value ||
                        widget.controller._paymentController.isLoading.value
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          final amount = _getRawAmount();
                          if (amount == null) {
                            _showErrorInDialog('Please enter an amount');
                            return;
                          }
                          if (amount <= 0) {
                            _showErrorInDialog(
                              'Amount must be greater than zero',
                            );
                            return;
                          }
                          widget.controller.processDonation(widget.groupId);
                        },
                        icon: const FaIcon(FontAwesomeIcons.heart, size: 16),
                        label: const Text(
                          'Donate',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showErrorInDialog(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.black,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.red),
    );
  }
}

// ─────────────────────────────────────────────
//  Transfer Ownership Dialog (internal)
// ─────────────────────────────────────────────
class _TransferOwnershipDialog extends StatelessWidget {
  final List<MemberModel> members;

  const _TransferOwnershipDialog({required this.members});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.transfer_within_a_station,
                      color: Colors.amber[700],
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer Ownership',
                          style: robotoBold.copyWith(fontSize: 16),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Choose the new group admin',
                          style: robotoRegular.copyWith(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Member list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(16),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return _MemberPickerTile(
                    member: member,
                    onTap: () => Get.back(result: member),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberPickerTile extends StatelessWidget {
  final MemberModel member;
  final VoidCallback onTap;

  const _MemberPickerTile({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF045F25),
              child: Text(
                member.firstName.isNotEmpty
                    ? member.firstName[0].toUpperCase()
                    : 'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: robotoBold.copyWith(fontSize: 14),
                  ),
                  Text(
                    member.isModerator ? 'Moderator' : 'Member',
                    style: robotoRegular.copyWith(
                      fontSize: 11,
                      color: member.isModerator
                          ? Color(0xFF045F25)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

*/

// lib/athlete/feature/groups/controller/group_controller.dart

import 'dart:io';
import 'package:afriendorse/athlete/feature/auth/binding/sports_service.dart';
import 'package:afriendorse/athlete/feature/donation_currency_swappy/donation_currency_widgets.dart';
import 'package:afriendorse/athlete/feature/groups/models/group_models.dart';
import 'package:afriendorse/athlete/feature/groups/repository/group_firestore_service.dart';
import 'package:afriendorse/athlete/feature/groups/controller/group_payment_controller.dart';
import 'package:afriendorse/athlete/feature/groups/screens/donation_payment_method_sheet.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/shared/currency_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:afriendorse/athlete/feature/profile/controller/user_controller.dart'
    as athlete_controller;
import 'package:afriendorse/feature/profile/controller/user_controller.dart'
    as brandfan_controller;
import 'package:intl/intl.dart';

class GroupController extends GetxController {
  // ─── Lists ───────────────────────────────────
  final RxList<GroupModel> myGroups = <GroupModel>[].obs;
  final RxList<GroupModel> publicGroups = <GroupModel>[].obs;
  final RxList<PostModel> groupPosts = <PostModel>[].obs;
  final RxList<MemberModel> groupMembers = <MemberModel>[].obs;
  final RxList<MemberModel> bannedMembers = <MemberModel>[].obs;
  final RxList<CommentModel> currentComments = <CommentModel>[].obs;
  final RxList<SportModel> availableSports = <SportModel>[].obs;

  // ─── New observable fields (add to the top section) ───────────────────────────
  final RxList<JoinRequestModel> joinRequests = <JoinRequestModel>[].obs;
  final RxList<GroupModel> pendingGroups = <GroupModel>[].obs;
  // For add-by-email lookup result
  final Rx<Map<String, String>?> lookedUpUser = Rx<Map<String, String>?>(null);
  final RxBool isLookingUp = false.obs;
  final addByEmailController = TextEditingController();

  // ─── Current state ───────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isUploadingMedia = false.obs;
  final Rx<UserRole> currentUserRole = UserRole.unknown.obs;
  final RxString currentGroupId = ''.obs;
  final Rx<GroupModel?> currentGroup = Rx<GroupModel?>(null);
  final Rx<MemberModel?> currentMembership = Rx<MemberModel?>(null);
  final Rx<GroupAnalytics?> groupAnalytics = Rx<GroupAnalytics?>(null);
  final Rx<SportModel?> selectedSport = Rx<SportModel?>(null);

  // ─── Permissions ─────────────────────────────
  final RxBool canUserPost = false.obs;
  final RxBool canUserJoin = false.obs;
  final RxBool isCurrentUserAdmin = false.obs;
  final RxBool isCurrentUserMember = false.obs;

  // ─── Selected media ──────────────────────────
  final Rx<File?> selectedImage = Rx<File?>(null);
  final Rx<File?> selectedVideo = Rx<File?>(null);
  final RxString selectedPostType = 'text'.obs;
  // Add this to the observables section at the top of GroupController
  final RxDouble uploadProgress = 0.0.obs;

  // ─── Form controllers ─────────────────────────
  final groupNameController = TextEditingController();
  final groupDescriptionController = TextEditingController();
  final postContentController = TextEditingController();
  final commentController = TextEditingController();
  final donationAmountController = TextEditingController();
  final donationMessageController = TextEditingController();
  final inviteCodeController = TextEditingController();
  final editGroupNameController = TextEditingController();
  final editGroupDescController = TextEditingController();

  late final GroupPaymentController _paymentController;
  final ImagePicker _picker = ImagePicker();

  // ─── App-mode detection ──────────────────────

  bool get _isAthleteMode {
    try {
      Get.find<athlete_controller.UserProfileController>();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool get _isBrandFanMode {
    try {
      Get.find<brandfan_controller.UserController>();
      return true;
    } catch (e) {
      return false;
    }
  }

  String get currentUserId {
    if (_isAthleteMode) {
      final email = Get.find<athlete_controller.UserProfileController>()
          .providerModel
          ?.content
          ?.providerInfo
          ?.owner
          ?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    if (_isBrandFanMode) {
      try {
        return Get.find<brandfan_controller.UserController>()
                .userInfoModel
                ?.id ??
            '';
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  String get currentUserEmail {
    if (_isAthleteMode) {
      try {
        return Get.find<athlete_controller.UserProfileController>()
                .providerModel
                ?.content
                ?.providerInfo
                ?.owner
                ?.email ??
            '';
      } catch (e) {
        return '';
      }
    }
    if (_isBrandFanMode) {
      try {
        return Get.find<brandfan_controller.UserController>()
                .userInfoModel
                ?.email ??
            '';
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  String get currentUserName {
    if (_isAthleteMode) {
      try {
        final p = Get.find<athlete_controller.UserProfileController>()
            .providerModel
            ?.content
            ?.providerInfo;
        return '${p?.contactPersonName ?? ''}'.trim();
      } catch (e) {
        return 'Athlete';
      }
    }
    if (_isBrandFanMode) {
      try {
        final u = Get.find<brandfan_controller.UserController>().userInfoModel;
        return '${u?.fName ?? ''} ${u?.lName ?? ''}'.trim();
      } catch (e) {
        return 'User';
      }
    }
    return 'User';
  }

  // ─── Lifecycle ───────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _paymentController = Get.put(GroupPaymentController());
    _initUserRole();
    _loadSports();

    // ── ONE-TIME MIGRATION — remove after first run ──
    // GroupFirestoreService.migrateExistingGroups();
  }

  Future<void> _loadSports() async {
    final sports = await SportsService.getSports();
    availableSports.value = sports;
    if (sports.isNotEmpty) selectedSport.value = sports.first;
  }

  Future<void> refresh() => _initUserRole();

  Future<void> _initUserRole() async {
    isLoading.value = true;

    UserRole role = _detectRoleFromControllers();
    if (role == UserRole.unknown && currentUserId.isNotEmpty) {
      role = await GroupFirestoreService.getUserRole(currentUserId);
    }
    if (role == UserRole.unknown && _isBrandFanMode) {
      role = UserRole.fan;
    }

    currentUserRole.value = role;
    canUserPost.value = role == UserRole.athlete;
    canUserJoin.value = role == UserRole.athlete;

    if (role == UserRole.athlete) {
      _listenToAthleteGroups();
      _listenToPublicGroups(); // ← ADD THIS: let athletes see public groups too
    } else if (role == UserRole.brand || role == UserRole.fan) {
      _listenToPublicGroups();
    }
    isLoading.value = false;
  }

  /// Detect role from already-loaded controller data without Firestore
  UserRole _detectRoleFromControllers() {
    if (_isAthleteMode) {
      final hasProfile =
          Get.find<athlete_controller.UserProfileController>()
              .providerModel
              ?.content
              ?.providerInfo !=
          null;
      if (hasProfile) return UserRole.athlete;
    }
    if (_isBrandFanMode) {
      try {
        final user =
            Get.find<brandfan_controller.UserController>().userInfoModel;
        if (user == null) return UserRole.unknown;
        // Check for userType field if available, otherwise default to fan
        final type = (user as dynamic).userType as String?;
        if (type == 'brand') return UserRole.brand;
        return UserRole.fan; // brand/fan controller present → at least fan
      } catch (_) {
        return UserRole.fan; // controller present but no userType field
      }
    }
    return UserRole.unknown;
  }

  void _listenToAthleteGroups() {
    final email = currentUserEmail;
    if (email.isEmpty) return;

    // Listen to active memberships via profile array
    FirebaseFirestore.instance
        .collection('athlete_profiles')
        .doc(email)
        .snapshots()
        .listen((profileSnap) async {
          if (!profileSnap.exists) {
            myGroups.clear();
            return;
          }
          final data = profileSnap.data() as Map<String, dynamic>?;
          final groupIds = List<String>.from(data?['groups'] ?? []);
          if (groupIds.isEmpty) {
            myGroups.clear();
            return;
          }

          final snaps = await Future.wait(
            groupIds.map(
              (id) =>
                  FirebaseFirestore.instance.collection('groups').doc(id).get(),
            ),
          );

          myGroups.value = snaps
              .where((s) => s.exists)
              .map((s) => GroupModel.fromDoc(s))
              .toList();
        });

    // Separately listen to groups created by this athlete (any status)
    // so they can see pending/rejected groups they created
    GroupFirestoreService.getCreatorGroups(email).listen((snap) {
      final createdGroups = snap.docs
          .map((d) => GroupModel.fromDoc(d))
          .toList();

      // Pending/rejected ones go to pendingGroups
      pendingGroups.value = createdGroups
          .where(
            (g) =>
                g.status == GroupStatus.pending ||
                g.status == GroupStatus.rejected,
          )
          .toList();

      // Active ones that are already in myGroups don't need re-adding
      // (membership array handles that)
      // But if somehow a created active group isn't in myGroups, add it
      final myGroupIds = myGroups.map((g) => g.id).toSet();
      final activeCreated = createdGroups
          .where(
            (g) => g.status == GroupStatus.active && !myGroupIds.contains(g.id),
          )
          .toList();
      if (activeCreated.isNotEmpty) {
        myGroups.addAll(activeCreated);
      }
    });
  }

  void _listenToPublicGroups() {
    GroupFirestoreService.getPublicGroups().listen((snap) {
      publicGroups.value = snap.docs.map((d) => GroupModel.fromDoc(d)).toList();
    });
  }

  // ─── Group Details ───────────────────────────

  void loadGroupDetails(String groupId) {
    currentGroupId.value = groupId;

    // Listen to group doc
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .listen((snap) {
          if (snap.exists) currentGroup.value = GroupModel.fromDoc(snap);
        });

    // Listen to posts
    GroupFirestoreService.getGroupPosts(groupId).listen((snap) {
      groupPosts.value = snap.docs.map((d) => PostModel.fromDoc(d)).toList();
    });

    // Listen to members
    GroupFirestoreService.getGroupMembers(groupId).listen((snap) {
      groupMembers.value = snap.docs
          .map((d) => MemberModel.fromDoc(d))
          .toList();
    });

    // Check current user's membership
    GroupFirestoreService.getMemberStream(
      groupId: groupId,
      userId: currentUserId,
    ).listen((snap) {
      if (snap.exists && snap.data() != null) {
        final m = MemberModel.fromDoc(snap);
        currentMembership.value = m;
        isCurrentUserMember.value = !m.isBanned;
        isCurrentUserAdmin.value = m.isAdmin || m.isModerator;
      } else {
        currentMembership.value = null;
        isCurrentUserMember.value = false;
        isCurrentUserAdmin.value = false;
      }
    });
  }

  Future<void> loadAnalytics(String groupId) async {
    final analytics = await GroupFirestoreService.getGroupAnalytics(
      groupId: groupId,
      athleteId: currentUserId,
    );
    groupAnalytics.value = analytics;
  }

  // ─── Create / Edit Group ─────────────────────

  // ─── Updated createGroup ──────────────────────────────────────────────────────

  Future<void> createGroup({
    bool isPublic = true,
    bool requiresApproval = true,
  }) async {
    if (!canUserPost.value) {
      showCustomSnackBar('Only athletes can create groups');
      return;
    }
    if (groupNameController.text.trim().isEmpty) {
      showCustomSnackBar('Please enter a group name');
      return;
    }

    Get.back(); // Close dialog
    isLoading.value = true;

    String? coverImageUrl;
    if (selectedImage.value != null) {
      coverImageUrl = await _uploadFile(selectedImage.value!, 'group_covers');
    }

    final sport = selectedSport.value?.name ?? 'General';

    final groupId = await GroupFirestoreService.createGroup(
      creatorEmail: currentUserEmail,
      creatorName: currentUserName,
      name: groupNameController.text.trim(),
      description: groupDescriptionController.text.trim(),
      sport: sport,
      coverImage: coverImageUrl,
      isPublic: isPublic,
      requiresApproval: requiresApproval,
    );

    isLoading.value = false;
    selectedImage.value = null;
    groupNameController.clear();
    groupDescriptionController.clear();
    selectedSport.value = availableSports.isNotEmpty
        ? availableSports.first
        : null;

    if (groupId != null) {
      showCustomSnackBar(
        'Group created! Awaiting AfriEndorse approval before going live.',
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar('Failed to create group');
    }
  }

  Future<void> updateGroup({
    required String groupId,
    bool? isPublic,
    bool? requiresApproval, // ← ADD THIS
  }) async {
    isLoading.value = true;

    String? coverImageUrl;
    if (selectedImage.value != null) {
      coverImageUrl = await _uploadFile(selectedImage.value!, 'group_covers');
    }

    final success = await GroupFirestoreService.updateGroup(
      groupId: groupId,
      requesterId: currentUserId,
      name: editGroupNameController.text.trim().isNotEmpty
          ? editGroupNameController.text.trim()
          : null,
      description: editGroupDescController.text.trim().isNotEmpty
          ? editGroupDescController.text.trim()
          : null,
      coverImage: coverImageUrl,
      isPublic: isPublic,
      requiresApproval: requiresApproval, // ← ADD THIS
    );

    isLoading.value = false;
    selectedImage.value = null;
    editGroupNameController.clear();
    editGroupDescController.clear();

    if (success) {
      showCustomSnackBar('Group updated!', type: ToasterMessageType.success);
      Get.back();
    } else {
      showCustomSnackBar('Update failed');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Group'),
        content: Text(
          'This will permanently delete the group and all its content. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    isLoading.value = true;
    final success = await GroupFirestoreService.deleteGroup(
      groupId: groupId,
      requesterId: currentUserId,
    );
    isLoading.value = false;
    if (success) {
      showCustomSnackBar('Group deleted', type: ToasterMessageType.success);
      Get.back();
    } else {
      showCustomSnackBar('Failed to delete group');
    }
  }

  // ─── Membership ──────────────────────────────

  // ─── Updated joinGroupByCode ──────────────────────────────────────────────────

  Future<void> joinGroupByCode() async {
    final code = inviteCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      showCustomSnackBar('Please enter invite code');
      return;
    }

    isLoading.value = true;
    final groupDoc = await GroupFirestoreService.getGroupByInviteCode(code);
    if (groupDoc == null) {
      showCustomSnackBar('Invalid invite code');
      isLoading.value = false;
      return;
    }

    final groupData = groupDoc.data() as Map<String, dynamic>;
    final requiresApproval = (groupData['requiresApproval'] as bool?) ?? false;
    final parts = currentUserName.split(' ');

    bool success;
    if (requiresApproval) {
      success = await GroupFirestoreService.requestJoinGroup(
        groupId: groupDoc.id,
        userId: currentUserId,
        firstName: parts.first,
        lastName: parts.length > 1 ? parts.last : '',
        userType: currentUserRole.value.name,
      );
    } else {
      success = await GroupFirestoreService.joinGroup(
        groupId: groupDoc.id,
        userId: currentUserId,
        firstName: parts.first,
        lastName: parts.length > 1 ? parts.last : '',
        userType: currentUserRole.value.name,
      );
    }

    isLoading.value = false;
    if (success) {
      inviteCodeController.clear();
      Get.back();
      showCustomSnackBar(
        requiresApproval
            ? 'Join request sent! Awaiting admin approval.'
            : 'Joined group successfully!',
        type: ToasterMessageType.success,
      );
    }
  }

  // ─── Join Request Management ──────────────────────────────────────────────────

  void loadJoinRequests(String groupId) {
    GroupFirestoreService.getJoinRequests(groupId).listen((snap) {
      joinRequests.value = snap.docs
          .map((d) => JoinRequestModel.fromDoc(d))
          .toList();
    });
  }

  Future<void> approveJoinRequest({
    required String groupId,
    required String requestId,
    required String requesterName,
  }) async {
    final success = await GroupFirestoreService.approveJoinRequest(
      groupId: groupId,
      approverId: currentUserId,
      requestId: requestId,
    );
    if (success) {
      showCustomSnackBar(
        '$requesterName has been approved',
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar('Failed to approve request');
    }
  }

  Future<void> rejectJoinRequest({
    required String groupId,
    required String requestId,
    required String requesterName,
  }) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject Request'),
        content: Text('Reject $requesterName\'s request to join the group?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final success = await GroupFirestoreService.rejectJoinRequest(
      groupId: groupId,
      rejecterId: currentUserId,
      requestId: requestId,
    );
    if (success) {
      showCustomSnackBar('Request rejected');
    } else {
      showCustomSnackBar('Failed to reject request');
    }
  }

  // ─── Add Member by Email ──────────────────────────────────────────────────────

  Future<void> showAddByEmailDialog(String groupId) async {
    addByEmailController.clear();
    lookedUpUser.value = null;

    await Get.dialog(
      _AddByEmailDialog(groupId: groupId, controller: this),
      barrierDismissible: false,
    );
  }

  Future<void> lookupUserByEmail() async {
    final email = addByEmailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      showCustomSnackBar('Enter an email address');
      return;
    }
    isLookingUp.value = true;
    lookedUpUser.value = null;
    final result = await GroupFirestoreService.lookupUserByEmail(email);
    isLookingUp.value = false;
    if (result == null) {
      showCustomSnackBar('No user found with that email');
    } else {
      lookedUpUser.value = result;
    }
  }

  Future<void> confirmAddMemberByEmail(String groupId) async {
    final userInfo = lookedUpUser.value;
    if (userInfo == null) return;

    isLoading.value = true;
    final success = await GroupFirestoreService.addMemberByEmail(
      groupId: groupId,
      requesterId: currentUserId,
      targetEmail: userInfo['email'] ?? addByEmailController.text.trim(),
      addedBy: 'admin',
    );
    isLoading.value = false;

    if (success) {
      addByEmailController.clear();
      lookedUpUser.value = null;
      Get.back(); // close dialog
      showCustomSnackBar(
        '${userInfo['name']} added to group!',
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar('Failed to add member');
    }
  }

  // ─── Updated joinPublicGroup ──────────────────────────────────────────────────

  Future<void> joinPublicGroup(String groupId) async {
    isLoading.value = true;
    final parts = currentUserName.split(' ');

    // Check if group requires approval
    final groupDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .get();
    if (!groupDoc.exists) {
      isLoading.value = false;
      return;
    }
    final groupData = groupDoc.data() as Map<String, dynamic>;
    final requiresApproval = (groupData['requiresApproval'] as bool?) ?? false;

    if (requiresApproval) {
      final success = await GroupFirestoreService.requestJoinGroup(
        groupId: groupId,
        userId: currentUserId,
        firstName: parts.first,
        lastName: parts.length > 1 ? parts.last : '',
        userType: currentUserRole.value.name,
      );
      isLoading.value = false;
      if (success) {
        showCustomSnackBar(
          'Join request sent! Awaiting admin approval.',
          type: ToasterMessageType.success,
        );
      }
    } else {
      final success = await GroupFirestoreService.joinGroup(
        groupId: groupId,
        userId: currentUserId,
        firstName: parts.first,
        lastName: parts.length > 1 ? parts.last : '',
        userType: currentUserRole.value.name,
      );
      isLoading.value = false;
      if (success) {
        showCustomSnackBar('Joined!', type: ToasterMessageType.success);
      }
    }
  }

  Future<void> leaveGroup(String groupId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Leave Group'),
        content: Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('Leave'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    isLoading.value = true;
    final success = await GroupFirestoreService.leaveGroup(
      groupId: groupId,
      userId: currentUserId,
    );
    isLoading.value = false;
    if (success) {
      showCustomSnackBar('Left group', type: ToasterMessageType.success);
      Get.back();
    }
  }

  // ─── Admin: Member Management ─────────────────

  Future<void> removeMember(String groupId, MemberModel member) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Remove Member'),
        content: Text('Remove ${member.fullName} from the group?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final success = await GroupFirestoreService.removeMember(
      groupId: groupId,
      adminId: currentUserId,
      memberId: member.id,
      ban: false,
    );
    if (success)
      showCustomSnackBar('Member removed', type: ToasterMessageType.success);
  }

  Future<void> banMember(String groupId, MemberModel member) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Ban Member'),
        content: Text(
          'Ban ${member.fullName}? They will not be able to rejoin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Ban', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final success = await GroupFirestoreService.removeMember(
      groupId: groupId,
      adminId: currentUserId,
      memberId: member.id,
      ban: true,
    );
    if (success)
      showCustomSnackBar('Member banned', type: ToasterMessageType.success);
  }

  // ─── Posts ───────────────────────────────────

  Future<void> createPost() async {
    if (!canUserPost.value && !isCurrentUserMember.value) {
      showCustomSnackBar('Only group members can post');
      return;
    }
    if (postContentController.text.trim().isEmpty &&
        selectedImage.value == null &&
        selectedVideo.value == null) {
      showCustomSnackBar('Please add some content');
      return;
    }

    // ── CHANGED: don't close dialog yet — user needs to see upload progress
    isLoading.value = true;
    isUploadingMedia.value =
        selectedImage.value != null || selectedVideo.value != null;

    String? imageUrl;
    String? videoUrl;
    PostType postType = PostType.text;

    if (selectedImage.value != null) {
      imageUrl = await _uploadFile(selectedImage.value!, 'group_posts/images');
      postType = PostType.image;
    }
    if (selectedVideo.value != null) {
      videoUrl = await _uploadFile(selectedVideo.value!, 'group_posts/videos');
      postType = PostType.video;
    }

    isUploadingMedia.value = false;

    // ── CHANGED: only close dialog AFTER upload completes
    Get.back();

    final postId = await GroupFirestoreService.createPost(
      groupId: currentGroupId.value,
      authorId: currentUserId,
      authorName: currentUserName,
      authorType: currentUserRole.value.name,
      content: postContentController.text.trim(),
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      postType: postType,
    );

    isLoading.value = false;
    postContentController.clear();
    selectedImage.value = null;
    selectedVideo.value = null;

    if (postId != null) {
      showCustomSnackBar('Posted!', type: ToasterMessageType.success);
    } else {
      showCustomSnackBar('Failed to post');
    }
  }

  Future<void> deletePost(String postId) async {
    final success = await GroupFirestoreService.deletePost(
      groupId: currentGroupId.value,
      postId: postId,
      requesterId: currentUserId,
    );
    if (success)
      showCustomSnackBar('Post deleted', type: ToasterMessageType.success);
    else
      showCustomSnackBar('Failed to delete post');
  }

  Future<void> togglePinPost(PostModel post) async {
    if (!isCurrentUserAdmin.value) return;

    // Optimistic local update
    final idx = groupPosts.indexWhere((p) => p.id == post.id);
    if (idx != -1) {
      // Unpin any currently pinned post locally
      for (int i = 0; i < groupPosts.length; i++) {
        if (groupPosts[i].isPinned && groupPosts[i].id != post.id) {
          groupPosts[i] = _copyPostWith(groupPosts[i], isPinned: false);
        }
      }
      groupPosts[idx] = _copyPostWith(post, isPinned: !post.isPinned);
      groupPosts.refresh();
    }

    if (post.isPinned) {
      await GroupFirestoreService.unpinPost(
        groupId: currentGroupId.value,
        postId: post.id,
        adminId: currentUserId,
      );
      showCustomSnackBar('Post unpinned');
    } else {
      await GroupFirestoreService.pinPost(
        groupId: currentGroupId.value,
        postId: post.id,
        adminId: currentUserId,
      );
      showCustomSnackBar('Post pinned!', type: ToasterMessageType.success);
    }
  }

  Future<void> toggleLikePost(PostModel post) async {
    final userId = currentUserId;
    final idx = groupPosts.indexWhere((p) => p.id == post.id);
    if (idx == -1) return;

    final alreadyLiked = post.likedBy.contains(userId);

    // Optimistic local update
    final updatedLikedBy = List<String>.from(post.likedBy);
    if (alreadyLiked) {
      updatedLikedBy.remove(userId);
    } else {
      updatedLikedBy.add(userId);
    }
    groupPosts[idx] = _copyPostWith(
      post,
      likes: alreadyLiked ? post.likes - 1 : post.likes + 1,
      likedBy: updatedLikedBy,
    );
    groupPosts.refresh();

    // Persist to Firestore
    await GroupFirestoreService.toggleLikePost(
      groupId: currentGroupId.value,
      postId: post.id,
      userId: userId,
    );
  }

  // Helper: immutable post copy with selective field overrides
  PostModel _copyPostWith(
    PostModel p, {
    bool? isPinned,
    int? likes,
    List<String>? likedBy,
  }) {
    return PostModel(
      id: p.id,
      groupId: p.groupId,
      authorId: p.authorId,
      authorName: p.authorName,
      authorType: p.authorType,
      authorAvatar: p.authorAvatar,
      content: p.content,
      imageUrl: p.imageUrl,
      videoUrl: p.videoUrl,
      postType: p.postType,
      likes: likes ?? p.likes,
      commentsCount: p.commentsCount,
      isPinned: isPinned ?? p.isPinned,
      likedBy: likedBy ?? p.likedBy,
      createdAt: p.createdAt,
    );
  }

  // ─── Comments ────────────────────────────────

  void loadComments(String postId) {
    GroupFirestoreService.getComments(
      groupId: currentGroupId.value,
      postId: postId,
    ).listen((snap) {
      currentComments.value = snap.docs
          .map((d) => CommentModel.fromDoc(d))
          .toList();
    });
  }

  Future<void> addComment(String postId) async {
    if (commentController.text.trim().isEmpty) return;
    final content = commentController.text.trim();
    commentController.clear(); // Clear immediately for better UX

    // Optimistic local comment count update
    final idx = groupPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      groupPosts[idx] = _copyPostWith(
        groupPosts[idx],
        likes: groupPosts[idx].likes, // unchanged
      );
      // Update comment count locally
      final post = groupPosts[idx];
      groupPosts[idx] = PostModel(
        id: post.id,
        groupId: post.groupId,
        authorId: post.authorId,
        authorName: post.authorName,
        authorType: post.authorType,
        authorAvatar: post.authorAvatar,
        content: post.content,
        imageUrl: post.imageUrl,
        videoUrl: post.videoUrl,
        postType: post.postType,
        likes: post.likes,
        commentsCount: post.commentsCount + 1,
        isPinned: post.isPinned,
        likedBy: post.likedBy,
        createdAt: post.createdAt,
      );
      groupPosts.refresh();
    }

    await GroupFirestoreService.addComment(
      groupId: currentGroupId.value,
      postId: postId,
      authorId: currentUserId,
      authorName: currentUserName,
      authorType: currentUserRole.value.name,
      content: content,
    );
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await GroupFirestoreService.deleteComment(
      groupId: currentGroupId.value,
      postId: postId,
      commentId: commentId,
      requesterId: currentUserId,
    );
  }

  Future<void> toggleLikeComment(String postId, String commentId) async {
    await GroupFirestoreService.toggleLikeComment(
      groupId: currentGroupId.value,
      postId: postId,
      commentId: commentId,
      userId: currentUserId,
    );
  }

  // ─── Media Picking ───────────────────────────

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      selectedImage.value = File(picked.path);
      selectedVideo.value = null;
      selectedPostType.value = 'image';
    }
  }

  Future<void> pickVideo() async {
    final picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 2), // limit duration
    );
    if (picked != null) {
      // Check file size before accepting — reject anything over 50MB
      final file = File(picked.path);
      final sizeInMB = await file.length() / (1024 * 1024);
      if (sizeInMB > 50) {
        showCustomSnackBar(
          'Video is too large. Please choose a video under 50MB.',
          type: ToasterMessageType.info,
        );
        return;
      }
      selectedVideo.value = file;
      selectedImage.value = null;
      selectedPostType.value = 'video';
    }
  }

  void clearSelectedMedia() {
    selectedImage.value = null;
    selectedVideo.value = null;
    selectedPostType.value = 'text';
  }

  Future<String?> _uploadFile(File file, String folder) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
        '$folder/${DateTime.now().millisecondsSinceEpoch}_$currentUserId',
      );

      uploadProgress.value = 0.0;
      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((event) {
        uploadProgress.value = event.bytesTransferred / event.totalBytes;
      });

      final snapshot = await uploadTask.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          uploadTask.cancel();
          throw Exception('Upload timed out');
        },
      );

      uploadProgress.value = 0.0;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      uploadProgress.value = 0.0;
      if (kDebugMode) print('Upload error: $e');
      showCustomSnackBar(
        e.toString().contains('timed out')
            ? 'Upload timed out. Try a smaller video.'
            : 'Upload failed. Please try again.',
      );
      return null;
    }
  }

  // ─── Donations ───────────────────────────────

  void showDonationDialog(String groupId) {
    Get.dialog(
      _DonationDialog(groupId: groupId, controller: this),
      barrierDismissible: false,
    );
  }

  Future<void> processDonation(
    String groupId, {
    required String paymentMethod, // 'wallet' | 'online'
  }) async {
    final amount = double.tryParse(donationAmountController.text) ?? 0;
    if (amount <= 0) {
      showCustomSnackBar('Please enter a valid amount');
      return;
    }

    if (paymentMethod == 'wallet') {
      await _paymentController.donateViaWallet(
        groupId: groupId,
        amount: amount,
        donorId: currentUserId,
        donorEmail: currentUserEmail,
        donorName: currentUserName,
        donorType: currentUserRole.value.name,
        message: donationMessageController.text.isEmpty
            ? null
            : donationMessageController.text,
      );
    } else {
      await _paymentController.donateToGroup(
        groupId: groupId,
        amount: amount,
        donorId: currentUserId,
        donorEmail: currentUserEmail,
        donorName: currentUserName,
        donorType: currentUserRole.value.name,
        message: donationMessageController.text.isEmpty
            ? null
            : donationMessageController.text,
      );
    }

    donationAmountController.clear();
    donationMessageController.clear();
  }

  // ─── Sharing ─────────────────────────────────

  Future<void> shareGroup(
    String groupId,
    String inviteCode,
    String groupName,
  ) async {
    await _paymentController.shareGroup(groupId, inviteCode, groupName);
  }

  // ─── Advanced Membership Management ───────────

  /// Leave group (non-admin members only)
  Future<void> requestLeaveGroup(String groupId) async {
    // Guard: admin cannot leave without transferring ownership first
    if (isCurrentUserAdmin.value) {
      showCustomSnackBar(
        'You must transfer ownership before leaving the group',
        type: ToasterMessageType.info,
      );
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.exit_to_app, color: Colors.orange[700], size: 22),
            SizedBox(width: 10),
            Text('Leave Group'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to leave this group?',
              style: robotoMedium.copyWith(fontSize: 14),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can rejoin later if the group is public or with an invite code.',
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: Colors.orange[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Leave Group'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;
    final success = await GroupFirestoreService.leaveGroup(
      groupId: groupId,
      userId: currentUserId,
    );
    isLoading.value = false;

    if (success) {
      showCustomSnackBar('Left group', type: ToasterMessageType.success);
      Get.back(); // Return to groups list
    } else {
      showCustomSnackBar('Failed to leave group');
    }
  }

  /// Transfer ownership to another athlete (admin only)
  Future<void> initiateOwnershipTransfer(String groupId) async {
    if (!isCurrentUserAdmin.value) {
      showCustomSnackBar('Only the admin can transfer ownership');
      return;
    }

    // Get all athlete members (excluding current admin)
    final eligibleMembers = groupMembers
        .where(
          (m) =>
              m.userType == 'athlete' && !m.isBanned && m.id != currentUserId,
        )
        .toList();

    if (eligibleMembers.isEmpty) {
      showCustomSnackBar(
        'No eligible athletes to transfer ownership to',
        type: ToasterMessageType.info,
      );
      return;
    }

    // Show member picker dialog
    final selectedMember = await Get.dialog<MemberModel>(
      _TransferOwnershipDialog(members: eligibleMembers),
    );

    if (selectedMember == null) return;

    // Final confirmation
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.transfer_within_a_station, color: Colors.amber[700]),
            SizedBox(width: 10),
            Text('Confirm Transfer'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: robotoRegular.copyWith(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(text: 'Transfer ownership to '),
                  TextSpan(
                    text: selectedMember.fullName,
                    style: robotoBold.copyWith(color: Color(0xFF045F25)),
                  ),
                  TextSpan(text: '?'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: Colors.amber[900],
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will become a regular member and lose admin privileges. This cannot be undone.',
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: Colors.amber[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Transfer Ownership'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;
    final success = await GroupFirestoreService.transferOwnership(
      groupId: groupId,
      currentAdminId: currentUserId,
      newAdminId: selectedMember.id,
    );
    isLoading.value = false;

    if (success) {
      showCustomSnackBar(
        'Ownership transferred to ${selectedMember.fullName}',
        type: ToasterMessageType.success,
      );
      Get.back(); // Return to group details (now as regular member)
    } else {
      showCustomSnackBar('Failed to transfer ownership');
    }
  }

  /// Toggle moderator role (admin only)
  Future<void> toggleModerator(String groupId, MemberModel member) async {
    if (!isCurrentUserAdmin.value) {
      showCustomSnackBar('Only admins can assign moderators');
      return;
    }

    final isMod = member.isModerator;
    final action = isMod ? 'Remove moderator status' : 'Promote to moderator';

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isMod ? Icons.remove_moderator : Icons.shield_outlined,
              color: isMod ? Colors.orange[700] : Color(0xFF045F25),
              size: 22,
            ),
            SizedBox(width: 10),
            Text(action),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMod
                  ? '${member.fullName} will lose moderator privileges.'
                  : '${member.fullName} will be able to pin posts, remove content, and manage members.',
              style: robotoRegular.copyWith(fontSize: 13, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isMod ? Colors.orange[700] : Color(0xFF045F25),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(isMod ? 'Remove' : 'Promote'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await GroupFirestoreService.toggleModeratorRole(
      groupId: groupId,
      adminId: currentUserId,
      memberId: member.id,
      promote: !isMod,
    );

    if (success) {
      showCustomSnackBar(
        isMod
            ? '${member.fullName} is no longer a moderator'
            : '${member.fullName} is now a moderator',
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar('Failed to update role');
    }
  }

  // ─── Cleanup ─────────────────────────────────

  @override
  void onClose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    postContentController.dispose();
    commentController.dispose();
    donationAmountController.dispose();
    donationMessageController.dispose();
    inviteCodeController.dispose();
    editGroupNameController.dispose();
    editGroupDescController.dispose();
    addByEmailController.dispose(); // ← NEW
    super.onClose();
  }
}

// ─────────────────────────────────────────────
//  Donation Dialog Widget (internal)
// ─────────────────────────────────────────────
// ─────────────────────────────────────────────
//  Donation Dialog Widget (internal) - WITH NUMBER FORMATTING
// ─────────────────────────────────────────────
class _DonationDialog extends StatefulWidget {
  final String groupId;
  final GroupController controller;

  const _DonationDialog({required this.groupId, required this.controller});

  @override
  State<_DonationDialog> createState() => _DonationDialogState();
}

class _DonationDialogState extends State<_DonationDialog> {
  final TextEditingController _displayController = TextEditingController();
  final NumberFormat _numberFormat = NumberFormat('#,##0.##');
  bool _isTextFieldEmpty = true;

  @override
  void initState() {
    super.initState();
    ensureDonationCurrencyReady(); // ← ADD THIS
    _displayController.text = widget.controller.donationAmountController.text;
    _isTextFieldEmpty = _displayController.text.isEmpty;
  }

  @override
  void dispose() {
    _displayController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    String rawValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    final parts = rawValue.split('.');
    if (parts.length > 2) {
      rawValue = '${parts[0]}.${parts.sublist(1).join('')}';
    }
    widget.controller.donationAmountController.text = rawValue;

    if (rawValue.isEmpty) {
      _displayController.text = '';
      setState(() => _isTextFieldEmpty = true);
    } else {
      final number = double.tryParse(rawValue) ?? 0;
      final formatted = _numberFormat.format(number);
      _displayController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      setState(() => _isTextFieldEmpty = false);
    }
  }

  double? _getRawAmount() {
    final raw = widget.controller.donationAmountController.text.trim();
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  void _onContinue() {
    final amount = _getRawAmount();
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Invalid Amount',
        'Please enter a valid donation amount.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
      return;
    }

    // Close dialog then open payment method bottom sheet
    Get.back();
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DonationPaymentMethodSheet(
        groupId: widget.groupId,
        amount: amount,
        controller: widget.controller,
      ),
    );
  }

  // Replace _DonationDialogState inside group_controller.dart
  // Only the build method changes — everything else stays identical

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              FontAwesomeIcons.heart,
              color: Colors.red[400],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Donate to Group',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Amount input ────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(
                  color: _isTextFieldEmpty
                      ? Colors.grey[300]!
                      : Theme.of(context).colorScheme.primary,
                  width: _isTextFieldEmpty ? 1 : 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    '\$', // Always USD input
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _isTextFieldEmpty
                          ? Colors.grey[400]
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _displayController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _isTextFieldEmpty
                            ? Colors.grey[400]
                            : Theme.of(context).colorScheme.primary,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: _onAmountChanged,
                    ),
                  ),
                ],
              ),
            ),

            // ── Live local equivalent as user types ─────────────────────────
            if (!_isTextFieldEmpty && (_getRawAmount() ?? 0) > 0)
              DonationLocalAmountHint(
                usdAmount: _getRawAmount() ?? 0,
                textColor: Theme.of(context).colorScheme.primary,
              ),

            const SizedBox(height: 12),

            // ── Quick amount chips with local equivalents ────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [5.0, 10.0, 25.0, 50.0, 100.0].map((amount) {
                final isSelected =
                    widget.controller.donationAmountController.text ==
                    amount.toString();
                return DonationQuickChipWithLocal(
                  usdAmount: amount,
                  isSelected: isSelected,
                  onTap: () => _onAmountChanged(amount.toString()),
                  activeColor: Theme.of(context).colorScheme.primary,
                  displayLabel: '\$$amount',
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // ── Message field ────────────────────────────────────────────────
            TextField(
              controller: widget.controller.donationMessageController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Message (optional)',
                prefixIcon: const Icon(Icons.message_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // ── Donor badge ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.user,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Donating as ${widget.controller.currentUserName}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  widget.controller.donationAmountController.clear();
                  widget.controller.donationMessageController.clear();
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _onContinue,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Transfer Ownership Dialog (internal)
// ─────────────────────────────────────────────
class _TransferOwnershipDialog extends StatelessWidget {
  final List<MemberModel> members;

  const _TransferOwnershipDialog({required this.members});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.transfer_within_a_station,
                      color: Colors.amber[700],
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer Ownership',
                          style: robotoBold.copyWith(fontSize: 16),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Choose the new group admin',
                          style: robotoRegular.copyWith(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Member list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(16),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return _MemberPickerTile(
                    member: member,
                    onTap: () => Get.back(result: member),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberPickerTile extends StatelessWidget {
  final MemberModel member;
  final VoidCallback onTap;

  const _MemberPickerTile({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF045F25),
              child: Text(
                member.firstName.isNotEmpty
                    ? member.firstName[0].toUpperCase()
                    : 'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: robotoBold.copyWith(fontSize: 14),
                  ),
                  Text(
                    member.isModerator ? 'Moderator' : 'Member',
                    style: robotoRegular.copyWith(
                      fontSize: 11,
                      color: member.isModerator
                          ? Color(0xFF045F25)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Add By Email Dialog (internal widget)
// ─────────────────────────────────────────────
class _AddByEmailDialog extends StatelessWidget {
  final String groupId;
  final GroupController controller;

  const _AddByEmailDialog({required this.groupId, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: Color(0xFF045F25),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Add Member by Email',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Enter the email of the person you want to add. They will be added directly without needing to request.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Email input + search
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.addByEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'athlete@email.com',
                      prefixIcon: const Icon(Icons.email_outlined, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => controller.isLookingUp.value
                      ? const SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: controller.lookupUserByEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF045F25),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(44, 44),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.search_rounded, size: 20),
                        ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Lookup result
            Obx(() {
              final user = controller.lookedUpUser.value;
              if (user == null) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF045F25).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF045F25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              (user['name']?.isNotEmpty == true
                                      ? user['name']![0]
                                      : user['email']?[0] ?? '?')
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name']?.isNotEmpty == true
                                    ? user['name']!
                                    : 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user['email'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (user['type'] ?? 'unknown').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF045F25),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Found! Confirm to add this person to the group.',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  controller.addByEmailController.clear();
                  controller.lookedUpUser.value = null;
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(
                () => controller.lookedUpUser.value == null
                    ? ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Add Member'),
                      )
                    : controller.isLoading.value
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () =>
                            controller.confirmAddMemberByEmail(groupId),
                        icon: const Icon(Icons.person_add_rounded, size: 16),
                        label: const Text(
                          'Add Member',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF045F25),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
