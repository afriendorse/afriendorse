/* 
import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class VerificationScreen extends StatefulWidget {
  final String? identity;
  final String fromPage;
  final String identityType;
  final String? firebaseSession;
  final String? redirectRoute;
  const VerificationScreen({
    super.key,
    this.identity,
    required this.fromPage,
    required this.identityType,
    this.firebaseSession,
    this.redirectRoute,
  });

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _identity;
  Timer? _timer;
  int? _seconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.identityType == "phone" && !widget.identity!.startsWith('+')) {
      _identity = '+${widget.identity!.substring(1, widget.identity!.length)}';
    } else {
      _identity = widget.identity;
    }

    // Reset wrong OTP status when screen initializes
    Get.find<AuthController>().setWrongOtpSubmitted(false);

    _startTimer();
  }

  void _startTimer() {
    _seconds =
        Get.find<SplashController>().configModel.content?.resentOtpTime ?? 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(title: 'otp_verification'.tr),
        body: SafeArea(
          child: FooterBaseView(
            isCenter: true,
            child: WebShadowWrap(
              child: Scrollbar(
                child: SizedBox(
                  height: ResponsiveHelper.isDesktop(context)
                      ? MediaQuery.of(context).size.height * 0.7
                      : MediaQuery.of(context).size.height - 130,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                      ),
                      child: GetBuilder<AuthController>(
                        builder: (authController) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.webMaxWidth / 3.5
                                  : ResponsiveHelper.isTab(context)
                                  ? Dimensions.webMaxWidth / 5.5
                                  : 0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(Images.otp, width: 140),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),

                                Get.find<SplashController>()
                                            .configModel
                                            .content
                                            ?.appEnvironment ==
                                        "demo"
                                    ? Text(
                                        'for_demo_purpose'.tr,
                                        style: robotoRegular,
                                      )
                                    : RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: DefaultTextStyle.of(
                                            context,
                                          ).style,
                                          children: [
                                            TextSpan(
                                              text:
                                                  'we_have_sent_a_verification_code_to'
                                                      .tr,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color
                                                    ?.withValues(alpha: 0.5),
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  StringParser.obfuscateMiddle(
                                                    _identity ?? "",
                                                  ),
                                              style: robotoMedium.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge!.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraMoreLarge,
                                ),

                                PinCodeTextField(
                                  length: 6,
                                  appContext: context,
                                  keyboardType: TextInputType.number,
                                  animationType: AnimationType.slide,
                                  pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    fieldHeight:
                                        ResponsiveHelper.isMobile(context)
                                        ? width / 9
                                        : 60,
                                    fieldWidth:
                                        ResponsiveHelper.isMobile(context)
                                        ? width / 9
                                        : 60,
                                    borderWidth: 0.5,
                                    activeBorderWidth: 0.5,
                                    inactiveBorderWidth: 0.5,
                                    errorBorderWidth: 0.5,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                    selectedColor:
                                        authController.isWrongOtpSubmitted
                                        ? Theme.of(context).colorScheme.error
                                              .withValues(alpha: 0.5)
                                        : Theme.of(context).colorScheme.primary
                                              .withValues(alpha: 0.2),
                                    selectedFillColor: Get.isDarkMode
                                        ? Colors.grey.withValues(alpha: 0.6)
                                        : Colors.white,
                                    inactiveFillColor: Get.isDarkMode
                                        ? Theme.of(context).disabledColor
                                              .withValues(alpha: 0.50)
                                        : Theme.of(context).cardColor,
                                    inactiveColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(
                                          alpha: Get.isDarkMode ? 0.7 : 0.2,
                                        ),
                                    activeColor:
                                        authController.isWrongOtpSubmitted
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.primary
                                              .withValues(alpha: 0.4),
                                    activeFillColor: Get.isDarkMode
                                        ? Theme.of(context).disabledColor
                                              .withValues(alpha: 0.50)
                                        : Theme.of(context).cardColor,
                                  ),
                                  animationDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  backgroundColor: Colors.transparent,
                                  enableActiveFill: true,
                                  onChanged:
                                      authController.updateVerificationCode,
                                  beforeTextPaste: (text) => true,
                                  pastedTextStyle: robotoRegular.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.color,
                                  ),
                                  textStyle: robotoMedium,
                                ),

                                authController.isWrongOtpSubmitted
                                    ? Text(
                                        'incorrect_otp'.tr,
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                    : const Text(" "),

                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                CustomButton(
                                  buttonText: "verify".tr,
                                  isLoading: authController.isLoading,
                                  onPressed:
                                      (authController.verificationCode.length ==
                                              6 &&
                                          !authController.isResendLoading)
                                      ? () {
                                          _otpVerify(
                                            _identity!,
                                            widget.identityType,
                                            authController.verificationCode,
                                            authController,
                                          );
                                        }
                                      : null,
                                ),

                                const SizedBox(
                                  height: Dimensions.paddingSizeEight,
                                ),

                                (widget.identity != null &&
                                        widget.identity!.isNotEmpty)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'did_not_receive_the_code'.tr,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color!
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: Dimensions.paddingSizeSmall,
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              minimumSize: const Size(1, 40),
                                              backgroundColor: Theme.of(
                                                context,
                                              ).cardColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeSmall,
                                                  ),
                                            ),
                                            onPressed:
                                                (_seconds! < 1 &&
                                                    !authController
                                                        .isResendLoading)
                                                ? () {
                                                    var config =
                                                        Get.find<
                                                              SplashController
                                                            >()
                                                            .configModel
                                                            .content;
                                                    SendOtpType type =
                                                        config?.firebaseOtpVerification ==
                                                                1 &&
                                                            widget.identityType ==
                                                                "phone"
                                                        ? SendOtpType.firebase
                                                        : widget.fromPage ==
                                                              "verification"
                                                        ? SendOtpType
                                                              .verification
                                                        : SendOtpType
                                                              .forgetPassword;

                                                    authController
                                                        .sendVerificationCode(
                                                          identity: _identity!,
                                                          identityType: widget
                                                              .identityType,
                                                          type: type,
                                                          isResend: true,
                                                        )
                                                        .then((status) {
                                                          if (status != null) {
                                                            if (status
                                                                .isSuccess!) {
                                                              _startTimer();
                                                              customSnackBar(
                                                                'resend_code_successful'
                                                                    .tr,
                                                                type:
                                                                    ToasterMessageType
                                                                        .success,
                                                              );
                                                            } else {
                                                              customSnackBar(
                                                                status.message,
                                                              );
                                                            }
                                                          }
                                                        });
                                                  }
                                                : null,
                                            child:
                                                authController.isResendLoading
                                                ? Row(
                                                    children: [
                                                      Text(
                                                        'resending'.tr,
                                                        style: robotoRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                    alpha: 0.8,
                                                                  ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall,
                                                      ),

                                                      SizedBox(
                                                        height: Dimensions
                                                            .fontSizeDefault,
                                                        width: Dimensions
                                                            .fontSizeDefault,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                    alpha: 0.8,
                                                                  ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    '${'resend'.tr}${_seconds! > 0 ? ' ($_seconds)' : ''}',
                                                    style: robotoRegular
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                    alpha: 0.9,
                                                                  ),
                                                        ),
                                                  ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraMoreLarge,
                                ),
                              ],
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
      ),
    );
  }

  void _otpVerify(
    String identity,
    String identityType,
    String otp,
    AuthController authController,
  ) async {
    if (widget.fromPage == "verification" || widget.fromPage == "profile") {
      authController.verifyOtpForVerificationScreen(
        identity: identity,
        identityType: identityType,
        otp: otp,
        fromPage: widget.fromPage,
        redirectUrl: widget.redirectRoute,
      );
    } else if (widget.fromPage == "otp-login") {
      authController.verifyOtpForPhoneOtpLogin(
        phone: identity,
        otp: otp,
        redirectUrl: widget.redirectRoute,
      );
    } else if (widget.fromPage == "firebase-otp" ||
        (widget.fromPage == "forget-password" && identityType == "phone") &&
            (widget.firebaseSession ?? '').isNotEmpty) {
      authController.verifyOtpForFirebaseOtp(
        session: widget.firebaseSession,
        phone: identity,
        code: otp,
        fromPage: widget.fromPage,
        redirectUrl: widget.redirectRoute,
      );
    } else {
      authController.updateForgetPasswordUrlSessionExpiredStatus(status: false);
      authController
          .verifyOtpForForgetPasswordScreen(identity, identityType, otp)
          .then((status) async {
            if (status.isSuccess!) {
              Get.offNamed(
                RouteHelper.getChangePasswordRoute(
                  body: ForgetPasswordBody(
                    identity: identity,
                    identityType: identityType,
                    otp: otp,
                    fromUrl: 0,
                  ),
                  redirectUrl: widget.redirectRoute,
                ),
              );
            } else {
              customSnackBar(status.message.toString().capitalizeFirst);
            }
          });
    }
  }
}
*/

