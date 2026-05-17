import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class SuggestServiceInputField extends StatefulWidget {
  const SuggestServiceInputField({super.key});

  @override
  State<SuggestServiceInputField> createState() =>
      _SuggestServiceInputFieldState();
}

class _SuggestServiceInputFieldState extends State<SuggestServiceInputField> {
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _detailsFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SuggestServiceController>(
      builder: (suggestedServiceController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldTitle(
              title: "service_category".tr,
              requiredMark: true,
              fontSize: Dimensions.fontSizeExtraSmall,
              isPadding: false,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: Get.width,
                  height: 35,
                  decoration: BoxDecoration(
                    //color: Colors.green,
                    border: Border(
                      bottom: BorderSide(
                        color: !suggestedServiceController.isCategoryValidate
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      dropdownColor: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(5),
                      elevation: 2,
                      hint: Text(
                        suggestedServiceController.selectedCategoryName == ''
                            ? "select_category".tr
                            : suggestedServiceController.selectedCategoryName,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              suggestedServiceController.selectedCategoryName ==
                                  ''
                              ? Theme.of(context).textTheme.bodyMedium!.color!
                                    .withValues(alpha: 0.6)
                              : Theme.of(context).textTheme.bodyMedium!.color!
                                    .withValues(alpha: 0.8),
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: suggestedServiceController.serviceCategoryList.map(
                        (ServiceCategoryModel items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Row(
                              children: [
                                Text(
                                  items.name ?? "",
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (ServiceCategoryModel? newValue) {
                        suggestedServiceController.updateSelectedCategory(
                          newValue,
                        );
                        suggestedServiceController
                            .updateCategoryValidateValue();
                      },
                    ),
                  ),
                ),
                if (!suggestedServiceController.isCategoryValidate)
                  Text(
                    "select_your_desired_category".tr,
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

            CustomTextField(
              isEnabled: suggestedServiceController.isShowInputField,
              hintText: 'service_name'.tr,
              title: "service_name".tr,
              controller: suggestedServiceController.serviceNameController,
              focusNode: _categoryFocus,
              nextFocus: _detailsFocus,
              inputType: TextInputType.text,
              inputAction: TextInputAction.next,
              onValidate: (value) {
                return (value == null || value.isEmpty)
                    ? "provide_your_desired_service_name".tr
                    : null;
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

            CustomTextField(
              isEnabled: suggestedServiceController.isShowInputField,
              inputType: TextInputType.text,
              title: "provide_some_details".tr,
              focusNode: _detailsFocus,
              hintText: "write_something".tr,
              controller: suggestedServiceController.serviceDetailsController,
              onValidate: (value) {
                return (value == null || value.isEmpty)
                    ? "provide_some_details_about_your_service".tr
                    : null;
              },
            ),
          ],
        );
      },
    );
  }
}
