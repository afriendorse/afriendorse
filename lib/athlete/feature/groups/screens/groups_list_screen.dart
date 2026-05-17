// lib/athlete/feature/groups/screens/groups_list_screen.dart

import 'package:afriendorse/athlete/feature/auth/binding/sports_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/groups/controller/group_controller.dart';
import 'package:afriendorse/athlete/feature/groups/models/group_models.dart';
import 'package:afriendorse/athlete/feature/groups/screens/group_detail_screen.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:afriendorse/shared/currency_helper.dart';

class GroupsListScreen extends StatelessWidget {
  const GroupsListScreen({Key? key}) : super(key: key);

  // Number formatter for currency displays
  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Groups & Clubs',
        actionWidget: Obx(() {
          if (controller.canUserPost.value) {
            return Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.vpn_key_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  tooltip: 'Join by code',
                  onPressed: () => _showJoinGroupDialog(controller),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  tooltip: 'Create group',
                  onPressed: () => _showCreateGroupDialog(context, controller),
                ),
              ],
            );
          }
          return SizedBox.shrink();
        }),
      ),
      body: Obx(() {
        final role = controller.currentUserRole.value;
        // Only show skeleton while actively loading AND role still unknown
        if (controller.isLoading.value && role == UserRole.unknown) {
          return _buildLoadingSkeleton(context);
        }
        if (role == UserRole.athlete) {
          return _buildAthleteView(context, controller);
        }
        // brand, fan, OR still unknown-but-not-loading → show brand/fan view
        // (unknown after load means Firestore lookup failed; show public groups anyway)
        return _buildBrandFanView(context, controller);
      }),
    );
  }

  // ─── Skeleton ─────────────────────────────────

  Widget _buildLoadingSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _ShimmerBox(height: 160, radius: 20),
          SizedBox(height: 14),
          _ShimmerBox(height: 16, radius: 8, width: 140),
          SizedBox(height: 16),
          ...List.generate(
            3,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: _ShimmerBox(height: 210, radius: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Athlete View ─────────────────────────────

  // ─── Athlete View ─────────────────────────────

  Widget _buildAthleteView(BuildContext context, GroupController controller) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _AthleteSummaryBanner(controller: controller),
          Container(
            color: Theme.of(context).cardColor,
            child: TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.groups, size: 16),
                      SizedBox(width: 6),
                      Obx(
                        () => Text('My Groups (${controller.myGroups.length})'),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.explore, size: 16),
                      SizedBox(width: 6),
                      Obx(
                        () => Text(
                          'Discover (${controller.publicGroups.length})',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _MyGroupsTab(controller: controller),
                _DiscoverGroupsTab(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*  Widget _buildAthleteEmptyState(
    BuildContext context,
    GroupController controller,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: Column(
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.15),
                    Theme.of(context).primaryColor.withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_outlined,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Start Your Community',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create a group for your fans and fellow athletes,\nor join one with an invite code.',
              style: robotoRegular.copyWith(
                color: Colors.grey[600],
                fontSize: Dimensions.fontSizeDefault,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            CustomButton(
              btnTxt: 'Create My First Group',
              onPressed: () => _showCreateGroupDialog(context, controller),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showJoinGroupDialog(controller),
              icon: Icon(Icons.vpn_key),
              label: Text('Join with Invite Code'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
*/
  // ─── Brand/Fan View ───────────────────────────

  Widget _buildBrandFanView(BuildContext context, GroupController controller) {
    return RefreshIndicator(
      onRefresh: () async => controller.refresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _SupportHeroBanner(controller: controller)),
          SliverToBoxAdapter(
            //  child: _BrandFanStatsStrip(controller: controller),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: Obx(() {
              if (controller.publicGroups.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          size: 72,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No Public Groups Yet',
                          style: robotoMedium.copyWith(color: Colors.grey[500]),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Athlete groups will appear here soon',
                          style: robotoRegular.copyWith(
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _BrandFanGroupCard(
                    group: controller.publicGroups[i],
                    controller: controller,
                  ),
                  childCount: controller.publicGroups.length,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Top-Level Dialog Functions ──────────────────────────────────────────────
// (Place these AFTER the closing brace of GroupsListScreen class,
//  BEFORE the _AthleteSummaryBanner class)

void _showCreateGroupDialog(BuildContext context, GroupController controller) {
  final isPublicObs = true.obs;
  final sports = List<SportModel>.from(controller.availableSports);
  SportModel? selectedSport = controller.selectedSport.value;

  Get.dialog(
    StatefulBuilder(
      builder: (ctx, setDialogState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.group_add,
                        color: Theme.of(ctx).primaryColor,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Group',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        Text(
                          'Build your athlete community',
                          style: robotoRegular.copyWith(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Cover picker
                Obx(
                  () => GestureDetector(
                    onTap: controller.pickImage,
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey[300]!),
                        image: controller.selectedImage.value != null
                            ? DecorationImage(
                                image: FileImage(
                                  controller.selectedImage.value!,
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: controller.selectedImage.value == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Colors.grey[400],
                                  size: 30,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Add Cover Photo (optional)',
                                  style: robotoRegular.copyWith(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 12),

                TextField(
                  controller: controller.groupNameController,
                  decoration: InputDecoration(
                    labelText: 'Group Name *',
                    prefixIcon: Icon(Icons.group),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: controller.groupDescriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Sport selector
                if (sports.isNotEmpty)
                  DropdownButtonFormField<SportModel>(
                    value: selectedSport,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Sport Type',
                      prefixIcon: Icon(Icons.sports),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: sports
                        .map(
                          (s) => DropdownMenuItem<SportModel>(
                            value: s,
                            child: Text('${s.icon ?? ''} ${s.name}'),
                          ),
                        )
                        .toList(),
                    onChanged: (s) {
                      setDialogState(() => selectedSport = s);
                      controller.selectedSport.value = s;
                    },
                  ),
                SizedBox(height: 10),

                // Visibility toggle
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPublicObs.value ? Icons.public : Icons.lock,
                            size: 16,
                            color: isPublicObs.value
                                ? Colors.green
                                : Colors.orange,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Visibility',
                            style: robotoMedium.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _VisibilityOption(
                            label: 'Public',
                            icon: Icons.public,
                            selected: isPublicObs.value,
                            selectedColor: Colors.green,
                            onTap: () =>
                                setDialogState(() => isPublicObs.value = true),
                          ),
                          SizedBox(width: 6),
                          _VisibilityOption(
                            label: 'Private',
                            icon: Icons.lock,
                            selected: !isPublicObs.value,
                            selectedColor: Colors.orange,
                            onTap: () =>
                                setDialogState(() => isPublicObs.value = false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.groupNameController.clear();
                          controller.groupDescriptionController.clear();
                          controller.clearSelectedMedia();
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            controller.createGroup(isPublic: isPublicObs.value),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

void _showJoinGroupDialog(GroupController controller) {
  Get.dialog(
    StatefulBuilder(
      builder: (ctx, setDialogState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.vpn_key,
                    size: 36,
                    color: Theme.of(ctx).primaryColor,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Join Group',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Enter the 6-character invite code',
                  style: robotoRegular.copyWith(color: Colors.grey[500]),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: controller.inviteCodeController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: robotoBold.copyWith(
                    fontSize: 26,
                    letterSpacing: 10,
                    color: Theme.of(ctx).primaryColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'A B C 1 2 3',
                    hintStyle: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 20,
                      letterSpacing: 4,
                    ),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.inviteCodeController.clear();
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final loading = controller.isLoading.value;
                        return loading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: controller.joinGroupByCode,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('Join'),
                              );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ─── Widget Classes Follow Below ──────────────────────────────────────────────
// (Your existing _AthleteSummaryBanner, _MyGroupsTab, etc.)

// ─── Athlete Summary Banner ───────────────────────

class _AthleteSummaryBanner extends StatelessWidget {
  final GroupController controller;
  const _AthleteSummaryBanner({required this.controller});

  // Number formatter for currency displays
  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalMembers = controller.myGroups.fold<int>(
        0,
        (s, g) => s + g.memberCount,
      );
      final totalRaised = controller.myGroups.fold<double>(
        0,
        (s, g) => s + g.totalDonations,
      );

      return Container(
        margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.72),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.32),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Groups',
                    style: robotoRegular.copyWith(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${controller.myGroups.length} Active',
                    style: robotoBold.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            _BannerStat(
              label: 'Members',
              value: '$totalMembers',
              icon: Icons.people,
            ),
            SizedBox(width: 16),
            _BannerStat(
              label: 'Raised',
              value: '${Currency.symbol}${_numberFormat.format(totalRaised)}',
              icon: Icons.attach_money,
            ),
          ],
        ),
      );
    });
  }
}

class _BannerStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _BannerStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        SizedBox(height: 2),
        Text(
          value,
          style: robotoBold.copyWith(color: Colors.white, fontSize: 16),
        ),
        Text(
          label,
          style: robotoRegular.copyWith(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }
}

// ─── Support Hero Banner ──────────────────────────

class _SupportHeroBanner extends StatelessWidget {
  final GroupController controller;
  const _SupportHeroBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: 155,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Color(0xFF045F25), Color(0xFF045F25)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1a237e).withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.volunteer_activism,
                      color: Colors.amber,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Support Athletes',
                      style: robotoRegular.copyWith(
                        color: Colors.amber,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Champion\nYour Favourites',
                  style: robotoBold.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Obx(
                  () => Text(
                    '${controller.publicGroups.length} groups to support',
                    style: robotoRegular.copyWith(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
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

// ─── Brand/Fan Stats Strip ────────────────────────

class _BrandFanStatsStrip extends StatelessWidget {
  final GroupController controller;
  const _BrandFanStatsStrip({required this.controller});

  // Number formatter for currency displays
  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalRaised = controller.publicGroups.fold<double>(
        0,
        (s, g) => s + g.totalDonations,
      );
      final totalAthletes = controller.publicGroups.fold<int>(
        0,
        (s, g) => s + g.memberCount,
      );

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            _StripStat(
              label: 'Groups',
              value: '${controller.publicGroups.length}',
              color: Colors.blue,
            ),
            SizedBox(width: 8),
            _StripStat(
              label: 'Athletes',
              value: '$totalAthletes',
              color: Colors.purple,
            ),
            SizedBox(width: 8),
            _StripStat(
              label: 'Raised',
              value: '${Currency.symbol}${_numberFormat.format(totalRaised)}',
              color: Colors.green,
            ),
          ],
        ),
      );
    });
  }
}

class _StripStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StripStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(value, style: robotoBold.copyWith(color: color, fontSize: 15)),
            Text(
              label,
              style: robotoRegular.copyWith(
                color: color.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Athlete Group Card ───────────────────────────
// ─── Athlete Group Card (Updated) ─────────────

class _AthleteGroupCard extends StatelessWidget {
  final GroupModel group;
  final GroupController controller;
  final bool isMember; // ← NEW: track membership status

  // Number formatter for currency displays
  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  const _AthleteGroupCard({
    required this.group,
    required this.controller,
    required this.isMember,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveCampaign = group.activeCampaignCount > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover with overlays
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                group.coverImage.isNotEmpty
                    ? Image.network(
                        group.coverImage,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _GroupCoverFallback(context: context),
                      )
                    : _GroupCoverFallback(context: context),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  child: _SportChip(sport: group.sport),
                ),
                Positioned(
                  top: 35,
                  left: 12,
                  child: _VisibilityChip(isPublic: group.isPublic),
                ),
                if (hasActiveCampaign)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: _ActiveCampaignBadge(
                      count: group.activeCampaignCount,
                    ),
                  ),
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Row(
                    children: [
                      Icon(Icons.people, size: 13, color: Colors.white70),
                      SizedBox(width: 4),
                      Text(
                        '${group.memberCount} members',
                        style: robotoRegular.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Text(
                    '${Currency.symbol}${_numberFormat.format(group.totalDonations)} raised',
                    style: robotoMedium.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (group.description.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    group.description,
                    style: robotoRegular.copyWith(
                      color: Colors.grey[600],
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (hasActiveCampaign) ...[
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.campaign, size: 13, color: Color(0xFF045F25)),
                      SizedBox(width: 4),
                      Text(
                        '${group.activeCampaignCount} active campaign${group.activeCampaignCount > 1 ? 's' : ''} running',
                        style: robotoRegular.copyWith(
                          color: Color(0xFF045F25),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 12),
                // ── Action buttons: always "Open Group", share available if member ──
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.loadGroupDetails(group.id);
                          Get.to(
                            () => GroupDetailScreen(
                              groupId: group.id,
                              group: group,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF045F25),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(isMember ? 'Open Group' : 'View Group'),
                      ),
                    ),
                    if (isMember) ...[
                      SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => controller.shareGroup(
                          group.id,
                          group.inviteCode,
                          group.name,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Icon(Icons.share, size: 18),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pending/Rejected Group Card ──────────────────

class _PendingGroupCard extends StatelessWidget {
  final GroupModel group;

  const _PendingGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final isPending = group.status == GroupStatus.pending;
    final color = isPending ? Colors.orange[700]! : Colors.red[700]!;
    final bgColor = isPending ? Colors.orange[50]! : Colors.red[50]!;
    final borderColor = isPending
        ? Colors.orange.withOpacity(0.3)
        : Colors.red.withOpacity(0.3);
    final icon = isPending
        ? Icons.hourglass_top_rounded
        : Icons.cancel_outlined;
    final statusLabel = isPending ? 'AWAITING APPROVAL' : 'NOT APPROVED';
    final statusMessage = isPending
        ? 'Your group is under review by AfriEndorse. You\'ll be notified once it\'s approved.'
        : 'Reason: ${group.rejectionReason ?? 'Not specified'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.name,
                        style: robotoBold.copyWith(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel,
                        style: robotoMedium.copyWith(
                          fontSize: 9,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  statusMessage,
                  style: robotoRegular.copyWith(
                    fontSize: 11,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.sports, size: 12, color: Colors.black38),
                    const SizedBox(width: 4),
                    Text(
                      group.sport,
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      group.isPublic ? Icons.public : Icons.lock,
                      size: 12,
                      color: Colors.black38,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      group.isPublic ? 'Public' : 'Private',
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: Colors.black45,
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
}

// ─── Brand/Fan Group Card ─────────────────────────

class _BrandFanGroupCard extends StatelessWidget {
  final GroupModel group;
  final GroupController controller;
  const _BrandFanGroupCard({required this.group, required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasActiveCampaign = group.activeCampaignCount > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cover
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                group.coverImage.isNotEmpty
                    ? Image.network(
                        group.coverImage,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _GroupCoverFallback(context: context),
                      )
                    : _GroupCoverFallback(context: context),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  child: _SportChip(sport: group.sport),
                ),
                // Active campaign badge — visible to donors so they know
                if (hasActiveCampaign)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: _ActiveCampaignBadge(
                      count: group.activeCampaignCount,
                    ),
                  ),
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Row(
                    children: [
                      Icon(Icons.people, size: 13, color: Colors.white70),
                      SizedBox(width: 3),
                      Text(
                        '${group.memberCount} members',
                        style: robotoRegular.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                /*  Positioned(
                  bottom: 10,
                  right: 12,
                  child: Row(
                    children: [
                      Icon(Icons.people, size: 13, color: Colors.white70),
                      SizedBox(width: 3),
                      Text(
                        '${group.memberCount}',
                        style: robotoRegular.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ), */
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.name,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (group.description.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    group.description,
                    style: robotoRegular.copyWith(
                      color: Colors.grey[600],
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                // Campaign callout for donors
                if (hasActiveCampaign) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF045F25).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFF045F25).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.campaign,
                          size: 13,
                          color: Color(0xFF045F25),
                        ),
                        SizedBox(width: 5),
                        Text(
                          '${group.activeCampaignCount} active campaign${group.activeCampaignCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Color(0xFF045F25),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.loadGroupDetails(group.id);
                          Get.to(
                            () => GroupDetailScreen(
                              groupId: group.id,
                              group: group,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('View'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            controller.showDonationDialog(group.id),
                        icon: Icon(Icons.favorite, size: 16),
                        label: Text('Donate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
}

// ─── My Groups Tab (Athlete's Joined Groups) ──

class _MyGroupsTab extends StatelessWidget {
  final GroupController controller;
  const _MyGroupsTab({required this.controller});

  // In _MyGroupsTab build():
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasActive = controller.myGroups.isNotEmpty;
      final hasPending = controller.pendingGroups.isNotEmpty;

      if (!hasActive && !hasPending) {
        return _buildAthleteEmptyState(context, controller);
      }

      return RefreshIndicator(
        onRefresh: () async => controller.refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Pending/Rejected groups (created but not yet approved) ──
            if (hasPending) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.pending_outlined,
                      size: 15,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Awaiting Approval',
                      style: robotoMedium.copyWith(
                        fontSize: 13,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
              ...controller.pendingGroups.map(
                (g) => _PendingGroupCard(group: g),
              ),
              const SizedBox(height: 8),
            ],

            // ── Active groups ──
            if (hasActive)
              ...controller.myGroups.map(
                (g) => _AthleteGroupCard(
                  group: g,
                  controller: controller,
                  isMember: true,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildAthleteEmptyState(
    BuildContext context,
    GroupController controller,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: Column(
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.15),
                    Theme.of(context).primaryColor.withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_outlined,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Start Your Community',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create a group for your fans and fellow athletes,\njoin via invite code, or discover public groups.',
              style: robotoRegular.copyWith(
                color: Colors.grey[600],
                fontSize: Dimensions.fontSizeDefault,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            CustomButton(
              btnTxt: 'Create My First Group',
              onPressed: () => _showCreateGroupDialog(context, controller),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showJoinGroupDialog(controller),
              icon: Icon(Icons.vpn_key),
              label: Text('Join with Invite Code'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Discover Groups Tab (Public Groups) ──────

class _DiscoverGroupsTab extends StatelessWidget {
  final GroupController controller;
  const _DiscoverGroupsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.publicGroups.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore_outlined, size: 64, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(
                'No Public Groups Yet',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Check back soon for athlete communities',
                style: robotoRegular.copyWith(color: Colors.grey[400]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => controller.refresh(),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.publicGroups.length,
          itemBuilder: (_, i) {
            final group = controller.publicGroups[i];
            // Check if athlete is already a member
            final isMember = controller.myGroups.any((g) => g.id == group.id);
            return _AthleteGroupCard(
              group: group,
              controller: controller,
              isMember: isMember,
            );
          },
        ),
      );
    });
  }
}

// ─── Shared Widgets ───────────────────────────────

class _VisibilityOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? selectedColor.withOpacity(0.5)
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: selected ? selectedColor : Colors.grey[400],
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: robotoRegular.copyWith(
                fontSize: 11,
                color: selected ? selectedColor : Colors.grey[500],
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveCampaignBadge extends StatelessWidget {
  final int count;
  const _ActiveCampaignBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFF045F25).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.campaign, size: 11, color: Colors.white),
          SizedBox(width: 4),
          Text(
            count == 1 ? 'Campaign Live' : '$count Campaigns Live',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCoverFallback extends StatelessWidget {
  final BuildContext context;
  const _GroupCoverFallback({required this.context});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.22),
            Theme.of(context).primaryColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.groups,
          size: 54,
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }
}

class _SportChip extends StatelessWidget {
  final String sport;
  const _SportChip({required this.sport});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        sport,
        style: robotoMedium.copyWith(color: Colors.white, fontSize: 10),
      ),
    );
  }
}

class _VisibilityChip extends StatelessWidget {
  final bool isPublic;
  const _VisibilityChip({required this.isPublic});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPublic
            ? Colors.green.withOpacity(0.85)
            : Colors.orange.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublic ? Icons.public : Icons.lock,
            size: 10,
            color: Colors.white,
          ),
          SizedBox(width: 3),
          Text(
            isPublic ? 'Public' : 'Private',
            style: robotoRegular.copyWith(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double radius;
  final double? width;
  const _ShimmerBox({required this.height, required this.radius, this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
