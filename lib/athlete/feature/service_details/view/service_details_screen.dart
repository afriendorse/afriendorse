import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final String serviceId;
  final Discount discount;
  const ServiceDetailsScreen({
    super.key,
    required this.serviceId,
    required this.discount,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<ServiceDetailsController>().updateServicePageCurrentState(
      ServiceTabControllerState.serviceOverview,
      shouldUpdate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: "service_details".tr),
      body: GetBuilder<ServiceDetailsController>(
        initState: (state) {
          Get.find<ServiceDetailsController>().getServiceDetailsData(
            widget.serviceId,
          );
        },
        builder: (serviceDetailsController) {
          return serviceDetailsController.isLoading
              ? const ServiceDetailsShimmer()
              : Container(
                  color: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.002),
                  child: CustomScrollView(
                    slivers: [
                      SliverPersistentHeader(
                        pinned: false,
                        floating: true,
                        delegate: BannerDelegate(
                          serviceDetailsController: serviceDetailsController,
                          discount: widget.discount,
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                boxShadow:
                                    context.customThemeColors.lightShadow,
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: Dimensions.paddingSizeExtraLarge,
                                  ),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.paddingSizeSmall,
                                        ),
                                        child: CustomImage(
                                          height: 80,
                                          width: 80,
                                          image:
                                              serviceDetailsController
                                                  .serviceDetailsModel
                                                  ?.content
                                                  ?.thumbnailFullPath ??
                                              "",
                                        ),
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeDefault,
                                      ),

                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            serviceDetailsController
                                                .serviceDetailsModel!
                                                .content!
                                                .name!,
                                            style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                            ),
                                          ),

                                          Row(
                                            children: [
                                              Image(
                                                image: AssetImage(
                                                  Images.starIcon,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),

                                              Text(
                                                double.tryParse(
                                                  serviceDetailsController
                                                          .serviceDetailsModel
                                                          ?.content
                                                          ?.avgRating
                                                          .toString() ??
                                                      "0",
                                                )!.toStringAsFixed(2),
                                                style: robotoBold.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.tertiary,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),

                                              Text(
                                                "(${serviceDetailsController.serviceDetailsModel?.content?.ratingCount ?? ""})",
                                                style: robotoRegular.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: Theme.of(
                                                    context,
                                                  ).hintColor,
                                                ),
                                              ),
                                            ],
                                          ),

                                          if (serviceDetailsController
                                              .variantList
                                              .isNotEmpty)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "start_form".tr,
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(
                                                      context,
                                                    ).hintColor,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall,
                                                ),

                                                if (widget
                                                        .discount
                                                        .discountAmount! >
                                                    0)
                                                  Text(
                                                    PriceConverter.convertPrice(
                                                      double.tryParse(
                                                        serviceDetailsController
                                                            .variantList[0]
                                                            .price
                                                            .toString(),
                                                      ),
                                                    ),
                                                    style: robotoRegular
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color: Theme.of(
                                                            context,
                                                          ).colorScheme.error,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        ),
                                                  ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall,
                                                ),

                                                Text(
                                                  PriceConverter.convertPrice(
                                                    double.parse(
                                                      serviceDetailsController
                                                          .variantList[0]
                                                          .price
                                                          .toString(),
                                                    ),
                                                    discount: double.parse(
                                                      '${widget.discount.discountAmount}',
                                                    ),
                                                    discountType:
                                                        widget
                                                                .discount
                                                                .discountAmountType !=
                                                            null
                                                        ? widget
                                                              .discount
                                                              .discountAmountType!
                                                        : "",
                                                  ).toString(),
                                                  style: robotoBold.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),

                                  Text(
                                    serviceDetailsController
                                        .serviceDetailsModel!
                                        .content!
                                        .shortDescription!,
                                    textAlign: TextAlign.justify,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: Dimensions.paddingSizeSmall),
                      ),

                      SliverPersistentHeader(
                        pinned: true,
                        floating: false,
                        delegate: TabBarDelegate(),
                      ),

                      GetBuilder<ReviewController>(
                        builder: (reviewController) {
                          return GetBuilder<ServiceDetailsController>(
                            initState: (_) {
                              Get.find<ServiceDetailsController>()
                                  .getServiceFAQData(widget.serviceId);
                              reviewController.getServiceReview(
                                widget.serviceId,
                              );
                            },
                            builder: (serviceController) {
                              if (serviceController.servicePageCurrentState ==
                                  ServiceTabControllerState.serviceOverview) {
                                return ServiceOverview(
                                  serviceDetailsController:
                                      serviceDetailsController,
                                );
                              } else if (serviceController
                                      .servicePageCurrentState ==
                                  ServiceTabControllerState.priceTable) {
                                return const PriceTableScreen();
                              } else if (serviceController
                                      .servicePageCurrentState ==
                                  ServiceTabControllerState.faq) {
                                return FaqScreen(
                                  faqList:
                                      serviceDetailsController
                                              .serviceFaqModel !=
                                          null
                                      ? serviceDetailsController
                                            .serviceFaqModel!
                                            .content!
                                            .data!
                                      : [],
                                );
                              } else if (serviceController
                                      .servicePageCurrentState ==
                                  ServiceTabControllerState.review) {
                                return ServiceDetailsReview(
                                  reviewList:
                                      reviewController.serviceReviewList ?? [],
                                  rating: reviewController.serviceRating,
                                  scrollController:
                                      reviewController.scrollController,
                                  serviceName: serviceDetailsController
                                      .serviceDetailsModel
                                      ?.content
                                      ?.name,
                                );
                              } else {
                                return const SliverToBoxAdapter(
                                  child: EmptyReviewWidget(),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}

class BannerDelegate extends SliverPersistentHeaderDelegate {
  final Discount? discount;
  final ServiceDetailsController serviceDetailsController;
  BannerDelegate({
    required this.serviceDetailsController,
    required this.discount,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Stack(
      children: [
        Container(color: light.cardColor, width: Get.width, height: 120),

        CustomImage(
          width: Get.width,
          height: 120,
          image:
              serviceDetailsController
                  .serviceDetailsModel
                  ?.content
                  ?.coverImageFullPath ??
              "",
        ),

        discount != null && discount!.discountAmount! > 0.0
            ? Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(
                        Dimensions.paddingSizeDefault,
                      ),
                    ),
                    color: Theme.of(context).colorScheme.error,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeExtraSmall,
                    ),
                    child: Center(
                      child: Text(
                        PriceConverter.percentageCalculation(
                          '',
                          discount!.discountAmount.toString(),
                          discount!.discountAmountType.toString(),
                        ),
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: light.cardColor,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  @override
  double get maxExtent => 120;
  @override
  double get minExtent => 120;
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class TabBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).cardColor,
      child: GetBuilder<ServiceDetailsController>(
        builder: (serviceTabController) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
            ),
            child: Container(
              height: Dimensions.paddingSizeExtraLarge * 2,
              width: Get.width,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                unselectedLabelColor: Theme.of(context).hintColor,
                controller: serviceTabController.controller,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorWeight: 4,
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelStyle: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
                labelStyle: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
                onTap: (int? index) {
                  switch (index) {
                    case 0:
                      serviceTabController.updateServicePageCurrentState(
                        ServiceTabControllerState.serviceOverview,
                      );
                      break;

                    case 1:
                      serviceTabController.updateServicePageCurrentState(
                        ServiceTabControllerState.priceTable,
                      );
                      break;

                    case 2:
                      serviceTabController.updateServicePageCurrentState(
                        ServiceTabControllerState.faq,
                      );
                      break;

                    case 3:
                      serviceTabController.updateServicePageCurrentState(
                        ServiceTabControllerState.review,
                      );
                      break;
                  }
                },
                tabs: serviceTabController.myTabs,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
