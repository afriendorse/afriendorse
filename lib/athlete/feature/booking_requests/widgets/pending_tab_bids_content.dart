// pending_tab_bids_content.dart
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/custom_post/widget/custom_post_list_view.dart';
import 'package:get/get.dart';

class PendingTabBidsContent extends StatefulWidget {
  const PendingTabBidsContent({super.key});

  @override
  State<PendingTabBidsContent> createState() => _PendingTabBidsContentState();
}

class _PendingTabBidsContentState extends State<PendingTabBidsContent> {
  @override
  void initState() {
    super.initState();

    // Only fetch if no preloaded data exists
    final controller = Get.find<PostController>();
    if (controller.bidPostList == null || controller.bidPostList!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.getCustomerPostList(
          1,
          "placed_offer",
          reload: true,
          fromBid: true,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostController>(
      builder: (postController) {
        // Show data immediately if available
        if (postController.bidPostList != null &&
            postController.bidPostList!.isNotEmpty) {
          return CustomPostListview(
            myPost: postController.bidPostList!,
            newRequest: false,
          );
        }

        // Only show loading if truly empty
        if (postController.loading &&
            (postController.bidPostList?.isEmpty ?? true)) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomPostListview(myPost: [], newRequest: false);
      },
    );
  }
}
