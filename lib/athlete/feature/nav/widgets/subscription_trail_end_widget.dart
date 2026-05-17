import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class SubscriptionTrailEndWidget extends StatefulWidget {
  const SubscriptionTrailEndWidget({super.key});

  @override
  State<SubscriptionTrailEndWidget> createState() =>
      _SubscriptionTrailEndWidgetState();
}

class _SubscriptionTrailEndWidgetState
    extends State<SubscriptionTrailEndWidget> {
  bool _isExpanded = false;

  toggleExpandStatus() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        int trialRemainDuration =
            DateConverter.countDays(
              endDate: DateTime.parse(
                userProfileController
                    .providerModel!
                    .content!
                    .subscriptionInfo!
                    .subscribedPackageDetails!
                    .packageEndDate!,
              ),
            ) -
            1;
        double trialPeriod =
            userProfileController
                .providerModel!
                .content!
                .subscriptionInfo!
                .subscribedPackageDetails
                ?.trialDuration ??
            0;

        double progressIndicatorValue =
            (trialPeriod - trialRemainDuration) / trialPeriod;

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusDefault),
                  bottomLeft: Radius.circular(Dimensions.radiusDefault),
                ),
                color: Theme.of(context).colorScheme.error,
              ),

              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeExtraSmall,
                vertical: Dimensions.paddingSizeSmall + 1,
              ),
              child: InkWell(
                onTap: () => toggleExpandStatus(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      _isExpanded
                          ? Icons.arrow_forward_ios_sharp
                          : Icons.arrow_back_ios_sharp,
                      color: Colors.white,
                      size: 17,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall - 3),
                    trialRemainDuration != 0
                        ? TweenAnimationBuilder(
                            tween: Tween<double>(
                              begin: 0,
                              end: progressIndicatorValue,
                            ),
                            duration: const Duration(milliseconds: 1000),
                            builder: (context, value, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 3,
                                      backgroundColor: Colors.white,
                                      strokeCap: StrokeCap.round,
                                      color: const Color(0xF9F1AABB),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: FittedBox(
                                      child: Text(
                                        "$trialRemainDuration",
                                        style: robotoBold.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : Text(
                            "${'free_trial'.tr}\n${'will_be_end_today'.tr}",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Colors.white,
                            ),
                          ),

                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    _isExpanded
                        ? TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.0, end: 1),
                            duration: const Duration(milliseconds: 130),
                            builder: (context, value, child) {
                              return Row(
                                children: [
                                  (value > 0.0) && trialRemainDuration != 0
                                      ? Text(
                                          "${'days_left'.tr}\n${'in_free_trial'.tr}",
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const SizedBox(),

                                  const SizedBox(
                                    width: Dimensions.paddingSizeSmall,
                                  ),

                                  (value > 0.40)
                                      ? InkWell(
                                          onTap: () {
                                            if (kDebugMode) {
                                              print("Tapped");
                                            }
                                          },
                                          child: InkWell(
                                            onTap: () {
                                              Get.toNamed(
                                                RouteHelper.getBusinessPlanScreen(),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions.radiusDefault,
                                                    ),
                                                color: Colors.white,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeDefault,
                                                    vertical:
                                                        Dimensions
                                                            .paddingSizeSmall -
                                                        2,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "choose_plan".tr,
                                                    style: robotoRegular
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color: Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                        ),
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),
                                                  Icon(
                                                    Icons
                                                        .arrow_forward_outlined,
                                                    size: 15,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),

                                  const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall,
                                  ),
                                ],
                              );
                            },
                          )
                        : const SizedBox(),

                    const SizedBox(width: Dimensions.paddingSizeSmall + 2),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
