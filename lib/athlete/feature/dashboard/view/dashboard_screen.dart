import 'package:afriendorse/athlete/feature/dashboard/view/dash_widget/athlete_ad_section.dart';
import 'package:afriendorse/athlete/feature/dashboard/view/dash_widget/athlete_campaign_section.dart';
import 'package:afriendorse/athlete/feature/dashboard/view/dash_widget/athlete_earnings_chart_card.dart';
import 'package:afriendorse/athlete/feature/dashboard/view/dash_widget/athlete_overview_stats.dart';
import 'package:afriendorse/athlete/feature/dashboard/view/dash_widget/athlete_quick_actions_section.dart';
import 'package:afriendorse/athlete/feature/dashboard/view/dash_widget/athlete_recent_activity_section.dart';
import 'package:afriendorse/athlete/feature/dashboard/view/dash_widget/athlete_wallet_spotlight_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/nav/widgets/subscription_trail_end_widget.dart';
import 'package:afriendorse/athlete/feature/wallet/screen/wallet_screen.dart';
import 'package:afriendorse/athlete/feature/campaigns/controller/campaign_controller.dart';
import 'package:afriendorse/athlete/feature/wallet/controller/wallet_controller.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with SingleTickerProviderStateMixin {
  final toolTip = JustTheController();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  late final AltCampaignController _campaignCtrl;
  late final WalletController _walletCtrl;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    // Ensure WalletController is available on dashboard
    _walletCtrl = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController(), permanent: true);

    // IMPORTANT: Always use the TAG to avoid collision with brand/fan controller
    _campaignCtrl =
        Get.isRegistered<AltCampaignController>(tag: AltCampaignController.tag)
        ? Get.find<AltCampaignController>(tag: AltCampaignController.tag)
        : Get.put(
            AltCampaignController(),
            tag: AltCampaignController.tag,
            permanent: true,
          );

    // Start myCampaigns stream safely
    _campaignCtrl.ensureMyCampaignsListening();

    // ============================================
    // PRELOAD BIDS DATA for PendingTabBidsContent
    // ============================================
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postController = Get.isRegistered<PostController>()
          ? Get.find<PostController>()
          : Get.put(PostController(postRepo: Get.find()), permanent: true);

      // Preload the bids data so it's ready when user navigates to BookingRequestScreen
      postController.getCustomerPostList(
        1,
        "placed_offer",
        reload: false,
        fromBid: true,
      );
    });

    final dashboard = Get.find<DashboardController>();
    dashboard.getMonthlyBookingsDataForChart(
      DateConverter.stringYear(DateTime.now()),
      DateTime.now().month.toString(),
    );
    dashboard.getYearlyBookingsDataForChart(
      DateConverter.stringYear(DateTime.now()),
    );

    Get.find<BusinessSettingController>().getBookingSettingsDataFromServer();
    Get.find<BusinessSettingController>()
        .getServiceAvailabilitySettingsFromServer();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final dash = Get.find<DashboardController>();

    await dash.getDashboardData();

    dash.changeGraph(EarningType.monthly);
    dash.changeRecentActivityView(status: true, shouldUpdate: true);
    dash.changeTypeOfShowBookingStatus(status: true, shouldUpdate: true);

    await dash.getMonthlyBookingsDataForChart(
      DateConverter.stringYear(DateTime.now()),
      DateTime.now().month.toString(),
    );
    await dash.getYearlyBookingsDataForChart(
      DateConverter.stringYear(DateTime.now()),
    );

    await _walletCtrl.refresh(); // keep this

    _campaignCtrl.ensureMyCampaignsListening();

    Get.find<NotificationController>().getNotifications(
      1,
      saveNotificationCount: false,
    );
    Get.find<SplashController>().getConfigData();
  }

  bool _canShowTrialWidget(UserProfileController userProfileController) {
    return userProfileController.providerModel != null &&
        userProfileController.providerModel!.content != null &&
        userProfileController.providerModel!.content!.subscriptionInfo !=
            null &&
        userProfileController
                .providerModel!
                .content!
                .subscriptionInfo!
                .subscribedPackageDetails !=
            null &&
        userProfileController
                .providerModel!
                .content!
                .subscriptionInfo!
                .subscribedPackageDetails!
                .trialDuration !=
            0 &&
        DateConverter.countDays(
              endDate: DateTime.parse(
                userProfileController
                    .providerModel!
                    .content!
                    .subscriptionInfo!
                    .subscribedPackageDetails!
                    .packageEndDate!,
              ),
            ) >
            0;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        final canShow = _canShowTrialWidget(userProfileController);

        return Scaffold(
          backgroundColor: AthleteDashboardColors.pageBg,
          body: Stack(
            children: [
              const AthleteDashboardBackground(),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const AthleteDashboardAppBar(),
                    Expanded(
                      child: RefreshIndicator(
                        color: AthleteDashboardColors.primary,
                        backgroundColor: Colors.white,
                        onRefresh: _onRefresh,
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: Builder(
                            builder: (context) {
                              final topPadding =
                                  MediaQuery.of(context).size.width < 380
                                  ? 4.0
                                  : 8.0;

                              return ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  16,
                                  topPadding,
                                  16,
                                  120,
                                ),
                                children: [
                                  const AthleteDashboardHeader(),
                                  const SizedBox(height: 18),
                                  const AthleteOverviewStats(),
                                  const SizedBox(height: 18),
                                  const AthleteRecentActivitySection(),
                                  const SizedBox(height: 18),
                                  AthleteCampaignSection(
                                    campaignCtrl: _campaignCtrl,
                                  ),
                                  const SizedBox(height: 18),
                                  const AthleteQuickActionsSection(),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton:
              canShow && !userProfileController.trialWidgetNotShow
              ? const SubscriptionTrailEndWidget()
              : const SizedBox(),
        );
      },
    );
  }
}

/// ======================================================
/// SHARED TOKENS
/// ======================================================

class AthleteDashboardColors {
  static const Color primary = Color(0xFF045F25);
  static const Color black = Color(0xFF000000);
  static const Color pageBg = Color(0xFFF7FAF8);
  static const Color softBg = Color(0xFFEAF7EF);
  static const Color cardBg = Colors.white;
  static const Color cardBg2 = Color(0xFFF4F8F5);
  static const Color border = Color(0xFFDDE8E1);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0EA5E9);
}

// The rest of your file (AthleteSectionTitle, AthleteGlassCard,
// AthleteDashboardBackground, AppBar, Header etc.) stays exactly the same.

class AthleteSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const AthleteSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: robotoBold.copyWith(
                    color: AthleteDashboardColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: robotoRegular.copyWith(
                      color: AthleteDashboardColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class AthleteGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AthleteGlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AthleteDashboardColors.border.withOpacity(0.95),
        ),
        boxShadow: [
          BoxShadow(
            color: AthleteDashboardColors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// ======================================================
/// BACKGROUND
/// ======================================================

class AthleteDashboardBackground extends StatelessWidget {
  const AthleteDashboardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF9FCFA), Color(0xFFF3F8F5), Color(0xFFF7FAF8)],
            ),
          ),
        ),

        // Top glow
        Positioned(
          top: -120,
          right: -80,
          child: _BlurOrb(
            size: 300,
            color: AthleteDashboardColors.primary.withOpacity(0.15),
          ),
        ),

        // Mid left glow
        Positioned(
          top: 180,
          left: -80,
          child: _BlurOrb(
            size: 220,
            color: const Color(0xFFB9E5C7).withOpacity(0.34),
          ),
        ),

        // Lower right white-green glow
        Positioned(
          bottom: 50,
          right: -60,
          child: _BlurOrb(size: 250, color: Colors.white.withOpacity(0.70)),
        ),

        // Mid page glow wash
        Positioned(
          top: 340,
          left: 30,
          right: 30,
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(220),
              gradient: RadialGradient(
                colors: [
                  AthleteDashboardColors.primary.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Subtle top highlight
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AthleteDashboardColors.primary.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Ultra subtle pattern layer
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _DashboardPatternPainter()),
          ),
        ),
      ],
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.35,
              spreadRadius: size * 0.08,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final verticalPaint = Paint()
      ..color = AthleteDashboardColors.primary.withOpacity(0.018)
      ..strokeWidth = 1;

    final horizontalPaint = Paint()
      ..color = Colors.black.withOpacity(0.012)
      ..strokeWidth = 1;

    const double gap = 34;

    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), verticalPaint);
    }

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), horizontalPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ======================================================
/// APP BAR
/// ======================================================

