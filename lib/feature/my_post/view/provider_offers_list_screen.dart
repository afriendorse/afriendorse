/*
import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class ProviderOfferListScreen extends StatefulWidget {
  final String? postId;
  final MyPostData? myPostData;
  final String? status;
  const ProviderOfferListScreen({
    super.key,
    this.postId,
    this.myPostData,
    this.status,
  });

  @override
  State<ProviderOfferListScreen> createState() =>
      _ProviderOfferListScreenState();
}

class _ProviderOfferListScreenState extends State<ProviderOfferListScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<CreatePostController>().getProvidersOfferList(
      1,
      widget.postId ?? "",
      reload: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return CustomPopWidget(
      child: Scaffold(
        appBar: CustomAppBar(title: 'provider_offers'.tr),
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        body: GetBuilder<CreatePostController>(
          builder: (createPostController) {
            return widget.postId == null || widget.myPostData == null
                ? NoDataScreen(
                    text: "no_data_found".tr,
                    type: NoDataType.bookings,
                  )
                : ExpandableBottomSheet(
                    background: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: Get.height * 0.6,
                              ),
                              child:
                                  createPostController.providerOfferModel !=
                                          null &&
                                      createPostController
                                              .providerOfferModel!
                                              .content !=
                                          null &&
                                      createPostController
                                              .listOfProviderOffer !=
                                          null &&
                                      createPostController
                                          .listOfProviderOffer!
                                          .isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: Dimensions.paddingSizeLarge,
                                      ),
                                      child: PaginatedListView(
                                        scrollController: scrollController,
                                        totalSize: createPostController
                                            .providerOfferModel!
                                            .content!
                                            .total!,
                                        onPaginate: (int offset) async =>
                                            await createPostController
                                                .getProvidersOfferList(
                                                  offset,
                                                  widget.postId ?? "",
                                                  reload: false,
                                                ),
                                        offset: createPostController
                                            .providerOfferModel!
                                            .content!
                                            .currentPage,
                                        itemView: GridView.builder(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    ResponsiveHelper.isDesktop(
                                                      context,
                                                    )
                                                    ? 2
                                                    : 1,
                                                mainAxisExtent:
                                                    Get.find<
                                                          LocalizationController
                                                        >()
                                                        .isLtr
                                                    ? 165
                                                    : 175,
                                                crossAxisSpacing: Dimensions
                                                    .paddingSizeDefault,
                                              ),
                                          itemCount: createPostController
                                              .listOfProviderOffer
                                              ?.length,
                                          shrinkWrap: true,
                                          padding: EdgeInsets.only(
                                            left:
                                                ResponsiveHelper.isDesktop(
                                                  context,
                                                )
                                                ? 0
                                                : Dimensions.paddingSizeDefault,
                                            right:
                                                ResponsiveHelper.isDesktop(
                                                  context,
                                                )
                                                ? 0
                                                : Dimensions.paddingSizeDefault,
                                            bottom:
                                                ResponsiveHelper.isDesktop(
                                                  context,
                                                )
                                                ? 0
                                                : 100, // Add bottom padding to ensure last items are visible
                                          ),
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return AcceptProviderRequestView(
                                              providerOfferData:
                                                  createPostController
                                                      .listOfProviderOffer![index],
                                              postId: widget.postId!,
                                              length:
                                                  createPostController
                                                      .listOfProviderOffer
                                                      ?.length ??
                                                  0,
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : createPostController.providerOfferModel ==
                                        null
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Center(
                                      child: Text(
                                        'no_provider_bid_this_post'.tr,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                        ),
                                      ),
                                    ),
                            ),
                          ),

                          if (ResponsiveHelper.isDesktop(context))
                            PostDetailsExpandableContent(
                              postData: widget.myPostData!,
                            ),
                          if (ResponsiveHelper.isDesktop(context))
                            const FooterView(),
                        ],
                      ),
                    ),
                    persistentContentHeight: 150,
                    // No need for persistent footer with taller height
                    expandableContent: ResponsiveHelper.isDesktop(context)
                        ? const SizedBox()
                        : PostDetailsExpandableContent(
                            postData: widget.myPostData!,
                          ),
                  );
          },
        ),
      ),
    );
  }
}

*/

import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class ProviderOfferListScreen extends StatefulWidget {
  final String? postId;
  final MyPostData? myPostData;
  final String? status;
  const ProviderOfferListScreen({
    super.key,
    this.postId,
    this.myPostData,
    this.status,
  });

  @override
  State<ProviderOfferListScreen> createState() =>
      _ProviderOfferListScreenState();
}

