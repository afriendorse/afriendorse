import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class AdvertisementListScreen extends StatefulWidget {
  final bool isDataAvailable;
  const AdvertisementListScreen({super.key, required this.isDataAvailable});
  @override
  State<AdvertisementListScreen> createState() =>
      _AdvertisementListScreenState();
}

class _AdvertisementListScreenState extends State<AdvertisementListScreen> {
  bool? isDataAvailable;

  @override
  void initState() {
    super.initState();
    Get.find<AdvertisementController>().updateAdvertisementTabIndex(
      0,
      shouldUpdate: false,
    );
    if (!widget.isDataAvailable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomDialog(child: const AddAdvertisementDialog());
      });
    } else {
      Get.find<AdvertisementController>().getAdvertisementList(
        'all',
        1,
        reload: true,
        isFirst: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'advertisement_list'.tr),
      body: GetBuilder<AdvertisementController>(
        builder: (advertisementController) {
          if (!widget.isDataAvailable) {
            isDataAvailable =
                Get.find<AdvertisementController>().advertisementDataList !=
                    null &&
                Get.find<AdvertisementController>()
                    .advertisementDataList!
                    .isNotEmpty;
          } else {
            isDataAvailable = widget.isDataAvailable;
          }

          return isDataAvailable != null && !isDataAvailable!
              ? Center(
                  child: SizedBox(
                    height: Get.height * 0.7,
                    child: NoDataScreen(
                      text: "no_advertisement_created_text".tr,
                      type: NoDataType.advertisement,
                    ),
                  ),
                )
              : Column(
                  children: [
                    const AdvertisementMenuBar(),
                    Expanded(
                      child: TabBarView(
                        controller: advertisementController.listTabController,
                        dragStartBehavior: DragStartBehavior.down,
                        children: const [
                          AdvertisementList(),
                          AdvertisementList(),
                          AdvertisementList(),
                          AdvertisementList(),
                          AdvertisementList(),
                          AdvertisementList(),
                          AdvertisementList(),
                        ],
                      ),
                    ),
                  ],
                );
        },
      ),

      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Get.find<AdvertisementController>().resetAllValues();
          Get.to(() => const CreateAdvertisementScreen(isEditScreen: false));
        },
        child: Icon(Icons.add, color: light.cardColor),
      ),
    );
  }
}

class TurnOnServiceAvailability extends StatelessWidget {
  const TurnOnServiceAvailability({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "service_availability_option_has_turned_off".tr,
              style: robotoRegular.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            InkWell(
              onTap: () => Get.to(const BusinessSettingScreen()),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Dimensions.radiusExtraLarge,
                  ),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall - 3,
                ),
                child: Text(
                  "go_to_business_settings".tr,
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdvertisementList extends StatefulWidget {
  const AdvertisementList({super.key});

  @override
  State<AdvertisementList> createState() => _AdvertisementListState();
}

class _AdvertisementListState extends State<AdvertisementList> {
  int value = 1;

  @override
  void initState() {
    super.initState();

    Get.find<AdvertisementController>().listTabController?.addListener(() {
      if (value == 1) {
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.find<AdvertisementController>().menuScrollController
              ?.scrollToIndex(
                Get.find<AdvertisementController>().listTabController!.index,
                preferPosition: AutoScrollPosition.middle,
                duration: const Duration(milliseconds: 500),
              );
          Get.find<AdvertisementController>().menuScrollController?.highlight(
            Get.find<AdvertisementController>().listTabController!.index,
          );
          Get.find<AdvertisementController>().updateAdvertisementTabIndex(
            Get.find<AdvertisementController>().listTabController!.index,
          );

          Get.find<AdvertisementController>().getAdvertisementList(
            Get.find<AdvertisementController>()
                .advertisementStatusList[Get.find<AdvertisementController>()
                .listTabController!
                .index],
            1,
            reload: true,
          );
        });
        value--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(
      builder: (advertisementController) {
        return advertisementController.advertisementDataList == null
            ? const BookingRequestItemShimmer()
            : advertisementController.advertisementDataList!.isEmpty
            ? Center(
                child: SizedBox(
                  height: Get.height * 0.7,
                  child: NoDataScreen(
                    text:
                        '${'you_have_not'.tr} ${advertisementController.advertisementStatus.tr.toLowerCase()} ${"request_yet".tr}',
                    type: NoDataType.request,
                  ),
                ),
              )
            : const AdvertisementListview();
      },
    );
  }
}
