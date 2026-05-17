import 'package:afriendorse/athlete/feature/tutorial/controller/tutorial_controller.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:showcaseview/showcaseview.dart';

class AllServicesScreen extends StatefulWidget {
  final bool isTutorialActive;
  const AllServicesScreen({super.key, required this.isTutorialActive});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  AutoScrollController? menuScrollController;
  final GlobalKey subscribeKey = GlobalKey();

  @override
  void initState() {
    ServiceCategoryController controller = Get.find();

    menuScrollController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );
    menuScrollController!.scrollToIndex(
      controller.selectedCategory,
      preferPosition: AutoScrollPosition.middle,
    );
    menuScrollController!.highlight(controller.selectedCategory);

    controller.getCategoryList(shouldUpdate: false, reloadSubcategory: true);

    if (widget.isTutorialActive) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCaseWidget.of(context).startShowCase([subscribeKey]),
      );
      Get.find<TutorialController>().updateTutorial(
        key: AppConstants.serviceSubscriptionTutorialKey,
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).primaryColor.withValues(alpha: 0.05),
      appBar: MainAppBar(
        title: 'available_services',
        color: Theme.of(context).primaryColor,
      ),

      body: GetBuilder<ServiceCategoryController>(
        builder: (allServiceController) {
          if (allServiceController.serviceCategoryList == null) {
            return const CategorySubcategoryShimmer();
          } else {
            return allServiceController.serviceCategoryList != null &&
                    allServiceController.serviceCategoryList!.isEmpty
                ? SizedBox(
                    height: Get.height * .8,
                    child: Center(
                      child: NoDataScreen(
                        showCaseKey: subscribeKey,
                        text: "no_available_service".tr,
                        type: NoDataType.service,
                      ),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Container(
                            width: 110,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.only(
                                bottomRight:
                                    allServiceController.selectedCategory == 0
                                    ? const Radius.circular(15)
                                    : const Radius.circular(0),
                              ),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                  ),
                                  child: Text(
                                    "sport_categories".tr,
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              width: 110,
                              child: ListView.builder(
                                itemCount: allServiceController
                                    .serviceCategoryList
                                    ?.length,
                                controller: menuScrollController,
                                physics: const ClampingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: AutoScrollTag(
                                      controller: menuScrollController!,
                                      key: ValueKey(index),
                                      index: index,
                                      child: Column(
                                        children: [
                                          CategoryItem(
                                            index: index,
                                            image:
                                                allServiceController
                                                    .serviceCategoryList?[index]
                                                    .imageFullPath
                                                    .toString() ??
                                                "",
                                            title:
                                                allServiceController
                                                    .serviceCategoryList?[index]
                                                    .name
                                                    .toString() ??
                                                "",
                                            selectedCategory:
                                                allServiceController
                                                    .serviceCategoryList?[allServiceController
                                                        .selectedCategory]
                                                    .name
                                                    .toString() ??
                                                "",
                                          ),
                                          index ==
                                                  (allServiceController
                                                              .serviceCategoryList
                                                              ?.length ??
                                                          1) -
                                                      1
                                              ? Container(
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(
                                                      context,
                                                    ).cardColor,
                                                    borderRadius: BorderRadius.only(
                                                      topRight:
                                                          allServiceController
                                                                  .selectedCategory ==
                                                              allServiceController
                                                                      .serviceCategoryList!
                                                                      .length -
                                                                  1
                                                          ? const Radius.circular(
                                                              Dimensions
                                                                  .paddingSizeDefault,
                                                            )
                                                          : const Radius.circular(
                                                              0,
                                                            ),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                    onTap: () async {
                                      allServiceController.changeCategory(
                                        index,
                                      );
                                      allServiceController.getSubCategoryList(
                                        offset: 1,
                                        isFromPagination: false,
                                      );
                                      await menuScrollController!.scrollToIndex(
                                        index,
                                        preferPosition:
                                            AutoScrollPosition.middle,
                                        duration: const Duration(
                                          milliseconds: 1000,
                                        ),
                                      );
                                      await menuScrollController!.highlight(
                                        index,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: Dimensions.paddingSizeDefault * 3,
                            left: Dimensions.paddingSizeExtraSmall + 2,
                          ),
                          child: SizedBox(
                            child: SubCategoryView(
                              subCategoryList:
                                  allServiceController.serviceSubCategoryList,
                              subscribeKey: subscribeKey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
          }
        },
      ),
    );
  }
}
