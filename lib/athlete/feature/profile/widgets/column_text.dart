import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ColumnText extends StatelessWidget {
  final String amount;
  final String title;
  const ColumnText({super.key, required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * .27,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              amount.toString(),
              style: robotoBold.copyWith(fontSize: 17, color: Colors.white),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              title,
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
