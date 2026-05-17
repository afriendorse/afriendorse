import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/suggest_service/widgets/suggest_service_input_field.dart';
import 'package:get/get.dart';

class SuggestServiceScreen extends StatefulWidget {
  const SuggestServiceScreen({super.key});

  @override
  State<SuggestServiceScreen> createState() => _SuggestServiceScreenState();
}

class _SuggestServiceScreenState extends State<SuggestServiceScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Get.find<SuggestServiceController>().updateShowInputField(
      shouldUpdate: false,
      showInputField: false,
      buttonPadding: 230,
      opacity: 0.0,
      imageSize: 100,
    );
    Get.find<SuggestServiceController>().updateCategoryValidateValue(
      shouldUpdate: false,
      isInitial: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "service_request".tr,
        actionWidget: IconButton(
          onPressed: () {
            Get.to(() => const SuggestedServiceListScreen());
          },
          icon: Icon(Icons.list, color: Theme.of(context).primaryColor),
        ),
      ),
      body: GetBuilder<SuggestServiceController>(
        builder: (suggestServiceController) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: SizedBox(
                height: Get.height - 100,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault,
                            ),
                            child: Text(
                              'tell_us_more_about_your_service'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.9),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                            ),
                            child: Text(
                              'suggest_more_service_that_you_willing'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeExtraLarge,
                              ),
                              child: Image.asset(
                                Images.suggestServiceIcon,
                                width:
                                    suggestServiceController.initialImageSize,
                              ),
                            ),
                          ),

                          AnimatedOpacity(
                            opacity: suggestServiceController
                                .initialContainerOpacity,
                            duration: const Duration(milliseconds: 1500),
                            child: const SuggestServiceInputField(),
                          ),
                        ],
                      ),
                    ),

                    AnimatedPositioned(
                      top: suggestServiceController.initialButtonPadding,
                      duration: const Duration(milliseconds: 500),
                      child: CustomButton(
                        width: 240,
                        fontSize: Dimensions.fontSizeDefault,
                        isLoading: suggestServiceController.isLoading,
                        btnTxt: suggestServiceController.isShowInputField
                            ? "send_request".tr
                            : 'request_for_service'.tr,
                        onPressed: () {
                          if (!suggestServiceController.isShowInputField) {
                            suggestServiceController.clearData();
                            suggestServiceController.updateShowInputField();
                          } else {
                            suggestServiceController
                                .updateCategoryValidateValue();
                            if (formKey.currentState!.validate() &&
                                suggestServiceController.isCategoryValidate) {
                              suggestServiceController
                                  .submitNewServiceRequest();
                            }
                          }
                        },
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
