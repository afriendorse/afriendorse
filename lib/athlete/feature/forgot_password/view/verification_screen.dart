/*

import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class VerificationScreen extends StatefulWidget {
  final String? identity;
  final String fromPage;
  final String identityType;
  final String? firebaseSession;
  final bool showSignUpDialog;
  const VerificationScreen({
    super.key,
    this.identity,
    required this.fromPage,
    required this.identityType,
    required this.showSignUpDialog,
    this.firebaseSession,
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

    Get.find<AuthController>().updateWrongVerificationCodeStatus();

    if (widget.identityType == "phone" && !widget.identity!.startsWith('+')) {
      _identity = '+${widget.identity!.substring(1, widget.identity!.length)}';
    } else {
      _identity = widget.identity;
    }

    _startTimer();
  }

  void _startTimer() {
    _seconds =
        Get.find<SplashController>().configModel.content?.sendOtpTimer ?? 60;
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'otp_verification'.tr),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: GetBuilder<AuthController>(
            builder: (authController) {
              return Column(
                children: [
                  Image.asset(Images.otp, width: 140),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Get.find<SplashController>()
                              .configModel
                              .content
                              ?.appEnvironment ==
                          "demo"
                      ? Text('for_demo_purpose'.tr, style: robotoRegular)
                      : RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                text: 'we_have_sent_a_verification_code_to'.tr,
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.5),
                                ),
                              ),
                              const TextSpan(text: "\n"),
                              TextSpan(
                                text: StringParser.obfuscateMiddle(
                                  _identity ?? "",
                                ),
                                style: robotoMedium.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                ),
                              ),

                              // const TextSpan(text: "\n"),
                              // TextSpan(text: 'otp_will_be_expire'.tr, style: ubuntuRegular.copyWith(
                              //   color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha:0.5),
                              //   height: 2,
                              // )),
                            ],
                          ),
                        ),

                  const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                  PinCodeTextField(
                    length: 6,
                    appContext: context,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.slide,
                    mainAxisAlignment: MainAxisAlignment.center,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      fieldHeight: ResponsiveHelper.isMobile(context)
                          ? width / 9
                          : 60,
                      fieldWidth: ResponsiveHelper.isMobile(context)
                          ? width / 9
                          : 60,
                      borderWidth: 0.5,
                      activeBorderWidth: 0.5,
                      inactiveBorderWidth: 0.5,
                      errorBorderWidth: 0.5,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSmall,
                      ),
                      selectedColor: authController.isWrongOtpSubmitted
                          ? Theme.of(
                              context,
                            ).colorScheme.error.withValues(alpha: 0.5)
                          : Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.2),
                      selectedFillColor: Get.isDarkMode
                          ? Colors.grey.withValues(alpha: 0.6)
                          : Colors.white,
                      inactiveFillColor: Theme.of(
                        context,
                      ).disabledColor.withValues(alpha: 0.2),
                      inactiveColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.2),
                      activeColor: authController.isWrongOtpSubmitted
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.4),
                      activeFillColor: Theme.of(
                        context,
                      ).disabledColor.withValues(alpha: 0.2),
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    onChanged: authController.updateVerificationCode,
                    beforeTextPaste: (text) => true,
                    pastedTextStyle: robotoRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        width: Dimensions.paddingSizeDefault,
                      );
                    },
                  ),

                  authController.isWrongOtpSubmitted
                      ? Text(
                          'incorrect_otp'.tr,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : const Text(" "),

                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  CustomButton(
                    margin: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                    ),
                    btnTxt: "verify".tr,
                    isLoading: authController.isLoading!,
                    onPressed: authController.verificationCode.length == 6
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

                  (widget.identity != null && widget.identity!.isNotEmpty)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'did_not_receive_the_code'.tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(1, 40),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                textStyle: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              onPressed: _seconds! < 1
                                  ? () {
                                      var config = Get.find<SplashController>()
                                          .configModel
                                          .content;
                                      SendOtpType type =
                                          config?.firebaseOtpVerification ==
                                                  1 &&
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
                                            resendOtp: true,
                                            fromPage: widget.fromPage,
                                          )
                                          .then((status) {
                                            if (status != null) {
                                              if (status.isSuccess!) {
                                                _startTimer();
                                                showCustomSnackBar(
                                                  'resend_code_successful'.tr,
                                                  type: ToasterMessageType
                                                      .success,
                                                );
                                              } else {
                                                showCustomSnackBar(
                                                  status.message,
                                                );
                                              }
                                            }
                                          });
                                    }
                                  : null,
                              child: Text(
                                '${'resend'.tr}${_seconds! > 0 ? ' ($_seconds)' : ''}',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),

                  SizedBox(height: Get.height * 0.1),
                ],
              );
            },
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
    var config = Get.find<SplashController>().configModel.content;
    var firebaseOtp =
        (config?.firebaseOtpVerification == 1) && identityType == "phone";

    if (widget.fromPage == "verification") {
      if (firebaseOtp) {
        authController
            .verifyOtpForFirebaseOtp(
              session: widget.firebaseSession,
              phone: identity,
              code: otp,
            )
            .then((status) {
              if (status.isSuccess!) {
                Get.toNamed(RouteHelper.getSignInRoute(""));
                if (widget.showSignUpDialog) {
                  showCustomBottomSheet(
                    child: const WelcomeBottomSheet(fromSignup: true),
                  );
                } else {
                  showCustomSnackBar(
                    status.message,
                    type: ToasterMessageType.success,
                  );
                }
              } else {
                showCustomSnackBar(status.message);
              }
            });
      } else {
        authController
            .verifyOtpForVerificationScreen(identity, identityType, otp)
            .then((status) {
              if (status.isSuccess!) {
                Get.toNamed(RouteHelper.getSignInRoute(""));
                if (widget.showSignUpDialog) {
                  showCustomBottomSheet(
                    child: const WelcomeBottomSheet(fromSignup: true),
                  );
                } else {
                  showCustomSnackBar(
                    status.message,
                    type: ToasterMessageType.success,
                  );
                }
              } else {
                showCustomSnackBar(status.message);
              }
            });
      }
    } else {
      if (firebaseOtp) {
        authController
            .verifyOtpForFirebaseOtp(
              session: widget.firebaseSession,
              phone: identity,
              code: otp,
            )
            .then((status) {
              if (status.isSuccess!) {
                Get.offNamed(
                  RouteHelper.getChangePasswordRoute(
                    identity,
                    identityType,
                    otp,
                    1,
                  ),
                );
              } else {
                showCustomSnackBar(status.message);
              }
            });
      } else {
        authController
            .verifyOtpForForgetPasswordScreen(identity, identityType, otp)
            .then((status) async {
              if (status.isSuccess!) {
                Get.offNamed(
                  RouteHelper.getChangePasswordRoute(
                    identity,
                    identityType,
                    otp,
                    0,
                  ),
                );
              } else {
                showCustomSnackBar(status.message);
              }
            });
      }
    }
  }
}

*/

