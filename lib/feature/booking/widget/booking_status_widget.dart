import 'package:afriendorse/helper/extension_helper.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class BookingStatusButtonWidget extends StatelessWidget {
  final String? bookingStatus;
  const BookingStatusButtonWidget({super.key, this.bookingStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeTine,
        horizontal: Dimensions.paddingSizeEight,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        //  color: context.customThemeColors.buttonBackgroundColorMap[bookingStatus],
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Text(
        bookingStatus?.tr ?? "",
        style: robotoMedium.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: Dimensions.fontSizeSmall,
          color: Colors.white,
          // color: context.customThemeColors.buttonTextColorMap[bookingStatus],
        ),
      ),
    );
  }
}