class AthleteDashboardAppBar extends StatelessWidget {
  const AthleteDashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = MediaQuery.of(context).size.width < 380;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  height: isSmallPhone ? 42 : 46,
                  width: isSmallPhone ? 42 : 46,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AthleteDashboardColors.border.withOpacity(0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AthleteDashboardColors.primary.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    Images
                        .appbarLogo, // replace if your logo constant is different
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppConstants.appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      color: AthleteDashboardColors.textPrimary,
                      fontSize: isSmallPhone ? 20 : 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AthleteDashboardColors.border.withOpacity(0.85),
              ),
              boxShadow: [
                BoxShadow(
                  color: AthleteDashboardColors.primary.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Get.to(() => const NotificationScreen()),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AthleteDashboardColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================================================
/// HEADER
/// ======================================================

class AthleteDashboardHeader extends StatelessWidget {
  const AthleteDashboardHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userCtrl) {
        final provider = userCtrl.providerModel?.content?.providerInfo;
        final isSmallPhone = MediaQuery.of(context).size.width < 380;

        final athleteName = (provider?.companyName ?? 'Athlete').trim();
        final avatar = provider?.logoFullPath ?? '';

        final avgRating = double.tryParse('${provider?.avgRating ?? 0}') ?? 0.0;
        final ratingCount = int.tryParse('${provider?.ratingCount ?? 0}') ?? 0;

        // ✅ this must match your Firestore doc id (you use email lowercased)
        final email = (provider?.owner?.email ?? '')
            .toString()
            .trim()
            .toLowerCase();

        // If we don't have email yet, just render without a badge
        if (email.isEmpty) {
          return _headerCard(
            context: context,
            isSmallPhone: isSmallPhone,
            avatar: avatar,
            athleteName: athleteName,
            avgRating: avgRating,
            ratingCount: ratingCount,
            showBadge: false,
          );
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('athletes')
              .doc(email)
              .snapshots(),
          builder: (context, snap) {
            final data = snap.data?.data();

            final bool showBadge =
                (data?['showVerificationBadge'] == true) &&
                (data?['isVerified'] == true) &&
                ((data?['verificationStatus'] ?? '').toString().trim() ==
                    'verified');

            return _headerCard(
              context: context,
              isSmallPhone: isSmallPhone,
              avatar: avatar,
              athleteName: athleteName,
              avgRating: avgRating,
              ratingCount: ratingCount,
              showBadge: showBadge,
            );
          },
        );
      },
    );
  }

