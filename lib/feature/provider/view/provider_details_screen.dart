/*
class ProviderDetailsScreen extends StatefulWidget {
  final String providerId;
  const ProviderDetailsScreen({super.key, required this.providerId});

  @override
  ProviderDetailsScreenState createState() => ProviderDetailsScreenState();
}

class ProviderDetailsScreenState extends State<ProviderDetailsScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();

    final providerBookingController = Get.find<ProviderBookingController>();

    providerBookingController.updateTabBarPinned(false);

    providerBookingController
        .getProviderDetailsData(widget.providerId, true)
        .then((value) {
          tabController = TabController(
            length:
                Get.find<ProviderBookingController>().categoryItemList.length,
            vsync: this,
          );
          Get.find<CartController>().updatePreselectedProvider(null);
        });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: const AnimatedCustomAppBar(),
        body: GetBuilder<ProviderBookingController>(
          builder: (providerBookingController) {
            if (providerBookingController.providerDetailsContent != null) {
              if (providerBookingController.providerDetailsContent?.provider ==
                  null) {
                return NoDataScreen(
                  text: 'no_data_found'.tr,
                  type: NoDataType.provider,
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification.metrics.axis == Axis.vertical) {
                    final threshold =
                        (context.width / 3 + 275) - kToolbarHeight;
                    if (scrollNotification.metrics.pixels >= threshold &&
                        !providerBookingController
                            .isTabBarPinnedNotifier
                            .value) {
                      providerBookingController.updateTabBarPinned(true);
                    } else if (scrollNotification.metrics.pixels < threshold &&
                        providerBookingController
                            .isTabBarPinnedNotifier
                            .value) {
                      providerBookingController.updateTabBarPinned(false);
                    }
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (providerBookingController
                              .providerDetailsContent
                              ?.provider
                              ?.serviceAvailability ==
                          0)
                        SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.1),
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeDefault,
                              horizontal: Dimensions.paddingSizeLarge,
                            ),
                            child: Center(
                              child: Text(
                                'provider_is_currently_unavailable'.tr,
                                style: robotoMedium,
                              ),
                            ),
                          ),
                        ),

                      SizedBox(
                        height: Get.height * 0.9,
                        width: Dimensions.webMaxWidth,
                        child: Stack(
                          children: [
                            VerticalScrollableTabView(
                              tabController: tabController!,
                              listItemData:
                                  providerBookingController.categoryItemList,
                              verticalScrollPosition:
                                  VerticalScrollPosition.begin,
                              eachItemChild: (object, index) => CategorySection(
                                category: object as CategoryModelItem,
                                providerData: providerBookingController
                                    .providerDetailsContent
                                    ?.provider,
                              ),
                              slivers: [
                                // if(!ResponsiveHelper.isDesktop(context)) SliverToBoxAdapter(child: SizedBox(height: (context.width / 3) * 0.7)),
                                if (!ResponsiveHelper.isDesktop(context))
                                  SliverToBoxAdapter(
                                    child: NilProviderHeroHeader(
                                      provider: providerBookingController
                                          .providerDetailsContent!
                                          .provider!,
                                    ),
                                  ),

                                //
                                //Deals Section start//
                                /*   ResponsiveHelper.isDesktop(context)
                                    ? SliverToBoxAdapter(
                                        child: ProviderDetailsTopCard(
                                          providerId: widget.providerId,
                                        ),
                                      )
                                    : const SliverToBoxAdapter(), */
                                SliverAppBar(
                                  automaticallyImplyLeading: false,
                                  backgroundColor: Colors.transparent,
                                  pinned: true,
                                  leading: const SizedBox(),
                                  actions: const [SizedBox()],
                                  expandedHeight:
                                      !ResponsiveHelper.isDesktop(context)
                                      ? 70
                                      : 0,
                                  elevation: 0,
                                  /*  flexibleSpace:
                                      !ResponsiveHelper.isDesktop(context)
                                      ? FlexibleSpaceBar(
                                          background: ProviderDetailsTopCard(
                                            providerId: widget.providerId,
                                          ),
                                        ) 
                                      : SizedBox(), */
                                  toolbarHeight: 0,
                                  bottom: PreferredSize(
                                    preferredSize: const Size.fromHeight(45),
                                    child: Container(
                                      height: 45,
                                      width: Dimensions.webMaxWidth,
                                      color: Theme.of(context).cardColor,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.0,
                                          ),
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.4),
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        child: TabBar(
                                          isScrollable: true,
                                           tabAlignment: TabAlignment.center, // ← add this
                                          controller: tabController,
                                          indicatorColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          labelColor: Get.isDarkMode
                                              ? Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.color
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          unselectedLabelColor:
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withValues(alpha: 0.7),
                                          unselectedLabelStyle: robotoRegular,
                                          tabs: providerBookingController
                                              .categoryItemList
                                              .map((e) => Tab(text: e.title))
                                              .toList(),
                                          onTap: (index) {
                                            VerticalScrollableTabBarStatus.setIndex(
                                              index,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (providerBookingController
                                    .categoryItemList
                                    .isEmpty)
                                  SliverToBoxAdapter(
                                    child: NoDataScreen(
                                      text:
                                          'no_subscribed_subcategories_available',
                                    ),
                                  ),

                                ////Deals Section end//
                                SliverToBoxAdapter(
                                  child: NilMediaKitSection(
                                    provider: providerBookingController
                                        .providerDetailsContent!
                                        .provider!,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (ResponsiveHelper.isDesktop(context))
                        const FooterView(),
                    ],
                  ),
                ),
              );
            } else {
              return const FooterBaseView(child: ProviderDetailsShimmer());
            }
          },
        ),
      ),
    );
  }
}

class AnimatedCustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final double height;

  const AnimatedCustomAppBar({super.key, this.height = kToolbarHeight});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProviderBookingController>();

    return ValueListenableBuilder<bool>(
      valueListenable: controller.isTabBarPinnedNotifier,
      builder: (context, isPinned, child) {
        return CustomAppBar(
          title: isPinned
              ? controller.providerDetailsContent?.provider?.companyName ??
                    "provider_details".tr
              : "provider_details".tr,
          showCart: true,
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

*/

//brand/fan athlete/provider details screen

import 'dart:ui';
import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:afriendorse/feature/brand_verify/brand_verification_controller.dart';
import 'package:afriendorse/feature/brand_verify/brand_verification_status_screen.dart';
import 'package:afriendorse/feature/fan_deals/fan_deal_request_controller.dart';
import 'package:afriendorse/feature/fan_deals/fan_deal_request_section.dart';
import 'package:afriendorse/feature/provider/widgets/athlete_campaign_section.dart';
import 'package:afriendorse/feature/provider/widgets/nil_media_kit_section.dart';
import 'package:afriendorse/feature/provider/widgets/nil_provider_hero_header.dart';
import 'package:afriendorse/feature/provider/widgets/provider_details_shimmer.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';
import 'package:flutter/material.dart';
import 'package:afriendorse/athlete/feature/donations/individual_athlete_donation_screen.dart';

// ─────────────────────────────────────────────
// Shared brand colours (mirror PortalScreen)
// ─────────────────────────────────────────────
const Color _kGreen = Color(0xFF045F25);
const Color _kBlack = Color(0xFF000000);
const Color _kWhite = Color(0xFFFFFFFF);

class ProviderDetailsScreen extends StatefulWidget {
  final String providerId;
  const ProviderDetailsScreen({super.key, required this.providerId});

  @override
  ProviderDetailsScreenState createState() => ProviderDetailsScreenState();
}

class ProviderDetailsScreenState extends State<ProviderDetailsScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();

    // ── Register and resolve role immediately ──────────────────────────────
    // Uses same dual-controller detection as GroupController
    if (!Get.isRegistered<FanDealRequestController>()) {
      Get.put(FanDealRequestController());
    }
    // Fire role resolution — updates isRoleLoading + currentUserType reactively
    Get.find<FanDealRequestController>().resolveUserRole();

    if (!Get.isRegistered<BrandVerificationController>()) {
      Get.put(BrandVerificationController());
    }
    final email = Get.find<UserController>().userInfoModel?.email;
    if (Get.find<AuthController>().isLoggedIn() &&
        (email ?? '').trim().isNotEmpty) {
      Get.find<BrandVerificationController>().load(email!.trim().toLowerCase());
    }

    // ── Existing init ──────────────────────────────────────────────────────
    final providerBookingController = Get.find<ProviderBookingController>();
    providerBookingController.updateTabBarPinned(false);

    providerBookingController
        .getProviderDetailsData(widget.providerId, true)
        .then((value) {
          if (mounted) {
            setState(() {
              tabController = TabController(
                length: Get.find<ProviderBookingController>()
                    .categoryItemList
                    .length,
                vsync: this,
              );
            });
          }
          Get.find<CartController>().updatePreselectedProvider(null);
        });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        backgroundColor: _kWhite,
        appBar: const AnimatedCustomAppBar(),
        body: Stack(
          children: [
            // ── Premium background (same as PortalScreen) ──
            const _ProviderPremiumBackground(),

            GetBuilder<ProviderBookingController>(
              builder: (providerBookingController) {
                if (providerBookingController.providerDetailsContent == null) {
                  return const FooterBaseView(child: ProviderDetailsShimmer());
                }

                final provider =
                    providerBookingController.providerDetailsContent?.provider;

                if (provider == null) {
                  return NoDataScreen(
                    text: 'no_data_found'.tr,
                    type: NoDataType.provider,
                  );
                }

                final categoryList = providerBookingController.categoryItemList;

                // ── Donation identifiers (declare OUTSIDE the children list) ──
                final athleteEmailLower =
                    (provider.owner?.email ?? provider.companyEmail ?? '')
                        .trim()
                        .toLowerCase();

                final athleteName =
                    ('${provider.owner?.firstName ?? ''} ${provider.owner?.lastName ?? ''}')
                        .trim();

                final athleteDisplayName = athleteName.isNotEmpty
                    ? athleteName
                    : (provider.companyName ?? 'Athlete');

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification.metrics.axis == Axis.vertical) {
                      final threshold =
                          (context.width / 3 + 275) - kToolbarHeight;

                      if (scrollNotification.metrics.pixels >= threshold &&
                          !providerBookingController
                              .isTabBarPinnedNotifier
                              .value) {
                        providerBookingController.updateTabBarPinned(true);
                      } else if (scrollNotification.metrics.pixels <
                              threshold &&
                          providerBookingController
                              .isTabBarPinnedNotifier
                              .value) {
                        providerBookingController.updateTabBarPinned(false);
                      }
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // ── Unavailability banner ──
                        if (provider.serviceAvailability == 0)
                          SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.error.withValues(alpha: 0.1),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeDefault,
                                horizontal: Dimensions.paddingSizeLarge,
                              ),
                              child: Center(
                                child: Text(
                                  'provider_is_currently_unavailable'.tr,
                                  style: robotoMedium,
                                ),
                              ),
                            ),
                          ),

                        // ── Hero header (mobile only) ──
                        if (!ResponsiveHelper.isDesktop(context))
                          SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: NilProviderHeroHeader(provider: provider),
                          ),

                        /// ── Donate button (fans + brands, logged-in) ──
                        if (athleteEmailLower.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(27),
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(
                                  Icons.volunteer_activism_outlined,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Donate to this Athlete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                onPressed: () {
                                  final auth = Get.find<AuthController>();
                                  if (!auth.isLoggedIn()) {
                                    Get.toNamed(RouteHelper.getSignInRoute());
                                    return;
                                  }

                                  Get.to(
                                    () => IndividualAthleteDonationScreen(
                                      athleteEmailLower: athleteEmailLower,
                                      athleteDisplayName: athleteDisplayName,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        // ── NEW: Individual campaign strip ──────────────────────────────
                        if (athleteEmailLower.isNotEmpty)
                          AthleteCampaignSection(
                            athleteEmailLower: athleteEmailLower,
                            athleteDisplayName: athleteDisplayName,
                          ),

                        // ── Role gate ─────────────────────────────────────────────
                        GetBuilder<FanDealRequestController>(
                          builder: (dealCtrl) {
                            final auth = Get.find<AuthController>();
                            final isLoggedIn = auth.isLoggedIn();

                            if (dealCtrl.isRoleLoading.value) {
                              return const SizedBox(
                                width: double.infinity,
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF045F25),
                                  ),
                                ),
                              );
                            }

                            // (A) Guest gate
                            if (!isLoggedIn) {
                              return SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: _GuestBookGate(
                                  onSignIn: () =>
                                      Get.toNamed(RouteHelper.getSignInRoute()),
                                ),
                              );
                            }

                            // (B) Fan: show fan deal request section
                            if (dealCtrl.isFan) {
                              final fanId = dealCtrl.currentFanId;
                              if (fanId.isNotEmpty) {
                                dealCtrl.checkExistingRequest(
                                  fanId: fanId,
                                  providerId: widget.providerId,
                                );
                              }

                              return SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: FanDealRequestSection(
                                  providerId: widget.providerId,
                                  providerName: provider.companyName ?? '',
                                ),
                              );
                            }

                            // (C) Non-fan: KYC gate for brands, else show tabs
                            if (Get.isRegistered<
                              BrandVerificationController
                            >()) {
                              return GetBuilder<BrandVerificationController>(
                                builder: (kycCtrl) {
                                  if (kycCtrl.isLoading.value) {
                                    return const SizedBox(
                                      width: double.infinity,
                                      height: 120,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: _kGreen,
                                        ),
                                      ),
                                    );
                                  }

                                  final isBrand =
                                      dealCtrl.currentUserType.value == 'brand';
                                  if (isBrand && !kycCtrl.isApproved) {
                                    final email =
                                        Get.find<UserController>()
                                            .userInfoModel
                                            ?.email ??
                                        '';
                                    return SizedBox(
                                      width: Dimensions.webMaxWidth,
                                      child: _BrandKycPendingGate(
                                        onViewStatus: () => Get.to(
                                          () => BrandVerificationStatusScreen(
                                            email: email,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return SizedBox(
                                    width: Dimensions.webMaxWidth,
                                    child: _buildDealsTabs(
                                      categoryList: categoryList,
                                      providerBookingController:
                                          providerBookingController,
                                    ),
                                  );
                                },
                              );
                            }

                            return SizedBox(
                              width: Dimensions.webMaxWidth,
                              child: _buildDealsTabs(
                                categoryList: categoryList,
                                providerBookingController:
                                    providerBookingController,
                              ),
                            );
                          },
                        ),

                        // ── NilMediaKitSection always below (all roles) ──
                        SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: NilMediaKitSection(provider: provider),
                        ),

                        if (ResponsiveHelper.isDesktop(context))
                          const FooterView(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealsTabs({
    required List<CategoryModelItem> categoryList,
    required ProviderBookingController providerBookingController,
  }) {
    return Column(
      children: [
        if (tabController != null && categoryList.isNotEmpty)
          SizedBox(
            width: Dimensions.webMaxWidth,
            child: _ModernTabBar(
              tabController: tabController!,
              categoryList: categoryList,
            ),
          ),

        if (categoryList.isEmpty)
          SizedBox(
            width: Dimensions.webMaxWidth,
            child: NoDataScreen(text: 'no_subscribed_subcategories_available'),
          ),

        if (tabController != null && categoryList.isNotEmpty)
          SizedBox(
            width: Dimensions.webMaxWidth,
            child: _ShrinkWrapTabBarView(
              controller: tabController!,
              children: categoryList
                  .map(
                    (e) => CategorySection(
                      category: e,
                      providerData: providerBookingController
                          .providerDetailsContent
                          ?.provider,
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _GuestBookGate extends StatelessWidget {
  final VoidCallback onSignIn;

  const _GuestBookGate({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kGreen.withOpacity(0.18)),
              boxShadow: [
                BoxShadow(
                  color: _kBlack.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
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
                        color: _kGreen.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: _kGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Sign in to book and send deal requests',
                        style: TextStyle(
                          color: _kBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Create an account to unlock deals, request bookings, and '
                  'work with athletes through AfriEndorse.',
                  style: TextStyle(
                    color: _kBlack.withOpacity(0.68),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onSignIn,
                    child: const Text(
                      'Sign in to continue',
                      style: TextStyle(
                        color: _kWhite,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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

class _BrandKycPendingGate extends StatelessWidget {
  final VoidCallback onViewStatus;

  const _BrandKycPendingGate({required this.onViewStatus});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kGreen.withOpacity(0.18)),
              boxShadow: [
                BoxShadow(
                  color: _kGreen.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
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
                        color: _kGreen.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: _kGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Verification under review',
                        style: TextStyle(
                          color: _kBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Your brand documents have been submitted successfully. '
                  'Our admin team is reviewing your KYC to enable Deals and bookings.',
                  style: TextStyle(
                    color: _kBlack.withOpacity(0.68),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _kGreen.withOpacity(0.35)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onViewStatus,
                    child: const Text(
                      'View verification status',
                      style: TextStyle(
                        color: _kGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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
// Modern glassmorphism pill tab bar
// ─────────────────────────────────────────────────────────────────────────────
class _ModernTabBar extends StatelessWidget {
  final TabController tabController;
  final List<CategoryModelItem> categoryList;

  const _ModernTabBar({
    required this.tabController,
    required this.categoryList,
  });

  @override
  Widget build(BuildContext context) {
    final bool scrollable = categoryList.length > 4;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.74),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: _kGreen.withOpacity(0.14), width: 1),
              boxShadow: [
                BoxShadow(
                  color: _kBlack.withOpacity(0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: _kGreen.withOpacity(0.07),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: TabBar(
              controller: tabController,
              isScrollable: scrollable,
              tabAlignment: scrollable ? TabAlignment.start : TabAlignment.fill,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: const LinearGradient(
                  colors: [Color(0xFF045F25), Color(0xFF0A7A33)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kGreen.withOpacity(0.32),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: _kWhite,
              unselectedLabelColor: _kBlack.withOpacity(0.52),
              labelStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
              padding: EdgeInsets.zero,
              tabs: categoryList
                  .map(
                    (e) => Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(e.title),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shrink-wrap TabBarView
//
// ROOT CAUSE OF THE CRASH:
//   TabBarView uses a PageView internally. PageView's Viewport requires a
//   *bounded* height — passing height=null (unconstrained) crashes the layout.
//
// FIX:
//   1. Render all tab children off-screen first using a Stack of Offstage
//      widgets to measure their natural heights.
//   2. Once heights are known, show the real TabBarView with the correct
//      bounded height. Until then use a safe fallback height so the
//      PageView never receives an unbounded constraint.
// ─────────────────────────────────────────────────────────────────────────────
class _ShrinkWrapTabBarView extends StatefulWidget {
  final TabController controller;
  final List<Widget> children;

  const _ShrinkWrapTabBarView({
    required this.controller,
    required this.children,
  });

  @override
  State<_ShrinkWrapTabBarView> createState() => _ShrinkWrapTabBarViewState();
}

class _ShrinkWrapTabBarViewState extends State<_ShrinkWrapTabBarView> {
  // -1 means "not yet measured"
  late List<double> _heights;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _heights = List.filled(widget.children.length, -1);
    _currentIndex = widget.controller.index;
    widget.controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!widget.controller.indexIsChanging) return;
    if (mounted) setState(() => _currentIndex = widget.controller.index);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  void _updateHeight(int index, double height) {
    if (_heights[index] != height) {
      setState(() => _heights[index] = height);
    }
  }

  // The height to give the TabBarView container.
  // Uses a safe fallback (300) while the current tab hasn't been measured yet.
  double get _activeHeight {
    final h = _heights[_currentIndex];
    return h > 0 ? h : 300.0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── 1. Off-screen measurement layer ──────────────────────────────
        // Each child is rendered invisible at unbounded height so we can
        // capture its natural size. Once measured it stays Offstage.
        ...List.generate(widget.children.length, (i) {
          return Offstage(
            // Keep offstage forever — we just need the layout pass.
            offstage: true,
            child: TickerMode(
              enabled: false,
              child: _HeightMeasurer(
                onMeasured: (h) => _updateHeight(i, h),
                child: widget.children[i],
              ),
            ),
          );
        }),

        // ── 2. Real TabBarView with a guaranteed bounded height ───────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          // Always a finite, positive number — never null/infinity.
          height: _activeHeight,
          child: TabBarView(
            controller: widget.controller,
            children: widget.children
                .map(
                  (child) => SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: child,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

// Measures the natural height of its child and reports it via [onMeasured].
class _HeightMeasurer extends SingleChildRenderObjectWidget {
  final ValueChanged<double> onMeasured;

  const _HeightMeasurer({required super.child, required this.onMeasured});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _HeightMeasurerBox(onMeasured);

  @override
  void updateRenderObject(
    BuildContext context,
    _HeightMeasurerBox renderObject,
  ) {
    renderObject.onMeasured = onMeasured;
  }
}

class _HeightMeasurerBox extends RenderProxyBox {
  ValueChanged<double> onMeasured;

  _HeightMeasurerBox(this.onMeasured);

  @override
  void performLayout() {
    // Give the child unconstrained vertical space so it reveals its full
    // natural height — safe here because this subtree is Offstage.
    child?.layout(
      constraints.copyWith(maxHeight: double.infinity, minHeight: 0),
      parentUsesSize: true,
    );
    // Match own size to child, clamped to parent's horizontal constraints.
    size = Size(
      constraints.constrainWidth(child?.size.width ?? 0),
      child?.size.height ?? 0,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onMeasured(size.height);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium background — identical style to PortalScreen
// ─────────────────────────────────────────────────────────────────────────────
class _ProviderPremiumBackground extends StatelessWidget {
  const _ProviderPremiumBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAF8), Color(0xFFFFFFFF)],
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.95),
                radius: 1.15,
                colors: [_kGreen.withOpacity(0.10), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _LineMeshPainter(color: _kGreen.withOpacity(0.08)),
          ),
        ),
      ],
    );
  }
}

class _LineMeshPainter extends CustomPainter {
  final Color color;
  _LineMeshPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.12)
      ..lineTo(size.width * 0.46, size.height * 0.05)
      ..lineTo(size.width * 0.92, size.height * 0.18)
      ..moveTo(size.width * 0.12, size.height * 0.36)
      ..lineTo(size.width * 0.60, size.height * 0.28)
      ..lineTo(size.width * 0.90, size.height * 0.42)
      ..moveTo(size.width * 0.06, size.height * 0.62)
      ..lineTo(size.width * 0.52, size.height * 0.52)
      ..lineTo(size.width * 0.94, size.height * 0.68);

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _LineMeshPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated app bar (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class AnimatedCustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final double height;

  const AnimatedCustomAppBar({super.key, this.height = kToolbarHeight});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProviderBookingController>();

    return ValueListenableBuilder<bool>(
      valueListenable: controller.isTabBarPinnedNotifier,
      builder: (context, isPinned, child) {
        return CustomAppBar(
          title: isPinned
              ? controller.providerDetailsContent?.provider?.companyName ??
                    "provider_details".tr
              : "provider_details".tr,
          showCart: false,
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