import 'dart:async';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/auth/widgets/auth_pattern_background.dart';

class VerificationScreen extends StatefulWidget {
  final String? identity;
  final String fromPage;
  final String identityType;
  final String? firebaseSession;
  final bool showSignUpDialog;

  const VerificationScreen({
    super.key,
    this.identity,
    required this.fromPage,
    required this.identityType,
    required this.showSignUpDialog,
    this.firebaseSession,
  });

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _identity;
  Timer? _timer;
  int? _seconds = 0;

  static const Color primaryGreen = Color(0xFF045F25);
  static const Color darkGreen = Color(0xFF033D18);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);

  @override
  void initState() {
    super.initState();

    Get.find<AuthController>().updateWrongVerificationCodeStatus();

    if (widget.identityType == "phone" && !widget.identity!.startsWith('+')) {
      _identity = '+${widget.identity!.substring(1, widget.identity!.length)}';
    } else {
      _identity = widget.identity;
    }

    _startTimer();
  }

  void _startTimer() {
    _seconds =
        Get.find<SplashController>().configModel.content?.sendOtpTimer ?? 60;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(title: 'otp_verification'.tr),
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
                  child: GetBuilder<AuthController>(
                    builder: (authController) {
                      final bool isLoading = authController.isLoading ?? false;
                      final bool canVerify =
                          authController.verificationCode.length == 6 &&
                          !isLoading;

                      return Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: pureWhite.withOpacity(0.93),
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
                        child: Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: primaryGreen.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Image.asset(
                                Images.otp,
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(height: 22),

                            Text(
                              'otp_verification'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: pureBlack,
                                letterSpacing: -0.3,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Get.find<SplashController>()
                                        .configModel
                                        .content
                                        ?.appEnvironment ==
                                    "demo"
                                ? Text(
                                    'for_demo_purpose'.tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: pureBlack.withOpacity(0.65),
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.55,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${'we_have_sent_a_verification_code_to'.tr}\n',
                                          style: TextStyle(
                                            color: pureBlack.withOpacity(0.60),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: StringParser.obfuscateMiddle(
                                            _identity ?? "",
                                          ),
                                          style: const TextStyle(
                                            color: pureBlack,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                            const SizedBox(height: 26),

                            SizedBox(
                              width: double.infinity,
                              child: PinCodeTextField(
                                length: 6,
                                appContext: context,
                                keyboardType: TextInputType.number,
                                animationType: AnimationType.fade,
                                mainAxisAlignment: MainAxisAlignment.center,
                                autoFocus: true,
                                autoDismissKeyboard: true,
                                enableActiveFill: true,
                                animationDuration: const Duration(
                                  milliseconds: 220,
                                ),
                                backgroundColor: Colors.transparent,
                                pastedTextStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w600,
                                ),
                                beforeTextPaste: (text) => true,
                                onChanged:
                                    authController.updateVerificationCode,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 6),
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(14),
                                  fieldHeight: 46,
                                  fieldWidth: 46,
                                  borderWidth: 1.2,
                                  activeBorderWidth: 1.4,
                                  selectedBorderWidth: 1.4,
                                  inactiveBorderWidth: 1.1,
                                  errorBorderWidth: 1.2,
                                  selectedColor:
                                      authController.isWrongOtpSubmitted
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.error.withOpacity(0.55)
                                      : primaryGreen.withOpacity(0.55),
                                  selectedFillColor: pureWhite,
                                  inactiveFillColor: Colors.grey.shade100,
                                  inactiveColor: primaryGreen.withOpacity(0.18),
                                  activeColor:
                                      authController.isWrongOtpSubmitted
                                      ? Theme.of(context).colorScheme.error
                                      : primaryGreen,
                                  activeFillColor: primaryGreen.withOpacity(
                                    0.06,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: authController.isWrongOtpSubmitted
                                  ? Text(
                                      'incorrect_otp'.tr,
                                      key: const ValueKey('incorrect'),
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  : const SizedBox(
                                      key: ValueKey('empty'),
                                      height: 18,
                                    ),
                            ),

                            const SizedBox(height: 14),

                            _primaryButton(
                              text: "verify".tr,
                              isLoading: isLoading,
                              isEnabled: canVerify,
                              onPressed: () {
                                _otpVerify(
                                  _identity!,
                                  widget.identityType,
                                  authController.verificationCode,
                                  authController,
                                );
                              },
                            ),

                            const SizedBox(height: 18),

                            if (widget.identity != null &&
                                widget.identity!.isNotEmpty)
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'did_not_receive_the_code'.tr,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: pureBlack.withOpacity(0.60),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _seconds! < 1
                                        ? () {
                                            var config =
                                                Get.find<SplashController>()
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
                                                ? SendOtpType.verification
                                                : SendOtpType.forgetPassword;

                                            authController
                                                .sendVerificationCode(
                                                  identity: _identity!,
                                                  identityType:
                                                      widget.identityType,
                                                  type: type,
                                                  resendOtp: true,
                                                  fromPage: widget.fromPage,
                                                )
                                                .then((status) {
                                                  if (status != null) {
                                                    if (status.isSuccess!) {
                                                      _startTimer();
                                                      showCustomSnackBar(
                                                        'resend_code_successful'
                                                            .tr,
                                                        type: ToasterMessageType
                                                            .success,
                                                      );
                                                    } else {
                                                      showCustomSnackBar(
                                                        status.message,
                                                      );
                                                    }
                                                  }
                                                });
                                          }
                                        : null,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      _seconds! > 0
                                          ? '${'resend'.tr} (${_seconds})'
                                          : 'resend'.tr,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: _seconds! > 0
                                            ? Colors.grey.shade500
                                            : primaryGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            SizedBox(height: Get.height * 0.03),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

  void _otpVerify(
    String identity,
    String identityType,
    String otp,
    AuthController authController,
  ) async {
    var config = Get.find<SplashController>().configModel.content;
    var firebaseOtp =
        (config?.firebaseOtpVerification == 1) && identityType == "phone";

    if (widget.fromPage == "verification") {
      if (firebaseOtp) {
        authController
            .verifyOtpForFirebaseOtp(
              session: widget.firebaseSession,
              phone: identity,
              code: otp,
            )
            .then((status) {
              if (status.isSuccess!) {
                Get.toNamed(RouteHelper.getSignInRoute(""));
                if (widget.showSignUpDialog) {
                  showCustomBottomSheet(
                    child: const WelcomeBottomSheet(fromSignup: true),
                  );
                } else {
                  showCustomSnackBar(
                    status.message,
                    type: ToasterMessageType.success,
                  );
                }
              } else {
                showCustomSnackBar(status.message);
              }
            });
      } else {
        authController
            .verifyOtpForVerificationScreen(identity, identityType, otp)
            .then((status) {
              if (status.isSuccess!) {
                Get.toNamed(RouteHelper.getSignInRoute(""));
                if (widget.showSignUpDialog) {
                  showCustomBottomSheet(
                    child: const WelcomeBottomSheet(fromSignup: true),
                  );
                } else {
                  showCustomSnackBar(
                    status.message,
                    type: ToasterMessageType.success,
                  );
                }
              } else {
                showCustomSnackBar(status.message);
              }
            });
      }
    } else {
      if (firebaseOtp) {
        authController
            .verifyOtpForFirebaseOtp(
              session: widget.firebaseSession,
              phone: identity,
              code: otp,
            )
            .then((status) {
              if (status.isSuccess!) {
                Get.offNamed(
                  RouteHelper.getChangePasswordRoute(
                    identity,
                    identityType,
                    otp,
                    1,
                  ),
                );
              } else {
                showCustomSnackBar(status.message);
              }
            });
      } else {
        authController
            .verifyOtpForForgetPasswordScreen(identity, identityType, otp)
            .then((status) async {
              if (status.isSuccess!) {
                Get.offNamed(
                  RouteHelper.getChangePasswordRoute(
                    identity,
                    identityType,
                    otp,
                    0,
                  ),
                );
              } else {
                showCustomSnackBar(status.message);
              }
            });
      }
    }
  }
}
