import 'dart:math';

import 'package:afriendorse/athlete/feature/captcha/app_captcha_widget.dart';
import 'package:afriendorse/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  const SignInScreen({super.key, required this.exitFromApp});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _passwordController = TextEditingController();

  bool _canExit = GetPlatform.isWeb ? true : false;
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  //Captcha
  final AppCaptchaController _captchaController = AppCaptchaController();
  bool _captchaVerified = false;

  // Brand-like colors
  static const Color primaryGreen = Color(0xFF045F25);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color darkGreen = Color(0xFF033D18);

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _setupAnimations();
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
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      onPopInvoked: () {
        if (!widget.exitFromApp) {
          Get.back();
          return;
        }

        if (_canExit) {
          exit(0);
        } else {
          showCustomSnackBar(
            'back_press_again_to_exit'.tr,
            type: ToasterMessageType.info,
          );
          _canExit = true;
          Timer(const Duration(seconds: 2), () => _canExit = false);
        }
      },
      child: Scaffold(
        // Make scaffold transparent so the pattern background shows through
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ── Fixed full-screen pattern background (WhatsApp-like) ──────────
            const Positioned.fill(child: _AuthFaPatternBackground()),

            // ── Foreground content ───────────────────────────────────────────
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: GetBuilder<AuthController>(
                    builder: (authController) {
                      final rememberMe =
                          authController.isActiveRememberMe ?? false;
                      final isLoading = authController.isLoading ?? false;

                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Form(
                            key: signInFormKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),

                                // Logo container (premium)
                                Center(
                                  child: Hero(
                                    tag: Images.logo,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: pureWhite.withOpacity(0.90),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: primaryGreen.withOpacity(0.08),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryGreen.withOpacity(
                                              0.10,
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
                                ),

                                const SizedBox(height: 32),

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

                                const SizedBox(height: 28),

                                // Email/Phone
                                _fieldWrap(
                                  child: CustomTextField(
                                    onCountryChanged: (countryCode) =>
                                        authController.countryDialCode =
                                            countryCode.dialCode!,
                                    countryDialCode:
                                        authController.isNumberLogin
                                        ? authController.countryDialCode
                                        : null,
                                    title: 'email_or_phone'.tr,
                                    hintText:
                                        'enter_email_address_or_phone_number'
                                            .tr,
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    nextFocus: _passwordFocus,
                                    inputType: TextInputType.emailAddress,
                                    isShowBorder: true,
                                    borderRadius: 14,
                                    fillColor: pureWhite, // field fill
                                    onChanged: (String text) {
                                      final numberRegExp = RegExp(
                                        r'^[+]?[0-9]+$',
                                      );

                                      if (text.isEmpty &&
                                          authController.isNumberLogin) {
                                        authController.toggleIsNumberLogin();
                                      }

                                      if (text.startsWith(numberRegExp) &&
                                          !authController.isNumberLogin) {
                                        authController.toggleIsNumberLogin();
                                        _emailController.text = text.replaceAll(
                                          "+",
                                          "",
                                        );
                                        _emailController.selection =
                                            TextSelection.fromPosition(
                                              TextPosition(
                                                offset: _emailController
                                                    .text
                                                    .length,
                                              ),
                                            );
                                      }

                                      final emailRegExp = RegExp(r'@');
                                      if (text.contains(emailRegExp) &&
                                          authController.isNumberLogin) {
                                        authController.toggleIsNumberLogin();
                                      }
                                    },
                                    onValidate: (String? value) {
                                      if (authController.isNumberLogin &&
                                          ValidationHelper.getValidPhone(
                                                authController.countryDialCode +
                                                    (value ?? ""),
                                              ) ==
                                              "") {
                                        return "enter_valid_phone_number".tr;
                                      }
                                      return (GetUtils.isPhoneNumber(
                                                (value ?? "").tr,
                                              ) ||
                                              GetUtils.isEmail(
                                                (value ?? "").tr,
                                              ))
                                          ? null
                                          : 'enter_email_address_or_phone_number'
                                                .tr;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // Password
                                _fieldWrap(
                                  child: CustomTextField(
                                    title: 'password'.tr,
                                    hintText: '********',
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    inputType: TextInputType.visiblePassword,
                                    isPassword: true,
                                    inputAction: TextInputAction.done,
                                    isShowBorder: true,
                                    borderRadius: 14,
                                    fillColor: pureWhite,
                                    onValidate: (String? value) {
                                      return FormValidationHelper()
                                          .isValidPassword(value);
                                    },
                                  ),
                                ),

                                const SizedBox(height: 20),

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

                                const SizedBox(height: 12),

                                // Remember + Forgot
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          authController.toggleRememberMe(),
                                      child: Row(
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              color: rememberMe
                                                  ? primaryGreen
                                                  : pureWhite,
                                              border: Border.all(
                                                color: rememberMe
                                                    ? primaryGreen
                                                    : pureBlack.withOpacity(
                                                        0.3,
                                                      ),
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: rememberMe
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
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: pureBlack.withOpacity(0.8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Get.toNamed(
                                        RouteHelper.getSendOtpScreen(),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(50, 30),
                                      ),
                                      child: Text(
                                        'forgot_password?'.tr,
                                        style: TextStyle(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: primaryGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                // Sign in button (gradient)
                                _primaryButton(
                                  text: 'sign_in'.tr,
                                  isLoading: isLoading,
                                  isEnabled: _captchaVerified,
                                  onPressed: () => _login(authController),
                                ),

                                /*   if (!_captchaVerified) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Complete the security check to continue',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ], */

                                // Registration block (kept)
                                if (Get.find<SplashController>()
                                        .configModel
                                        .content
                                        ?.providerSelfRegistration ==
                                    1) ...[
                                  const SizedBox(height: 14),
                                  Center(
                                    child: Text(
                                      "or".tr,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: pureBlack.withOpacity(0.5),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  //  const SizedBox(height: 8),
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'do_not_have_an_account'.tr,
                                          style: TextStyle(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: pureBlack.withOpacity(0.7),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Get.toNamed(RouteHelper.signUp),
                                          child: Text(
                                            'register_here'.tr,
                                            style: const TextStyle(
                                              color: primaryGreen,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 18),

                                // Switch card
                                _buildBrandFanSwitchCard(),

                                const SizedBox(height: 10),
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
          ],
        ),
      ),
    );
  }

  // ───────────────────────── UI helpers ─────────────────────────

  Widget _fieldWrap({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: pureWhite.withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
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

  Widget _buildBrandFanSwitchCard() {
    return Container(
      decoration: BoxDecoration(
        color: lightGreen.withOpacity(0.30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryGreen.withOpacity(0.20), width: 1),
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
                    color: primaryGreen.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.business_center_rounded,
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
                        'Are you a Brand or Fan?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: pureBlack.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Switch to the Brand & Fan app to continue.',
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
              onPressed: () => _switchToBrand(),
              icon: const Icon(
                Icons.swap_horiz_rounded,
                size: 20,
                color: primaryGreen,
              ),
              label: const Text(
                'Switch to Brand & Fan App',
                style: TextStyle(
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

  // ───────────────────────── logic (same as yours) ─────────────────────────

  void _initializeController() {
    final authController = Get.find<AuthController>();

    final phoneWithoutCountryCode = ValidationHelper.getValidPhone(
      Get.find<AuthController>().getUserNumber(),
    );
    final countryCode = ValidationHelper.getCountryCode(
      Get.find<AuthController>().getUserNumber(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (countryCode != "" && phoneWithoutCountryCode != "") {
        authController.toggleIsNumberLogin(value: true);
      } else {
        authController.toggleIsNumberLogin(value: false);
      }
      authController.initCountryCode(
        countryCode: countryCode != "" ? countryCode : null,
      );
    });

    _emailController.text = phoneWithoutCountryCode != ""
        ? phoneWithoutCountryCode
        : authController.isNumberLogin
        ? ""
        : Get.find<AuthController>().getUserNumber();

    _passwordController.text = Get.find<AuthController>().getUserPassword();
  }

  void _login(AuthController authController) async {
    if (!signInFormKey.currentState!.validate()) {
      return;
    }

    if (!_captchaController.isVerified || !_captchaVerified) {
      showCustomSnackBar(
        'Please complete the security verification',
        type: ToasterMessageType.info,
      );
      return;
    }

    final phone = ValidationHelper.getValidPhone(
      authController.countryDialCode + _emailController.text.trim(),
      withCountryCode: true,
    );

    await authController.login(
      phone != "" ? phone : _emailController.text.trim(),
      _passwordController.text.trim(),
      phone != "" ? "phone" : "email",
    );
  }

  Future<void> _switchToBrand() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_mode');
    Get.reset();
    runApp(const PortalApp());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WhatsApp-like FontAwesome pattern background (fixed, full screen)
// ─────────────────────────────────────────────────────────────────────────────

class _AuthFaPatternBackground extends StatelessWidget {
  const _AuthFaPatternBackground();

  static const Color _kGreen = Color(0xFF045F25);

  // Base + bloom
  static const double _bloomOpacity = 0.14;
  static const double _bloomRadius = 2.45;

  // Pattern tuning
  static const double _patternOpacity = 0.075; // 0.06–0.10
  static const double _tile = 74; // 64–86 (smaller = denser)
  static const int _seed = 13;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Soft base
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF6FAF7), Color(0xFFFFFFFF)],
            ),
          ),
        ),

        // Bloom
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.95),
                radius: _bloomRadius,
                colors: [
                  _kGreen.withOpacity(_bloomOpacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Pattern
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _FaOnlyPatternPainter(
                icons: const <FaIconData>[
                  FontAwesomeIcons.futbol,
                  FontAwesomeIcons.basketball,
                  FontAwesomeIcons.volleyball,
                  FontAwesomeIcons.baseball,
                  FontAwesomeIcons.tableTennisPaddleBall,
                  FontAwesomeIcons.personRunning,
                  FontAwesomeIcons.personBiking,
                  FontAwesomeIcons.dumbbell,
                  FontAwesomeIcons.stopwatch,
                  FontAwesomeIcons.trophy,
                  FontAwesomeIcons.medal,
                ],
                color: _kGreen,
                opacity: _patternOpacity,
                tile: _tile,
                seed: _seed,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FaOnlyPatternPainter extends CustomPainter {
  final List<FaIconData> icons;
  final Color color;
  final double opacity;
  final double tile;
  final int seed;

  const _FaOnlyPatternPainter({
    required this.icons,
    required this.color,
    required this.opacity,
    required this.tile,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed);

    const sizesMain = <double>[16, 18, 20, 22, 24, 26];
    const sizesSmall = <double>[12, 14, 16, 18];

    for (double y = -tile; y < size.height + tile; y += tile) {
      final row = (y / tile).round();
      final rowShift = row.isEven ? tile * 0.35 : 0.0;

      for (double x = -tile; x < size.width + tile; x += tile) {
        _drawFa(
          canvas: canvas,
          rnd: rnd,
          icon: icons[rnd.nextInt(icons.length)],
          origin: Offset(x + rowShift + tile / 2, y + tile / 2),
          size: sizesMain[rnd.nextInt(sizesMain.length)],
          opacityScale: 1.0,
        );

        if (rnd.nextDouble() < 0.55) {
          _drawFa(
            canvas: canvas,
            rnd: rnd,
            icon: icons[rnd.nextInt(icons.length)],
            origin: Offset(
              x + rowShift + tile * (0.25 + rnd.nextDouble() * 0.5),
              y + tile * (0.25 + rnd.nextDouble() * 0.5),
            ),
            size: sizesSmall[rnd.nextInt(sizesSmall.length)],
            opacityScale: 0.85,
          );
        }
      }
    }
  }

  void _drawFa({
    required Canvas canvas,
    required Random rnd,
    required FaIconData icon,
    required Offset origin,
    required double size,
    required double opacityScale,
  }) {
    final angle = (rnd.nextDouble() - 0.5) * 0.55;
    final jitter = Offset(
      (rnd.nextDouble() - 0.5) * 10,
      (rnd.nextDouble() - 0.5) * 10,
    );

    final alpha = (opacity * opacityScale) * (0.75 + rnd.nextDouble() * 0.5);

    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          color: color.withOpacity(alpha.clamp(0.0, 1.0)),
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
    )..layout();

    canvas.save();
    canvas.translate(origin.dx + jitter.dx, origin.dy + jitter.dy);
    canvas.rotate(angle);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FaOnlyPatternPainter old) {
    return old.opacity != opacity ||
        old.tile != tile ||
        old.color != color ||
        old.seed != seed ||
        old.icons != icons;
  }
}
