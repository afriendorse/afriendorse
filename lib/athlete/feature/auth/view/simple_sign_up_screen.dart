import 'package:afriendorse/athlete/feature/auth/binding/sports_service.dart';
import 'package:afriendorse/athlete/feature/auth/repository/athlete_firestore_sync_service.dart';
import 'package:afriendorse/athlete/feature/auth/repository/welcome_push_notification_service.dart';
import 'package:afriendorse/athlete/feature/auth/widgets/auth_pattern_background.dart';
import 'package:afriendorse/athlete/feature/captcha/app_captcha_widget.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/feature/referral/repository/referral_tracking_service.dart';
import 'package:afriendorse/feature/referral/repository/user_referral_code_service.dart';
import 'package:get/get.dart';

const Color _kGreen = Color(0xFF045F25);
const Color _kDarkGreen = Color(0xFF033D18);

enum _SimpleStep { step1, step2 }

class SimpleSignUpController extends GetxController {
  final AuthRepo authRepo;
  SimpleSignUpController({required this.authRepo});

  _SimpleStep currentStep = _SimpleStep.step1;
  bool isLoading = false;

  List<SportModel> sportsList = [];
  String selectedSportId = '';
  bool isSportValid = true;

  List<ZoneData> zoneList = [];
  String selectedZoneId = '';
  String selectedZoneName = '';
  bool isZoneValid = true;

  BusinessPlanType? selectedBusinessPlan;
  SubscriptionPackage? selectedSubscriptionPackage;
  SubscriptionPaymentType? selectedPaymentType;
  int selectedDigitalPaymentIndex = -1;

  final referCodeController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String countryDialCode = '+234';

