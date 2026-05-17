import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class CustomAlertDialogWidget extends StatelessWidget {
  final String? image;
  final IconData? icon;
  final String? title;
  final String? subTitle;
  final TextStyle? subTitleStyle;
  final String? leftButtonText;
  final String? rightButtonText;
  final Function? onPressLeft;
  final Function? onPressRight;
  final Color? iconColor;
  final Widget? iconWidget;
  final bool? isLoading;
  final Color? buttonColor;

  const CustomAlertDialogWidget({
    super.key,
    this.image,
    this.icon,
    this.title,
    this.subTitle,
    this.leftButtonText,
    this.rightButtonText,
    this.onPressLeft,
    this.onPressRight,
    this.iconColor,
    this.isLoading = false,
    this.buttonColor,
    this.iconWidget,
    this.subTitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeLarge,
        horizontal: Dimensions.paddingSizeSmall,
      ),
      // width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Get.back(),
              child: Icon(
                Icons.highlight_remove_outlined,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),

          if (ResponsiveHelper.isDesktop(context))
            const SizedBox(height: Dimensions.paddingSizeLarge),

          if (image != null) Image.asset(image!, width: 50),

          if (icon != null)
            Icon(
              icon!,
              size: 50,
              color: iconColor ?? Theme.of(context).colorScheme.error,
            ),

          if (iconWidget != null) iconWidget!,

          const SizedBox(height: Dimensions.paddingSizeDefault),

          if (title != null)
            Text(
              title!,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          if (subTitle != null)
            Text(
              subTitle!,
              style:
                  subTitleStyle ??
                  robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: Dimensions.imageSize),

          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: SizedBox(
                  width: ResponsiveHelper.isDesktop(context) ? 120 : null,
                  child: CustomButton(
                    color: Theme.of(
                      context,
                    ).disabledColor.withValues(alpha: 0.2),
                    btnTxt: leftButtonText ?? 'no'.tr,
                    textColor: Theme.of(context).textTheme.titleMedium?.color,
                    fontSize: Dimensions.fontSizeLarge,
                    onPressed: onPressLeft != null
                        ? () => onPressLeft!()
                        : () => Get.back(),
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              Flexible(
                child: SizedBox(
                  width: ResponsiveHelper.isDesktop(context) ? 120 : null,
                  child: CustomButton(
                    color: buttonColor,
                    isLoading: isLoading ?? false,
                    btnTxt: rightButtonText ?? 'yes'.tr,
                    onPressed: onPressRight != null
                        ? () => onPressRight!()
                        : () => Get.back(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
