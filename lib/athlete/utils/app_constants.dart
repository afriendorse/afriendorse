import 'package:afriendorse/athlete/common/model/language_model.dart';
import 'package:afriendorse/athlete/utils/images.dart';

class AppConstants {
  static const String appName = 'AfriEndorse';
  static const String appUser = 'Athlete';
  static const String appVersion = '1.0';

  static const String sendTwoFactorEmailUri =
      '/api/v1/customer/auth/send-2fa-email';

  /// Flutter SDK: 3.35.1
  static const String baseUrl = 'https://admin.afriendorse.com';
  static const bool avoidMaintenanceMode = false;
  static const String configUri = '/api/v1/provider/config';
  static const String registerUri = '/api/v1/provider/auth/registration';
  static const String loginUri = '/api/v1/provider/auth/login';
  static const String dashboardUri = '/api/v1/provider/dashboard';
  static const String servicemanListUri = '/api/v1/provider/serviceman';
  static const String servicemanDetailsUri = '/api/v1/provider/serviceman';
  static const String servicemanDeleteUri =
      '/api/v1/provider/serviceman/delete';
  static const String addNewServicemanUri = '/api/v1/provider/serviceman';
  static const String servicemanUpdateUri = '/api/v1/provider/serviceman';
  static const String servicemanAssignUri =
      '/api/v1/provider/booking/assign-serviceman';
  static const String servicemanUpdateStatus =
      '/api/v1/provider/serviceman/status/update';
  static const String providerProfileUri = '/api/v1/provider/account/overview';
  static const String providerProfileUpdateUrl =
      '/api/v1/provider/update/profile';
  static const String bookingListUrl = '/api/v1/provider/booking';
  static const String bookingDetailsUrl = '/api/v1/provider/booking/';
  static const String subBookingDetailsUrl = '/api/v1/provider/booking/single/';
  static const String acceptBookingRequestUrl =
      '/api/v1/provider/booking/request-accept';

  static const String ignoreBookingRequestUrl =
      '/api/v1/provider/booking/request-ignore';
  static const String cancelSubBookingUrl =
      '/api/v1/provider/booking/single-repeat-cancel/';
  static const String changeBookingStatus =
      '/api/v1/provider/booking/status-update';
  static const String changeSubBookingStatus =
      '/api/v1/provider/booking/single-repeat-status-update';
  static const String bookingOTPNotificationUri =
      '/api/v1/provider/booking/opt/notification-send';
  static const String bankDetailsUrl = '/api/v1/provider/get-bank-details';
  static const String updateBankDetailsUrl =
      '/api/v1/provider/update-bank-details';
  static const String serviceCategoryUrl = '/api/v1/provider/category';
  static const String serviceSubcategoryUrl =
      '/api/v1/provider/category/childes';
  static const String serviceListBasedOnSubCategory =
      '/api/v1/provider/service/data/sub-category-wise';
  static const String serviceDetailsUrl = '/api/v1/provider/service';
  static const String serviceFaqUrl = '/api/v1/provider/faq';
  static const String changeSubscriptionStatusUrl =
      '/api/v1/provider/service/update-subscription';
  static const String changeScheduleUrl =
      '/api/v1/provider/booking/schedule-update';
  static const String subscriptionListUrl =
      '/api/v1/provider/subscribed/sub-categories';
  static const String notificationUrl = '/api/v1/provider/notifications';
  static const String zoneUrl = '/api/v1/zones';
  static const String tokenUrl = '/api/v1/provider/update/fcm-token';
  static const String withdrawRequestUrl = '/api/v1/provider/withdraw';
  static const String withdrawMethodRequest =
      '/api/v1/provider/withdraw/methods';
  static const String createChannel = '/api/v1/provider/chat/create-channel';
  static const String getChannelListUrl = '/api/v1/provider/chat/channel-list';
  static const String searchChannelListUrl =
      '/api/v1/provider/chat/channel-list-search';
  static const String getConversationUrl = '/api/v1/provider/chat/conversation';
  static const String sendMessageUrl = '/api/v1/provider/chat/send-message';
  static const String getServiceReviewList = '/api/v1/provider/service/review';
  static const String getProviderReviewList = '/api/v1/provider/review';
  static const String reviewReply = '/api/v1/provider/review-reply';
  static const String pagesDetailsApi = '/api/v1/customer/config/page-details';
  static const String getTransactionReportList =
      '/api/v1/provider/report/transaction';
  static const String getBookingReportList = '/api/v1/provider/report/booking';
  static const String getBusinessExpenseList =
      '/api/v1/provider/report/business/expense';
  static const String getBusinessEarningList =
      '/api/v1/provider/report/business/earning';
  static const String getBusinessOverviewList =
      '/api/v1/provider/report/business/overview';
  static const String submitNewServiceRequest =
      '/api/v1/provider/service-request';
  static const String getSuggestedServiceList =
      '/api/v1/provider/service-request';
  static const String getBookingPriceList =
      '/api/v1/provider/booking/service/info';
  static const String removeCartServiceFromServer =
      '/api/v1/provider/booking/service/edit/remove-service';
  static const String updateRegularBooking =
      '/api/v1/provider/booking/service/edit/update-booking';
  static const String updateRepeatBooking =
      '/api/v1/provider/booking/repeat/service/edit/update-booking';
  static const String updateBusinessBookingSettings =
      '/api/v1/provider/business-settings/set-business-settings';
  static const String getBusinessBookingSettings =
      '/api/v1/provider/business-settings/get-business-settings';

