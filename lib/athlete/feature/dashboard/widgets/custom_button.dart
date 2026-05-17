import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class GraphCustomButton extends StatelessWidget {
  final String buttonText;
  final bool isSelectedButton;
  const GraphCustomButton({
    super.key,
    required this.buttonText,
    required this.isSelectedButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: isSelectedButton ? context.customThemeColors.shadow : null,
        color: isSelectedButton
            ? Theme.of(context).cardColor
            : Colors.grey.withValues(alpha: 0.2),
      ),
      child: Center(
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: Dimensions.fontSizeSmall,
            color: isSelectedButton
                ? Theme.of(context).primaryColor
                : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
