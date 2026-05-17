import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SignUpStep5 extends StatefulWidget {
  const SignUpStep5({super.key});
  @override
  State<SignUpStep5> createState() => _SignUpStep5State();
}

class _SignUpStep5State extends State<SignUpStep5> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          await Get.find<SplashController>().getConfigData();
          await Get.find<BusinessSubscriptionController>()
              .getSubscriptionPackageList(reload: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          child: GetBuilder<SplashController>(
            builder: (splashController) {
              return GetBuilder<SignUpController>(
                builder: (signUpController) {
                  String? trialType = splashController
                      .configModel
                      .content
                      ?.subscriptionFreeTrailType;
                  int trialPeriod =
                      splashController
                          .configModel
                          .content
                          ?.subscriptionFreeTrailPeriod ??
                      0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        splashController
                                        .configModel
                                        .content
                                        ?.subscriptionFreeTrail ==
                                    1 ||
                                splashController
                                        .configModel
                                        .content
                                        ?.digitalPayment ==
                                    1
                            ? Column(
                                children: [
                                  splashController
                                              .configModel
                                              .content
                                              ?.subscriptionFreeTrail ==
                                          1
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            top: Dimensions
                                                .paddingSizeExtraLarge,
                                          ),
                                          child: Text(
                                            "free_trail_hint_text".tr,
                                            textAlign: TextAlign.start,
                                            style: robotoRegular.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),

                                  const SizedBox(
                                    height: Dimensions.paddingSizeExtraLarge,
                                  ),

                                  (splashController
                                              .configModel
                                              .content
                                              ?.subscriptionFreeTrail ==
                                          1)
                                      ? BusinessPlanCard(
                                          title:
                                              "$trialPeriod ${(trialType == "day" && trialPeriod > 1)
                                                  ? "days".tr
                                                  : (trialType == "day" && trialPeriod <= 1)
                                                  ? "day".tr
                                                  : (trialType == "month" && trialPeriod > 1)
                                                  ? "months".tr
                                                  : (trialType == "month" && trialPeriod <= 1)
                                                  ? "month".tr
                                                  : ""} ${'free_trail'.tr}",
                                          subtitle: "trial_end_hint_text".tr,
                                          cardColor:
                                              signUpController
                                                      .selectedSubscriptionPaymentType ==
                                                  SubscriptionPaymentType
                                                      .freeTrail
                                              ? Theme.of(context).primaryColor
                                                    .withValues(alpha: 0.05)
                                              : null,
                                          isSelected:
                                              signUpController
                                                  .selectedSubscriptionPaymentType ==
                                              SubscriptionPaymentType.freeTrail,
                                          onTap: () {
                                            signUpController
                                                .updateDigitalPaymentMethodIndex(
                                                  -1,
                                                );
                                            signUpController
                                                .updateSubscriptionPaymentType(
                                                  SubscriptionPaymentType
                                                      .freeTrail,
                                                );
                                          },
                                        )
                                      : const SizedBox(),

                                  const SizedBox(
                                    height: Dimensions.paddingSizeLarge,
                                  ),

                                  splashController
                                              .configModel
                                              .content
                                              ?.digitalPayment ==
                                          1
                                      ? signUpController
                                                    .selectedSubscriptionPaymentType ==
                                                SubscriptionPaymentType.digital
                                            ? SelectedDigitalPaymentWidget(
                                                signUpController:
                                                    signUpController,
                                              )
                                            : BusinessPlanCard(
                                                title: "pay_via_online",
                                                subtitle:
                                                    "${'faster_and_secure_way_to_pay_and_grow_your_business_with'.tr} ${AppConstants.appName}",
                                                cardColor:
                                                    signUpController
                                                            .selectedSubscriptionPaymentType ==
                                                        SubscriptionPaymentType
                                                            .digital
                                                    ? Theme.of(
                                                        context,
                                                      ).primaryColor.withValues(
                                                        alpha: 0.05,
                                                      )
                                                    : null,
                                                isSelected:
                                                    signUpController
                                                        .selectedSubscriptionPaymentType ==
                                                    SubscriptionPaymentType
                                                        .digital,
                                                onTap: () {
                                                  signUpController
                                                      .updateSubscriptionPaymentType(
                                                        SubscriptionPaymentType
                                                            .digital,
                                                      );
                                                },
                                              )
                                      : const SizedBox(),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                  top: Dimensions.paddingSizeExtraMoreLarge,
                                ),
                                child: Text("no_payment_option_available".tr),
                              ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class SelectedDigitalPaymentWidget extends StatelessWidget {
  final SignUpController signUpController;
  const SelectedDigitalPaymentWidget({
    super.key,
    required this.signUpController,
  });

  @override
  Widget build(BuildContext context) {
    List<DigitalPaymentMethod> paymentMethodList =
        Get.find<SplashController>().configModel.content?.paymentMethodList ??
        [];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
      child: Column(
        children: [
          BusinessPlanCard(
            title: "pay_via_online",
            subtitle:
                "${'faster_and_secure_way_to_pay_and_grow_your_business_with'.tr} ${AppConstants.appName}",
            isSelected:
                signUpController.selectedSubscriptionPaymentType ==
                SubscriptionPaymentType.digital,
            showBorder: false,
            cardColor:
                signUpController.selectedSubscriptionPaymentType ==
                    SubscriptionPaymentType.digital
                ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                : null,
            onTap: () {
              signUpController.updateSubscriptionPaymentType(
                SubscriptionPaymentType.digital,
              );
            },
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          ListView.builder(
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  DigitalPaymentButtonWidget(
                    isSelected:
                        signUpController.selectedDigitalPaymentMethodIndex ==
                        index,
                    paymentMethod: paymentMethodList[index],
                  ),

                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeSmall,
                      ),
                      child: CustomInkWell(
                        onTap: () {
                          signUpController.updateDigitalPaymentMethodIndex(
                            index,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paymentMethodList.length,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
          ),
        ],
      ),
    );
  }
}
