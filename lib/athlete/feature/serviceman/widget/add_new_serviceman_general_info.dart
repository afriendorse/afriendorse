import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ServiceManGeneralInfo extends StatefulWidget {
  final bool isFromEditScreen;
  const ServiceManGeneralInfo({super.key, this.isFromEditScreen = false});

  @override
  State<ServiceManGeneralInfo> createState() => _ServiceManGeneralInfoState();
}

class _ServiceManGeneralInfoState extends State<ServiceManGeneralInfo> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _identityFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    Get.find<ServicemanSetupController>().resetOtherValidationData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GetBuilder<ServicemanSetupController>(
        builder: (servicemanSetupController) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Form(
              key: servicemanSetupController.addServiceManGeneralInfoValidation,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: Get.width),
                      servicemanSetupController.profileImage == '' &&
                              servicemanSetupController.pickedProfileImage ==
                                  null
                          ? DottedBorderBox(
                              onTap: () => servicemanSetupController
                                  .pickProfileImage(false),
                            )
                          : servicemanSetupController.profileImage != '' &&
                                servicemanSetupController.pickedProfileImage ==
                                    null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  CustomImage(
                                    height: 100,
                                    width: 100,
                                    image:
                                        servicemanSetupController.profileImage,
                                  ),

                                  Container(
                                    width: 35,
                                    height: 35,
                                    padding: const EdgeInsets.only(
                                      bottom: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).disabledColor,
                                      ),
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: IconButton(
                                      onPressed: () => servicemanSetupController
                                          .pickProfileImage(false),
                                      icon: Icon(
                                        Icons.edit,
                                        color: light.cardColor,
                                        size: 17,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(
                                      servicemanSetupController
                                          .pickedProfileImage!
                                          .path,
                                    ),
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: 100,
                                  ),
                                ),

                                Positioned(
                                  top: -10,
                                  right: -10,
                                  child: IconButton(
                                    onPressed: () => servicemanSetupController
                                        .pickProfileImage(true),
                                    icon: const Icon(
                                      Icons.highlight_remove_rounded,
                                      color: Colors.red,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      if (!servicemanSetupController.isProfilePicValid)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'fill_required_field'.tr,
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ),

                      SizedBox(
                        width: 180,
                        child: Text(
                          "image_validation_text_1".tr,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          inputType: TextInputType.text,
                          controller:
                              servicemanSetupController.firstNameController,
                          focusNode: _firstNameFocus,
                          nextFocus: _lastNameFocus,
                          capitalization: TextCapitalization.words,
                          hintText: "serviceman_first_name".tr,
                          title: "first_name".tr,

                          maxLines: 1,
                          onValidate: (value) {
                            return FormValidationHelper().isValidFirstName(
                              value ?? "",
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeLarge),
                      Expanded(
                        child: CustomTextField(
                          inputType: TextInputType.text,
                          focusNode: _lastNameFocus,
                          nextFocus: _phoneFocus,
                          controller:
                              servicemanSetupController.lastNameController,
                          hintText: "serviceman_last_name".tr,
                          title: "last_name".tr,
                          capitalization: TextCapitalization.words,

                          maxLines: 1,
                          onValidate: (value) {
                            return FormValidationHelper().isValidLastName(
                              value ?? "",
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  CustomTextField(
                    onCountryChanged: (CountryCode countryCode) {
                      servicemanSetupController.countryDialCode =
                          countryCode.dialCode!;
                    },
                    countryDialCode: servicemanSetupController.countryDialCode,
                    hintText: 'serviceman_phone_number'.tr,
                    controller: servicemanSetupController.phoneController,
                    inputType: TextInputType.phone,
                    focusNode: _phoneFocus,
                    onValidate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'phone_number_hint'.tr;
                      } else {
                        return FormValidationHelper().isValidPhone(
                          servicemanSetupController.countryDialCode! + value,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  TextFieldTitle(
                    title: "serviceman_identity_type".tr,
                    requiredMark: true,
                    isPadding: false,
                  ),
                  Container(
                    width: Get.width,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Theme.of(context).hintColor),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        dropdownColor: Theme.of(context).focusColor,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                        elevation: 2,
                        hint: Text(
                          servicemanSetupController.selectedIdentityType == ''
                              ? "select_serviceman_identity".tr
                              : servicemanSetupController
                                    .selectedIdentityType
                                    .tr,
                          style: robotoRegular.copyWith(
                            color:
                                servicemanSetupController
                                        .selectedIdentityType ==
                                    ''
                                ? Theme.of(context).textTheme.bodyLarge!.color!
                                      .withValues(alpha: 0.6)
                                : Theme.of(context).textTheme.bodyLarge!.color!
                                      .withValues(alpha: 0.8),
                          ),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: AppConstants.identityTypeList.map((
                          String items,
                        ) {
                          return DropdownMenuItem(
                            value: items,
                            child: Row(children: [Text(items.tr)]),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          servicemanSetupController.setValue(newValue!);
                        },
                      ),
                    ),
                  ),
                  if (!servicemanSetupController.isIdentityTypeValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        'fill_required_field'.tr,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ),
                  const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                  CustomTextField(
                    inputType: TextInputType.text,
                    hintText: "serviceman_identity_number".tr,
                    controller:
                        servicemanSetupController.identityNumberController,
                    maxLines: 1,
                    focusNode: _identityFocus,
                    title: "serviceman_identity".tr,
                    onValidate: (value) {
                      return FormValidationHelper()
                          .isValidServicemanIdentityNumber(value);
                    },
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  servicemanSetupController.identificationImage.isNotEmpty
                      ? ListView.builder(
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeExtraSmall,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault,
                                ),
                                child: CustomImage(
                                  height: 180,
                                  width: Get.width,
                                  image: servicemanSetupController
                                      .identificationImage[index],
                                ),
                              ),
                            );
                          },
                          itemCount: servicemanSetupController
                              .identificationImage
                              .length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                        )
                      : const SizedBox.shrink(),

                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return PickedIdentityImage(index: index);
                    },
                    itemCount: servicemanSetupController
                        .selectedIdentityImageList
                        .length,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  servicemanSetupController.selectedIdentityImageList.length <
                          AppConstants.limitOfPickedIdentityImageNumber
                      ? DottedBorderBox(
                          height: 100,
                          width: Get.width,
                          onTap: () => servicemanSetupController
                              .pickIdentityImage(false),
                        )
                      : const SizedBox.shrink(),
                  if (!servicemanSetupController.isServicemanIdentityImageValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        'fill_required_field'.tr,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                  servicemanSetupController
                          .isLoading //&& widget.isFromEditScreen
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Theme.of(context).hoverColor,
                            ),
                          ],
                        )
                      : CustomButton(
                          fontSize: Dimensions.fontSizeDefault,
                          btnTxt: !widget.isFromEditScreen
                              ? "next_btn".tr
                              : 'save'.tr,
                          onPressed: () {
                            _validate(servicemanSetupController);
                          },
                        ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _validate(ServicemanSetupController servicemanSetupController) async {
    servicemanSetupController.checkOtherValidationField();
    if (servicemanSetupController
            .addServiceManGeneralInfoValidation
            .currentState!
            .validate() &&
        servicemanSetupController.isIdentityTypeValid &&
        servicemanSetupController.isServicemanIdentityImageValid &&
        servicemanSetupController.isProfilePicValid) {
      String numberWithCountryCode =
          servicemanSetupController.countryDialCode! +
          ValidationHelper.getValidPhone(
            "${servicemanSetupController.countryDialCode!}${servicemanSetupController.phoneController.value.text}",
          );

      if (!widget.isFromEditScreen) {
        //servicemanSetupController.setValidGeneralInfo();
        servicemanSetupController.controller!.index = 1;
        servicemanSetupController.updateTabControllerValue(
          ServicemanTabControllerState.accountIno,
        );
      } else {
        ServicemanBody servicemanBody = ServicemanBody(
          firstName: servicemanSetupController.firstNameController.text,
          lastName: servicemanSetupController.lastNameController.text,
          email: servicemanSetupController.emailController.text,
          phone: numberWithCountryCode,
          identityNumber:
              servicemanSetupController.identityNumberController.text,
          identityType: servicemanSetupController.selectedIdentityType,
        );

        String servicemanId;

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
        servicemanSetupController.editServicemanInfoWithoutPassword(
          servicemanBody,
          servicemanId,
        );
      }
    }
  }
}

class PickedIdentityImage extends StatelessWidget {
  final int index;
  const PickedIdentityImage({super.key, required this.index});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicemanSetupController>(
      builder: (servicemanSetupController) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.fontSizeExtraSmall,
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(
                    servicemanSetupController
                        .selectedIdentityImageList[index]
                        .file
                        .path,
                  ),
                  fit: BoxFit.cover,
                  height: 120,
                  width: Get.width,
                ),
              ),

              Positioned(
                top: -10,
                right: -10,
                child: IconButton(
                  onPressed: () => servicemanSetupController.pickIdentityImage(
                    true,
                    index: index,
                  ),
                  icon: const Icon(
                    Icons.highlight_remove_rounded,
                    color: Colors.red,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
