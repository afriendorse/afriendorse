/*import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class UpdateProfileScreen extends StatefulWidget {
  final String? phone;
  final String? email;
  final String? tempToken;
  final String? userName;
  final String? redirectUrl;
  const UpdateProfileScreen({
    super.key,
    this.phone,
    this.email,
    this.tempToken,
    this.userName,
    this.redirectUrl,
  });

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailPhoneController = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _phoneEmailFocus = FocusNode();

  bool _canExit = GetPlatform.isWeb ? true : false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _setUserName();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      onPopInvoked: () => _existFromApp(),
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const WebMenuBar()
            : AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  hoverColor: Colors.transparent,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () {
                    Navigator.pop(context);
                    _socialLogout();
                  },
                ),
              ),

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
                child: GetBuilder<AuthController>(
                  builder: (authController) {
                    return Form(
                      autovalidateMode: ResponsiveHelper.isDesktop(context)
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      key: formKey,
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

                            const SizedBox(
                              height: Dimensions.paddingSizeTextFieldGap,
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                              ),
                              child: Text(
                                'just_one_step_away'.tr,
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withValues(alpha: 0.5),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraLarge,
                            ),

                            CustomTextField(
                              title: 'first_name'.tr,
                              hintText: 'first_name'.tr,
                              controller: firstNameController,
                              inputType: TextInputType.name,
                              focusNode: _firstNameFocus,
                              nextFocus: _lastNameFocus,
                              capitalization: TextCapitalization.words,
                              onValidate: (String? value) {
                                return FormValidation().isValidFirstName(
                                  value!,
                                );
                              },
                            ),

                            const SizedBox(
                              height: Dimensions.paddingSizeTextFieldGap,
                            ),
                            CustomTextField(
                              title: 'last_name'.tr,
                              hintText: 'last_name'.tr,
                              focusNode: _lastNameFocus,
                              nextFocus: _phoneEmailFocus,
                              controller: lastNameController,
                              inputType: TextInputType.name,
                              capitalization: TextCapitalization.words,
                              onValidate: (String? value) {
                                return FormValidation().isValidLastName(value!);
                              },
                            ),

                            const SizedBox(
                              height: Dimensions.paddingSizeTextFieldGap,
                            ),

                            CustomTextField(
                              onCountryChanged: (CountryCode countryCode) {
                                authController.countryDialCode =
                                    countryCode.dialCode!;
                              },
                              countryDialCode: (widget.email != "")
                                  ? authController.countryDialCode
                                  : null,
                              title: 'email_address'.tr,
                              hintText: (widget.email != "")
                                  ? "please_enter_phone_number".tr
                                  : 'enter_email_address'.tr,
                              inputType: TextInputType.emailAddress,
                              focusNode: _phoneEmailFocus,
                              controller: emailPhoneController,
                              onValidate: (String? value) {
                                if (widget.email != "" &&
                                    PhoneVerificationHelper.getValidPhoneNumber(
                                          authController.countryDialCode +
                                              emailPhoneController.text.trim(),
                                          withCountryCode: true,
                                        ) ==
                                        "") {
                                  return "enter_valid_phone_number".tr;
                                } else if (widget.email == "") {
                                  return null;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(
                              height: Dimensions.paddingSizeTextFieldGap,
                            ),

                            CustomButton(
                              buttonText: "done".tr,
                              onPressed: () {
                                _updateProfileAndNavigate(authController);
                              },
                              isLoading: authController.isLoading,
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeTextFieldGap * 2,
                            ),
                          ],
                        ),
                      ),
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

  void _setUserName() {
    if (widget.userName != null && widget.userName != "") {
      String fullName = widget.userName!.trim();
      List<String> nameParts = fullName.split(' ');

      if (nameParts.length == 1) {
        firstNameController.text = nameParts.first;
        lastNameController.text = "";
      } else {
        firstNameController.text = nameParts.first;
        lastNameController.text = nameParts.sublist(1).join(' ');
      }
    }
  }

  void _socialLogout() {
    Get.find<AuthController>().googleLogout();
    Get.find<AuthController>().signOutWithFacebook();
  }

  Future<bool> _existFromApp() async {
    if (_canExit) {
      if (GetPlatform.isAndroid) {
        SystemNavigator.pop();
      } else if (GetPlatform.isIOS) {
        SystemNavigator.pop();
      } else {
        _socialLogout();
        Navigator.pushNamed(context, RouteHelper.getInitialRoute());
      }
      return Future.value(false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'back_press_again_to_exit'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        ),
      );
      _canExit = true;
      Timer(const Duration(seconds: 2), () {
        _canExit = false;
      });
      return Future.value(false);
    }
  }

  Future<void> _updateProfileAndNavigate(AuthController authController) async {
    if (formKey.currentState!.validate()) {
      final String firstName = firstNameController.text.toString();
      final String lastName = lastNameController.text.toString();
      final String email = emailPhoneController.text.trim();
      String phone = PhoneVerificationHelper.getValidPhoneNumber(
        authController.countryDialCode + emailPhoneController.text.trim(),
        withCountryCode: true,
      );

      if (widget.tempToken != "") {
        await authController.registerWithSocialMedia(
          firstName: firstName,
          lastName: lastName,
          email: widget.email,
          phone: phone,
          redirectUrl: widget.redirectUrl,
        );
      } else {
        await authController.updateNewUserProfileAndLogin(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: widget.phone,
          redirectUrl: widget.redirectUrl,
        );
      }
    }
  }
} 
*/

