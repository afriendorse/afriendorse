import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NilProviderHeroHeader extends StatelessWidget {
  final ProviderData provider;
  const NilProviderHeroHeader({super.key, required this.provider});

  static const Color kGreen = Color(0xFF045F25);

  DocumentReference<Map<String, dynamic>>? _mediaKitRef() {
    final email = provider.owner?.email?.trim();
    if (email == null || email.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('athlete_profiles')
        .doc(email.toLowerCase());
  }

  DocumentReference<Map<String, dynamic>>? _athleteRef() {
    final email = provider.owner?.email?.trim();
    if (email == null || email.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('athletes')
        .doc(email.toLowerCase());
  }

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
    final cover = (provider.coverImageFullPath ?? '').toString();
    final avatar = (provider.logoFullPath ?? '').toString();
    final title = (provider.companyName ?? 'Athlete').toString();

    final isAvailable = provider.serviceAvailability == 1;

    final mediaKitRef =
        _mediaKitRef(); // athlete_profiles (schoolTeam/socialStats/etc)
    final athleteRef = _athleteRef(); // athletes (verification badge fields)

    Widget contentFrom(
      Map<String, dynamic>? mediaKit,
      Map<String, dynamic>? athleteDoc,
    ) {
      final schoolTeam = (mediaKit?['schoolTeam'] ?? '').toString().trim();
      final positionRole = (mediaKit?['positionRole'] ?? '').toString().trim();

      // ✅ badge fields come from athletes collection doc
      final bool showBadge =
          (athleteDoc?['showVerificationBadge'] == true) &&
          (athleteDoc?['isVerified'] == true) &&
          ((athleteDoc?['verificationStatus'] ?? '').toString().trim() ==
              'verified');

      final socialStats =
          (mediaKit?['socialStats'] as Map?)?.cast<String, dynamic>() ?? {};
      final igFollowers = _compact(socialStats['igFollowers']);
      final ttFollowers = _compact(socialStats['ttFollowers']);
      final xFollowers = _compact(socialStats['xFollowers']);

      final stats = <_HeroStat>[
        if (igFollowers.isNotEmpty)
          _HeroStat(value: igFollowers, icon: FontAwesomeIcons.instagram),
        if (ttFollowers.isNotEmpty)
          _HeroStat(value: ttFollowers, icon: FontAwesomeIcons.tiktok),
        if (xFollowers.isNotEmpty)
          _HeroStat(value: xFollowers, icon: FontAwesomeIcons.xTwitter),
      ];

      return Container(
        margin: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeSmall,
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeDefault,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Cover
            SizedBox(
              height: 270,
              width: double.infinity,
              child: CustomImage(
                image: cover,
                fit: BoxFit.cover,
                placeholder: Images.placeholder,
              ),
            ),

            // Scrim
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.10),
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.70),
                    ],
                    stops: const [0.0, 0.62, 1.0],
                  ),
                ),
              ),
            ),

            // Favorite
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.90),
                  shape: BoxShape.circle,
                ),
                child: FavoriteIconWidget(
                  value: provider.isFavorite,
                  providerId: provider.id,
                ),
              ),
            ),

            // Bottom meta (glass panel)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.85),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 22,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CustomImage(
                        image: avatar,
                        fit: BoxFit.cover,
                        placeholder: Images.userPlaceHolder,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Name + badge
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              if (showBadge) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  size: 18,
                                  color: Color(0xFF045F25),
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
                                color: Colors.white.withOpacity(0.88),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),

                          if (stats.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: stats.take(3).map((s) {
                                return _SocialStatPill(stat: s);
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 10),

                          // Rating + availability
                          Row(
                            children: [
                              RatingBar(rating: provider.avgRating),
                              const SizedBox(width: 8),
                              Text(
                                '${provider.ratingCount ?? 0} ${'reviews'.tr}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.90),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // _AvailabilityPill(isAvailable: isAvailable),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // No refs? show base UI.
    if (mediaKitRef == null && athleteRef == null) {
      return contentFrom(null, null);
    }

    // ✅ Stream both docs (athlete_profiles + athletes) and combine
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: mediaKitRef?.snapshots(),
      builder: (context, mkSnap) {
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: athleteRef?.snapshots(),
          builder: (context, aSnap) {
            return contentFrom(mkSnap.data?.data(), aSnap.data?.data());
          },
        );
      },
    );
  }
}

class _HeroStat {
  final String value;
  final FaIconData icon;
  const _HeroStat({required this.value, required this.icon});
}

class _SocialStatPill extends StatelessWidget {
  final _HeroStat stat;
  const _SocialStatPill({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(stat.icon, size: 15, color: Colors.white.withOpacity(0.95)),
          const SizedBox(width: 7),
          Text(
            stat.value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  final bool isAvailable;
  const _AvailabilityPill({required this.isAvailable});

  static const Color kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    final bg = isAvailable
        ? kGreen.withOpacity(0.40)
        : Colors.white.withOpacity(0.14);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Unavailable',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.90),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.black.withOpacity(0.78), size: 18),
        ),
      ),
    );
  }
}
