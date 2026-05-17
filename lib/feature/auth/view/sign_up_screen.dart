/*
import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class SignUpScreen extends StatefulWidget {
  final String? referralCode;
  final String? redirectRoute;

  const SignUpScreen({super.key, this.referralCode, this.redirectRoute});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var referCodeController = TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();

  String? selectedUserType; // 'brand' or 'fan'

  late final GlobalKey<FormState> customerSignUpKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().initCountryCode();
    Get.find<AuthController>().toggleTerms(value: false, shouldUpdate: false);
    final ConfigModel config = Get.find<SplashController>().configModel;

    if (config.content?.referEarnStatus == 1 &&
        (widget.referralCode?.isNotEmpty ?? false)) {
      referCodeController.text = widget.referralCode ?? '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _clearControllerValue();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      onPopInvoked: () {
        AuthController authController = Get.find();
        authController.acceptTerms == true
            ? authController.toggleTerms()
            : authController.acceptTerms;
      },
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: const CustomAppBar(title: "", isBackgroundTransparent: true),
        body: SafeArea(
          child: GetBuilder<AuthController>(
            builder: (authController) {
              var config = Get.find<SplashController>().configModel.content;
              var socialLogin =
                  config?.customerLogin?.loginOption?.socialMediaLogin;

              return FooterBaseView(
                child: WebShadowWrap(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeExtraLarge,
                    ),
                    child: Column(
                      children: [
                        Form(
                          key: customerSignUpKey,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraMoreLarge,
                              ),

                              Hero(
                                tag: Images.logo,
                                child: Image.asset(
                                  Images.logo,
                                  width: Dimensions.logoSize,
                                ),
                              ),

                              const SizedBox(
                                height: Dimensions.paddingSizeExtraMoreLarge,
                              ),
                              if (ResponsiveHelper.isMobile(context))
                                _firstList(authController),
                              if (ResponsiveHelper.isMobile(context))
                                _secondList(authController),
                              if (!ResponsiveHelper.isMobile(context))
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _firstList(authController)),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeLarge,
                                    ),
                                    Expanded(
                                      child: _secondList(authController),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        ConditionCheckBox(
                          checkBoxValue: authController.acceptTerms,
                          onTap: (bool? value) {
                            if (customerSignUpKey.currentState?.validate() ==
                                true) {
                              authController.toggleTerms(value: true);
                            } else {
                              authController.toggleTerms(value: false);
                            }
                          },
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraLarge,
                        ),
                        CustomButton(
                          buttonText: 'sign_up'.tr,
                          isLoading: authController.isLoading,
                          onPressed:
                              authController.acceptTerms &&
                                  customerSignUpKey.currentState?.validate() ==
                                      true
                              ? () => _register(authController)
                              : null,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        socialLogin == 1
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.webMaxWidth / 3.5
                                      : ResponsiveHelper.isTab(context)
                                      ? Dimensions.webMaxWidth / 5.5
                                      : 0,
                                ),
                                child: SocialLoginWidget(
                                  redirectUrl: widget.redirectRoute,
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${'already_have_an_account'.tr} ',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.toNamed(RouteHelper.getSignInRoute());
                              },
                              child: Text(
                                'sign_in_here'.tr,
                                style: robotoRegular.copyWith(
                                  decoration: TextDecoration.underline,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        const SizedBox(
                          height: Dimensions.paddingSizeExtraMoreLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _firstList(AuthController authController) {
    return Column(
      children: [
        CustomTextField(
          title: 'first_name'.tr,
          hintText: 'enter_your_first_name'.tr,
          controller: firstNameController,
          isAutoFocus: false,
          focusNode: _firstNameFocus,
          nextFocus: _lastNameFocus,
          inputType: TextInputType.name,
          capitalization: TextCapitalization.words,
          onValidate: (String? value) {
            return FormValidation().isValidFirstName(value!);
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

        CustomTextField(
          title: 'last_name'.tr,
          hintText: 'enter_your_last_name'.tr,
          controller: lastNameController,
          focusNode: _lastNameFocus,
          nextFocus: _emailFocus,
          inputType: TextInputType.name,
          capitalization: TextCapitalization.words,
          onValidate: (String? value) {
            return FormValidation().isValidLastName(value!);
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

        CustomTextField(
          title: 'email_address'.tr,
          hintText: 'enter_email_address'.tr,
          controller: emailController,
          focusNode: _emailFocus,
          nextFocus: _phoneFocus,
          inputType: TextInputType.emailAddress,
          onValidate: (String? value) {
            return FormValidation().isValidEmail(value);
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

        CustomTextField(
          onCountryChanged: (CountryCode countryCode) {
            authController.countryDialCode = countryCode.dialCode!;
          },
          countryDialCode: authController.countryDialCode,
          hintText: 'enter_phone_number'.tr,
          controller: phoneController,
          focusNode: _phoneFocus,
          nextFocus: _passwordFocus,
          inputType: TextInputType.phone,
          isRequired: false,
          onValidate: (String? value) {
            if (value == null || value.isEmpty) {
              return 'enter_phone_number'.tr;
            } else {
              return FormValidation().isValidPhone(
                authController.countryDialCode + (value),
                fromAuthPage: true,
              );
            }
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),
        // User Type Selection
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 12),
                child: Text(
                  'register_as'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('brand'.tr, style: robotoRegular),
                      value: 'brand',
                      groupValue: selectedUserType,
                      onChanged: (value) {
                        setState(() {
                          selectedUserType = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('fan'.tr, style: robotoRegular),
                      value: 'fan',
                      groupValue: selectedUserType,
                      onChanged: (value) {
                        setState(() {
                          selectedUserType = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _secondList(AuthController authController) {
    return Column(
      children: [
        CustomTextField(
          title: 'password'.tr,
          hintText: '****************'.tr,
          controller: passwordController,
          focusNode: _passwordFocus,
          nextFocus: _confirmPasswordFocus,
          inputType: TextInputType.visiblePassword,
          onValidate: (String? value) {
            return FormValidation().isValidPassword(value!);
          },
          isPassword: true,
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

        CustomTextField(
          title: 'confirm_password'.tr,
          hintText: '****************'.tr,
          controller: confirmPasswordController,
          focusNode: _confirmPasswordFocus,
          nextFocus: _referCodeFocus,
          inputType: TextInputType.visiblePassword,
          isPassword: true,
          onValidate: (String? value) {
            if (value == null || value.isEmpty) {
              return 'this_field_can_not_empty'.tr;
            } else {
              return FormValidation().isValidConfirmPassword(
                passwordController.text,
                confirmPasswordController.text,
              );
            }
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),
        CustomTextField(
          title: 'referral_code'.tr,
          hintText: 'optional'.tr,
          controller: referCodeController,
          focusNode: _referCodeFocus,
          inputType: TextInputType.text,
          inputAction: TextInputAction.done,
          isRequired: false,
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),
      ],
    );
  }

  void _register(AuthController authController) async {
    if (customerSignUpKey.currentState!.validate()) {
      // Validate user type selection
      if (selectedUserType == null) {
        customSnackBar('please_select_user_type'.tr);
        return;
      }

      SignUpBody signUpBody;
      String numberWithCountryCode =
          PhoneVerificationHelper.getValidPhoneNumber(
            authController.countryDialCode + phoneController.value.text,
            withCountryCode: true,
          );

      if (referCodeController.text != "") {
        signUpBody = SignUpBody(
          fName: firstNameController.value.text.trim(),
          lName: lastNameController.value.text.trim(),
          email: emailController.value.text.trim(),
          phone: numberWithCountryCode.trim(),
          password: passwordController.value.text.trim(),
          confirmPassword: confirmPasswordController.value.text.trim(),
          referCode: referCodeController.text.trim(),
          userType: selectedUserType, // Pass the selected type
        );
      } else {
        signUpBody = SignUpBody(
          fName: firstNameController.value.text.trim(),
          lName: lastNameController.value.text.trim(),
          email: emailController.value.text.trim(),
          phone: numberWithCountryCode.trim(),
          password: passwordController.value.text.trim(),
          confirmPassword: confirmPasswordController.value.text.trim(),
          userType: selectedUserType, // Pass the selected type
        );
      }
      authController.registration(
        signUpBody: signUpBody,
        redirectUrl: widget.redirectRoute,
      );
    }
  }

  void _clearControllerValue() {
    firstNameController.text = "";
    lastNameController.text = "";
    emailController.text = "";
    phoneController.text = "";
    passwordController.text = "";
    confirmPasswordController.text = "";
    referCodeController.text = "";
  }
}
*/

