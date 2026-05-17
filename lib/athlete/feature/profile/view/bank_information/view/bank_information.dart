import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BankInformation extends StatefulWidget {
  const BankInformation({super.key});

  @override
  State<BankInformation> createState() => _BankInformationState();
}

class _BankInformationState extends State<BankInformation> {
  final FocusNode _bankNameFocus = FocusNode();
  final FocusNode _branchNameFocus = FocusNode();
  final FocusNode _accountNoFocus = FocusNode();
  final FocusNode _accountHolderFocus = FocusNode();
  final FocusNode _routingNumberFocus = FocusNode();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Get.find<BankInfoController>().getBankInfoData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: "bank_information".tr),
      body: SingleChildScrollView(
        child: GetBuilder<BankInfoController>(
          builder: (bankInfoController) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: bankInfoController.bankNameController,
                      hintText: "bank_name_hint".tr,
                      title: "bank_name".tr,
                      inputType: TextInputType.text,
                      capitalization: TextCapitalization.words,
                      focusNode: _bankNameFocus,
                      nextFocus: _branchNameFocus,
                      onValidate: (value) {
                        return (value == null || value.isEmpty)
                            ? "bank_name_hint".tr
                            : null;
                      },
                    ),
                    const SizedBox(
                      height: Dimensions.paddingSizeExtraMoreLarge,
                    ),

                    CustomTextField(
                      controller: bankInfoController.branchNameController,
                      hintText: "branch_name_hint".tr,
                      title: "branch_name".tr,
                      inputType: TextInputType.text,
                      capitalization: TextCapitalization.words,
                      focusNode: _branchNameFocus,
                      nextFocus: _accountNoFocus,
                      onValidate: (value) {
                        return (value == null || value.isEmpty)
                            ? 'branch_name_hint'.tr
                            : null;
                      },
                    ),
                    const SizedBox(
                      height: Dimensions.paddingSizeExtraMoreLarge,
                    ),

                    CustomTextField(
                      controller: bankInfoController.accountNoController,
                      hintText: "account_no_hint".tr,
                      title: "account_no".tr,
                      maxLines: 1,
                      inputType: TextInputType.number,
                      focusNode: _accountNoFocus,
                      nextFocus: _accountHolderFocus,
                      onValidate: (value) {
                        return (value == null || value.isEmpty)
                            ? 'account_no_hint'.tr
                            : null;
                      },
                    ),
                    const SizedBox(
                      height: Dimensions.paddingSizeExtraMoreLarge,
                    ),

                    CustomTextField(
                      controller:
                          bankInfoController.accountHolderNameController,
                      hintText: "enter_account_holder_name".tr,
                      title: "account_holder_name".tr,
                      maxLines: 1,
                      capitalization: TextCapitalization.words,
                      inputAction: TextInputAction.next,
                      focusNode: _accountHolderFocus,
                      nextFocus: _routingNumberFocus,
                      onValidate: (value) {
                        return (value == null || value.isEmpty)
                            ? 'account_holder_name_hint'.tr
                            : null;
                      },
                    ),
                    const SizedBox(
                      height: Dimensions.paddingSizeExtraMoreLarge,
                    ),

                    CustomTextField(
                      controller: bankInfoController.routingNumberController,
                      hintText: "enter_account_routing_number".tr,
                      title: "routing_number".tr,
                      maxLines: 1,
                      capitalization: TextCapitalization.words,
                      focusNode: _routingNumberFocus,
                      onValidate: (value) {
                        return (value == null || value.isEmpty)
                            ? 'enter_account_routing_number'.tr
                            : null;
                      },
                    ),

                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    CustomButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          bankInfoController.updateBankInfo();
                        }
                      },
                      isLoading: bankInfoController.isLoading,
                      btnTxt: "save".tr,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
