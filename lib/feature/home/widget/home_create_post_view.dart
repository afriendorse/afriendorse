import 'dart:ui';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

// ── Brand palette ─────────────────────────────────────────────────────────────
const Color _kGreen = Color(0xFF045F25);
const Color _kGreenLight = Color(0xFF0A7A33);
const Color _kWhite = Color(0xFFFFFFFF);

class HomeCreatePostView extends StatelessWidget {
  final bool showShimmer;
  const HomeCreatePostView({super.key, required this.showShimmer});

  @override
  Widget build(BuildContext context) {
    if (showShimmer) return const _HomeCreatePostShimmer();
    return const _HomeCreatePostCard();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main card
// ─────────────────────────────────────────────────────────────────────────────
class _HomeCreatePostCard extends StatelessWidget {
  const _HomeCreatePostCard();

  @override
  Widget build(BuildContext context) {
    final bool isLtr = Get.find<LocalizationController>().isLtr;

    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Stack(
        children: [
          // ── Background image ─────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              Images.createPostBackgroundImage,
              fit: BoxFit.cover,
            ),
          ),

          // ── Green gradient overlay ───────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: isLtr ? Alignment.centerLeft : Alignment.centerRight,
                  end: isLtr ? Alignment.centerRight : Alignment.centerLeft,
                  colors: [
                    _kGreen.withOpacity(0.92),
                    _kGreen.withOpacity(0.75),
                    _kGreen.withOpacity(0.30),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // ── Subtle mesh lines (brand texture) ────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _MeshPainter(color: _kWhite.withOpacity(0.06)),
            ),
          ),

          // ── Content row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeLarge,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text + button side
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── AfriEndorse badge ──────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _kWhite.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _kWhite.withOpacity(0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              color: Colors.amber,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AfriEndorse',
                              style: robotoMedium.copyWith(
                                color: _kWhite,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      // ── Headline ───────────────────────────────────────
                      Text(
                        'post_for_customized_service'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: _kWhite,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // ── Sub-text ───────────────────────────────────────
                      Text(
                        'create_post_text'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: _kWhite.withOpacity(0.80),
                          height: 1.45,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      // ── CTA button ─────────────────────────────────────
                      _CreatePostButton(
                        onPressed: () =>
                            Get.toNamed(RouteHelper.getCreatePostScreen()),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: Dimensions.paddingSizeDefault),

                // ── Athlete illustration ───────────────────────────────────
                _AthleteIllustration(isLtr: isLtr),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA button — glass style
// ─────────────────────────────────────────────────────────────────────────────
class _CreatePostButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CreatePostButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraMoreLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: _kWhite.withOpacity(0.22),
              borderRadius: BorderRadius.circular(
                Dimensions.radiusExtraMoreLarge,
              ),
              border: Border.all(color: _kWhite.withOpacity(0.45), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_circle_outline_rounded,
                  color: _kWhite,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'create_post'.tr,
                  style: robotoBold.copyWith(
                    color: _kWhite,
                    fontSize: Dimensions.fontSizeDefault,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Athlete illustration with subtle glow
// ─────────────────────────────────────────────────────────────────────────────
class _AthleteIllustration extends StatelessWidget {
  final bool isLtr;
  const _AthleteIllustration({required this.isLtr});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Glow circle behind athlete
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [_kWhite.withOpacity(0.12), _kWhite.withOpacity(0.0)],
            ),
          ),
        ),
        Image.asset(
          Images.homeCreatePostMan,
          height: 115,
          width: 100,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mesh texture painter — matches PortalScreen / ProviderDetailsScreen style
// ─────────────────────────────────────────────────────────────────────────────
class _MeshPainter extends CustomPainter {
  final Color color;
  const _MeshPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path()
      ..moveTo(size.width * 0.0, size.height * 0.3)
      ..lineTo(size.width * 0.4, size.height * 0.0)
      ..lineTo(size.width * 0.8, size.height * 0.4)
      ..moveTo(size.width * 0.1, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.9, size.height * 0.9);

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton — proper bone shapes matching real layout
// ─────────────────────────────────────────────────────────────────────────────
class _HomeCreatePostShimmer extends StatelessWidget {
  const _HomeCreatePostShimmer();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Shimmer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Stack(
          children: [
            // ── Background placeholder ───────────────────────────────────
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1A2E1F), const Color(0xFF0D1A11)]
                        : [const Color(0xFFD6E8D9), const Color(0xFFEAF3EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // ── Skeleton content ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text skeleton
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge bone
                        _ShimmerBone(
                          width: 90,
                          height: 22,
                          radius: 20,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),

                        // Title bone — two lines
                        _ShimmerBone(
                          width: double.infinity,
                          height: 16,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 6),
                        _ShimmerBone(width: 160, height: 16, isDark: isDark),
                        const SizedBox(height: 10),

                        // Body text bones
                        _ShimmerBone(
                          width: double.infinity,
                          height: 10,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 5),
                        _ShimmerBone(width: 180, height: 10, isDark: isDark),
                        const SizedBox(height: 5),
                        _ShimmerBone(width: 140, height: 10, isDark: isDark),

                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        // Button bone
                        _ShimmerBone(
                          width: 130,
                          height: 38,
                          radius: Dimensions.radiusExtraMoreLarge,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  // Illustration bone
                  _ShimmerBone(
                    width: 90,
                    height: 110,
                    radius: 12,
                    isDark: isDark,
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

// ─────────────────────────────────────────────────────────────────────────────
// Single shimmer bone — reusable within the shimmer skeleton
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerBone extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final bool isDark;

  const _ShimmerBone({
    required this.width,
    required this.height,
    this.radius = 6,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.10)
            : Colors.white.withOpacity(0.60),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
