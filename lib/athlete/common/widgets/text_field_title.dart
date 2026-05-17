import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class TextFieldTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool requiredMark;
  final double? fontSize;
  final bool isPadding;
  const TextFieldTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.requiredMark = false,
    this.fontSize,
    this.isPadding = true,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isPadding ? Dimensions.paddingSizeSmall : 0,
        top: Dimensions.paddingSizeDefault,
      ),
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: title,
              style: robotoRegular.copyWith(
                color: Theme.of(
                  Get.context!,
                ).textTheme.bodyLarge!.color!.withValues(alpha: 0.9),
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: subtitle ?? "",
              style: robotoRegular.copyWith(
                color: Theme.of(
                  Get.context!,
                ).textTheme.bodyLarge!.color!.withValues(alpha: 0.2),
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: requiredMark ? ' *' : "",
              style: robotoRegular.copyWith(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
