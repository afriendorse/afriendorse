import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SignUpStep4 extends StatefulWidget {
  const SignUpStep4({super.key});
  @override
  State<SignUpStep4> createState() => _SignUpStep4State();
}

class _SignUpStep4State extends State<SignUpStep4> {
  AutoScrollController? scrollController;
  List<SubscriptionPackage>? subscriptionPackagesList;

  @override
  void initState() {
    subscriptionPackagesList =
        Get.find<BusinessSubscriptionController>()
            .packageSubscriptionModel
            ?.subscriptionPackages ??
        [];
    subscriptionPackagesList?.removeWhere((element) => element.id == "0");
    if (subscriptionPackagesList != null &&
        subscriptionPackagesList!.isNotEmpty) {
      Get.find<SignUpController>().updateSelectedSubscription(
        subscriptionPackagesList![0],
        shouldUpdate: false,
      );
    }
    scrollController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );
    scrollController!.scrollToIndex(
      0,
      preferPosition: AutoScrollPosition.middle,
    );
    scrollController!.highlight(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          await Get.find<SplashController>().getConfigData();
          await Get.find<BusinessSubscriptionController>()
              .getSubscriptionPackageList(reload: true);

          subscriptionPackagesList =
              Get.find<BusinessSubscriptionController>()
                  .packageSubscriptionModel
                  ?.subscriptionPackages ??
              [];
          if (subscriptionPackagesList != null &&
              subscriptionPackagesList!.isNotEmpty) {
            Get.find<SignUpController>().updateSelectedSubscription(
              subscriptionPackagesList![0],
              shouldUpdate: true,
            );
            scrollController!.scrollToIndex(
              0,
              preferPosition: AutoScrollPosition.middle,
            );
            scrollController!.highlight(0);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          child: GetBuilder<SplashController>(
            builder: (splashController) {
              return GetBuilder<SignUpController>(
                builder: (signUpController) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraLarge,
                        ),
                        Text(
                          "business_plan_hint_text".tr,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraLarge,
                        ),

                        (splashController
                                        .configModel
                                        .content
                                        ?.commissionBasePlan ==
                                    1 ||
                                splashController
                                        .configModel
                                        .content
                                        ?.subscriptionBasePlan ==
                                    0)
                            ? BusinessPlanCard(
                                icon: Images.commissionIcon,
                                title: "commission_base",
                                subtitle:
                                    "${'with_this_you_pay'.tr} ${splashController.configModel.content?.defaultCommission ?? ""}% ${"commission_on_every_service_you_provide".tr}",
                                isSelected:
                                    signUpController.selectedBusinessPlan ==
                                    BusinessPlanType.commissionBase,
                                onTap: () {
                                  signUpController.updateBusinessPlanType(
                                    BusinessPlanType.commissionBase,
                                  );
                                  if (subscriptionPackagesList != null &&
                                      subscriptionPackagesList!.isNotEmpty) {
                                    signUpController.updateSelectedSubscription(
                                      subscriptionPackagesList![0],
                                    );
                                  }
                                },
                              )
                            : const SizedBox(),

                        SizedBox(
                          height:
                              splashController
                                      .configModel
                                      .content
                                      ?.commissionBasePlan ==
                                  1
                              ? Dimensions.paddingSizeLarge
                              : 0,
                        ),

                        splashController
                                    .configModel
                                    .content
                                    ?.subscriptionBasePlan ==
                                1
                            ? signUpController.selectedBusinessPlan ==
                                      BusinessPlanType.subscriptionBase
                                  ? SelectedSubscriptionWidget(
                                      scrollController: scrollController,
                                      signUpController: signUpController,
                                      subscriptionList:
                                          subscriptionPackagesList,
                                    )
                                  : BusinessPlanCard(
                                      icon: Images.subscriptionIcon,
                                      title: "subscription_base",
                                      subtitle:
                                          "just_select_plan_and_pay_subscription_fee_and_business_with_us",
                                      isSelected:
                                          signUpController
                                              .selectedBusinessPlan ==
                                          BusinessPlanType.subscriptionBase,
                                      showBorder:
                                          signUpController
                                              .selectedBusinessPlan !=
                                          BusinessPlanType.subscriptionBase,
                                      onTap: () {
                                        signUpController.updateBusinessPlanType(
                                          BusinessPlanType.subscriptionBase,
                                        );
                                      },
                                    )
                            : const SizedBox(),

                        const SizedBox(height: Dimensions.paddingSizeLarge),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class SelectedSubscriptionWidget extends StatelessWidget {
  final SignUpController signUpController;
  final AutoScrollController? scrollController;
  final List<SubscriptionPackage>? subscriptionList;
  const SelectedSubscriptionWidget({
    super.key,
    required this.signUpController,
    required this.scrollController,
    required this.subscriptionList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
      child: Column(
        children: [
          BusinessPlanCard(
            icon: Images.subscriptionIcon,
            title: "subscription_base",
            subtitle:
                "just_select_plan_and_pay_subscription_fee_and_business_with_us",
            isSelected:
                signUpController.selectedBusinessPlan ==
                BusinessPlanType.subscriptionBase,
            showBorder:
                signUpController.selectedBusinessPlan !=
                BusinessPlanType.subscriptionBase,
            onTap: () {
              signUpController.updateBusinessPlanType(
                BusinessPlanType.subscriptionBase,
              );
            },
          ),

          signUpController.selectedBusinessPlan ==
                  BusinessPlanType.subscriptionBase
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeLarge,
                  ),
                  child: Text(
                    'select_plan'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                )
              : const SizedBox(),

          signUpController.selectedBusinessPlan ==
                  BusinessPlanType.subscriptionBase
              ? (subscriptionList != null && subscriptionList!.isNotEmpty)
                    ? SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                            ),
                            child: Row(
                              children: subscriptionList!.map((element) {
                                return AutoScrollTag(
                                  controller: scrollController!,
                                  key: ValueKey(
                                    subscriptionList!.indexOf(element),
                                  ),
                                  index: subscriptionList!.indexOf(element),
                                  child: Stack(
                                    children: [
                                      SubscriptionItemCard(
                                        isSelected:
                                            signUpController
                                                .selectedSubscriptionPackage
                                                ?.id ==
                                            element.id,
                                        selectedPackage: element,
                                        scrollController: scrollController,
                                      ),

                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                          ),
                                          child: CustomInkWell(
                                            onTap: () async {
                                              signUpController
                                                  .updateSelectedSubscription(
                                                    element,
                                                  );
                                              await scrollController!
                                                  .scrollToIndex(
                                                    subscriptionList!.indexOf(
                                                      element,
                                                    ),
                                                    preferPosition:
                                                        AutoScrollPosition
                                                            .middle,
                                                    duration: const Duration(
                                                      milliseconds: 800,
                                                    ),
                                                  );
                                              await scrollController!.highlight(
                                                subscriptionList!.indexOf(
                                                  element,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
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
                      )
              : const SizedBox(),
        ],
      ),
    );
  }
}
