import 'package:afriendorse/athlete/common/widgets/app_bar.dart';
import 'package:afriendorse/athlete/feature/splash/controller/splash_controller.dart';
import 'package:afriendorse/athlete/utils/dimensions.dart';
import 'package:afriendorse/athlete/utils/images.dart';
import 'package:afriendorse/athlete/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppBar(title: 'help_&_support'.tr),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(minHeight: Get.height * 0.4),
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraMoreLarge,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                Images.helpSupportImage,
                                width: 172,
                                height: 80,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraLarge,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'contact_for_support'.tr,
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.paddingSizeLarge,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeDefault,
                                  ),
                                  Text(
                                    'were_here_to_help'.tr,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.paddingSizeLarge),

                    Container(
                      decoration: BoxDecoration(
                        color: Get.isDarkMode
                            ? Colors.grey.withValues(alpha: 0.2)
                            : Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: Dimensions.paddingSizeSmall),
                          ContactWithEmailOrPhone(
                            title: 'call_our_customer'.tr,
                            subTitle: 'talk_with_our_customer'.tr,
                            message:
                                Get.find<SplashController>()
                                    .configModel
                                    .content
                                    ?.businessPhone ??
                                '',
                            isPhone: true,
                          ),
                          ContactWithEmailOrPhone(
                            title: 'send_us_email_through'.tr,
                            subTitle: 'typically_the_support'.tr,
                            message:
                                Get.find<SplashController>()
                                    .configModel
                                    .content
                                    ?.businessEmail ??
                                '',
                            isPhone: false,
                          ),
                          SizedBox(height: Dimensions.paddingSizeSmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ContactWithEmailOrPhone extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? message;
  final bool? isPhone;
  ContactWithEmailOrPhone({
    super.key,
    required this.title,
    required this.subTitle,
    required this.message,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeEight,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        color: Theme.of(context).cardColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Get.isDarkMode
                  ? Colors.grey.withValues(alpha: 0.2)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.05),
            ),
            child: Image.asset(
              isPhone ?? false ? Images.phoneIconBlue : Images.mailIconBlue,
              height: 15,
              width: 15,
            ),
          ),
          SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: robotoMedium.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
                    fontSize: Dimensions.paddingSizeLarge,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(
                  subTitle!,
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isPhone!
                          ? (Get.find<SplashController>()
                                    .configModel
                                    .content
                                    ?.businessPhone ??
                                '')
                          : (Get.find<SplashController>()
                                    .configModel
                                    .content
                                    ?.businessEmail ??
                                ''),
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),

                    InkWell(
                      onTap: () async {
                        if (isPhone!) {
                          await launchUrl(launchUri);
                        } else {
                          await launchUrl(email);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusExtraLarge,
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Image.asset(
                          isPhone!
                              ? Images.phoneIconWhite
                              : Images.mailIconWhite,
                          height: 15,
                          width: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final Uri launchUri = Uri(
    scheme: 'tel',
    path: Get.find<SplashController>().configModel.content!.businessPhone
        .toString(),
  );
  final Uri email = Uri(
    scheme: 'mailto',
    path: Get.find<SplashController>().configModel.content!.businessEmail,
  );
}
