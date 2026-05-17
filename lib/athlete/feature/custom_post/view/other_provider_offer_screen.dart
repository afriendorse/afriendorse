import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/custom_post/widget/others_provider_offer_list_screen.dart';
import 'package:get/get.dart';

class OtherProviderOfferScreen extends StatelessWidget {
  const OtherProviderOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostController>(
      builder: (postController) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radiusLarge),
              topRight: Radius.circular(Dimensions.radiusLarge),
            ),
            color: Theme.of(context).cardColor,
          ),
          padding: const EdgeInsets.all(15),

          child: Column(
            children: [
              Container(
                width: 80,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).hintColor,
                ),
                margin: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeDefault,
                ),
              ),

              Text(
                "others_provider_offer".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              Expanded(
                child: !postController.isLoading
                    ? postController.providerOfferList.isNotEmpty
                          ? ListView.builder(
                              itemBuilder: (context, index) {
                                return OtherProviderOfferListItem(
                                  providerOfferData:
                                      postController.providerOfferList[index],
                                );
                              },
                              itemCount:
                                  postController.providerOfferList.length,
                            )
                          : Center(
                              child: Text('no_other_provider_bid_this_post'.tr),
                            )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        );
      },
    );
  }
}