import 'package:afriendorse/athlete/feature/captcha/app_captcha_widget.dart';
import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class SignUpScreen extends StatefulWidget {
  final String? referralCode;
  final String? redirectRoute;

  const SignUpScreen({super.key, this.referralCode, this.redirectRoute});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var referCodeController = TextEditingController();

  var brandNameController = TextEditingController();
  var industryController = TextEditingController();
  var cacNumberController = TextEditingController();
  var brandDescriptionController = TextEditingController();

  File? cacDocumentFile;
  String? cacDocumentUrl;

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();

  String? selectedUserType;

  // ── Captcha ──────────────────────────────────────────────────────────────
  final AppCaptchaController _captchaController = AppCaptchaController();
  bool _captchaVerified = false;

  late final GlobalKey<FormState> customerSignUpKey = GlobalKey<FormState>();

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
  static const Color subtleGrey = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    Get.find<AuthController>().initCountryCode();
    Get.find<AuthController>().toggleTerms(value: false, shouldUpdate: false);
    final ConfigModel config = Get.find<SplashController>().configModel;

    if (config.content?.referEarnStatus == 1 &&
        (widget.referralCode?.isNotEmpty ?? false)) {
      referCodeController.text = widget.referralCode ?? '';
    }
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
    _clearControllerValue();
    _disposeFocusNodes();
    super.dispose();
  }

  void _disposeFocusNodes() {
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _referCodeFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      onPopInvoked: () {
        AuthController authController = Get.find();
        authController.acceptTerms == true
            ? authController.toggleTerms()
            : authController.acceptTerms;
      },
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
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: GetBuilder<AuthController>(
            builder: (authController) {
              var config = Get.find<SplashController>().configModel.content;
              var socialLogin =
                  config?.customerLogin?.loginOption?.socialMediaLogin;

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FooterBaseView(
                    child: WebShadowWrap(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeExtraLarge,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Header Section
                            Center(
                              child: Column(
                                children: [
                                  Hero(
                                    tag: Images.appbarLogo,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryGreen.withOpacity(
                                              0.1,
                                            ),
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
                                  const SizedBox(height: 24),
                                  Text(
                                    'create_account'.tr,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: pureBlack,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'join_community'.tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: pureBlack.withOpacity(0.6),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            Form(
                              key: customerSignUpKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User Type Selection
                                  _buildUserTypeSelection(),

                                  const SizedBox(height: 24),

                                  // Form Fields
                                  if (ResponsiveHelper.isMobile(context))
                                    _buildMobileLayout(authController),
                                  if (!ResponsiveHelper.isMobile(context))
                                    _buildDesktopLayout(authController),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Captcha ──────────────────────────────────
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

                            const SizedBox(height: 24),

                            // Terms Checkbox
                            _buildTermsCheckbox(authController),

                            const SizedBox(height: 24),

                            // Primary Action Button
                            _buildPrimaryButton(authController),

                            const SizedBox(height: 24),

                            // Social Login
                            if (socialLogin == 1) ...[
                              _buildDivider(),
                              const SizedBox(height: 16),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.webMaxWidth / 3.5
                                      : ResponsiveHelper.isTab(context)
                                      ? Dimensions.webMaxWidth / 5.5
                                      : 0,
                                ),
                                child: SocialLoginWidget(
                                  redirectUrl: widget.redirectRoute,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Sign In Link
                            _buildSignInLink(),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ───────────────────────── layouts ─────────────────────────

  Widget _buildMobileLayout(AuthController authController) {
    return Column(
      children: [
        _buildFirstList(authController),
        const SizedBox(height: 20),
        _buildSecondList(authController),
      ],
    );
  }

  Widget _buildDesktopLayout(AuthController authController) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildFirstList(authController)),
        const SizedBox(width: Dimensions.paddingSizeLarge),
        Expanded(child: _buildSecondList(authController)),
      ],
    );
  }

  // ───────────────────────── user type ─────────────────────────

  Widget _buildUserTypeSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lightGreen.withOpacity(0.5), pureWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryGreen.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'i_am_a'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: pureBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildUserTypeCard(
                  title: 'brand'.tr,
                  subtitle: 'business_team'.tr,
                  icon: Icons.business_center_outlined,
                  value: 'brand',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUserTypeCard(
                  title: 'fan'.tr,
                  subtitle: 'supporter'.tr,
                  icon: Icons.favorite_outline,
                  value: 'fan',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = selectedUserType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUserType = value;
        });
        // Reset captcha when user type changes so they re-verify
        _captchaController.reset();
        setState(() {
          _captchaVerified = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : pureWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryGreen : pureBlack.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? pureWhite : primaryGreen, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? pureWhite : pureBlack,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? pureWhite.withOpacity(0.9)
                    : pureBlack.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── form fields ─────────────────────────

  Widget _buildFirstList(AuthController authController) {
    return Column(
      children: [
        _buildInputField(
          child: CustomTextField(
            title: 'first_name'.tr,
            hintText: 'enter_your_first_name'.tr,
            controller: firstNameController,
            isAutoFocus: false,
            focusNode: _firstNameFocus,
            nextFocus: _lastNameFocus,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
            onValidate: (String? value) {
              return FormValidation().isValidFirstName(value!);
            },
          ),
        ),
        const SizedBox(height: 20),

        _buildInputField(
          child: CustomTextField(
            title: 'last_name'.tr,
            hintText: 'enter_your_last_name'.tr,
            controller: lastNameController,
            focusNode: _lastNameFocus,
            nextFocus: _emailFocus,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
            onValidate: (String? value) {
              return FormValidation().isValidLastName(value!);
            },
          ),
        ),
        const SizedBox(height: 20),

        _buildInputField(
          child: CustomTextField(
            title: 'email_address'.tr,
            hintText: 'enter_email_address'.tr,
            controller: emailController,
            focusNode: _emailFocus,
            nextFocus: _phoneFocus,
            inputType: TextInputType.emailAddress,
            onValidate: (String? value) {
              return FormValidation().isValidEmail(value);
            },
          ),
        ),
        const SizedBox(height: 20),

        _buildInputField(
          child: CustomTextField(
            onCountryChanged: (CountryCode countryCode) {
              authController.countryDialCode = countryCode.dialCode!;
            },
            countryDialCode: authController.countryDialCode,
            hintText: 'enter_phone_number'.tr,
            controller: phoneController,
            focusNode: _phoneFocus,
            nextFocus: _passwordFocus,
            inputType: TextInputType.phone,
            isRequired: false,
            onValidate: (String? value) {
              if (value == null || value.isEmpty) {
                return 'enter_phone_number'.tr;
              } else {
                return FormValidation().isValidPhone(
                  authController.countryDialCode + (value),
                  fromAuthPage: true,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSecondList(AuthController authController) {
    return Column(
      children: [
        _buildInputField(
          child: CustomTextField(
            title: 'password'.tr,
            hintText: '••••••••••••',
            controller: passwordController,
            focusNode: _passwordFocus,
            nextFocus: _confirmPasswordFocus,
            inputType: TextInputType.visiblePassword,
            onValidate: (String? value) {
              return FormValidation().isValidPassword(value!);
            },
            isPassword: true,
          ),
        ),
        const SizedBox(height: 20),

        _buildInputField(
          child: CustomTextField(
            title: 'confirm_password'.tr,
            hintText: '••••••••••••',
            controller: confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            nextFocus: _referCodeFocus,
            inputType: TextInputType.visiblePassword,
            isPassword: true,
            onValidate: (String? value) {
              if (value == null || value.isEmpty) {
                return 'this_field_can_not_empty'.tr;
              } else {
                return FormValidation().isValidConfirmPassword(
                  passwordController.text,
                  confirmPasswordController.text,
                );
              }
            },
          ),
        ),
        const SizedBox(height: 20),

        _buildInputField(
          child: CustomTextField(
            title: 'referral_code'.tr,
            hintText: 'optional'.tr,
            controller: referCodeController,
            focusNode: _referCodeFocus,
            inputType: TextInputType.text,
            inputAction: TextInputAction.done,
            isRequired: false,
          ),
        ),
      ],
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

  Widget _buildTermsCheckbox(AuthController authController) {
    final bool isFormValid = customerSignUpKey.currentState?.validate() == true;

    final TextStyle baseStyle = TextStyle(
      fontSize: 14,
      color: pureBlack.withOpacity(0.80),
      height: 1.4,
      fontWeight: FontWeight.w500,
    );

    final TextStyle linkStyle = const TextStyle(
      fontSize: 14,
      color: primaryGreen,
      height: 1.4,
      fontWeight: FontWeight.w800,
      decoration: TextDecoration.underline,
      decorationThickness: 1.4,
    );

    void handleToggle() {
      if (!authController.acceptTerms && selectedUserType == null) {
        customSnackBar('please_select_user_type'.tr);
        return;
      }

      // ── Captcha gate for terms ────────────────────────────────────────
      if (!authController.acceptTerms && !_captchaVerified) {
        customSnackBar('Please complete the security verification first');
        return;
      }

      if (isFormValid) {
        authController.toggleTerms(value: !authController.acceptTerms);
      } else {
        authController.toggleTerms(value: false);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: authController.acceptTerms
            ? lightGreen.withOpacity(0.30)
            : subtleGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: authController.acceptTerms
              ? primaryGreen.withOpacity(0.30)
              : pureBlack.withOpacity(0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: handleToggle,
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: authController.acceptTerms ? primaryGreen : pureWhite,
                border: Border.all(
                  color: authController.acceptTerms
                      ? primaryGreen
                      : pureBlack.withOpacity(0.30),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: authController.acceptTerms
                  ? const Icon(Icons.check, size: 16, color: pureWhite)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              children: [
                Text('${'i_agree_with_the'.tr} ', style: baseStyle),
                InkWell(
                  onTap: () =>
                      Get.toNamed(RouteHelper.getTermsAndConditionsRoute()),
                  child: Text('terms_and_conditions'.tr, style: linkStyle),
                ),
                Text(' ${'and'.tr} ', style: baseStyle),
                InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getPrivacyPolicyRoute()),
                  child: Text('privacy_policy'.tr, style: linkStyle),
                ),
                Text('.', style: baseStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Updated: captcha gates the submit button too ──────────────
  Widget _buildPrimaryButton(AuthController authController) {
    final bool canSubmit =
        authController.acceptTerms &&
        _captchaVerified &&
        customerSignUpKey.currentState?.validate() == true;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: canSubmit
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
            color: canSubmit
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
          onTap: canSubmit ? () => _register(authController) : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: authController.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: pureWhite,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'create_account'.tr,
                    style: TextStyle(
                      color: pureWhite.withOpacity(canSubmit ? 1.0 : 0.9),
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
            'or_sign_up_with'.tr,
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

  Widget _buildSignInLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${'already_have_an_account'.tr} ',
            style: TextStyle(
              fontSize: Dimensions.fontSizeDefault,
              color: pureBlack.withOpacity(0.7),
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(RouteHelper.getSignInRoute()),
            child: Text(
              'sign_in_here'.tr,
              style: TextStyle(
                decoration: TextDecoration.none,
                color: primaryGreen,
                fontWeight: FontWeight.w700,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── logic ─────────────────────────

  void _register(AuthController authController) async {
    if (customerSignUpKey.currentState!.validate()) {
      if (selectedUserType == null) {
        customSnackBar('please_select_user_type'.tr);
        return;
      }

      // ── Captcha gate ──────────────────────────────────────────────────
      if (!_captchaController.isVerified || !_captchaVerified) {
        customSnackBar('Please complete the security verification');
        return;
      }

      SignUpBody signUpBody;
      String numberWithCountryCode =
          PhoneVerificationHelper.getValidPhoneNumber(
            authController.countryDialCode + phoneController.value.text,
            withCountryCode: true,
          );

      if (referCodeController.text != "") {
        signUpBody = SignUpBody(
          fName: firstNameController.value.text.trim(),
          lName: lastNameController.value.text.trim(),
          email: emailController.value.text.trim(),
          phone: numberWithCountryCode.trim(),
          password: passwordController.value.text.trim(),
          confirmPassword: confirmPasswordController.value.text.trim(),
          referCode: referCodeController.text.trim(),
          userType: selectedUserType,
        );
      } else {
        signUpBody = SignUpBody(
          fName: firstNameController.value.text.trim(),
          lName: lastNameController.value.text.trim(),
          email: emailController.value.text.trim(),
          phone: numberWithCountryCode.trim(),
          password: passwordController.value.text.trim(),
          confirmPassword: confirmPasswordController.value.text.trim(),
          userType: selectedUserType,
        );
      }

      authController.registration(
        signUpBody: signUpBody,
        redirectUrl: widget.redirectRoute,
      );
    }
  }

  void _clearControllerValue() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    referCodeController.clear();
  }
}
