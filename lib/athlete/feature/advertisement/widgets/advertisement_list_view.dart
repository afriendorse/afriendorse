import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class AdvertisementListview extends StatelessWidget {
  const AdvertisementListview({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(
      builder: (advertisementController) {
        return Column(
          children: [
            advertisementController.advertisementDataList!.isNotEmpty
                ? Expanded(
                    child: RefreshIndicator(
                      color: Theme.of(context).primaryColorLight,
                      backgroundColor: Theme.of(context).cardColor,
                      onRefresh: () async {
                        Get.find<AdvertisementController>()
                            .getAdvertisementList(
                              Get.find<AdvertisementController>()
                                  .advertisementStatusList[Get.find<
                                    AdvertisementController
                                  >()
                                  .currentIndex],
                              1,
                            );
                      },
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: ClampingScrollPhysics(),
                        ),
                        controller: advertisementController.scrollController,
                        itemCount: advertisementController
                            .advertisementDataList
                            ?.length,
                        padding: EdgeInsets.only(
                          bottom: advertisementController.isLoading
                              ? 0
                              : Dimensions.paddingSizeLarge * 3,
                        ),
                        itemBuilder: (ctx, index) => AdvertisementItem(
                          advertisementData: advertisementController
                              .advertisementDataList![index],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),

            advertisementController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
