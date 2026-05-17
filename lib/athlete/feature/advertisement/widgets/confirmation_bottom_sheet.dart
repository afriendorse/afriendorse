import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ConfirmationBottomSheet extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final String status;
  final Color? yesTestColor;
  final bool isShowNotNowButton;
  final Function() yesButtonPressed;
  final String? confirmButtonText;
  const ConfirmationBottomSheet({
    super.key,
    this.confirmButtonText,
    this.isShowNotNowButton = true,
    required this.image,
    required this.title,
    required this.description,
    required this.yesButtonPressed,
    required this.status,
    this.yesTestColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(Dimensions.radiusDefault),
          topLeft: Radius.circular(Dimensions.radiusDefault),
        ),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: GetBuilder<AdvertisementController>(
        builder: (advertisementController) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(image, height: 100, width: 100),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                ),
                child: Text(
                  title.tr,
                  textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                child: Text(
                  description.tr,
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              status == 'cancel_ads' || status == 'pause_ads'
                  ? Form(
                      key: advertisementController.noteFormKey,
                      child: CustomTextFormField(
                        inputType: TextInputType.text,
                        controller: advertisementController.noteController,
                        hintText: status == 'cancel_ads'
                            ? "cancelation_note".tr.replaceAll(":", "")
                            : 'pause_note'.tr,
                        capitalization: TextCapitalization.words,
                        maxLines: 3,
                        onValidate: (value) {
                          return (value == null || value.isEmpty)
                              ? status == 'cancel_ads'
                                    ? 'enter_cancellation_note'.tr
                                    : 'enter_paused_note'.tr
                              : null;
                        },
                      ),
                    )
                  : const SizedBox(),
              status == 'cancel_ads' || status == 'pause_ads'
                  ? const SizedBox(height: Dimensions.paddingSizeLarge)
                  : const SizedBox(),

              Row(
                children: [
                  isShowNotNowButton
                      ? Expanded(
                          flex: 2,
                          child: CustomButton(
                            btnTxt: "not_now".tr,
                            onPressed: () {
                              if (!advertisementController.isLoading) {
                                Get.back();
                              }
                            },
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.2),
                            textColor: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withValues(alpha: 0.8),
                          ),
                        )
                      : const SizedBox(),

                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      isLoading: advertisementController.isLoading,
                      btnTxt: confirmButtonText?.tr ?? "yes".tr,
                      onPressed: !advertisementController.isLoading
                          ? yesButtonPressed
                          : () {},
                      color:
                          yesTestColor ?? Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),

              //SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          );
        },
      ),
    );
  }
}
