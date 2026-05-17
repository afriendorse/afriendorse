import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationSetup notificationSetup;
  final String userType;
  final int index;
  const NotificationItemWidget({
    super.key,
    required this.notificationSetup,
    required this.index,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationSetupController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: context.customThemeColors.lightShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeExtraSmall + 3,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notificationSetup.title ?? "",
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .color!
                                  .withValues(alpha: 0.7),
                            ),
                          ),

                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),

                          Text(
                            notificationSetup.subTitle ?? "",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .color!
                                  .withValues(alpha: 0.5),
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (notificationSetup.value?.notification != null)
                                CustomCheckBox(
                                  title: "push_notification".tr,
                                  value:
                                      notificationSetup.value?.notification == 1
                                      ? (notificationSetup
                                                        .providerNotifications
                                                        ?.value
                                                        ?.notification ==
                                                    1 ||
                                                notificationSetup
                                                        .providerNotifications
                                                        ?.value
                                                        ?.notification ==
                                                    null)
                                            ? true
                                            : false
                                      : false,
                                  onTap:
                                      notificationSetup.value?.notification == 1
                                      ? () {
                                          var value =
                                              notificationSetup
                                                  .providerNotifications
                                                  ?.value
                                                  ?.notification ??
                                              notificationSetup
                                                  .value
                                                  ?.notification ??
                                              0;
                                          controller.toggleCheckbox(
                                            userType: userType,
                                            type: "notification",
                                            value: value,
                                            index: index,
                                          );
                                        }
                                      : () {
                                          showCustomSnackBar(
                                            "this_option_is_disabled_from_admin"
                                                .tr,
                                            type: ToasterMessageType.info,
                                          );
                                        },
                                ),
                              if (notificationSetup.value?.sms != null)
                                CustomCheckBox(
                                  title: "sms".tr,
                                  value: notificationSetup.value?.sms == 1
                                      ? (notificationSetup
                                                        .providerNotifications
                                                        ?.value
                                                        ?.sms ==
                                                    1 ||
                                                notificationSetup
                                                        .providerNotifications
                                                        ?.value
                                                        ?.sms ==
                                                    null)
                                            ? true
                                            : false
                                      : false,
                                  onTap: notificationSetup.value?.sms == 1
                                      ? () {
                                          var value =
                                              notificationSetup
                                                  .providerNotifications
                                                  ?.value
                                                  ?.sms ??
                                              notificationSetup.value?.sms ??
                                              0;
                                          controller.toggleCheckbox(
                                            userType: userType,
                                            type: "sms",
                                            value: value,
                                            index: index,
                                          );
                                        }
                                      : () {
                                          showCustomSnackBar(
                                            "this_option_is_disabled_from_admin"
                                                .tr,
                                            type: ToasterMessageType.info,
                                          );
                                        },
                                ),
                              if (notificationSetup.value?.email != null)
                                CustomCheckBox(
                                  title: "mail".tr,
                                  value: notificationSetup.value?.email == 1
                                      ? (notificationSetup
                                                        .providerNotifications
                                                        ?.value
                                                        ?.email ==
                                                    1 ||
                                                notificationSetup
                                                        .providerNotifications
                                                        ?.value
                                                        ?.email ==
                                                    null)
                                            ? true
                                            : false
                                      : false,
                                  onTap: notificationSetup.value?.email == 1
                                      ? () {
                                          var value =
                                              notificationSetup
                                                  .providerNotifications
                                                  ?.value
                                                  ?.email ??
                                              notificationSetup.value?.email ??
                                              0;
                                          controller.toggleCheckbox(
                                            userType: userType,
                                            type: "email",
                                            value: value,
                                            index: index,
                                          );
                                        }
                                      : () {
                                          showCustomSnackBar(
                                            "this_option_is_disabled_from_admin"
                                                .tr,
                                            type: ToasterMessageType.info,
                                          );
                                        },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: Dimensions.paddingSizeDefault),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