  @override
  void onInit() {
    super.onInit();
    _loadSports();
    _loadZones();
    _loadSubscriptionPackages();
    countryDialCode =
        CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel.content?.countryCode ?? 'NG',
        ).dialCode ??
        '+234';
  }

  Future<void> _loadSports() async {
    sportsList = await SportsService.getSports();
    update();
  }

  Future<void> _loadZones() async {
    final response = await authRepo.getZonesDataList();
    if (response?.statusCode == 200) {
      zoneList = [];
      response!.body['content']['data'].forEach((e) {
        zoneList.add(ZoneData.fromJson(e));
      });
      update();
    }
  }

  Future<void> _handleReferralOnSignup({
    required String userEmail,
    required String userType,
    required String firstName,
    String? referralCode,
  }) async {
    try {
      await UserReferralCodeService.getOrCreateReferralCode(
        email: userEmail,
        userType: userType,
        firstName: firstName,
      );

      if (referralCode != null && referralCode.trim().isNotEmpty) {
        final tracked = await ReferralTrackingService.trackReferral(
          referralCode: referralCode.trim(),
          refereeEmail: userEmail,
          refereeType: userType,
        );

        if (tracked != null) {
          // ✅ Small delay to let Firestore propagate the pending write
          await Future.delayed(const Duration(milliseconds: 800));

          // Athlete path
          await AthleteFirestoreSyncService.completeAthleteReferralIfExists(
            userEmail,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error handling referral: $e');
    }
  }

  Future<void> _loadSubscriptionPackages() async {
    await Get.find<BusinessSubscriptionController>()
        .getSubscriptionPackageList();
    final packages =
        Get.find<BusinessSubscriptionController>()
            .packageSubscriptionModel
            ?.subscriptionPackages ??
        [];
    if (packages.isNotEmpty) {
      selectedSubscriptionPackage = packages.first;
    }
    update();
  }

  void setSport(String id) {
    selectedSportId = id;
    isSportValid = true;
    update();
  }

  void setZone(ZoneData zone) {
    selectedZoneId = zone.id ?? '';
    selectedZoneName = zone.name ?? '';
    isZoneValid = true;
    update();
  }

  void setBusinessPlan(BusinessPlanType type) {
    selectedBusinessPlan = type;
    update();
  }

  void setSubscriptionPackage(SubscriptionPackage pkg) {
    selectedSubscriptionPackage = pkg;
    update();
  }

  void setPaymentType(SubscriptionPaymentType type) {
    selectedPaymentType = type;
    if (type != SubscriptionPaymentType.digital) {
      selectedDigitalPaymentIndex = -1;
    }
    update();
  }

  void setDigitalPaymentIndex(int index) {
    selectedDigitalPaymentIndex = index;
    update();
  }

  void goToStep2() {
    currentStep = _SimpleStep.step2;
    update();
  }

  void goToStep1() {
    currentStep = _SimpleStep.step1;
    update();
  }

  SignUpBody _buildSignUpBody() {
    final firstName = firstNameController.text.trim();
    const lastName = 'N/A';
    final fullName = firstName;
    final email = emailController.text.trim();

    final fullPhone = '${countryDialCode}0000000000';

    DigitalPaymentMethod? paymentMethod;
    if (selectedDigitalPaymentIndex != -1 &&
        selectedBusinessPlan == BusinessPlanType.subscriptionBase) {
      final list =
          Get.find<SplashController>().configModel.content?.paymentMethodList ??
          [];
      if (selectedDigitalPaymentIndex < list.length) {
        paymentMethod = list[selectedDigitalPaymentIndex];
      }
    }

    return SignUpBody(
      companyName: fullName,
      companyEmail: email,
      companyPhone: fullPhone,
      companyAddress: 'N/A',
      contactPersonName: fullName,
      contactPersonEmail: email,
      contactPersonPhone: fullPhone,
      accountEmail: email,
      accountPhone: fullPhone,
      accountFirstName: firstName,
      accountLastName: lastName,
      password: passwordController.text,
      confirmedPassword: confirmPasswordController.text,
      zoneId: selectedZoneId,
      lat: '${Get.find<LocationController>().pickPosition.latitude}',
      lon: '${Get.find<LocationController>().pickPosition.longitude}',
      fieldOfSport: selectedSportId,
      chooseBusinessPlan:
          selectedBusinessPlan == BusinessPlanType.commissionBase
          ? 'commission_base'
          : 'subscription_base',
      subscriptionPackageId: selectedSubscriptionPackage?.id,
      paymentMethod: paymentMethod?.gateway,
      freeTrialOrPayment:
          selectedBusinessPlan == BusinessPlanType.commissionBase
          ? 'free_trial'
          : selectedPaymentType == SubscriptionPaymentType.freeTrail
          ? 'free_trial'
          : 'payment',
      paymentPlatform: 'app',
      identityType: 'passport',
      identityNumber: '000000',
      referCode: referCodeController.text.trim().isNotEmpty
          ? referCodeController.text.trim()
          : null,
    );
  }

  Future<void> register() async {
    isLoading = true;
    update();

    final signUpBody = _buildSignUpBody();
    final email = emailController.text.trim().toLowerCase();

    try {
      final placeholderImage = await _createPlaceholderImage();

      final identityImagePlaceholder = MultipartBody(
        'identity_images[]',
        placeholderImage,
      );

      final response = await authRepo.registration(
        signUpBody: signUpBody,
        identityImage: [identityImagePlaceholder],
        profileImage: placeholderImage,
        coverImage: placeholderImage,
      );

      if (response == null) {
        showCustomSnackBar('connection_error_please_try_again'.tr);
        isLoading = false;
        update();
        return;
      }

      if (response.statusCode == 200 &&
          response.body['response_code'] == 'provider_store_200') {
        // ✅ SYNC TO FIRESTORE (with FCM token)
        if (email.isNotEmpty && selectedSportId.isNotEmpty) {
          try {
            final fcmToken = await FirebaseMessaging.instance.getToken();

            await AthleteFirestoreSyncService.syncAthleteToFirestore(
              userId: email,
              email: email,
              phone: signUpBody.accountPhone,
              firstName: firstNameController.text.trim(),
              lastName: lastNameController.text.trim(),
              companyName: signUpBody.companyName ?? '',
              fieldOfSport: selectedSportId,
              fcmToken: fcmToken,
            );
          } catch (e) {
            if (kDebugMode) print('❌ Firestore sync error: $e');
          }
        }

        // ⭐⭐⭐ HANDLE REFERRAL SYSTEM ⭐⭐⭐
        await _handleReferralOnSignup(
          userEmail: email,
          userType: 'athlete',
          firstName: firstNameController.text.trim(),
          referralCode: referCodeController.text.trim(),
        );

        // ⭐⭐⭐ NEW: SEND WELCOME PUSH NOTIFICATION VIA CLOUD FUNCTION ⭐⭐⭐
        if (email.isNotEmpty) {
          try {
            final pushSent =
                await WelcomePushNotificationService.sendWelcomePush(
                  email: email,
                  firstName: firstNameController.text.trim(),
                  fieldOfSport: selectedSportId,
                );

            if (kDebugMode) {
              print(
                pushSent
                    ? '✅ Welcome push notification sent via Cloud Function'
                    : '⚠️ Welcome push notification failed (non-fatal)',
              );
            }
          } catch (e) {
            if (kDebugMode) print('❌ Welcome push error (non-fatal): $e');
          }
        }

        final config = Get.find<SplashController>().configModel.content;

        if (response.body['content'] != null) {
          _reset();
          Get.to(
            () => PaymentScreen(
              url: response.body['content'],
              fromPage: 'signUp',
            ),
          );
        } else if (config?.emailVerification == 1 ||
            config?.phoneVerification == 1) {
          final identity = config?.phoneVerification == 1
              ? signUpBody.accountPhone!.trim()
              : email;
          final identityType = config?.phoneVerification == 1
              ? 'phone'
              : 'email';
          final otpType =
              (config?.phoneVerification == 1 &&
                  config?.firebaseOtpVerification == 1)
              ? SendOtpType.firebase
              : SendOtpType.verification;

          final status = await Get.find<AuthController>().sendVerificationCode(
            identity: identity,
            identityType: identityType,
            type: otpType,
            fromPage: 'verification',
          );

          if (status != null) {
            if (status.isSuccess!) {
              Get.toNamed(
                RouteHelper.getVerificationRoute(
                  identity: identity,
                  identityType: identityType,
                  fromPage: 'verification',
                  firebaseSession: otpType == SendOtpType.firebase
                      ? status.message
                      : null,
                  showSignUpDialog: true,
                ),
              );
            } else {
              Get.offNamed(RouteHelper.signIn);
              showCustomSnackBar(status.message.toString().capitalizeFirst);
            }
          }
          _reset();
        } else {
          _reset();
          Get.offNamed(RouteHelper.signIn);
          showCustomBottomSheet(
            child: const WelcomeBottomSheet(fromSignup: true),
          );
        }
      } else if (response.statusCode == 400 &&
          response.body['response_code'] == 'default_400') {
        final errors = response.body['errors'];
        String message = 'something_went_wrong'.tr;
        if (errors is List && errors.isNotEmpty) {
          message = errors[0]['message']?.toString() ?? message;
        } else if (errors is Map && errors.isNotEmpty) {
          message = errors.values.first?.toString() ?? message;
        }
        showCustomSnackBar(message);
      } else {
        showCustomSnackBar(
          response.body['message']?.toString() ?? response.statusText ?? '',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ SimpleSignUp register error: $e');
        print('📍 StackTrace: $stackTrace');
      }
      showCustomSnackBar('connection_error_please_try_again'.tr);
    }

    isLoading = false;
    update();
  }

  void _reset() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    referCodeController.clear();
    selectedSportId = '';
    selectedZoneId = '';
    selectedZoneName = '';
    selectedBusinessPlan = null;
    selectedSubscriptionPackage = null;
    selectedPaymentType = null;
    selectedDigitalPaymentIndex = -1;
    currentStep = _SimpleStep.step1;
  }

  Future<XFile> _createPlaceholderImage() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/placeholder.png');

    final byteData = await rootBundle.load('assets/images/default_athlete.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    return XFile(file.path);
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    referCodeController.dispose();
    super.onClose();
  }
}

class SimpleSignUpScreen extends StatefulWidget {
  const SimpleSignUpScreen({super.key});

  @override
  State<SimpleSignUpScreen> createState() => _SimpleSignUpScreenState();
}

class _SimpleSignUpScreenState extends State<SimpleSignUpScreen> {
  final _step1Key = GlobalKey<FormState>();
  late final SimpleSignUpController _ctrl;
  final AppCaptchaController _captchaController = AppCaptchaController();
  bool _captchaVerified = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(
      SimpleSignUpController(authRepo: Get.find<AuthController>().authRepo),
    );
    Get.find<SplashController>().getConfigData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _SimpleSignUpAppBar(ctrl: _ctrl),
      body: Stack(
        children: [
          const Positioned.fill(child: AuthFaPatternBackground(formMode: true)),
          SafeArea(
            bottom: GetPlatform.isIOS,
            child: GetBuilder<SimpleSignUpController>(
              builder: (ctrl) => Column(
                children: [
                  Expanded(
                    child: ctrl.currentStep == _SimpleStep.step1
                        ? _Step1Body(ctrl: ctrl, formKey: _step1Key)
                        : _Step2Body(
                            ctrl: ctrl,
                            captchaController: _captchaController,
                            onCaptchaChanged: (verified) {
                              setState(() {
                                _captchaVerified = verified;
                              });
                            },
                          ),
                  ),
                  _BottomBar(
                    ctrl: ctrl,
                    step1Key: _step1Key,
                    captchaController: _captchaController,
                    captchaVerified: _captchaVerified,
                  ),
                  SizedBox(
                    height: GetPlatform.isIOS ? 0 : Dimensions.paddingSizeSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleSignUpAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final SimpleSignUpController ctrl;
  const _SimpleSignUpAppBar({required this.ctrl});

  @override
  Size get preferredSize =>
      const Size(double.maxFinite, Dimensions.signUpAppbarHeight);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimpleSignUpController>(
      builder: (c) {
        final step = c.currentStep == _SimpleStep.step1 ? 1 : 2;
        final title = step == 1 ? 'Your Details' : 'Choose Plan';

        return AppBar(
          elevation: 5,
          titleSpacing: 0,
          backgroundColor: Theme.of(context).cardColor,
          surfaceTintColor: Theme.of(context).cardColor,
          shadowColor: _kGreen.withOpacity(0.1),
          centerTitle: false,
          toolbarHeight: Dimensions.signUpAppbarHeight,
          title: Text(
            title,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              if (c.currentStep == _SimpleStep.step1) {
                Get.back();
              } else {
                c.goToStep1();
              }
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).primaryColorLight,
              size: 20,
            ),
          ),
          actions: [
            const SizedBox(width: 20),
            TweenAnimationBuilder(
              tween: Tween<double>(
                begin: step == 1 ? 0.0 : 0.5,
                end: step == 1 ? 0.5 : 1.0,
              ),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, _) => Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: Dimensions.signUpAppbarHeight * 0.62,
                    width: Dimensions.signUpAppbarHeight * 0.62,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: Dimensions.signUpAppbarHeight * 0.06,
                      backgroundColor: Theme.of(
                        context,
                      ).hintColor.withOpacity(0.2),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.signUpAppbarHeight * 0.4,
                    width: Dimensions.signUpAppbarHeight * 0.4,
                    child: FittedBox(
                      child: Text(
                        '$step of 2',
                        style: robotoBold.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
          ],
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  final SimpleSignUpController ctrl;
  final GlobalKey<FormState> step1Key;
  final AppCaptchaController captchaController;
  final bool captchaVerified;

  const _BottomBar({
    required this.ctrl,
    required this.step1Key,
    required this.captchaController,
    required this.captchaVerified,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimpleSignUpController>(
      builder: (c) {
        final isStep2 = c.currentStep == _SimpleStep.step2;
        final bool isConfirmEnabled = !isStep2 || captchaVerified;
        final bool canTap = !c.isLoading && isConfirmEnabled;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kGreen.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: _kGreen.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isStep2) ...[
                SizedBox(
                  height: 44,
                  width: 100,
                  child: OutlinedButton(
                    onPressed: c.goToStep1,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _kGreen.withOpacity(0.4),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: _kGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 44,
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: canTap
                      ? const LinearGradient(
                          colors: [_kGreen, _kDarkGreen],
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
                          ? _kGreen.withOpacity(0.30)
                          : Colors.grey.withOpacity(0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: canTap
                        ? () => isStep2
                              ? _onConfirm(c, captchaController)
                              : _onNext(c)
                        : null,
                    child: Center(
                      child: c.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isStep2 ? 'Confirm' : 'Next',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(
                                      canTap ? 1 : 0.9,
                                    ),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (!isStep2) ...[
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onNext(SimpleSignUpController c) {
    bool valid = true;

    if (c.selectedSportId.isEmpty) {
      c.isSportValid = false;
      valid = false;
    }
    if (c.selectedZoneId.isEmpty) {
      c.isZoneValid = false;
      valid = false;
    }
    c.update();

    if (step1Key.currentState!.validate() && valid) {
      c.goToStep2();
    }
  }

  void _onConfirm(
    SimpleSignUpController c,
    AppCaptchaController captchaController,
  ) {
    if (!captchaController.isVerified) {
      showCustomSnackBar(
        'Please complete the security verification',
        type: ToasterMessageType.info,
      );
      return;
    }

    if (c.selectedBusinessPlan == null) {
      showCustomSnackBar(
        'choose_business_plan'.tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    if (c.selectedBusinessPlan == BusinessPlanType.commissionBase) {
      c.register();
      return;
    }

    if (c.selectedSubscriptionPackage == null) {
      showCustomSnackBar(
        'no_subscription_plan_available_at_this_moment'.tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    if (c.selectedPaymentType == null) {
      showCustomSnackBar(
        'free_trail_hint_text'.tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    if (c.selectedPaymentType == SubscriptionPaymentType.digital &&
        c.selectedDigitalPaymentIndex == -1) {
      showCustomSnackBar(
        'select_payment_method'.tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    c.register();
  }
}

class _Step1Body extends StatefulWidget {
  final SimpleSignUpController ctrl;
  final GlobalKey<FormState> formKey;
  const _Step1Body({required this.ctrl, required this.formKey});

  @override
  State<_Step1Body> createState() => _Step1BodyState();
}

class _Step1BodyState extends State<_Step1Body> {
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: GetBuilder<SimpleSignUpController>(
        builder: (c) => Form(
          key: widget.formKey,
          child: _SCard(
            marginTop: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SHeader(
                  icon: Icons.person_outline_rounded,
                  label: 'Your Details',
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  controller: c.firstNameController,
                  title: 'Athlete Name',
                  hintText: 'Enter athlete name',
                  inputType: TextInputType.name,
                  focusNode: _firstNameFocus,
                  nextFocus: _lastNameFocus,
                  capitalization: TextCapitalization.words,
                  isShowBorder: true,
                  borderRadius: 12,
                  fillColor: Colors.white,
                  onValidate: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter your first name'
                      : null,
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  controller: c.emailController,
                  title: 'Email Address',
                  hintText: 'your@email.com',
                  inputType: TextInputType.emailAddress,
                  focusNode: _emailFocus,
                  nextFocus: _phoneFocus,
                  isShowBorder: true,
                  borderRadius: 12,
                  fillColor: Colors.white,
                  onValidate: (v) {
                    if (v == null || v.isEmpty) return 'Enter your email';
                    return FormValidationHelper().isValidEmail(v);
                  },
                ),
                const SizedBox(height: 14),

                const _FieldLabel(label: 'Field of Sport', required: true),
                const SizedBox(height: 6),
                _SportDropdown(ctrl: c),
                const SizedBox(height: 14),

                const _FieldLabel(label: 'Select Zone', required: true),
                const SizedBox(height: 6),
                _ZoneDropdown(ctrl: c),
                const SizedBox(height: 14),

                CustomTextField(
                  controller: c.passwordController,
                  title: 'Password',
                  hintText: '••••••••',
                  isPassword: true,
                  isShowSuffixIcon: true,
                  inputType: TextInputType.visiblePassword,
                  focusNode: _passwordFocus,
                  nextFocus: _confirmFocus,
                  isShowBorder: true,
                  borderRadius: 12,
                  fillColor: Colors.white,
                  onValidate: (v) => (v == null || v.isEmpty)
                      ? 'Enter a password'
                      : v.length < 8
                      ? 'password_should_be'.tr
                      : null,
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  controller: c.confirmPasswordController,
                  title: 'Confirm Password',
                  hintText: '••••••••',
                  isPassword: true,
                  isShowSuffixIcon: true,
                  inputType: TextInputType.visiblePassword,
                  focusNode: _confirmFocus,
                  inputAction: TextInputAction.done,
                  isShowBorder: true,
                  borderRadius: 12,
                  fillColor: Colors.white,
                  onValidate: (v) => (v == null || v.isEmpty)
                      ? 'Confirm your password'
                      : v != c.passwordController.text
                      ? 'confirm_password_does_not_matched'.tr
                      : null,
                ),

                const SizedBox(height: 14),

                CustomTextField(
                  controller: c.referCodeController,
                  title: 'Referral Code (Optional)',
                  hintText: 'Enter referral code',
                  inputType: TextInputType.text,
                  inputAction: TextInputAction.done,
                  isShowBorder: true,
                  borderRadius: 12,
                  fillColor: Colors.white,
                  isRequired: false,
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step2Body extends StatefulWidget {
  final SimpleSignUpController ctrl;
  final AppCaptchaController captchaController;
  final ValueChanged<bool> onCaptchaChanged;

  const _Step2Body({
    required this.ctrl,
    required this.captchaController,
    required this.onCaptchaChanged,
  });

  @override
  State<_Step2Body> createState() => _Step2BodyState();
}

class _Step2BodyState extends State<_Step2Body> {
  List<SubscriptionPackage> get _packages =>
      Get.find<BusinessSubscriptionController>()
          .packageSubscriptionModel
          ?.subscriptionPackages
          ?.where((p) => p.id != '0')
          .toList() ??
      [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      child: GetBuilder<SimpleSignUpController>(
        builder: (c) => GetBuilder<SplashController>(
          builder: (splash) {
            final config = splash.configModel.content;
            final hasCommission = config?.commissionBasePlan == 1;
            final hasSubscription = config?.subscriptionBasePlan == 1;
            final hasFreeTrail = config?.subscriptionFreeTrail == 1;
            final hasDigital = config?.digitalPayment == 1;
            final trialType = config?.subscriptionFreeTrailType ?? 'day';
            final trialPeriod = config?.subscriptionFreeTrailPeriod ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                _SCard(
                  marginTop: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SHeader(
                        icon: Icons.business_center_outlined,
                        label: 'Choose Your Plan',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'business_plan_hint_text'.tr,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                if (hasCommission || !hasSubscription)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: BusinessPlanCard(
                      icon: Images.commissionIcon,
                      title: 'commission_base',
                      subtitle:
                          '${'with_this_you_pay'.tr} '
                          '${config?.defaultCommission ?? ''}% '
                          '${'commission_on_every_service_you_provide'.tr}',
                      isSelected:
                          c.selectedBusinessPlan ==
                          BusinessPlanType.commissionBase,
                      onTap: () =>
                          c.setBusinessPlan(BusinessPlanType.commissionBase),
                    ),
                  ),

                if (hasCommission && hasSubscription)
                  const SizedBox(height: 12),

                if (hasSubscription) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: BusinessPlanCard(
                      icon: Images.subscriptionIcon,
                      title: 'subscription_base',
                      subtitle:
                          'just_select_plan_and_pay_subscription_fee_and_business_with_us',
                      isSelected:
                          c.selectedBusinessPlan ==
                          BusinessPlanType.subscriptionBase,
                      onTap: () =>
                          c.setBusinessPlan(BusinessPlanType.subscriptionBase),
                    ),
                  ),

                  if (c.selectedBusinessPlan ==
                      BusinessPlanType.subscriptionBase) ...[
                    const SizedBox(height: 14),

                    if (_packages.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'select_plan'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          itemCount: _packages.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final pkg = _packages[i];
                            return GestureDetector(
                              onTap: () => c.setSubscriptionPackage(pkg),
                              child: SubscriptionItemCard(
                                isSelected:
                                    c.selectedSubscriptionPackage?.id == pkg.id,
                                selectedPackage: pkg,
                                scrollController: null,
                              ),
                            );
                          },
                        ),
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'no_subscription_plan_available_at_this_moment'.tr,
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ),

                    if (hasFreeTrail || hasDigital) ...[
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'Payment Method',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (hasFreeTrail)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: BusinessPlanCard(
                            title:
                                '$trialPeriod '
                                '${_trialLabel(trialType, trialPeriod)} '
                                '${'free_trail'.tr}',
                            subtitle: 'trial_end_hint_text'.tr,
                            isSelected:
                                c.selectedPaymentType ==
                                SubscriptionPaymentType.freeTrail,
                            cardColor:
                                c.selectedPaymentType ==
                                    SubscriptionPaymentType.freeTrail
                                ? _kGreen.withOpacity(0.05)
                                : null,
                            onTap: () => c.setPaymentType(
                              SubscriptionPaymentType.freeTrail,
                            ),
                          ),
                        ),

                      if (hasFreeTrail && hasDigital)
                        const SizedBox(height: 10),

                      if (hasDigital) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: BusinessPlanCard(
                            title: 'pay_via_online',
                            subtitle:
                                '${'faster_and_secure_way_to_pay_and_grow_your_business_with'.tr} ${AppConstants.appName}',
                            isSelected:
                                c.selectedPaymentType ==
                                SubscriptionPaymentType.digital,
                            cardColor:
                                c.selectedPaymentType ==
                                    SubscriptionPaymentType.digital
                                ? _kGreen.withOpacity(0.05)
                                : null,
                            onTap: () => c.setPaymentType(
                              SubscriptionPaymentType.digital,
                            ),
                          ),
                        ),

                        if (c.selectedPaymentType ==
                            SubscriptionPaymentType.digital)
                          _DigitalPaymentList(ctrl: c),
                      ],
                    ],
                  ],
                ],

                const SizedBox(height: 250),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: AppCaptchaWidget(
                    controller: widget.captchaController,
                    title: 'Verify you are a human',
                    hintText: 'Answer',
                    onVerifiedChanged: widget.onCaptchaChanged,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  String _trialLabel(String type, int period) {
    if (type == 'day') return period > 1 ? 'days'.tr : 'day'.tr;
    if (type == 'month') return period > 1 ? 'months'.tr : 'month'.tr;
    return '';
  }
}

class _DigitalPaymentList extends StatelessWidget {
  final SimpleSignUpController ctrl;
  const _DigitalPaymentList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final methods =
        Get.find<SplashController>().configModel.content?.paymentMethodList ??
        [];

    return Column(
      children: List.generate(methods.length, (i) {
        return Stack(
          children: [
            DigitalPaymentButtonWidget(
              isSelected: ctrl.selectedDigitalPaymentIndex == i,
              paymentMethod: methods[i],
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeSmall,
                ),
                child: CustomInkWell(
                  onTap: () => ctrl.setDigitalPaymentIndex(i),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SCard extends StatelessWidget {
  final Widget child;
  final double marginTop;
  const _SCard({required this.child, this.marginTop = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(14, marginTop, 14, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.93),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGreen.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kGreen, _kDarkGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return TextFieldTitle(
      title: label,
      requiredMark: required,
      isPadding: false,
      fontSize: Dimensions.fontSizeSmall,
    );
  }
}

class _SportDropdown extends StatelessWidget {
  final SimpleSignUpController ctrl;
  const _SportDropdown({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ctrl.isSportValid
                  ? _kGreen.withOpacity(0.25)
                  : Theme.of(context).colorScheme.error,
              width: 1.2,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              menuMaxHeight: Get.height * 0.40,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              isExpanded: true,
              hint: Text(
                ctrl.selectedSportId.isEmpty
                    ? 'Select your sport'
                    : ctrl.sportsList
                          .firstWhere(
                            (s) => s.id == ctrl.selectedSportId,
                            orElse: () => SportModel(id: '', name: ''),
                          )
                          .name,
                style: TextStyle(
                  color: ctrl.selectedSportId.isEmpty
                      ? Colors.grey.shade500
                      : const Color(0xFF1A1A1A),
                  fontSize: 14,
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _kGreen,
              ),
              items: ctrl.sportsList
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Row(
                        children: [
                          Text(
                            s.icon ?? '',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            s.name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                if (id != null) ctrl.setSport(id);
              },
            ),
          ),
        ),
        if (!ctrl.isSportValid)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              'fill_required_field'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _ZoneDropdown extends StatelessWidget {
  final SimpleSignUpController ctrl;
  const _ZoneDropdown({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ctrl.isZoneValid
                  ? _kGreen.withOpacity(0.25)
                  : Theme.of(context).colorScheme.error,
              width: 1.2,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ZoneData>(
              menuMaxHeight: Get.height * 0.40,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              isExpanded: true,
              hint: Text(
                ctrl.selectedZoneName.isEmpty
                    ? 'Select your zone'
                    : ctrl.selectedZoneName,
                style: TextStyle(
                  color: ctrl.selectedZoneName.isEmpty
                      ? Colors.grey.shade500
                      : const Color(0xFF1A1A1A),
                  fontSize: 14,
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _kGreen,
              ),
              items: ctrl.zoneList
                  .map(
                    (z) => DropdownMenuItem(
                      value: z,
                      child: Text(
                        z.name ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (z) {
                if (z != null) ctrl.setZone(z);
              },
            ),
          ),
        ),
        if (!ctrl.isZoneValid)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              'fill_required_field'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
