import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class AdminFeedbackDialog extends StatelessWidget {
  final int index;

  const AdminFeedbackDialog({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      title: Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      content: SingleChildScrollView(
        child: GetBuilder<SuggestServiceController>(
          builder: (controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "admin_feedback".tr,
                        style: robotoMedium.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.color!.withValues(alpha: 0.9),
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${"category_name".tr} : ",
                            style: robotoRegular.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withValues(alpha: 0.8),
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),

                          Flexible(
                            child: Text(
                              controller
                                      .suggestedServiceList[index]
                                      .category
                                      ?.name ??
                                  "",
                              style: robotoRegular.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.5),
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${"service_name".tr} : ",
                            style: robotoRegular.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withValues(alpha: 0.8),
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),

                          Flexible(
                            child: Text(
                              controller
                                      .suggestedServiceList[index]
                                      .serviceName ??
                                  "",
                              style: robotoRegular.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.5),
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(),
                      controller.suggestedServiceList[index].adminFeedback !=
                                  null &&
                              controller
                                      .suggestedServiceList[index]
                                      .adminFeedback !=
                                  ""
                          ? Text(
                              controller
                                  .suggestedServiceList[index]
                                  .adminFeedback
                                  .toString(),
                              style: robotoRegular.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.5),
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                              textAlign: TextAlign.justify,
                            )
                          : Text(
                              controller.suggestedServiceList[index].status ==
                                      "pending"
                                  ? "under_review".tr
                                  : "no_feedback_is_available".tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.5),
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),

                      const Divider(),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
