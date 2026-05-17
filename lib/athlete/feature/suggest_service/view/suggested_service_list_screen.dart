import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/suggest_service/widgets/suggest_service_item_view.dart';
import 'package:afriendorse/athlete/feature/suggest_service/widgets/suggest_service_list_shimmer.dart';
import 'package:get/get.dart';

class SuggestedServiceListScreen extends StatefulWidget {
  const SuggestedServiceListScreen({super.key});

  @override
  State<SuggestedServiceListScreen> createState() =>
      _SuggestedServiceListScreenState();
}

class _SuggestedServiceListScreenState
    extends State<SuggestedServiceListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'service_request_list'.tr),
      body: GetBuilder<SuggestServiceController>(
        initState: (_) => Get.find<SuggestServiceController>()
            .getSuggestedServiceList(1, reload: true),
        builder: (suggestServiceController) {
          if (suggestServiceController.suggestedServiceModel != null) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Text(
                        '${'request'.tr} (${suggestServiceController.suggestedServiceList.length})',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                    ),

                    ListView.builder(
                      itemCount:
                          suggestServiceController.suggestedServiceList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return SuggestServiceItemView(
                          suggestedService: suggestServiceController
                              .suggestedServiceList[index],
                          index: index,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const SuggestServiceListShimmer();
          }
        },
      ),
    );
  }
}
