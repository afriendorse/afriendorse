import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ServicesScreen extends StatefulWidget {
  final int index;
  final ServiceSubCategoryModel? subcategoryModel;
  final SubscriptionModelData? subscriptionModelData;
  final String fromPage;

  const ServicesScreen({
    super.key,
    this.subcategoryModel,
    this.subscriptionModelData,
    required this.index,
    required this.fromPage,
    r,
  });

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    ServiceCategoryController serviceCategoryController = Get.find();
    serviceCategoryController.getServiceListBasedOnSubcategory(
      subCategoryId:
          widget.subcategoryModel?.id ??
          widget.subscriptionModelData?.subCategoryId ??
          "",
    );
    serviceCategoryController.clearSearchController(shouldUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceCategoryController>(
      builder: (allServiceController) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: CustomAppBar(
            title:
                widget.subcategoryModel?.name ??
                widget.subscriptionModelData?.subCategory?.name ??
                "",
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
            ),
            child: allServiceController.serviceList != null
                ? Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeDefault,
                              ),
                              child: Center(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "${allServiceController.serviceList?.length.toString()} ",
                                        style: robotoBold.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).primaryColorLight,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'services_available'.tr,
                                        style: robotoRegular,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            ServiceSearchWidget(
                              subcategoryId:
                                  widget.subcategoryModel?.id ??
                                  widget.subscriptionModelData?.subCategoryId ??
                                  "",
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),

                            allServiceController.searchServiceList == null &&
                                    !allServiceController.isSearchComplete
                                ? const SearchedServiceListShimmer()
                                : allServiceController.searchServiceList !=
                                          null &&
                                      allServiceController.isSearchComplete
                                ? ServiceListView(
                                    serviceList:
                                        allServiceController.searchServiceList!,
                                  )
                                : ServiceListView(
                                    serviceList:
                                        allServiceController.serviceList!,
                                  ),
                          ],
                        ),
                      ),

                      (allServiceController.serviceList != null &&
                              allServiceController.searchServiceList == null &&
                              allServiceController.isSearchComplete)
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 20,
                              ),
                              height: 85,
                              width: Get.width,
                              color: Theme.of(context).colorScheme.surface,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  //minimumSize: Size.zero,
                                  fixedSize: const Size(100, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide.none,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 8,
                                  ),
                                  backgroundColor:
                                      (widget.subcategoryModel?.isSubscribed ==
                                              1 ||
                                          widget
                                                  .subscriptionModelData
                                                  ?.isSubscribed ==
                                              1)
                                      ? Colors.orangeAccent.shade400
                                      : Theme.of(context).primaryColor,
                                ),

                                onPressed: () {
                                  Get.find<BusinessSubscriptionController>()
                                      .openTrialEndBottomSheet()
                                      .then((isTrial) {
                                        if (isTrial) {
                                          int? isSubscribe =
                                              (widget
                                                          .subcategoryModel
                                                          ?.isSubscribed ==
                                                      1 ||
                                                  widget
                                                          .subscriptionModelData
                                                          ?.isSubscribed ==
                                                      1)
                                              ? 1
                                              : 0;
                                          showCustomBottomSheet(
                                            child:
                                                SubscribeUnsubscribeBottomSheet(
                                                  isSubscribe: isSubscribe == 1
                                                      ? false
                                                      : true,
                                                  subCategoryModel:
                                                      widget.subcategoryModel,
                                                  subscriptionModelData: widget
                                                      .subscriptionModelData,
                                                  index: widget.index,
                                                  fromPage: widget.fromPage,
                                                ),
                                          );
                                        }
                                      });
                                },
                                child: Text(
                                  (widget.subcategoryModel?.isSubscribed == 0 ||
                                          widget
                                                  .subscriptionModelData
                                                  ?.isSubscribed ==
                                              0)
                                      ? "subscribe_to_this_subcategory".tr
                                      : "unsubscribe_to_this_subcategory".tr,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: light.cardColor,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  )
                : const ServiceListShimmer(),
          ),
        );
      },
    );
  }
}
