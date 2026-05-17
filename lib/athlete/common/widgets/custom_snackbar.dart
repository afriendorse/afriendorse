import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

void showCustomSnackBar(
  String? message, {
  ToasterMessageType type = ToasterMessageType.error,
  int duration = 2,
  String? toasterTitle,
  String? icon,
}) {
  if (message != null && message.isNotEmpty) {
    Get.closeAllSnackbars();
    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.transparent,
        duration: Duration(seconds: duration),
        overlayBlur: 0.0,
        messageText: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF393f47),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon != null
                      ? Image.asset(icon, width: 25)
                      : CustomToasterIcon(type: type),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (toasterTitle != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              toasterTitle.tr,
                              style: robotoMedium.copyWith(color: Colors.white),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Text(
                          message,
                          style: robotoRegular.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            height: toasterTitle != null ? 1.0 : 1.2,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        borderRadius: 10,
        padding: const EdgeInsets.all(0),
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
        forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
        reverseAnimationCurve: Curves.fastEaseInToSlowEaseOut,
        animationDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

class CustomToasterIcon extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final ToasterMessageType type;
  final Color checkColor;

  const CustomToasterIcon({
    super.key,
    required this.type,
    this.size = Dimensions.paddingSizeLarge,
    this.backgroundColor,
    this.checkColor = Colors.white,
  });

  ({Color color, IconData icon}) _getDataByType(BuildContext context) {
    switch (type) {
      case ToasterMessageType.success:
        return (color: context.customThemeColors.success, icon: Icons.check);
      case ToasterMessageType.error:
        return (color: context.customThemeColors.error, icon: Icons.close);

      case ToasterMessageType.info:
        return (
          color: context.customThemeColors.info,
          icon: Icons.info_outline,
        );
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    final data = _getDataByType(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? data.color,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Icon(
          data.icon,
          size: size * 0.7, // Relative sizing
          color: checkColor,
        ),
      ),
    );
  }
}
