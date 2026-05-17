import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ServicemanAccountInfo extends StatefulWidget {
  final bool isFromEditScreen;
  const ServicemanAccountInfo({super.key, this.isFromEditScreen = false});

  @override
  State<ServicemanAccountInfo> createState() => _ServicemanAccountInfoState();
}

class _ServicemanAccountInfoState extends State<ServicemanAccountInfo> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicemanSetupController>(
      builder: (servicemanSetupController) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Form(
              key: servicemanSetupController.addServiceManAccountInfoValidation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  CustomTextField(
                    inputType: TextInputType.text,
                    hintText: "serviceman_email_address".tr,
                    title: "email".tr,
                    focusNode: _emailFocus,
                    nextFocus: _passwordFocus,
                    maxLines: 1,
                    controller: servicemanSetupController.emailController,
                    onValidate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'empty_email_hint'.tr;
                      } else {
                        return FormValidationHelper().isValidEmail(value);
                      }
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                  CustomTextField(
                    inputType: TextInputType.text,
                    hintText: "********",
                    title: "password".tr,
                    focusNode: _passwordFocus,
                    nextFocus: _confirmPasswordFocus,
                    maxLines: 1,
                    isPassword: true,
                    isShowSuffixIcon: true,
                    controller: servicemanSetupController.passController,
                    onValidate: (value) {
                      return FormValidationHelper().isValidPassword(value);
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                  CustomTextField(
                    inputType: TextInputType.text,
                    hintText: "********",
                    title: "confirm_password".tr,
                    focusNode: _confirmPasswordFocus,
                    maxLines: 1,
                    isPassword: true,
                    isShowSuffixIcon: true,
                    controller:
                        servicemanSetupController.confirmPasswordController,
                    onValidate: (value) {
                      return (value == null || value.isEmpty)
                          ? "field_cannot_be_empty".tr
                          : value !=
                                servicemanSetupController.passController.text
                          ? "confirm_password_does_not_matched".tr
                          : null;
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge * 2),

                  CustomButton(
                    btnTxt: "save".tr,
                    isLoading: servicemanSetupController.isLoading,
                    onPressed: () =>
                        saveServicemanData(servicemanSetupController),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void saveServicemanData(
    ServicemanSetupController servicemanSetupController,
  ) async {
    String numberWithCountryCode;
    if (servicemanSetupController
        .addServiceManAccountInfoValidation
        .currentState!
        .validate()) {
      String valid = ValidationHelper.getValidPhone(
        "${servicemanSetupController.countryDialCode!}${servicemanSetupController.phoneController.value.text}",
      );

      if (servicemanSetupController.firstNameController.text.isNotEmpty &&
          servicemanSetupController.lastNameController.text.isNotEmpty &&
          valid.isNotEmpty &&
          servicemanSetupController.selectedIdentityType != "" &&
          servicemanSetupController.identityNumberController.text.isNotEmpty &&
          (servicemanSetupController.identificationImage.isNotEmpty ||
              servicemanSetupController.selectedIdentityImageList.isNotEmpty)) {
        if (!widget.isFromEditScreen) {
          numberWithCountryCode =
              servicemanSetupController.countryDialCode! +
              ValidationHelper.getValidPhone(
                "${servicemanSetupController.countryDialCode!}${servicemanSetupController.phoneController.value.text}",
              );

          if (kDebugMode) {
            print("From Add Page : $numberWithCountryCode");
          }
        } else {
          numberWithCountryCode =
              servicemanSetupController.countryDialCode! +
              servicemanSetupController.phoneController.value.text;
          if (kDebugMode) {
            print("From Edit Page : $numberWithCountryCode");
          }
        }

        ServicemanBody servicemanBody = ServicemanBody(
          firstName: servicemanSetupController.firstNameController.text,
          lastName: servicemanSetupController.lastNameController.text,
          email: servicemanSetupController.emailController.text,
          phone: numberWithCountryCode,
          password: servicemanSetupController.passController.text,
          confirmedPassword:
              servicemanSetupController.confirmPasswordController.text,
          identityNumber:
              servicemanSetupController.identityNumberController.text,
          identityType: servicemanSetupController.selectedIdentityType,
        );

        String servicemanId;

        if (widget.isFromEditScreen) {
          if (servicemanSetupController.currentServicemanIndex != null) {
            servicemanId = servicemanSetupController
                .servicemanList![servicemanSetupController
                    .currentServicemanIndex!]
                .serviceman!
                .id!;
          } else {
            servicemanId =
                Get.find<ServicemanDetailsController>().servicemanModel!.id!;
          }
          servicemanSetupController.editServicemanInfoWithPassword(
            servicemanBody,
            servicemanId,
          );
        } else {
          servicemanSetupController.addNewServiceman(servicemanBody);
        }
      } else {
        showCustomSnackBar(
          'fill_in_all_required_field'.tr,
          type: ToasterMessageType.info,
        );
      }
    }
  }
}
