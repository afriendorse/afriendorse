import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class OtpVerificationBottomSheet extends StatefulWidget {
  final String? bookingId;
  final bool isSubBooking;
  const OtpVerificationBottomSheet({
    super.key,
    this.bookingId,
    required this.isSubBooking,
  });

  @override
  State<OtpVerificationBottomSheet> createState() =>
      _OtpVerificationBottomSheetState();
}

class _OtpVerificationBottomSheetState
    extends State<OtpVerificationBottomSheet> {
  @override
  void initState() {
    super.initState();
    Get.find<BookingDetailsController>().setOtp('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GetBuilder<BookingDetailsController>(
        builder: (bookingDetailsController) {
          return Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    color: Theme.of(
                      context,
                    ).disabledColor.withValues(alpha: 0.5),
                  ),
                ),

                Column(
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Text(
                      'otp_verification'.tr,
                      style: robotoBold.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.9),
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Text(
                      'enter_otp_number'.tr,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    SizedBox(
                      width: 260,
                      child: PinCodeTextField(
                        length: 6,
                        appContext: context,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.slide,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.underline,
                          fieldHeight: 30,
                          fieldWidth: 30,
                          borderWidth: 2,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSmall,
                          ),
                          selectedColor:
                              bookingDetailsController.isWrongOtpSubmitted
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).primaryColor,
                          selectedFillColor: Theme.of(context).cardColor,
                          inactiveFillColor: Theme.of(context).cardColor,
                          inactiveColor: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.2),
                          activeColor:
                              bookingDetailsController.isWrongOtpSubmitted
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.7),
                          activeFillColor: Theme.of(context).cardColor,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        onChanged: (String text) =>
                            bookingDetailsController.setOtp(text),
                        beforeTextPaste: (text) => true,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    bookingDetailsController.isWrongOtpSubmitted
                        ? Text(
                            'wrong_otp_number'.tr,
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : !bookingDetailsController.isWrongOtpSubmitted &&
                              !bookingDetailsController.isStatusUpdateLoading
                        ? Text(
                            'collect_otp_from_customer'.tr,
                            style: robotoRegular,
                            textAlign: TextAlign.center,
                          )
                        : const Text(""),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
                //
                CustomButton(
                  btnTxt: 'submit'.tr,
                  radius: Dimensions.radiusDefault,
                  isLoading: bookingDetailsController.isStatusUpdateLoading,
                  margin: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeSmall,
                  ),
                  onPressed: (bookingDetailsController.otp.length != 6)
                      ? null
                      : () async {
                          bookingDetailsController.resetWrongOtpValue();
                          await bookingDetailsController.changeBookingStatus(
                            widget.bookingId ?? "",
                            bookingStatus: "completed",
                            isBack: true,
                            isSubBooking: widget.isSubBooking,
                          );
                        },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'did_not_get_any_OTP'.tr,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    bookingDetailsController.hideResendButton
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeLarge,
                            ),
                            child: SizedBox(
                              height: Dimensions.fontSizeLarge,
                              width: Dimensions.fontSizeLarge,
                              child: const CircularProgressIndicator(),
                            ),
                          )
                        : InkWell(
                            onTap: () async {
                              bool resend = await bookingDetailsController
                                  .sendBookingOTPNotification(widget.bookingId);

                              if (resend) {
                                showCustomSnackBar(
                                  "otp_resend_successfully".tr,
                                  type: ToasterMessageType.success,
                                );
                              } else {}
                            },
                            child: Text(
                              'resend_it'.tr,
                              style: robotoMedium.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                          ),
                  ],
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
