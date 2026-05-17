import 'package:afriendorse/athlete/feature/auth/repository/general_firebase_auth_sync_service.dart';
import 'package:afriendorse/feature/auth/controller/facebook_login_controller.dart';
import 'package:afriendorse/feature/auth/repository/brand_fan_welcome_notification_service.dart';
import 'package:afriendorse/feature/auth/repository/email_service.dart';
import 'package:afriendorse/feature/auth/repository/firestore_sync_service.dart';
import 'package:afriendorse/feature/auth/repository/two_factor_service.dart';
import 'package:afriendorse/feature/auth/view/complete_brand_profile_screen.dart';
import 'package:afriendorse/feature/auth/view/two_factor_verification_screen.dart';
import 'package:afriendorse/feature/referral/repository/referral_tracking_service.dart';
import 'package:afriendorse/feature/referral/repository/user_referral_code_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;

  bool _isLoading = false;
  bool _isResendLoading = false;
  bool _acceptTerms = false;
  bool _forgetPasswordUrlSessionExpired = false;
  bool savedCookiesData = false;

  bool _twoFactorEnabled = false;
  String? _pendingLoginToken;
  String? _pendingLoginEmail;
  String? _pendingRedirectRoute;

  AuthController({required this.authRepo});

  bool get isLoading => _isLoading;
  bool get isResendLoading => _isResendLoading;
  bool get forgetPasswordUrlSessionExpired => _forgetPasswordUrlSessionExpired;
  bool get acceptTerms => _acceptTerms;
  bool get twoFactorEnabled => _twoFactorEnabled;

  String _verificationCode = '';
  String get verificationCode => _verificationCode;

  bool _isNumberLogin = false;
  bool get isNumberLogin => _isNumberLogin;

  bool _isActiveRememberMe = false;
  bool get isActiveRememberMe => _isActiveRememberMe;

  bool _isWrongOtpSubmitted = false;
  bool get isWrongOtpSubmitted => _isWrongOtpSubmitted;

  void setWrongOtpSubmitted(bool value) {
    _isWrongOtpSubmitted = value;
  }

  LoginMedium _selectedLoginMedium = LoginMedium.manual;
  LoginMedium get selectedLoginMedium => _selectedLoginMedium;

  var countryDialCode = "+234";
  final String _mobileNumber = '';
  String get mobileNumber => _mobileNumber;

  var newPasswordController = TextEditingController();
  var confirmNewPasswordController = TextEditingController();

  final GoogleSignIn signIn = GoogleSignIn.instance;
  GoogleSignInAccount? googleAccount;

  @override
  void onInit() {
    super.onInit();
    countryDialCode = CountryCode.fromCountryCode(
      Get.find<SplashController>().configModel.content != null
          ? Get.find<SplashController>().configModel.content!.countryCode!
          : "NG",
    ).dialCode!;
  }

  Future<void> loadTwoFactorPreference({String? email}) async {
    if (email == null || email.trim().isEmpty) return;
    _twoFactorEnabled = await FirestoreSyncService.getTwoFactorPreference(
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

    final success = await FirestoreSyncService.updateTwoFactorPreference(
      email: email.trim().toLowerCase(),
      enabled: enabled,
    );

    if (success) {
      _twoFactorEnabled = enabled;
      customSnackBar(
        enabled
            ? 'Two-factor authentication enabled'
            : 'Two-factor authentication disabled',
        type: ToasterMessageType.success,
      );
    } else {
      customSnackBar('Failed to update two-factor preference');
    }

    _isLoading = false;
    update();
  }

  Future<void> verifyFirestoreTwoFactorCode({
    required String sessionId,
    required String code,
    required String email,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();

    final isValid = await TwoFactorService.verifyCode(
      sessionId: sessionId,
      code: code,
    );

    if (isValid) {
      await _saveTokenAndNavigate(
        redirectRoute: redirectUrl ?? _pendingRedirectRoute,
        token: _pendingLoginToken ?? '',
        emailPhone: email,
        password: '',
      );

      _pendingLoginToken = null;
      _pendingLoginEmail = null;
      _pendingRedirectRoute = null;

      customSnackBar('Login successful', type: ToasterMessageType.success);
    } else {
      customSnackBar('Invalid or expired verification code');
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
      customSnackBar('Unable to resend code');
      return;
    }

    final response = await authRepo.sendTwoFactorEmail(
      email: email,
      code: newCode,
    );

    if (response.statusCode == 200) {
      customSnackBar(
        'Verification code resent',
        type: ToasterMessageType.success,
      );
    } else {
      String errorMessage = 'Failed to resend verification code';
      try {
        if (response.body is Map && response.body['message'] != null) {
          errorMessage = response.body['message'].toString();
        } else if (response.statusText != null) {
          errorMessage = response.statusText.toString();
        } else {
          errorMessage = response.body.toString();
        }
      } catch (_) {}
      customSnackBar(errorMessage);
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

          // Brand/Fan path
          await FirestoreSyncService.completeUserReferralIfExists(userEmail);
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error handling referral: $e');
    }
  }

  Future<void> registration({
    required SignUpBody signUpBody,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();

    try {
      Response response = await authRepo.registration(signUpBody);

      if (response.statusCode == 200 &&
          response.body['response_code'] == 'registration_200') {
        final String email = (signUpBody.email ?? '').trim().toLowerCase();

        final String? mysqlUserId =
            response.body['content']?['user']?['id']?.toString() ??
            response.body['content']?['id']?.toString();

        if (email.isNotEmpty) {
          await FirebaseAuthSyncService.syncAfterLogin(email: email);
        }

        // ── Firestore sync + Welcome Notifications ─────────────────────────────
        if (email.isNotEmpty && signUpBody.userType != null) {
          try {
            await FirestoreSyncService.syncUserToFirestore(
              email: email,
              phone: signUpBody.phone,
              firstName: signUpBody.fName ?? '',
              lastName: signUpBody.lName ?? '',
              userType: signUpBody.userType!,
              mysqlUserId: mysqlUserId,
              fcmToken: await FirebaseMessaging.instance.getToken(),
            );

            // ⭐⭐⭐ HANDLE REFERRAL SYSTEM ⭐⭐⭐
            await _handleReferralOnSignup(
              userEmail: email,
              userType: signUpBody.userType!,
              firstName: signUpBody.fName ?? '',
              referralCode: signUpBody.referCode,
            );

            if (mysqlUserId != null && mysqlUserId.isNotEmpty) {
              await FirestoreSyncService.updateMysqlUserId(email, mysqlUserId);
            }

            // ⭐⭐⭐ SEND WELCOME NOTIFICATIONS (Email + Push) ⭐⭐⭐
            if (signUpBody.userType == 'brand' ||
                signUpBody.userType == 'fan') {
              try {
                final welcomeResult =
                    await BrandFanWelcomeNotificationService.sendWelcomeNotifications(
                      email: email,
                      firstName: signUpBody.fName ?? 'User',
                      userType: signUpBody.userType!,
                      brandName: signUpBody.brandName,
                      industry: signUpBody.industry,
                    );

                if (kDebugMode) {
                  print('📊 Welcome notification result: $welcomeResult');
                }
              } catch (e) {
                if (kDebugMode)
                  print('❌ Welcome notification error (non-fatal): $e');
                // Non-fatal — don't block registration flow
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('❌ Firestore sync error: $e');
            }
          }
        }

        var config = Get.find<SplashController>().configModel.content;

        if (config?.phoneVerification == 1 || config?.emailVerification == 1) {
          String identity = config?.phoneVerification == 1
              ? signUpBody.phone!.trim()
              : signUpBody.email!.trim();
          String identityType = config?.phoneVerification == 1
              ? "phone"
              : "email";
          SendOtpType type =
              config?.phoneVerification == 1 &&
                  config?.firebaseOtpVerification == 1
              ? SendOtpType.firebase
              : SendOtpType.verification;

          await sendVerificationCode(
            identity: identity,
            identityType: identityType,
            type: type,
          ).then((status) {
            if (status != null) {
              if (status.isSuccess!) {
                Get.toNamed(
                  RouteHelper.getVerificationRoute(
                    identity: identity,
                    identityType: identityType,
                    fromPage:
                        config?.phoneVerification == 1 &&
                            config?.firebaseOtpVerification == 1
                        ? "firebase-otp"
                        : "verification",
                    firebaseSession: type == SendOtpType.firebase
                        ? status.message
                        : null,
                    redirectUrl: redirectUrl,
                  ),
                );
              } else {
                customSnackBar(status.message.toString().capitalizeFirst);
              }
            }
          });
        } else {
          await _handlePostRegistrationNavigation(
            token: response.body['content']['token'],
            email: email,
            userType: signUpBody.userType ?? 'fan',
            redirectUrl: redirectUrl,
          );
        }

        customSnackBar('registration_200'.tr, type: ToasterMessageType.success);
      } else if (response.statusCode == 404 &&
          response.body['response_code'] == "referral_code_400") {
        customSnackBar("invalid_refer_code".tr);
      } else if (response.statusCode == 400 &&
          response.body['response_code'] == "default_400") {
        String errorMessage = 'An error occurred';
        try {
          if (response.body['errors'] is List &&
              response.body['errors'].isNotEmpty) {
            errorMessage =
                response.body['errors'][0]['message'] ?? errorMessage;
          } else if (response.body['errors'] is Map) {
            final errors = response.body['errors'] as Map;
            errorMessage = errors.values.first?.toString() ?? errorMessage;
          } else if (response.body['message'] != null) {
            errorMessage = response.body['message'];
          }
        } catch (e) {
          errorMessage = response.body.toString();
        }
        customSnackBar(errorMessage);
      } else {
        customSnackBar(response.statusText);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Registration error: $e');
      }
      customSnackBar('Registration failed. Please try again.');
    }

    _isLoading = false;
    update();
  }

  Future<void> _handlePostRegistrationNavigation({
    required String token,
    required String email,
    required String userType,
    String? redirectUrl,
  }) async {
    authRepo.saveUserToken(token);

    Get.find<SplashController>().updateLanguage(true);
    Get.find<LocationController>().getAddressList();

    if (userType == 'brand') {
      Get.offAll(
        () =>
            CompleteBrandProfileScreen(email: email, redirectUrl: redirectUrl),
      );
      return;
    }

    Get.offAllNamed(
      redirectUrl ??
          (Get.find<LocationController>().getUserAddress() != null
              ? RouteHelper.home
              : RouteHelper.pickMap),
    );
  }

  Future<void> login({
    String? redirectRoute,
    required String emailPhone,
    required String password,
    required String type,
  }) async {
    _isLoading = true;
    update();

    Response? response = await authRepo.login(
      phone: emailPhone,
      password: password,
      type: type,
    );

    if (response == null) {
      customSnackBar('connection_error_please_try_again'.tr);
      _isLoading = false;
      update();
      return;
    }

    if (response.statusCode == 200 &&
        response.body['response_code'] == "auth_login_200") {
      final String? mysqlUserId =
          response.body['content']?['user']?['id']?.toString() ??
          response.body['content']?['id']?.toString();

      final String email =
          (response.body['content']?['user']?['email']?.toString() ??
                  response.body['content']?['email']?.toString() ??
                  (type == 'email' ? emailPhone : ''))
              .trim()
              .toLowerCase();

      // ── 🔥 Firebase Auth sync ────────────────────────────────────────────
      if (email.isNotEmpty) {
        await FirebaseAuthSyncService.syncAfterLogin(email: email);
      }

      final String? phone =
          response.body['content']?['user']?['phone']?.toString() ??
          response.body['content']?['phone']?.toString();

      final String firstName =
          response.body['content']?['user']?['first_name']?.toString() ??
          response.body['content']?['user']?['f_name']?.toString() ??
          '';

      final String lastName =
          response.body['content']?['user']?['last_name']?.toString() ??
          response.body['content']?['user']?['l_name']?.toString() ??
          '';

      final String? userType = response.body['content']?['user']?['user_type']
          ?.toString();

      if (email.isNotEmpty) {
        try {
          final existingProfile = await FirestoreSyncService.getUserByEmail(
            email,
          );

          if (existingProfile == null &&
              userType != null &&
              userType.isNotEmpty) {
            await FirestoreSyncService.syncUserToFirestore(
              email: email,
              phone: phone,
              firstName: firstName,
              lastName: lastName,
              userType: userType,
              mysqlUserId: mysqlUserId,
              fcmToken: null,
            );
          } else if (mysqlUserId != null && mysqlUserId.isNotEmpty) {
            await FirestoreSyncService.updateMysqlUserId(email, mysqlUserId);
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Firestore sync error during login: $e');
          }
        }
      }

      final bool twoFactorOn = email.isNotEmpty
          ? await FirestoreSyncService.getTwoFactorPreference(email)
          : false;

      if (twoFactorOn && email.isNotEmpty) {
        final sessionId = await TwoFactorService.createSession(email: email);
        final code = await TwoFactorService.getSessionCode(sessionId);

        if (code == null) {
          customSnackBar('Failed to generate verification code');
          _isLoading = false;
          update();
          return;
        }

        final sendResponse = await authRepo.sendTwoFactorEmail(
          email: email,
          code: code,
        );

        if (sendResponse.statusCode != 200) {
          String errorMessage = 'Failed to send verification code';

          try {
            if (sendResponse.body is Map &&
                sendResponse.body['message'] != null) {
              errorMessage = sendResponse.body['message'].toString();
            } else if (sendResponse.statusText != null) {
              errorMessage = sendResponse.statusText.toString();
            } else {
              errorMessage = sendResponse.body.toString();
            }
          } catch (_) {}

          customSnackBar(errorMessage);
          _isLoading = false;
          update();
          return;
        }

        _pendingLoginToken = response.body['content']['token'];
        _pendingLoginEmail = email;
        _pendingRedirectRoute = redirectRoute;

        _isLoading = false;
        update();

        Get.to(
          () => TwoFactorVerificationScreen(
            sessionId: sessionId,
            email: email,
            redirectUrl: redirectRoute,
          ),
        );
        return;
      }

      await _saveTokenAndNavigate(
        redirectRoute: redirectRoute,
        token: response.body['content']['token'],
        userId: mysqlUserId,
        emailPhone: email.isNotEmpty ? email : emailPhone,
        password: password,
      );
    } else if (response.statusCode == 401 &&
            (response.body["response_code"] == "unverified_phone_401") ||
        response.body["response_code"] == "unverified_email_401") {
      var config = Get.find<SplashController>().configModel.content;

      SendOtpType sendOtpType =
          type == "phone" && config?.firebaseOtpVerification == 1
          ? SendOtpType.firebase
          : SendOtpType.verification;

      await sendVerificationCode(
        identity: emailPhone,
        identityType: type,
        type: sendOtpType,
      ).then((status) {
        if (status != null) {
          if (status.isSuccess!) {
            Get.toNamed(
              RouteHelper.getVerificationRoute(
                identity: emailPhone,
                identityType: type,
                fromPage:
                    type == "phone" && config?.firebaseOtpVerification == 1
                    ? "firebase-otp"
                    : "verification",
                firebaseSession: sendOtpType == SendOtpType.firebase
                    ? status.message
                    : null,
                redirectUrl: redirectRoute,
              ),
            );
          } else {
            customSnackBar(status.message.toString().capitalizeFirst);
          }
        }
      });
    } else {
      customSnackBar(
        response.body["message"].toString().capitalizeFirst ??
            response.statusText,
      );
    }

    _isLoading = false;
    update();
  }

  Future<void> logOut() async {
    Response? response = await authRepo.logOut();
    if (response?.statusCode == 200) {
      if (kDebugMode) {
        print("Logout successfully with ${response?.body}");
      }
    } else {
      if (kDebugMode) {
        print("Logout Failed");
      }
    }
  }

  Future<void> _saveTokenAndNavigate({
    String? redirectRoute,
    required String token,
    String? userId,
    String? emailPhone,
    String? password,
  }) async {
    authRepo.saveUserToken(token);
    Get.find<SplashController>().updateLanguage(true);
    Get.find<LocationController>().getAddressList();

    if (_isActiveRememberMe) {
      saveUserNumberAndPassword(
        number: emailPhone ?? "",
        password: password ?? "",
      );
    } else {
      clearUserNumberAndPassword();
    }

    if (redirectRoute == null && emailPhone != null && emailPhone.isNotEmpty) {
      String emailKey = emailPhone.trim().toLowerCase();

      if (GetUtils.isEmail(emailKey)) {
        final userDoc = await FirestoreSyncService.getUserByEmail(emailKey);

        if (userDoc != null) {
          final userType = userDoc['userType']?.toString();
          final profileComplete = userDoc['profileComplete'] == true;

          if (userType == 'brand' && !profileComplete) {
            Get.offAll(
              () => CompleteBrandProfileScreen(
                email: emailKey,
                redirectUrl: redirectRoute,
              ),
            );
            return;
          }
        }
      }
    }

    if (redirectRoute != null) {
      if (Get.find<LocationController>().getUserAddress() != null) {
        updateSavedLocalAddress();
      }
      final routeData = RouteHelper.parseRedirectRouteToNavigate(redirectRoute);
      Get.offAllNamed(routeData.path, parameters: routeData.parameters);
    } else {
      Get.offAllNamed(RouteHelper.getMainRoute('home'));
    }
  }

  Future<void> updateSavedLocalAddress({
    bool saveContactPersonInfo = true,
  }) async {
    AddressModel addressModel = Get.find<LocationController>()
        .getUserAddress()!;

    if (saveContactPersonInfo) {
      if (Get.find<UserController>().userInfoModel == null) {
        Get.find<UserController>().getUserInfo(reload: true);
      } else {
        String? firstName;
        if (Get.find<AuthController>().isLoggedIn() &&
            Get.find<UserController>().userInfoModel?.phone != null &&
            Get.find<UserController>().userInfoModel?.fName != null) {
          firstName = "${Get.find<UserController>().userInfoModel?.fName} ";
        }

        addressModel.contactPersonNumber = firstName != null
            ? Get.find<UserController>().userInfoModel?.phone ?? ""
            : "";
        addressModel.contactPersonName = firstName != null
            ? "$firstName${Get.find<UserController>().userInfoModel?.lName ?? ""}"
            : "";
        addressModel.addressLabel = 'others';
      }
    } else {
      addressModel.contactPersonNumber = "";
      addressModel.contactPersonName = "";
    }
    Get.find<LocationController>().saveUserAddress(addressModel);
  }

  Future<void> loginWithSocialMedia(
    SocialLogInBody socialLogInBody,
    Function callback,
  ) async {
    _isLoading = true;
    update();
    Response response = await authRepo.loginWithSocialMedia(socialLogInBody);
    _isLoading = false;
    if (response.statusCode == 200 &&
        response.body['response_code'] == "auth_login_200") {
      Map map = response.body;
      String? message = '';
      String? token = '';
      String? tempToken = '';
      String? email;
      UserInfoModel? userInfoModel;
      try {
        message = map['message'] ?? '';
      } catch (e) {
        debugPrint('error ===> $e');
      }

      try {
        token = map['content']['token'];
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      try {
        tempToken = map['content']['temporary_token'];
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      try {
        email = map['content']['email'];
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      if (map['content']['user'] != null) {
        try {
          userInfoModel = UserInfoModel.fromJson(map['content']['user']);
          callback(
            true,
            null,
            message,
            null,
            userInfoModel,
            socialLogInBody.medium,
            null,
            null,
          );
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }

      if (token != null) {
        saveUserNumberAndPassword(number: "", password: "");
        await authRepo.saveUserToken(token);
        await authRepo.saveUserToken(token);
        await Get.find<UserController>().getUserInfo(reload: true);
        authRepo.updateToken();
        callback(
          true,
          token,
          message,
          null,
          null,
          null,
          socialLogInBody.userName,
          socialLogInBody.email,
        );
      }

      if (tempToken != null) {
        callback(
          true,
          null,
          message,
          tempToken,
          null,
          null,
          socialLogInBody.userName,
          socialLogInBody.email ?? email,
        );
      }

      update();
    } else {
      String? errorMessage = response.body['message'] ?? response.statusText;
      callback(
        false,
        '',
        errorMessage,
        null,
        null,
        null,
        socialLogInBody.userName,
        socialLogInBody.email,
      );
      update();
    }
  }

  Future<ResponseModel?> sendVerificationCode({
    required String identity,
    required String identityType,
    required SendOtpType type,
    int checkUser = 1,
    String fromPage = "",
    bool isResend = false,
    String? redirectUrl,
  }) async {
    ResponseModel? responseModel;
    if (isResend) {
      _isResendLoading = true;
      update();
    }
    if (type == SendOtpType.firebase) {
      _sendOtpForFirebaseVerification(
        identity: identity,
        identityType: identityType,
        fromPage: fromPage,
        isResend: isResend,
        redirectUrl: redirectUrl,
      );
    } else if (type == SendOtpType.verification) {
      responseModel = await _sendOtpForVerificationScreen(
        identity: identity,
        identityType: identityType,
        checkUser: checkUser,
        isResend: isResend,
      );
    } else {
      responseModel = await _sendOtpForForgetPassword(
        identity: identity,
        identityType: identityType,
        isResend: isResend,
      );
    }
    if (isResend) {
      _isResendLoading = false;
      update();
    }
    return responseModel;
  }

  Future<ResponseModel> _sendOtpForVerificationScreen({
    required String identity,
    required String identityType,
    required int checkUser,
    bool isResend = false,
  }) async {
    if (!isResend) {
      _isLoading = true;
      update();
    }
    Response response = await authRepo.sendOtpForVerificationScreen(
      identity: identity,
      identityType: identityType,
      checkUser: checkUser,
    );
    if (response.statusCode == 200 &&
        response.body["response_code"] == "default_200") {
      if (!isResend) {
        _isLoading = false;
        update();
      }
      return ResponseModel(true, "");
    } else {
      if (!isResend) {
        _isLoading = false;
        update();
      }
      String responseText = "";
      if (response.statusCode == 500) {
        responseText = "Internal Server Error";
      } else {
        responseText = response.body["message"] ?? response.statusText;
      }
      return ResponseModel(false, responseText);
    }
  }

  Future<ResponseModel> _sendOtpForForgetPassword({
    required String identity,
    required String identityType,
    bool isResend = false,
  }) async {
    if (!isResend) {
      _isLoading = true;
      update();
    }
    Response response = await authRepo.sendOtpForForgetPassword(
      identity,
      identityType,
    );

    if (response.statusCode == 200 &&
        response.body["response_code"] == "default_200") {
      if (!isResend) {
        _isLoading = false;
        update();
      }
      return ResponseModel(true, "");
    } else {
      if (!isResend) {
        _isLoading = false;
        update();
      }
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
    bool isResend = false,
    String? redirectUrl,
  }) async {
    if (!isResend) {
      _isLoading = true;
      update();
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: identity,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        if (!isResend) {
          _isLoading = false;
        }
        if (isResend) {
          _isResendLoading = false;
        }
        update();
        if (fromPage == "profile") {
          Get.back();
        }
        if (e.code == 'invalid-phone-number') {
          customSnackBar(
            'please_submit_a_valid_phone_number',
            type: ToasterMessageType.info,
          );
        } else {
          customSnackBar('${e.message}'.replaceAll('_', ' ').capitalizeFirst);
        }
      },
      codeSent: (String vId, int? resendToken) {
        if (!isResend) {
          _isLoading = false;
        }
        if (isResend) {
          _isResendLoading = false;
        }
        update();
        if (fromPage == "profile") {
          Get.back();
        }
        Get.toNamed(
          RouteHelper.getVerificationRoute(
            identity: identity,
            identityType: identityType,
            fromPage: fromPage == "forget-password"
                ? "forget-password"
                : "firebase-otp",
            firebaseSession: vId,
            redirectUrl: redirectUrl,
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyOtpForVerificationScreen({
    required String identity,
    required String identityType,
    required String otp,
    required String fromPage,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();

    Response? response = await authRepo.verifyOtpForVerificationScreen(
      identity,
      identityType,
      otp,
    );

    if (response != null &&
        response.statusCode == 200 &&
        response.body['response_code'] == "default_200") {
      customSnackBar(
        response.body["message"],
        type: ToasterMessageType.success,
      );

      if (fromPage == "profile") {
        Get.find<UserController>().getUserInfo(reload: false);
        if (Navigator.canPop(Get.context!)) {
          Navigator.pop(Get.context!);
        } else {
          Get.toNamed(RouteHelper.getEditProfileRoute());
        }
      } else {
        final String token = response.body['content']['token'];
        final String email =
            (response.body['content']?['user']?['email']?.toString() ??
                    identity)
                .trim()
                .toLowerCase();

        String? mysqlUserId =
            response.body['content']?['user']?['id']?.toString() ??
            response.body['content']?['id']?.toString();

        if (email.isNotEmpty && mysqlUserId != null && mysqlUserId.isNotEmpty) {
          try {
            await FirestoreSyncService.updateMysqlUserId(email, mysqlUserId);
          } catch (_) {}
        }

        authRepo.saveUserToken(token);
        Get.find<SplashController>().updateLanguage(true);
        Get.find<LocationController>().getAddressList();

        final userDoc = await FirestoreSyncService.getUserByEmail(email);
        final userType = userDoc?['userType']?.toString();
        final profileComplete = userDoc?['profileComplete'] == true;

        if (userType == 'brand' && !profileComplete) {
          Get.offAll(
            () => CompleteBrandProfileScreen(
              email: email,
              redirectUrl: redirectUrl,
            ),
          );
        } else {
          Get.offAllNamed(
            redirectUrl ??
                (Get.find<LocationController>().getUserAddress() != null
                    ? RouteHelper.home
                    : RouteHelper.pickMap),
          );
        }
      }
    } else {
      ResponseModel responseModel = _checkWrongOtp(response!);
      customSnackBar(responseModel.message.toString().capitalizeFirst);
    }

    _isLoading = false;
    update();
  }

  Future<ResponseModel> verifyOtpForForgetPasswordScreen(
    String identity,
    String identityType,
    String otp, {
    bool fromOutsideUrl = false,
    bool shouldUpdate = true,
  }) async {
    _isLoading = true;

    if (fromOutsideUrl) {
      _forgetPasswordUrlSessionExpired = true;
    }

    if (shouldUpdate) {
      update();
    }

    Response response = await authRepo.verifyOtpForForgetPassword(
      identity,
      identityType,
      otp,
    );

    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_200') {
      _isLoading = false;
      _forgetPasswordUrlSessionExpired = false;
      update();
      return ResponseModel(true, "successfully_verified");
    } else {
      _isLoading = false;
      update();
      String responseText = "";
      if (response.statusCode == 500) {
        responseText = "Internal Server Error";
      } else if (response.statusCode == 400 &&
          response.body['errors'] != null) {
        responseText = response.body['errors'][0]['message'];
      } else {
        responseText = response.body["message"] ?? response.statusText;
      }
      return ResponseModel(false, responseText);
    }
  }

  Future<void> verifyOtpForPhoneOtpLogin({
    required String phone,
    required String otp,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.verifyOtpForPhoneOtpLogin(
      phone: phone,
      otp: otp,
    );

    if (response!.statusCode == 200) {
      if (response.body['content']['token'] != null) {
        await _saveTokenAndNavigate(
          redirectRoute: redirectUrl ?? RouteHelper.getMainRoute("home"),
          token: response.body['content']['token'],
          emailPhone: phone,
          password: "",
        );
      } else if (response.body['content']['temporary_token'] != null) {
        Get.offNamed(
          RouteHelper.getUpdateProfileRoute(
            phone: phone,
            redirectUrl: redirectUrl,
          ),
        );
      }
    } else {
      ResponseModel responseModel = _checkWrongOtp(response);
      customSnackBar(responseModel.message ?? "");
    }
    _isLoading = false;
    update();
  }

  Future<void> verifyOtpForFirebaseOtp({
    String? session,
    String? phone,
    String? code,
    required String fromPage,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.verifyOtpForFirebaseOtpLogin(
      session: session,
      phone: phone,
      code: code,
    );

    if (response!.statusCode == 200) {
      if (fromPage == "forget-password") {
        Get.offNamed(
          RouteHelper.getChangePasswordRoute(
            body: ForgetPasswordBody(
              identity: phone,
              identityType: "phone",
              otp: code,
              fromUrl: 0,
              isFirebaseOtp: 1,
            ),
            redirectUrl: redirectUrl,
          ),
        );
      } else {
        if (response.body['content']['token'] != null) {
          await _saveTokenAndNavigate(
            redirectRoute:
                redirectUrl ??
                (Get.find<LocationController>().getUserAddress() != null
                    ? RouteHelper.home
                    : RouteHelper.pickMap),
            token: response.body['content']['token'],
            emailPhone: phone,
          );
        } else if (response.body['content']['temporary_token'] != null) {
          Get.offNamed(
            RouteHelper.getUpdateProfileRoute(
              phone: phone ?? "",
              redirectUrl: redirectUrl,
            ),
          );
        }
      }
    } else {
      ResponseModel responseModel = _checkWrongOtp(response);
      customSnackBar(responseModel.message);
    }
    _isLoading = false;
    update();
  }

  Future<void> updateNewUserProfileAndLogin({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? userType,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();

    Response response = await authRepo.updateNewUserProfileAndLogin(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      userType: userType,
    );

    if (response.statusCode == 200) {
      if (response.body['content']['token'] != null) {
        final String resolvedEmail =
            (response.body['content']?['user']?['email']?.toString() ??
                    email ??
                    '')
                .trim()
                .toLowerCase();

        final String? mysqlUserId =
            response.body['content']?['user']?['id']?.toString() ??
            response.body['content']?['id']?.toString();

        // ── Firestore sync + Welcome Notifications ─────────────────────────────
        if (resolvedEmail.isNotEmpty && userType != null) {
          try {
            await FirestoreSyncService.syncUserToFirestore(
              email: resolvedEmail,
              phone: phone,
              firstName: firstName ?? '',
              lastName: lastName ?? '',
              userType: userType,
              mysqlUserId: mysqlUserId,
              fcmToken: await FirebaseMessaging.instance.getToken(),
            );

            if (mysqlUserId != null && mysqlUserId.isNotEmpty) {
              await FirestoreSyncService.updateMysqlUserId(
                resolvedEmail,
                mysqlUserId,
              );
            }

            // ⭐⭐⭐ SEND WELCOME NOTIFICATIONS (Email + Push) ⭐⭐⭐
            if (userType == 'brand' || userType == 'fan') {
              try {
                final welcomeResult =
                    await BrandFanWelcomeNotificationService.sendWelcomeNotifications(
                      email: resolvedEmail,
                      firstName: firstName ?? 'User',
                      userType: userType,
                    );

                if (kDebugMode) {
                  print(
                    '📊 Profile update welcome notification result: $welcomeResult',
                  );
                }
              } catch (e) {
                if (kDebugMode)
                  print(
                    '❌ Profile update welcome notification error (non-fatal): $e',
                  );
                // Non-fatal — don't block registration flow
              }
            }
          } catch (_) {}
        }

        if (userType == 'brand') {
          authRepo.saveUserToken(response.body['content']['token']);
          Get.offAll(
            () => CompleteBrandProfileScreen(
              email: resolvedEmail,
              redirectUrl: redirectUrl,
            ),
          );
        } else {
          await _saveTokenAndNavigate(
            redirectRoute: redirectUrl,
            token: response.body['content']['token'],
            emailPhone: resolvedEmail,
            password: "",
          );
        }
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> registerWithSocialMedia({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? userType,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();
    Response response = await authRepo.registerWithSocialMedia(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      userType: userType,
    );

    if (response.statusCode == 200) {
      final String resolvedEmail =
          (response.body['content']?['user']?['email']?.toString() ??
                  email ??
                  '')
              .trim()
              .toLowerCase();

      final String? mysqlUserId =
          response.body['content']?['user']?['id']?.toString() ??
          response.body['content']?['id']?.toString();

      // ── Firestore sync + Welcome Notifications ─────────────────────────────
      if (resolvedEmail.isNotEmpty && userType != null) {
        try {
          await FirestoreSyncService.syncUserToFirestore(
            email: resolvedEmail,
            phone: phone,
            firstName: firstName ?? '',
            lastName: lastName ?? '',
            userType: userType,
            mysqlUserId: mysqlUserId,
            fcmToken: await FirebaseMessaging.instance.getToken(),
          );

          if (mysqlUserId != null && mysqlUserId.isNotEmpty) {
            await FirestoreSyncService.updateMysqlUserId(
              resolvedEmail,
              mysqlUserId,
            );
          }

          // ⭐⭐⭐ SEND WELCOME NOTIFICATIONS (Email + Push) ⭐⭐⭐
          if (userType == 'brand' || userType == 'fan') {
            try {
              final welcomeResult =
                  await BrandFanWelcomeNotificationService.sendWelcomeNotifications(
                    email: resolvedEmail,
                    firstName: firstName ?? 'User',
                    userType: userType,
                  );

              if (kDebugMode) {
                print(
                  '📊 Social login welcome notification result: $welcomeResult',
                );
              }
            } catch (e) {
              if (kDebugMode)
                print(
                  '❌ Social login welcome notification error (non-fatal): $e',
                );
              // Non-fatal — don't block registration flow
            }
          }
        } catch (_) {}
      }

      if (response.body['content']['token'] != null) {
        if (userType == 'brand') {
          authRepo.saveUserToken(response.body['content']['token']);
          Get.offAll(
            () => CompleteBrandProfileScreen(
              email: resolvedEmail,
              redirectUrl: redirectUrl,
            ),
          );
        } else {
          await _saveTokenAndNavigate(
            redirectRoute: redirectUrl,
            token: response.body['content']['token'],
            emailPhone: resolvedEmail,
            password: "",
          );
        }
      } else if (response.body['content']['temporary_token'] != null) {
        var config = Get.find<SplashController>().configModel.content;
        SendOtpType type = config?.firebaseOtpVerification == 1
            ? SendOtpType.firebase
            : SendOtpType.verification;

        await sendVerificationCode(
          identity: phone!,
          identityType: "phone",
          type: type,
        ).then((status) {
          if (status != null) {
            if (status.isSuccess!) {
              Get.toNamed(
                RouteHelper.getVerificationRoute(
                  identity: phone,
                  identityType: "phone",
                  fromPage: type == SendOtpType.firebase
                      ? "firebase-otp"
                      : "otp-login",
                  firebaseSession: type == SendOtpType.firebase
                      ? status.message
                      : null,
                  redirectUrl: redirectUrl,
                ),
              );
            } else {
              customSnackBar(status.message.toString().capitalizeFirst);
            }
          }
        });
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> existingAccountCheck({
    String? email,
    required int userResponse,
    required String medium,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();
    Response response = await authRepo.existingAccountCheck(
      email: email ?? "",
      userResponse: userResponse,
      medium: medium,
    );
    if (response.statusCode == 200) {
      if (response.body['content']['token'] != null) {
        await _saveTokenAndNavigate(
          redirectRoute:
              redirectUrl ??
              (Get.find<LocationController>().getUserAddress() != null
                  ? RouteHelper.home
                  : RouteHelper.pickMap),
          token: response.body['content']['token'],
        );
      } else if (response.body['content']['temporary_token'] != null) {
        Get.offNamed(
          RouteHelper.getUpdateProfileRoute(
            email: email ?? "",
            tempToken: response.body['content']['temporary_token'],
            redirectUrl: redirectUrl,
          ),
        );
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> resetPassword({
    required String identity,
    required String identityType,
    required String otp,
    required String password,
    required String confirmPassword,
    required int isFirebaseOtp,
    String? redirectUrl,
  }) async {
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

    if (response!.statusCode == 200 &&
        response.body['response_code'] == "default_password_reset_200") {
      Get.offNamed(RouteHelper.getSignInRoute(redirectUrl: redirectUrl));
      customSnackBar(
        'password_changed_successfully'.tr,
        type: ToasterMessageType.success,
      );
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
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

  void updateForgetPasswordUrlSessionExpiredStatus({
    required bool status,
    bool shouldUpdate = false,
  }) {
    _forgetPasswordUrlSessionExpired = status;
    if (shouldUpdate) {
      update();
    }
  }

  void toggleTerms({bool? value, bool shouldUpdate = true}) {
    if (value != null) {
      _acceptTerms = value;
    } else {
      _acceptTerms = !_acceptTerms;
    }
    if (shouldUpdate) {
      update();
    }
  }

  void toggleIsNumberLogin({bool? value, bool isUpdate = true}) {
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

  void toggleSelectedLoginMedium({
    required LoginMedium loginMedium,
    bool isUpdate = true,
  }) {
    _selectedLoginMedium = loginMedium;
    if (isUpdate) {
      update();
    }
  }

  void cancelTermsAndCondition() {
    _acceptTerms = false;
  }

  void toggleRememberMe({bool? value, bool shouldUpdate = true}) {
    if (value != null) {
      _isActiveRememberMe = value;
    } else {
      _isActiveRememberMe = !_isActiveRememberMe;
    }
    if (shouldUpdate) {
      update();
    }
  }

  void toggleReferralBottomSheetShow() {
    authRepo.toggleReferralBottomSheetShow(false);
    update();
  }

  bool getIsShowReferralBottomSheet() {
    return authRepo.getIsShowReferralBottomSheet();
  }

  bool isLoggedIn() => authRepo.isLoggedIn();
  String getUserNumber() => authRepo.getUserNumber();
  String getUserCountryCode() => authRepo.getUserCountryCode();
  String getUserPassword() => authRepo.getUserPassword();
  bool isNotificationActive() => authRepo.isNotificationActive();

  void saveUserNumberAndPassword({
    required String number,
    required String password,
  }) => authRepo.saveUserNumberAndPassword(number, password, countryDialCode);

  Future<bool> clearUserNumberAndPassword() async =>
      authRepo.clearUserNumberAndPassword();

  bool clearSharedData({Response? response}) =>
      authRepo.clearSharedData(response: response);
  String getUserToken() => authRepo.getUserToken();

  void toggleNotificationSound() {
    authRepo.toggleNotificationSound(!isNotificationActive());
    update();
  }

  /* Future<void> signOutWithFacebook() async {
    await FacebookAuth.instance.logOut();
  } */

  Future<void> updateToken() async {
    await authRepo.updateToken();
  }

  Future<void> saveUserToken({required String token}) async {
    await authRepo.saveUserToken(token);
    update();
  }

  void initCountryCode({String? countryCode}) {
    countryDialCode =
        countryCode ??
        CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel.content?.countryCode ?? "BD",
        ).dialCode ??
        "+880";
  }

  Future<SocialLogInBody?> _googleWebSignIn() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential = await auth.signInWithPopup(
        googleProvider,
      );

      return SocialLogInBody(
        uniqueId: userCredential.credential?.accessToken,
        token: userCredential.credential?.accessToken,
        medium: SocialLoginType.google.name,
        email: userCredential.user?.email,
        guestId: Get.find<SplashController>().getGuestId(),
      );
    } catch (e) {
      customSnackBar(e.toString());
    }
    return null;
  }

  Future<SocialLogInBody?> googleLogin() async {
    SocialLogInBody? socialLoginModel;

    if (kIsWeb) {
      socialLoginModel = await _googleWebSignIn();
    } else {
      try {
        if (signIn.supportsAuthenticate()) {
          await signIn
              .initialize(serverClientId: AppConstants.googleServerClientId)
              .then((_) async {
                googleAccount = await signIn.authenticate();
                const List<String> scopes = <String>['email'];
                final auth = await googleAccount?.authorizationClient
                    .authorizationForScopes(scopes);

                socialLoginModel = SocialLogInBody(
                  uniqueId: auth?.accessToken,
                  token: auth?.accessToken,
                  medium: SocialLoginType.google.name,
                  email: googleAccount?.email,
                  userName: googleAccount?.displayName,
                  guestId: Get.find<SplashController>().getGuestId(),
                );
              });
        } else {
          debugPrint("Google Sign-In not supported on this device.");
        }
      } catch (e) {
        debugPrint("google_login: $e");
      }
    }

    return socialLoginModel;
  }

  /*
  Future<SocialLogInBody?> facebookLogin() async {
    final FacebookLoginController facebookLoginController =
        Get.find<FacebookLoginController>();

    await facebookLoginController.login();

    if (facebookLoginController.result.status == LoginStatus.success) {
      final Map userData = await facebookLoginController.facebookAuth
          .getUserData(fields: 'name, email');

      return SocialLogInBody(
        email: userData['email'],
        token: facebookLoginController.result.accessToken?.tokenString,
        uniqueId: userData['id'],
        medium: SocialLoginType.facebook.name,
        userName: userData['name'],
        guestId: Get.find<SplashController>().getGuestId(),
      );
    }

    return null;
  } */

  Future<void> googleLogout() async {
    try {
      await signIn.signOut();
      await signIn.disconnect();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  /* Future<void> facebookLogout() async {
   // await Get.find<FacebookLoginController>().facebookAuth.logOut();
  } */
}
