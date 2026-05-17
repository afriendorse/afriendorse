import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class CollectCashDialog extends StatelessWidget {
  const CollectCashDialog({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController amountController = TextEditingController();
    TextEditingController noteController = TextEditingController();

    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: GetBuilder<BankInfoController>(
        builder: (bankInfoController) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFieldTitle(title: "amount".tr, requiredMark: true),
                      CustomTextFormField(
                        inputType: TextInputType.number,
                        controller: amountController,
                        hintText: 'amount'.tr,
                        maxLines: 1,
                      ),

                      TextFieldTitle(title: "note".tr),
                      CustomTextFormField(
                        inputType: TextInputType.text,
                        controller: noteController,
                        hintText: 'optional'.tr,
                        maxLines: 1,
                      ),

                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          bankInfoController.isLoading
                              ? SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).hoverColor,
                                  ),
                                )
                              : CustomButton(
                                  btnTxt: "send".tr,
                                  height: 35,
                                  width: 80,
                                  fontSize: Dimensions.fontSizeDefault,
                                  onPressed: () {
                                    requestMoney(
                                      amountController.text.trim(),
                                      noteController.text.trim(),
                                      bankInfoController,
                                    );
                                  },
                                ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void requestMoney(
    String amount,
    String note,
    BankInfoController bankInfoController,
  ) {
    double withDrawableAmount = double.tryParse(
      Get.find<UserProfileController>()
          .providerModel!
          .content!
          .providerInfo!
          .owner!
          .account!
          .accountReceivable!,
    )!;
    if (amount.isEmpty) {
      showCustomSnackBar("enter_amount_first".tr);
    } else if (double.tryParse(amount)! < 1.0) {
      showCustomSnackBar('amount_should_be'.tr);
    } else if (double.tryParse(amount)! > withDrawableAmount) {
      showCustomSnackBar('insufficient_balance'.tr);
    } else {
      bankInfoController.withdrawRequest(amount, note);
    }
  }
}