  static const String getServiceAvailabilitySettings =
      '/api/v1/provider/available-time-schedule';
  static const String updateServiceAvailabilitySettings =
      '/api/v1/provider/available-time-schedule';

  static const String geocodeUri = '/api/v1/customer/config/geocode-api';
  static const String searchLocationUri =
      '/api/v1/customer/config/place-api-autocomplete';
  static const String placeDetailsUri =
      '/api/v1/customer/config/place-api-details';

  static const String getCustomerPostList = '/api/v1/provider/post';
  static const String bidCustomerPost = '/api/v1/provider/post/bid';
  static const String declineCustomerPost = '/api/v1/provider/post';
  static const String withdrawBidRequest = '/api/v1/provider/post/bid/withdraw';
  static const String getProviderOfferList = '/api/v1/provider/post/bid';
  static const String getPostDetails = '/api/v1/provider/post/details';

  static const String sendOtpForVerification =
      '/api/v1/user/verification/send-otp';
  static const String sendOtpForForgetPassword =
      '/api/v1/user/forget-password/send-otp';
  static const String verifyOtpForForgetPasswordScreen =
      '/api/v1/user/forget-password/verify-otp';
  static const String verifyOtpForVerificationScreen =
      '/api/v1/user/verification/verify-otp';
  static const String firebaseOtpVerify =
      '/api/v1/user/verification/firebase-auth-verify';
  static const String resetPasswordUri = '/api/v1/user/forget-password/reset';
  static const String providerRemove = '/api/v1/provider/delete';
  static const String adjustTransaction = '/api/v1/provider/adjust';
  static const String paymentUri = '/api/v1/customer/config';
  static const String changeLanguage = '/api/v1/provider/change-language';

  static const String packageSubscriptionUri =
      '/api/v1/provider/subscription/package/list';
  static const String subscriptionDetailsUri =
      '/api/v1/provider/subscription/package/subscriber-details';
  static const String changeSubscriptionStatus =
      '/api/v1/provider/subscription/package/';
  static const String subscriptionTransactionListUri =
      '/api/v1/provider/subscription/transactions';

