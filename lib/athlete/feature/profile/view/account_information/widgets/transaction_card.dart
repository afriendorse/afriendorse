import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class TransactionCard extends StatelessWidget {
  final String amount;
  final Color amountTextColor;
  final String title;
  final Color borderColor;
  final Color backgroundColor;

  const TransactionCard({
    super.key,
    required this.amount,
    required this.amountTextColor,
    required this.title,
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: Get.isDarkMode ? 0.6 : 1,
          ),
          color: Theme.of(context).cardColor,
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width * .30,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(300),
                    bottomLeft: Radius.circular(50),
                    topLeft: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      backgroundColor,
                      Get.isDarkMode ? Colors.transparent : Colors.white,
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeExtraSmall,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    amount,
                    style: robotoBold.copyWith(
                      color: amountTextColor,
                      fontSize: Dimensions.fontSizeLarge + 2,
                    ),
                  ),
                  Text(
                    title,
                    style: robotoMedium.copyWith(
                      fontSize: width > 400 ? 14 : 13,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
