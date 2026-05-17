/*
import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:afriendorse/feature/athlete_module.dart';
import 'package:afriendorse/main.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final String? redirectRoute;
  const SignInScreen({
    super.key,
    required this.exitFromApp,
    this.redirectRoute,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var signInPhoneController = TextEditingController();
  var signInPasswordController = TextEditingController();

  final _passwordFocus = FocusNode();
  final _phoneFocus = FocusNode();

  final GlobalKey<FormState> customerSignInKey = GlobalKey<FormState>();

  @override
  void initState() {
    _initializeController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const WebMenuBar()
            : !widget.exitFromApp
            ? AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  hoverColor: Colors.transparent,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : null,

        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,

        body: SafeArea(
          child: FooterBaseView(
            isCenter: true,
            child: WebShadowWrap(
              child: Center(
                child: GetBuilder<SplashController>(
                  builder: (splashController) {
                    return GetBuilder<AuthController>(
                      builder: (authController) {
                        var config = splashController.configModel.content;
                        var otpLogin =
                            config?.customerLogin?.loginOption?.otpLogin;
                        var manualLogin =
                            config?.customerLogin?.loginOption?.manualLogin ??
                            1;
                        var socialLogin = config
                            ?.customerLogin
                            ?.loginOption
                            ?.socialMediaLogin;

                        return Form(
                          autovalidateMode: ResponsiveHelper.isDesktop(context)
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          key: customerSignInKey,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.webMaxWidth / 3.5
                                  : ResponsiveHelper.isTab(context)
                                  ? Dimensions.webMaxWidth / 5.5
                                  : Dimensions.paddingSizeLarge,
                            ),
                            child: Column(
                              children: [
                                Hero(
                                  tag: Images.logo,
                                  child: Image.asset(
                                    Images.logo,
                                    width: Dimensions.logoSize,
                                  ),
                                ),
                                SizedBox(
                                  height: manualLogin == 1 || otpLogin == 1
                                      ? Dimensions.paddingSizeExtraMoreLarge
                                      : Dimensions.paddingSizeDefault,
                                ),

                                manualLogin == 1 || otpLogin == 1
                                    ? CustomTextField(
                                        onCountryChanged: (countryCode) =>
                                            authController.countryDialCode =
                                                countryCode.dialCode!,
                                        countryDialCode:
                                            authController.isNumberLogin ||
                                                (manualLogin == 0 &&
                                                    otpLogin == 1)
                                            ? authController.countryDialCode
                                            : null,
                                        title: 'email_phone'.tr,
                                        hintText:
                                            authController
                                                        .selectedLoginMedium ==
                                                    LoginMedium.otp ||
                                                (manualLogin == 0 &&
                                                    otpLogin == 1)
                                            ? "please_enter_phone_number".tr
                                            : 'enter_email_or_phone'.tr,
                                        controller: signInPhoneController,
                                        focusNode: _phoneFocus,
                                        nextFocus: _passwordFocus,
                                        capitalization:
                                            TextCapitalization.words,
                                        onChanged: (String text) {
                                          if (authController
                                                  .selectedLoginMedium !=
                                              LoginMedium.otp) {
                                            final numberRegExp = RegExp(
                                              r'^[+]?[0-9]+$',
                                            );

                                            if (text.isEmpty &&
                                                authController.isNumberLogin) {
                                              authController
                                                  .toggleIsNumberLogin();
                                            }
                                            if (text.startsWith(numberRegExp) &&
                                                !authController.isNumberLogin &&
                                                manualLogin == 1) {
                                              authController
                                                  .toggleIsNumberLogin();
                                              final cursorPosition =
                                                  signInPhoneController
                                                      .selection
                                                      .baseOffset;
                                              signInPhoneController.text = text
                                                  .replaceAll("+", "");
                                              signInPhoneController.selection =
                                                  TextSelection.fromPosition(
                                                    TextPosition(
                                                      offset: cursorPosition,
                                                    ),
                                                  );
                                            }
                                            final emailRegExp = RegExp(r'@');
                                            if (text.contains(emailRegExp) &&
                                                authController.isNumberLogin &&
                                                manualLogin == 1) {
                                              authController
                                                  .toggleIsNumberLogin();
                                            }

                                            _phoneFocus.requestFocus();
                                          }
                                        },
                                        onValidate: (String? value) {
                                          if (otpLogin == 1 &&
                                              manualLogin == 0 &&
                                              PhoneVerificationHelper.getValidPhoneNumber(
                                                    authController
                                                            .countryDialCode +
                                                        signInPhoneController
                                                            .text
                                                            .trim(),
                                                    withCountryCode: true,
                                                  ) ==
                                                  "") {
                                            return "enter_valid_phone_number"
                                                .tr;
                                          }
                                          if (authController.isNumberLogin &&
                                              PhoneVerificationHelper.getValidPhoneNumber(
                                                    authController
                                                            .countryDialCode +
                                                        signInPhoneController
                                                            .text
                                                            .trim(),
                                                    withCountryCode: true,
                                                  ) ==
                                                  "") {
                                            return "enter_valid_phone_number"
                                                .tr;
                                          }
                                          return (PhoneVerificationHelper.getValidPhoneNumber(
                                                        authController
                                                                .countryDialCode +
                                                            signInPhoneController
                                                                .text
                                                                .trim(),
                                                        withCountryCode: true,
                                                      ) !=
                                                      "" ||
                                                  GetUtils.isEmail(value ?? ""))
                                              ? null
                                              : 'enter_email_or_phone'.tr;
                                        },
                                      )
                                    : const SizedBox.shrink(),

                                SizedBox(
                                  height:
                                      manualLogin == 1 &&
                                          authController.selectedLoginMedium ==
                                              LoginMedium.manual
                                      ? Dimensions.paddingSizeTextFieldGap
                                      : 0,
                                ),

                                manualLogin == 1 &&
                                        authController.selectedLoginMedium ==
                                            LoginMedium.manual
                                    ? CustomTextField(
                                        title: 'password'.tr,
                                        hintText: '************'.tr,
                                        controller: signInPasswordController,
                                        focusNode: _passwordFocus,
                                        inputType:
                                            TextInputType.visiblePassword,
                                        isPassword: true,
                                        inputAction: TextInputAction.done,
                                        onValidate: (String? value) {
                                          return FormValidation()
                                              .isValidPassword(value!.tr);
                                        },
                                      )
                                    : const SizedBox.shrink(),
                                SizedBox(
                                  height:
                                      authController.selectedLoginMedium ==
                                          LoginMedium.manual
                                      ? Dimensions.paddingSizeDefault
                                      : 0,
                                ),

                                manualLogin == 1 || otpLogin == 1
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () => authController
                                                .toggleRememberMe(),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.0,
                                                  child: Checkbox(
                                                    activeColor: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                    value: authController
                                                        .isActiveRememberMe,
                                                    onChanged:
                                                        (
                                                          bool? isChecked,
                                                        ) => authController
                                                            .toggleRememberMe(),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall,
                                                ),
                                                Text(
                                                  'remember_me'.tr,
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          manualLogin == 1 &&
                                                  authController
                                                          .selectedLoginMedium ==
                                                      LoginMedium.manual
                                              ? TextButton(
                                                  onPressed: () {
                                                    Get.toNamed(
                                                      RouteHelper.getSendOtpScreen(
                                                        redirectUrl: widget
                                                            .redirectRoute,
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    'forgot_password'.tr,
                                                    style: robotoRegular
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .tertiary,
                                                        ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      )
                                    : const SizedBox.shrink(),

                                SizedBox(
                                  height: manualLogin == 1 || otpLogin == 1
                                      ? Dimensions.paddingSizeLarge
                                      : 0,
                                ),

                                manualLogin == 1 || otpLogin == 1
                                    ? CustomButton(
                                        buttonText:
                                            (authController
                                                        .selectedLoginMedium ==
                                                    LoginMedium.otp) ||
                                                (manualLogin == 0 &&
                                                    otpLogin == 1)
                                            ? "get_otp".tr
                                            : 'sign_in'.tr,
                                        onPressed: () {
                                          if (customerSignInKey.currentState!
                                              .validate()) {
                                            _login(
                                              authController,
                                              manualLogin,
                                              otpLogin,
                                            );
                                          }
                                        },
                                        isLoading: authController.isLoading,
                                      )
                                    : const SizedBox.shrink(),
                                SizedBox(
                                  height: manualLogin == 1 || otpLogin == 1
                                      ? Dimensions.paddingSizeDefault
                                      : 0,
                                ),

                                (manualLogin == 1 || otpLogin == 1) &&
                                        socialLogin == 1
                                    ? Center(
                                        child: Text(
                                          'or'.tr,
                                          style: robotoRegular.copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color!
                                                .withValues(alpha: 0.6),
                                            fontSize: Dimensions.fontSizeSmall,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),

                                manualLogin == 1 &&
                                        (otpLogin == 1 || socialLogin == 1)
                                    ? Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'sign_in_with'.tr,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color!
                                                    .withValues(alpha: 0.6),
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                              ),
                                            ),
                                            otpLogin == 1 && manualLogin == 1
                                                ? TextButton(
                                                    onPressed: () {
                                                      String
                                                      phoneWithoutCountryCode =
                                                          PhoneVerificationHelper.getValidPhoneNumber(
                                                            Get.find<
                                                                  AuthController
                                                                >()
                                                                .getUserNumber(),
                                                          );
                                                      String countryCode =
                                                          PhoneVerificationHelper.getCountryCode(
                                                            Get.find<
                                                                  AuthController
                                                                >()
                                                                .getUserNumber(),
                                                          );

                                                      if (authController
                                                              .selectedLoginMedium ==
                                                          LoginMedium.otp) {
                                                        authController
                                                            .toggleSelectedLoginMedium(
                                                              loginMedium:
                                                                  LoginMedium
                                                                      .manual,
                                                            );
                                                        signInPhoneController
                                                                .text =
                                                            phoneWithoutCountryCode !=
                                                                ""
                                                            ? phoneWithoutCountryCode
                                                            : authController
                                                                  .getUserNumber();
                                                        if (countryCode != "") {
                                                          authController
                                                              .toggleIsNumberLogin(
                                                                value: true,
                                                              );
                                                        } else {
                                                          authController
                                                              .toggleIsNumberLogin(
                                                                value: false,
                                                              );
                                                        }
                                                        authController
                                                            .initCountryCode(
                                                              countryCode:
                                                                  countryCode !=
                                                                      ""
                                                                  ? countryCode
                                                                  : null,
                                                            );
                                                        signInPasswordController
                                                            .text = authController
                                                            .getUserPassword();

                                                        if (signInPasswordController
                                                            .text
                                                            .isEmpty) {
                                                          signInPhoneController
                                                                  .text =
                                                              "";
                                                          authController
                                                              .toggleIsNumberLogin(
                                                                value: false,
                                                              );
                                                        }
                                                      } else {
                                                        authController
                                                            .toggleSelectedLoginMedium(
                                                              loginMedium:
                                                                  LoginMedium
                                                                      .otp,
                                                            );
                                                        authController
                                                            .toggleIsNumberLogin(
                                                              value: true,
                                                            );
                                                        signInPasswordController
                                                            .clear();

                                                        signInPhoneController
                                                                .text =
                                                            phoneWithoutCountryCode;
                                                        authController
                                                            .initCountryCode(
                                                              countryCode:
                                                                  countryCode !=
                                                                      ""
                                                                  ? countryCode
                                                                  : null,
                                                            );
                                                      }
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: const Size(
                                                        30,
                                                        30,
                                                      ),
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 5,
                                                          ),
                                                      child: Text(
                                                        authController
                                                                    .selectedLoginMedium ==
                                                                LoginMedium
                                                                    .manual
                                                            ? 'OTP'.tr
                                                            : "email_phone".tr,
                                                        style: robotoRegular.copyWith(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          color: Theme.of(
                                                            context,
                                                          ).colorScheme.primary,
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),

                                socialLogin == 1
                                    ? SocialLoginWidget(
                                        redirectUrl: widget.redirectRoute,
                                      )
                                    : const SizedBox(),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),

                                manualLogin == 1
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${'do_not_have_an_account'.tr} ',
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge!.color,
                                            ),
                                          ),

                                          TextButton(
                                            onPressed: () {
                                              signInPhoneController.clear();
                                              signInPasswordController.clear();

                                              Get.toNamed(
                                                RouteHelper.getSignUpRoute(
                                                  redirectUrl:
                                                      widget.redirectRoute,
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(50, 30),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              'sign_up_here'.tr,
                                              style: robotoRegular.copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),

                                // ADD EVERYTHING BELOW THIS LINE
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge,
                                ),

                                // Divider with "or switch to" text
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(color: Colors.grey[300]),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Text(
                                        'or switch to',
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(color: Colors.grey[300]),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                // Switch button
                                OutlinedButton.icon(
                                  onPressed: () => _switchToAthlete(),
                                  icon: const Icon(
                                    Icons.sports_handball,
                                    size: 20,
                                  ),
                                  label: Text(
                                    'Athlete App',
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    side: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault,
                                      ),
                                    ),
                                  ),
                                ),

                                // END OF ADDED CODE
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _initializeController() {
    var authController = Get.find<AuthController>();
    String phoneWithoutCountryCode =
        PhoneVerificationHelper.getValidPhoneNumber(
          Get.find<AuthController>().getUserNumber(),
        );
    String countryCode = PhoneVerificationHelper.getCountryCode(
      Get.find<AuthController>().getUserNumber(),
    );

    var config = Get.find<SplashController>().configModel.content;
    var manualLogin = config?.customerLogin?.loginOption?.manualLogin ?? 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (countryCode != "" && phoneWithoutCountryCode != "") {
        authController.toggleIsNumberLogin(value: true);
      } else {
        authController.toggleIsNumberLogin(value: false);
      }
      authController.toggleSelectedLoginMedium(loginMedium: LoginMedium.manual);
      authController.initCountryCode(
        countryCode: countryCode != "" ? countryCode : null,
      );

      signInPhoneController.text = phoneWithoutCountryCode != ""
          ? phoneWithoutCountryCode
          : authController.isNumberLogin
          ? ""
          : Get.find<AuthController>().getUserNumber();
      signInPasswordController.text = Get.find<AuthController>()
          .getUserPassword();

      if (manualLogin == 1 && signInPasswordController.text.isEmpty) {
        signInPhoneController.text = "";
        authController.initCountryCode();
        authController.toggleIsNumberLogin(value: false);
      }
    });
    authController.toggleRememberMe(value: false, shouldUpdate: false);
  }

  void _login(
    AuthController authController,
    var manualLogin,
    var otpLogin,
  ) async {
    if (customerSignInKey.currentState!.validate()) {
      var config = Get.find<SplashController>().configModel.content;

      SendOtpType type = config?.firebaseOtpVerification == 1
          ? SendOtpType.firebase
          : SendOtpType.verification;

      String phone = PhoneVerificationHelper.getValidPhoneNumber(
        authController.countryDialCode + signInPhoneController.text.trim(),
        withCountryCode: true,
      );

      if ((authController.selectedLoginMedium == LoginMedium.otp) ||
          (manualLogin == 0 && otpLogin == 1)) {
        authController
            .sendVerificationCode(
              identity: phone,
              identityType: "phone",
              type: type,
              checkUser: 0,
              redirectUrl: widget.redirectRoute,
            )
            .then((status) {
              if (status != null) {
                if (status.isSuccess!) {
                  Get.toNamed(
                    RouteHelper.getVerificationRoute(
                      identity: phone,
                      identityType: "phone",
                      fromPage: config?.firebaseOtpVerification == 1
                          ? "firebase-otp"
                          : "otp-login",
                      firebaseSession: type == SendOtpType.firebase
                          ? status.message
                          : null,
                      redirectUrl: widget.redirectRoute,
                    ),
                  );
                } else {
                  customSnackBar(status.message.toString().capitalizeFirst);
                }
              }
            });
      } else {
        authController.login(
          redirectRoute: widget.redirectRoute,
          emailPhone: phone != "" ? phone : signInPhoneController.text.trim(),
          password: signInPasswordController.text.trim(),
          type: phone != "" ? "phone" : "email",
        );
      }
    }
  }

  // ADD THIS NEW METHOD HERE
  Future<void> _switchToAthlete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_mode');
    Get.reset(); // Clear GetX before switching
    runApp(const PortalApp());
  }
}
*/

