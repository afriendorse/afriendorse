import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class TutorialItemWidget extends StatelessWidget {
  final String? keyName;
  final bool? isActive;
  final Function onTap;
  const TutorialItemWidget({
    super.key,
    this.keyName,
    this.isActive,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimensions.radiusDefault),
          ),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                side: BorderSide(
                  width: 1,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.9),
                ),
                value: isActive,
                onChanged: (_) {},
                // fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                //   if (states.contains(WidgetState.selected)) {
                //     return Theme.of(context).primaryColor; // Checked color
                //   }
                //   return Theme.of(context).cardColor; // Unchecked color
                // }),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            Text(
              (keyName ?? '').tr,
              style: robotoRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
