import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/profile/model/provider_model.dart';
import 'package:get/get.dart';

class ChangeBusinessPlanBottomSheet extends StatefulWidget {
  final bool showCommissionCard;
  const ChangeBusinessPlanBottomSheet({
    super.key,
    this.showCommissionCard = true,
  });

  @override
  State<ChangeBusinessPlanBottomSheet> createState() =>
      _ChangeBusinessPlanBottomSheetState();
}

class _ChangeBusinessPlanBottomSheetState
    extends State<ChangeBusinessPlanBottomSheet> {
  AutoScrollController? scrollController;
  List<SubscriptionPackage>? subscriptionPackagesList;
  int? commissionStatus;
  @override
  void initState() {
    commissionStatus = Get.find<UserProfileController>()
        .providerModel
        ?.content
        ?.providerInfo
        ?.commissionStatus;

    subscriptionPackagesList =
        Get.find<BusinessSubscriptionController>()
            .packageSubscriptionModel
            ?.subscriptionPackages ??
        [];
    int? isCommissionBaseActive =
        Get.find<SplashController>().configModel.content?.commissionBasePlan;

    subscriptionPackagesList?.removeWhere((element) => element.id == "0");

    if (isCommissionBaseActive == 1 &&
            subscriptionPackagesList!.isNotEmpty &&
            (subscriptionPackagesList?.first.id != "0" &&
                widget.showCommissionCard) ||
        (subscriptionPackagesList!.isEmpty && widget.showCommissionCard)) {
      subscriptionPackagesList!.insert(
        0,
        SubscriptionPackage(
          id: "0",
          name: "commission_base",
          price: commissionStatus == 1
              ? Get.find<UserProfileController>()
                    .providerModel
                    ?.content
                    ?.providerInfo
                    ?.commissionPercentage
              : double.tryParse(
                  Get.find<SplashController>()
                          .configModel
                          .content
                          ?.defaultCommission ??
                      "0",
                ),
          description:
              "${'provider_will_pay'.tr} ${Get.find<SplashController>().configModel.content?.defaultCommission ?? ""}% ${'commission_to'.tr} ${Get.find<SplashController>().configModel.content?.businessName} ${'from_each_order_You_will_get_access_of_all'.tr}",
        ),
      );
    }

    scrollController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );

    Get.find<BusinessSubscriptionController>().updateSelectedPackageIndex();

    scrollController!.scrollToIndex(
      Get.find<BusinessSubscriptionController>().selectedPackageIndex != -1
          ? Get.find<BusinessSubscriptionController>().selectedPackageIndex
          : 0,
      preferPosition: AutoScrollPosition.middle,
    );
    scrollController!.highlight(
      Get.find<BusinessSubscriptionController>().selectedPackageIndex != -1
          ? Get.find<BusinessSubscriptionController>().selectedPackageIndex
          : 0,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var config = Get.find<SplashController>().configModel.content;

    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
      child: GetBuilder<BusinessSubscriptionController>(
        builder: (businessSubscriptionController) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(),

                Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "change_business_plan".tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: robotoBold.copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Padding(
                  padding: const EdgeInsets.only(
                    left: Dimensions.paddingSizeLarge * 1.5,
                    right: Dimensions.paddingSizeLarge * 1.5,
                  ),
                  child: Text(
                    "renew_or_shift_your_plan_to_get_better_experience".tr,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                subscriptionPackagesList != null &&
                        subscriptionPackagesList!.isNotEmpty
                    ? SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                            ),
                            child: Row(
                              children: subscriptionPackagesList!.map((
                                element,
                              ) {
                                String? packageStatus;
                                SubscriptionPackage? activePackage;
                                SubscriptionInfo? subscriptionInfo =
                                    Get.find<UserProfileController>()
                                        .providerModel
                                        ?.content
                                        ?.subscriptionInfo;

                                if (subscriptionInfo?.status ==
                                    "commission_base") {
                                  activePackage = SubscriptionPackage(
                                    id: "0",
                                    name: "commission_base",
                                    price: commissionStatus == 1
                                        ? Get.find<UserProfileController>()
                                              .providerModel
                                              ?.content
                                              ?.providerInfo
                                              ?.commissionPercentage
                                        : double.tryParse(
                                            Get.find<SplashController>()
                                                    .configModel
                                                    .content
                                                    ?.defaultCommission ??
                                                "0",
                                          ),
                                  );
                                } else {
                                  subscriptionPackagesList?.forEach((element) {
                                    if (element.id ==
                                        Get.find<UserProfileController>()
                                            .providerModel
                                            ?.content
                                            ?.subscriptionInfo
                                            ?.subscribedPackageDetails
                                            ?.subscriptionPackageId) {
                                      activePackage = element;
                                    }
                                  });

                                  if (activePackage == null &&
                                      subscriptionInfo?.status ==
                                          "subscription_base") {
                                    activePackage = SubscriptionPackage(
                                      id: subscriptionInfo
                                          ?.subscribedPackageDetails
                                          ?.subscriptionPackageId,
                                      name: subscriptionInfo
                                          ?.subscribedPackageDetails
                                          ?.packageName,
                                      price: subscriptionInfo
                                          ?.subscribedPackageDetails
                                          ?.packagePrice,
                                      duration: DateConverter.countDays(
                                        dateTime: DateTime.tryParse(
                                          subscriptionInfo
                                                  ?.subscribedPackageDetails
                                                  ?.packageStartDate ??
                                              "",
                                        ),
                                        endDate: DateTime.tryParse(
                                          subscriptionInfo
                                                  ?.subscribedPackageDetails
                                                  ?.packageEndDate ??
                                              "",
                                        ),
                                      ),
                                    );
                                  }
                                }

                                if (activePackage?.id == "0" &&
                                    activePackage!.name == "commission_base") {
                                  packageStatus = "purchase";
                                } else if (activePackage?.id == element.id) {
                                  packageStatus = "renew";
                                } else if (activePackage != null &&
                                    activePackage?.id != element.id) {
                                  packageStatus = "shift";
                                }

                                return AutoScrollTag(
                                  controller: scrollController!,
                                  key: ValueKey(
                                    subscriptionPackagesList!.indexOf(element),
                                  ),
                                  index: subscriptionPackagesList!.indexOf(
                                    element,
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      businessSubscriptionController
                                          .updateSelectedPackageIndex(
                                            index: subscriptionPackagesList!
                                                .indexOf(element),
                                            shouldUpdate: true,
                                          );
                                      await scrollController!.scrollToIndex(
                                        subscriptionPackagesList!.indexOf(
                                          element,
                                        ),
                                        preferPosition:
                                            AutoScrollPosition.middle,
                                        duration: const Duration(
                                          milliseconds: 800,
                                        ),
                                      );
                                      await scrollController!.highlight(
                                        subscriptionPackagesList!.indexOf(
                                          element,
                                        ),
                                      );
                                    },
                                    child: SubscriptionItemCard(
                                      isSelected:
                                          subscriptionPackagesList!.indexOf(
                                            element,
                                          ) ==
                                          businessSubscriptionController
                                              .selectedPackageIndex,
                                      selectedPackage: element,
                                      activePackage: activePackage,
                                      scrollController: scrollController,
                                      packageStatus: packageStatus,
                                      onPressed:
                                          element.name == "commission_base" ||
                                              config?.digitalPayment == 1
                                          ? () async {
                                              businessSubscriptionController
                                                  .updateSelectedPackageIndex(
                                                    index:
                                                        subscriptionPackagesList!
                                                            .indexOf(element),
                                                    shouldUpdate: true,
                                                  );

                                              showCustomBottomSheet(
                                                child:
                                                    RenewSubscriptionPlanBottomSheet(
                                                      selectedPackage: element,
                                                      activePackage:
                                                          activePackage,
                                                      packageStatus:
                                                          packageStatus,
                                                    ),
                                              );

                                              await scrollController!
                                                  .scrollToIndex(
                                                    subscriptionPackagesList!
                                                        .indexOf(element),
                                                    preferPosition:
                                                        AutoScrollPosition
                                                            .middle,
                                                    duration: const Duration(
                                                      milliseconds: 50,
                                                    ),
                                                  );
                                              await scrollController!.highlight(
                                                subscriptionPackagesList!
                                                    .indexOf(element),
                                              );
                                            }
                                          : null,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeLarge,
                        ),
                        child: Text(
                          'no_subscription_plan_available_at_this_moment'.tr,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),

                const SizedBox(height: Dimensions.paddingSizeLarge),
              ],
            ),
          );
        },
      ),
    );
  }
}
