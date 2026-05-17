import 'package:afriendorse/athlete/feature/auth/repository/general_firebase_auth_sync_service.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class AuthRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AuthRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response?> registration({
    required SignUpBody signUpBody,
    required List<MultipartBody> identityImage,
    required XFile profileImage,
    required XFile coverImage,
  }) async {
    try {
      final List<MultipartBody> imageList = identityImage.toList();
      imageList.add(MultipartBody('cover_image', coverImage));

      Response<dynamic>? response = await apiClient.postMultipartData(
        AppConstants.registerUri,
        signUpBody.toJson(),
        imageList,
        MultipartBody('logo', profileImage),
      );

      return response;
    } on TimeoutException catch (e) {
      if (kDebugMode) print('❌ Registration Timeout: $e');
      // You can return a custom response here to handle specifically in controller
      return Response(statusCode: 408, statusText: 'upload_timeout'.tr);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Registration API error: $e');
      }
      return null;
    }
  }

  Future<Response?> sendTwoFactorEmail({
    required String email,
    required String code,
  }) async {
    try {
      return await apiClient.postData(AppConstants.sendTwoFactorEmailUri, {
        "email": email,
        "code": code,
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Send athlete 2FA email error: $e');
      }
      return null;
    }
  }

  Future<Response?> login({
    required String emailOrPassword,
    required String password,
    required String type,
  }) async {
    try {
      return await apiClient.postData(AppConstants.loginUri, {
        "email_or_phone": emailOrPassword,
        "password": password,
        "type": type,
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login API error: $e');
      }
      return null;
    }
  }

  Future<Response?> deleteUser() async {
    try {
      return await apiClient.deleteData(AppConstants.providerRemove);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Delete user error: $e');
      }
      return null;
    }
  }

  Future<Response?> sendOtpForVerificationScreen(
    String identity,
    String type,
  ) async {
    try {
      return await apiClient.postData(AppConstants.sendOtpForVerification, {
        "identity": identity,
        "identity_type": type,
        "check_user": "1",
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Send OTP error: $e');
      }
      return null;
    }
  }

  Future<Response?> verifyOtpForFirebaseOtpLogin({
    String? session,
    String? phone,
    String? code,
  }) async {
    try {
      return await apiClient.postData(AppConstants.firebaseOtpVerify, {
        "sessionInfo": session,
        'phoneNumber': phone,
        'code': code,
        "user_type": "provider-admin",
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Verify Firebase OTP error: $e');
      }
      return null;
    }
  }

  Future<Response?> sendOtpForForgetPassword(
    String identity,
    String identityType,
  ) async {
    try {
      return await apiClient.postData(AppConstants.sendOtpForForgetPassword, {
        "identity": identity,
        "identity_type": identityType,
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Send OTP forget password error: $e');
      }
      return null;
    }
  }

  Future<Response?> verifyOtpForVerificationScreen(
    String? identity,
    String identityType,
    String otp,
  ) async {
    try {
      return await apiClient.postData(
        AppConstants.verifyOtpForVerificationScreen,
        {"identity": identity, 'otp': otp, "identity_type": identityType},
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Verify OTP error: $e');
      }
      return null;
    }
  }

  Future<Response?> verifyOtpForForgetPassword(
    String identity,
    String identityType,
    String otp,
  ) async {
    try {
      return await apiClient.postData(
        AppConstants.verifyOtpForForgetPasswordScreen,
        {"identity": identity, 'otp': otp, "identity_type": identityType},
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Verify OTP forget password error: $e');
      }
      return null;
    }
  }

  Future<Response?> resetPassword(
    String identity,
    String identityType,
    String otp,
    String password,
    String confirmPassword,
    int isFirebaseOtp,
  ) async {
    try {
      return await apiClient.putData(AppConstants.resetPasswordUri, {
        "_method": "put",
        "identity": identity,
        "identity_type": identityType,
        "otp": otp,
        "password": password,
        "confirm_password": confirmPassword,
        "is_firebase_otp": isFirebaseOtp,
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Reset password error: $e');
      }
      return null;
    }
  }

  Future<Response?> updateToken() async {
    try {
      String? deviceToken;
      if (GetPlatform.isIOS) {
        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        NotificationSettings settings = await FirebaseMessaging.instance
            .requestPermission(
              alert: true,
              announcement: false,
              badge: true,
              carPlay: false,
              criticalAlert: false,
              provisional: false,
              sound: true,
            );
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          deviceToken = await _saveDeviceToken();
        }
      } else {
        deviceToken = await _saveDeviceToken();
      }

      FirebaseMessaging.instance.subscribeToTopic(AppConstants.topic);
      FirebaseMessaging.instance.subscribeToTopic(
        '${AppConstants.topic}-${Get.find<UserProfileController>().myZoneId}',
      );
      return await apiClient.postData(AppConstants.tokenUrl, {
        "_method": "put",
        "fcm_token": deviceToken,
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update token error: $e');
      }
      return null;
    }
  }

  Future<String?> _saveDeviceToken() async {
    String? deviceToken = '@';
    if (!GetPlatform.isWeb) {
      try {
        deviceToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        if (kDebugMode) {
          print('token error : $e');
        }
      }
    }
    if (deviceToken != null) {
      if (kDebugMode) {
        print('--------Device Token---------- $deviceToken');
      }
    }
    return deviceToken;
  }

  Future<void> unsubscribeToken() async {
    if (GetPlatform.isAndroid) {
      FirebaseMessaging.instance.unsubscribeFromTopic(
        '${AppConstants.topic}-${Get.find<UserProfileController>().myZoneId}',
      );
      apiClient.postData(AppConstants.tokenUrl, {
        "_method": "put",
        "fcm_token": "@",
      });
    }
  }

  Future<bool?> saveUserToken(String token) async {
    apiClient.token = token;
    apiClient.updateHeader(
      token,
      sharedPreferences.getString(AppConstants.languageCode),
    );
    return await sharedPreferences.setString(AppConstants.token, token);
  }

  String getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.token);
  }

  bool clearSharedData() {
    if (GetPlatform.isAndroid) {
      FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
      FirebaseMessaging.instance.unsubscribeFromTopic(
        '${AppConstants.topic}-${Get.find<UserProfileController>().myZoneId}',
      );
      apiClient.postData(AppConstants.tokenUrl, {
        "_method": "put",
        "fcm_token": "@",
      });
    }
    sharedPreferences.remove(AppConstants.token);
    sharedPreferences.remove(AppConstants.userAddress);
    apiClient.token = null;
    apiClient.updateHeader(null, null);

    // 🔥 Sign out of Firebase Auth too
    FirebaseAuthSyncService.syncOnLogout(); // fire and forget

    return true;
  }

  Future<void> saveUserNumberAndPassword(String number, String password) async {
    try {
      await sharedPreferences.setString(AppConstants.userPassword, password);
      await sharedPreferences.setString(AppConstants.userNumber, number);
    } catch (e) {
      rethrow;
    }
  }

  toggleNotificationSound(bool isNotification) {
    sharedPreferences.setBool(AppConstants.notification, isNotification);
  }

  bool isNotificationActive() {
    return sharedPreferences.getBool(AppConstants.notification) ?? true;
  }

  Future<bool> clearUserNumberAndPassword() async {
    await sharedPreferences.remove(AppConstants.userPassword);
    return await sharedPreferences.remove(AppConstants.userNumber);
  }

  Future<Response?> getZonesDataList() async {
    try {
      return await apiClient.getData(
        '${AppConstants.zoneUrl}?limit=200&offset=1',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get zones error: $e');
      }
      return null;
    }
  }

  String getUserNumber() {
    return sharedPreferences.getString(AppConstants.userNumber) ?? "";
  }

  String getUserPassword() {
    return sharedPreferences.getString(AppConstants.userPassword) ?? "";
  }

  void setRememberMeValue(bool rememberMeValue) {
    sharedPreferences.setBool(AppConstants.isRememberActive, rememberMeValue);
  }

  bool? getRememberMeValue() {
    return sharedPreferences.getBool(AppConstants.isRememberActive);
  }
}
