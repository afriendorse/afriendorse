import 'package:afriendorse/athlete/utils/core_export.dart';

class ValidationHelper {
  static String getValidPhone(String number, {bool withCountryCode = false}) {
    bool isValid = false;
    String phone = "";

    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      isValid = phoneNumber.isValid(type: PhoneNumberType.mobile);
      if (isValid) {
        phone = withCountryCode
            ? "+${phoneNumber.countryCode}${phoneNumber.nsn}"
            : phoneNumber.nsn.toString();
        if (kDebugMode) {
          print("Phone Number : $phone");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return phone;
  }

  static String getCountryCode(String number, {bool withCountryCode = false}) {
    bool isValid = false;
    String countryCode = "";

    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      isValid = phoneNumber.isValid(type: PhoneNumberType.mobile);
      if (isValid) {
        countryCode = "+${phoneNumber.countryCode}";
        if (kDebugMode) {
          print("Country Code : $countryCode");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return countryCode;
  }

  static String getValidCountryCode(
    String number, {
    bool withCountryCode = false,
  }) {
    bool isValid = false;
    String countryCode = "";

    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      isValid = phoneNumber.isValid(type: PhoneNumberType.mobile);
      if (isValid) {
        countryCode = "+${phoneNumber.countryCode.toString()}";
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return countryCode;
  }
}