  /// Helper to keep your UI exactly the same and avoid duplicating it.
  Widget _headerCard({
    required BuildContext context,
    required bool isSmallPhone,
    required String avatar,
    required String athleteName,
    required double avgRating,
    required int ratingCount,
    required bool showBadge,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A7A31), Color(0xFF045F25), Color(0xFF03471C)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AthleteDashboardColors.primary.withOpacity(0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -8,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.10), Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.35)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CustomImage(
                        image: avatar,
                        height: isSmallPhone ? 54 : 58,
                        width: isSmallPhone ? 54 : 58,
                        fit: BoxFit.cover,
                        placeholder: Images.userPlaceHolder,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_greeting()},',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoMedium.copyWith(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: isSmallPhone ? 12 : 13,
                          ),
                        ),
                        const SizedBox(height: 2),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                athleteName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoBold.copyWith(
                                  color: Colors.white,
                                  fontSize: isSmallPhone ? 22 : 24,
                                  height: 1.08,
                                ),
                              ),
                            ),
                            if (showBadge) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified,
                                size: 20,
                                color: Color.fromARGB(255, 46, 218, 77),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  RatingBar(rating: avgRating),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$ratingCount review(s)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(
                        color: Colors.white.withOpacity(0.90),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _HeaderActionButton(
                      title: 'Edit Bio',
                      icon: Icons.edit_outlined,
                      onTap: () => Get.to(() => const BusinessSettingScreen()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeaderActionButton(
                      title: 'Wallet',
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () => Get.to(() => const AthleteWalletScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = MediaQuery.of(context).size.width < 380;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 10 : 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 7),
            Text(
              title,
              style: robotoMedium.copyWith(
                color: Colors.white,
                fontSize: isSmallPhone ? 11.5 : 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
