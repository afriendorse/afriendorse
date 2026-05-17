/*
import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class ForgetPassScreen extends StatefulWidget {
  final String? redirectUrl;
  const ForgetPassScreen({super.key, this.redirectUrl});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _identityController = TextEditingController();

  String countryDialCode = "";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode _identityFocus = FocusNode();

  bool _isNumberLogin = false;

  String _forgetPasswordMethod = "phone";

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
    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(
          title: 'forgot_password'.tr.replaceAll("?", " "),
          onBackPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.toNamed(RouteHelper.getSignInRoute());
            }
          },
        ),

        body: SafeArea(
          child: GetBuilder<SplashController>(
            builder: (splashController) {
              return GetBuilder<AuthController>(
                builder: (authController) {
                  return FooterBaseView(
                    isCenter: true,
                    child: WebShadowWrap(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.isDesktop(context)
                              ? Dimensions.webMaxWidth / 3.5
                              : ResponsiveHelper.isTab(context)
                              ? Dimensions.webMaxWidth / 5.5
                              : 0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeLarge,
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  Images.forgotPass,
                                  width: 100,
                                  height: 100,
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
                                          : "email_phone".tr}',
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
                                          : "email_phone".tr} ${"to_receive_a_verification_code".tr}',
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
                                      ? "email_address".tr
                                      : _forgetPasswordMethod == "phone_number"
                                      ? "phone".tr
                                      : 'email_phone'.tr,
                                  hintText: _forgetPasswordMethod == "email"
                                      ? "enter_email_address".tr
                                      : _forgetPasswordMethod == "phone"
                                      ? 'ex : 1234567890'.tr
                                      : 'enter_email_or_phone'.tr,
                                  controller: _identityController,
                                  focusNode: _identityFocus,
                                  inputType: TextInputType.emailAddress,
                                  onChanged: (String text) {
                                    final numberRegExp = RegExp(r'^-?[0-9]+$');

                                    if (text.isEmpty && _isNumberLogin) {
                                      toggleIsNumberLogin();
                                    }
                                    if (text.startsWith(numberRegExp) &&
                                        !_isNumberLogin) {
                                      toggleIsNumberLogin();
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
                                        PhoneVerificationHelper.getValidPhoneNumber(
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
                                        : 'enter_email_or_phone'.tr;
                                  },
                                ),

                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge * 1.5,
                                ),
                                GetBuilder<AuthController>(
                                  builder: (authController) {
                                    return CustomButton(
                                      buttonText: 'send_verification_code'.tr,
                                      isLoading: authController.isLoading,
                                      fontSize: Dimensions.fontSizeDefault,
                                      onPressed: () =>
                                          formKey.currentState!.validate()
                                          ? _forgetPass(
                                              countryDialCode,
                                              authController,
                                            )
                                          : null,
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge * 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  void _forgetPass(
    String countryDialCode,
    AuthController authController,
  ) async {
    String phone = PhoneVerificationHelper.getValidPhoneNumber(
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
          redirectUrl: widget.redirectUrl,
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
                  redirectUrl: widget.redirectUrl,
                ),
              );
            } else {
              customSnackBar(status.message.toString().capitalizeFirst ?? "");
            }
          }
        });
  }

  void toggleIsNumberLogin({bool? value, bool isUpdate = true}) {
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

import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class ForgetPassScreen extends StatefulWidget {
  final String? redirectUrl;
  const ForgetPassScreen({super.key, this.redirectUrl});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _identityController = TextEditingController();
  String countryDialCode = "";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode _identityFocus = FocusNode();

  bool _isNumberLogin = false;
  String _forgetPasswordMethod = "phone";

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Brand colors
  static const Color primaryGreen = Color(0xFF045F25);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color darkGreen = Color(0xFF033D18);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeMethod();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  void _initializeMethod() {
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
    _animationController.dispose();
    _identityController.dispose();
    _identityFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        backgroundColor: pureWhite,
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: AppBar(
          backgroundColor: pureWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: primaryGreen),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Get.back();
              } else {
                Get.toNamed(RouteHelper.getSignInRoute());
              }
            },
          ),
          title: Text(
            'forgot_password'.tr,
            style: const TextStyle(
              color: pureBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        body: SafeArea(
          child: GetBuilder<SplashController>(
            builder: (splashController) {
              return GetBuilder<AuthController>(
                builder: (authController) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FooterBaseView(
                        isCenter: true,
                        child: WebShadowWrap(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.webMaxWidth / 3.5
                                  : ResponsiveHelper.isTab(context)
                                  ? Dimensions.webMaxWidth / 5.5
                                  : 0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge,
                              ),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 20),

                                    // Icon with background
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: lightGreen,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryGreen.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.lock_reset_rounded,
                                        size: 48,
                                        color: primaryGreen,
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Header
                                    Text(
                                      'recover_account'.tr,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: pureBlack,
                                        letterSpacing: -0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 12),

                                    // Subtitle
                                    Text(
                                      'verify_your'.tr + ' ' + _getMethodText(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: pureBlack.withOpacity(0.6),
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      'to_receive_verification_code'.tr,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: pureBlack.withOpacity(0.5),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 40),

                                    // Input Field
                                    _buildInputField(
                                      child: CustomTextField(
                                        onCountryChanged: (countryCode) =>
                                            countryDialCode =
                                                countryCode.dialCode!,
                                        countryDialCode:
                                            (_forgetPasswordMethod != "email" &&
                                                _isNumberLogin)
                                            ? countryDialCode
                                            : null,
                                        title: _getInputTitle(),
                                        hintText: _getHintText(),
                                        controller: _identityController,
                                        focusNode: _identityFocus,
                                        inputType: TextInputType.emailAddress,
                                        onChanged: (String text) {
                                          final numberRegExp = RegExp(
                                            r'^-?[0-9]+$',
                                          );
                                          if (text.isEmpty && _isNumberLogin) {
                                            toggleIsNumberLogin();
                                          }
                                          if (text.startsWith(numberRegExp) &&
                                              !_isNumberLogin) {
                                            toggleIsNumberLogin();
                                          }
                                          final emailRegExp = RegExp(r'@');
                                          if (text.contains(emailRegExp) &&
                                              _isNumberLogin) {
                                            toggleIsNumberLogin();
                                          }
                                        },
                                        onValidate: (String? value) {
                                          if (_isNumberLogin &&
                                              (_forgetPasswordMethod ==
                                                      "phone" ||
                                                  _forgetPasswordMethod ==
                                                      "both") &&
                                              PhoneVerificationHelper.getValidPhoneNumber(
                                                    countryDialCode + value!,
                                                  ) ==
                                                  "") {
                                            return "enter_valid_phone_number"
                                                .tr;
                                          }
                                          if (_forgetPasswordMethod ==
                                                  "email" &&
                                              !GetUtils.isEmail(value!)) {
                                            return "enter_valid_email_address"
                                                .tr;
                                          }
                                          return (GetUtils.isPhoneNumber(
                                                    value!.tr,
                                                  ) ||
                                                  GetUtils.isEmail(value.tr))
                                              ? null
                                              : 'enter_email_or_phone'.tr;
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Send Button
                                    _buildPrimaryButton(
                                      text: 'send_code'.tr,
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                          _forgetPass(
                                            countryDialCode,
                                            authController,
                                          );
                                        }
                                      },
                                      isLoading: authController.isLoading,
                                    ),

                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

  String _getMethodText() {
    if (_forgetPasswordMethod == "email")
      return 'email_address'.tr.toLowerCase();
    if (_forgetPasswordMethod == "phone")
      return 'phone_number'.tr.toLowerCase();
    return 'email_or_phone'.tr;
  }

  String _getInputTitle() {
    if (_forgetPasswordMethod == "email") return "email_address".tr;
    if (_forgetPasswordMethod == "phone") return "phone".tr;
    return 'email_phone'.tr;
  }

  String _getHintText() {
    if (_forgetPasswordMethod == "email") return "enter_email_address".tr;
    if (_forgetPasswordMethod == "phone") return 'ex : 1234567890'.tr;
    return 'enter_email_or_phone'.tr;
  }

  Widget _buildInputField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [primaryGreen, darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: pureWhite,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: pureWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
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
    String phone = PhoneVerificationHelper.getValidPhoneNumber(
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
          redirectUrl: widget.redirectUrl,
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
                  redirectUrl: widget.redirectUrl,
                ),
              );
            } else {
              customSnackBar(status.message.toString().capitalizeFirst ?? "");
            }
          }
        });
  }

  void toggleIsNumberLogin({bool? value, bool isUpdate = true}) {
    if (_forgetPasswordMethod == "both") {
      if (isUpdate) {
        setState(() {
          _isNumberLogin = value ?? !_isNumberLogin;
        });
      } else {
        _isNumberLogin = value ?? !_isNumberLogin;
      }
    } else if (_forgetPasswordMethod == "phone") {
      _isNumberLogin = true;
    }
  }
}