  static const String submitNewAdvertisement =
      '/api/v1/provider/advertisements/ads-store';
  static const String editAdvertisement =
      '/api/v1/provider/advertisements/update';
  static const String getAdvertisementList =
      '/api/v1/provider/advertisements/ads-list';
  static const String getAdvertisementDetails =
      '/api/v1/provider/advertisements/details';
  static const String deleteAdvertisement =
      '/api/v1/provider/advertisements/delete';
  static const String changeAdvertisementStatus =
      '/api/v1/provider/advertisements/status-update';
  static const String reSubmitAdvertisement =
      '/api/v1/provider/advertisements/store-re-submit';
  static const String getNotificationSettingList =
      '/api/v1/provider/configuration/get-notification-setting';
  static const String updateNotificationSetting =
      '/api/v1/provider/configuration/update-notification-status';
  static const String regularBookingInvoiceUrl =
      "/admin/booking/provider-invoice/";
  static const String fullRepeatBookingInvoiceUrl =
      "/admin/booking/provider-fullbooking-invoice/";
  static const String singleRepeatBookingInvoiceUrl =
      "/admin/booking/provider-fullbooking-single-invoice/";
  static const String subscriptionTransactionInvoice =
      '/admin/subscription/package/invoice/';
  static const String changeServiceLocation =
      '/api/v1/provider/booking/change-service-location';
  static const String updateTutorialUrl = '/api/v1/provider/update/tutorial';
  static const String updatePasswordUrl = '/api/v1/provider/update/password';

  static const String storePaymentMethod =
      '/api/v1/provider/payment-information/store';
  static const String statusUpdatePaymentMethod =
      '/api/v1/provider/payment-information/status-update';
  static const String markAsDefaultPaymentMethod =
      '/api/v1/provider/payment-information/default-status-update';
  static const String updatePaymentMethod =
      '/api/v1/provider/payment-information/update';
  static const String deletePaymentMethod =
      '/api/v1/provider/payment-information/delete';
  static const String getPaymentMethodList =
      '/api/v1/provider/payment-information/index';

  static const String theme = 'demand_theme';
  static const String token = 'demand_token';
  static const String countryCode = 'demand_country_code';
  static const String languageCode = 'demand_language_code';
  static const String userPassword = 'demand_user_password';
  static const String userAddress = 'demand_user_address';
  static const String userNumber = 'demand_user_number';
  static const String notification = 'demand_notification';
  static const String isRememberActive = 'is_remember_active';
  static const String notificationCount = 'notification_count';
  static const String initialLanguage = 'initial-language';
  static const String topic = 'provider-admin';
  static const String localizationKey = 'X-localization';

  static List<LanguageModel> languages = [
    LanguageModel(
      imageUrl: Images.us,
      languageName: 'English',
      countryCode: 'US',
      languageCode: 'en',
    ),
    LanguageModel(
      imageUrl: Images.ar,
      languageName: 'عربى',
      countryCode: 'SA',
      languageCode: 'ar',
    ),
    LanguageModel(
      imageUrl: Images.bn,
      languageName: 'বাংলা',
      countryCode: 'BD',
      languageCode: 'bn',
    ),
    LanguageModel(
      imageUrl: Images.india,
      languageName: 'Hindi',
      countryCode: 'IN',
      languageCode: 'hi',
    ),
  ];

  static final List<Map<String, String>> walletTransactionSortingList = [
    {'title': 'all', 'value': 'all'},
    {'title': 'withdrawn_amount', 'value': 'paid_commission'},

    {'title': 'paid_amount', 'value': 'paid_amount'},
  ];

  static Map<String, String> configHeader = {
    'Content-Type': 'application/json; charset=UTF-8',
    'zoneId': 'configuration',
  };

  static const List<String> identityTypeList = [
    "passport",
    "nin",
    "trade_license",
    "driving_license",
  ];
  static const int limitOfPickedIdentityImageNumber = 5;
  static const double limitOfPickedImageSizeInMB = 2;
  static const double limitOfPickedVideoSizeInMB = 50;
  static const double balanceInputLength = 10;

  static const double maxLimitOfFileSentINConversation = 25;
  static const double maxLimitOfTotalFileSent = 5;
  static const double maxSizeOfASingleFile = 10;

  static const String businessInfoTutorialKey = 'business_information';
  static const String serviceSubscriptionTutorialKey = 'service_subscription';
  static const String serviceAvailabilityTutorialKey = 'service_availability';
  static const String paymentInfoTutorialKey = 'payment_information';
}
