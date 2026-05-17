import 'package:afriendorse/athlete/feature/notifications/widget/notification_shimmer.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class NotificationScreen extends StatefulWidget {
  final String? fromNotificationPage;
  const NotificationScreen({super.key, this.fromNotificationPage});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<NotificationController>().getNotifications(1, reload: true);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(
          title: "notifications".tr,
          onBackPressed: widget.fromNotificationPage == "notification"
              ? () {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                }
              : null,
        ),
        body: GetBuilder<NotificationController>(
          builder: (controller) {
            return controller.notificationModel == null
                ? const NotificationShimmer()
                : controller.dateList.isEmpty
                ? NoDataScreen(
                    text: 'empty_notifications'.tr,
                    type: NoDataType.notification,
                  )
                : RefreshIndicator(
                    color: Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).cardColor,
                    onRefresh: () async {
                      controller.getNotifications(1);
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index0) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeDefault,
                                      vertical: Dimensions.paddingSizeDefault,
                                    ),
                                    child: Text(
                                      Get.find<NotificationController>()
                                          .dateList[index0]
                                          .toString(),
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.7),
                                      ),
                                      textDirection: TextDirection.ltr,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: Get.isDarkMode
                                          ? null
                                          : [
                                              BoxShadow(
                                                offset: const Offset(0, 1),
                                                blurRadius: 3,
                                                color: Colors.black.withValues(
                                                  alpha: 0.08,
                                                ),
                                              ),
                                            ],
                                      color: Theme.of(context).cardColor,
                                    ),

                                    child: ListView.separated(
                                      itemBuilder: (context, index1) {
                                        return InkWell(
                                          onTap: () => showDialog(
                                            context: context,
                                            builder: (ctx) => ImageDialog(
                                              imageUrl:
                                                  '${controller.notificationList[index0][index1].coverImageFullPath}',
                                              title: controller
                                                  .notificationList[index0][index1]
                                                  .title
                                                  .toString()
                                                  .trim(),
                                              subTitle:
                                                  "${controller.notificationList[index0][index1].description}",
                                            ),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeDefault,
                                              vertical:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            50,
                                                          ),
                                                      child: CustomImage(
                                                        image:
                                                            '${controller.notificationList[index0][index1].coverImageFullPath}',
                                                        height: 30,
                                                        width: 30,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),

                                                    const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeDefault,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            controller
                                                                .notificationList[index0][index1]
                                                                .title
                                                                .toString()
                                                                .trim(),
                                                            style: robotoMedium.copyWith(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .bodyLarge!
                                                                      .color!
                                                                      .withValues(
                                                                        alpha:
                                                                            0.7,
                                                                      ),
                                                              fontSize: Dimensions
                                                                  .fontSizeDefault,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: Dimensions
                                                                .paddingSizeSmall,
                                                          ),
                                                          Text(
                                                            "${controller.notificationList[index0][index1].description}",
                                                            style: robotoRegular.copyWith(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .bodyLarge!
                                                                      .color!
                                                                      .withValues(
                                                                        alpha:
                                                                            0.5,
                                                                      ),
                                                              fontSize: Dimensions
                                                                  .fontSizeDefault,
                                                            ),
                                                            maxLines: 2,
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    SizedBox(
                                                      height: 40,
                                                      width: 65,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            DateConverter.convertStringTimeOnly(
                                                              DateConverter.isoUtcStringToLocalDate(
                                                                controller
                                                                    .notificationList[index0][index1]
                                                                    .createdAt,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: controller
                                          .notificationList[index0]
                                          .length,
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                            return Divider(
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                              thickness: 0.3,
                                            );
                                          },
                                    ),
                                  ),
                                ],
                              );
                            },
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: controller.dateList.length,
                            padding: const EdgeInsets.only(
                              bottom: Dimensions.paddingSizeLarge,
                            ),
                            controller: controller.scrollController,
                          ),
                        ),
                        controller.paginationLoading
                            ? CircularProgressIndicator(
                                color: Theme.of(context).hoverColor,
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }
}
