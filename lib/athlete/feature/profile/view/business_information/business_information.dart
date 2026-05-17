import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BusinessInformation extends StatelessWidget {
  const BusinessInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: "Business_Information".tr),
      body: SingleChildScrollView(
        child: GetBuilder<UserProfileController>(
          builder: (userController) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: userController.providerModel == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFieldTitle(title: "identity_type".tr),
                        NonEditableTextField(
                          text: userController
                              .providerModel!
                              .content!
                              .providerInfo!
                              .owner!
                              .identificationType!,
                        ),

                        TextFieldTitle(title: "identity_number".tr),
                        NonEditableTextField(
                          text: userController
                              .providerModel!
                              .content!
                              .providerInfo!
                              .owner!
                              .identificationNumber!,
                        ),

                        const SizedBox(height: 20),
                        if (userController
                                    .providerModel!
                                    .content!
                                    .providerInfo!
                                    .owner!
                                    .identificationImageFullPath !=
                                null &&
                            userController
                                .providerModel!
                                .content!
                                .providerInfo!
                                .owner!
                                .identificationImageFullPath!
                                .isNotEmpty)
                          GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      ResponsiveHelper.isTab(context) ? 2 : 1,
                                  crossAxisSpacing: Dimensions.paddingSizeSmall,
                                  mainAxisSpacing: Dimensions.paddingSizeSmall,
                                  mainAxisExtent: 200,
                                ),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () => showCustomDialog(
                                  child: ImageDialog(
                                    imageUrl:
                                        userController
                                            .providerModel
                                            ?.content
                                            ?.providerInfo
                                            ?.owner
                                            ?.identificationImageFullPath?[index] ??
                                        "",
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CustomImage(
                                    fit: BoxFit.fill,
                                    image:
                                        userController
                                            .providerModel
                                            ?.content
                                            ?.providerInfo
                                            ?.owner
                                            ?.identificationImageFullPath?[index] ??
                                        "",
                                  ),
                                ),
                              );
                            },
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: userController
                                .providerModel
                                ?.content
                                ?.providerInfo
                                ?.owner
                                ?.identificationImageFullPath
                                ?.length,
                          ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        Row(
                          children: [
                            const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall,
                            ),
                            Text(
                              "you_can't_change_this_info".tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.5),
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
