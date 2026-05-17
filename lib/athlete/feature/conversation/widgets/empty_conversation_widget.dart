import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class EmptyConversationWidget extends StatelessWidget {
  final bool fromSearch;
  const EmptyConversationWidget({super.key, this.fromSearch = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(
      builder: (conversationController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Images.emptyConversation, width: 50),

            const SizedBox(height: Dimensions.paddingSizeDefault * 2),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
              child: Text(
                fromSearch && conversationController.tabController?.index == 0
                    ? "no_customer_found_to_your_related_search".tr
                    : fromSearch &&
                          conversationController.tabController?.index == 1
                    ? "no_serviceman_found_to_your_related_search".tr
                    : "you_don't_have_any_conversation_yet".tr,
                style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          ],
        );
      },
    );
  }
}
