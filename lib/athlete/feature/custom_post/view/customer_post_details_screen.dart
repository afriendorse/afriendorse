import 'dart:math';
import 'package:afriendorse/athlete/feature/custom_post/widget/brand_info_chip.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/custom_post/model/post_model.dart';
import 'package:get/get.dart';

class CustomerPostDetailsScreen extends StatefulWidget {
  final PostData postData;
  final bool? fromNotification;
  final bool? fromDashboard;

  const CustomerPostDetailsScreen({
    super.key,
    required this.postData,
    this.fromNotification,
    this.fromDashboard,
  });

  @override
  State<CustomerPostDetailsScreen> createState() =>
      _CustomerPostDetailsScreenState();
}

class _CustomerPostDetailsScreenState extends State<CustomerPostDetailsScreen> {
  bool get _isDirectDeal =>
      widget.postData.targetProviderId != null &&
      widget.postData.targetProviderId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    Get.find<PostController>().resetInputValue();
    Get.find<PostController>().getProviderOfferList(
      1,
      widget.postData.id!,
      reload: true,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String get _customerFullName =>
      "${widget.postData.customer?.firstName ?? ""} "
              "${widget.postData.customer?.lastName ?? ""}"
          .trim();

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, primary),
      body: GetBuilder<PostController>(
        builder: (postController) {
          return GestureDetector(
            onTap: postController.hideInfoIcon,
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero header card ───────────────────────────────
                      _buildHeroHeader(
                        context,
                        postController,
                        primary,
                        isDark,
                      ),

                      // ── Body content ───────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Direct deal callout
                            if (_isDirectDeal) ...[
                              const SizedBox(height: 20),
                              _buildDirectDealBanner(context, primary),
                            ],

                            const SizedBox(height: 28),

                            // Deal type label
                            _buildSectionLabel(
                              context,
                              icon: Icons.handshake_outlined,
                              label: "deal_overview".tr,
                            ),
                            const SizedBox(height: 12),

                            // Service card
                            _buildServiceCard(context, primary, isDark),

                            const SizedBox(height: 20),
                            _buildServicePriceInfo(context, primary),

                            //  const SizedBox(height: 28),

                            // Description
                            /*   _buildSectionLabel(
                              context,
                              icon: Icons.article_outlined,
                              label: "description".tr,
                            ),
                            const SizedBox(height: 12), */
                            _buildDescriptionCard(context, isDark),

                            // Additional instructions
                            if (widget.postData.additionInstructions != null &&
                                widget
                                    .postData
                                    .additionInstructions!
                                    .isNotEmpty) ...[
                              const SizedBox(height: 28),
                              _buildSectionLabel(
                                context,
                                icon: Icons.checklist_rounded,
                                label: "additional_instruction".tr,
                              ),
                              const SizedBox(height: 12),
                              _buildInstructionsList(context, primary),
                            ],

                            // Bottom spacing for FAB + bottom sheet
                            const SizedBox(height: 140),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Tooltip overlay — sits above everything
                if (postController.showInfoWidget)
                  _buildTooltipOverlay(context),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildSeeOffersButton(context),
      bottomSheet: _buildPlaceOfferBar(context),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context, Color primary) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
      title: Text(
        "service_request".tr,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          letterSpacing: 0.3,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Hero header ────────────────────────────────────────────────────────────

  Widget _buildHeroHeader(
    BuildContext context,
    PostController postController,
    Color primary,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [primary.withOpacity(0.25), primary.withOpacity(0.08)]
              : [primary.withOpacity(0.12), primary.withOpacity(0.03)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: primary.withOpacity(isDark ? 0.25 : 0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        child: Column(
          children: [
            // Title row
            _buildHeaderTitleRow(context, postController, primary),
            const SizedBox(height: 24),

            // Avatar
            _buildAvatar(context, primary),
            const SizedBox(height: 16),

            // Name
            Text(
              _customerFullName,
              style: robotoBold.copyWith(fontSize: 18, letterSpacing: 0.2),
            ),
            const SizedBox(height: 6),

            // Distance
            //  _buildDistanceRow(context),
            //   const SizedBox(height: 14),

            // Divider
            Container(
              height: 1,
              width: 60,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),

            // Brand + industry chips
            BrandInfoChip(email: widget.postData.customer?.email),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTitleRow(
    BuildContext context,
    PostController postController,
    Color primary,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Direct deal badge
        if (_isDirectDeal) ...[
          // _DirectDealBadge(primary: primary),
          const SizedBox(width: 8),
        ],

        Flexible(
          child: Text(
            "new_booking_request_from".tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Colors.black,
              letterSpacing: 0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(width: 6),

        // Info icon
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: postController.changeVisibilityInfoWidgetStatus,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: primary,
                ),
              ),
            ),
            if (postController.showInfoWidget)
              Positioned(
                top: 26,
                child: Transform.rotate(
                  angle: 45 * pi / 180,
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, Color primary) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Outer glow ring
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                primary.withOpacity(0.9),
                primary.withOpacity(0.2),
                primary.withOpacity(0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.25),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: ClipOval(
              child: CustomImage(
                height: 72,
                width: 72,
                fit: BoxFit.cover,
                image: widget.postData.customer?.profileImageFullPath ?? "",
              ),
            ),
          ),
        ),

        // Verified badge
        Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 2,
            ),
          ),
          child: const Icon(Icons.check_rounded, size: 11, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDistanceRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on_rounded,
          size: 13,
          color: Theme.of(context).secondaryHeaderColor.withOpacity(0.5),
        ),
        const SizedBox(width: 3),
        Text(
          "${widget.postData.distance ?? "0 km"} ${'away_from_you'.tr}",
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).secondaryHeaderColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  // ── Tooltip overlay ────────────────────────────────────────────────────────

  Widget _buildTooltipOverlay(BuildContext context) {
    return Positioned(
      top: 80,
      left: 24,
      right: 24,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).primaryColorDark.withOpacity(0.96),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: Text(
            "accept_service_request_instruction".tr,
            style: robotoRegular.copyWith(
              color: Colors.white.withOpacity(0.85),
              fontSize: Dimensions.fontSizeSmall,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ── Direct deal banner ─────────────────────────────────────────────────────

  Widget _buildDirectDealBanner(BuildContext context, Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.12), primary.withOpacity(0.05)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.lock_rounded, size: 14, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "direct_deal".tr.toUpperCase(),
                  style: robotoMedium.copyWith(
                    fontSize: 10,
                    color: Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "this_brand_sent_you_a_direct_deal".tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _buildSectionLabel(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final primary = Theme.of(context).primaryColor;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: primary),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ── Service card (Modal style) ─────────────────────────────────────────────

  Widget _buildServiceCard(BuildContext context, Color primary, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Optional: Show service details modal
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Color(0xFF2A2A2A), Color(0xFF1F1F1F)]
                  : [Colors.white, Color(0xFFF8F9FA)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : primary.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Service thumbnail with elevated style
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomImage(
                    image: "${widget.postData.service?.thumbnailFullPath}",
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Service info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.postData.service?.name ?? "",
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        letterSpacing: 0.2,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_outlined, size: 12, color: primary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.postData.subCategory?.name ?? "",
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: primary.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow with background
              /*  Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: primary,
                  size: 20,
                ),
              ), */
            ],
          ),
        ),
      ),
    );
  }

  // ── Service Price Info ───────────────────────────────────────────
  Widget _buildServicePriceInfo(BuildContext context, Color primary) {
    final servicePrice = widget.postData.service?.minBiddingPrice ?? "0";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: primary,
              ),
              const SizedBox(width: 8),
              Text(
                "service_budget".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            PriceConverter.convertPrice(
              double.tryParse(servicePrice.toString()) ?? 0,
            ),
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge,
              color: primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "place_your_offer_around_this_budget".tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Description card (Modal style) ───────────────────────────────────────────

  Widget _buildDescriptionCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [Color(0xFF2A2A2A).withOpacity(0.8), Color(0xFF1F1F1F)]
              : [Color(0xFFF8F9FA), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Description",
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          Text(
            widget.postData.serviceDescription ?? "",
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              height: 1.7,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.85),
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
  // ── Instructions list ──────────────────────────────────────────────────────

  Widget _buildInstructionsList(BuildContext context, Color primary) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.postData.additionInstructions!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: primary.withOpacity(0.15)),
            color: primary.withOpacity(0.04),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Numbered badge
              Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${index + 1}",
                  style: robotoMedium.copyWith(
                    fontSize: 11,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.postData.additionInstructions![index].details ?? "",
                  style: robotoRegular.copyWith(
                    color: Colors.black,
                    fontSize: Dimensions.fontSizeDefault,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── See offers FAB ─────────────────────────────────────────────────────────

  Widget? _buildSeeOffersButton(BuildContext context) {
    final configAllows =
        Get.find<SplashController>()
            .configModel
            .content
            ?.bidOfferVisibilityForProvider ==
        1;

    if (_isDirectDeal || !configAllows) return null;

    final primary = Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.18, vertical: 58),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            isScrollControlled: false,
            backgroundColor: Colors.transparent,
            context: Get.context!,
            builder: (context) => const OtherProviderOfferScreen(),
          );
        },
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: primary.withOpacity(0.2)),
            boxShadow: Get.isDarkMode
                ? null
                : [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 16,
                      color: Colors.black.withOpacity(0.12),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline_rounded, size: 15, color: primary),
              const SizedBox(width: 7),
              Text(
                "see_other_provider_offers".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: primary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Place offer bar ────────────────────────────────────────────────────────

  Widget _buildPlaceOfferBar(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Get.find<BusinessSubscriptionController>()
                  .openTrialEndBottomSheet()
                  .then((isTrial) async {
                    if (isTrial) {
                      if (Get.find<UserProfileController>()
                          .checkAvailableFeatureInSubscriptionPlan(
                            featureType: 'bidding',
                          )) {
                        Get.off(
                          () => ProviderOfferScreen(
                            postData: widget.postData,
                            fromNotification: widget.fromNotification,
                            fromDashboard: widget.fromDashboard,
                          ),
                        );
                      }
                    }
                  });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_offer_rounded,
                  size: 17,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  "place_your_offer".tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.white,
                    letterSpacing: 0.3,
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

// ── Direct deal badge widget ───────────────────────────────────────────────────

class _DirectDealBadge extends StatelessWidget {
  final Color primary;

  const _DirectDealBadge({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: primary.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 12, color: primary),
          const SizedBox(width: 4),
          Text(
            "direct_deal".tr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