import 'dart:async';
import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:afriendorse/feature/auth/repository/firestore_sync_service.dart';

import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class UpdateProfileScreen extends StatefulWidget {
  final String? phone;
  final String? email;
  final String? tempToken;
  final String? userName;
  final String? redirectUrl;
  const UpdateProfileScreen({
    super.key,
    this.phone,
    this.email,
    this.tempToken,
    this.userName,
    this.redirectUrl,
  });

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen>
    with SingleTickerProviderStateMixin {
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailPhoneController = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _phoneEmailFocus = FocusNode();

  bool _canExit = GetPlatform.isWeb ? true : false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? selectedUserType;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color primaryGreen = Color(0xFF045F25);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color darkGreen = Color(0xFF033D18);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setUserName();
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
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneEmailFocus.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      onPopInvoked: () => _existFromApp(),
      child: Scaffold(
        backgroundColor: pureWhite,
        appBar: ResponsiveHelper.isDesktop(context)
            ? const WebMenuBar()
            : AppBar(
                elevation: 0,
                backgroundColor: pureWhite,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: primaryGreen,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _socialLogout();
                  },
                ),
              ),
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
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: GetBuilder<AuthController>(
                      builder: (authController) {
                        return Form(
                          autovalidateMode: ResponsiveHelper.isDesktop(context)
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          key: formKey,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.webMaxWidth / 3.5
                                  : ResponsiveHelper.isTab(context)
                                  ? Dimensions.webMaxWidth / 5.5
                                  : Dimensions.paddingSizeLarge,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Hero(
                                    tag: Images.logo,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: lightGreen,
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
                                        Images.logo,
                                        width: Dimensions.logoSize,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  Text(
                                    'complete_profile'.tr,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: pureBlack,
                                      letterSpacing: -0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'just_one_step_away'.tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: pureBlack.withOpacity(0.6),
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 30),

                                  _buildUserTypeSelection(),
                                  const SizedBox(height: 20),

                                  _buildInputField(
                                    child: CustomTextField(
                                      title: 'first_name'.tr,
                                      hintText: 'enter_first_name'.tr,
                                      controller: firstNameController,
                                      inputType: TextInputType.name,
                                      focusNode: _firstNameFocus,
                                      nextFocus: _lastNameFocus,
                                      capitalization: TextCapitalization.words,
                                      onValidate: (String? value) {
                                        return FormValidation()
                                            .isValidFirstName(value!);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  _buildInputField(
                                    child: CustomTextField(
                                      title: 'last_name'.tr,
                                      hintText: 'enter_last_name'.tr,
                                      focusNode: _lastNameFocus,
                                      nextFocus: _phoneEmailFocus,
                                      controller: lastNameController,
                                      inputType: TextInputType.name,
                                      capitalization: TextCapitalization.words,
                                      onValidate: (String? value) {
                                        return FormValidation().isValidLastName(
                                          value!,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  _buildInputField(
                                    child: CustomTextField(
                                      onCountryChanged:
                                          (CountryCode countryCode) {
                                            authController.countryDialCode =
                                                countryCode.dialCode!;
                                          },
                                      countryDialCode: (widget.email != "")
                                          ? authController.countryDialCode
                                          : null,
                                      title: (widget.email != "")
                                          ? 'phone_number'.tr
                                          : 'email_address'.tr,
                                      hintText: (widget.email != "")
                                          ? "enter_phone_number".tr
                                          : 'enter_email_address'.tr,
                                      inputType: TextInputType.emailAddress,
                                      focusNode: _phoneEmailFocus,
                                      controller: emailPhoneController,
                                      onValidate: (String? value) {
                                        if (widget.email != "" &&
                                            PhoneVerificationHelper.getValidPhoneNumber(
                                                  authController
                                                          .countryDialCode +
                                                      emailPhoneController.text
                                                          .trim(),
                                                  withCountryCode: true,
                                                ) ==
                                                "") {
                                          return "enter_valid_phone_number".tr;
                                        } else if (widget.email == "") {
                                          return null;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  _buildPrimaryButton(
                                    text: 'complete_setup'.tr,
                                    onPressed: () => _updateProfileAndNavigate(
                                      authController,
                                    ),
                                    isLoading:
                                        authController.isLoading ?? false,
                                  ),

                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildUserTypeSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightGreen.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Account Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: pureBlack,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildTypeCard(
                  title: 'Brand',
                  subtitle: 'Business / Team',
                  value: 'brand',
                  icon: Icons.business_center_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeCard(
                  title: 'Fan',
                  subtitle: 'Supporter',
                  value: 'fan',
                  icon: Icons.favorite_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final isSelected = selectedUserType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUserType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : pureWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryGreen : pureBlack.withOpacity(0.12),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? pureWhite : primaryGreen, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? pureWhite : pureBlack,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? pureWhite.withOpacity(0.9)
                    : pureBlack.withOpacity(0.55),
              ),
              textAlign: TextAlign.center,
            ),
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

  void _setUserName() {
    if (widget.userName != null && widget.userName != "") {
      String fullName = widget.userName!.trim();
      List<String> nameParts = fullName.split(' ');

      if (nameParts.length == 1) {
        firstNameController.text = nameParts.first;
        lastNameController.text = "";
      } else {
        firstNameController.text = nameParts.first;
        lastNameController.text = nameParts.sublist(1).join(' ');
      }
    }
  }

  void _socialLogout() {
    Get.find<AuthController>().googleLogout();
    //  Get.find<AuthController>().signOutWithFacebook();
  }

  Future<bool> _existFromApp() async {
    if (_canExit) {
      if (GetPlatform.isAndroid || GetPlatform.isIOS) {
        SystemNavigator.pop();
      } else {
        _socialLogout();
        Navigator.pushNamed(context, RouteHelper.getInitialRoute());
      }
      return Future.value(false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'back_press_again_to_exit'.tr,
            style: const TextStyle(color: pureWhite),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryGreen,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        ),
      );
      _canExit = true;
      Timer(const Duration(seconds: 2), () {
        _canExit = false;
      });
      return Future.value(false);
    }
  }

  Future<void> _updateProfileAndNavigate(AuthController authController) async {
    if (!formKey.currentState!.validate()) return;

    if (selectedUserType == null) {
      customSnackBar('please_select_user_type'.tr);
      return;
    }

    final String firstName = firstNameController.text.toString().trim();
    final String lastName = lastNameController.text.toString().trim();
    final String emailInput = emailPhoneController.text.trim();

    String phone = PhoneVerificationHelper.getValidPhoneNumber(
      authController.countryDialCode + emailPhoneController.text.trim(),
      withCountryCode: true,
    );

    if (widget.tempToken != null && widget.tempToken!.isNotEmpty) {
      await authController.registerWithSocialMedia(
        firstName: firstName,
        lastName: lastName,
        email: widget.email,
        phone: phone,
        userType: selectedUserType,
        redirectUrl: widget.redirectUrl,
      );
    } else {
      await authController.updateNewUserProfileAndLogin(
        firstName: firstName,
        lastName: lastName,
        email: emailInput,
        phone: widget.phone,
        userType: selectedUserType,
        redirectUrl: widget.redirectUrl,
      );
    }
  }
}
