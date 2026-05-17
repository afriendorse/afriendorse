import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class CustomBottomSheetWidget extends StatelessWidget {
  final String? icon;
  final String? title;
  final String? subTitle;
  final String? buttonText;
  final String? errorText;
  final bool isLoading;
  final Function()? onTap;
  const CustomBottomSheetWidget({
    super.key,
    this.icon,
    this.title,
    this.subTitle,
    this.errorText,
    this.onTap,
    this.buttonText,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.paddingSizeDefault),
          topRight: Radius.circular(Dimensions.paddingSizeDefault),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).hintColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            margin: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault * 2,
            ),
          ),

          Image.asset(
            icon ?? Images.welcomeIcon,
            height: 80,
            fit: BoxFit.fitHeight,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            title ?? "",
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault * 2,
            ),
            child: Text(
              subTitle?.tr ?? "",
              maxLines: 5,
              style: robotoRegular.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge * 1.3),

          CustomButton(
            btnTxt: buttonText?.tr ?? "",
            fontSize: Dimensions.fontSizeDefault,
            width: 100,
            isLoading: isLoading,
            onPressed: onTap ?? () => Get.back(),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      ),
    );
  }
}
