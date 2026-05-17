import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class TotalCashInHandWidget extends StatelessWidget {
  final JustTheController? toolTip;
  const TotalCashInHandWidget({super.key, this.toolTip});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        if (userProfileController.providerModel == null) {
          return const SizedBox();
        }

        final receivableAmount =
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

        final payableAmount =
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

        final transactionAmount = userProfileController
            .getTransactionAmountAmount(payableAmount, receivableAmount);

        final payablePercent = userProfileController.getOverflowPercent(
          payableAmount,
          receivableAmount,
          Get.find<SplashController>()
                  .configModel
                  .content
                  ?.maxCashInHandLimit ??
              0,
        );

        final bool isWarning = payablePercent >= 80;

        return Container(
          margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isWarning
                  ? Colors.red.withOpacity(0.20)
                  : Colors.white.withOpacity(0.20),
            ),
            color: isWarning
                ? Colors.red.withOpacity(0.08)
                : Colors.white.withOpacity(0.12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            PriceConverter.convertPrice(transactionAmount),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeOverLarge - 3,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isWarning)
                          JustTheTooltip(
                            preferredDirection: AxisDirection.down,
                            tailLength: 12,
                            tailBaseWidth: 18,
                            controller: toolTip,
                            backgroundColor: Colors.black87,
                            content: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                              child: Text(
                                '${'maximum_cash_in_hand_amount'.tr} ${PriceConverter.convertPrice(Get.find<SplashController>().configModel.content?.maxCashInHandLimit ?? 0)}',
                                style: robotoRegular.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => toolTip?.showTooltip(),
                              child: const Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        text: '${'payable_balance'.tr} ',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault - 1,
                          color: Colors.white70,
                        ),
                        children: payablePercent >= 100
                            ? <TextSpan>[
                                TextSpan(
                                  text: 'limit_exceed'.tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: const Color(0xFFFFD4D4),
                                  ),
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 110,
                child: CustomButton(
                  height: 38,
                  radius: 12,
                  btnTxt: "view_details".tr,
                  fontSize: Dimensions.fontSizeSmall + 1,
                  color: Colors.white,
                  textColor: AthleteDashboardColors.primary,
                  onPressed: () {
                    Get.to(const AccountInformation());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
