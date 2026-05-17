/*
import 'package:afriendorse/athlete/feature/settings/business/widget/business_info_tab_item_widget.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BusinessSettingScreen extends StatefulWidget {
  final int? tabIndex;
  const BusinessSettingScreen({super.key, this.tabIndex});

  @override
  State<BusinessSettingScreen> createState() => _BusinessSettingScreenState();
}

class _BusinessSettingScreenState extends State<BusinessSettingScreen> {
  @override
  void initState() {
    super.initState();
    // Get.find<UserProfileController>().getProviderInfo(reload: true);
    Get.find<UserProfileController>().resetImage();

    Get.find<BusinessSettingController>().initServiceLocationValue();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessSettingController>(
      builder: (businessSettingController) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: CustomAppBar(title: "business_settings".tr),

          body: SafeArea(
            child: DefaultTabController(
              length: 3,
              initialIndex: widget.tabIndex ?? 0,
              child: Column(
                children: [
                  SizedBox(height: Dimensions.paddingSizeDefault),

                  Container(
                    height: 45,
                    margin: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: TabBar(
                      isScrollable: true,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusExtraLarge,
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      labelStyle: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                      unselectedLabelStyle: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                      tabAlignment: TabAlignment.start,
                      dividerHeight: 0,
                      labelPadding: EdgeInsets.symmetric(horizontal: 10),
                      splashBorderRadius: BorderRadius.circular(
                        Dimensions.radiusExtraLarge,
                      ),
                      tabs: [
                        Tab(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusExtraLarge,
                              ),
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.1),
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                            ),
                            child: Text("business_information".tr),
                          ),
                        ),

                        Tab(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusExtraLarge,
                              ),
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.1),
                            ),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              child: Text("service_availability".tr),
                            ),
                          ),
                        ),

                        /* Tab(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusExtraLarge,
                              ),
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.1),
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                            ),
                            child: Text("bookings".tr),
                          ),
                        ),  */
                      ],
                    ),
                  ),

                  const Expanded(
                    child: TabBarView(
                      children: [
                        BusinessInfoTabItemWidget(),

                        ServiceAvailabilityTabItemWidget(),

                        BookingSetupTabItemWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SwitchButton extends StatelessWidget {
  final String titleText;
  final String tootTipText;
  final int value;
  final Function(bool) onTap;
  final JustTheController? tooltipController;
  final bool showOutSideBorder;
  final TextStyle? titleTextStyle;
  const SwitchButton({
    super.key,
    required this.titleText,
    required this.value,
    required this.onTap,
    this.tooltipController,
    this.showOutSideBorder = false,
    this.titleTextStyle,
    required this.tootTipText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: showOutSideBorder
            ? Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
              )
            : null,
        boxShadow: context.customThemeColors.lightShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                titleText.tr,
                style:
                    titleTextStyle ??
                    robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                    ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              if (tooltipController != null)
                JustTheTooltip(
                  backgroundColor: Colors.black87,
                  controller: tooltipController,
                  preferredDirection: AxisDirection.down,
                  tailLength: 14,
                  tailBaseWidth: 20,
                  content: Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    child: Text(
                      tootTipText.tr,
                      style: robotoRegular.copyWith(color: Colors.white),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => tooltipController?.showTooltip(),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),

          FlutterSwitch(
            width: 40,
            height: 22,
            valueFontSize: Dimensions.fontSizeExtraSmall,
            showOnOff: true,
            activeText: "",
            inactiveText: "",
            activeColor: Theme.of(context).primaryColor,
            value: value == 1 ? true : false,
            padding: 1.5,
            toggleSize: 19,
            onToggle: (value) => onTap(value),
          ),
        ],
      ),
    );
  }
}
*/

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/settings/business/widget/business_info_tab_item_widget.dart';
import 'package:afriendorse/athlete/feature/settings/business/widget/athlete_media_kit_tab_item_widget.dart';
import 'package:afriendorse/athlete/feature/settings/business/widget/service_availability_tab_item_widget.dart';
import 'package:afriendorse/athlete/feature/settings/business/widget/booking_setup_tab_item_widget.dart';
import 'package:afriendorse/athlete/feature/settings/business/controller/athlete_media_kit_controller.dart';

class BusinessSettingScreen extends StatefulWidget {
  final int? tabIndex;
  const BusinessSettingScreen({super.key, this.tabIndex});

  @override
  State<BusinessSettingScreen> createState() => _BusinessSettingScreenState();
}

class _BusinessSettingScreenState extends State<BusinessSettingScreen>
    with TickerProviderStateMixin {
  static const Color kGreen = Color(0xFF045F25);

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.tabIndex ?? 0,
    );

    // Existing logic
    Get.find<UserProfileController>().resetImage();
    Get.find<BusinessSettingController>().initServiceLocationValue();

    // Ensure settings are loaded
    Get.find<BusinessSettingController>().getBookingSettingsDataFromServer();
    Get.find<BusinessSettingController>()
        .getServiceAvailabilitySettingsFromServer();

    // Ensure media kit controller is ready (completeness badge)
    Get.put(AthleteMediaKitController(), permanent: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerScrolled) {
            return [
              SliverToBoxAdapter(
                child: _PremiumHeader(tabController: _tabController),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarHeaderDelegate(
                  child: _PremiumTabBar(tabController: _tabController),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: const [
              BusinessInfoTabItemWidget(),
              AthleteMediaKitTabItemWidget(), // ✅ new NIL media kit
              ServiceAvailabilityTabItemWidget(),
              // BookingSetupTabItemWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  final TabController tabController;
  const _PremiumHeader({required this.tabController});

  static const Color kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    final providerInfo =
        Get.find<UserProfileController>().providerModel?.content?.providerInfo;

    final name =
        (providerInfo?.companyName ??
                providerInfo?.contactPersonName ??
                'Athlete')
            .toString();
    final image = (providerInfo?.logoFullPath ?? '').toString();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF045F25), Color(0xFF0A7A33)],
        ),
        boxShadow: [
          BoxShadow(
            color: kGreen.withOpacity(0.25),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<AthleteMediaKitController>(
          builder: (mk) {
            final pct = mk.completenessPercent;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top row
                Row(
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.20),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.20),
                        ),
                      ),
                      child: Text(
                        // 'Profile completeness: $pct%',
                        'Athlete Details',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: image.isEmpty
                          ? const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 30,
                            )
                          : CustomImage(
                              image: image,
                              fit: BoxFit.cover,
                              placeholder: Images.userPlaceHolder,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Complete your NIL-ready profile & media kit for brands.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.88),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // premium progress bar
                /*  ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: mk.completeness,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.20),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.92),
                    ),
                  ),
                ), */
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PremiumTabBar extends StatelessWidget {
  final TabController tabController;
  const _PremiumTabBar({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        0,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TabBar(
            controller: tabController,
            isScrollable: false,
            tabAlignment: TabAlignment.fill,
            dividerHeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [Color(0xFF045F25), Color(0xFF0A7A33)],
              ),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black.withOpacity(0.60),
            labelStyle: robotoMedium.copyWith(fontSize: 13.2),
            unselectedLabelStyle: robotoRegular.copyWith(fontSize: 13.2),
            tabs: const [
              Tab(text: 'Basic Info'),
              Tab(text: 'Media Kit'),
              Tab(text: 'Availability'),
              //  Tab(text: 'Bookings'),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _TabBarHeaderDelegate({required this.child});

  @override
  double get minExtent => 74;
  @override
  double get maxExtent => 74;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) => false;
}
