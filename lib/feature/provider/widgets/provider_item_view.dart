import 'dart:ui';

import 'package:afriendorse/util/core_export.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ProviderItemView extends StatelessWidget {
  final bool fromHomePage;
  final ProviderData providerData;
  final GlobalKey<CustomShakingWidgetState>? signInShakeKey;
  final int index;
  final bool isVerticalLayout;

  final Map<String, dynamic>? athleteExtras;

  const ProviderItemView({
    super.key,
    this.fromHomePage = true,
    required this.providerData,
    required this.index,
    this.signInShakeKey,
    this.isVerticalLayout = false,
    this.athleteExtras, // ✅ add
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProviderBookingController>(
      builder: (providerBookingController) {
        // No horizontal padding for vertical layout (full width cards)
        return Padding(
          padding: isVerticalLayout
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(
                  horizontal:
                      ResponsiveHelper.isDesktop(context) && fromHomePage
                      ? 5
                      : Dimensions.paddingSizeEight,
                  vertical: fromHomePage ? 0 : Dimensions.paddingSizeEight,
                ),
          child: OnHover(
            isItem: true,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Conditional layout rendering
                isVerticalLayout
                    ? _buildVerticalLayout(context)
                    : _buildHorizontalLayout(context),

                Positioned.fill(
                  child: RippleButton(
                    onTap: () {
                      Get.toNamed(
                        RouteHelper.getProviderDetails(providerData.id!),
                      );
                    },
                  ),
                ),

                // Favorite button positioned differently for vertical layout
                /*  Align(
                  alignment: isVerticalLayout
                      ? Alignment.topRight
                      : favButtonAlignment(),
                  child: Padding(
                    padding: isVerticalLayout
                        ? const EdgeInsets.all(Dimensions.paddingSizeDefault)
                        : EdgeInsets.zero,
                    child: FavoriteIconWidget(
                      value: providerData.isFavorite,
                      providerId: providerData.id,
                      signInShakeKey: signInShakeKey,
                    ),
                  ),
                ), */
              ],
            ),
          ),
        );
      },
    );
  }

  // Facebook-style vertical layout: Full width image on top, details below
  /*
  Widget _buildVerticalLayout(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
        bottom: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).hintColor.withValues(alpha: 0.2),
        ),
        boxShadow: Get.isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.grey[300]!,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // FULL WIDTH rectangular image at top (Facebook style)
          CustomImage(
            height: 220, // Taller for better visual impact
            width: double.infinity,
            fit: BoxFit.cover,
            image: providerData.logoFullPath ?? "",
            placeholder: Images.userPlaceHolder,
          ),

          // Details section below image
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company name - bold and prominent
                Text(
                  providerData.companyName ?? "",
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                // Rating row
                Row(
                  children: [
                    RatingBar(rating: providerData.avgRating),
                    Gaps.horizontalGapOf(5),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '${providerData.ratingCount} ${'reviews'.tr}',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                // Address with icon
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        providerData.companyAddress ?? "",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Dimensions.paddingSizeTine),

                // Distance
                /* Row(
                  children: [
                    Image.asset(Images.distance, height: 14),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      "${providerData.distance!.toStringAsFixed(2)} ${'km_away_from_you'.tr}",
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ), */
              ],
            ),
          ),
        ],
      ),
    );
  }
