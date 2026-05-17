// lib/athlete/feature/groups/screens/group_admin_screen.dart

/*
import 'package:afriendorse/athlete/feature/groups/repository/group_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/groups/controller/group_controller.dart';
import 'package:afriendorse/athlete/feature/groups/models/group_models.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _green = Color(0xFF045F25);
const _greenLight = Color(0xFFE8F5EE);
const _greenMid = Color(0xFF1A7A3C);
const _surface = Color(0xFFFAFAFA);
const _cardBg = Colors.white;
const _textPrimary = Color(0xFF0A0A0A);
const _textSecondary = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _amber = Color(0xFFF59E0B);
const _red = Color(0xFFDC2626);
const _redLight = Color(0xFFFEF2F2);

class GroupAdminScreen extends StatelessWidget {
  final String groupId;
  final String groupName;

  const GroupAdminScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _surface,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _AdminSliverAppBar(
              groupName: groupName,
              innerBoxIsScrolled: innerBoxIsScrolled,
            ),
          ],
          body: TabBarView(
            children: [
              _SettingsTab(controller: controller, groupId: groupId),
              _AdminMembersTab(controller: controller, groupId: groupId),
              _BannedTab(controller: controller, groupId: groupId),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sliver App Bar ───────────────────────────────────────────────────────────

class _AdminSliverAppBar extends StatelessWidget {
  final String groupName;
  final bool innerBoxIsScrolled;

  const _AdminSliverAppBar({
    required this.groupName,
    required this.innerBoxIsScrolled,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: _green,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_green, _greenMid],
            ),
          ),
          child: Stack(
            children: [
              // Subtle pattern overlay
              Positioned.fill(
                child: Opacity(
                  opacity: 0.04,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                        ),
                    itemBuilder: (_, __) => Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 60,
                left: 56,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'GROUP PANEL',
                        style: robotoMedium.copyWith(
                          fontSize: 9,
                          color: Colors.white70,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      groupName,
                      style: robotoBold.copyWith(
                        fontSize: 22,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: _green,
          child: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: robotoMedium.copyWith(fontSize: 12),
            tabs: const [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune_rounded, size: 15),
                    SizedBox(width: 6),
                    Text('Settings'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_alt_rounded, size: 15),
                    SizedBox(width: 6),
                    Text('Members'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.block_rounded, size: 15),
                    SizedBox(width: 6),
                    Text('Banned'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Settings Tab ─────────────────────────────────────────────────────────────

class _SettingsTab extends StatefulWidget {
  final GroupController controller;
  final String groupId;

  const _SettingsTab({required this.controller, required this.groupId});

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.controller.currentGroup.value?.isPublic ?? true;
    widget.controller.editGroupNameController.text =
        widget.controller.currentGroup.value?.name ?? '';
    widget.controller.editGroupDescController.text =
        widget.controller.currentGroup.value?.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section label
          _SectionLabel(icon: Icons.edit_rounded, label: 'Edit Group Info'),
          const SizedBox(height: 16),

          // ── Cover Image
          GestureDetector(
            onTap: controller.pickImage,
            child: Obx(() {
              final group = controller.currentGroup.value;
              final hasImage =
                  controller.selectedImage.value != null ||
                  (group?.coverImage.isNotEmpty ?? false);

              return Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: _greenLight,
                  border: Border.all(
                    color: hasImage
                        ? Colors.transparent
                        : _green.withOpacity(0.2),
                    width: 1.5,
                  ),
                  image: controller.selectedImage.value != null
                      ? DecorationImage(
                          image: FileImage(controller.selectedImage.value!),
                          fit: BoxFit.cover,
                        )
                      : (group?.coverImage.isNotEmpty == true
                            ? DecorationImage(
                                image: NetworkImage(group!.coverImage),
                                fit: BoxFit.cover,
                              )
                            : null),
                ),
                child: hasImage
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: const Center(child: _EditOverlayBadge()),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_rounded,
                              color: _green,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload Cover Photo',
                            style: robotoMedium.copyWith(
                              color: _green,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Recommended: 1200 × 400px',
                            style: robotoRegular.copyWith(
                              color: _textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // ── Name field
          _StyledTextField(
            controller: controller.editGroupNameController,
            label: 'Group / Club Name',
            icon: Icons.group_rounded,
          ),
          const SizedBox(height: 14),

          // ── Description field
          _StyledTextField(
            controller: controller.editGroupDescController,
            label: 'Description',
            icon: Icons.notes_rounded,
            maxLines: 3,
            alignLabelWithHint: true,
          ),

          const SizedBox(height: 20),

          // ── Visibility
          _SectionLabel(icon: Icons.visibility_rounded, label: 'Visibility'),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _VisibilityOption(
                  label: 'Public',
                  description: 'Anyone can join',
                  icon: Icons.public_rounded,
                  selected: _isPublic,
                  onTap: () => setState(() => _isPublic = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VisibilityOption(
                  label: 'Private',
                  description: 'Invite only',
                  icon: Icons.lock_rounded,
                  selected: !_isPublic,
                  onTap: () => setState(() => _isPublic = false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Save button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: controller.isLoading.value
                  ? Container(
                      decoration: BoxDecoration(
                        color: _greenLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: _green,
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => controller.updateGroup(
                        groupId: widget.groupId,
                        isPublic: _isPublic,
                      ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(
                        'Save Changes',
                        style: robotoBold.copyWith(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 36),

          //  const SizedBox(height: 20),

          // ── Transfer Ownership ────────────────────────
          _SectionLabel(
            icon: Icons.transfer_within_a_station_rounded,
            label: 'Ownership',
            color: Colors.black,
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _amber.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: _amber,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Transfer Ownership',
                      style: robotoBold.copyWith(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Hand over admin control to another athlete. You will become a regular member.',
                  style: robotoRegular.copyWith(
                    color: Colors.black.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        controller.initiateOwnershipTransfer(widget.groupId),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: Text(
                      'Transfer to Another Athlete',
                      style: robotoMedium.copyWith(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: _amber),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          // (Danger Zone section follows below as before)

          // ── Danger Zone
          _SectionLabel(
            icon: Icons.warning_amber_rounded,
            label: 'Danger Zone',
            color: _red,
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _redLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _red.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: _red,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Delete Group',
                      style: robotoBold.copyWith(color: _red, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Permanently deletes the group, all posts, and member data. This action cannot be undone.',
                  style: robotoRegular.copyWith(
                    color: _red.withOpacity(0.75),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => controller.deleteGroup(widget.groupId),
                    icon: const Icon(Icons.delete_forever_rounded, size: 16),
                    label: Text(
                      'Delete Group Permanently',
                      style: robotoMedium.copyWith(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: const BorderSide(color: _red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

// ─── Admin Members Tab ────────────────────────────────────────────────────────

class _AdminMembersTab extends StatelessWidget {
  final GroupController controller;
  final String groupId;

  const _AdminMembersTab({required this.controller, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final members = controller.groupMembers;

      if (members.isEmpty) {
        return _EmptyTabState(
          icon: Icons.people_alt_rounded,
          message: 'No members yet',
          subMessage: 'Members will appear here once they join.',
        );
      }

      // Separate admins and regular members
      final admins = members.where((m) => m.isAdmin).toList();
      final regular = members.where((m) => !m.isAdmin).toList();

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          if (admins.isNotEmpty) ...[
            _SectionLabel(
              icon: Icons.star_rounded,
              label: 'Admin',
              color: _amber,
            ),
            const SizedBox(height: 12),
            ...admins.map(
              (m) => _MemberCard(
                member: m,
                groupId: groupId,
                controller: controller,
                isAdmin: true,
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (regular.isNotEmpty) ...[
            _SectionLabel(icon: Icons.people_rounded, label: 'Members'),
            const SizedBox(height: 12),
            ...regular.map(
              (m) => _MemberCard(
                member: m,
                groupId: groupId,
                controller: controller,
                isAdmin: false,
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _MemberCard extends StatelessWidget {
  final MemberModel member;
  final String groupId;
  final GroupController controller;
  final bool isAdmin;

  const _MemberCard({
    required this.member,
    required this.groupId,
    required this.controller,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = member.id == controller.currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isAdmin ? _amber.withOpacity(0.3) : _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAdmin
                    ? [_amber, const Color(0xFFF97316)]
                    : [_green, _greenMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                member.firstName.isNotEmpty
                    ? member.firstName[0].toUpperCase()
                    : '?',
                style: robotoBold.copyWith(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.fullName,
                        style: robotoBold.copyWith(
                          fontSize: 13,
                          color: _textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _greenLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'You',
                          style: robotoMedium.copyWith(
                            fontSize: 9,
                            color: _green,
                          ),
                        ),
                      ),
                    ],
                    if (isAdmin) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.star_rounded, size: 13, color: _amber),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  member.userType.toUpperCase(),
                  style: robotoRegular.copyWith(
                    fontSize: 10,
                    color: _textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Replace the existing "Actions" comment section with:
          // Actions
          if (!isMe && !isAdmin)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Moderator toggle ──
                _ActionIconButton(
                  icon: member.isModerator
                      ? Icons.remove_moderator_rounded
                      : Icons.shield_outlined,
                  color: member.isModerator ? const Color(0xFFEA580C) : _green,
                  bgColor: member.isModerator
                      ? const Color(0xFFFFF7ED)
                      : _greenLight,
                  tooltip: member.isModerator
                      ? 'Remove Moderator'
                      : 'Make Moderator',
                  onTap: () => controller.toggleModerator(groupId, member),
                ),
                const SizedBox(width: 8),
                _ActionIconButton(
                  icon: Icons.person_remove_rounded,
                  color: const Color(0xFFEA580C),
                  bgColor: const Color(0xFFFFF7ED),
                  tooltip: 'Remove',
                  onTap: () => controller.removeMember(groupId, member),
                ),
                const SizedBox(width: 8),
                _ActionIconButton(
                  icon: Icons.block_rounded,
                  color: _red,
                  bgColor: _redLight,
                  tooltip: 'Ban',
                  onTap: () => controller.banMember(groupId, member),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Banned Tab ───────────────────────────────────────────────────────────────

class _BannedTab extends StatefulWidget {
  final GroupController controller;
  final String groupId;

  const _BannedTab({required this.controller, required this.groupId});

  @override
  State<_BannedTab> createState() => _BannedTabState();
}

class _BannedTabState extends State<_BannedTab> {
  @override
  void initState() {
    super.initState();
    GroupFirestoreService.getBannedMembers(widget.groupId).listen((snap) {
      widget.controller.bannedMembers.value = snap.docs
          .map((d) => MemberModel.fromDoc(d))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final banned = widget.controller.bannedMembers;

      if (banned.isEmpty) {
        return _EmptyTabState(
          icon: Icons.verified_user_rounded,
          iconColor: _green,
          message: 'No Banned Members',
          subMessage: 'All members are in good standing.',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        itemCount: banned.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SectionLabel(
                icon: Icons.block_rounded,
                label:
                    '${banned.length} Banned ${banned.length == 1 ? 'Member' : 'Members'}',
                color: _red,
              ),
            );
          }

          final member = banned[index - 1];
          return _BannedCard(
            member: member,
            groupId: widget.groupId,
            controller: widget.controller,
          );
        },
      );
    });
  }
}

class _BannedCard extends StatelessWidget {
  final MemberModel member;
  final String groupId;
  final GroupController controller;

  const _BannedCard({
    required this.member,
    required this.groupId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _redLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.block_rounded, color: _red, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: robotoBold.copyWith(fontSize: 13, color: _textPrimary),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'BANNED',
                    style: robotoMedium.copyWith(
                      fontSize: 9,
                      color: _red,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final success = await GroupFirestoreService.unbanMember(
                groupId: groupId,
                adminId: controller.currentUserId,
                memberId: member.id,
              );
              if (success) {
                showCustomSnackBar(
                  'Member unbanned',
                  type: ToasterMessageType.success,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _green.withOpacity(0.3)),
              ),
              child: Text(
                'Unban',
                style: robotoMedium.copyWith(fontSize: 12, color: _green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _SectionLabel({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? _textPrimary;
    return Row(
      children: [
        Icon(icon, size: 15, color: c),
        const SizedBox(width: 6),
        Text(
          label,
          style: robotoBold.copyWith(
            fontSize: 13,
            color: c,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final bool alignLabelWithHint;

  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.alignLabelWithHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: robotoRegular.copyWith(fontSize: 14, color: _textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: robotoRegular.copyWith(fontSize: 13, color: _textSecondary),
        prefixIcon: Icon(icon, size: 18, color: _textSecondary),
        alignLabelWithHint: alignLabelWithHint,
        filled: true,
        fillColor: _cardBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _green, width: 1.5),
        ),
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _greenLight : _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _green : _border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: selected ? _green : _textSecondary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: robotoBold.copyWith(
                    fontSize: 13,
                    color: selected ? _green : _textPrimary,
                  ),
                ),
                const Spacer(),
                if (selected)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: robotoRegular.copyWith(
                fontSize: 11,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _EditOverlayBadge extends StatelessWidget {
  const _EditOverlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white38),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            'Change Photo',
            style: robotoMedium.copyWith(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String message;
  final String subMessage;

  const _EmptyTabState({
    required this.icon,
    required this.message,
    required this.subMessage,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (iconColor ?? _textSecondary).withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                size: 36,
                color: (iconColor ?? _textSecondary).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: robotoBold.copyWith(fontSize: 15, color: _textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              subMessage,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: 13,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// lib/athlete/feature/groups/screens/group_admin_screen.dart

import 'package:afriendorse/athlete/feature/groups/repository/group_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/groups/controller/group_controller.dart';
import 'package:afriendorse/athlete/feature/groups/models/group_models.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:timeago/timeago.dart' as timeago;

// ─── Design tokens ────────────────────────────────────────────────────────────
const _green = Color(0xFF045F25);
const _greenLight = Color(0xFFE8F5EE);
const _greenMid = Color(0xFF1A7A3C);
const _surface = Color(0xFFFAFAFA);
const _cardBg = Colors.white;
const _textPrimary = Color(0xFF0A0A0A);
const _textSecondary = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _amber = Color(0xFFF59E0B);
const _red = Color(0xFFDC2626);
const _redLight = Color(0xFFFEF2F2);
const _blue = Color(0xFF2563EB);
const _blueLight = Color(0xFFEFF6FF);

class GroupAdminScreen extends StatelessWidget {
  final String groupId;
  final String groupName;

  const GroupAdminScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupController>();

    // Load join requests when screen opens
    controller.loadJoinRequests(groupId);

    return DefaultTabController(
      length: 4, // Settings | Members | Requests | Banned
      child: Scaffold(
        backgroundColor: _surface,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _AdminSliverAppBar(
              groupName: groupName,
              innerBoxIsScrolled: innerBoxIsScrolled,
            ),
          ],
          body: TabBarView(
            children: [
              _SettingsTab(controller: controller, groupId: groupId),
              _AdminMembersTab(controller: controller, groupId: groupId),
              _RequestsTab(controller: controller, groupId: groupId),
              _BannedTab(controller: controller, groupId: groupId),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sliver App Bar ───────────────────────────────────────────────────────────

class _AdminSliverAppBar extends StatelessWidget {
  final String groupName;
  final bool innerBoxIsScrolled;

  const _AdminSliverAppBar({
    required this.groupName,
    required this.innerBoxIsScrolled,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: _green,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_green, _greenMid],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.04,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                        ),
                    itemBuilder: (_, __) => Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 56,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'GROUP PANEL',
                        style: robotoMedium.copyWith(
                          fontSize: 9,
                          color: Colors.white70,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      groupName,
                      style: robotoBold.copyWith(
                        fontSize: 22,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: _green,
          child: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: robotoMedium.copyWith(fontSize: 11),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune_rounded, size: 14),
                    SizedBox(width: 5),
                    Text('Settings'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_alt_rounded, size: 14),
                    SizedBox(width: 5),
                    Text('Members'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pending_actions_rounded, size: 14),
                    SizedBox(width: 5),
                    Text('Requests'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.block_rounded, size: 14),
                    SizedBox(width: 5),
                    Text('Banned'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Settings Tab ─────────────────────────────────────────────────────────────

class _SettingsTab extends StatefulWidget {
  final GroupController controller;
  final String groupId;

  const _SettingsTab({required this.controller, required this.groupId});

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  late bool _isPublic;
  late bool _requiresApproval;

  @override
  void initState() {
    super.initState();
    final group = widget.controller.currentGroup.value;
    _isPublic = group?.isPublic ?? true;
    _requiresApproval = group?.requiresApproval ?? true;
    widget.controller.editGroupNameController.text = group?.name ?? '';
    widget.controller.editGroupDescController.text = group?.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section label
          _SectionLabel(icon: Icons.edit_rounded, label: 'Edit Group Info'),
          const SizedBox(height: 16),

          // ── Cover Image
          GestureDetector(
            onTap: controller.pickImage,
            child: Obx(() {
              final group = controller.currentGroup.value;
              final hasImage =
                  controller.selectedImage.value != null ||
                  (group?.coverImage.isNotEmpty ?? false);

              return Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: _greenLight,
                  border: Border.all(
                    color: hasImage
                        ? Colors.transparent
                        : _green.withOpacity(0.2),
                    width: 1.5,
                  ),
                  image: controller.selectedImage.value != null
                      ? DecorationImage(
                          image: FileImage(controller.selectedImage.value!),
                          fit: BoxFit.cover,
                        )
                      : (group?.coverImage.isNotEmpty == true
                            ? DecorationImage(
                                image: NetworkImage(group!.coverImage),
                                fit: BoxFit.cover,
                              )
                            : null),
                ),
                child: hasImage
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: const Center(child: _EditOverlayBadge()),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_rounded,
                              color: _green,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload Cover Photo',
                            style: robotoMedium.copyWith(
                              color: _green,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Recommended: 1200 × 400px',
                            style: robotoRegular.copyWith(
                              color: _textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
              );
            }),
          ),

          const SizedBox(height: 20),

          _StyledTextField(
            controller: controller.editGroupNameController,
            label: 'Group / Club Name',
            icon: Icons.group_rounded,
          ),
          const SizedBox(height: 14),

          _StyledTextField(
            controller: controller.editGroupDescController,
            label: 'Description',
            icon: Icons.notes_rounded,
            maxLines: 3,
            alignLabelWithHint: true,
          ),

          const SizedBox(height: 20),

          // ── Visibility
          _SectionLabel(icon: Icons.visibility_rounded, label: 'Visibility'),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _VisibilityOption(
                  label: 'Public',
                  description: 'Anyone can discover',
                  icon: Icons.public_rounded,
                  selected: _isPublic,
                  onTap: () => setState(() => _isPublic = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VisibilityOption(
                  label: 'Private',
                  description: 'Invite only',
                  icon: Icons.lock_rounded,
                  selected: !_isPublic,
                  onTap: () => setState(() => _isPublic = false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Member Approval Toggle ────────────────────────────────────────
          _SectionLabel(
            icon: Icons.how_to_reg_rounded,
            label: 'Member Approval',
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _requiresApproval
                        ? _green.withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.how_to_reg_rounded,
                    size: 20,
                    color: _requiresApproval ? _green : _textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Require Approval to Join',
                        style: robotoBold.copyWith(
                          fontSize: 13,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _requiresApproval
                            ? 'New members must be approved by admin or moderator'
                            : 'Anyone can join directly without approval',
                        style: robotoRegular.copyWith(
                          fontSize: 11,
                          color: _textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _requiresApproval,
                  onChanged: (val) => setState(() => _requiresApproval = val),
                  activeColor: _green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Save button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: controller.isLoading.value
                  ? Container(
                      decoration: BoxDecoration(
                        color: _greenLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: _green,
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => controller.updateGroup(
                        groupId: widget.groupId,
                        isPublic: _isPublic,
                        requiresApproval: _requiresApproval,
                      ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(
                        'Save Changes',
                        style: robotoBold.copyWith(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 36),

          // ── Transfer Ownership
          _SectionLabel(
            icon: Icons.transfer_within_a_station_rounded,
            label: 'Ownership',
            color: Colors.black,
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _amber.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: _amber,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Transfer Ownership',
                      style: robotoBold.copyWith(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Hand over admin control to another athlete. You will become a regular member.',
                  style: robotoRegular.copyWith(
                    color: Colors.black.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        controller.initiateOwnershipTransfer(widget.groupId),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: Text(
                      'Transfer to Another Athlete',
                      style: robotoMedium.copyWith(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: _amber),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Danger Zone
          _SectionLabel(
            icon: Icons.warning_amber_rounded,
            label: 'Danger Zone',
            color: _red,
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _redLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _red.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: _red,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Delete Group',
                      style: robotoBold.copyWith(color: _red, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Permanently deletes the group, all posts, and member data. This action cannot be undone.',
                  style: robotoRegular.copyWith(
                    color: _red.withOpacity(0.75),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => controller.deleteGroup(widget.groupId),
                    icon: const Icon(Icons.delete_forever_rounded, size: 16),
                    label: Text(
                      'Delete Group Permanently',
                      style: robotoMedium.copyWith(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: const BorderSide(color: _red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

// ─── Admin Members Tab ────────────────────────────────────────────────────────

class _AdminMembersTab extends StatelessWidget {
  final GroupController controller;
  final String groupId;

  const _AdminMembersTab({required this.controller, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final members = controller.groupMembers;

      return Column(
        children: [
          // ── Add by Email button (admin only) ─────────────────────────────
          if (controller.isCurrentUserAdmin.value)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.showAddByEmailDialog(groupId),
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: Text(
                    'Add Member by Email',
                    style: robotoBold.copyWith(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

          // ── Members list ─────────────────────────────────────────────────
          Expanded(
            child: members.isEmpty
                ? _EmptyTabState(
                    icon: Icons.people_alt_rounded,
                    message: 'No members yet',
                    subMessage: 'Members will appear here once they join.',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    children: [
                      // Admins
                      ...() {
                        final admins = members.where((m) => m.isAdmin).toList();
                        if (admins.isEmpty) return <Widget>[];
                        return [
                          _SectionLabel(
                            icon: Icons.star_rounded,
                            label: 'Admin',
                            color: _amber,
                          ),
                          const SizedBox(height: 12),
                          ...admins.map(
                            (m) => _MemberCard(
                              member: m,
                              groupId: groupId,
                              controller: controller,
                              isAdmin: true,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ];
                      }(),
                      // Moderators
                      ...() {
                        final mods = members
                            .where((m) => m.isModerator && !m.isAdmin)
                            .toList();
                        if (mods.isEmpty) return <Widget>[];
                        return [
                          _SectionLabel(
                            icon: Icons.shield_outlined,
                            label: 'Moderators',
                            color: _blue,
                          ),
                          const SizedBox(height: 12),
                          ...mods.map(
                            (m) => _MemberCard(
                              member: m,
                              groupId: groupId,
                              controller: controller,
                              isAdmin: false,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ];
                      }(),
                      // Regular members
                      ...() {
                        final regular = members
                            .where((m) => !m.isAdmin && !m.isModerator)
                            .toList();
                        if (regular.isEmpty) return <Widget>[];
                        return [
                          _SectionLabel(
                            icon: Icons.people_rounded,
                            label: 'Members',
                          ),
                          const SizedBox(height: 12),
                          ...regular.map(
                            (m) => _MemberCard(
                              member: m,
                              groupId: groupId,
                              controller: controller,
                              isAdmin: false,
                            ),
                          ),
                        ];
                      }(),
                    ],
                  ),
          ),
        ],
      );
    });
  }
}

class _MemberCard extends StatelessWidget {
  final MemberModel member;
  final String groupId;
  final GroupController controller;
  final bool isAdmin;

  const _MemberCard({
    required this.member,
    required this.groupId,
    required this.controller,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = member.id == controller.currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAdmin
              ? _amber.withOpacity(0.3)
              : member.isModerator
              ? _blue.withOpacity(0.3)
              : _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAdmin
                    ? [_amber, const Color(0xFFF97316)]
                    : member.isModerator
                    ? [_blue, const Color(0xFF1D4ED8)]
                    : [_green, _greenMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                member.firstName.isNotEmpty
                    ? member.firstName[0].toUpperCase()
                    : '?',
                style: robotoBold.copyWith(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.fullName,
                        style: robotoBold.copyWith(
                          fontSize: 13,
                          color: _textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _greenLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'You',
                          style: robotoMedium.copyWith(
                            fontSize: 9,
                            color: _green,
                          ),
                        ),
                      ),
                    ],
                    if (isAdmin) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.star_rounded, size: 13, color: _amber),
                    ],
                    if (member.isModerator && !isAdmin) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.shield_outlined, size: 13, color: _blue),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      member.userType.toUpperCase(),
                      style: robotoRegular.copyWith(
                        fontSize: 10,
                        color: _textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (member.addedBy != null && member.addedBy != 'self') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          member.addedBy == 'platform'
                              ? 'Added by AfriEndorse'
                              : member.addedBy == 'approved'
                              ? 'Approved'
                              : 'Added by admin',
                          style: robotoRegular.copyWith(
                            fontSize: 9,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions (only for non-self, non-admin members)
          if (!isMe && !isAdmin)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionIconButton(
                  icon: member.isModerator
                      ? Icons.remove_moderator_rounded
                      : Icons.shield_outlined,
                  color: member.isModerator ? const Color(0xFFEA580C) : _green,
                  bgColor: member.isModerator
                      ? const Color(0xFFFFF7ED)
                      : _greenLight,
                  tooltip: member.isModerator
                      ? 'Remove Moderator'
                      : 'Make Moderator',
                  onTap: () => controller.toggleModerator(groupId, member),
                ),
                const SizedBox(width: 8),
                _ActionIconButton(
                  icon: Icons.person_remove_rounded,
                  color: const Color(0xFFEA580C),
                  bgColor: const Color(0xFFFFF7ED),
                  tooltip: 'Remove',
                  onTap: () => controller.removeMember(groupId, member),
                ),
                const SizedBox(width: 8),
                _ActionIconButton(
                  icon: Icons.block_rounded,
                  color: _red,
                  bgColor: _redLight,
                  tooltip: 'Ban',
                  onTap: () => controller.banMember(groupId, member),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Requests Tab ─────────────────────────────────────────────────────────────

class _RequestsTab extends StatelessWidget {
  final GroupController controller;
  final String groupId;

  const _RequestsTab({required this.controller, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final requests = controller.joinRequests;

      if (requests.isEmpty) {
        return _EmptyTabState(
          icon: Icons.how_to_reg_rounded,
          iconColor: _green,
          message: 'No Pending Requests',
          subMessage: 'New join requests will appear here.',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        itemCount: requests.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SectionLabel(
                icon: Icons.pending_actions_rounded,
                label:
                    '${requests.length} Pending '
                    '${requests.length == 1 ? 'Request' : 'Requests'}',
                color: _blue,
              ),
            );
          }
          return _JoinRequestCard(
            request: requests[index - 1],
            groupId: groupId,
            controller: controller,
          );
        },
      );
    });
  }
}

class _JoinRequestCard extends StatelessWidget {
  final JoinRequestModel request;
  final String groupId;
  final GroupController controller;

  const _JoinRequestCard({
    required this.request,
    required this.groupId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _blue.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: request.userType == 'athlete'
                          ? [_green, _greenMid]
                          : request.userType == 'brand'
                          ? [const Color(0xFF7C3AED), const Color(0xFF5B21B6)]
                          : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      request.avatarUrl != null && request.avatarUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            request.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _avatarInitial(),
                          ),
                        )
                      : _avatarInitial(),
                ),
                const SizedBox(width: 12),

                // Name + type + time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.fullName.isNotEmpty
                            ? request.fullName
                            : request.email,
                        style: robotoBold.copyWith(
                          fontSize: 14,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _UserTypeBadge(userType: request.userType),
                          const SizedBox(width: 8),
                          Text(
                            timeago.format(request.requestedAt),
                            style: robotoRegular.copyWith(
                              fontSize: 11,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Details ──────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: request.email,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'User Type',
                  value: request.userType.toUpperCase(),
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Requested',
                  value: _formatDate(request.requestedAt),
                ),
              ],
            ),
          ),

          // ── Actions ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                // Reject
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.rejectJoinRequest(
                      groupId: groupId,
                      requestId: request.id,
                      requesterName: request.fullName.isNotEmpty
                          ? request.fullName
                          : request.email,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: BorderSide(color: _red.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Approve
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.approveJoinRequest(
                      groupId: groupId,
                      requestId: request.id,
                      requesterName: request.fullName.isNotEmpty
                          ? request.fullName
                          : request.email,
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  Widget _avatarInitial() {
    return Center(
      child: Text(
        request.firstName.isNotEmpty
            ? request.firstName[0].toUpperCase()
            : request.email.isNotEmpty
            ? request.email[0].toUpperCase()
            : '?',
        style: robotoBold.copyWith(color: Colors.white, fontSize: 18),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} at '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: robotoRegular.copyWith(fontSize: 11, color: _textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: robotoMedium.copyWith(fontSize: 11, color: _textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _UserTypeBadge extends StatelessWidget {
  final String userType;
  const _UserTypeBadge({required this.userType});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (userType.toLowerCase()) {
      case 'athlete':
        color = _green;
        break;
      case 'brand':
        color = const Color(0xFF7C3AED);
        break;
      default:
        color = _amber;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        userType.toUpperCase(),
        style: robotoMedium.copyWith(
          fontSize: 9,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Banned Tab ───────────────────────────────────────────────────────────────

class _BannedTab extends StatefulWidget {
  final GroupController controller;
  final String groupId;

  const _BannedTab({required this.controller, required this.groupId});

  @override
  State<_BannedTab> createState() => _BannedTabState();
}

class _BannedTabState extends State<_BannedTab> {
  @override
  void initState() {
    super.initState();
    GroupFirestoreService.getBannedMembers(widget.groupId).listen((snap) {
      widget.controller.bannedMembers.value = snap.docs
          .map((d) => MemberModel.fromDoc(d))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final banned = widget.controller.bannedMembers;

      if (banned.isEmpty) {
        return _EmptyTabState(
          icon: Icons.verified_user_rounded,
          iconColor: _green,
          message: 'No Banned Members',
          subMessage: 'All members are in good standing.',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        itemCount: banned.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SectionLabel(
                icon: Icons.block_rounded,
                label:
                    '${banned.length} Banned '
                    '${banned.length == 1 ? 'Member' : 'Members'}',
                color: _red,
              ),
            );
          }

          final member = banned[index - 1];
          return _BannedCard(
            member: member,
            groupId: widget.groupId,
            controller: widget.controller,
          );
        },
      );
    });
  }
}

class _BannedCard extends StatelessWidget {
  final MemberModel member;
  final String groupId;
  final GroupController controller;

  const _BannedCard({
    required this.member,
    required this.groupId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _redLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.block_rounded, color: _red, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: robotoBold.copyWith(fontSize: 13, color: _textPrimary),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'BANNED',
                    style: robotoMedium.copyWith(
                      fontSize: 9,
                      color: _red,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final success = await GroupFirestoreService.unbanMember(
                groupId: groupId,
                adminId: controller.currentUserId,
                memberId: member.id,
              );
              if (success) {
                showCustomSnackBar(
                  'Member unbanned',
                  type: ToasterMessageType.success,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _green.withOpacity(0.3)),
              ),
              child: Text(
                'Unban',
                style: robotoMedium.copyWith(fontSize: 12, color: _green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _SectionLabel({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? _textPrimary;
    return Row(
      children: [
        Icon(icon, size: 15, color: c),
        const SizedBox(width: 6),
        Text(
          label,
          style: robotoBold.copyWith(
            fontSize: 13,
            color: c,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final bool alignLabelWithHint;

  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.alignLabelWithHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: robotoRegular.copyWith(fontSize: 14, color: _textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: robotoRegular.copyWith(fontSize: 13, color: _textSecondary),
        prefixIcon: Icon(icon, size: 18, color: _textSecondary),
        alignLabelWithHint: alignLabelWithHint,
        filled: true,
        fillColor: _cardBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _green, width: 1.5),
        ),
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _greenLight : _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _green : _border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: selected ? _green : _textSecondary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: robotoBold.copyWith(
                    fontSize: 13,
                    color: selected ? _green : _textPrimary,
                  ),
                ),
                const Spacer(),
                if (selected)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: robotoRegular.copyWith(
                fontSize: 11,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _EditOverlayBadge extends StatelessWidget {
  const _EditOverlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white38),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            'Change Photo',
            style: robotoMedium.copyWith(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String message;
  final String subMessage;

  const _EmptyTabState({
    required this.icon,
    required this.message,
    required this.subMessage,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (iconColor ?? _textSecondary).withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                size: 36,
                color: (iconColor ?? _textSecondary).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: robotoBold.copyWith(fontSize: 15, color: _textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              subMessage,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: 13,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
