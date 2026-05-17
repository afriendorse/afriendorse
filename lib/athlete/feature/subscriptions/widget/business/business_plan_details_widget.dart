import 'package:afriendorse/athlete/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/profile/model/provider_model.dart';
import 'package:get/get.dart';

class BusinessPlanDetailsWidget extends StatelessWidget {
  final JustTheController? tooltipController;
  const BusinessPlanDetailsWidget({super.key, this.tooltipController});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessSubscriptionController>(
      builder: (businessSubscriptionController) {
        return GetBuilder<UserProfileController>(
          builder: (userProfileController) {
            if (userProfileController.providerModel != null &&
                userProfileController
                        .providerModel!
                        .content!
                        .subscriptionInfo !=
                    null) {
              SubscriptionInfo? subscriptionInfo = userProfileController
                  .providerModel
                  ?.content
                  ?.subscriptionInfo;
              SubscribedPackageDetails? subscribedPackageDetails =
                  userProfileController
                      .providerModel
                      ?.content
                      ?.subscriptionInfo
                      ?.subscribedPackageDetails;
              int remainingDays = subscribedPackageDetails != null
                  ? DateConverter.countDays(
                      endDate: DateTime.tryParse(
                        subscribedPackageDetails.packageEndDate ?? "",
                      ),
                    )
                  : 0;

              int duration =
                  (subscribedPackageDetails?.packageStartDate != null &&
                      subscribedPackageDetails?.packageEndDate != null)
                  ? DateConverter.countDays(
                      dateTime: DateTime.tryParse(
                        subscribedPackageDetails?.packageStartDate ?? "",
                      ),
                      endDate: DateTime.tryParse(
                        subscribedPackageDetails?.packageEndDate ?? "",
                      ),
                    )
                  : subscriptionInfo?.renewalPackageDetails?.duration ?? 0;

              bool isFreeTrial =
                  subscribedPackageDetails?.trialDuration != null &&
                  subscribedPackageDetails?.trialDuration != 0;
              bool isPaid = subscribedPackageDetails?.isPaid == 0
                  ? false
                  : true;

              double nextRenewalBill =
                  (subscriptionInfo?.renewalPackageDetails?.price ?? 0) +
                  ((subscriptionInfo?.renewalPackageDetails?.price ?? 0) *
                          (subscriptionInfo?.applicableVat ?? 0)) /
                      100;

              return RefreshIndicator(
                onRefresh: () async {
                  userProfileController.getProviderInfo(reload: true);
                },
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: ClampingScrollPhysics(),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "billing_details".tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                    ),
                                  ),
                                  (Get.find<SplashController>()
                                                  .configModel
                                                  .content
                                                  ?.subscriptionDeadlineWarning ??
                                              0) >=
                                          remainingDays
                                      ? WarningTooltipWidget(
                                          tooltipController: tooltipController,
                                          subscriptionDetails:
                                              subscribedPackageDetails,
                                        )
                                      : const SizedBox(),
                                ],
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  color: Theme.of(context).cardColor,
                                  boxShadow:
                                      context.customThemeColors.lightShadow,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                  vertical: Dimensions.paddingSizeDefault,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeDefault,
                                ),

                                child: Column(
                                  children: [
                                    BillingDetailsItemView(
                                      icon: Images.nextBillingIcon,
                                      title: "next_billing_date",
                                      subTitle:
                                          DateConverter.dateStringMonthYear(
                                            DateTime.tryParse(
                                              subscribedPackageDetails
                                                      ?.packageEndDate ??
                                                  "",
                                            ),
                                          ),
                                    ),

                                    BillingDetailsItemView(
                                      icon: Images.totalBillingIcon,
                                      title: "next_renewal_bill(vat_included)",
                                      subTitle: PriceConverter.convertPrice(
                                        nextRenewalBill,
                                      ),
                                    ),

                                    BillingDetailsItemView(
                                      icon: Images.numberUsersIcon,
                                      title: "total_subscription_taken",
                                      subTitle:
                                          "${subscribedPackageDetails?.numberOfUses ?? 0}",
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                children: [
                                  Text(
                                    "package_overview".tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: Dimensions.paddingSizeSmall,
                                  ),

                                  (!isPaid && !isFreeTrial)
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                            vertical: 5,
                                          ),
                                          child: Text(
                                            'unpaid'.tr,
                                            style: robotoMedium.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : remainingDays <= 0
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                            vertical: 5,
                                          ),
                                          child: Text(
                                            'expired'.tr,
                                            style: robotoMedium.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : subscribedPackageDetails?.isCanceled ==
                                            1
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                            vertical: 5,
                                          ),
                                          child: Text(
                                            'canceled'.tr,
                                            style: robotoMedium.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  color: Theme.of(context).cardColor,
                                  boxShadow:
                                      context.customThemeColors.lightShadow,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                  vertical: Dimensions.paddingSizeDefault,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeDefault,
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        subscriptionInfo
                                                ?.renewalPackageDetails
                                                ?.name ??
                                            "",
                                        style: robotoBold.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: Dimensions.fontSizeLarge,
                                        ),
                                      ),
                                      subtitle: Text(
                                        subscriptionInfo
                                                ?.renewalPackageDetails
                                                ?.description ??
                                            "",
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context).hintColor,
                                          fontSize: Dimensions.fontSizeDefault,
                                        ),
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: RichText(
                                        text: TextSpan(
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: PriceConverter.convertPrice(
                                                (subscriptionInfo
                                                            ?.subscribedPackageDetails
                                                            ?.packagePrice ??
                                                        0) -
                                                    (subscriptionInfo
                                                            ?.subscribedPackageDetails
                                                            ?.vatAmount ??
                                                        0),
                                              ),
                                              style: robotoBold.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.color,
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                              ),
                                            ),
                                            TextSpan(
                                              text: " / ",
                                              style: robotoBold.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.color,
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "$duration ${'days'.tr}",
                                              style: robotoLight.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).hintColor,
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    ListView.builder(
                                      itemBuilder: (context, index) {
                                        String? limitInString =
                                            subscribedPackageDetails
                                                    ?.featureList?[index] ==
                                                "booking"
                                            ? subscribedPackageDetails
                                                  ?.featureLimit
                                                  ?.booking
                                            : subscribedPackageDetails
                                                      ?.featureList?[index] ==
                                                  "category"
                                            ? subscribedPackageDetails
                                                  ?.featureLimit
                                                  ?.category
                                            : null;
                                        int? limit = int.tryParse(
                                          limitInString ?? "",
                                        );

                                        return PackageOverviewItemView(
                                          title: subscribedPackageDetails
                                              ?.featureList?[index],
                                          subTitle:
                                              subscribedPackageDetails
                                                          ?.featureList?[index] ==
                                                      "booking" &&
                                                  subscribedPackageDetails
                                                          ?.featureLimit
                                                          ?.booking
                                                          ?.toLowerCase() !=
                                                      "unlimited"
                                              ? subscribedPackageDetails
                                                    ?.featureLimitLeft
                                                    ?.booking
                                                    .toString()
                                              : subscribedPackageDetails
                                                            ?.featureList?[index] ==
                                                        "category" &&
                                                    subscribedPackageDetails
                                                            ?.featureLimit
                                                            ?.category
                                                            ?.toLowerCase() !=
                                                        "unlimited"
                                              ? subscribedPackageDetails!
                                                    .featureLimitLeft
                                                    ?.category
                                                    ?.toString()
                                              : null,
                                          limit: limit,
                                        );
                                      },
                                      padding: EdgeInsets.zero,
                                      itemCount: subscribedPackageDetails
                                          ?.featureList
                                          ?.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Column(
                        children: [
                          CustomButton(
                            btnTxt: "change/renew_subscription_plan".tr,
                            fontSize: Dimensions.fontSizeDefault,
                            onPressed: () {
                              showCustomBottomSheet(
                                child: const ChangeBusinessPlanBottomSheet(),
                              );
                            },
                          ),

                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          subscribedPackageDetails?.isCanceled == 0 &&
                                  remainingDays > 0
                              ? CustomButton(
                                  color: Theme.of(
                                    context,
                                  ).primaryColorLight.withValues(alpha: 0.07),
                                  textColor: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.8),
                                  btnTxt: "cancel_subscription".tr,
                                  fontSize: Dimensions.fontSizeDefault,
                                  onPressed: () {
                                    showCustomBottomSheet(
                                      child: CustomBottomSheetWidget(
                                        icon: Images.cancelDialogIcon,
                                        title: 'are_you_sure'.tr,
                                        buttonText: "cancel",
                                        subTitle:
                                            '${'if_you_cancel_the_subscription_after'.tr} $remainingDays ${'days_you_will_no_longer_be_able_to_run_the_business_before_subscribe_to_a_new_plan'.tr}',
                                        onTap: () async {
                                          showCustomDialog(
                                            child: const CustomLoader(),
                                          );
                                          ResponseModel response =
                                              await businessSubscriptionController
                                                  .cancelSubscription(
                                                    packageId:
                                                        subscribedPackageDetails!
                                                            .subscriptionPackageId!,
                                                  );
                                          Get.back();
                                          Get.back();
                                          if (response.isSuccess!) {
                                            showCustomSnackBar(
                                              response.message,
                                              type: ToasterMessageType.success,
                                            );
                                          } else {
                                            showCustomSnackBar(
                                              response.message,
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        );
      },
    );
  }
}

class BillingDetailsItemView extends StatelessWidget {
  final String icon;
  final String? title;
  final String? subTitle;
  const BillingDetailsItemView({
    super.key,
    required this.icon,
    this.title,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(icon, width: 35),
      horizontalTitleGap: 20,
      title: Text(
        title?.tr ?? "",
        style: robotoMedium.copyWith(
          color: Theme.of(context).hintColor.withValues(alpha: 0.7),
          fontSize: Dimensions.fontSizeDefault,
        ),
      ),
      subtitle: Text(
        subTitle?.tr ?? "",
        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
      ),
    );
  }
}

class PackageOverviewItemView extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final int? limit;
  const PackageOverviewItemView({
    super.key,
    this.title,
    this.subTitle,
    this.limit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
      visualDensity: VisualDensity.compact,
      horizontalTitleGap: 20,
      dense: true,
      title: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text:
                  "${(title == "booking" || title == "category") && limit == null ? "unlimited".tr : limit ?? ""}"
                  " ${(title == "category") ? "subcategory's_subscription".tr : title?.tr ?? ""}",
              style: robotoRegular.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
            const TextSpan(text: "  "),
            if (subTitle != null)
              TextSpan(
                text: "($subTitle ${'left'.tr} )",
                style: robotoLight.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
