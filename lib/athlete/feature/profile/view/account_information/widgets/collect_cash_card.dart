import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class CollectCashCard extends StatelessWidget {
  final JustTheController toolTipController;
  const CollectCashCard(this.toolTipController, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Container(
        height: 160,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.lightBlue.shade100,
            width: Get.isDarkMode ? 0.6 : 1,
          ),
          color: Theme.of(context).cardColor,
        ),
        child: Stack(
          children: [
            Container(
              height: 160,
              width: MediaQuery.of(context).size.width * .65,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(300),
                  bottomLeft: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: Get.isDarkMode
                      ? [Colors.transparent, Colors.transparent]
                      : [Colors.blue.shade50, Colors.white],
                ),
              ),
            ),
            GetBuilder<UserProfileController>(
              builder: (userProfileController) {
                double transactionAmount = 0;
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

                transactionAmount = userProfileController
                    .getTransactionAmountAmount(
                      payableAmount,
                      receivableAmount,
                    );

                TransactionType transactionType = userProfileController
                    .getTransactionType(payableAmount, receivableAmount);

                if (transactionType == TransactionType.adjust) {
                  transactionAmount = payableAmount;
                } else {
                  transactionAmount = userProfileController
                      .getTransactionAmountAmount(
                        payableAmount,
                        receivableAmount,
                      );
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          transactionType == TransactionType.payable
                              ? "payable_balance".tr
                              : transactionType == TransactionType.withdrawAble
                              ? "receivable_balance".tr
                              : transactionType ==
                                    TransactionType.adjustAndPayable
                              ? "final_payable_balance".tr
                              : transactionType ==
                                    TransactionType.adjustWithdrawAble
                              ? "final_receivable_balance".tr
                              : transactionType == TransactionType.adjust
                              ? "adjustable_balance".tr
                              : "empty_balance".tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        JustTheTooltip(
                          backgroundColor: Colors.black87,
                          controller: toolTipController,
                          preferredDirection: AxisDirection.down,
                          tailLength: 14,
                          tailBaseWidth: 20,
                          content: Padding(
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault,
                            ),
                            child: Text(
                              transactionType == TransactionType.payable
                                  ? "payable_balance_text".tr
                                  : transactionType ==
                                        TransactionType.withdrawAble
                                  ? "receivable_balance_text".tr
                                  : transactionType ==
                                        TransactionType.adjustAndPayable
                                  ? "final_payable_balance_text".tr
                                  : transactionType ==
                                        TransactionType.adjustWithdrawAble
                                  ? "final_receivable_balance_text".tr
                                  : transactionType == TransactionType.adjust
                                  ? "adjustable_balance_text".tr
                                  : "",
                              style: robotoRegular.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          child: InkWell(
                            onTap: () => toolTipController.showTooltip(),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Text(
                      PriceConverter.convertPrice(transactionAmount),
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeOverLarge * 1.2,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    GetBuilder<TransactionController>(
                      builder: (transactionController) {
                        return CustomButton(
                          width: 220,
                          height: 40,
                          isLoading: transactionController.isLoading,
                          btnTxt: transactionType == TransactionType.payable
                              ? "pay_now".tr
                              : transactionType == TransactionType.withdrawAble
                              ? "withdraw".tr
                              : transactionType ==
                                    TransactionType.adjustAndPayable
                              ? "adjust_and_pay".tr
                              : transactionType ==
                                    TransactionType.adjustWithdrawAble
                              ? "adjust_and_withdraw".tr
                              : transactionType == TransactionType.adjust
                              ? "adjust".tr
                              : "empty_balance".tr,
                          onPressed: transactionType == TransactionType.none
                              ? null
                              : () {
                                  var config = Get.find<SplashController>()
                                      .configModel
                                      .content;

                                  if (transactionType ==
                                          TransactionType.payable ||
                                      transactionType ==
                                          TransactionType.adjustAndPayable) {
                                    if (config?.digitalPayment == 0) {
                                      showCustomSnackBar(
                                        "no_payment_option_available".tr,
                                      );
                                    } else if ((config?.minimumPayableAmount ??
                                            0) <=
                                        transactionAmount) {
                                      Get.find<DashboardController>()
                                          .updateIndex(-1, isUpdate: false);
                                      showModalBottomSheet(
                                        context: context,
                                        useRootNavigator: true,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            PaymentMethodDialog(
                                              amount: transactionAmount,
                                            ),
                                      );
                                    } else {
                                      showCustomSnackBar(
                                        "${'minimum_payable_amount'.tr} ${PriceConverter.convertPrice(config?.minimumPayableAmount ?? 0)}",
                                      );
                                    }
                                  } else if (transactionType ==
                                          TransactionType.withdrawAble ||
                                      transactionType ==
                                          TransactionType.adjustWithdrawAble) {
                                    Get.to(
                                      () => WithdrawRequestScreen(
                                        amount: transactionAmount,
                                      ),
                                    );
                                  } else if (transactionType ==
                                      TransactionType.adjust) {
                                    transactionController.adjustTransaction();
                                  }
                                },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
