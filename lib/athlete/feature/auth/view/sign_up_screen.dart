import 'package:afriendorse/athlete/feature/auth/widgets/auth_pattern_background.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> step2FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> step3FormKey = GlobalKey<FormState>();

  static const Color _primaryGreen = Color(0xFF045F25);
  static const Color _darkGreen = Color(0xFF033D18);

  @override
  void initState() {
    super.initState();
    _loadData();
    Get.find<LocationController>().setPickedLocation(shouldUpdate: false);
    Get.find<SignUpController>().checkOthersFieldValidity(
      shouldUpdate: false,
      isInitial: true,
    );
  }

  _loadData() {
    Get.find<SplashController>().getConfigData();
    Get.find<BusinessSubscriptionController>().getSubscriptionPackageList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const SignUpAppbar(),
      body: Stack(
        children: [
          // ── Subtle pattern background ──────────────────────────────────
          const Positioned.fill(child: AuthFaPatternBackground(formMode: true)),

          // ── Content ───────────────────────────────────────────────────
          SafeArea(
            bottom: GetPlatform.isIOS ? true : false,
            child: GetBuilder<SplashController>(
              builder: (splashController) {
                var config = splashController.configModel.content;
                return GetBuilder<SignUpController>(
                  builder: (signUpController) {
                    return Column(
                      children: [
                        signUpController.currentStep == SignUpPageStep.step1
                            ? SignUpStep1(formKey: step1FormKey)
                            : signUpController.currentStep ==
                                  SignUpPageStep.step2
                            ? SignUpStep2(formKey: step2FormKey)
                            : signUpController.currentStep ==
                                  SignUpPageStep.step3
                            ? SignUpStep3(formKey: step3FormKey)
                            : signUpController.currentStep ==
                                  SignUpPageStep.step4
                            ? const SignUpStep4()
                            : const SignUpStep5(),

                        const SizedBox(height: 12),

                        // ── Bottom action bar ───────────────────────────
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _primaryGreen.withOpacity(0.10),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryGreen.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (signUpController.currentStep !=
                                  SignUpPageStep.step1)
                                _buildBackButton(context, signUpController),

                              if (signUpController.currentStep !=
                                  SignUpPageStep.step1)
                                const SizedBox(width: 12),

                              _buildNextButton(
                                context,
                                signUpController,
                                config,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: GetPlatform.isIOS
                              ? 0
                              : Dimensions.paddingSizeSmall,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(
    BuildContext context,
    SignUpController signUpController,
  ) {
    return SizedBox(
      height: 44,
      width: 100,
      child: OutlinedButton(
        onPressed: () => signUpController.updateRegistrationStep(
          signUpController.currentStep == SignUpPageStep.step5
              ? SignUpPageStep.step4
              : signUpController.currentStep == SignUpPageStep.step4
              ? SignUpPageStep.step3
              : signUpController.currentStep == SignUpPageStep.step3
              ? SignUpPageStep.step2
              : SignUpPageStep.step1,
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _primaryGreen.withOpacity(0.4), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          'back'.tr,
          style: const TextStyle(
            color: _primaryGreen,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(
    BuildContext context,
    SignUpController signUpController,
    dynamic config,
  ) {
    final bool isConfirm =
        (signUpController.currentStep == SignUpPageStep.step5 ||
        (signUpController.currentStep == SignUpPageStep.step4 &&
            signUpController.selectedBusinessPlan ==
                BusinessPlanType.commissionBase));

    final bool isDisabled =
        signUpController.currentStep == SignUpPageStep.step5 &&
        config?.digitalPayment == 0 &&
        config?.subscriptionFreeTrail == 0;

    return Container(
      height: 44,
      width: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isDisabled
            ? null
            : const LinearGradient(
                colors: [_primaryGreen, _darkGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDisabled ? const Color(0xFFCCCCCC) : null,
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: GetBuilder<SignUpController>(
        builder: (sc) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isDisabled
                  ? null
                  : () {
                      if (signUpController.currentStep ==
                          SignUpPageStep.step1) {
                        validateStep1(signUpController);
                      } else if (signUpController.currentStep ==
                          SignUpPageStep.step2) {
                        validateStep2(signUpController);
                      } else if (signUpController.currentStep ==
                          SignUpPageStep.step3) {
                        validateStep3(signUpController);
                      } else if (signUpController.currentStep ==
                          SignUpPageStep.step4) {
                        validateStep4(signUpController);
                      } else {
                        validateStep5(signUpController);
                      }
                    },
              child: Center(
                child: sc.isLoading!
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isConfirm ? 'confirm'.tr : 'next'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (!isConfirm) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Validation (unchanged logic) ────────────────────────────────────────

  void validateStep1(SignUpController signUpController) async {
    signUpController.checkOthersFieldValidity(step1: true);
    if (step1FormKey.currentState!.validate() &&
        signUpController.isLogoValid &&
        signUpController.isCoverImageValidity &&
        signUpController.selectedFieldOfSport.isNotEmpty) {
      signUpController.updateRegistrationStep(SignUpPageStep.step2);
    } else {
      if (signUpController.selectedFieldOfSport.isEmpty) {
        signUpController.setFieldOfSport('');
      }
    }
  }

  void validateStep2(SignUpController signUpController) {
    signUpController.checkOthersFieldValidity(step2: true);
    if (step2FormKey.currentState!.validate() &&
        signUpController.isZoneValid &&
        signUpController.isIdentityTypeValid &&
        signUpController.isIdentityImageValid) {
      signUpController.updateRegistrationStep(SignUpPageStep.step3);
    }
  }

  void validateStep3(SignUpController signUpController) async {
    if (step3FormKey.currentState!.validate()) {
      signUpController.updateRegistrationStep(SignUpPageStep.step4);
    }
  }

  void validateStep4(SignUpController signUpController) async {
    if (signUpController.selectedBusinessPlan == null) {
      showCustomSnackBar(
        "choose_business_plan".tr,
        type: ToasterMessageType.info,
      );
    } else if (signUpController.selectedBusinessPlan ==
        BusinessPlanType.commissionBase) {
      signUpController.registration(_getSignUpBody(signUpController));
    } else if (signUpController.selectedBusinessPlan ==
            BusinessPlanType.subscriptionBase &&
        signUpController.selectedSubscriptionPackage == null) {
      showCustomSnackBar(
        "no_subscription_plan_available_at_this_moment".tr,
        type: ToasterMessageType.info,
      );
    } else {
      signUpController.updateRegistrationStep(SignUpPageStep.step5);
    }
  }

  void validateStep5(SignUpController signUpController) async {
    if (signUpController.selectedSubscriptionPaymentType == null) {
      showCustomSnackBar(
        "free_trail_hint_text".tr,
        type: ToasterMessageType.info,
      );
    } else if (signUpController.selectedSubscriptionPaymentType ==
            SubscriptionPaymentType.digital &&
        signUpController.selectedDigitalPaymentMethodIndex == -1) {
      showCustomSnackBar(
        "select_payment_method".tr,
        type: ToasterMessageType.info,
      );
    } else {
      signUpController.registration(_getSignUpBody(signUpController));
    }
  }

  SignUpBody _getSignUpBody(SignUpController signUpController) {
    String companyNumberWithCountryCode =
        signUpController.countryDialCode +
        ValidationHelper.getValidPhone(
          "${signUpController.countryDialCode}${signUpController.companyPhoneController.value.text}",
        );
    String contactNumberWithCountryCode =
        signUpController.countryDialCode +
        ValidationHelper.getValidPhone(
          "${signUpController.countryDialCode}${signUpController.contactPersonPhoneController.value.text}",
        );
    DigitalPaymentMethod? paymentMethod;
    if (signUpController.selectedDigitalPaymentMethodIndex != -1 &&
        signUpController.selectedBusinessPlan ==
            BusinessPlanType.subscriptionBase) {
      List<DigitalPaymentMethod> paymentMethodList =
          Get.find<SplashController>().configModel.content?.paymentMethodList ??
          [];
      paymentMethod =
          paymentMethodList[signUpController.selectedDigitalPaymentMethodIndex];
    }
    if (kDebugMode) {
      print('Field of Sport: ${signUpController.selectedFieldOfSport}');
    }
    return SignUpBody(
      contactPersonEmail: signUpController.contactPersonEmailController.text,
      contactPersonName: signUpController.contactPersonNameController.text,
      contactPersonPhone: contactNumberWithCountryCode,
      password: signUpController.accountPasswordController.text,
      confirmedPassword: signUpController.accountConfirmPasswordController.text,
      companyName: signUpController.companyNameController.text,
      companyAddress: signUpController.companyAddressController.text,
      companyEmail: signUpController.companyEmailController.text,
      companyPhone: companyNumberWithCountryCode,
      accountEmail: signUpController.companyEmailController.text,
      accountPhone: companyNumberWithCountryCode,
      identityType: signUpController.selectedIdentityType,
      identityNumber: signUpController.identityNumberController.text,
      zoneId: signUpController.selectedZoneId,
      lat: "${Get.find<LocationController>().pickPosition.latitude}",
      lon: "${Get.find<LocationController>().pickPosition.longitude}",
      chooseBusinessPlan:
          signUpController.selectedBusinessPlan ==
              BusinessPlanType.commissionBase
          ? "commission_base"
          : "subscription_base",
      subscriptionPackageId: signUpController.selectedSubscriptionPackage?.id,
      paymentMethod: paymentMethod?.gateway,
      freeTrialOrPayment:
          signUpController.selectedSubscriptionPaymentType ==
              SubscriptionPaymentType.freeTrail
          ? "free_trial"
          : "payment",
      paymentPlatform: "app",
      fieldOfSport: signUpController.selectedFieldOfSport.isNotEmpty
          ? signUpController.selectedFieldOfSport
          : '',
    );
  }
}
