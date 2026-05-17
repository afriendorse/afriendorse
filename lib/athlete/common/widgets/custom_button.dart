import 'package:flutter/material.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final Function()? onPressed;
  final bool? transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double? radius;
  final IconData? icon;
  final Color? color;
  final String btnTxt;
  final bool isLoading;
  final bool isShowLoadingButton;
  final bool showBorder;
  final Color? textColor;

  const CustomButton({
    super.key,
    this.onPressed,
    this.transparent = false,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.fontSize,
    this.radius = 5,
    this.icon,
    required this.btnTxt,
    this.isLoading = false,
    this.isShowLoadingButton = true,
    this.showBorder = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = onPressed == null
        ? Theme.of(context).disabledColor
        : transparent!
        ? Colors.transparent
        : color ?? Theme.of(context).primaryColor;

    final fgColor = transparent!
        ? Theme.of(context).primaryColor
        : textColor ?? Colors.white;

    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      elevation: 0,
      backgroundColor: bgColor,
      minimumSize: Size(width ?? Dimensions.webMaxWidth, height ?? 45),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius!),
        side: showBorder
            ? BorderSide(
                color: (color ?? Theme.of(context).primaryColor).withOpacity(
                  0.6,
                ),
              )
            : BorderSide.none,
      ),
    );

    return Center(
      child: SizedBox(
        width: width ?? Dimensions.webMaxWidth,
        child: Padding(
          padding: margin ?? EdgeInsets.zero,
          child: ElevatedButton(
            onPressed: !isLoading ? onPressed : null,
            style: flatButtonStyle,
            child: Padding(
              padding: isLoading
                  ? const EdgeInsets.only(right: Dimensions.paddingSizeSmall)
                  : EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isShowLoadingButton && isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                      ),
                      child: SizedBox(
                        height: fontSize ?? Dimensions.fontSizeDefault,
                        width: fontSize ?? Dimensions.fontSizeDefault,
                        child: CircularProgressIndicator(
                          color: fgColor,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  if (icon != null && !isLoading)
                    Padding(
                      padding: const EdgeInsets.only(
                        right: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Icon(
                        icon,
                        color: fgColor,
                        size: fontSize ?? Dimensions.fontSizeLarge,
                      ),
                    ),
                  Flexible(
                    child: Text(
                      isLoading ? "loading".tr : btnTxt,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(
                        color: fgColor,
                        fontSize: fontSize ?? Dimensions.fontSizeLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
