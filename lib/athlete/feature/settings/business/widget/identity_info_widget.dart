import 'package:afriendorse/athlete/feature/settings/business/controller/identity_controller.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class IdentityInfoWidget extends StatelessWidget {
  final TextEditingController identityNumberController;
  const IdentityInfoWidget({super.key, required this.identityNumberController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IdentityController>(
      builder: (identityController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'identity_information'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
              Text(
                'setup_your_identity_information'.tr,
                style: robotoLight.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            padding: EdgeInsets.zero,
                            dropdownColor: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(5),
                            elevation: 2,
                            hint: Text('select_identity_type'.tr),
                            value: identityController.selectedIdentityType,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: AppConstants.identityTypeList.map((
                              String items,
                            ) {
                              return DropdownMenuItem(
                                value: items,
                                child: Row(
                                  children: [
                                    Text(
                                      items.tr,
                                      style: robotoRegular.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              identityController.onChangeIdentityType(newValue);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                  CustomTextField(
                    inputType: TextInputType.text,
                    title: "identity_number".tr,
                    controller: identityNumberController,
                    hintText: "enter_identity_number".tr,
                    maxLines: 1,
                    onValidate: (value) {
                      return (value == null || value.isEmpty)
                          ? 'enter_identity_number'.tr
                          : null;
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFieldTitle(
                        title: "identity_image".tr,
                        requiredMark: true,
                        isPadding: false,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      ListView.separated(
                        separatorBuilder: (_, __) =>
                            SizedBox(height: Dimensions.paddingSizeSmall),
                        itemBuilder: (context, index) {
                          final pickedIdentityImage =
                              identityController
                                  .replacedIdentityImages?[index] !=
                              null;

                          return DottedBorderBox(
                            height: MediaQuery.of(context).size.width / 3,
                            width: MediaQuery.of(context).size.width,
                            onTap: () => showCustomDialog(
                              child: ImageDialog(
                                imageUrl:
                                    identityController
                                        .currentIdentityImages[index] ??
                                    "",
                              ),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                pickedIdentityImage
                                    ? Image.file(
                                        File(
                                          identityController
                                              .replacedIdentityImages![index]!
                                              .imageFile!
                                              .path,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CustomImage(
                                          fit: BoxFit.fill,
                                          image:
                                              identityController
                                                  .currentIdentityImages[index] ??
                                              "",
                                        ),
                                      ),

                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!pickedIdentityImage)
                                          Container(
                                            transform:
                                                Matrix4.translationValues(
                                                  8,
                                                  0,
                                                  0,
                                                ),
                                            child: IconButton(
                                              highlightColor:
                                                  Colors.transparent,
                                              onPressed: () {
                                                showCustomDialog(
                                                  child: ConfirmationDialog(
                                                    icon:
                                                        Images.deleteDialogIcon,
                                                    title:
                                                        'are_you_want_to_delete'
                                                            .tr,
                                                    onNoPressed: () {
                                                      Get.back();
                                                    },
                                                    onYesPressed: () {
                                                      identityController
                                                          .removeCurrentImage(
                                                            index,
                                                          );
                                                      Get.back();
                                                    },
                                                    description: '',
                                                  ),
                                                  barrierDismissible: true,
                                                  useSafeArea: true,
                                                );
                                              },
                                              icon: Container(
                                                transform:
                                                    Matrix4.translationValues(
                                                      8,
                                                      -8,
                                                      0,
                                                    ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        Dimensions
                                                            .radiusDefault,
                                                      ),
                                                  color: Theme.of(
                                                    context,
                                                  ).cardColor,
                                                  border: Border.all(
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                                ),
                                                padding: EdgeInsets.all(
                                                  Dimensions
                                                      .paddingSizeExtraSmall,
                                                ),
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                  size: Dimensions
                                                      .paddingSizeDefault,
                                                ),
                                              ),
                                            ),
                                          ),

                                        IconButton(
                                          highlightColor: Colors.transparent,
                                          onPressed: () {
                                            identityController
                                                .onReplacePickIdentityImage(
                                                  index: index,
                                                  isRemoved:
                                                      pickedIdentityImage,
                                                );
                                          },
                                          icon: Container(
                                            transform:
                                                Matrix4.translationValues(
                                                  8,
                                                  -8,
                                                  0,
                                                ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.radiusDefault,
                                                  ),
                                              color: Theme.of(
                                                context,
                                              ).cardColor,
                                              border: Border.all(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                            ),
                                            padding: EdgeInsets.all(
                                              Dimensions.paddingSizeExtraSmall,
                                            ),
                                            child: Icon(
                                              pickedIdentityImage
                                                  ? Icons.close
                                                  : Icons.edit,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              size:
                                                  Dimensions.paddingSizeDefault,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                            identityController.currentIdentityImages.length,
                      ),
                      SizedBox(height: Dimensions.paddingSizeSmall),

                      ListView.separated(
                        separatorBuilder: (_, __) =>
                            SizedBox(height: Dimensions.paddingSizeSmall),
                        itemBuilder: (context, index) {
                          return DottedBorderBox(
                            height: MediaQuery.of(context).size.width / 3,
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  child: Image.file(
                                    File(
                                      identityController
                                          .identityImages![index]!
                                          .path,
                                    ),
                                  ),
                                ),

                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      highlightColor: Colors.transparent,
                                      onPressed: () {
                                        identityController.pickIdentityImage(
                                          index: index,
                                          isRemoved: true,
                                        );
                                      },
                                      icon: Container(
                                        transform: Matrix4.translationValues(
                                          8,
                                          -8,
                                          0,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                          color: Theme.of(context).cardColor,
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                        ),
                                        padding: EdgeInsets.all(
                                          Dimensions.paddingSizeExtraSmall,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Theme.of(context).primaryColor,
                                          size: Dimensions.paddingSizeDefault,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                            identityController.identityImages?.length ?? 0,
                      ),
                      SizedBox(height: Dimensions.paddingSizeDefault),

                      if ((((identityController.identityImages?.length ?? 0) -
                                  identityController
                                      .deletedIdentityImages
                                      .length) +
                              (identityController
                                      .replacedIdentityImages
                                      ?.length ??
                                  0)) <
                          AppConstants.limitOfPickedIdentityImageNumber) ...[
                        DottedBorderBox(
                          height: MediaQuery.of(context).size.width / 3,
                          width: MediaQuery.of(context).size.width,
                          onTap: () {
                            identityController.pickIdentityImage();
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeExtraSmall,
                          ),
                          child: Text(
                            'Image format - jpg, png, jpeg, gif Image Size - max size 2 MB',
                            style: robotoLight.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color!
                                  .withValues(alpha: 0.7),
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
