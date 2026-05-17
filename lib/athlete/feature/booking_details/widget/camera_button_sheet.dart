import 'package:afriendorse/athlete/utils/core_export.dart';

import 'package:get/get.dart';

class CameraButtonSheet extends StatelessWidget {
  final String bookingId;
  final bool isSubBooking;
  const CameraButtonSheet({
    super.key,
    required this.bookingId,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            "submit_service_proof".tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault * 2,
            ),
            child: Text(
              "photo_proof_hint".tr,
              maxLines: 3,
              style: robotoRegular.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(),
              InkWell(
                onTap: () {
                  if (Get.isBottomSheetOpen!) {
                    Get.back();
                  }
                  Get.find<BookingDetailsController>().pickPhotoEvidence(
                    isRemove: false,
                    isCamera: false,
                  );
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeLarge,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                      ),
                      child: Image.asset(Images.upload, width: 30),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Text(
                      'upload_image'.tr,
                      style: robotoRegular.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              InkWell(
                onTap: () {
                  if (Get.isBottomSheetOpen!) {
                    Get.back();
                  }
                  Get.find<BookingDetailsController>().pickPhotoEvidence(
                    isRemove: false,
                    isCamera: true,
                  );
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeLarge,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Text(
                      'take_photo'.tr,
                      style: robotoRegular.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          TextButton(
            onPressed: () {
              Get.back();

              if (Get.find<SplashController>()
                      .configModel
                      .content
                      ?.bookingOtpVerification ==
                  1) {
                Get.find<BookingDetailsController>().sendBookingOTPNotification(
                  bookingId,
                  shouldUpdate: false,
                );
                showCustomBottomSheet(
                  child: OtpVerificationBottomSheet(
                    bookingId: bookingId,
                    isSubBooking: isSubBooking,
                  ),
                );
              }
            },
            child: Text(
              'skip'.tr,
              style: robotoRegular.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
