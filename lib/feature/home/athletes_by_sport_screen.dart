import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/feature/favorite/controller/provider_favorite_state_controller.dart';
import 'package:afriendorse/feature/favorite/widget/sql_favorite_icon_button.dart';

class AthletesBySportScreen extends StatefulWidget {
  final String sportId;
  final String sportName;

  const AthletesBySportScreen({
    super.key,
    required this.sportId,
    required this.sportName,
  });

  @override
  State<AthletesBySportScreen> createState() => _AthletesBySportScreenState();
}

class _AthletesBySportScreenState extends State<AthletesBySportScreen> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ProviderFavoriteStateController>()) {
      Get.put(
        ProviderFavoriteStateController(
          myFavoriteRepo: Get.find<MyFavoriteRepo>(),
        ),
        permanent: true,
      );
    }
    Get.find<ProviderFavoriteStateController>().loadFavorites(reload: true);
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('athletes')
        .where('isActive', isEqualTo: true)
        .where('fieldOfSport', isEqualTo: widget.sportId)
        .where('hasMysqlAthleteId', isEqualTo: true)
        .orderBy('updatedAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text(widget.sportName), centerTitle: false),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load athletes.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _AthleteListShimmer();
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No athletes found for ${widget.sportName}.',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeExtraLarge,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final mysqlId = (data['mysqlAthleteId'] ?? '').toString();
              if (mysqlId.isEmpty) return const SizedBox();

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeDefault,
                ),
                child: _AthleteCardShell(
                  providerId: mysqlId,
                  athleteData: data,
                  onTap: () =>
                      Get.toNamed(RouteHelper.getProviderDetails(mysqlId)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Shell: resolves athlete_profiles doc ─────────────────────────────────────
class _AthleteCardShell extends StatelessWidget {
  final String providerId;
  final Map<String, dynamic> athleteData;
  final VoidCallback onTap;

  const _AthleteCardShell({
    required this.providerId,
    required this.athleteData,
    required this.onTap,
  });

  /// Tries multiple possible email field names in the athletes doc
  DocumentReference<Map<String, dynamic>>? _profileRef() {
    // Try flat field first, then nested owner map
    final email = [
      (athleteData['ownerEmail'] ?? '').toString().trim(),
      (athleteData['email'] ?? '').toString().trim(),
      ((athleteData['owner'] is Map)
                  ? (athleteData['owner'] as Map)['email']
                  : null)
              ?.toString()
              .trim() ??
          '',
    ].firstWhere((e) => e.isNotEmpty, orElse: () => '');

    if (email.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('athlete_profiles')
        .doc(email.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final ref = _profileRef();
    if (ref == null) {
      return _AthleteNilCard(
        providerId: providerId,
        athleteData: athleteData,
        profileData: null,
        onTap: onTap,
      );
    }
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ref.snapshots(),
      builder: (context, snap) => _AthleteNilCard(
        providerId: providerId,
        athleteData: athleteData,
        profileData: snap.data?.data(),
        onTap: onTap,
      ),
    );
  }
}

// ─── Glass pill overlay ───────────────────────────────────────────────────────
class _GlassPill extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _GlassPill({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: IconTheme.merge(
              data: const IconThemeData(color: Colors.white),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── NIL Marketplace Card (FULL COVER IMAGE, no circular avatar) ──────────────
class _AthleteNilCard extends StatelessWidget {
  final String providerId;
  final Map<String, dynamic> athleteData;
  final Map<String, dynamic>? profileData;
  final VoidCallback onTap;

  const _AthleteNilCard({
    required this.providerId,
    required this.athleteData,
    required this.profileData,
    required this.onTap,
  });

  static const Color kGreen = Color(0xFF045F25);

  num? _toNum(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim().replaceAll(',', '');
    if (s.isEmpty) return null;
    return num.tryParse(s);
  }

  String _compact(dynamic v) {
    final n = _toNum(v);
    if (n == null) return '';
    final abs = n.abs();
    String fmt(num value, String suffix) {
      final d = value.toDouble();
      final fixed = d.toStringAsFixed(1);
      final cleaned = fixed.endsWith('.0')
          ? fixed.substring(0, fixed.length - 2)
          : fixed;
      return '$cleaned$suffix';
    }

    if (abs >= 1000000000) return fmt(n / 1000000000, 'B');
    if (abs >= 1000000) return fmt(n / 1000000, 'M');
    if (abs >= 1000) return fmt(n / 1000, 'k');
    return n.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    // ── Athletes doc fields ────────────────────────────────────────────────
    final firstName = (athleteData['firstName'] ?? '').toString().trim();
    final lastName = (athleteData['lastName'] ?? '').toString().trim();
    final companyName = (athleteData['companyName'] ?? '').toString().trim();
    final name = companyName.isNotEmpty
        ? companyName
        : ('$firstName $lastName').trim().isNotEmpty
        ? ('$firstName $lastName').trim()
        : 'Athlete';

    final logo = (athleteData['logoFullPath'] ?? '').toString().trim();
    final cover = (athleteData['coverImageFullPath'] ?? '').toString().trim();

    // User asked: avatar as FULL COVER only (no circular avatar).
    // We’ll use the "avatar" source, but render it as the full cover image.
    // Prefer logo if you consider it the avatar; fallback to cover.
    final heroImageUrl = (logo.isNotEmpty ? logo : cover).trim();

    final avgRating = (athleteData['avgRating'] is num)
        ? (athleteData['avgRating'] as num).toDouble()
        : double.tryParse('${athleteData['avgRating'] ?? 0}') ?? 0.0;
    final ratingCount = (athleteData['ratingCount'] is num)
        ? (athleteData['ratingCount'] as num).toInt()
        : int.tryParse('${athleteData['ratingCount'] ?? 0}') ?? 0;

    final isAvailable =
        athleteData['serviceAvailability'] == 1 ||
        athleteData['serviceAvailability'] == true;

    final bool isVerified =
        athleteData['isVerified'] == true ||
        athleteData['showVerificationBadge'] == true ||
        athleteData['verificationStatus'] == 'verified';

    // ── athlete_profiles doc fields ────────────────────────────────────────
    final schoolTeam = (profileData?['schoolTeam'] ?? '').toString().trim();
    final positionRole = (profileData?['positionRole'] ?? '').toString().trim();
    final sportName = (profileData?['sportName'] ?? '').toString().trim();
    final publicLocation = (profileData?['publicLocation'] ?? '')
        .toString()
        .trim();

    final socialStats =
        (profileData?['socialStats'] as Map?)?.cast<String, dynamic>() ?? {};
    final igFollowers = _compact(socialStats['igFollowers']);
    final ttFollowers = _compact(socialStats['ttFollowers']);
    final xFollowers = _compact(socialStats['xFollowers']);

    final stats = <({String value, FaIconData icon, String label})>[
      if (igFollowers.isNotEmpty)
        (value: igFollowers, icon: FontAwesomeIcons.instagram, label: ''),
      if (ttFollowers.isNotEmpty)
        (value: ttFollowers, icon: FontAwesomeIcons.tiktok, label: ''),
      if (xFollowers.isNotEmpty)
        (value: xFollowers, icon: FontAwesomeIcons.xTwitter, label: ''),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(20);

    // Outer shell keeps shadow outside clip (premium look)
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.07),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── FULL COVER IMAGE ────────────────────────────────────
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CustomImage(
                      image: heroImageUrl,
                      fit: BoxFit.cover,
                      placeholder: Images.userPlaceHolder,
                    ),
                  ),

                  // Gradient overlay for "premium" depth + readable chips
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.10),
                            Colors.black.withOpacity(0.45),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Favorite (top-right)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _GlassPill(
                      padding: const EdgeInsets.all(6),
                      child: SqlFavoriteIconButton(providerId: providerId),
                    ),
                  ),

                  // Availability (bottom-left)
                  /*  Positioned(
                    bottom: 12,
                    left: 12,
                    child: _GlassPill(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAvailable
                                  ? const Color(0xFF22C55E)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            isAvailable ? 'Available' : 'Unavailable',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), */

                  // Sport badge (bottom-right)
                  if (sportName.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: _GlassPill(
                        child: Text(
                          sportName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // ── DETAILS & STATS BELOW COVER ─────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: Colors.green,
                            size: 18,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 6),

                    // School • Position
                    if (schoolTeam.isNotEmpty || positionRole.isNotEmpty)
                      Text(
                        [
                          if (schoolTeam.isNotEmpty) schoolTeam,
                          if (positionRole.isNotEmpty) positionRole,
                        ].join('  •  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white.withOpacity(0.65)
                              : Colors.black.withOpacity(0.55),
                          height: 1.3,
                        ),
                      ),

                    // Location
                    if (publicLocation.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: kGreen.withOpacity(0.85),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              publicLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white.withOpacity(0.55)
                                    : Colors.black.withOpacity(0.45),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Social stat pills
                    if (stats.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: stats.take(3).map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: kGreen.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: kGreen.withOpacity(0.20),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(s.icon, size: 12, color: kGreen),
                                const SizedBox(width: 6),
                                Text(
                                  '${s.label} ${s.value}',
                                  style: const TextStyle(
                                    color: kGreen,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 12),

                    // Rating row
                    Row(
                      children: [
                        RatingBar(rating: avgRating),
                        const SizedBox(width: 6),
                        Text(
                          '($ratingCount)',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white.withOpacity(0.55)
                                : Colors.black.withOpacity(0.45),
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
      ),
    );
  }
}

// ─── Shimmer (updated to match full-cover layout) ─────────────────────────────
class _AthleteListShimmer extends StatelessWidget {
  const _AthleteListShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).hintColor.withOpacity(0.10),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Shimmer(
            duration: const Duration(seconds: 1),
            interval: const Duration(seconds: 1),
            enabled: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cover shimmer
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(color: Theme.of(context).shadowColor),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        color: Theme.of(context).shadowColor,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 12,
                        width: 220,
                        color: Theme.of(context).shadowColor,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 12,
                        width: 160,
                        color: Theme.of(context).shadowColor,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            height: 26,
                            width: 86,
                            decoration: BoxDecoration(
                              color: Theme.of(context).shadowColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            height: 26,
                            width: 86,
                            decoration: BoxDecoration(
                              color: Theme.of(context).shadowColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 12,
                        width: 120,
                        color: Theme.of(context).shadowColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