import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class VerificationScreen extends StatefulWidget {
  final String? identity;
  final String fromPage;
  final String identityType;
  final String? firebaseSession;
  final String? redirectRoute;
  const VerificationScreen({
    super.key,
    this.identity,
    required this.fromPage,
    required this.identityType,
    this.firebaseSession,
    this.redirectRoute,
  });

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen>
    with SingleTickerProviderStateMixin {
  String? _identity;
  Timer? _timer;
  int? _seconds = 0;

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
  static const Color errorRed = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupIdentity();
    _startTimer();
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

  void _setupIdentity() {
    if (widget.identityType == "phone" && !widget.identity!.startsWith('+')) {
      _identity = '+${widget.identity!.substring(1, widget.identity!.length)}';
    } else {
      _identity = widget.identity;
    }
    Get.find<AuthController>().setWrongOtpSubmitted(false);
  }

  void _startTimer() {
    _seconds =
        Get.find<SplashController>().configModel.content?.resentOtpTime ?? 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

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
            onPressed: () => Get.back(),
          ),
          title: Text(
            'verification'.tr,
            style: const TextStyle(
              color: pureBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: FooterBaseView(
                isCenter: true,
                child: WebShadowWrap(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                      ),
                      child: GetBuilder<AuthController>(
                        builder: (authController) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.webMaxWidth / 3.5
                                  : ResponsiveHelper.isTab(context)
                                  ? Dimensions.webMaxWidth / 5.5
                                  : 0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),

                                // OTP Icon with pulse animation
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
                                    Icons.message_rounded,
                                    size: 48,
                                    color: primaryGreen,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Header
                                Text(
                                  'enter_verification_code'.tr,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: pureBlack,
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 12),

                                // Identity display
                                Get.find<SplashController>()
                                            .configModel
                                            .content
                                            ?.appEnvironment ==
                                        "demo"
                                    ? Text(
                                        'for_demo_purpose'.tr,
                                        style: const TextStyle(
                                          color: primaryGreen,
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: lightGreen,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          StringParser.obfuscateMiddle(
                                            _identity ?? "",
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: primaryGreen,
                                          ),
                                        ),
                                      ),

                                const SizedBox(height: 8),

                                Text(
                                  'we_sent_code_to'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: pureBlack.withOpacity(0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 40),

                                // OTP Input with custom styling
                                PinCodeTextField(
                                  length: 6,
                                  appContext: context,
                                  keyboardType: TextInputType.number,
                                  animationType: AnimationType.fade,
                                  pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    fieldHeight:
                                        ResponsiveHelper.isMobile(context)
                                        ? width / 9
                                        : 60,
                                    fieldWidth:
                                        ResponsiveHelper.isMobile(context)
                                        ? width / 9
                                        : 60,
                                    borderWidth: 2,
                                    activeBorderWidth: 2,
                                    inactiveBorderWidth: 2,
                                    errorBorderWidth: 2,
                                    borderRadius: BorderRadius.circular(12),
                                    selectedColor:
                                        authController.isWrongOtpSubmitted
                                        ? errorRed
                                        : primaryGreen,
                                    selectedFillColor: pureWhite,
                                    inactiveFillColor: pureWhite,
                                    inactiveColor: pureBlack.withOpacity(0.2),
                                    activeColor:
                                        authController.isWrongOtpSubmitted
                                        ? errorRed
                                        : primaryGreen,
                                    activeFillColor: pureWhite,
                                  ),
                                  animationDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  backgroundColor: Colors.transparent,
                                  enableActiveFill: true,
                                  onChanged:
                                      authController.updateVerificationCode,
                                  beforeTextPaste: (text) => true,
                                  pastedTextStyle: const TextStyle(
                                    color: pureBlack,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),

                                // Error message
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: authController.isWrongOtpSubmitted
                                      ? 30
                                      : 0,
                                  child: authController.isWrongOtpSubmitted
                                      ? Text(
                                          'incorrect_otp'.tr,
                                          style: const TextStyle(
                                            color: errorRed,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      : const SizedBox(),
                                ),

                                const SizedBox(height: 32),

                                // Verify Button
                                _buildPrimaryButton(
                                  text: "verify".tr,
                                  onPressed:
                                      (authController.verificationCode.length ==
                                              6 &&
                                          !authController.isResendLoading)
                                      ? () {
                                          _otpVerify(
                                            _identity!,
                                            widget.identityType,
                                            authController.verificationCode,
                                            authController,
                                          );
                                        }
                                      : null,
                                  isLoading: authController.isLoading,
                                ),

                                const SizedBox(height: 24),

                                // Resend Section
                                if (widget.identity != null &&
                                    widget.identity!.isNotEmpty)
                                  _buildResendSection(authController),

                                const SizedBox(height: 32),
                              ],
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
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    final bool isActive = onPressed != null;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isActive
            ? const LinearGradient(
                colors: [primaryGreen, darkGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  pureBlack.withOpacity(0.2),
                  pureBlack.withOpacity(0.1),
                ],
              ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
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
                    style: TextStyle(
                      color: isActive ? pureWhite : pureBlack.withOpacity(0.4),
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

  Widget _buildResendSection(AuthController authController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'did_not_receive_code'.tr,
            style: TextStyle(fontSize: 14, color: pureBlack.withOpacity(0.7)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(1, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: _seconds! < 1 && !authController.isResendLoading
                  ? primaryGreen
                  : pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: (_seconds! < 1 && !authController.isResendLoading)
                ? () {
                    var config =
                        Get.find<SplashController>().configModel.content;
                    SendOtpType type =
                        config?.firebaseOtpVerification == 1 &&
                            widget.identityType == "phone"
                        ? SendOtpType.firebase
                        : widget.fromPage == "verification"
                        ? SendOtpType.verification
                        : SendOtpType.forgetPassword;

                    authController
                        .sendVerificationCode(
                          identity: _identity!,
                          identityType: widget.identityType,
                          type: type,
                          isResend: true,
                        )
                        .then((status) {
                          if (status != null) {
                            if (status.isSuccess!) {
                              _startTimer();
                              customSnackBar(
                                'resend_code_successful'.tr,
                                type: ToasterMessageType.success,
                              );
                            } else {
                              customSnackBar(status.message);
                            }
                          }
                        });
                  }
                : null,
            child: authController.isResendLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: pureWhite,
                    ),
                  )
                : Text(
                    _seconds! > 0 ? 'resend_in'.tr + ' $_seconds' : 'resend'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _seconds! < 1 && !authController.isResendLoading
                          ? pureWhite
                          : primaryGreen,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _otpVerify(
    String identity,
    String identityType,
    String otp,
    AuthController authController,
  ) async {
    if (widget.fromPage == "verification" || widget.fromPage == "profile") {
      authController.verifyOtpForVerificationScreen(
        identity: identity,
        identityType: identityType,
        otp: otp,
        fromPage: widget.fromPage,
        redirectUrl: widget.redirectRoute,
      );
    } else if (widget.fromPage == "otp-login") {
      authController.verifyOtpForPhoneOtpLogin(
        phone: identity,
        otp: otp,
        redirectUrl: widget.redirectRoute,
      );
    } else if (widget.fromPage == "firebase-otp" ||
        (widget.fromPage == "forget-password" && identityType == "phone") &&
            (widget.firebaseSession ?? '').isNotEmpty) {
      authController.verifyOtpForFirebaseOtp(
        session: widget.firebaseSession,
        phone: identity,
        code: otp,
        fromPage: widget.fromPage,
        redirectUrl: widget.redirectRoute,
      );
    } else {
      authController.updateForgetPasswordUrlSessionExpiredStatus(status: false);
      authController
          .verifyOtpForForgetPasswordScreen(identity, identityType, otp)
          .then((status) async {
            if (status.isSuccess!) {
              Get.offNamed(
                RouteHelper.getChangePasswordRoute(
                  body: ForgetPasswordBody(
                    identity: identity,
                    identityType: identityType,
                    otp: otp,
                    fromUrl: 0,
                  ),
                  redirectUrl: widget.redirectRoute,
                ),
              );
            } else {
              customSnackBar(status.message.toString().capitalizeFirst);
            }
          });
    }
  }
}
