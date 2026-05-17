import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class AdvertisementMenuBar extends StatefulWidget {
  const AdvertisementMenuBar({super.key});

  @override
  State<AdvertisementMenuBar> createState() => _AdvertisementMenuBarState();
}

class _AdvertisementMenuBarState extends State<AdvertisementMenuBar> {
  AdvertisementController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.menuScrollController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );
    controller.menuScrollController!.scrollToIndex(
      controller.currentIndex,
      preferPosition: AutoScrollPosition.middle,
    );
    controller.menuScrollController!.highlight(controller.currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
        horizontal: Dimensions.paddingSizeSmall,
      ),
      child: ListView.builder(
        controller: controller.menuScrollController,
        itemCount: 7,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GetBuilder<AdvertisementController>(
            builder: (controller) {
              return InkWell(
                child: AutoScrollTag(
                  controller: controller.menuScrollController!,
                  key: ValueKey(index),
                  index: index,
                  child: AdvertisementMenuItem(
                    image: controller.advertisementStatusImageList[index],
                    bookingCount: controller.bookingCount,
                    title: controller.advertisementStatusList[index]
                        .toLowerCase(),
                    index: index,
                  ),
                ),
                onTap: () async {
                  controller.updateAdvertisementTabIndex(index);
                  await controller.menuScrollController!.scrollToIndex(
                    index,
                    preferPosition: AutoScrollPosition.middle,
                    duration: const Duration(milliseconds: 700),
                  );
                  await controller.menuScrollController!.highlight(index);
                },
              );
            },
          );
        },
      ),
    );
  }
}
