import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class CostPercentageWidget extends StatelessWidget {
  final String title;
  final String amount;
  const CostPercentageWidget({
    super.key,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${title.tr} :",
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge - 1,
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
          ),
        ),
        Text(
          " $amount%",
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}
