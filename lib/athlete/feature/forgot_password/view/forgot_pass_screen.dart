/*import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _identityController = TextEditingController();

  String countryDialCode = "";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode _identityFocus = FocusNode();

  bool _isNumberLogin = false;

  String _forgetPasswordMethod = "email";

  @override
  void initState() {
    super.initState();
    countryDialCode =
        CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel.content!.countryCode!,
        ).dialCode ??
        "+880";

    var config = Get.find<SplashController>().configModel.content;
    if (config?.forgetPasswordVerificationMethod?.phone == 1 &&
        config?.forgetPasswordVerificationMethod?.email == 1) {
      _forgetPasswordMethod = "both";
    } else if (config?.forgetPasswordVerificationMethod?.phone == 1) {
      _forgetPasswordMethod = "phone";
    } else {
      _forgetPasswordMethod = "email";
    }
    toggleIsNumberLogin(value: false, isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'forgot_password'.tr.replaceAll("?", " ")),

      body: SafeArea(
        child: Center(
          child: Scrollbar(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Image.asset(
                          Images.forgetPassword,
                          height: 100,
                          width: 100,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: Dimensions.paddingSizeLarge,
                          ),
                          child: Center(
                            child: Text(
                              '${"verify_your".tr} ${_forgetPasswordMethod == "email"
                                  ? "email_address".tr.toLowerCase()
                                  : _forgetPasswordMethod == "phone"
                                  ? "phone_number".tr.toLowerCase()
                                  : "email_or_phone".tr}',
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!
                                    .withValues(alpha: 0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeLarge * 1.5,
                          ),
                          child: Center(
                            child: Text(
                              '${"please_enter_your".tr} ${_forgetPasswordMethod == "email"
                                  ? "email_address".tr.toLowerCase()
                                  : _forgetPasswordMethod == "phone"
                                  ? "phone_number".tr.toLowerCase()
                                  : "email_or_phone".tr} ${"to_receive_a_verification_code".tr}',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!
                                    .withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        CustomTextField(
                          onCountryChanged: (countryCode) =>
                              countryDialCode = countryCode.dialCode!,
                          countryDialCode:
                              (_forgetPasswordMethod != "email" &&
                                  _isNumberLogin)
                              ? countryDialCode
                              : null,
                          title: _forgetPasswordMethod == "email"
                              ? "email".tr
                              : _forgetPasswordMethod == "phone"
                              ? "phone".tr
                              : 'email_or_phone'.tr,
                          hintText: _forgetPasswordMethod == "email"
                              ? "enter_email_address".tr
                              : _forgetPasswordMethod == "phone"
                              ? 'ex : 1234567890'.tr
                              : 'enter_email_or_password'.tr,
                          controller: _identityController,
                          focusNode: _identityFocus,
                          inputType: TextInputType.emailAddress,
                          onChanged: (String text) {
                            final numberRegExp = RegExp(r'^[+]?[0-9]+$');
                            if (text.isEmpty && _isNumberLogin) {
                              toggleIsNumberLogin();
                            }
                            if (text.startsWith(numberRegExp) &&
                                !_isNumberLogin) {
                              toggleIsNumberLogin();
                              _identityController.text = text.replaceAll(
                                "+",
                                "",
                              );
                            }
                            final emailRegExp = RegExp(r'@');
                            if (text.contains(emailRegExp) && _isNumberLogin) {
                              toggleIsNumberLogin();
                            }
                          },
                          onValidate: (String? value) {
                            if (_isNumberLogin &&
                                (_forgetPasswordMethod == "phone" ||
                                    _forgetPasswordMethod == "both") &&
                                ValidationHelper.getValidPhone(
                                      countryDialCode + value!,
                                    ) ==
                                    "") {
                              return "enter_valid_phone_number".tr;
                            }
                            if (_forgetPasswordMethod == "email" &&
                                !GetUtils.isEmail(value!)) {
                              return "enter_valid_email_address".tr;
                            }
                            return (GetUtils.isPhoneNumber(value!.tr) ||
                                    GetUtils.isEmail(value.tr))
                                ? null
                                : 'enter_email_address_or_phone_number'.tr;
                          },
                        ),

                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        GetBuilder<AuthController>(
                          builder: (authController) {
                            return CustomButton(
                              btnTxt: "send_verification_code".tr,
                              isLoading: authController.isLoading!,
                              onPressed: () => formKey.currentState!.validate()
                                  ? _forgetPass(countryDialCode, authController)
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _forgetPass(
    String countryDialCode,
    AuthController authController,
  ) async {
    String phone = ValidationHelper.getValidPhone(
      countryDialCode + _identityController.text.trim(),
      withCountryCode: true,
    );
    String identity = phone != "" ? phone : _identityController.text.trim();

    var config = Get.find<SplashController>().configModel.content;
    SendOtpType type = config?.firebaseOtpVerification == 1 && phone != ""
        ? SendOtpType.firebase
        : SendOtpType.forgetPassword;

    authController
        .sendVerificationCode(
          identity: identity,
          identityType: phone != "" ? "phone" : "email",
          type: type,
          fromPage: "forget-password",
        )
        .then((status) {
          if (status != null) {
            if (status.isSuccess!) {
              Get.toNamed(
                RouteHelper.getVerificationRoute(
                  identity: identity,
                  identityType: phone != "" ? "phone" : "email",
                  fromPage: "forget-password",
                  firebaseSession: type == SendOtpType.firebase
                      ? status.message
                      : null,
                  showSignUpDialog: false,
                ),
              );
            } else {
              showCustomSnackBar(
                status.message.toString().capitalizeFirst ?? "",
              );
            }
          }
        });
  }

  toggleIsNumberLogin({bool? value, bool isUpdate = true}) {
    if (_forgetPasswordMethod == "both") {
      if (isUpdate) {
        setState(() {
          if (value == null) {
            _isNumberLogin = !_isNumberLogin;
          } else {
            _isNumberLogin = value;
          }
        });
      } else {
        if (value == null) {
          _isNumberLogin = !_isNumberLogin;
        } else {
          _isNumberLogin = value;
        }
      }
    } else if (_forgetPasswordMethod == "phone") {
      _isNumberLogin = true;
    }
  }
}

*/

