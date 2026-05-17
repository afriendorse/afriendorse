import 'dart:math';
import 'package:afriendorse/athlete/feature/custom_post/widget/brand_info_chip.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/custom_post/model/post_model.dart';
import 'package:get/get.dart';

class ProviderOfferScreen extends StatefulWidget {
  final PostData postData;
  final bool? fromNotification;
  final bool? fromDashboard;

  const ProviderOfferScreen({
    super.key,
    required this.postData,
    this.fromNotification,
    this.fromDashboard,
  });

  @override
  State<ProviderOfferScreen> createState() => _ProviderOfferScreenState();
}

class _ProviderOfferScreenState extends State<ProviderOfferScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<PostController>().resetInputValue();
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
      appBar: _buildAppBar(context),
      body: ExpandableBottomSheet(
        background: GetBuilder<PostController>(
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
                        // ── Hero header ──────────────────────────────────
                        _buildHeroHeader(
                          context,
                          postController,
                          primary,
                          isDark,
                        ),

                        // ── Form body ────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Service card
                              _buildSectionLabel(
                                context,
                                icon: Icons.handshake_outlined,
                                label: "deal_overview".tr,
                              ),
                              const SizedBox(height: 12),
                              _buildServiceCard(context, primary, isDark),

                              const SizedBox(height: 20),
                              _buildServicePriceInfo(context, primary),

                              const SizedBox(height: 28),

                              // Offer price field
                              _buildSectionLabel(
                                context,
                                icon: Icons.local_offer_rounded,
                                label: "offer_price".tr,
                              ),
                              const SizedBox(height: 12),
                              _buildPriceField(
                                context,
                                postController,
                                primary,
                                isDark,
                              ),

                              const SizedBox(height: 28),

                              // Note field
                              _buildNoteSection(
                                context,
                                postController,
                                primary,
                                isDark,
                              ),

                              const SizedBox(height: 18),

                              _buildActionButtons(
                                context,
                                postController,
                                primary,
                                isDark,
                              ),

                              // Bottom padding for expandable sheet
                              const SizedBox(height: 130),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tooltip overlay
                  if (postController.showInfoWidget)
                    _buildTooltipOverlay(context),
                ],
              ),
            );
          },
        ),

        // Required parameter - provide empty SizedBox
        expandableContent: const SizedBox.shrink(),
        persistentContentHeight: 0, // Set to 0 since we don't use it
        /*  persistentContentHeight: 80,

         expandableContent: GetBuilder<PostController>(
          builder: (postController) {
            return _buildExpandableActions(
              context,
              postController,
              primary,
              isDark,
            );
          },
        ), */
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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

  // ── Service card ───────────────────────────────────────────────────────────

  Widget _buildServiceCard(BuildContext context, Color primary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImage(
                image: "${widget.postData.service?.thumbnailFullPath}",
                height: 52,
                width: 52,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.postData.service?.name ?? "",
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.folder_outlined, size: 12, color: Colors.black),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.postData.subCategory?.name ?? "",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          /*  Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).secondaryHeaderColor.withOpacity(0.3),
            size: 20,
          ), */
        ],
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

  // ── Price field ────────────────────────────────────────────────────────────
  Widget _buildPriceField(
    BuildContext context,
    PostController postController,
    Color primary,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // Currency badge
          Container(
            height: 56,
            width: 52,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.4),
                ),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              "\$",
              style: robotoBold.copyWith(fontSize: 20, color: primary),
            ),
          ),

          // Input with formatter
          Expanded(
            child: TextField(
              controller: postController.offerPriceController,
              focusNode: postController.offerPriceNode,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(
                context,
              ).requestFocus(postController.providerNoteNode),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: InputDecoration(
                hintText: "e.g. 100",
                hintStyle: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                isDense: true,
              ),
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Note section ───────────────────────────────────────────────────────────

  Widget _buildNoteSection(
    BuildContext context,
    PostController postController,
    Color primary,
    bool isDark,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.sticky_note_2_outlined,
                    size: 14,
                    color: primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "add_your_note".tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 6),

                // Note info icon
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    GestureDetector(
                      onTap: postController.changeNoteWidgetStatus,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 13,
                          color: primary,
                        ),
                      ),
                    ),
                    if (postController.showNoteInfoWidget)
                      Positioned(
                        top: 26,
                        child: Transform.rotate(
                          angle: 45 * pi / 180,
                          child: Container(
                            height: 10,
                            width: 10,
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
            ),

            // Note tooltip
            if (postController.showNoteInfoWidget) ...[
              const SizedBox(height: 8),
              Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(14),
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(context).primaryColorDark.withOpacity(0.96),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  child: Text(
                    "post_service_request_instruction".tr,
                    style: robotoRegular.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: Dimensions.fontSizeSmall,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Note text area
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.4),
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: CustomTextFormField(
                hintText: "write_something".tr,
                inputType: TextInputType.text,
                maxLines: 5,
                controller: postController.providerNoteController,
                focusNode: postController.providerNoteNode,
                inputAction: TextInputAction.done,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Expandable actions ─────────────────────────────────────────────────────

  /*  Widget _buildExpandableActions(
    BuildContext context,
    PostController postController,
    Color primary,
    bool isDark,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            height: 4,
            width: 44,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              children: [
                if (!postController.isLoading) ...[
                  // ── Send offer button ──────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final double amount =
                            double.tryParse(
                              postController.offerPriceController.text,
                            ) ??
                            0;
                        final double minBiddingAmount =
                            widget.postData.service?.minBiddingPrice ?? 0;

                        if (postController.offerPriceController.text.isEmpty) {
                          showCustomSnackBar(
                            "enter_your_offer_price".tr,
                            type: ToasterMessageType.info,
                          );
                        } else if (amount < minBiddingAmount) {
                          showCustomSnackBar(
                            "${'minimum_bidding_amount'.tr} "
                            "${PriceConverter.convertPrice(minBiddingAmount)}",
                          );
                        } else {
                          postController.bidCustomBooking(
                            postId: widget.postData.id,
                            offerPrice:
                                postController.offerPriceController.text,
                            note:
                                postController
                                    .providerNoteController
                                    .text
                                    .isNotEmpty
                                ? postController.providerNoteController.text
                                : "",
                            fromNotification: widget.fromNotification,
                            fromDashboard: widget.fromDashboard,
                          );
                        }
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
                            Icons.send_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "send_your_offer".tr,
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

                  const SizedBox(height: 10),

                  // ── Not interested button ──────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () async {
                        showCustomDialog(child: const CustomLoader());
                        await Get.find<PostController>().rejectCustomerPost(
                          widget.postData.id!,
                        );
                        Get.back();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'not_interested'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).colorScheme.error,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // ── Loading state ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],
            ),
          ),
        ],
      ),
    );
  } */

  Widget _buildActionButtons(
    BuildContext context,
    PostController postController,
    Color primary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      /*  decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
         borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ], 
      ),*/
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!postController.isLoading) ...[
            // ── Send offer button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final double amount =
                      double.tryParse(
                        postController.offerPriceController.text.replaceAll(
                          ',',
                          '',
                        ),
                      ) ??
                      0;
                  final double minBiddingAmount =
                      widget.postData.service?.minBiddingPrice ?? 0;

                  if (postController.offerPriceController.text.isEmpty) {
                    showCustomSnackBar(
                      "enter_your_offer_price".tr,
                      type: ToasterMessageType.info,
                    );
                  } else if (amount < minBiddingAmount) {
                    showCustomSnackBar(
                      "${'minimum_bidding_amount'.tr} "
                      "${PriceConverter.convertPrice(minBiddingAmount)}",
                    );
                  } else {
                    postController.bidCustomBooking(
                      postId: widget.postData.id,
                      offerPrice: postController.offerPriceController.text
                          .replaceAll(',', ''),
                      note:
                          postController.providerNoteController.text.isNotEmpty
                          ? postController.providerNoteController.text
                          : "",
                      fromNotification: widget.fromNotification,
                      fromDashboard: widget.fromDashboard,
                    );
                  }
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
                      Icons.send_rounded,
                      size: 17,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "send_your_offer".tr,
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

            const SizedBox(height: 12),

            // ── Not interested button ──────────────────────────
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () async {
                  showCustomDialog(child: const CustomLoader());
                  await Get.find<PostController>().rejectCustomerPost(
                    widget.postData.id!,
                  );
                  Get.back();
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close_rounded, size: 16, color: Colors.red),
                    const SizedBox(width: 7),
                    Text(
                      'not_interested'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Colors.red,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // ── Loading state ──────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
            ),
          ],
        ],
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Remove all non-digit characters
    final String cleaned = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.isEmpty) return newValue.copyWith(text: '');

    // Parse and format with commas
    final int? value = int.tryParse(cleaned);
    if (value == null) return oldValue;

    final String formatted = _formatWithCommas(value);

    // Calculate cursor position
    final int selectionIndex = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  String _formatWithCommas(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }
}