*/

  Widget _buildVerticalLayout(BuildContext context) {
    const kGreen = Color(0xFF045F25);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(20);

    // Firestore mirrored fields (from athletes doc)
    final schoolTeam = (athleteExtras?['schoolTeam'] ?? '').toString().trim();
    final positionRole = (athleteExtras?['positionRole'] ?? '')
        .toString()
        .trim();
    final sportName = (athleteExtras?['sportName'] ?? '').toString().trim();
    final publicLocation = (athleteExtras?['publicLocation'] ?? '')
        .toString()
        .trim();

    // ✅ Verification badge fields
    final bool showBadge = athleteExtras?['showVerificationBadge'] == true;
    final bool isVerified = athleteExtras?['isVerified'] == true;
    final String verificationStatus =
        (athleteExtras?['verificationStatus'] ?? '').toString().trim();
    final bool shouldShowBadge =
        showBadge && isVerified && verificationStatus == 'verified';

    final socialStats =
        (athleteExtras?['socialStats'] as Map?)?.cast<String, dynamic>() ?? {};

    String compact(dynamic v) {
      if (v == null) return '';
      final s = v.toString().trim().replaceAll(',', '');
      final n = num.tryParse(s);
      if (n == null) return '';
      final abs = n.abs();
      String fmt(num value, String suffix) {
        final fixed = value.toDouble().toStringAsFixed(1);
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

    final stats = <({String value, FaIconData icon})>[
      if (compact(socialStats['igFollowers']).isNotEmpty)
        (
          value: compact(socialStats['igFollowers']),
          icon: FontAwesomeIcons.instagram,
        ),
      if (compact(socialStats['ttFollowers']).isNotEmpty)
        (
          value: compact(socialStats['ttFollowers']),
          icon: FontAwesomeIcons.tiktok,
        ),
      if (compact(socialStats['xFollowers']).isNotEmpty)
        (
          value: compact(socialStats['xFollowers']),
          icon: FontAwesomeIcons.xTwitter,
        ),
    ];

    final heroImageUrl = [
      (athleteExtras?['coverImageFullPath'] ?? '').toString().trim(),
      (athleteExtras?['galleryCover'] ?? '').toString().trim(),
      (athleteExtras?['logoFullPath'] ?? '').toString().trim(),
      (providerData.logoFullPath ?? '').toString().trim(),
    ].firstWhere((e) => e.isNotEmpty, orElse: () => '');

    final locationText = publicLocation.isNotEmpty
        ? publicLocation
        : (providerData.companyAddress ?? '').toString().trim();

    return Container(
      margin: const EdgeInsets.only(
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
        bottom: Dimensions.paddingSizeDefault,
      ),
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cover
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

              // Favorite pill (top-right)
              Positioned(
                top: 12,
                right: 12,
                child: _GlassPill(
                  padding: const EdgeInsets.all(6),
                  child: FavoriteIconWidget(
                    value: providerData.isFavorite,
                    providerId: providerData.id,
                    signInShakeKey: signInShakeKey,
                  ),
                ),
              ),

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

          // Details area
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Row 1: Name + badge left, chips right
                Row(
                  children: [
                    // ✅ Name + verification badge grouped together
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              providerData.companyName ?? "",
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
                          // ✅ Verification badge right after name
                          if (shouldShowBadge) ...[
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.verified,
                              size: 18,
                              color: Color(0xFF045F25),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (schoolTeam.isNotEmpty || positionRole.isNotEmpty)
                      SizedBox(
                        height: 30,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Row 2: Location left + rating right
                Row(
                  children: [
                    Expanded(
                      child: locationText.isEmpty
                          ? const SizedBox.shrink()
                          : Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: kGreen.withOpacity(0.85),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    locationText,
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
                    ),
                    const SizedBox(width: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RatingBar(rating: providerData.avgRating),
                        const SizedBox(width: 6),
                        Text(
                          '(${providerData.ratingCount})',
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

                // Row 3: Social stats
                if (stats.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: stats.take(3).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final s = stats[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kGreen.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: kGreen.withOpacity(0.20)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(s.icon, size: 12, color: kGreen),
                              const SizedBox(width: 6),
                              Text(
                                s.value,
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
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.10)
              : Colors.black.withOpacity(0.08),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: isDark
              ? Colors.white.withOpacity(0.80)
              : Colors.black.withOpacity(0.70),
        ),
      ),
    );
  }

  // Original horizontal layout (compact card style)
  Widget _buildHorizontalLayout(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).hintColor.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  Dimensions.radiusExtraMoreLarge,
                ),
                child: CustomImage(
                  height: 65,
                  width: 65,
                  fit: BoxFit.cover,
                  image: providerData.logoFullPath ?? "",
                  placeholder: Images.userPlaceHolder,
                ),
              ),

              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            providerData.companyName ?? "",
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraLarge),
                      ],
                    ),

                    Row(
                      children: [
                        RatingBar(rating: providerData.avgRating),
                        Gaps.horizontalGapOf(5),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '${providerData.ratingCount} ${'reviews'.tr}',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).secondaryHeaderColor,
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

          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            providerData.companyAddress ?? "",
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: Dimensions.paddingSizeTine),

          Row(
            children: [
              Image.asset(Images.distance, height: 12),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Flexible(
                child: Text(
                  "${providerData.distance!.toStringAsFixed(2)} ${'km_away_from_you'.tr}",
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
          child: child,
        ),
      ),
    );
  }
}
