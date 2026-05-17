import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class AdvertisementMenuItem extends GetView<AdvertisementController> {
  const AdvertisementMenuItem({
    super.key,
    required this.title,
    this.index,
    required this.bookingCount,
    required this.image,
  });
  final String title;
  final String image;
  final int? index;
  final BookingCount? bookingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraSmall,
      ),
      padding: const EdgeInsets.fromLTRB(
        15,
        0,
        10,
        0,
        //vertical: 5
      ),
      decoration: BoxDecoration(
        color: controller.currentIndex != index && Get.isDarkMode
            ? Colors.grey.withValues(alpha: 0.2)
            : controller.currentIndex == index
            ? Theme.of(context).primaryColor
            : Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(image, height: 18, width: 18),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Text(
            title.tr,
            textAlign: TextAlign.center,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: controller.currentIndex == index
                  ? Colors.white
                  : Theme.of(
                      context,
                    ).textTheme.bodyLarge!.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
