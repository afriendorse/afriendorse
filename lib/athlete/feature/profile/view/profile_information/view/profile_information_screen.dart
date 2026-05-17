import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});
  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final GlobalKey<FormState> accountInfo = GlobalKey<FormState>();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Get.find<UserProfileController>().getProviderInfo(reload: true);
    Get.find<UserProfileController>().resetImage();

    emailAddressController.text =
        Get.find<UserProfileController>()
            .providerModel!
            .content!
            .providerInfo!
            .owner!
            .email ??
        "";
    phoneNumberController.text =
        Get.find<UserProfileController>()
            .providerModel!
            .content!
            .providerInfo!
            .owner!
            .phone ??
        "";
  }

  @override
  void dispose() {
    super.dispose();
    Get.find<UserProfileController>().passwordController?.clear();
    Get.find<UserProfileController>().confirmPasswordController?.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: "edit_profile".tr),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: GetBuilder<UserProfileController>(
                  builder: (userProfileController) {
                    return Padding(
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault,
                      ),
                      child: Form(
                        key: accountInfo,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: Dimensions.paddingSizeSmall),
                            //TextFieldTitle(title: "email".tr, requiredMark: true, isPadding: false,),
                            CustomTextField(
                              title: "email".tr,
                              isEnabled: false,
                              controller: emailAddressController,
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraMoreLarge,
                            ),

                            // NonEditableTextField(text: userProfileController.providerModel!.content!.providerInfo!.owner!.email??"",),
                            CustomTextField(
                              title: "phone_number".tr,
                              isEnabled: false,
                              controller: phoneNumberController,
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraMoreLarge,
                            ),

                            //TextFieldTitle(title: "phone_number".tr, requiredMark: true, isPadding: false,),

                            //NonEditableTextField(text: userProfileController.providerModel!.content!.providerInfo!.owner!.phone??"",),
                            CustomTextField(
                              title: "password".tr,
                              isShowSuffixIcon: true,
                              controller:
                                  userProfileController.passwordController,
                              hintText: "******",
                              isPassword: true,
                              focusNode: _passwordFocus,
                              nextFocus: _confirmPasswordFocus,
                              onValidate: (value) {
                                return FormValidationHelper().isValidPassword(
                                  value,
                                );
                              },
                            ),

                            const SizedBox(
                              height: Dimensions.paddingSizeExtraMoreLarge,
                            ),

                            CustomTextField(
                              title: "confirm_password".tr,
                              isShowSuffixIcon: true,
                              controller: userProfileController
                                  .confirmPasswordController,
                              hintText: "******",
                              isPassword: true,
                              focusNode: _confirmPasswordFocus,
                              inputAction: TextInputAction.done,
                              onValidate: (value) {
                                return (value == null || value.isEmpty)
                                    ? "field_cannot_be_empty".tr
                                    : value !=
                                          userProfileController
                                              .passwordController
                                              ?.text
                                    ? "confirm_password_does_not_matched".tr
                                    : null;
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            GetBuilder<UserProfileController>(
              builder: (userProfileController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  child: CustomButton(
                    isLoading: userProfileController.isLoading,
                    btnTxt: "save".tr,
                    onPressed: () {
                      if (accountInfo.currentState!.validate()) {
                        userProfileController.updatePassword();
                      }
                    },
                  ),
                );
              },
            ),
            SizedBox(height: Dimensions.paddingSizeSmall),
          ],
        ),
      ),
    );
  }
}
