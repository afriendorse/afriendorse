import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ProviderNotificationSetup extends StatelessWidget {
  const ProviderNotificationSetup({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationSetupController>(
      builder: (notificationSetupController) {
        List<NotificationSetup>? nList =
            notificationSetupController.tabController?.index == 0 &&
                notificationSetupController.isActiveSuffixIcon
            ? notificationSetupController.searchedProviderNotificationSetupList
            : notificationSetupController.providerNotificationSetupList;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Column(
            children: [
              Expanded(
                child: nList != null && nList.isNotEmpty
                    ? ListView.separated(
                        itemBuilder: (context, index) {
                          return NotificationItemWidget(
                            notificationSetup: nList[index],
                            index: index,
                            userType: "provider",
                          );
                        },
                        itemCount: nList.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: Dimensions.paddingSizeSmall,
                          );
                        },
                      )
                    : nList != null && nList.isEmpty
                    ? NoDataScreen(text: "no_data_found".tr)
                    : nList == null
                    ? const NotificationSetupShimmer()
                    : const SizedBox(),
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomButton(
                btnTxt: "update".tr,
                onPressed: nList != null && nList.isNotEmpty
                    ? () {
                        dynamic body;
                        if (!notificationSetupController.isActiveSuffixIcon) {
                          body = notificationSetupController
                              .getNotificationObject(
                                notificationSetupController
                                    .providerNotificationSetupList,
                              );
                        } else {
                          body = notificationSetupController
                              .getNotificationObject(
                                notificationSetupController
                                    .searchedProviderNotificationSetupList,
                              );
                        }
                        notificationSetupController.updateNotificationSetup(
                          body: body,
                        );
                      }
                    : null,
                isLoading: notificationSetupController.isLoading,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],
          ),
        );
      },
    );
  }
}
