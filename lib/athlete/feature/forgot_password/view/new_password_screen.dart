/*
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class NewPassScreen extends StatefulWidget {
  final String identity;
  final String identityType;
  final String otp;
  final int isFirebaseOtp;
  const NewPassScreen({
    super.key,
    required this.identity,
    required this.otp,
    required this.identityType,
    required this.isFirebaseOtp,
  });

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String _identity = '';

  @override
  void initState() {
    super.initState();
    _identity = widget.identity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: "change_password".tr),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    title: 'New_Password'.tr,
                    hintText: "********",
                    controller: _newPasswordController,
                    focusNode: _newPasswordFocus,
                    nextFocus: _confirmPasswordFocus,
                    inputType: TextInputType.visiblePassword,
                    isPassword: true,
                    onValidate: (value) {
                      return (value == null || value.isEmpty)
                          ? "field_cannot_be_empty".tr
                          : value.length < 8
                          ? "password_should_be".tr
                          : null;
                    },
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                  CustomTextField(
                    title: "Confirm_New_Password".tr,
                    hintText: "********",
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    inputAction: TextInputAction.done,
                    inputType: TextInputType.visiblePassword,
                    isPassword: true,
                    onValidate: (value) {
                      return (value == null || value.isEmpty)
                          ? "field_cannot_be_empty".tr
                          : value != _newPasswordController.text
                          ? "confirm_password_does_not_matched".tr
                          : null;
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                  //const SizedBox(height: Dimensions.paddingSizeDefault),
                  GetBuilder<AuthController>(
                    builder: (controller) {
                      return CustomButton(
                        fontSize: Dimensions.fontSizeDefault,
                        btnTxt: "change_password".tr,
                        isLoading: controller.isLoading!,
                        onPressed: () => _resetPassword(
                          _identity,
                          widget.otp,
                          _newPasswordController.text.trim(),
                          _confirmPasswordController.text.trim(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword(
    String identity,
    String otp,
    String password,
    String conPassword,
  ) {
    if (formKey.currentState!.validate()) {
      Get.find<AuthController>().resetPassword(
        identity,
        widget.identityType,
        otp,
        password,
        conPassword,
        widget.isFirebaseOtp,
      );
    }
  }
}

*/

import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/auth/widgets/auth_pattern_background.dart';

class NewPassScreen extends StatefulWidget {
  final String identity;
  final String identityType;
  final String otp;
  final int isFirebaseOtp;

  const NewPassScreen({
    super.key,
    required this.identity,
    required this.otp,
    required this.identityType,
    required this.isFirebaseOtp,
  });

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _identity = '';

  static const Color primaryGreen = Color(0xFF045F25);
  static const Color darkGreen = Color(0xFF033D18);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);

  @override
  void initState() {
    super.initState();
    _identity = widget.identity;
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(title: "change_password".tr),
      body: Stack(
        children: [
          const Positioned.fill(child: AuthFaPatternBackground()),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: pureWhite.withOpacity(0.93),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: primaryGreen.withOpacity(0.10)),
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
                            width: 88,
                            height: 88,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Icon(
                              Icons.lock_reset_rounded,
                              size: 42,
                              color: primaryGreen,
                            ),
                          ),

                          const SizedBox(height: 22),

                          Text(
                            "change_password".tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: pureBlack,
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Create a new secure password for your account.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.55,
                              color: pureBlack.withOpacity(0.62),
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 26),

                          _fieldWrap(
                            child: CustomTextField(
                              title: 'New_Password'.tr,
                              hintText: "********",
                              controller: _newPasswordController,
                              focusNode: _newPasswordFocus,
                              nextFocus: _confirmPasswordFocus,
                              inputType: TextInputType.visiblePassword,
                              isPassword: true,
                              isShowBorder: true,
                              borderRadius: 14,
                              fillColor: Colors.white,
                              onValidate: (value) {
                                return (value == null || value.isEmpty)
                                    ? "field_cannot_be_empty".tr
                                    : value.length < 8
                                    ? "password_should_be".tr
                                    : null;
                              },
                            ),
                          ),

                          const SizedBox(height: 18),

                          _fieldWrap(
                            child: CustomTextField(
                              title: "Confirm_New_Password".tr,
                              hintText: "********",
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocus,
                              inputAction: TextInputAction.done,
                              inputType: TextInputType.visiblePassword,
                              isPassword: true,
                              isShowBorder: true,
                              borderRadius: 14,
                              fillColor: Colors.white,
                              onValidate: (value) {
                                return (value == null || value.isEmpty)
                                    ? "field_cannot_be_empty".tr
                                    : value != _newPasswordController.text
                                    ? "confirm_password_does_not_matched".tr
                                    : null;
                              },
                            ),
                          ),

                          const SizedBox(height: 24),

                          GetBuilder<AuthController>(
                            builder: (controller) {
                              final bool isLoading =
                                  controller.isLoading ?? false;

                              return _primaryButton(
                                text: "change_password".tr,
                                isLoading: isLoading,
                                isEnabled: !isLoading,
                                onPressed: () => _resetPassword(
                                  _identity,
                                  widget.otp,
                                  _newPasswordController.text.trim(),
                                  _confirmPasswordController.text.trim(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 8),
                        ],
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

  void _resetPassword(
    String identity,
    String otp,
    String password,
    String conPassword,
  ) {
    if (formKey.currentState!.validate()) {
      Get.find<AuthController>().resetPassword(
        identity,
        widget.identityType,
        otp,
        password,
        conPassword,
        widget.isFirebaseOtp,
      );
    }
  }
}
