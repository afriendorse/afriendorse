import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ChooseLanguageScreen extends StatefulWidget {
  const ChooseLanguageScreen({super.key});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  double opacity = 0.5;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        opacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              GetBuilder<LocalizationController>(
                initState: (_) =>
                    Get.find<LocalizationController>().filterLanguage(
                      shouldUpdate: false,
                      isChooseLanguage: true,
                    ),
                builder: (localizationController) {
                  return Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(Images.logo, width: 400),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  Text(
                                    "select_language".tr,
                                    style: robotoMedium.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall,
                                  ),
                                ],
                              ),

                              GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          ResponsiveHelper.isDesktop(context)
                                          ? 4
                                          : ResponsiveHelper.isTab(context)
                                          ? 3
                                          : 2,
                                      childAspectRatio: (1 / 1),
                                    ),
                                itemCount: localizationController
                                    .localLanguages
                                    .length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(
                                  top: Dimensions.paddingSizeSmall,
                                ),
                                itemBuilder: (context, index) => LanguageWidget(
                                  languageModel: localizationController
                                      .localLanguages[index],
                                  localizationController:
                                      localizationController,
                                  index: index,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              Row(
                                children: [
                                  const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  Text(
                                    "language_hint_text".tr,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!
                                          .withValues(alpha: 0.5),
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              GetBuilder<LocalizationController>(
                builder: (localizationController) {
                  return CustomButton(
                    btnTxt: 'save'.tr,
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    onPressed: () {
                      Get.find<SplashController>()
                          .disableShowInitialLanguageScreen();
                      if (localizationController.localLanguages.isNotEmpty &&
                          localizationController.selectedIndex != -1) {
                        localizationController.setLanguage(
                          Locale(
                            localizationController
                                .localLanguages[localizationController
                                    .selectedIndex]
                                .languageCode!,
                            localizationController
                                .localLanguages[localizationController
                                    .selectedIndex]
                                .countryCode,
                          ),
                          isInitial: true,
                        );
                        Get.find<SplashController>().getConfigData();

                        Get.offNamed(RouteHelper.signIn);
                      } else {
                        showCustomSnackBar(
                          'select_a_language'.tr,
                          type: ToasterMessageType.info,
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
