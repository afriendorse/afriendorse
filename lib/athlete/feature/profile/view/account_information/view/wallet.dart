import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({super.key});
  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  JustTheController tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();
    Get.find<UserProfileController>().getProviderInfo(reload: true);
    Get.find<UserProfileController>().updateNumberOfTimeShowingDialog();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: () async =>
          Get.find<UserProfileController>().getProviderInfo(reload: true),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(title: "account_information".tr),
        body: GetBuilder<UserProfileController>(
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

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      transactionType == TransactionType.none
                          ? const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            )
                          : CollectCashCard(tooltipController),

                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        child: Row(
                          children: [
                            TransactionCard(
                              amount: PriceConverter.convertPrice(
                                double.tryParse(
                                  userProfileController
                                      .providerModel!
                                      .content!
                                      .providerInfo!
                                      .owner!
                                      .account!
                                      .accountPayable!,
                                ),
                              ),
                              amountTextColor: Colors.red,
                              title: "payable_balance".tr,
                              borderColor: Colors.red.shade100,
                              backgroundColor: Get.isDarkMode
                                  ? Theme.of(context).cardColor
                                  : Colors.red.shade50,
                            ),
                            const SizedBox(width: 8),
                            TransactionCard(
                              amount: PriceConverter.convertPrice(
                                double.tryParse(
                                  userProfileController
                                      .providerModel!
                                      .content!
                                      .providerInfo!
                                      .owner!
                                      .account!
                                      .accountReceivable!,
                                ),
                              ),
                              amountTextColor: Colors.blue,
                              title: "receivable_balance".tr,
                              borderColor: Colors.blue.shade100,
                              backgroundColor: Get.isDarkMode
                                  ? Theme.of(context).cardColor
                                  : Colors.blue.shade50,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        child: Row(
                          children: [
                            TransactionCard(
                              amount: PriceConverter.convertPrice(
                                double.tryParse(
                                  userProfileController
                                      .providerModel!
                                      .content!
                                      .providerInfo!
                                      .owner!
                                      .account!
                                      .balancePending!,
                                ),
                              ),
                              amountTextColor: Colors.blue,
                              title: "pending_withdrawn".tr,
                              borderColor: Colors.blue.shade100,
                              backgroundColor: Get.isDarkMode
                                  ? Theme.of(context).cardColor
                                  : Colors.blue.shade50,
                            ),
                            const SizedBox(width: 8),
                            TransactionCard(
                              amount: PriceConverter.convertPrice(
                                double.tryParse(
                                  userProfileController
                                      .providerModel!
                                      .content!
                                      .providerInfo!
                                      .owner!
                                      .account!
                                      .totalWithdrawn!,
                                ),
                              ),
                              amountTextColor: Colors.green,
                              title: "already_withdrawn".tr,
                              borderColor: Colors.green.shade100,
                              backgroundColor: Get.isDarkMode
                                  ? Theme.of(context).cardColor
                                  : Colors.green.shade50,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        child: Row(
                          children: [
                            TransactionCard(
                              amount: PriceConverter.convertPrice(
                                (double.tryParse(
                                      userProfileController
                                          .providerModel!
                                          .content!
                                          .providerInfo!
                                          .owner!
                                          .account!
                                          .totalWithdrawn!,
                                    ))! +
                                    (double.tryParse(
                                      userProfileController
                                          .providerModel!
                                          .content!
                                          .providerInfo!
                                          .owner!
                                          .account!
                                          .receivedBalance!,
                                    )!),
                              ),
                              amountTextColor: Colors.orangeAccent,
                              title: "total_earning".tr,
                              borderColor: Colors.orangeAccent.shade100,
                              backgroundColor: Get.isDarkMode
                                  ? Theme.of(context).cardColor
                                  : Colors.orange.shade50,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      const TransactionChart(),

                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      CustomButton(
                        height: 40,
                        width: 200,
                        btnTxt: "see_withdraw_history".tr,
                        onPressed: () => Get.toNamed(RouteHelper.transactions),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