import 'package:afriendorse/athlete/feature/auth/widgets/auth_pattern_background.dart';
import 'package:afriendorse/athlete/feature/captcha/app_captcha_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _identityController = TextEditingController();

  String countryDialCode = "";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode _identityFocus = FocusNode();

  final AppCaptchaController _captchaController = AppCaptchaController();
  bool _captchaVerified = false;

  bool _isNumberLogin = false;
  String _forgetPasswordMethod = "email";

  static const Color primaryGreen = Color(0xFF045F25);
  static const Color darkGreen = Color(0xFF033D18);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);

  @override
  void initState() {
    super.initState();
    countryDialCode =
        CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel.content!.countryCode!,
        ).dialCode ??
        "+880";

    var config = Get.find<SplashController>().configModel.content;
    if (config?.forgetPasswordVerificationMethod?.phone == 1 &&
        config?.forgetPasswordVerificationMethod?.email == 1) {
      _forgetPasswordMethod = "both";
    } else if (config?.forgetPasswordVerificationMethod?.phone == 1) {
      _forgetPasswordMethod = "phone";
    } else {
      _forgetPasswordMethod = "email";
    }
    toggleIsNumberLogin(value: false, isUpdate: false);
  }

  @override
  void dispose() {
    _identityController.dispose();
    _identityFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String verifyTitle = _forgetPasswordMethod == "email"
        ? "email_address".tr.toLowerCase()
        : _forgetPasswordMethod == "phone"
        ? "phone_number".tr.toLowerCase()
        : "email_or_phone".tr;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(title: 'forgot_password'.tr.replaceAll("?", " ")),
      body: Stack(
        children: [
          const Positioned.fill(child: AuthFaPatternBackground()),

          SafeArea(
            child: Center(
              child: Scrollbar(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: pureWhite.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: primaryGreen.withOpacity(0.10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryGreen.withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: primaryGreen.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Image.asset(
                                  Images.forgetPassword,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              const SizedBox(height: 20),

                              Text(
                                'Verify Your $verifyTitle',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: pureBlack,
                                  letterSpacing: -0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 10),

                              Text(
                                '${"please_enter_your".tr} $verifyTitle ${"to_receive_a_verification_code".tr}',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.55,
                                  color: pureBlack.withOpacity(0.65),
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 24),

                              _fieldWrap(
                                child: CustomTextField(
                                  onCountryChanged: (countryCode) =>
                                      this.countryDialCode =
                                          countryCode.dialCode!,
                                  countryDialCode:
                                      (_forgetPasswordMethod != "email" &&
                                          _isNumberLogin)
                                      ? countryDialCode
                                      : null,
                                  title: _forgetPasswordMethod == "email"
                                      ? "email".tr
                                      : _forgetPasswordMethod == "phone"
                                      ? "phone".tr
                                      : 'email_or_phone'.tr,
                                  hintText: _forgetPasswordMethod == "email"
                                      ? "enter_email_address".tr
                                      : _forgetPasswordMethod == "phone"
                                      ? 'ex : 1234567890'.tr
                                      : 'enter_email_or_password'.tr,
                                  controller: _identityController,
                                  focusNode: _identityFocus,
                                  inputType: TextInputType.emailAddress,
                                  fillColor: Colors.white,
                                  isShowBorder: true,
                                  borderRadius: 14,
                                  onChanged: (String text) {
                                    final numberRegExp = RegExp(
                                      r'^[+]?[0-9]+$',
                                    );

                                    if (text.isEmpty && _isNumberLogin) {
                                      toggleIsNumberLogin();
                                    }

                                    if (text.startsWith(numberRegExp) &&
                                        !_isNumberLogin) {
                                      toggleIsNumberLogin();
                                      _identityController.text = text
                                          .replaceAll("+", "");
                                      _identityController.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                              offset: _identityController
                                                  .text
                                                  .length,
                                            ),
                                          );
                                    }

                                    final emailRegExp = RegExp(r'@');
                                    if (text.contains(emailRegExp) &&
                                        _isNumberLogin) {
                                      toggleIsNumberLogin();
                                    }
                                  },
                                  onValidate: (String? value) {
                                    if (_isNumberLogin &&
                                        (_forgetPasswordMethod == "phone" ||
                                            _forgetPasswordMethod == "both") &&
                                        ValidationHelper.getValidPhone(
                                              countryDialCode + (value ?? ""),
                                            ) ==
                                            "") {
                                      return "enter_valid_phone_number".tr;
                                    }

                                    if (_forgetPasswordMethod == "email" &&
                                        !GetUtils.isEmail(value ?? "")) {
                                      return "enter_valid_email_address".tr;
                                    }

                                    return (GetUtils.isPhoneNumber(
                                              (value ?? "").tr,
                                            ) ||
                                            GetUtils.isEmail((value ?? "").tr))
                                        ? null
                                        : 'enter_email_address_or_phone_number'
                                              .tr;
                                  },
                                ),
                              ),

                              const SizedBox(height: 18),

                              AppCaptchaWidget(
                                controller: _captchaController,
                                title: 'Verify you are a human',
                                hintText: 'Answer',
                                onVerifiedChanged: (verified) {
                                  setState(() {
                                    _captchaVerified = verified;
                                  });
                                },
                              ),

                              const SizedBox(height: 22),

                              GetBuilder<AuthController>(
                                builder: (authController) {
                                  final bool canSubmit =
                                      _captchaVerified &&
                                      !(authController.isLoading ?? false);

                                  return _primaryButton(
                                    text: "send_verification_code".tr,
                                    isLoading:
                                        authController.isLoading ?? false,
                                    isEnabled: _captchaVerified,
                                    onPressed: () {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      if (!_captchaController.isVerified ||
                                          !_captchaVerified) {
                                        showCustomSnackBar(
                                          'Please complete the security verification',
                                          type: ToasterMessageType.info,
                                        );
                                        return;
                                      }

                                      _forgetPass(
                                        countryDialCode,
                                        authController,
                                      );
                                    },
                                  );
                                },
                              ),

                              if (!_captchaVerified) ...[
                                const SizedBox(height: 10),
                                Text(
                                  'Complete the security check to continue.',
                                  style: TextStyle(
                                    color: pureBlack.withOpacity(0.55),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],

                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldWrap({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: pureWhite.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _primaryButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
    required bool isEnabled,
  }) {
    final bool canTap = isEnabled && !isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: canTap
            ? const LinearGradient(
                colors: [primaryGreen, darkGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: canTap
                ? primaryGreen.withOpacity(0.28)
                : Colors.grey.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canTap ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: pureWhite,
                      strokeWidth: 2.4,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: pureWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _forgetPass(
    String countryDialCode,
    AuthController authController,
  ) async {
    String phone = ValidationHelper.getValidPhone(
      countryDialCode + _identityController.text.trim(),
      withCountryCode: true,
    );
    String identity = phone != "" ? phone : _identityController.text.trim();

    var config = Get.find<SplashController>().configModel.content;
    SendOtpType type = config?.firebaseOtpVerification == 1 && phone != ""
        ? SendOtpType.firebase
        : SendOtpType.forgetPassword;

    authController
        .sendVerificationCode(
          identity: identity,
          identityType: phone != "" ? "phone" : "email",
          type: type,
          fromPage: "forget-password",
        )
        .then((status) {
          if (status != null) {
            if (status.isSuccess!) {
              Get.toNamed(
                RouteHelper.getVerificationRoute(
                  identity: identity,
                  identityType: phone != "" ? "phone" : "email",
                  fromPage: "forget-password",
                  firebaseSession: type == SendOtpType.firebase
                      ? status.message
                      : null,
                  showSignUpDialog: false,
                ),
              );
            } else {
              showCustomSnackBar(
                status.message.toString().capitalizeFirst ?? "",
              );
            }
          }
        });
  }

  toggleIsNumberLogin({bool? value, bool isUpdate = true}) {
    if (_forgetPasswordMethod == "both") {
      if (isUpdate) {
        setState(() {
          if (value == null) {
            _isNumberLogin = !_isNumberLogin;
          } else {
            _isNumberLogin = value;
          }
        });
      } else {
        if (value == null) {
          _isNumberLogin = !_isNumberLogin;
        } else {
          _isNumberLogin = value;
        }
      }
    } else if (_forgetPasswordMethod == "phone") {
      _isNumberLogin = true;
    }
  }
}
