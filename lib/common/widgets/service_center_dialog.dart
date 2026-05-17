import 'package:afriendorse/helper/analytics/analytics_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

class ServiceCenterDialog extends StatefulWidget {
  final Service? service;
  final CartModel? cart;
  final int? cartIndex;
  final bool? isFromDetails;
  final ProviderData? providerData;

  const ServiceCenterDialog({
    super.key,
    required this.service,
    this.cart,
    this.cartIndex,
    this.isFromDetails = false,
    this.providerData,
  });

  @override
  State<ServiceCenterDialog> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ServiceCenterDialog> {
  static const Color primaryGreen = Color(0xFF045F25);
  static const Color darkGreen = Color(0xFF033D18);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGreen = Color(0xFFE8F5E9);

  DocumentReference<Map<String, dynamic>>? get _athleteRef {
    final email = widget.providerData?.owner?.email?.trim();
    if (email == null || email.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('athletes')
        .doc(email.toLowerCase());
  }

  bool _resolveBadge(Map<String, dynamic>? athleteDoc) {
    if (athleteDoc == null) return false;
    return (athleteDoc['showVerificationBadge'] == true) &&
        (athleteDoc['isVerified'] == true) &&
        ((athleteDoc['verificationStatus'] ?? '').toString().trim() ==
            'verified');
  }

  @override
  void initState() {
    Get.find<CartController>().setInitialCartList(widget.service!);
    Get.find<CartController>().updatePreselectedProvider(
      null,
      shouldUpdate: false,
    );
    Get.find<AllSearchController>().searchFocus.unfocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        ),
        insetPadding: const EdgeInsets.all(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: _pointerInterceptor(),
      );
    }
    return _pointerInterceptor();
  }

