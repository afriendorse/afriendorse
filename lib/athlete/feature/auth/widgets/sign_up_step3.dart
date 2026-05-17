import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SignUpStep3 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const SignUpStep3({super.key, required this.formKey});

  @override
  State<SignUpStep3> createState() => _SignUpStep3State();
}

class _SignUpStep3State extends State<SignUpStep3> {
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  static const Color _primaryGreen = Color(0xFF045F25);
  static const Color _darkGreen = Color(0xFF033D18);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: GetBuilder<SignUpController>(
          builder: (signUpController) {
            return Container(
              margin: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.93),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primaryGreen.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: _primaryGreen.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Form(
                key: widget.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_primaryGreen, _darkGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "account_information".tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Email (read-only)
                    CustomTextField(
                      inputType: TextInputType.emailAddress,
                      controller: signUpController.companyEmailController,
                      hintText: "enter_email".tr,
                      title: "Email_address".tr,
                      isEnabled: false,
                      isShowBorder: true,
                      borderRadius: 12,
                      fillColor: const Color(0xFFF5F5F5),
                    ),
                    const SizedBox(height: 14),

                    // Phone (read-only)
                    CustomTextField(
                      onCountryChanged: (CountryCode countryCode) {
                        signUpController.countryDialCode =
                            countryCode.dialCode!;
                      },
                      countryDialCode: signUpController.countryDialCode,
                      hintText: 'ex : 123456789'.tr,
                      isEnabled: false,
                      controller: signUpController.companyPhoneController,
                      isShowBorder: true,
                      borderRadius: 12,
                      fillColor: const Color(0xFFF5F5F5),
                    ),
                    const SizedBox(height: 14),

                    // Password
                    CustomTextField(
                      isShowSuffixIcon: true,
                      inputType: TextInputType.visiblePassword,
                      focusNode: _passwordFocus,
                      nextFocus: _confirmPasswordFocus,
                      inputAction: TextInputAction.next,
                      controller: signUpController.accountPasswordController,
                      hintText: "********",
                      title: "password".tr,
                      isPassword: true,
                      isShowBorder: true,
                      borderRadius: 12,
                      fillColor: Colors.white,
                      onValidate: (value) => (value == null || value.isEmpty)
                          ? "field_cannot_be_empty".tr
                          : value.length < 8
                          ? "password_should_be".tr
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Confirm password
                    CustomTextField(
                      isShowSuffixIcon: true,
                      focusNode: _confirmPasswordFocus,
                      inputType: TextInputType.visiblePassword,
                      controller:
                          signUpController.accountConfirmPasswordController,
                      inputAction: TextInputAction.done,
                      hintText: "********",
                      title: "confirm_password".tr,
                      isPassword: true,
                      isShowBorder: true,
                      borderRadius: 12,
                      fillColor: Colors.white,
                      onValidate: (value) => (value == null || value.isEmpty)
                          ? "field_cannot_be_empty".tr
                          : value !=
                                signUpController.accountPasswordController.text
                          ? "confirm_password_does_not_matched".tr
                          : null,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
