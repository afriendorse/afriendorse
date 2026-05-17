import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class AdCreatedSuccessfullySheet extends StatelessWidget {
  const AdCreatedSuccessfullySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).hintColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            margin: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault * 2,
            ),
          ),

          Image.asset(
            Images.addAdvertisementSuccessfulIcon,
            height: 130,
            fit: BoxFit.fitHeight,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Text(
              "ad_created_successfully".tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.paddingSizeDefault,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: RichText(
              textHeightBehavior: const TextHeightBehavior(
                leadingDistribution: TextLeadingDistribution.even,
              ),
              textAlign: TextAlign.center,

              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'ad_created_successfully_description_1'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                    ),
                  ),

                  TextSpan(
                    text: 'ad_created_successfully_description_2'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        ConversationController conversationController =
                            Get.find();
                        if (conversationController.adminConversationModel !=
                            null) {
                          String name = "admin";
                          ConversationUserModel? conversationUser;
                          if (conversationController
                                      .adminConversationModel
                                      ?.channelUsers !=
                                  null &&
                              conversationController
                                      .adminConversationModel!
                                      .channelUsers!
                                      .length >
                                  1) {
                            conversationUser =
                                conversationController
                                        .adminConversationModel
                                        ?.channelUsers?[0]
                                        .user
                                        ?.userType !=
                                    "super-admin"
                                ? conversationController
                                      .adminConversationModel
                                      ?.channelUsers![0]
                                : conversationController
                                      .adminConversationModel
                                      ?.channelUsers![1];
                          }
                          String image =
                              '${Get.find<SplashController>().configModel.content?.faviconFullPath}';
                          String phone = conversationUser?.user?.phone ?? "";
                          String userType = "super_admin";
                          Get.toNamed(
                            RouteHelper.getChatScreenRoute(
                              conversationUser?.channelId ?? "",
                              name,
                              image,
                              phone,
                              userType,
                            ),
                          );
                        } else {
                          Get.toNamed(RouteHelper.getInboxScreenRoute());
                        }
                      },
                  ),

                  TextSpan(
                    text: 'ad_created_successfully_description_3'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomButton(
            btnTxt: 'okay'.tr,
            width: 100,
            onPressed: () => Get.back(),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      ),
    );
  }
}
