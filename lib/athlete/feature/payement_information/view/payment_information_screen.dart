import 'package:afriendorse/athlete/common/widgets/custom_shimmer_widget.dart';
import 'package:afriendorse/athlete/feature/payement_information/controller/payment_info_controller.dart';
import 'package:afriendorse/athlete/feature/payement_information/widgets/payment_info_card.dart';
import 'package:afriendorse/athlete/feature/tutorial/controller/tutorial_controller.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class PaymentInformationScreen extends StatefulWidget {
  const PaymentInformationScreen({super.key});

  @override
  State<PaymentInformationScreen> createState() =>
      _PaymentInformationScreenState();
}

class _PaymentInformationScreenState extends State<PaymentInformationScreen> {
  @override
  void initState() {
    super.initState();

    Get.find<PaymentInfoController>().getPaymentMethods(
      isUpdate: false,
      isReload: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final heightSize = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(title: 'payment_information'.tr, centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: GetBuilder<PaymentInfoController>(
          builder: (paymentInfoController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onTertiary.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(
                      Dimensions.paddingSizeSmall,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info,
                        color: Theme.of(
                          context,
                        ).colorScheme.tertiary.withValues(alpha: 0.8),
                        size: Dimensions.paddingSizeLarge,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Flexible(
                        child: Text(
                          'verify_payment_info_warning'.tr,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color
                                ?.withValues(alpha: 0.70),
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.paddingSizeLarge),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(
                        Dimensions.paddingSizeSmall,
                      ),
                    ),
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'payment_information'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async => paymentInfoController
                                .getPaymentMethods(isReload: true),
                            child:
                                paymentInfoController.paymentMethodListModel !=
                                    null
                                ? (paymentInfoController
                                              .paymentMethodListModel
                                              ?.content
                                              ?.isNotEmpty ??
                                          false)
                                      ? ListView.separated(
                                          itemCount:
                                              paymentInfoController
                                                  .paymentMethodListModel
                                                  ?.content
                                                  ?.length ??
                                              0,
                                          separatorBuilder: (_, __) => SizedBox(
                                            height: Dimensions.paddingSizeSmall,
                                          ),
                                          itemBuilder: (context, index) =>
                                              PaymentInfoCard(
                                                index: index,
                                                paymentMethod:
                                                    paymentInfoController
                                                        .paymentMethodListModel
                                                        ?.content?[index],
                                              ),
                                        )
                                      : SingleChildScrollView(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).hintColor
                                                  .withValues(alpha: 0.05),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.paddingSizeEight,
                                                  ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: heightSize * 0.1,
                                                ),

                                                NoDataScreen(
                                                  text:
                                                      'no_payment_info_added_yet'
                                                          .tr,
                                                  type: NoDataType.paymentInfo,
                                                ),

                                                CustomButton(
                                                  btnTxt: 'add_payment_info'.tr,
                                                  onPressed: () {
                                                    final tutorialData =
                                                        Get.find<
                                                              UserProfileController
                                                            >()
                                                            .providerModel
                                                            ?.content
                                                            ?.providerInfo
                                                            ?.tutorialData;

                                                    if (tutorialData?[AppConstants
                                                                .serviceAvailabilityTutorialKey]
                                                            ?.contains('0') ??
                                                        true) {
                                                      Get.find<
                                                            TutorialController
                                                          >()
                                                          .updateTutorial(
                                                            key: AppConstants
                                                                .serviceAvailabilityTutorialKey,
                                                          );
                                                    }

                                                    Get.toNamed(
                                                      RouteHelper.getAddPaymentInformationRoute(),
                                                    );
                                                  },
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.5,
                                                  isLoading: false,
                                                ),
                                                SizedBox(
                                                  height: heightSize * 0.25,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                : CustomShimmerWidget(
                                    isSliver: false,
                                    child: PaymentInfoCard(
                                      index: 5,
                                      paymentMethod: null,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (paymentInfoController
                        .paymentMethodListModel
                        ?.content
                        ?.isNotEmpty ??
                    false)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingSizeSmall,
                    ),
                    child: CustomButton(
                      btnTxt: 'add_payment_info'.tr,
                      onPressed: () => Get.toNamed(
                        RouteHelper.getAddPaymentInformationRoute(),
                      ),
                      width: MediaQuery.of(context).size.width,
                      isLoading: false,
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
