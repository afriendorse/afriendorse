enum SendOtpType {forgetPassword, firebase, verification}
enum SignUpPageStep {step1, step2, step3, step4, step5}
enum BusinessPlanType {commissionBase, subscriptionBase}
enum SubscriptionPaymentType {freeTrail, digital}
enum BookingDetailsTabControllerState {bookingDetails,status}
enum ServicemanTabControllerState {generalInfo,accountIno}
enum FileType{png,jpg,jpeg,csv,txt,xlx,xls,pdf}
enum ToasterMessageType {success, error, info}
enum ServiceType { all ,regular, repeat}
enum BookingEditType { regular , repeat, subBooking}
enum ServiceLocationType {customer, provider}
enum AddressLabel {home, office, others }
enum AddressType {service, billing }

enum HtmlType {
  termsAndCondition('terms-and-conditions'),
  aboutUs('about-us'),
  privacyPolicy('privacy-policy'),
  cancellationPolicy('cancellation-policy'),
  refundPolicy('refund-policy'),
  others('');

  final String value;
  const HtmlType(this.value);

  /// Convert string to enum
  static HtmlType? fromValue(String value) {
    return HtmlType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => others,
    );
  }
}

enum NoDataType {
  request,
  notification,
  faq,
  conversation,
  transaction,
  others,
  service,
  customPost,
  myBids,
  subscriptions,
  none,
  advertisement,
  paymentInfo
}

enum TransactionType {none ,payable, withdrawAble, adjust , adjustAndPayable, adjustWithdrawAble}
enum UserAccountStatus {deletable ,haveExistingBooking, needPaymentSettled}