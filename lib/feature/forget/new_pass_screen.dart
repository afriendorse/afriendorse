/* import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class NewPassScreen extends StatefulWidget {
  final ForgetPasswordBody? forgetPasswordBody;
  final String? redirectUrl;
  const NewPassScreen({super.key, this.forgetPasswordBody, this.redirectUrl});

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  final GlobalKey<FormState> newPassKey = GlobalKey<FormState>();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  String _identity = '';

  @override
  void initState() {
    AuthController authController = Get.find();

    authController.newPasswordController.clear();
    authController.confirmNewPasswordController.clear();

    super.initState();
    _identity = widget.forgetPasswordBody?.identity ?? "";

    if (widget.forgetPasswordBody?.fromUrl == 1) {
      authController
          .verifyOtpForForgetPasswordScreen(
            widget.forgetPasswordBody?.identity ?? "",
            widget.forgetPasswordBody?.identityType ?? "",
            widget.forgetPasswordBody?.otp ?? "",
            fromOutsideUrl: true,
            shouldUpdate: false,
          )
          .then((status) async {
            if (status.isSuccess!) {
              if (kDebugMode) {
                print("Session Available");
              }
            } else {
              if (kDebugMode) {
                print("Session Expired");
              }
            }
          });
    }
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
          title: 'change_password'.tr,
          onBackPressed: () {
            Get.find<AuthController>().updateVerificationCode('');
            Get.back();
          },
        ),
        body: GetBuilder<AuthController>(
          builder: (controller) {
            return SafeArea(
              child: FooterBaseView(
                isCenter: true,
                child: WebShadowWrap(
                  child: Center(
                    child:
                        controller.forgetPasswordUrlSessionExpired &&
                            controller.isLoading
                        ? const CircularProgressIndicator()
                        : controller.forgetPasswordUrlSessionExpired &&
                              !controller.isLoading
                        ? Column(
                            children: [
                              Text("url_session_expired".tr),
                              const SizedBox(
                                height: Dimensions.paddingSizeLarge,
                              ),
                              CustomButton(
                                width: 200,
                                buttonText: "go_back".tr,
                                onPressed: () {
                                  Get.offAllNamed(RouteHelper.getSignInRoute());
                                },
                              ),
                            ],
                          )
                        : Form(
                            key: newPassKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        ResponsiveHelper.isDesktop(context)
                                        ? Dimensions.webMaxWidth / 3.5
                                        : ResponsiveHelper.isTab(context)
                                        ? Dimensions.webMaxWidth / 5.5
                                        : Dimensions.paddingSizeLarge,
                                  ),
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        title: 'new_password'.tr,
                                        hintText: '**************',
                                        controller:
                                            controller.newPasswordController,
                                        focusNode: _passwordFocus,
                                        nextFocus: _confirmPasswordFocus,
                                        inputType:
                                            TextInputType.visiblePassword,
                                        isPassword: true,
                                        onValidate: (String? value) {
                                          return FormValidation()
                                              .isValidPassword(value!);
                                        },
                                      ),
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeTextFieldGap,
                                      ),

                                      CustomTextField(
                                        title: 'confirm_new_password'.tr,
                                        hintText: '**************',
                                        controller: controller
                                            .confirmNewPasswordController,
                                        inputAction: TextInputAction.done,
                                        focusNode: _confirmPasswordFocus,
                                        inputType:
                                            TextInputType.visiblePassword,
                                        isPassword: true,
                                        onValidate: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'this_field_can_not_empty'
                                                .tr;
                                          } else {
                                            return FormValidation()
                                                .isValidConfirmPassword(
                                                  controller
                                                      .newPasswordController
                                                      .text,
                                                  value,
                                                );
                                          }
                                        },
                                        onSubmit: (text) => GetPlatform.isWeb
                                            ? _resetPassword(
                                                confirmNewPassword: controller
                                                    .confirmNewPasswordController
                                                    .text,
                                                newPassword: controller
                                                    .confirmNewPasswordController
                                                    .text,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeTextFieldGap,
                                      ),

                                      GetBuilder<UserController>(
                                        builder: (userController) {
                                          return GetBuilder<AuthController>(
                                            builder: (authBuilder) {
                                              return CustomButton(
                                                buttonText:
                                                    'change_password'.tr,
                                                isLoading:
                                                    authBuilder.isLoading,
                                                onPressed: () {
                                                  if (isRedundentClick(
                                                    DateTime.now(),
                                                  )) {
                                                    return;
                                                  } else {
                                                    _resetPassword(
                                                      newPassword: controller
                                                          .newPasswordController
                                                          .value
                                                          .text,
                                                      confirmNewPassword: controller
                                                          .confirmNewPasswordController
                                                          .value
                                                          .text,
                                                    );
                                                  }
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
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
    );
  }

  void _resetPassword({
    required String newPassword,
    required String confirmNewPassword,
  }) {
    if (newPassKey.currentState!.validate()) {
      if (newPassword != confirmNewPassword) {
        customSnackBar('confirm_password_not_matched'.tr);
      } else {
        Get.find<AuthController>().resetPassword(
          identity: _identity,
          identityType: widget.forgetPasswordBody?.identityType ?? "",
          otp: widget.forgetPasswordBody?.otp ?? "",
          password: newPassword,
          confirmPassword: confirmNewPassword,
          isFirebaseOtp: widget.forgetPasswordBody?.isFirebaseOtp ?? 0,
          redirectUrl: widget.redirectUrl,
        );
      }
    }
  }
}
*/