class _ProviderOfferListScreenState extends State<ProviderOfferListScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<CreatePostController>().getProvidersOfferList(
      1,
      widget.postId ?? "",
      reload: true,
    );
  }

  // Check if this is a targeted post
  bool get isTargetedPost =>
      widget.myPostData?.targetProviderId != null &&
      widget.myPostData!.targetProviderId!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return CustomPopWidget(
      child: Scaffold(
        appBar: CustomAppBar(
          title: isTargetedPost ? 'proposal_details'.tr : 'provider_offers'.tr,
        ),
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        body: GetBuilder<CreatePostController>(
          builder: (createPostController) {
            if (widget.postId == null || widget.myPostData == null) {
              return NoDataScreen(
                text: "no_data_found".tr,
                type: NoDataType.bookings,
              );
            }

            // ── TARGETED POST: Show awaiting state if no bids yet ─────────────
            if (isTargetedPost &&
                createPostController.providerOfferModel != null &&
                (createPostController.listOfProviderOffer?.isEmpty ?? true)) {
              return _buildTargetedAwaitingState(context);
            }

            return ExpandableBottomSheet(
              background: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Header banner for targeted posts ───────────────────────
                    //   if (isTargetedPost) _buildTargetedHeader(context),
                    SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: Get.height * 0.6,
                        ),
                        child:
                            createPostController.providerOfferModel != null &&
                                createPostController
                                        .providerOfferModel!
                                        .content !=
                                    null &&
                                createPostController.listOfProviderOffer !=
                                    null &&
                                createPostController
                                    .listOfProviderOffer!
                                    .isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeLarge,
                                ),
                                child: PaginatedListView(
                                  scrollController: scrollController,
                                  totalSize: createPostController
                                      .providerOfferModel!
                                      .content!
                                      .total!,
                                  onPaginate: (int offset) async =>
                                      await createPostController
                                          .getProvidersOfferList(
                                            offset,
                                            widget.postId ?? "",
                                            reload: false,
                                          ),
                                  offset: createPostController
                                      .providerOfferModel!
                                      .content!
                                      .currentPage,
                                  itemView: ListView.separated(
                                    padding: EdgeInsets.only(
                                      left: ResponsiveHelper.isDesktop(context)
                                          ? 0
                                          : Dimensions.paddingSizeDefault,
                                      right: ResponsiveHelper.isDesktop(context)
                                          ? 0
                                          : Dimensions.paddingSizeDefault,
                                      bottom:
                                          ResponsiveHelper.isDesktop(context)
                                          ? 0
                                          : 100,
                                    ),
                                    itemCount: createPostController
                                        .listOfProviderOffer!
                                        .length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    separatorBuilder: (_, __) => const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),
                                    itemBuilder: (context, index) {
                                      return AcceptProviderRequestView(
                                        providerOfferData: createPostController
                                            .listOfProviderOffer![index],
                                        postId: widget.postId!,
                                        length:
                                            createPostController
                                                .listOfProviderOffer
                                                ?.length ??
                                            0,
                                        isTargeted: isTargetedPost,
                                      );
                                    },
                                  ),
                                ),
                              )
                            : createPostController.providerOfferModel == null
                            ? const Center(child: CircularProgressIndicator())
                            : _buildEmptyState(context),
                      ),
                    ),

                    if (ResponsiveHelper.isDesktop(context))
                      PostDetailsExpandableContent(
                        postData: widget.myPostData!,
                        isTargeted: isTargetedPost,
                      ),
                    if (ResponsiveHelper.isDesktop(context)) const FooterView(),
                  ],
                ),
              ),
              persistentContentHeight: 150,
              expandableContent: ResponsiveHelper.isDesktop(context)
                  ? const SizedBox()
                  : PostDetailsExpandableContent(
                      postData: widget.myPostData!,
                      isTargeted: isTargetedPost,
                    ),
            );
          },
        ),
      ),
    );
  }

  // ── Targeted post: Show header with athlete info ─────────────────────────
  Widget _buildTargetedHeader(BuildContext context) {
    final athlete = widget.myPostData?.targetProvider;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'direct_proposal_to'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  athlete?.companyName ?? 'Athlete',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'exclusive'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Targeted post: Awaiting bid state ────────────────────────────────────
  Widget _buildTargetedAwaitingState(BuildContext context) {
    return Center(
      child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_empty,
                size: 60,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            Text(
              'awaiting_athlete_response'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeExtraLarge,
              ),
              child: Text(
                'targeted_proposal_pending_desc'.tr,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            TextButton.icon(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back),
              label: Text('back_to_posts'.tr),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state for open posts ────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Theme.of(context).hintColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          Text(
            'no_provider_bid_this_post'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeExtraLarge,
            ),
            child: Text(
              'check_back_later_desc'.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