//
import 'package:afriendorse/athlete/feature/captcha/app_captcha_widget.dart';
import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:afriendorse/main.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final String? redirectRoute;
  const SignInScreen({
    super.key,
    required this.exitFromApp,
    this.redirectRoute,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  var signInPhoneController = TextEditingController();
  var signInPasswordController = TextEditingController();

  final _passwordFocus = FocusNode();
  final _phoneFocus = FocusNode();

  final GlobalKey<FormState> customerSignInKey = GlobalKey<FormState>();

  // ── Captcha ──────────────────────────────────────────────────────────────
  final AppCaptchaController _captchaController = AppCaptchaController();
  bool _captchaVerified = false;

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
    _initializeController();
    _setupAnimations();
    super.initState();
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

  @override
  void dispose() {
    _animationController.dispose();
    _passwordFocus.dispose();
    _phoneFocus.dispose();
    signInPhoneController.dispose();
    signInPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        backgroundColor: pureWhite,
        appBar: ResponsiveHelper.isDesktop(context)
            ? const WebMenuBar()
            : !widget.exitFromApp
            ? AppBar(
                elevation: 0,
                backgroundColor: pureWhite,
                leading: IconButton(
                  hoverColor: lightGreen,
                  highlightColor: lightGreen.withOpacity(0.3),
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: primaryGreen,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : null,

        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,

        body: SafeArea(
          child: FooterBaseView(
            isCenter: true,
            child: WebShadowWrap(
              child: Center(
                child: GetBuilder<SplashController>(
                  builder: (splashController) {
                    return GetBuilder<AuthController>(
                      builder: (authController) {
                        var config = splashController.configModel.content;
                        var otpLogin =
                            config?.customerLogin?.loginOption?.otpLogin;
                        var manualLogin =
                            config?.customerLogin?.loginOption?.manualLogin ??
                            1;
                        var socialLogin = config
                            ?.customerLogin
                            ?.loginOption
                            ?.socialMediaLogin;

                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Form(
                              autovalidateMode:
                                  ResponsiveHelper.isDesktop(context)
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              key: customerSignInKey,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.webMaxWidth / 3.5
                                      : ResponsiveHelper.isTab(context)
                                      ? Dimensions.webMaxWidth / 5.5
                                      : Dimensions.paddingSizeLarge,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 20),

                                      // Logo
                                      Center(
                                        child: Hero(
                                          tag: Images.logo,
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: primaryGreen
                                                      .withOpacity(0.1),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Image.asset(
                                              Images.appbarLogo,
                                              width: 70,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Welcome Text
                                      if (manualLogin == 1 ||
                                          otpLogin == 1) ...[
                                        Text(
                                          'welcome_back'.tr,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: pureBlack,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'sign_in_to_continue'.tr,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: pureBlack.withOpacity(0.6),
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 32),
                                      ],

                                      // Phone/Email Field
                                      if (manualLogin == 1 || otpLogin == 1)
                                        _buildInputField(
                                          child: CustomTextField(
                                            onCountryChanged: (countryCode) =>
                                                authController.countryDialCode =
                                                    countryCode.dialCode!,
                                            countryDialCode:
                                                authController.isNumberLogin ||
                                                    (manualLogin == 0 &&
                                                        otpLogin == 1)
                                                ? authController.countryDialCode
                                                : null,
                                            title: 'email_phone'.tr,
                                            hintText:
                                                authController
                                                            .selectedLoginMedium ==
                                                        LoginMedium.otp ||
                                                    (manualLogin == 0 &&
                                                        otpLogin == 1)
                                                ? "please_enter_phone_number".tr
                                                : 'enter_email_or_phone'.tr,
                                            controller: signInPhoneController,
                                            focusNode: _phoneFocus,
                                            nextFocus: _passwordFocus,
                                            capitalization:
                                                TextCapitalization.words,
                                            onChanged: (String text) {
                                              if (authController
                                                      .selectedLoginMedium !=
                                                  LoginMedium.otp) {
                                                final numberRegExp = RegExp(
                                                  r'^[+]?[0-9]+$',
                                                );

                                                if (text.isEmpty &&
                                                    authController
                                                        .isNumberLogin) {
                                                  authController
                                                      .toggleIsNumberLogin();
                                                }
                                                if (text.startsWith(
                                                      numberRegExp,
                                                    ) &&
                                                    !authController
                                                        .isNumberLogin &&
                                                    manualLogin == 1) {
                                                  authController
                                                      .toggleIsNumberLogin();
                                                  final cursorPosition =
                                                      signInPhoneController
                                                          .selection
                                                          .baseOffset;
                                                  signInPhoneController.text =
                                                      text.replaceAll("+", "");
                                                  signInPhoneController
                                                          .selection =
                                                      TextSelection.fromPosition(
                                                        TextPosition(
                                                          offset:
                                                              cursorPosition,
                                                        ),
                                                      );
                                                }
                                                final emailRegExp = RegExp(
                                                  r'@',
                                                );
                                                if (text.contains(
                                                      emailRegExp,
                                                    ) &&
                                                    authController
                                                        .isNumberLogin &&
                                                    manualLogin == 1) {
                                                  authController
                                                      .toggleIsNumberLogin();
                                                }

                                                _phoneFocus.requestFocus();
                                              }
                                            },
                                            onValidate: (String? value) {
                                              if (otpLogin == 1 &&
                                                  manualLogin == 0 &&
                                                  PhoneVerificationHelper.getValidPhoneNumber(
                                                        authController
                                                                .countryDialCode +
                                                            signInPhoneController
                                                                .text
                                                                .trim(),
                                                        withCountryCode: true,
                                                      ) ==
                                                      "") {
                                                return "enter_valid_phone_number"
                                                    .tr;
                                              }
                                              if (authController
                                                      .isNumberLogin &&
                                                  PhoneVerificationHelper.getValidPhoneNumber(
                                                        authController
                                                                .countryDialCode +
                                                            signInPhoneController
                                                                .text
                                                                .trim(),
                                                        withCountryCode: true,
                                                      ) ==
                                                      "") {
                                                return "enter_valid_phone_number"
                                                    .tr;
                                              }
                                              return (PhoneVerificationHelper.getValidPhoneNumber(
                                                            authController
                                                                    .countryDialCode +
                                                                signInPhoneController
                                                                    .text
                                                                    .trim(),
                                                            withCountryCode:
                                                                true,
                                                          ) !=
                                                          "" ||
                                                      GetUtils.isEmail(
                                                        value ?? "",
                                                      ))
                                                  ? null
                                                  : 'enter_email_or_phone'.tr;
                                            },
                                          ),
                                        ),

                                      // Password Field
                                      if (manualLogin == 1 &&
                                          authController.selectedLoginMedium ==
                                              LoginMedium.manual) ...[
                                        const SizedBox(height: 20),
                                        _buildInputField(
                                          child: CustomTextField(
                                            title: 'password'.tr,
                                            hintText: '••••••••••••',
                                            controller:
                                                signInPasswordController,
                                            focusNode: _passwordFocus,
                                            inputType:
                                                TextInputType.visiblePassword,
                                            isPassword: true,
                                            inputAction: TextInputAction.done,
                                            onValidate: (String? value) {
                                              return FormValidation()
                                                  .isValidPassword(value!.tr);
                                            },
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 20),

                                      // ── Captcha ─────────────────────────
                                      if (manualLogin == 1 || otpLogin == 1)
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

                                      const SizedBox(height: 16),

                                      // Remember Me & Forgot Password Row
                                      if (manualLogin == 1 || otpLogin == 1)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () => authController
                                                  .toggleRememberMe(),
                                              child: Row(
                                                children: [
                                                  AnimatedContainer(
                                                    duration: const Duration(
                                                      milliseconds: 200,
                                                    ),
                                                    width: 22,
                                                    height: 22,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          authController
                                                              .isActiveRememberMe
                                                          ? primaryGreen
                                                          : pureWhite,
                                                      border: Border.all(
                                                        color:
                                                            authController
                                                                .isActiveRememberMe
                                                            ? primaryGreen
                                                            : pureBlack
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child:
                                                        authController
                                                            .isActiveRememberMe
                                                        ? const Icon(
                                                            Icons.check,
                                                            size: 14,
                                                            color: pureWhite,
                                                          )
                                                        : null,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'remember_me'.tr,
                                                    style: TextStyle(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      color: pureBlack
                                                          .withOpacity(0.8),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (manualLogin == 1 &&
                                                authController
                                                        .selectedLoginMedium ==
                                                    LoginMedium.manual)
                                              TextButton(
                                                onPressed: () {
                                                  Get.toNamed(
                                                    RouteHelper.getSendOtpScreen(
                                                      redirectUrl:
                                                          widget.redirectRoute,
                                                    ),
                                                  );
                                                },
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: const Size(
                                                    50,
                                                    30,
                                                  ),
                                                ),
                                                child: Text(
                                                  'forgot_password'.tr,
                                                  style: TextStyle(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: primaryGreen,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),

                                      const SizedBox(height: 28),

                                      // Primary Action Button
                                      if (manualLogin == 1 || otpLogin == 1)
                                        _buildPrimaryButton(
                                          text:
                                              (authController
                                                          .selectedLoginMedium ==
                                                      LoginMedium.otp) ||
                                                  (manualLogin == 0 &&
                                                      otpLogin == 1)
                                              ? "get_otp".tr
                                              : 'sign_in'.tr,
                                          isLoading: authController.isLoading,
                                          // ── Captcha gate ────────────────
                                          isEnabled: _captchaVerified,
                                          onPressed: () {
                                            if (customerSignInKey.currentState!
                                                .validate()) {
                                              _login(
                                                authController,
                                                manualLogin,
                                                otpLogin,
                                              );
                                            }
                                          },
                                        ),

                                      const SizedBox(height: 24),

                                      // Divider
                                      if ((manualLogin == 1 || otpLogin == 1) &&
                                          socialLogin == 1)
                                        _buildDivider(),

                                      const SizedBox(height: 16),

                                      // Toggle Login Method
                                      if (manualLogin == 1 &&
                                          (otpLogin == 1 || socialLogin == 1))
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'sign_in_with'.tr,
                                                style: TextStyle(
                                                  color: pureBlack.withOpacity(
                                                    0.6,
                                                  ),
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                ),
                                              ),
                                              if (otpLogin == 1 &&
                                                  manualLogin == 1)
                                                TextButton(
                                                  onPressed: () {
                                                    String
                                                    phoneWithoutCountryCode =
                                                        PhoneVerificationHelper.getValidPhoneNumber(
                                                          Get.find<
                                                                AuthController
                                                              >()
                                                              .getUserNumber(),
                                                        );
                                                    String countryCode =
                                                        PhoneVerificationHelper.getCountryCode(
                                                          Get.find<
                                                                AuthController
                                                              >()
                                                              .getUserNumber(),
                                                        );

                                                    if (authController
                                                            .selectedLoginMedium ==
                                                        LoginMedium.otp) {
                                                      authController
                                                          .toggleSelectedLoginMedium(
                                                            loginMedium:
                                                                LoginMedium
                                                                    .manual,
                                                          );
                                                      signInPhoneController
                                                              .text =
                                                          phoneWithoutCountryCode !=
                                                              ""
                                                          ? phoneWithoutCountryCode
                                                          : authController
                                                                .getUserNumber();
                                                      if (countryCode != "") {
                                                        authController
                                                            .toggleIsNumberLogin(
                                                              value: true,
                                                            );
                                                      } else {
                                                        authController
                                                            .toggleIsNumberLogin(
                                                              value: false,
                                                            );
                                                      }
                                                      authController
                                                          .initCountryCode(
                                                            countryCode:
                                                                countryCode !=
                                                                    ""
                                                                ? countryCode
                                                                : null,
                                                          );
                                                      signInPasswordController
                                                          .text = authController
                                                          .getUserPassword();

                                                      if (signInPasswordController
                                                          .text
                                                          .isEmpty) {
                                                        signInPhoneController
                                                                .text =
                                                            "";
                                                        authController
                                                            .toggleIsNumberLogin(
                                                              value: false,
                                                            );
                                                      }
                                                    } else {
                                                      authController
                                                          .toggleSelectedLoginMedium(
                                                            loginMedium:
                                                                LoginMedium.otp,
                                                          );
                                                      authController
                                                          .toggleIsNumberLogin(
                                                            value: true,
                                                          );
                                                      signInPasswordController
                                                          .clear();

                                                      signInPhoneController
                                                              .text =
                                                          phoneWithoutCountryCode;
                                                      authController
                                                          .initCountryCode(
                                                            countryCode:
                                                                countryCode !=
                                                                    ""
                                                                ? countryCode
                                                                : null,
                                                          );
                                                    }

                                                    // Reset captcha when
                                                    // switching login mode
                                                    _captchaController.reset();
                                                    setState(() {
                                                      _captchaVerified = false;
                                                    });
                                                  },
                                                  style: TextButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                        ),
                                                    minimumSize: const Size(
                                                      30,
                                                      30,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    authController
                                                                .selectedLoginMedium ==
                                                            LoginMedium.manual
                                                        ? 'OTP'.tr
                                                        : "email_phone".tr,
                                                    style: TextStyle(
                                                      decoration:
                                                          TextDecoration.none,
                                                      color: primaryGreen,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                      if (socialLogin == 1) ...[
                                        const SizedBox(height: 16),
                                        SocialLoginWidget(
                                          redirectUrl: widget.redirectRoute,
                                        ),
                                      ],

                                      const SizedBox(height: 24),

                                      // Sign Up Link
                                      if (manualLogin == 1)
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${'do_not_have_an_account'.tr} ',
                                                style: TextStyle(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: pureBlack.withOpacity(
                                                    0.7,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  signInPhoneController.clear();
                                                  signInPasswordController
                                                      .clear();
                                                  Get.toNamed(
                                                    RouteHelper.getSignUpRoute(
                                                      redirectUrl:
                                                          widget.redirectRoute,
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  'sign_up_here'.tr,
                                                  style: TextStyle(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: primaryGreen,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      const SizedBox(height: 32),

                                      // Athlete Switch
                                      _buildAthleteSwitch(),

                                      const SizedBox(height: 20),
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
          ),
        ),
      ),
    );
  }

  // ───────────────────────── UI helpers ─────────────────────────

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

  // ── Updated: accepts isEnabled for captcha gate ───────────────
  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
    required bool isEnabled,
  }) {
    final bool canTap = isEnabled && !isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      height: 56,
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
                ? primaryGreen.withOpacity(0.30)
                : Colors.grey.withOpacity(0.20),
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
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: pureWhite,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: pureWhite.withOpacity(canTap ? 1 : 0.9),
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, pureBlack.withOpacity(0.2)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or'.tr,
            style: TextStyle(
              fontSize: 14,
              color: pureBlack.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [pureBlack.withOpacity(0.2), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAthleteSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: lightGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryGreen.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sports_handball_rounded,
                    color: primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'are_you_an_athlete'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: pureBlack.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'switch_to_athlete_portal'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: pureBlack.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 48,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OutlinedButton.icon(
              onPressed: () => _switchToAthlete(),
              icon: const Icon(
                Icons.swap_horiz_rounded,
                size: 20,
                color: primaryGreen,
              ),
              label: Text(
                'switch_to_athlete_portal'.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: primaryGreen,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: pureWhite,
                side: const BorderSide(color: primaryGreen, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── logic ─────────────────────────

  void _initializeController() {
    var authController = Get.find<AuthController>();
    String phoneWithoutCountryCode =
        PhoneVerificationHelper.getValidPhoneNumber(
          Get.find<AuthController>().getUserNumber(),
        );
    String countryCode = PhoneVerificationHelper.getCountryCode(
      Get.find<AuthController>().getUserNumber(),
    );

    var config = Get.find<SplashController>().configModel.content;
    var manualLogin = config?.customerLogin?.loginOption?.manualLogin ?? 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (countryCode != "" && phoneWithoutCountryCode != "") {
        authController.toggleIsNumberLogin(value: true);
      } else {
        authController.toggleIsNumberLogin(value: false);
      }
      authController.toggleSelectedLoginMedium(loginMedium: LoginMedium.manual);
      authController.initCountryCode(
        countryCode: countryCode != "" ? countryCode : null,
      );

      signInPhoneController.text = phoneWithoutCountryCode != ""
          ? phoneWithoutCountryCode
          : authController.isNumberLogin
          ? ""
          : Get.find<AuthController>().getUserNumber();
      signInPasswordController.text = Get.find<AuthController>()
          .getUserPassword();

      if (manualLogin == 1 && signInPasswordController.text.isEmpty) {
        signInPhoneController.text = "";
        authController.initCountryCode();
        authController.toggleIsNumberLogin(value: false);
      }
    });
    authController.toggleRememberMe(value: false, shouldUpdate: false);
  }

  void _login(
    AuthController authController,
    var manualLogin,
    var otpLogin,
  ) async {
    // ── Captcha gate ─────────────────────────────────────────────────────
    if (!_captchaController.isVerified || !_captchaVerified) {
      customSnackBar('Please complete the security verification');
      return;
    }

    if (customerSignInKey.currentState!.validate()) {
      var config = Get.find<SplashController>().configModel.content;

      SendOtpType type = config?.firebaseOtpVerification == 1
          ? SendOtpType.firebase
          : SendOtpType.verification;

      String phone = PhoneVerificationHelper.getValidPhoneNumber(
        authController.countryDialCode + signInPhoneController.text.trim(),
        withCountryCode: true,
      );

      if ((authController.selectedLoginMedium == LoginMedium.otp) ||
          (manualLogin == 0 && otpLogin == 1)) {
        authController
            .sendVerificationCode(
              identity: phone,
              identityType: "phone",
              type: type,
              checkUser: 0,
              redirectUrl: widget.redirectRoute,
            )
            .then((status) {
              if (status != null) {
                if (status.isSuccess!) {
                  Get.toNamed(
                    RouteHelper.getVerificationRoute(
                      identity: phone,
                      identityType: "phone",
                      fromPage: config?.firebaseOtpVerification == 1
                          ? "firebase-otp"
                          : "otp-login",
                      firebaseSession: type == SendOtpType.firebase
                          ? status.message
                          : null,
                      redirectUrl: widget.redirectRoute,
                    ),
                  );
                } else {
                  customSnackBar(status.message.toString().capitalizeFirst);
                }
              }
            });
      } else {
        authController.login(
          redirectRoute: widget.redirectRoute,
          emailPhone: phone != "" ? phone : signInPhoneController.text.trim(),
          password: signInPasswordController.text.trim(),
          type: phone != "" ? "phone" : "email",
        );
      }
    }
  }

  Future<void> _switchToAthlete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_mode');
    Get.reset();
    runApp(const PortalApp());
  }
}