  Widget _pointerInterceptor() {
    return Padding(
      padding: EdgeInsets.only(
        top: ResponsiveHelper.isWeb() ? 0 : Dimensions.cartDialogPadding,
      ),
      child: PointerInterceptor(
        child: Container(
          width: ResponsiveHelper.isDesktop(context)
              ? Dimensions.webMaxWidth / 2
              : Dimensions.webMaxWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Dimensions.radiusExtraLarge),
            ),
          ),
          child: _athleteRef != null
              ? StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _athleteRef!.snapshots(),
                  builder: (context, snap) {
                    final showBadge = _resolveBadge(snap.data?.data());
                    return _buildDialogBody(showBadge: showBadge);
                  },
                )
              : _buildDialogBody(showBadge: false),
        ),
      ),
    );
  }

  Widget _buildDialogBody({required bool showBadge}) {
    return GetBuilder<CartController>(
      builder: (cartController) {
        return GetBuilder<ServiceController>(
          builder: (serviceController) {
            final bool hasVariations =
                widget.service!.variationsAppFormat?.zoneWiseVariations != null;

            if (hasVariations) {
              return _buildMainContent(
                cartController: cartController,
                showBadge: showBadge,
              );
            }

            return _buildNoVariationFallback();
          },
        );
      },
    );
  }

  Widget _buildMainContent({
    required CartController cartController,
    required bool showBadge,
  }) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (widget.providerData != null)
            _buildAthleteHero(showBadge: showBadge),

          if (widget.providerData != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 62, 20, 12),
              child: _buildStatsRow(),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.format_list_bulleted_rounded,
                  size: 16,
                  color: primaryGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  'select_a_package'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
          ),

          _buildPackageSection(cartController),

          _buildNilDealCard(),

          _buildCtaButton(cartController: cartController, showBadge: showBadge),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAthleteHero({required bool showBadge}) {
    final provider = widget.providerData!;
    final athleteName = provider.companyName?.isNotEmpty == true
        ? provider.companyName!
        : '${provider.owner?.firstName ?? ''} ${provider.owner?.lastName ?? ''}'
              .trim();

    final sport = provider.subscribedServices?.isNotEmpty == true
        ? (provider.subscribedServices!.first.subCategory?.name ?? '')
        : '';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 110,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Dimensions.radiusExtraLarge),
            ),
            child: provider.coverImageFullPath?.isNotEmpty == true
                ? CustomImage(
                    image: provider.coverImageFullPath!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryGreen, darkGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Opacity(
                      opacity: 0.15,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                            ),
                        itemCount: 64,
                        itemBuilder: (_, __) => const Icon(
                          Icons.sports_soccer,
                          color: pureWhite,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
          ),
        ),

        Container(
          height: 110,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Dimensions.radiusExtraLarge),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
            ),
          ),
        ),

        Positioned(
          top: 12,
          right: 16,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: pureWhite, size: 18),
            ),
          ),
        ),

        Positioned(
          bottom: -42,
          left: 20,
          right: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: pureWhite, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: provider.logoFullPath?.isNotEmpty == true
                      ? CustomImage(
                          image: provider.logoFullPath!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: lightGreen,
                          child: const Icon(
                            Icons.person_rounded,
                            color: primaryGreen,
                            size: 36,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            athleteName,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showBadge) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: primaryGreen,
                          ),
                        ],
                      ],
                    ),
                    if (sport.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          sport,
                          style: robotoRegular.copyWith(
                            fontSize: 10,
                            color: pureWhite,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 110),
      ],
    );
  }

  Widget _buildStatsRow() {
    final provider = widget.providerData;
    if (provider == null) return const SizedBox.shrink();

    final rating = provider.avgRating ?? 0.0;
    final ratingCount = provider.ratingCount ?? 0;
    final jobsDone = provider.totalServiceServed ?? 0;
    final location = provider.companyAddress?.isNotEmpty == true
        ? provider.companyAddress!
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: lightGreen.withOpacity(0.45),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: primaryGreen.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statChip(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
            label: ratingCount > 0
                ? '${rating.toStringAsFixed(1)} ($ratingCount)'
                : 'no_rating'.tr,
          ),
          _statDivider(),
          _statChip(
            icon: Icons.check_circle_outline_rounded,
            iconColor: primaryGreen,
            label: '$jobsDone ${'jobs_done'.tr}',
          ),
          if (location.isNotEmpty) ...[
            _statDivider(),
            _statChip(
              icon: Icons.location_on_outlined,
              iconColor: Colors.redAccent,
              label: location,
              maxWidth: 90,
            ),
          ],
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    double? maxWidth,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth ?? 120),
          child: Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: 11,
              color: Theme.of(Get.context!).textTheme.bodyMedium?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 16,
      color: primaryGreen.withOpacity(0.2),
    );
  }

  Widget _buildPackageSection(CartController cartController) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).hoverColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryGreen.withOpacity(0.10)),
        ),
        child: Column(
          children: [
            _buildPackageHeaderCard(),
            _buildPackageDivider(),
            _buildVariationsList(cartController),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageHeaderCard() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CustomImage(
              image: '${widget.service!.thumbnailFullPath}',
              height: 56,
              width: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.service?.name ?? '',
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: primaryGreen.withOpacity(0.08),
    );
  }

  Widget _buildVariationsList(CartController cartController) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: cartController.initialCartList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = cartController.initialCartList[index];

        return GetBuilder<CartController>(
          builder: (_) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryGreen.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lightGreen.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: primaryGreen,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.variantKey.replaceAll('-', ' '),
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      PriceConverter.convertPrice(
                        double.parse(item.price.toString()),
                        isShowLongPrice: true,
                      ),
                      style: robotoMedium.copyWith(
                        color: Get.isDarkMode
                            ? Theme.of(context).primaryColorLight
                            : primaryGreen,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNilDealCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).hoverColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primaryGreen.withOpacity(0.15), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lightGreen.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.handshake_outlined,
                    color: primaryGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'nil_deal'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'nil_booking_info'.tr,
              style: robotoRegular.copyWith(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.75),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaButton({
    required CartController cartController,
    required bool showBadge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: cartController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.providerData != null) const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Get.back();

                    if (widget.service != null) {
                      Get.find<CreatePostController>().resetCreatePostValue(
                        removeService: false,
                      );
                      Get.find<CreatePostController>().updateSelectedService(
                        widget.service!,
                      );
                    }

                    Get.toNamed(
                      RouteHelper.getCreatePostScreen(
                        targetProviderId: widget.providerData?.id ?? '',
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: ResponsiveHelper.isDesktop(context) ? 55 : 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [primaryGreen, darkGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.30),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit_note_rounded,
                          color: pureWhite,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'request_custom_booking'.tr,
                          style: robotoMedium.copyWith(
                            color: pureWhite,
                            fontSize: Dimensions.fontSizeDefault,
                            letterSpacing: 0.3,
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

  Widget _buildAthleteConfirmationChip({required bool showBadge}) {
    final provider = widget.providerData!;
    final athleteName = provider.companyName?.isNotEmpty == true
        ? provider.companyName!
        : '${provider.owner?.firstName ?? ''} ${provider.owner?.lastName ?? ''}'
              .trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: lightGreen.withOpacity(0.50),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primaryGreen.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: provider.logoFullPath?.isNotEmpty == true
                ? CustomImage(
                    image: provider.logoFullPath!,
                    height: 22,
                    width: 22,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 22,
                    width: 22,
                    color: primaryGreen.withOpacity(0.15),
                    child: const Icon(
                      Icons.person_rounded,
                      color: primaryGreen,
                      size: 14,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${'booking_with'.tr} $athleteName',
              style: robotoMedium.copyWith(fontSize: 12, color: primaryGreen),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showBadge) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 14, color: primaryGreen),
          ],
        ],
      ),
    );
  }

  Widget _buildNoVariationFallback() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 20,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white70.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.grey[Get.find<ThemeController>().darkTheme
                            ? 700
                            : 300]!,
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.close),
            ),
          ),
        ),
        SizedBox(
          height: Get.height / 7,
          child: Center(
            child: Text(
              'no_variation_is_available'.tr,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
          ),
        ),
      ],
    );
  }
}
