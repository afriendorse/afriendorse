/*
import 'package:afriendorse/athlete/feature/wallet/screen/wallet_screen.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<UserProfileController>(
        initState: (_) async {
          Get.find<BusinessSettingController>()
              .getBookingSettingsDataFromServer();
          Get.find<BankInfoController>().getBankInfoData();
          Get.find<UserProfileController>().getProviderInfo(reload: true);
          Get.find<TransactionController>().getWithdrawMethods();
        },
        builder: (userController) {
          if (userController.providerModel != null) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  profileHeaderSection(context, userController),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  GestureDetector(
                    onTap: () => Get.to(() => const ProfileInformationScreen()),
                    child: ProfileCardItem(
                      title: "edit_profile",
                      leadingIcon: Images.profileInformation,
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Get.to(() => const AccountInformation()),
                    child: ProfileCardItem(
                      title: "account_information",
                      leadingIcon: Images.accountInformation,
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Get.to(() => const AthleteWalletScreen()),
                    child: ProfileCardItem(
                      title: "wallet",
                      leadingIcon: Images.accountInformation,
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Get.to(() => const BusinessSettingScreen()),
                    child: ProfileCardItem(
                      title: "business_settings",
                      leadingIcon: Images.businessSettings,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Get.find<BusinessSubscriptionController>()
                          .openTrialEndBottomSheet()
                          .then((isTrial) {
                            if (isTrial) {
                              if (userController
                                  .checkAvailableFeatureInSubscriptionPlan(
                                    featureType: 'review',
                                  )) {
                                Get.to(() => const ProviderReviewScreen());
                              }
                            }
                          });
                    },
                    child: ProfileCardItem(
                      title: "reviews",
                      leadingIcon: Images.reviewIcon,
                    ),
                  ),

                  /* GestureDetector(
                    onTap: () => Get.toNamed(RouteHelper.bankInfo),
                    child: ProfileCardItem(
                      title: "bank_information",
                      leadingIcon: Images.bankInformation,
                    ),
                  ), */
                  (Get.find<UserProfileController>()
                              .providerModel
                              ?.content
                              ?.subscriptionInfo
                              ?.status ==
                          "commission_base")
                      ? GestureDetector(
                          onTap: () => showCustomBottomSheet(
                            child: const CommissionBottomSheet(),
                          ),
                          child: ProfileCardItem(
                            title: "commission",
                            leadingIcon: Images.commission,
                            isDarkItem: true,
                          ),
                        )
                      : const SizedBox(),

                  GestureDetector(
                    onTap: () => showCustomBottomSheet(
                      child: const PromotionBottomSheet(),
                    ),
                    child: ProfileCardItem(
                      title: "promotional_cost",
                      leadingIcon: Images.promotionalCostIcon,
                      isDarkItem: true,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Get.find<BusinessSubscriptionController>()
                          .openTrialEndBottomSheet()
                          .then((isTrial) {
                            if (isTrial) {
                              if (userController
                                  .checkAvailableFeatureInSubscriptionPlan(
                                    featureType: "service_request",
                                  )) {
                                Get.toNamed(RouteHelper.suggestService);
                              }
                            }
                          });
                    },
                    child: ProfileCardItem(
                      title: "suggest_service",
                      leadingIcon: Images.suggestServiceIcon,
                      isDarkItem: true,
                    ),
                  ),

                  Get.find<SplashController>()
                              .configModel
                              .content
                              ?.providerSlfDelete ==
                          1
                      ? GestureDetector(
                          onTap: () {
                            showCustomBottomSheet(
                              child: const DeleteAccountBottomSheet(),
                            );
                          },
                          child: ProfileCardItem(
                            title: "delete_account".tr,
                            leadingIcon: Images.servicemanDelete,
                            isDarkItem: true,
                          ),
                        )
                      : const SizedBox(),

                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  RichText(
                    text: TextSpan(
                      text: "app_version".tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).primaryColor,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: " ${AppConstants.appVersion} ",
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).hoverColor,
              ),
            );
          }
        },
      ),
    );
  }

  Widget profileHeaderSection(context, UserProfileController userController) {
    return Container(
      height: 310,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        color: Get.isDarkMode
            ? Theme.of(context).primaryColorDark
            : Theme.of(context).primaryColor,
      ),

      child: Stack(
        children: [
          Container(
            height: 250,
            width:
                MediaQuery.of(context).size.width -
                MediaQuery.of(context).size.width / 4,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(300),
              ),
              color: Colors.white.withValues(alpha: .05),
              boxShadow: Get.isDarkMode
                  ? null
                  : [
                      BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 5,
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.3),
                      ),
                    ],
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeSmall,
                  left: Dimensions.paddingSizeSmall,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                            color: light.cardColor,
                          ),
                        ),
                        Text(
                          "my_profile".tr,
                          style: robotoMedium.copyWith(
                            fontSize: 16,
                            color: light.cardColor,
                          ),
                        ),
                      ],
                    ),

                    GetBuilder<ThemeController>(
                      builder: (themeController) {
                        return GestureDetector(
                          onTap: () => themeController.toggleTheme(),
                          child: Container(
                            height: 25,
                            width: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            child: Row(
                              mainAxisAlignment: themeController.darkTheme
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 22,
                                  width: 22,
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(0, 2),
                                        blurRadius: 5,
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ],
                                    color: light.cardColor,
                                  ),
                                  child: Icon(
                                    themeController.darkTheme
                                        ? Icons.dark_mode_outlined
                                        : Icons.light_mode_outlined,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CustomImage(
                        height: 80,
                        width: 80,
                        image:
                            userController
                                .providerModel
                                ?.content
                                ?.providerInfo
                                ?.logoFullPath ??
                            "",
                        placeholder: Images.userPlaceHolder,
                      ),
                    ),

                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userController
                                    .providerModel
                                    ?.content
                                    ?.providerInfo
                                    ?.companyName ??
                                "",
                            style: robotoBold.copyWith(
                              fontSize: 17,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),

                          Text(
                            userController
                                    .providerModel
                                    ?.content
                                    ?.providerInfo
                                    ?.companyPhone ??
                                userController
                                    .providerModel
                                    ?.content
                                    ?.providerInfo
                                    ?.companyEmail ??
                                "",
                            style: robotoBold.copyWith(
                              fontSize: 17,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: Get.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ColumnText(
                      amount:
                          Get.find<DashboardController>()
                              .dashboardTopCards
                              ?.totalSubscribedServices
                              .toString() ??
                          "",
                      title: "total_subscription".tr,
                    ),

                    ColumnText(
                      amount:
                          Get.find<DashboardController>()
                              .dashboardTopCards
                              ?.totalBookingServed
                              .toString() ??
                          "",
                      title: "Booking_Served".tr,
                    ),

                    ColumnText(
                      amount: DateTime.now()
                          .difference(
                            DateConverter.isoStringToLocalDate(
                              userController
                                      .providerModel
                                      ?.content
                                      ?.providerInfo
                                      ?.createdAt
                                      .toString() ??
                                  DateTime.now().toString(),
                            ),
                          )
                          .inDays
                          .toString(),
                      title: "Days_Since_Joined".tr,
                    ),
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

*/

// lib/athlete/feature/profile/screens/profile_screen.dart
// FULL REVAMP — replaces the existing profile_screen.dart
// lib/athlete/feature/profile/screens/profile_screen.dart

import 'package:afriendorse/athlete/feature/auth/repository/athlete_firestore_sync_service.dart';
import 'package:afriendorse/athlete/feature/profile/service/athlete_profile_deep_link_service.dart';
import 'package:afriendorse/athlete/feature/profile/view/view/athlete_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/campaigns/controller/campaign_controller.dart';
import 'package:afriendorse/athlete/feature/campaigns/model/campaign_model.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/campaign_detail_screen.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/campaigns_screen.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/create_campaign_flow.dart';
import 'package:afriendorse/athlete/feature/wallet/screen/wallet_screen.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/shared/currency_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  AltCampaignController? _campaignCtrl;

  String? _firestoreVerificationStatus;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    try {
      _campaignCtrl = Get.find<AltCampaignController>();
    } catch (_) {
      _campaignCtrl = Get.put(AltCampaignController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final upc = Get.find<UserProfileController>();
      final info = upc.providerModel?.content?.providerInfo;
      final athleteEmail = info?.owner?.email ?? info?.companyEmail ?? '';

      if (athleteEmail.isNotEmpty) {
        _campaignCtrl?.listenToMyCampaigns(athleteEmail);

        final status = await AthleteFirestoreSyncService.getVerificationStatus(
          athleteEmail,
        );
        if (mounted) setState(() => _firestoreVerificationStatus = status);
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ─── Verification helpers ─────────────────────────────────────────────────

  String get _verificationChipLabel => switch (_firestoreVerificationStatus) {
    'verified' => 'Verified',
    'pending' => 'Pending',
    'rejected' => 'Rejected',
    _ => 'Unverified',
  };

  Color get _verificationChipColor => switch (_firestoreVerificationStatus) {
    'verified' => const Color(0xFF045F25),
    'pending' => Colors.amber,
    'rejected' => Colors.red,
    _ => Colors.grey,
  };

  // ─── Share handler ────────────────────────────────────────────────────────

  Future<void> _onShareTap(UserProfileController userCtrl) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    final info = userCtrl.providerModel?.content?.providerInfo;
    final email = info?.owner?.email ?? info?.companyEmail ?? '';
    final name = info?.companyName ?? 'Athlete';

    await AthleteProfileDeepLinkService.shareAthleteProfile(
      athleteEmail: email,
      athleteName: name,
    );

    if (mounted) setState(() => _isSharing = false);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<UserProfileController>(
        initState: (_) async {
          Get.find<BusinessSettingController>()
              .getBookingSettingsDataFromServer();
          Get.find<BankInfoController>().getBankInfoData();
          Get.find<UserProfileController>().getProviderInfo(reload: true);
          Get.find<TransactionController>().getWithdrawMethods();
        },
        builder: (userCtrl) {
          if (userCtrl.providerModel == null) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).hoverColor,
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              slivers: [
                _buildSliverHeader(context, userCtrl),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _CampaignStrip(
                        campaignCtrl: _campaignCtrl,
                        athleteId:
                            userCtrl
                                .providerModel
                                ?.content
                                ?.providerInfo
                                ?.owner
                                ?.email ??
                            '',
                      ),
                      const SizedBox(height: 8),
                      _buildMenuSection(context, userCtrl),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          text: 'app_version'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).primaryColor,
                          ),
                          children: [
                            TextSpan(
                              text: ' ${AppConstants.appVersion} ',
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Sliver Header ────────────────────────────────────────────────────────

  Widget _buildSliverHeader(
    BuildContext context,
    UserProfileController userCtrl,
  ) {
    final info = userCtrl.providerModel?.content?.providerInfo;

    return SliverAppBar(
      expandedHeight: 270, // slightly taller to fit the share button row
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),

      // ── AppBar-level share icon (visible when header is collapsed) ────────
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _isSharing
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  tooltip: 'Share profile',
                  icon: const Icon(
                    Icons.ios_share_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => _onShareTap(userCtrl),
                ),
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // ── Green gradient ──────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    const Color(0xFF033D18),
                  ],
                ),
              ),
            ),

            // ── Decorative circles ──────────────────────────────────────────
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: 60,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            // ── Content ─────────────────────────────────────────────────────
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // ── Avatar row ────────────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CustomImage(
                                height: 76,
                                width: 76,
                                image: info?.logoFullPath ?? '',
                                placeholder: Images.userPlaceHolder,
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Name / email / edit button
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  info?.companyName ?? '',
                                  style: robotoBold.copyWith(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  info?.companyEmail ??
                                      info?.companyPhone ??
                                      '',
                                  style: robotoRegular.copyWith(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),

                                // ── Edit + Share buttons side-by-side ────────
                                Row(
                                  children: [
                                    // Edit Profile pill
                                    GestureDetector(
                                      onTap: () => Get.to(
                                        () => const ProfileInformationScreen(),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.edit,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Edit Profile',
                                              style: robotoRegular.copyWith(
                                                color: Colors.white,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // ── Share Profile pill ────────────────────
                                    // This is the prominent, always-visible
                                    // share button inside the expanded card.
                                    GestureDetector(
                                      onTap: _isSharing
                                          ? null
                                          : () => _onShareTap(userCtrl),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          // Slightly brighter so it stands out
                                          color: Colors.white.withOpacity(0.22),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.5,
                                            ),
                                          ),
                                        ),
                                        child: _isSharing
                                            ? const SizedBox(
                                                width: 14,
                                                height: 14,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 1.5,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.ios_share_rounded,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Share Profile',
                                                    style: robotoRegular
                                                        .copyWith(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                        ),
                                                  ),
                                                ],
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

                      const SizedBox(height: 20),

                      // ── Stats row ─────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _HeaderStat(
                              value:
                                  Get.find<DashboardController>()
                                      .dashboardTopCards
                                      ?.totalSubscribedServices
                                      .toString() ??
                                  '0',
                              label: 'Services',
                            ),
                            _HeaderDivider(),
                            _HeaderStat(
                              value:
                                  Get.find<DashboardController>()
                                      .dashboardTopCards
                                      ?.totalBookingServed
                                      .toString() ??
                                  '0',
                              label: 'Deals',
                            ),
                            _HeaderDivider(),
                            _HeaderStat(
                              value: DateTime.now()
                                  .difference(
                                    DateConverter.isoStringToLocalDate(
                                      info?.createdAt.toString() ??
                                          DateTime.now().toString(),
                                    ),
                                  )
                                  .inDays
                                  .toString(),
                              label: 'Days joined',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Menu Section ─────────────────────────────────────────────────────────

  Widget _buildMenuSection(
    BuildContext context,
    UserProfileController userCtrl,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _MenuGroup(
            title: 'Account',
            items: [
              _MenuItem(
                icon: Icons.person_outline,
                iconColor: Colors.blue,
                title: 'Change password',
                onTap: () => Get.to(() => const ProfileInformationScreen()),
              ),
              _MenuItem(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFF045F25),
                title: 'Wallet',
                subtitle: 'View earnings & withdraw',
                onTap: () => Get.to(() => const AthleteWalletScreen()),
              ),
              _MenuItem(
                icon: Icons.campaign_outlined,
                iconColor: Colors.orange,
                title: 'My Campaigns',
                subtitle: 'Discover & manage your campaigns',
                onTap: () => Get.to(() => const CampaignsScreen()),
                trailing: _campaignCtrl != null
                    ? Obx(() {
                        final count = _campaignCtrl!.myCampaigns
                            .where((c) => c.isActive)
                            .length;
                        if (count == 0) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      })
                    : null,
              ),
              _MenuItem(
                icon: Icons.verified_user_outlined,
                iconColor: _verificationChipColor,
                title: 'Identity Verification',
                subtitle: 'Upload ID • Get Badge • Build Trust',
                onTap: () async {
                  await Get.to(() => const AthleteVerificationScreen());
                  final email =
                      Get.find<UserProfileController>()
                          .providerModel
                          ?.content
                          ?.providerInfo
                          ?.owner
                          ?.email ??
                      '';
                  if (email.isNotEmpty && mounted) {
                    final status =
                        await AthleteFirestoreSyncService.getVerificationStatus(
                          email,
                        );
                    if (mounted) {
                      setState(() => _firestoreVerificationStatus = status);
                    }
                  }
                },
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _verificationChipColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _verificationChipColor.withOpacity(0.30),
                    ),
                  ),
                  child: Text(
                    _verificationChipLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _verificationChipColor,
                    ),
                  ),
                ),
              ),
              _MenuItem(
                icon: Icons.ios_share_rounded,
                iconColor: const Color(0xFF045F25),
                title: 'Share My Profile',
                subtitle: 'Invite brands & fans to your NIL page',
                onTap: () => _onShareTap(Get.find<UserProfileController>()),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _MenuGroup(
            title: 'Business',
            items: [
              _MenuItem(
                icon: Icons.settings_outlined,
                iconColor: Colors.blueGrey,
                title: 'Athlete Bio Settings',
                subtitle: 'Manage your NIL Profile',
                onTap: () => Get.to(() => const BusinessSettingScreen()),
              ),
              _MenuItem(
                icon: Icons.star_outline,
                iconColor: Colors.amber,
                title: 'Reviews',
                onTap: () {
                  Get.find<BusinessSubscriptionController>()
                      .openTrialEndBottomSheet()
                      .then((isTrial) {
                        if (isTrial &&
                            userCtrl.checkAvailableFeatureInSubscriptionPlan(
                              featureType: 'review',
                            )) {
                          Get.to(() => const ProviderReviewScreen());
                        }
                      });
                },
              ),
              if (userCtrl.providerModel?.content?.subscriptionInfo?.status ==
                  'commission_base')
                _MenuItem(
                  icon: Icons.percent,
                  iconColor: Colors.purple,
                  title: 'Commission',
                  isDark: true,
                  onTap: () => showCustomBottomSheet(
                    child: const CommissionBottomSheet(),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          _MenuGroup(
            title: 'More',
            items: [
              _MenuItem(
                icon: Icons.groups_outlined,
                iconColor: Colors.indigo,
                title: 'Groups & Clubs',
                onTap: () => Get.toNamed(RouteHelper.groups),
              ),
              _MenuItem(
                icon: Icons.payment_outlined,
                iconColor: Colors.green,
                title: 'Payment Information',
                onTap: () => Get.toNamed(RouteHelper.paymentInformation),
              ),
              _MenuItem(
                icon: Icons.help_outline,
                iconColor: Colors.orange,
                title: 'Help & Support',
                onTap: () => Get.toNamed(RouteHelper.helpAndSupport),
              ),
              if (Get.find<SplashController>()
                      .configModel
                      .content
                      ?.providerSlfDelete ==
                  1)
                _MenuItem(
                  icon: Icons.delete_outline,
                  iconColor: Colors.red,
                  title: 'Delete Account',
                  onTap: () => showCustomBottomSheet(
                    child: const DeleteAccountBottomSheet(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── All unchanged small widgets below ────────────────────────────────────────

class _CampaignStrip extends StatelessWidget {
  final AltCampaignController? campaignCtrl;
  final String athleteId;
  const _CampaignStrip({required this.campaignCtrl, required this.athleteId});

  @override
  Widget build(BuildContext context) {
    if (campaignCtrl == null) return const SizedBox.shrink();
    return Obx(() {
      final campaigns = campaignCtrl!.myCampaigns;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Row(
              children: [
                const Text(
                  '🚀 My Campaigns',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Get.to(() => const CampaignsScreen()),
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      color: Color(0xFF045F25),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (campaigns.isEmpty)
            GestureDetector(
              onTap: () => showCreateCampaignFlow(context),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF045F25).withOpacity(0.2),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF045F25).withOpacity(0.04),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF045F25).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.campaign_outlined,
                        color: Color(0xFF045F25),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Launch Your First Campaign',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Raise funds from fans & sponsors',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: campaigns.length + 1,
                itemBuilder: (_, i) {
                  if (i == campaigns.length) {
                    return GestureDetector(
                      onTap: () => showCreateCampaignFlow(context),
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF045F25).withOpacity(0.25),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF045F25).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Color(0xFF045F25),
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'New\nCampaign',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF045F25),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final c = campaigns[i];
                  return GestureDetector(
                    onTap: () {
                      campaignCtrl!.selectCampaign(c);
                      Get.to(() => CampaignDetailScreen(campaign: c));
                    },
                    child: _ProfileCampaignCard(campaign: c),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _CampaignAggStat(
                    label: 'Total Raised',
                    value:
                        '${Currency.symbol}${_fmtLarge(campaigns.fold<double>(0, (s, c) => s + c.raisedAmount))}',
                    icon: Icons.trending_up,
                    color: const Color(0xFF045F25),
                  ),
                  const SizedBox(width: 10),
                  _CampaignAggStat(
                    label: 'Total Donors',
                    value:
                        '${campaigns.fold<int>(0, (s, c) => s + c.donorCount)}',
                    icon: Icons.favorite,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 10),
                  _CampaignAggStat(
                    label: 'Goals Hit',
                    value: '${campaigns.where((c) => c.isGoalReached).length}',
                    icon: Icons.flag,
                    color: Colors.amber,
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  String _fmtLarge(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _ProfileCampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  const _ProfileCampaignCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                campaign.coverImage != null && campaign.coverImage!.isNotEmpty
                    ? Image.network(
                        campaign.coverImage!,
                        height: 70,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _MiniCoverFallback(),
                      )
                    : _MiniCoverFallback(),
                if (campaign.isGoalReached)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: Text('🏆', style: TextStyle(fontSize: 14)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: campaign.progressPercent,
                  backgroundColor: const Color(0xFF045F25).withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF045F25)),
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${Currency.symbol}${_fmt(campaign.raisedAmount)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: Color(0xFF045F25),
                      ),
                    ),
                    Text(
                      '${(campaign.progressPercent * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
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

  String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _MiniCoverFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF056B2A), Color(0xFF033D18)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.campaign_outlined,
          color: Colors.white.withOpacity(0.3),
          size: 24,
        ),
      ),
    );
  }
}

class _CampaignAggStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _CampaignAggStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: Colors.grey.withOpacity(0.08),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDark = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[trailing!, const SizedBox(width: 4)],
            Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeaderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }
}

class _HeaderDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withOpacity(0.2),
    );
  }
}
