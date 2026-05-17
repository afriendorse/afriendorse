import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class DeleteAccountBottomSheet extends StatelessWidget {
  const DeleteAccountBottomSheet({super.key});

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

        UserAccountStatus accountStatus = UserAccountStatus.deletable;

        if (userProfileController.haveAnyAcceptedAndOngoingBooking()) {
          accountStatus = UserAccountStatus.haveExistingBooking;
        } else if (transactionType != TransactionType.none) {
          accountStatus = UserAccountStatus.needPaymentSettled;
        } else {
          accountStatus = UserAccountStatus.deletable;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Dimensions.paddingSizeLarge * 1.5),

            Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge * 1.5),

            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(Images.personProfileIcon, width: 70),

                Positioned(
                  top: -5,
                  right: -5,
                  child: Icon(
                    accountStatus == UserAccountStatus.deletable
                        ? Icons.cancel
                        : Icons.warning_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Text(
              accountStatus == UserAccountStatus.deletable
                  ? "delete_your_account".tr
                  : "can_not_delete_account".tr,
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge * 2,
              ),
              child: Text(
                accountStatus == UserAccountStatus.haveExistingBooking
                    ? "complete_ongoing_accepted_bookings".tr
                    : accountStatus == UserAccountStatus.needPaymentSettled
                    ? "cash_in_hand_pay_the_due".tr
                    : "wont_be_able_to_recover".tr,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault * 1.5),

            accountStatus == UserAccountStatus.needPaymentSettled
                ? CustomButton(
                    btnTxt: transactionType == TransactionType.payable
                        ? "pay_now".tr
                        : transactionType == TransactionType.withdrawAble
                        ? "withdraw".tr
                        : transactionType == TransactionType.adjustAndPayable
                        ? "adjust_and_pay".tr
                        : transactionType == TransactionType.adjustWithdrawAble
                        ? "adjust_and_withdraw".tr
                        : transactionType == TransactionType.adjust
                        ? "adjust".tr
                        : "empty_balance".tr,
                    width: 220,
                    onPressed: () {
                      Get.back();
                      Get.to(const AccountInformation());
                    },
                  )
                : accountStatus == UserAccountStatus.haveExistingBooking
                ? CustomButton(
                    btnTxt: "booking_requests".tr,
                    width: 220,
                    onPressed: () => Get.offAllNamed(
                      RouteHelper.getInitialRoute(pageIndex: 1),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        btnTxt: 'cancel'.tr,
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        onPressed: () => Get.back(),
                        textColor: Theme.of(context).textTheme.bodySmall?.color,
                        width: 130,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraLarge),

                      CustomButton(
                        btnTxt: 'remove'.tr,
                        onPressed: () {
                          Get.back();
                          Get.find<AuthController>().removeUser();
                        },
                        transparent: false,
                        color: Colors.red,
                        width: 130,
                      ),
                    ],
                  ),

            const SizedBox(height: Dimensions.paddingSizeLarge * 2),
          ],
        );
      },
    );
  }
}
