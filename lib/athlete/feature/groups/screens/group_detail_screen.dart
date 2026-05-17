// lib/athlete/feature/groups/screens/group_detail_screen.dart

import 'package:afriendorse/athlete/feature/campaigns/widgets/group_campaigns_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afriendorse/athlete/feature/groups/controller/group_controller.dart';
import 'package:afriendorse/athlete/feature/groups/models/group_models.dart';
import 'package:afriendorse/athlete/feature/groups/screens/group_admin_screen.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:chewie/chewie.dart';
import 'package:afriendorse/shared/currency_helper.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;
  final GroupModel group;

  // Number formatter for currency displays
  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  const GroupDetailScreen({
    Key? key,
    required this.groupId,
    required this.group,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupController>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildAppBar(context, controller),
            _buildGroupInfo(context, controller),
            _buildTabBar(context),
          ],
          body: TabBarView(
            children: [
              _FeedTab(controller: controller, groupId: groupId),
              _MembersTab(controller: controller, groupId: groupId),
              _AnalyticsTab(controller: controller, groupId: groupId),
              GroupCampaignsSection(
                // ADD THIS
                group: group,
                currentUserId: controller.currentUserId,
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFAB(context, controller),
        // bottomNavigationBar: _buildBottomBar(context, controller),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, GroupController controller) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          group.name,
          style: robotoMedium.copyWith(
            color: Colors.white,
            fontSize: Dimensions.fontSizeDefault,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            group.coverImage.isNotEmpty
                ? Image.network(
                    group.coverImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _CoverFallback(context: context),
                  )
                : _CoverFallback(context: context),
            // Dark gradient overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
      // In _buildAppBar method, replace the existing actions array with:
      actions: [
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () =>
              controller.shareGroup(groupId, group.inviteCode, group.name),
          tooltip: 'Share Group',
        ),
        // ── Leave button (non-admin members) ──
        Obx(() {
          if (controller.isCurrentUserMember.value &&
              !controller.isCurrentUserAdmin.value) {
            return IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.orange[300]),
              onPressed: () => controller.requestLeaveGroup(groupId),
              tooltip: 'Leave Group',
            );
          }
          return SizedBox.shrink();
        }),
        // ── Admin panel (admin only) ──
        Obx(() {
          if (controller.isCurrentUserAdmin.value) {
            return IconButton(
              icon: Icon(Icons.admin_panel_settings),
              onPressed: () => Get.to(
                () => GroupAdminScreen(groupId: groupId, groupName: group.name),
              ),
              tooltip: 'Admin Panel',
            );
          }
          return SizedBox.shrink();
        }),
      ],
    );
  }

  SliverToBoxAdapter _buildGroupInfo(
    BuildContext context,
    GroupController controller,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          children: [
            // Description
            if (group.description.isNotEmpty)
              Text(
                group.description,
                style: robotoRegular.copyWith(
                  color: Colors.grey[700],
                  fontSize: Dimensions.fontSizeDefault,
                ),
                textAlign: TextAlign.center,
              ),

            SizedBox(height: 16),

            // Stats
            // REPLACE the Stats Row in _buildGroupInfo
            Obx(() {
              final isAthlete =
                  controller.currentUserRole.value == UserRole.athlete;

              final stats = <Widget>[
                _StatColumn(
                  icon: Icons.people,
                  value:
                      '${controller.currentGroup.value?.memberCount ?? group.memberCount}',
                  label: 'Members',
                  color: Colors.blue,
                ),
                if (isAthlete)
                  _StatColumn(
                    icon: Icons.attach_money,
                    value:
                        '${Currency.symbol}${_numberFormat.format(controller.currentGroup.value?.totalDonations ?? group.totalDonations)}',
                    label: 'Raised',
                    color: Colors.green,
                  ),
                _StatColumn(
                  icon: group.isPublic ? Icons.public : Icons.lock,
                  value: group.isPublic ? 'Public' : 'Private',
                  label: 'Type',
                  color: group.isPublic ? Colors.teal : Colors.orange,
                ),
                _StatColumn(
                  icon: Icons.sports,
                  value: group.sport,
                  label: 'Sport',
                  color: Colors.purple,
                ),
              ];

              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: stats
                    .map((stat) => Expanded(child: Center(child: stat)))
                    .toList(),
              );
            }),
            /* Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Obx(
                  () => _StatColumn(
                    icon: Icons.people,
                    value:
                        '${controller.currentGroup.value?.memberCount ?? group.memberCount}',
                    label: 'Members',
                    color: Colors.blue,
                  ),
                ),
                Obx(
                  () => _StatColumn(
                    icon: Icons.attach_money,
                    value:
                        '\${Currency.symbol}${(controller.currentGroup.value?.totalDonations ?? group.totalDonations).toStringAsFixed(0)}',
                    label: 'Raised',
                    color: Colors.green,
                  ),
                ),
                _StatColumn(
                  icon: group.isPublic ? Icons.public : Icons.lock,
                  value: group.isPublic ? 'Public' : 'Private',
                  label: 'Type',
                  color: group.isPublic ? Colors.teal : Colors.orange,
                ),
                _StatColumn(
                  icon: Icons.sports,
                  value: group.sport,
                  label: 'Sport',
                  color: Colors.purple,
                ),
              ],
            ),
*/
            SizedBox(height: 12),

            // ── JOIN BUTTON (Athletes who aren't members yet) ──
            Obx(() {
              final isAthlete =
                  controller.currentUserRole.value == UserRole.athlete;
              final isMember = controller.isCurrentUserMember.value;

              if (isAthlete && !isMember && group.isPublic) {
                return Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.joinPublicGroup(group.id),
                      icon: Icon(Icons.group_add, size: 18),
                      label: Text('Join This Group'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF045F25),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }),

            // Invite code (for admins)
            Obx(
              () => controller.isCurrentUserAdmin.value
                  ? GestureDetector(
                      onTap: () => controller.shareGroup(
                        groupId,
                        group.inviteCode,
                        group.name,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.vpn_key,
                              size: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Invite Code: ${group.inviteCode}',
                              style: robotoBold.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: 13,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.copy,
                              size: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ),

            // Donate button for non-athletes (shown in header)
            Obx(
              () => controller.currentUserRole.value != UserRole.athlete
                  ? Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              controller.showDonationDialog(groupId),
                          icon: Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Text('Donate to Support Athletes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  SliverPersistentHeader _buildTabBar(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SliverTabBarDelegate(
        TabBar(
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(icon: Icon(Icons.feed, size: 18), text: 'Feed'),
            Tab(icon: Icon(Icons.people, size: 18), text: 'Members'),
            Tab(icon: Icon(Icons.bar_chart, size: 18), text: 'Dashboard'),
            Tab(icon: Icon(Icons.campaign, size: 18), text: 'Campaigns'),
          ],
        ),
      ),
      pinned: true,
    );
  }

  Widget? _buildFAB(BuildContext context, GroupController controller) {
    return Obx(() {
      // Athletes who are members can post
      if (controller.isCurrentUserMember.value &&
          controller.canUserPost.value) {
        return FloatingActionButton.extended(
          onPressed: () => _showCreatePostDialog(context, controller),
          icon: Icon(Icons.add),
          label: Text('Post'),
          backgroundColor: Theme.of(context).primaryColor,
        );
      }
      return SizedBox.shrink();
    });
  }

  Widget? _buildBottomBar(BuildContext context, GroupController controller) {
    return Obx(() {
      if (controller.currentUserRole.value == UserRole.brand ||
          controller.currentUserRole.value == UserRole.fan) {
        return Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton.icon(
              onPressed: () => controller.showDonationDialog(groupId),
              icon: Icon(Icons.favorite),
              label: Text('Donate to Support Athletes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      }
      return SizedBox.shrink();
    });
  }

  // ─── Post Dialog ─────────────────────────────

  void _showCreatePostDialog(BuildContext context, GroupController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: 18,
                    child: Text(
                      controller.currentUserName.isNotEmpty
                          ? controller.currentUserName[0].toUpperCase()
                          : 'A',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.currentUserName,
                          style: robotoBold.copyWith(fontSize: 14),
                        ),
                        Text(
                          'Posting to ${group.name}',
                          style: robotoRegular.copyWith(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              TextField(
                controller: controller.postContentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Share something with your group...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
              ),

              SizedBox(height: 12),

              // Media preview
              Obx(() {
                if (controller.selectedImage.value != null) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          controller.selectedImage.value!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: controller.clearSelectedMedia,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                if (controller.selectedVideo.value != null) {
                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.video_file, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Video selected', style: robotoRegular),
                        Spacer(),
                        GestureDetector(
                          onTap: controller.clearSelectedMedia,
                          child: Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              }),

              SizedBox(height: 12),

              // Media action buttons
              Row(
                children: [
                  _MediaButton(
                    icon: Icons.image,
                    label: 'Add Photo',
                    color: Colors.green,
                    onTap: controller.pickImage,
                  ),
                  SizedBox(width: 8),
                  _MediaButton(
                    icon: Icons.videocam,
                    label: 'Add Video',
                    color: Colors.black,
                    onTap: controller.pickVideo,
                  ),
                ],
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.postContentController.clear();
                        controller.clearSelectedMedia();
                        Get.back();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      final isLoading = controller.isLoading.value;

                      if (isLoading) {
                        return ElevatedButton.icon(
                          onPressed: null, // disabled while uploading
                          icon: const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          label: const Text('Posting...'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }

                      return ElevatedButton.icon(
                        onPressed: controller.createPost,
                        icon: const Icon(Icons.send, size: 18),
                        label: const Text('Post'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),

              // ── Upload progress bar (shown below buttons during upload) ──
              Obx(() {
                final isUploading = controller.isUploadingMedia.value;
                final progress = controller.uploadProgress.value;

                if (!isUploading) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Uploading media...',
                                style: robotoMedium.copyWith(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: robotoBold.copyWith(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.grey[200],
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Please keep the app open until upload completes',
                        style: robotoRegular.copyWith(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Feed Tab ─────────────────────────────────────

class _FeedTab extends StatelessWidget {
  final GroupController controller;
  final String groupId;

  const _FeedTab({required this.controller, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.groupPosts.isEmpty) {
        return _EmptyFeed(isAthlete: controller.canUserPost.value);
      }
      return ListView.builder(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        itemCount: controller.groupPosts.length,
        itemBuilder: (context, index) {
          final post = controller.groupPosts[index];
          return _PostCard(
            post: post,
            controller: controller,
            groupId: groupId,
          );
        },
      );
    });
  }
}

class _EmptyFeed extends StatelessWidget {
  final bool isAthlete;
  const _EmptyFeed({required this.isAthlete});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No Posts Yet',
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 8),
          Text(
            isAthlete
                ? 'Tap the Post button to share with your group!'
                : 'Athletes will post updates here. Stay tuned!',
            style: robotoRegular.copyWith(
              color: Colors.grey[400],
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Post Card ────────────────────────────────────

class _PostCard extends StatelessWidget {
  final PostModel post;
  final GroupController controller;
  final String groupId;

  const _PostCard({
    required this.post,
    required this.controller,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = post.likedBy.contains(controller.currentUserId);
    final isAdmin = controller.isCurrentUserAdmin.value;
    final isAuthor = post.authorId == controller.currentUserId;

    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: post.isPinned
            ? Border.all(color: Colors.amber.shade300, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned indicator
          if (post.isPinned)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.push_pin, size: 14, color: Colors.amber[700]),
                  SizedBox(width: 4),
                  Text(
                    'Pinned Post',
                    style: robotoMedium.copyWith(
                      color: Colors.amber[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author header
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 20,
                      backgroundImage:
                          post.authorAvatar != null &&
                              post.authorAvatar!.isNotEmpty
                          ? NetworkImage(post.authorAvatar!)
                          : null,
                      child:
                          post.authorAvatar == null ||
                              post.authorAvatar!.isEmpty
                          ? Text(
                              post.authorName.isNotEmpty
                                  ? post.authorName[0].toUpperCase()
                                  : 'A',
                              style: TextStyle(color: Colors.white),
                            )
                          : null,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            style: robotoBold.copyWith(fontSize: 14),
                          ),
                          Row(
                            children: [
                              _RoleBadge(role: post.authorType),
                              SizedBox(width: 6),
                              Text(
                                timeago.format(post.createdAt),
                                style: robotoRegular.copyWith(
                                  fontSize: 11,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Post options menu
                    if (isAdmin || isAuthor)
                      PopupMenuButton<String>(
                        onSelected: (val) async {
                          if (val == 'delete') {
                            await controller.deletePost(post.id);
                          } else if (val == 'pin') {
                            await controller.togglePinPost(post);
                          }
                        },
                        itemBuilder: (_) => [
                          if (isAdmin)
                            PopupMenuItem(
                              value: 'pin',
                              child: Row(
                                children: [
                                  Icon(
                                    post.isPinned
                                        ? Icons.push_pin_outlined
                                        : Icons.push_pin,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(post.isPinned ? 'Unpin' : 'Pin Post'),
                                ],
                              ),
                            ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                SizedBox(height: 12),

                // Content
                if (post.content.isNotEmpty)
                  Text(
                    post.content,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),

                // Image
                if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                  SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],

                // Video indicator
                if (post.videoUrl != null && post.videoUrl!.isNotEmpty) ...[
                  SizedBox(height: 10),
                  _VideoPlaceholder(videoUrl: post.videoUrl!),
                ],

                SizedBox(height: 12),
                Divider(height: 1),
                SizedBox(height: 8),

                // Engagement row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.toggleLikePost(post),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: isLiked ? Colors.red : Colors.grey[500],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${post.likes}',
                            style: robotoRegular.copyWith(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => _showCommentsSheet(context),
                      child: Row(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 20,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${post.commentsCount}',
                            style: robotoRegular.copyWith(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => _showCommentsSheet(context),
                      child: Text(
                        'View comments',
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsSheet(BuildContext context) {
    controller.loadComments(post.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CommentsSheet(post: post, controller: controller),
    );
  }
}

// ─── Comments Sheet ───────────────────────────────

class _CommentsSheet extends StatelessWidget {
  final PostModel post;
  final GroupController controller;

  const _CommentsSheet({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 8, bottom: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                Spacer(),
                Obx(
                  () => Text(
                    '${controller.currentComments.length}',
                    style: robotoRegular.copyWith(color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),

          Divider(),

          // Comments list
          Expanded(
            child: Obx(
              () => controller.currentComments.isEmpty
                  ? Center(
                      child: Text(
                        'No comments yet. Be the first!',
                        style: robotoRegular.copyWith(color: Colors.grey[400]),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.currentComments.length,
                      itemBuilder: (context, index) {
                        final comment = controller.currentComments[index];
                        final isCommentAuthor =
                            comment.authorId == controller.currentUserId;
                        final isAdmin = controller.isCurrentUserAdmin.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  comment.authorName.isNotEmpty
                                      ? comment.authorName[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          comment.authorName,
                                          style: robotoBold.copyWith(
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        _RoleBadge(
                                          role: comment.authorType,
                                          small: true,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      comment.content,
                                      style: robotoRegular.copyWith(
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          timeago.format(comment.createdAt),
                                          style: robotoRegular.copyWith(
                                            color: Colors.grey[400],
                                            fontSize: 11,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: () =>
                                              controller.toggleLikeComment(
                                                post.id,
                                                comment.id,
                                              ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                comment.likedBy.contains(
                                                      controller.currentUserId,
                                                    )
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                size: 14,
                                                color:
                                                    comment.likedBy.contains(
                                                      controller.currentUserId,
                                                    )
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                '${comment.likes}',
                                                style: robotoRegular.copyWith(
                                                  fontSize: 11,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isCommentAuthor || isAdmin)
                                GestureDetector(
                                  onTap: () => controller.deleteComment(
                                    post.id,
                                    comment.id,
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Comment input
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    controller.currentUserName.isNotEmpty
                        ? controller.currentUserName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller.commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 20,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () => controller.addComment(post.id),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Members Tab ──────────────────────────────────

class _MembersTab extends StatelessWidget {
  final GroupController controller;
  final String groupId;

  const _MembersTab({required this.controller, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Filter banned members client-side — ensures creator always appears
      final members = controller.groupMembers
          .where((m) => !m.isBanned)
          .toList();

      if (members.isEmpty) {
        return Center(
          child: Text(
            'No members yet',
            style: robotoRegular.copyWith(color: Colors.grey[500]),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return _MemberTile(
            member: member,
            controller: controller,
            groupId: groupId,
          );
        },
      );
    });
  }
}

class _MemberTile extends StatelessWidget {
  final MemberModel member;
  final GroupController controller;
  final String groupId;

  // Number formatter for currency displays
  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  const _MemberTile({
    required this.member,
    required this.controller,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = controller.isCurrentUserAdmin.value;
    final isMe = member.id == controller.currentUserId;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: member.isAdmin
            ? Border.all(color: Colors.amber.shade300, width: 1)
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: member.isAdmin
                ? Colors.amber
                : Theme.of(context).primaryColor,
            backgroundImage:
                member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                ? Text(
                    '${member.firstName.isNotEmpty ? member.firstName[0] : ''}${member.lastName.isNotEmpty ? member.lastName[0] : ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.fullName,
                      style: robotoBold.copyWith(fontSize: 14),
                    ),
                    if (isMe) ...[
                      SizedBox(width: 4),
                      Text(
                        '(You)',
                        style: robotoRegular.copyWith(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                    if (member.isAdmin) ...[SizedBox(width: 6), _AdminBadge()],
                  ],
                ),
                SizedBox(height: 2),
                // REPLACE the earnings row inside _MemberTile's Column children
                Row(
                  children: [
                    _RoleBadge(role: member.userType, small: true),
                    SizedBox(width: 8),
                    // ── CHANGED: earnings only visible to athletes (admins see all) ──
                    if (member.userType == 'athlete')
                      Obx(
                        () =>
                            controller.currentUserRole.value == UserRole.athlete
                            ? Text(
                                '${Currency.symbol}${_numberFormat.format(member.earnings)} earned',
                                style: robotoMedium.copyWith(
                                  color: Colors.green,
                                  fontSize: 11,
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                  ],
                ),
                /*  Row(
                  children: [
                    _RoleBadge(role: member.userType, small: true),
                    SizedBox(width: 8),
                    if (member.userType == 'athlete') ...[
                      // Icon(Icons.attach_money, size: 12, color: Colors.green),
                      Text(
                        '${Currency.symbol}${member.earnings.toStringAsFixed(2)} earned',
                        style: robotoMedium.copyWith(
                          color: Colors.green,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ), */
              ],
            ),
          ),

          // Admin actions
          if (isAdmin && !isMe && !member.isAdmin)
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'remove') controller.removeMember(groupId, member);
                if (val == 'ban') controller.banMember(groupId, member);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Remove'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'ban',
                  child: Row(
                    children: [
                      Icon(Icons.block, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Ban', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Analytics Tab ────────────────────────────────

class _AnalyticsTab extends StatefulWidget {
  final GroupController controller;
  final String groupId;

  const _AnalyticsTab({required this.controller, required this.groupId});

  @override
  State<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<_AnalyticsTab> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadAnalytics(widget.groupId);
  }

  // Number formatter for currency displays
  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  /* 
   @override
  Widget build(BuildContext context) {
    return Obx(() {
      final analytics = widget.controller.groupAnalytics.value;
      if (analytics == null) {
        return Center(child: CircularProgressIndicator());
      }

      return ListView(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        children: [
          // My Earnings card (if athlete)
          if (widget.controller.canUserPost.value)
            _DashboardCard(
              title: 'My Earnings',
              icon: Icons.account_balance_wallet,
              color: Colors.green,
              child: Column(
                children: [
                  _MetricRow(
                    label: 'My Total Earnings',
                    value: '\${Currency.symbol}${analytics.myEarnings.toStringAsFixed(2)}',
                    valueColor: Colors.green,
                    large: true,
                  ),
                  Divider(),
                  _MetricRow(
                    label: 'This Month (Group)',
                    value: '\${Currency.symbol}${analytics.monthlyRevenue.toStringAsFixed(2)}',
                    valueColor: Colors.teal,
                  ),
                  _MetricRow(
                    label: 'My Share (this month)',
                    value: analytics.athleteMembers > 0
                        ? '\${Currency.symbol}${(analytics.monthlyRevenue / analytics.athleteMembers).toStringAsFixed(2)}'
                        : '\${Currency.symbol}0.00',
                  ),
                ],
              ),
            ),

          SizedBox(height: 12),

          // Group stats
          _DashboardCard(
            title: 'Group Overview',
            icon: Icons.groups,
            color: Colors.blue,
            child: Column(
              children: [
                _MetricRow(
                  label: 'Total Members',
                  value: '${analytics.totalMembers}',
                ),
                _MetricRow(
                  label: 'Athlete Members',
                  value: '${analytics.athleteMembers}',
                ),
                _MetricRow(
                  label: 'Total Posts',
                  value: '${analytics.totalPosts}',
                ),
                _MetricRow(
                  label: 'Total Donors',
                  value: '${analytics.totalDonors}',
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Donation totals
          _DashboardCard(
            title: 'Donation Summary',
            icon: Icons.volunteer_activism,
            color: Colors.red,
            child: Column(
              children: [
                _MetricRow(
                  label: 'Total Raised (All Time)',
                  value: '\${Currency.symbol}${analytics.totalDonations.toStringAsFixed(2)}',
                  valueColor: Colors.green,
                  large: true,
                ),
                Divider(),
                _MetricRow(
                  label: 'This Month',
                  value: '\${Currency.symbol}${analytics.monthlyRevenue.toStringAsFixed(2)}',
                  valueColor: Colors.teal,
                ),
                if (analytics.athleteMembers > 0)
                  _MetricRow(
                    label: 'Per Athlete (All Time)',
                    value:
                        '\${Currency.symbol}${(analytics.totalDonations / analytics.athleteMembers).toStringAsFixed(2)}',
                  ),
              ],
            ),
          ),

          // Recent donations
          if (analytics.recentDonations.isNotEmpty) ...[
            SizedBox(height: 12),
            _DashboardCard(
              title: 'Recent Donations',
              icon: Icons.history,
              color: Colors.purple,
              child: Column(
                children: analytics.recentDonations
                    .map(
                      (d) => Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.red[50],
                              child: Icon(
                                Icons.favorite,
                                size: 14,
                                color: Colors.red[300],
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.donorName,
                                    style: robotoBold.copyWith(fontSize: 13),
                                  ),
                                  if (d.message != null &&
                                      d.message!.isNotEmpty)
                                    Text(
                                      '"${d.message}"',
                                      style: robotoRegular.copyWith(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\${Currency.symbol}${d.amount.toStringAsFixed(2)}',
                                  style: robotoBold.copyWith(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  timeago.format(d.createdAt),
                                  style: robotoRegular.copyWith(
                                    fontSize: 10,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],

          SizedBox(height: 32),
        ],
      );
    });
  }
*/
  // REPLACE the build method of _AnalyticsTabState
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ── CHANGED: non-athletes see a restricted view ──
      if (widget.controller.currentUserRole.value != UserRole.athlete) {
        return _FanBrandDashboardView(controller: widget.controller);
      }

      final analytics = widget.controller.groupAnalytics.value;
      if (analytics == null) {
        return Center(child: CircularProgressIndicator());
      }

      return ListView(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        children: [
          // My Earnings card (athletes only — already gated by canUserPost)
          if (widget.controller.canUserPost.value)
            _DashboardCard(
              title: 'My Earnings',
              icon: Icons.account_balance_wallet,
              color: Colors.green,
              child: Column(
                children: [
                  // My Earnings card
                  _MetricRow(
                    label: 'My Total Earnings',
                    value:
                        '${Currency.symbol}${_numberFormat.format(analytics.myEarnings)}',
                    valueColor: Colors.green,
                    large: true,
                  ),
                  Divider(),
                  _MetricRow(
                    label: 'This Month (Group)',
                    value:
                        '${Currency.symbol}${_numberFormat.format(analytics.monthlyRevenue)}',
                    valueColor: Colors.teal,
                  ),
                  _MetricRow(
                    label: 'My Share (this month)',
                    value: analytics.athleteMembers > 0
                        ? '${Currency.symbol}${_numberFormat.format(analytics.monthlyRevenue / analytics.athleteMembers)}'
                        : '${Currency.symbol}0.00',
                  ),
                ],
              ),
            ),

          SizedBox(height: 12),

          // Group stats — athletes see full picture
          _DashboardCard(
            title: 'Group Overview',
            icon: Icons.groups,
            color: Colors.blue,
            child: Column(
              children: [
                _MetricRow(
                  label: 'Total Members',
                  value: '${analytics.totalMembers}',
                ),
                _MetricRow(
                  label: 'Athlete Members',
                  value: '${analytics.athleteMembers}',
                ),
                _MetricRow(
                  label: 'Total Posts',
                  value: '${analytics.totalPosts}',
                ),
                _MetricRow(
                  label: 'Total Donors',
                  value: '${analytics.totalDonors}',
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Donation totals — athletes only
          _DashboardCard(
            title: 'Donation Summary',
            icon: Icons.volunteer_activism,
            color: Colors.red,
            child: Column(
              children: [
                // Donation Summary
                _MetricRow(
                  label: 'Total Raised (All Time)',
                  value:
                      '${Currency.symbol}${_numberFormat.format(analytics.totalDonations)}',
                  valueColor: Colors.green,
                  large: true,
                ),
                Divider(),
                _MetricRow(
                  label: 'This Month',
                  value:
                      '${Currency.symbol}${_numberFormat.format(analytics.monthlyRevenue)}',
                  valueColor: Colors.teal,
                ),
                if (analytics.athleteMembers > 0)
                  _MetricRow(
                    label: 'Per Athlete (All Time)',
                    value:
                        '${Currency.symbol}${_numberFormat.format(analytics.totalDonations / analytics.athleteMembers)}',
                  ),
              ],
            ),
          ),

          // Recent donations — athletes only
          if (analytics.recentDonations.isNotEmpty) ...[
            SizedBox(height: 12),
            _DashboardCard(
              title: 'Recent Donations',
              icon: Icons.history,
              color: Colors.purple,
              child: Column(
                children: analytics.recentDonations
                    .map(
                      (d) => Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.red[50],
                              child: Icon(
                                Icons.favorite,
                                size: 14,
                                color: Colors.red[300],
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.donorName,
                                    style: robotoBold.copyWith(fontSize: 13),
                                  ),
                                  if (d.message != null &&
                                      d.message!.isNotEmpty)
                                    Text(
                                      '"${d.message}"',
                                      style: robotoRegular.copyWith(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Recent donation amount
                                Text(
                                  '${Currency.symbol}${_numberFormat.format(d.amount)}',
                                  style: robotoBold.copyWith(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  timeago.format(d.createdAt),
                                  style: robotoRegular.copyWith(
                                    fontSize: 10,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],

          SizedBox(height: 32),
        ],
      );
    });
  }
}

/// Restricted dashboard shown to fans and brands.
/// Shows community stats only — no earnings, no fund distribution.
class _FanBrandDashboardView extends StatelessWidget {
  final GroupController controller;
  const _FanBrandDashboardView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final group = controller.currentGroup.value;
      final memberCount = group?.memberCount ?? 0;
      final postCount = controller.groupPosts.length;

      return ListView(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        children: [
          // Community overview — safe public stats only
          _DashboardCard(
            title: 'Community Overview',
            icon: Icons.groups,
            color: Colors.blue,
            child: Column(
              children: [
                _MetricRow(label: 'Total Members', value: '$memberCount'),
                _MetricRow(label: 'Total Posts', value: '$postCount'),
                _MetricRow(label: 'Sport', value: group?.sport ?? '—'),
                _MetricRow(
                  label: 'Visibility',
                  value: (group?.isPublic ?? true) ? 'Public' : 'Private',
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Support prompt — encourage donation without showing totals
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF045F25), Color(0xFF033D18)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.volunteer_activism,
                      color: Colors.amber,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Support This Group',
                      style: robotoBold.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Your donation goes directly to the athletes in this group. Every contribution makes a difference!',
                  style: robotoRegular.copyWith(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 14),
                //Support this group view color riot
                /*  SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.showDonationDialog(
                      controller.currentGroupId.value,
                    ),
                    icon: Icon(Icons.favorite, color: Colors.white, size: 16),
                    label: Text('Donate Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ), */
              ],
            ),
          ),

          SizedBox(height: 32),
        ],
      );
    });
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Text(
                  title,
                  style: robotoBold.copyWith(color: color, fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool large;

  const _MetricRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: robotoRegular.copyWith(
              color: Colors.grey[600],
              fontSize: large ? 14 : 13,
            ),
          ),
          Text(
            value,
            style: (large ? robotoBold : robotoMedium).copyWith(
              color: valueColor ?? Colors.black87,
              fontSize: large ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: robotoBold.copyWith(fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: robotoRegular.copyWith(fontSize: 10, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  final bool small;

  const _RoleBadge({required this.role, this.small = false});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role.toLowerCase()) {
      case 'athlete':
        color = Colors.blue;
        break;
      case 'brand':
        color = Colors.purple;
        break;
      case 'fan':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 5 : 7,
        vertical: small ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.toUpperCase(),
        style: robotoRegular.copyWith(
          fontSize: small ? 9 : 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AdminBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 10, color: Colors.amber[700]),
          SizedBox(width: 2),
          Text(
            'Admin',
            style: robotoRegular.copyWith(
              fontSize: 10,
              color: Colors.amber[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlaceholder extends StatefulWidget {
  final String videoUrl;
  const _VideoPlaceholder({required this.videoUrl});

  @override
  State<_VideoPlaceholder> createState() => _VideoPlaceholderState();
}

class _VideoPlaceholderState extends State<_VideoPlaceholder> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasError = false;

  Future<void> _initAndPlay() async {
    if (_isLoading || _isInitialized) return;
    setState(() => _isLoading = true);

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _videoController!.initialize().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception('Video load timed out'),
      );

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF045F25),
          handleColor: const Color(0xFF045F25),
          bufferedColor: Colors.grey.shade300,
          backgroundColor: Colors.black26,
        ),
        placeholder: Container(color: Colors.black),
        errorBuilder: (context, errorMessage) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 32),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: robotoRegular.copyWith(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      if (kDebugMode) print('Video init error: $e');
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized && _chewieController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
      );
    }

    return GestureDetector(
      onTap: _initAndPlay,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: _hasError
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[300], size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Could not load video',
                      style: robotoRegular.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() => _hasError = false);
                        _initAndPlay();
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                )
              : _isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 10),
                    Text(
                      'Loading video...',
                      style: robotoRegular.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      radius: 28,
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to play video',
                      style: robotoRegular.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 4),
            Text(
              label,
              style: robotoRegular.copyWith(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  final BuildContext context;
  const _CoverFallback({required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(child: Icon(Icons.groups, size: 64, color: Colors.white30)),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Theme.of(context).cardColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate old) => false;
}
