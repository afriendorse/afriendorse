import 'package:afriendorse/athlete/feature/subscriptions/widget/subcategory/category_item_widget.dart';
import 'package:afriendorse/athlete/feature/subscriptions/widget/subcategory/no_subscription_widget.dart';
import 'package:afriendorse/athlete/feature/subscriptions/widget/subcategory/subscription_item_shimmer.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  JustTheController? tooltipController;
  AutoScrollController? subscriptionMenuController;

  @override
  void initState() {
    ServiceCategoryController controller = Get.find();
    tooltipController = JustTheController();

    subscriptionMenuController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );
    subscriptionMenuController!.scrollToIndex(
      0,
      preferPosition: AutoScrollPosition.middle,
    );
    subscriptionMenuController!.highlight(0);

    controller.getCategoryList(shouldUpdate: false);
    controller.changeSubscriptionCategoryIndex(0, isUpdate: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? null : Theme.of(context).cardColor,
      appBar: CustomAppBar(
        title: "mySubscription".tr,
        actionWidget: GetBuilder<SubcategorySubscriptionController>(
          builder: (subscriptionController) {
            return !subscriptionController.isLoading &&
                    subscriptionController.subscriptionList.isEmpty &&
                    Get.find<ServiceCategoryController>()
                            .selectedSubsCategoryIndex ==
                        0
                ? JustTheTooltip(
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
                        'from_this_section_you_can_specify'.tr,
                        style: robotoRegular.copyWith(color: Colors.white),
                      ),
                    ),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      onTap: () => tooltipController?.showTooltip(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: Theme.of(context).hintColor,
                          size: 18,
                        ),
                      ),
                    ),
                  )
                : SizedBox();
          },
        ),
      ),

      body: GetBuilder<SubcategorySubscriptionController>(
        initState: (_) {
          Get.find<SubcategorySubscriptionController>().getMySubscriptionData(
            1,
            false,
          );
        },
        builder: (mySubscriptionController) {
          bool isAllSelected =
              Get.find<ServiceCategoryController>().selectedSubsCategoryIndex ==
              0;

          return (isAllSelected
                  ? (!mySubscriptionController.isLoading &&
                        mySubscriptionController.subscriptionList.isNotEmpty &&
                        Get.find<ServiceCategoryController>()
                                .selectedSubsCategoryIndex ==
                            0)
                  : true)
              ? CustomScrollView(
                  controller: mySubscriptionController.scrollController,
                  slivers: [
                    SubscriptionHeaderWidget(
                      mySubscriptionController: mySubscriptionController,
                      subscriptionMenuController: subscriptionMenuController,
                    ),

                    !mySubscriptionController.isLoading &&
                            mySubscriptionController.subscriptionList.isNotEmpty
                        ? SliverToBoxAdapter(
                            child: Column(
                              children: [
                                ListView.builder(
                                  itemBuilder: (context, index) {
                                    if (mySubscriptionController
                                            .subscriptionList[index]
                                            .subCategory !=
                                        null) {
                                      return SubscriptionItem(
                                        subscriptionModelData:
                                            mySubscriptionController
                                                .subscriptionList[index],
                                        index: index,
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: mySubscriptionController
                                      .subscriptionList
                                      .length,
                                ),

                                if (Get.find<ServiceCategoryController>()
                                        .selectedSubsCategoryIndex !=
                                    0)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 20,
                                      top: 20,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.find<ServiceCategoryController>()
                                            .changeCategory(
                                              Get.find<
                                                        ServiceCategoryController
                                                      >()
                                                      .selectedSubsCategoryIndex -
                                                  1,
                                            );
                                        Get.offAllNamed(
                                          RouteHelper.getInitialRoute(
                                            pageIndex: 2,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "+ ${"subscribe_subcategory".tr}",
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          decoration: TextDecoration.underline,
                                          color: Theme.of(context).primaryColor,
                                          decorationColor: Theme.of(
                                            context,
                                          ).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),

                                mySubscriptionController.isPaginationLoading
                                    ? CircularProgressIndicator(
                                        color: Theme.of(context).hoverColor,
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          )
                        : !mySubscriptionController.isLoading &&
                              mySubscriptionController.subscriptionList.isEmpty
                        ? SliverToBoxAdapter(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height - 150,
                              child: NoSubscriptionWidget(fromAll: false),
                            ),
                          )
                        : SliverToBoxAdapter(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height - 150,
                              child: const SubscriptionItemShimmer(),
                            ),
                          ),
                  ],
                )
              : !mySubscriptionController.isLoading &&
                    mySubscriptionController.subscriptionList.isEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height - 150,
                  child: const NoSubscriptionWidget(fromAll: true),
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height - 20,
                  child: const SubscriptionItemShimmer(),
                );
        },
      ),
    );
  }
}

class SubscriptionHeaderWidget extends StatelessWidget {
  final SubcategorySubscriptionController mySubscriptionController;
  final AutoScrollController? subscriptionMenuController;
  const SubscriptionHeaderWidget({
    super.key,
    required this.mySubscriptionController,
    this.subscriptionMenuController,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverDelegate(
        extentSize: 100,
        child: Container(
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              mySubscriptionController.totalSubscription! > 0
                  ? SizedBox(
                      height: 36,
                      width: double.infinity,
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'you_have'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).primaryColorLight,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: mySubscriptionController.totalSubscription
                                    .toString(),
                                style: robotoBold.copyWith(
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              ),
                              TextSpan(
                                text:
                                    mySubscriptionController
                                            .totalSubscription! >
                                        1
                                    ? 'subscriptions'.tr
                                    : 'subscription'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),

              GetBuilder<ServiceCategoryController>(
                builder: (serviceCategoryController) {
                  List<ServiceCategoryModel> serviceCategoryList = [];
                  serviceCategoryList.add(ServiceCategoryModel(name: 'all'.tr));
                  serviceCategoryList.addAll(
                    serviceCategoryController.serviceCategoryList ?? [],
                  );
                  return Container(
                    color: Theme.of(context).cardColor,
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                      horizontal: Dimensions.paddingSizeSmall,
                    ),
                    child: ListView.builder(
                      controller: subscriptionMenuController,
                      itemCount: serviceCategoryList.length,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return AutoScrollTag(
                          controller: subscriptionMenuController!,
                          key: ValueKey(index),
                          index: index,
                          child: CategoryItemWidget(
                            categoryName: serviceCategoryList[index].name ?? '',
                            isSelected:
                                serviceCategoryController
                                    .selectedSubsCategoryIndex ==
                                index,
                            onTap: () async {
                              serviceCategoryController
                                  .changeSubscriptionCategoryIndex(index);
                              Get.find<SubcategorySubscriptionController>()
                                  .getMySubscriptionData(
                                    1,
                                    false,
                                    categoryId: index == 0
                                        ? null
                                        : (serviceCategoryList[index].id),
                                  );
                              await subscriptionMenuController!.scrollToIndex(
                                index,
                                preferPosition: AutoScrollPosition.middle,
                                duration: const Duration(milliseconds: 1000),
                              );
                              await subscriptionMenuController!.highlight(
                                index,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget? child;
  double? extentSize;
  SliverDelegate({@required this.child, @required this.extentSize});
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child!;
  }

  @override
  double get maxExtent => extentSize!;
  @override
  double get minExtent => extentSize!;
  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != maxExtent ||
        child != oldDelegate.child;
  }
}
