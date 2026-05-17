import 'package:afriendorse/athlete/feature/auth/repository/athlete_firestore_sync_service.dart';
import 'package:afriendorse/athlete/feature/auth/repository/general_firebase_auth_sync_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/auth/repository/two_factor_service.dart';
import 'package:afriendorse/athlete/feature/auth/view/two_factor_verification_screen.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  AuthController({required this.authRepo});

  bool? _isLoading = false;
  final bool _notification = true;

  bool _isNumberLogin = false;
  bool get isNumberLogin => _isNumberLogin;

  bool? get isLoading => _isLoading;
  bool? get notification => _notification;

  bool? _isActiveRememberMe = false;
  bool? get isActiveRememberMe => _isActiveRememberMe;

  String _verificationCode = '';
  String get verificationCode => _verificationCode;

  bool _isWrongOtpSubmitted = false;
  bool get isWrongOtpSubmitted => _isWrongOtpSubmitted;

  bool _twoFactorEnabled = false;
  bool get twoFactorEnabled => _twoFactorEnabled;

  String? _pendingLoginToken;
  String? _pendingLoginEmail;

  var countryDialCode = "+880";

  Future<void> loadTwoFactorPreference({String? email}) async {
    if (email == null || email.trim().isEmpty) return;
    _twoFactorEnabled =
        await AthleteFirestoreSyncService.getTwoFactorPreference(
          email.trim().toLowerCase(),
        );
    update();
  }

  Future<void> toggleTwoFactor({
    required String email,
    required bool enabled,
  }) async {
    _isLoading = true;
    update();

    final success = await AthleteFirestoreSyncService.updateTwoFactorPreference(
      email: email.trim().toLowerCase(),
      enabled: enabled,
    );

    if (success) {
      _twoFactorEnabled = enabled;
      showCustomSnackBar(
        enabled
            ? 'Two-factor authentication enabled'
            : 'Two-factor authentication disabled',
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar('Failed to update two-factor preference');
    }

    _isLoading = false;
    update();
  }

  Future<void> verifyFirestoreTwoFactorCode({
    required String sessionId,
    required String code,
    required String email,
  }) async {
    _isLoading = true;
    update();

    final isValid = await TwoFactorService.verifyCode(
      sessionId: sessionId,
      code: code,
    );

    if (isValid) {
      if (isActiveRememberMe!) {
        authRepo.saveUserNumberAndPassword(email, '');
      }

      if (_pendingLoginToken != null && _pendingLoginToken!.isNotEmpty) {
        authRepo.saveUserToken(_pendingLoginToken!);
        await Get.find<UserProfileController>().getProviderInfo();
        await authRepo.updateToken();
        Get.offAllNamed(RouteHelper.initial);

        _pendingLoginToken = null;
        _pendingLoginEmail = null;

        showCustomSnackBar(
          "successfully_logged_in".tr,
          type: ToasterMessageType.success,
        );
      } else {
        showCustomSnackBar('Login session expired. Please login again.');
      }
    } else {
      showCustomSnackBar('Invalid or expired verification code');
    }

    _isLoading = false;
    update();
  }

  Future<void> resendFirestoreTwoFactorCode({
    required String sessionId,
    required String email,
  }) async {
    final newCode = await TwoFactorService.resendCode(sessionId: sessionId);

    if (newCode == null) {
      showCustomSnackBar('Unable to resend code');
      return;
    }

    final response = await authRepo.sendTwoFactorEmail(
      email: email,
      code: newCode,
    );

    if (response != null && response.statusCode == 200) {
      showCustomSnackBar(
        'Verification code resent',
        type: ToasterMessageType.success,
      );
    } else {
      String errorMessage = 'Failed to resend verification code';
      try {
        if (response?.body is Map && response?.body['message'] != null) {
          errorMessage = response!.body['message'].toString();
        } else if (response?.statusText != null) {
          errorMessage = response!.statusText.toString();
        } else if (response != null) {
          errorMessage = response.body.toString();
        }
      } catch (_) {}
      showCustomSnackBar(errorMessage);
    }
  }

  Future<void> login(String emailOrPhone, String password, String type) async {
    _isLoading = true;
    update();

    try {
      Response? response = await authRepo.login(
        emailOrPassword: emailOrPhone,
        password: password,
        type: type,
      );

      if (response == null) {
        showCustomSnackBar('connection_error_please_try_again'.tr);
        _isLoading = false;
        update();
        return;
      }

      final body = response.body;

      if (kDebugMode) {
        print('🔐 ===== LOGIN RESPONSE DEBUG =====');
        print('🔐 Status Code: ${response.statusCode}');
        print('🔐 Raw Body: ${response.body}');
        print('🔐 Raw Body String: ${response.bodyString}');
        print('🔐 ==================================');
      }

      if (body == null || body is! Map) {
        showCustomSnackBar('connection_error_please_try_again'.tr);
        _isLoading = false;
        update();
        return;
      }

      if (response.statusCode == 200 &&
          body['response_code'] == 'auth_login_200') {
        await _handleSuccessfulLogin(
          response: response,
          emailOrPhone: emailOrPhone,
          password: password,
          type: type,
        );
      } else if (response.statusCode == 200 &&
          body['response_code'] == 'provider_account_not_approved_401') {
        await _handleSuccessfulLogin(
          response: response,
          emailOrPhone: emailOrPhone,
          password: password,
          type: type,
          isUnderReview: true,
          reviewMessage: body['message']?.toString() ?? '',
        );
      } else if ((body['response_code'] == 'unverified_email_401' ||
              body['response_code'] == 'unverified_phone_401') &&
          response.statusCode == 401) {
        var config = Get.find<SplashController>().configModel.content;
        SendOtpType sendOtpType =
            (type == "phone" && config?.firebaseOtpVerification == 1)
            ? SendOtpType.firebase
            : SendOtpType.verification;

        await sendVerificationCode(
          identity: emailOrPhone,
          identityType: type,
          type: sendOtpType,
          fromPage: "verification",
        ).then((status) {
          if (status != null) {
            if (status.isSuccess!) {
              Get.toNamed(
                RouteHelper.getVerificationRoute(
                  identity: emailOrPhone,
                  identityType: type,
                  fromPage: "verification",
                  firebaseSession: sendOtpType == SendOtpType.firebase
                      ? status.message
                      : null,
                ),
              );
            } else {
              showCustomSnackBar(status.message.toString().capitalizeFirst);
            }
          }
        });

        _isLoading = false;
        update();
      } else if (response.statusCode == 401 &&
          body['response_code'] == "account_disabled_401") {
        showCustomSnackBar(
          icon: Images.userBlock,
          toasterTitle: 'account_blocked_notice'.tr,
          body['message']?.toString().capitalizeFirst ?? response.statusText,
        );
        _isLoading = false;
        update();
      } else {
        showCustomSnackBar(
          body['message']?.toString().capitalizeFirst ??
              'connection_error_please_try_again'.tr,
        );
        _isLoading = false;
        update();
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔐 LOGIN ERROR: $e');
      }
      showCustomSnackBar('connection_error_please_try_again'.tr);
      _isLoading = false;
      update();
    }
  }

  Future<void> _handleSuccessfulLogin({
    required Response response,
    required String emailOrPhone,
    required String password,
    required String type,
    bool isUnderReview = false,
    String reviewMessage = '',
  }) async {
    if (kDebugMode) {
      print('🔐 _handleSuccessfulLogin() — isUnderReview: $isUnderReview');
    }

    final String? mysqlAthleteId =
        response.body['content']?['id']?.toString() ??
        response.body['content']?['provider_id']?.toString();

    final String email =
        (response.body['content']?['email']?.toString() ?? emailOrPhone)
            .trim()
            .toLowerCase();

    if (kDebugMode) {
      print('🔐 Email resolved: $email');
      print('🔐 mysqlAthleteId: $mysqlAthleteId');
    }

    // ── Firestore sync ─────────────────────────────────────────────────────
    if (email.isNotEmpty) {
      try {
        final existingProfile =
            await AthleteFirestoreSyncService.getAthleteByEmail(email);

        if (kDebugMode) {
          print('🔐 Firestore profile exists: ${existingProfile != null}');
        }

        if (existingProfile == null) {
          if (kDebugMode) print('🔐 🆕 Creating Firestore profile for: $email');

          await AthleteFirestoreSyncService.syncAthleteToFirestore(
            userId: email,
            email: email,
            phone: response.body['content']?['phone']?.toString(),
            firstName:
                response.body['content']?['first_name']?.toString() ?? '',
            lastName: response.body['content']?['last_name']?.toString() ?? '',
            companyName:
                response.body['content']?['company_name']?.toString() ?? '',
            fieldOfSport:
                response.body['content']?['field_of_sport']?.toString() ??
                'General',
            mysqlAthleteId: mysqlAthleteId,
            fcmToken: null,
          );
        } else if (mysqlAthleteId != null) {
          if (kDebugMode) print('🔐 🔄 Updating mysqlAthleteId for: $email');

          await AthleteFirestoreSyncService.updateMysqlAthleteId(
            email,
            mysqlAthleteId,
          );
        }

        // Keep listing/profile fields fresh, but DO NOT touch verification badge
        if (mysqlAthleteId != null && mysqlAthleteId.isNotEmpty) {
          if (kDebugMode) {
            print(
              '🔐 📋 Upserting listing fields without modifying badge status',
            );
          }

          await AthleteFirestoreSyncService.upsertAthleteListingFields(
            email: email,
            mysqlAthleteId: mysqlAthleteId,
            phone: response.body['content']?['phone']?.toString(),
            companyName: response.body['content']?['company_name']?.toString(),
            fieldOfSport: response.body['content']?['field_of_sport']
                ?.toString(),
          );
        }
      } catch (e) {
        if (kDebugMode) print('🔐 ❌ Firestore sync error: $e');
        // Non-fatal — continue with login
      }
    }

    // ── 🔥 NEW: Firebase Auth sync ────────────────────────────────────────
    // This ensures FirebaseAuth.instance.currentUser?.email is always set
    // so deal approvals, OTP workflows etc. can read the athlete's email.
    if (email.isNotEmpty) {
      await FirebaseAuthSyncService.syncAfterLogin(email: email);
    }

    // ── 2FA check (skipped for under-review accounts if you still keep that flow) ──
    if (!isUnderReview && email.isNotEmpty) {
      if (kDebugMode) print('🔐 Checking 2FA preference for: $email');

      final bool twoFactorOn =
          await AthleteFirestoreSyncService.getTwoFactorPreference(email);

      if (kDebugMode) print('🔐 2FA enabled: $twoFactorOn');

      if (twoFactorOn) {
        if (kDebugMode) print('🔐 🔒 2FA required — creating session');

        final sessionId = await TwoFactorService.createSession(email: email);
        final code = await TwoFactorService.getSessionCode(sessionId);

        if (code == null) {
          if (kDebugMode) print('🔐 ❌ 2FA code generation failed');
          showCustomSnackBar('Failed to generate verification code');
          _isLoading = false;
          update();
          return;
        }

        final sendResponse = await authRepo.sendTwoFactorEmail(
          email: email,
          code: code,
        );

        if (kDebugMode) {
          print('🔐 2FA email send status: ${sendResponse?.statusCode}');
        }

        if (sendResponse == null || sendResponse.statusCode != 200) {
          if (kDebugMode) print('🔐 ❌ Failed to send 2FA email');
          showCustomSnackBar('Failed to send verification code');
          _isLoading = false;
          update();
          return;
        }

        _pendingLoginToken = response.body['content']['token'];
        _pendingLoginEmail = email;
        _isLoading = false;
        update();

        Get.to(
          () => TwoFactorVerificationScreen(sessionId: sessionId, email: email),
        );
        return;
      }
    }

    // ── Save credentials & complete login ─────────────────────────────────
    if (kDebugMode) print('🔐 💾 Saving token and completing login');

    if (isActiveRememberMe!) {
      authRepo.saveUserNumberAndPassword(emailOrPhone, password);
    } else {
      authRepo.clearUserNumberAndPassword();
    }

    authRepo.saveUserToken(response.body['content']['token']);

    if (kDebugMode) print('🔐 📡 Fetching provider info...');
    await Get.find<UserProfileController>().getProviderInfo();

    if (kDebugMode) print('🔐 📡 Updating FCM token...');
    await authRepo.updateToken();

    Get.offAllNamed(RouteHelper.initial);
    Get.find<SplashController>().updateLanguage(true);

    _isLoading = false;
    update();

    if (isUnderReview) {
      if (kDebugMode) print('🔐 ⏳ Showing under-review dialog');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUnderReviewDialog(reviewMessage);
      });
    } else {
      if (kDebugMode) print('🔐 ✅ Login complete — showing success snackbar');
      showCustomSnackBar(
        "successfully_logged_in".tr,
        type: ToasterMessageType.success,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Shared login success handler — used by both normal + under-review logins
  // ─────────────────────────────────────────────────────────────────────────────

  // ─────────────────────────────────────────────────────────────────────────────
  // Under-review dialog
  // ─────────────────────────────────────────────────────────────────────────────

  void _showUnderReviewDialog(String serverMessage) {
    if (Get.context == null) {
      if (kDebugMode) print('🔐 ⚠️ _showUnderReviewDialog: context is null');
      return;
    }

    Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.hourglass_bottom_rounded,
                  color: Color(0xFFF59E0B),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Account Under Review',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                serverMessage.isNotEmpty
                    ? serverMessage
                    : 'Your account is currently under review by our team.\n\n'
                          'While you wait, you can explore the app — but please note '
                          'that accepting deals, receiving bookings, and accessing '
                          'payout features will be unlocked once your account is approved.\n\n'
                          'This usually takes 24–48 hours. You will be notified via email as soon '
                          'as your account is verified and ready to go! 🎉',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF666666),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF045F25), Color(0xFF033D18)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Got it, thanks!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<ResponseModel?> sendVerificationCode({
    required String identity,
    required String identityType,
    required SendOtpType type,
    required String fromPage,
    bool resendOtp = false,
  }) async {
    ResponseModel? responseModel;
    if (type == SendOtpType.firebase) {
      await _sendOtpForFirebaseVerification(
        identity: identity,
        identityType: identityType,
        resendOtp: resendOtp,
        fromPage: fromPage,
      );
    } else if (type == SendOtpType.verification) {
      responseModel = await _sendOtpForVerificationScreen(
        identity,
        identityType,
      );
    } else {
      responseModel = await _sendOtpForForgetPassword(identity, identityType);
    }
    return responseModel;
  }

  Future<ResponseModel> _sendOtpForVerificationScreen(
    String identity,
    String identityType,
  ) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.sendOtpForVerificationScreen(
      identity,
      identityType,
    );

    if (response == null) {
      _isLoading = false;
      update();
      return ResponseModel(false, "connection_error_please_try_again".tr);
    }

    if (response.statusCode == 200 &&
        response.body["response_code"] == "default_200") {
      _isLoading = false;
      update();
      return ResponseModel(true, "");
    } else {
      _isLoading = false;
      update();

      String responseText = "";
      if (response.statusCode == 500) {
        responseText = "Internal Server Error";
      } else {
        responseText = response.body["message"] ?? response.statusText;
      }
      return ResponseModel(false, responseText);
    }
  }

  Future<ResponseModel> _sendOtpForForgetPassword(
    String identity,
    String identityType,
  ) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.sendOtpForForgetPassword(
      identity,
      identityType,
    );

    if (response == null) {
      _isLoading = false;
      update();
      return ResponseModel(false, "connection_error_please_try_again".tr);
    }

    if (response.statusCode == 200 &&
        response.body["response_code"] == "default_200") {
      _isLoading = false;
      update();
      return ResponseModel(true, "");
    } else {
      _isLoading = false;
      update();

      String responseText = "";
      if (response.statusCode == 500) {
        responseText = "Internal Server Error";
      } else {
        responseText = response.body["message"] ?? response.statusText;
      }
      return ResponseModel(false, responseText);
    }
  }

  Future<void> _sendOtpForFirebaseVerification({
    required String identity,
    required String identityType,
    required String fromPage,
    required bool resendOtp,
  }) async {
    _isLoading = true;
    update();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: identity,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        _isLoading = false;
        update();

        if (e.code == 'invalid-phone-number') {
          showCustomSnackBar(
            'please_submit_a_valid_phone_number',
            type: ToasterMessageType.info,
          );
        } else {
          showCustomSnackBar(
            '${e.message}'.replaceAll('_', ' ').capitalizeFirst,
          );
        }
      },
      codeSent: (String vId, int? resendToken) {
        _isLoading = false;
        update();
        if (!resendOtp) {
          Get.toNamed(
            RouteHelper.getVerificationRoute(
              identity: identity,
              identityType: identityType,
              fromPage: fromPage,
              firebaseSession: vId,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<ResponseModel> verifyOtpForVerificationScreen(
    String identity,
    String identityType,
    String otp,
  ) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.verifyOtpForVerificationScreen(
      identity,
      identityType,
      otp,
    );

    if (response == null) {
      _isLoading = false;
      update();
      return ResponseModel(false, "connection_error_please_try_again".tr);
    }

    ResponseModel responseModel;
    if (response.statusCode == 200 &&
        response.body['response_code'] == "default_200") {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = _checkWrongOtp(response);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> verifyOtpForForgetPasswordScreen(
    String identity,
    String identityType,
    String otp,
  ) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.verifyOtpForForgetPassword(
      identity,
      identityType,
      otp,
    );

    if (response == null) {
      _isLoading = false;
      update();
      return ResponseModel(false, "connection_error_please_try_again".tr);
    }

    ResponseModel responseModel;
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_200') {
      _isLoading = false;
      update();
      responseModel = ResponseModel(true, "successfully_verified");
    } else {
      responseModel = _checkWrongOtp(response);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> verifyOtpForFirebaseOtp({
    String? session,
    String? phone,
    String? code,
  }) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.verifyOtpForFirebaseOtpLogin(
      session: session,
      phone: phone,
      code: code,
    );

    if (response == null) {
      _isLoading = false;
      update();
      return ResponseModel(false, "connection_error_please_try_again".tr);
    }

    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, "successfully_verified");
    } else {
      responseModel = _checkWrongOtp(response);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> resetPassword(
    String identity,
    String identityType,
    String otp,
    String password,
    String confirmPassword,
    int isFirebaseOtp,
  ) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.resetPassword(
      identity,
      identityType,
      otp,
      password,
      confirmPassword,
      isFirebaseOtp,
    );

    if (response == null) {
      showCustomSnackBar('connection_error_please_try_again'.tr);
      _isLoading = false;
      update();
      return;
    }

    if (response.statusCode == 200 &&
        response.body['response_code'] == "default_password_reset_200") {
      Get.offNamed(RouteHelper.signIn);
      showCustomSnackBar(
        'password_changed_successfully'.tr,
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar(response.statusText);
    }
    _isLoading = false;
    update();
  }

  Future removeUser() async {
    _isLoading = true;
    update();

    Response? response = await authRepo.deleteUser();
    _isLoading = false;

    if (response == null) {
      showCustomSnackBar('connection_error_please_try_again'.tr);
      update();
      return;
    }

    print('====> Delete Status: ${response.statusCode}');
    print('====> Delete Body: ${response.body}');

    if (response.statusCode == 200) {
      // ── Delete from Firestore ─────────────────────────
      try {
        final email =
            Get.find<UserProfileController>()
                .providerModel
                ?.content
                ?.providerInfo
                ?.owner
                ?.email ??
            '';

        if (email.isNotEmpty) {
          final docId = email.trim().toLowerCase();
          final firestore = FirebaseFirestore.instance;

          await Future.wait([
            firestore.collection('athletes').doc(docId).delete(),
            firestore.collection('athlete_profiles').doc(docId).delete(),
          ]);

          if (kDebugMode) print('✅ Firestore athlete data deleted: $docId');
        }
      } catch (e) {
        if (kDebugMode) print('❌ Firestore delete error: $e');
        // Non-fatal — continue with logout
      }

      // ── Clear local data & navigate ───────────────────
      showCustomSnackBar(
        'your_account_remove_successfully'.tr,
        type: ToasterMessageType.success,
      );
      clearSharedData();
      Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
    } else {
      Get.back();
      ApiChecker.checkApi(response);
    }

    update();
  }

  toggleIsNumberLogin({bool? value, bool isUpdate = true}) {
    if (value == null) {
      _isNumberLogin = !_isNumberLogin;
    } else {
      _isNumberLogin = value;
    }
    initCountryCode();
    if (isUpdate) {
      update();
    }
  }

  ResponseModel _checkWrongOtp(Response response) {
    if (verificationCode.length == 6 && response.statusCode == 403) {
      _isWrongOtpSubmitted = true;
    }
    String responseText = "";
    if (response.statusCode == 500) {
      responseText = "Internal Server Error";
    } else {
      responseText = response.body["message"] ?? "verification_failed".tr;
    }
    return ResponseModel(false, responseText);
  }

  void updateVerificationCode(String query) {
    _verificationCode = query;
    _isWrongOtpSubmitted = false;
    update();
  }

  void updateWrongVerificationCodeStatus({
    bool value = false,
    bool shouldUpdate = false,
  }) {
    _isWrongOtpSubmitted = value;
    if (shouldUpdate) {
      update();
    }
  }

  bool isNotificationActive() {
    return authRepo.isNotificationActive();
  }

  toggleNotificationSound() {
    authRepo.toggleNotificationSound(!isNotificationActive());
    update();
  }

  bool isLoggedIn() {
    return authRepo.isLoggedIn();
  }

  bool clearSharedData() {
    return authRepo.clearSharedData();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe!;
    authRepo.setRememberMeValue(_isActiveRememberMe!);
    update();
  }

  bool? getRememberMeValue() {
    return authRepo.getRememberMeValue();
  }

  String getUserNumber() {
    return authRepo.getUserNumber();
  }

  String getUserPassword() {
    return authRepo.getUserPassword();
  }

  Future<void> updateToken() async {
    await authRepo.updateToken();
  }

  void unsubscribeToken() async {
    await authRepo.unsubscribeToken();
  }

  void initCountryCode({String? countryCode}) {
    countryDialCode =
        countryCode ??
        CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel.content?.countryCode ?? "BD",
        ).dialCode ??
        "+880";
  }
}
