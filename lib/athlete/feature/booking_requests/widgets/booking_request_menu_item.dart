/*
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingRequestMenuItem extends GetView<BookingRequestController> {
  const BookingRequestMenuItem({
    super.key,
    required this.title,
    this.index,
    required this.bookingCount,
  });
  final String title;
  final int? index;
  final BookingCount? bookingCount;

  @override
  Widget build(BuildContext context) {
    int? allBookingCount =
        (bookingCount?.pending ?? 0) +
        (bookingCount?.accepted ?? 0) +
        (bookingCount?.ongoing ?? 0) +
        (bookingCount?.completed ?? 0) +
        (bookingCount?.canceled ?? 0);

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
          const SizedBox(width: Dimensions.paddingSizeExtraSmall + 2),
          bookingCount != null
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Theme.of(context).cardColor.withValues(
                      alpha: controller.currentIndex == index ? 0.3 : 0.7,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  child: Text(
                    title == "all"
                        ? bookingCount == null
                              ? ""
                              : "${(allBookingCount)}"
                        : title == "accepted"
                        ? bookingCount?.accepted == null
                              ? ""
                              : "${bookingCount?.accepted}"
                        : title == "ongoing"
                        ? bookingCount?.ongoing == null
                              ? ""
                              : "${bookingCount?.ongoing}"
                        : title == "completed"
                        ? bookingCount?.completed == null
                              ? ""
                              : "${bookingCount?.completed}"
                        : title == "canceled"
                        ? bookingCount?.canceled == null
                              ? ""
                              : "${bookingCount?.canceled}"
                        : bookingCount?.pending == null
                        ? ""
                        : "${bookingCount?.pending}",

                    style: robotoMedium.copyWith(
                      color: controller.currentIndex == index
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge!.color
                                ?.withValues(alpha: 0.7),
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

*/

import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingRequestMenuItem extends GetView<BookingRequestController> {
  const BookingRequestMenuItem({
    super.key,
    required this.title,
    this.index,
    required this.bookingCount,
    this.overrideCount,
  });

  final String title;
  final int? index;
  final BookingCount? bookingCount;
  final int? overrideCount;

  @override
  Widget build(BuildContext context) {
    int? allBookingCount =
        (bookingCount?.pending ?? 0) +
        (bookingCount?.accepted ?? 0) +
        (bookingCount?.ongoing ?? 0) +
        (bookingCount?.completed ?? 0) +
        (bookingCount?.canceled ?? 0);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraSmall,
      ),
      padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
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
          const SizedBox(width: Dimensions.paddingSizeExtraSmall + 2),
          bookingCount != null
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Theme.of(context).cardColor.withValues(
                      alpha: controller.currentIndex == index ? 0.3 : 0.7,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  child: Text(
                    overrideCount != null
                        ? "$overrideCount"
                        : title == "all"
                        ? bookingCount == null
                              ? ""
                              : "${(allBookingCount)}"
                        : title == "accepted"
                        ? bookingCount?.accepted == null
                              ? ""
                              : "${bookingCount?.accepted}"
                        : title == "ongoing"
                        ? bookingCount?.ongoing == null
                              ? ""
                              : "${bookingCount?.ongoing}"
                        : title == "completed"
                        ? bookingCount?.completed == null
                              ? ""
                              : "${bookingCount?.completed}"
                        : title == "canceled"
                        ? bookingCount?.canceled == null
                              ? ""
                              : "${bookingCount?.canceled}"
                        : bookingCount?.pending == null
                        ? ""
                        : "${bookingCount?.pending}",
                    style: robotoMedium.copyWith(
                      color: controller.currentIndex == index
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge!.color
                                ?.withValues(alpha: 0.7),
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
