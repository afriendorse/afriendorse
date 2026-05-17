import 'package:afriendorse/athlete/feature/dashboard/widgets/caash_in_hand_widget.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class TopCardSection extends StatelessWidget {
  final JustTheController? toolTip;
  const TopCardSection({super.key, this.toolTip});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        double receivableAmount =
            double.tryParse(
              userProfileController
                      .providerModel
                      ?.content
                      ?.providerInfo
                      ?.owner
                      ?.account
                      ?.accountReceivable ??
                  "0",
            ) ??
            0;
        double payableAmount =
            double.tryParse(
              userProfileController
                      .providerModel
                      ?.content
                      ?.providerInfo
                      ?.owner
                      ?.account
                      ?.accountPayable ??
                  "0",
            ) ??
            0;

        TransactionType transactionType = userProfileController
            .getTransactionType(payableAmount, receivableAmount);

        return GetBuilder<DashboardController>(
          builder: (dashboardController) =>
              dashboardController.dashboardTopCards == null
              ? const DashboardShimmer()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault + 3,
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                      child: Text(
                        "business_summery".tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      width: Get.width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: context.customThemeColors.cardBottomShadow,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              TopCardItem(
                                height: 100,
                                curveColor: Colors.green,
                                cardColor: Colors.green,
                                amount: PriceConverter.convertPrice(
                                  dashboardController.dashboardTopCards != null
                                      ? dashboardController
                                            .dashboardTopCards!
                                            .totalEarning
                                      : 0,
                                  isShowLongPrice: true,
                                ),
                                title: "total_earning".tr,
                                iconData: Images.earning,
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          /*
                          Row(
                            children: [
                              TopCardItem(
                                height: 90,
                                curveColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                cardColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                amount:
                                    dashboardController.dashboardTopCards !=
                                            null &&
                                        dashboardController
                                                .dashboardTopCards!
                                                .totalSubscribedServices !=
                                            null
                                    ? dashboardController
                                          .dashboardTopCards!
                                          .totalSubscribedServices
                                          .toString()
                                    : "0",
                                title: "total_subscribed_subcategories".tr,
                                iconData: Images.topCardService,
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),

                              TopCardItem(
                                height: 90,
                                cardColor: Theme.of(
                                  context,
                                ).colorScheme.tertiary,
                                amount:
                                    dashboardController.dashboardTopCards !=
                                            null &&
                                        dashboardController
                                                .dashboardTopCards!
                                                .totalServiceMan !=
                                            null
                                    ? dashboardController
                                          .dashboardTopCards!
                                          .totalServiceMan
                                          .toString()
                                    : "0",
                                title: "total_service_men".tr,
                                iconData: Images.serviceMan,
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
*/
                          Row(
                            children: [
                              // ResponsiveHelper.isTab(context)?
                              TopCardItem(
                                height: 90,
                                cardColor: Theme.of(context).primaryColor,
                                amount:
                                    dashboardController.dashboardTopCards !=
                                            null &&
                                        dashboardController
                                                .dashboardTopCards!
                                                .totalBookingServed !=
                                            null
                                    ? dashboardController
                                          .dashboardTopCards!
                                          .totalBookingServed
                                          .toString()
                                    : "0",
                                title: "total_booking_served".tr,
                                iconData: Images.booking,
                              ),
                              //:const SizedBox.shrink()
                            ],
                          ),
                          (transactionType == TransactionType.payable ||
                                  transactionType ==
                                      TransactionType.adjustAndPayable)
                              ? TotalCashInHandWidget(toolTip: toolTip)
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
