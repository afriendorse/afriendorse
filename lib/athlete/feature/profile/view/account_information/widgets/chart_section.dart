import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class TransactionChart extends StatelessWidget {
  const TransactionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Container(
        height: 270,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: Colors.lightBlue.shade100,
            width: Get.isDarkMode ? 0.6 : 1,
          ),
          color: Theme.of(context).cardColor,
        ),
        child: const TransactionPieChart(),
      ),
    );
  }
}
