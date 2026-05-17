import 'package:afriendorse/athlete/helper/validation_helper.dart';
import 'package:get/get.dart';

class FormValidationHelper {
  String? isValidEmailOrPhone(String value) {
    if (GetUtils.isPhoneNumber(value) &&
        ValidationHelper.getValidPhone(value) != "") {
      return null;
    } else if (GetUtils.isPhoneNumber(value) &&
        value.length > 10 &&
        ValidationHelper.getValidPhone(value) == "") {
      return "enter_valid_phone_number_with_country_code".tr;
    } else if (GetUtils.isEmail(value)) {
      return null;
    } else {
      return "enter_email_address_or_phone_number".tr;
    }
  }

  String? isValidPhone(String value) =>
      ValidationHelper.getValidPhone(value) == ""
      ? "invalid_phone_number".tr
      : null;

  String? isValidEmail(String? value) =>
      (value != null && !GetUtils.isEmail(value))
      ? 'enter_valid_email_address'.tr
      : null;

  String? isValidLength(String value) {
    if (value.length <= 2) {
      return 'enter_valid_information'.tr;
    }
    return null;
  }

  String? isValidFirstName(String value) {
    if (value.length <= 2) {
      return 'enter_your_first_name'.tr;
    }
    return null;
  }

  String? isValidLastName(String value) {
    if (value.length <= 2) {
      return 'enter_your_last_name'.tr;
    }
    return null;
  }

  String? isValidPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_cannot_be_empty'.tr;
    } else if (value.length > 7) {
      return null;
    } else {
      return 'password_should_be'.tr;
    }
  }

  String? isValidServicemanIdentityNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_identity_number'.tr;
    } else {
      return null;
    }
  }

  String? validateDynamicTextFiled(String inputValue, String validateText) {
    if (inputValue.isEmpty) {
      return validateText.tr;
    }
    return null;
  }
}
