// ─── Home Groups Horizontal View ─────────────────────────────────────────────
// Place this after _FirestoreSportsCategories in home_screen.dart slivers list

// In your slivers list, add after the sports categories:
//
//   const SliverToBoxAdapter(
//     child: _FirestoreGroupsHorizontal(),
//   ),

import 'package:afriendorse/athlete/feature/groups/models/group_models.dart';
import 'package:afriendorse/athlete/feature/groups/screens/group_detail_screen.dart';
import 'package:afriendorse/athlete/feature/groups/screens/groups_list_screen.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class _FirestoreGroupsHorizontal extends StatelessWidget {
  const _FirestoreGroupsHorizontal();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Athlete Groups',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const GroupsListScreen()),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF045F25),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 185,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .where('isPublic', isEqualTo: true)
                .orderBy('memberCount', descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading groups'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (_, __) => Container(
                    width: 155,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                );
              }

              final groups = snapshot.data?.docs ?? [];

              if (groups.isEmpty) {
                return const Center(
                  child: Text(
                    'No groups yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: _HomeGroupCard(doc: groups[index]),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _HomeGroupCard extends StatelessWidget {
  final DocumentSnapshot doc;

  const _HomeGroupCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final groupId = doc.id;

    final name = data['name'] as String? ?? 'Unknown Group';
    final sport = data['sport'] as String? ?? '';
    final coverImage = data['coverImage'] as String? ?? '';
    final memberCount = (data['memberCount'] as num?)?.toInt() ?? 0;
    final totalDonations = (data['totalDonations'] as num?)?.toDouble() ?? 0.0;
    final activeCampaignCount =
        (data['activeCampaignCount'] as num?)?.toInt() ?? 0;
    final hasActiveCampaign = activeCampaignCount > 0;

    return GestureDetector(
      onTap: () {
        Get.to(
          () => GroupDetailScreen(
            groupId: groupId,
            group: GroupModel.fromDoc(doc),
          ),
        );
      },
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover image ──────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  // Cover or fallback
                  coverImage.isNotEmpty
                      ? Image.network(
                          coverImage,
                          height: 95,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _GroupCardCoverFallback(),
                        )
                      : const _GroupCardCoverFallback(),

                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Sport chip — top left
                  if (sport.isNotEmpty)
                    Positioned(
                      top: 7,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          sport,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // Campaign live badge — top right
                  if (hasActiveCampaign)
                    Positioned(
                      top: 7,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF045F25).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.campaign, size: 9, color: Colors.white),
                            SizedBox(width: 3),
                            Text(
                              'Live',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Member count — bottom left
                  Positioned(
                    bottom: 6,
                    left: 8,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 10,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$memberCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Info section ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 11,
                        color: Color(0xFF045F25),
                      ),
                      Text(
                        '${Currency.symbol}${totalDonations.toStringAsFixed(0)} raised',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF045F25),
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
    );
  }
}

class _GroupCardCoverFallback extends StatelessWidget {
  const _GroupCardCoverFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF045F25).withOpacity(0.25),
            const Color(0xFF045F25).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.groups,
          size: 38,
          color: const Color(0xFF045F25).withOpacity(0.35),
        ),
      ),
    );
  }
}

class _GroupsLoadingShimmer extends StatelessWidget {
  const _GroupsLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        width: 155,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
