/*
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingRequestMenuBar extends StatefulWidget {
  const BookingRequestMenuBar({super.key});

  @override
  State<BookingRequestMenuBar> createState() => _BookingRequestMenuBarState();
}

class _BookingRequestMenuBarState extends State<BookingRequestMenuBar> {
  BookingRequestController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.menuScrollController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );
    Get.find<BookingRequestController>().menuScrollController!.scrollToIndex(
      controller.currentIndex,
      preferPosition: AutoScrollPosition.middle,
    );
    controller.menuScrollController!.highlight(controller.currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingRequestController>(
      builder: (bookingRequestController) {
        return Column(
          children: [
            if (bookingRequestController.selectedServiceType != ServiceType.all)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  bookingRequestController.selectedServiceType ==
                          ServiceType.regular
                      ? "regular_booking".tr
                      : "repeat_booking".tr,
                ),
              ),

            Container(
              color: Theme.of(context).colorScheme.surface,
              width: double.infinity,
              height: 55,
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeSmall,
                horizontal: Dimensions.paddingSizeSmall,
              ),
              child: ListView.builder(
                controller: controller.menuScrollController,
                itemCount: 6,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GetBuilder<BookingRequestController>(
                    builder: (controller) {
                      return InkWell(
                        child: AutoScrollTag(
                          controller: controller.menuScrollController!,
                          key: ValueKey(index),
                          index: index,
                          child: BookingRequestMenuItem(
                            bookingCount: controller.bookingCount,
                            title: controller.bookingRequestStatusList[index]
                                .toLowerCase(),
                            index: index,
                          ),
                        ),
                        onTap: () async {
                          controller.updateBookingRequestIndex(index);
                          await controller.menuScrollController!.scrollToIndex(
                            index,
                            preferPosition: AutoScrollPosition.middle,
                            duration: const Duration(milliseconds: 700),
                          );
                          await controller.menuScrollController!.highlight(
                            index,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

*/

import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingRequestMenuBar extends StatefulWidget {
  const BookingRequestMenuBar({super.key});

  @override
  State<BookingRequestMenuBar> createState() => _BookingRequestMenuBarState();
}

class _BookingRequestMenuBarState extends State<BookingRequestMenuBar> {
  BookingRequestController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.menuScrollController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );
    Get.find<BookingRequestController>().menuScrollController!.scrollToIndex(
      controller.currentIndex,
      preferPosition: AutoScrollPosition.middle,
    );
    controller.menuScrollController!.highlight(controller.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingRequestController>(
      builder: (bookingRequestController) {
        return Column(
          children: [
            if (bookingRequestController.selectedServiceType != ServiceType.all)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  bookingRequestController.selectedServiceType ==
                          ServiceType.regular
                      ? "regular_booking".tr
                      : "repeat_booking".tr,
                ),
              ),
            Container(
              color: Theme.of(context).colorScheme.surface,
              width: double.infinity,
              height: 55,
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeSmall,
                horizontal: Dimensions.paddingSizeSmall,
              ),
              child: ListView.builder(
                controller: controller.menuScrollController,
                itemCount: 5, // updated from 6 since "all" is commented out
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GetBuilder<BookingRequestController>(
                    builder: (controller) {
                      return GetBuilder<PostController>(
                        builder: (postController) {
                          return InkWell(
                            child: AutoScrollTag(
                              controller: controller.menuScrollController!,
                              key: ValueKey(index),
                              index: index,
                              child: BookingRequestMenuItem(
                                bookingCount: controller.bookingCount,
                                title: controller
                                    .bookingRequestStatusList[index]
                                    .toLowerCase(),
                                index: index,
                                // index 0 = pending (since "all" is commented out)
                                overrideCount: index == 0
                                    ? postController.bidPostList?.length
                                    : null,
                              ),
                            ),
                            onTap: () async {
                              controller.updateBookingRequestIndex(index);
                              await controller.menuScrollController!
                                  .scrollToIndex(
                                    index,
                                    preferPosition: AutoScrollPosition.middle,
                                    duration: const Duration(milliseconds: 700),
                                  );
                              await controller.menuScrollController!.highlight(
                                index,
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