import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class NewPassScreen extends StatefulWidget {
  final ForgetPasswordBody? forgetPasswordBody;
  final String? redirectUrl;
  const NewPassScreen({super.key, this.forgetPasswordBody, this.redirectUrl});

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> newPassKey = GlobalKey<FormState>();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  String _identity = '';

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
    _initializePassword();
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

  void _initializePassword() {
    AuthController authController = Get.find();
    authController.newPasswordController.clear();
    authController.confirmNewPasswordController.clear();
    _identity = widget.forgetPasswordBody?.identity ?? "";

    if (widget.forgetPasswordBody?.fromUrl == 1) {
      authController
          .verifyOtpForForgetPasswordScreen(
            widget.forgetPasswordBody?.identity ?? "",
            widget.forgetPasswordBody?.identityType ?? "",
            widget.forgetPasswordBody?.otp ?? "",
            fromOutsideUrl: true,
            shouldUpdate: false,
          )
          .then((status) async {
            if (status.isSuccess!) {
              if (kDebugMode) print("Session Available");
            } else {
              if (kDebugMode) print("Session Expired");
            }
          });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
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
              Get.find<AuthController>().updateVerificationCode('');
              Get.back();
            },
          ),
          title: Text(
            'create_new_password'.tr,
            style: const TextStyle(
              color: pureBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: GetBuilder<AuthController>(
          builder: (controller) {
            return SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FooterBaseView(
                    isCenter: true,
                    child: WebShadowWrap(
                      child: Center(
                        child:
                            controller.forgetPasswordUrlSessionExpired &&
                                controller.isLoading
                            ? const CircularProgressIndicator(
                                color: primaryGreen,
                              )
                            : controller.forgetPasswordUrlSessionExpired &&
                                  !controller.isLoading
                            ? _buildExpiredView()
                            : _buildPasswordForm(controller),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpiredView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.timer_off_rounded,
            size: 48,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "url_session_expired".tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: pureBlack.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton(
          text: "go_back".tr,
          onPressed: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
          isLoading: false,
          width: 200,
        ),
      ],
    );
  }

  Widget _buildPasswordForm(AuthController controller) {
    return Form(
      key: newPassKey,
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
            const SizedBox(height: 20),

            // Security Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 48,
                color: primaryGreen,
              ),
            ),

            const SizedBox(height: 32),

            // Header
            Text(
              'set_new_password'.tr,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: pureBlack,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              'create_strong_password'.tr,
              style: TextStyle(
                fontSize: 16,
                color: pureBlack.withOpacity(0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            _buildInputField(
              child: CustomTextField(
                title: 'new_password'.tr,
                hintText: '••••••••••••',
                controller: controller.newPasswordController,
                focusNode: _passwordFocus,
                nextFocus: _confirmPasswordFocus,
                inputType: TextInputType.visiblePassword,
                isPassword: true,
                onValidate: (String? value) {
                  return FormValidation().isValidPassword(value!);
                },
              ),
            ),

            const SizedBox(height: 20),

            _buildInputField(
              child: CustomTextField(
                title: 'confirm_new_password'.tr,
                hintText: '••••••••••••',
                controller: controller.confirmNewPasswordController,
                inputAction: TextInputAction.done,
                focusNode: _confirmPasswordFocus,
                inputType: TextInputType.visiblePassword,
                isPassword: true,
                onValidate: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'this_field_can_not_empty'.tr;
                  } else {
                    return FormValidation().isValidConfirmPassword(
                      controller.newPasswordController.text,
                      value,
                    );
                  }
                },
                onSubmit: (text) => GetPlatform.isWeb
                    ? _resetPassword(
                        confirmNewPassword:
                            controller.confirmNewPasswordController.text,
                        newPassword:
                            controller.confirmNewPasswordController.text,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 32),

            GetBuilder<UserController>(
              builder: (userController) {
                return GetBuilder<AuthController>(
                  builder: (authBuilder) {
                    return _buildPrimaryButton(
                      text: 'update_password'.tr,
                      onPressed: () {
                        if (isRedundentClick(DateTime.now())) return;
                        _resetPassword(
                          newPassword:
                              controller.newPasswordController.value.text,
                          confirmNewPassword: controller
                              .confirmNewPasswordController
                              .value
                              .text,
                        );
                      },
                      isLoading: authBuilder.isLoading,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
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
    double width = double.infinity,
  }) {
    return Container(
      width: width,
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

  void _resetPassword({
    required String newPassword,
    required String confirmNewPassword,
  }) {
    if (newPassKey.currentState!.validate()) {
      if (newPassword != confirmNewPassword) {
        customSnackBar('confirm_password_not_matched'.tr);
      } else {
        Get.find<AuthController>().resetPassword(
          identity: _identity,
          identityType: widget.forgetPasswordBody?.identityType ?? "",
          otp: widget.forgetPasswordBody?.otp ?? "",
          password: newPassword,
          confirmPassword: confirmNewPassword,
          isFirebaseOtp: widget.forgetPasswordBody?.isFirebaseOtp ?? 0,
          redirectUrl: widget.redirectUrl,
        );
      }
    }
  }
}
