import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/custom_post/widget/custom_post_list_view.dart';
import 'package:get/get.dart';

class CustomerRequestListScreen extends StatefulWidget {
  const CustomerRequestListScreen({super.key});

  @override
  State<CustomerRequestListScreen> createState() =>
      _CustomerRequestListScreenState();
}

class _CustomerRequestListScreenState extends State<CustomerRequestListScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<PostController>().setTabControllerIndex(index: 0);

    // Defer the data loading until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.find<PostController>().tabController!.index == 0) {
        Get.find<PostController>().getCustomerPostList(
          1,
          "new_request",
          reload: false,
          fromBid: false,
        );
      } else {
        Get.find<PostController>().getCustomerPostList(
          1,
          "placed_offer",
          reload: false,
          fromBid: true,
        );
      }
    });

    Get.find<SplashController>().updateCustomBookingRedDotButtonStatus(
      status: false,
      shouldUpdate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "custom_booking_request".tr,
        onBackPressed: () {
          if (Navigator.canPop(context)) {
            Get.back();
          } else {
            Get.offNamed(RouteHelper.initial);
          }
        },
      ),

      body: GetBuilder<PostController>(
        builder: (postController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.blue)),
                ),
                child: TabBar(
                  unselectedLabelColor: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                  indicatorColor: Theme.of(context).primaryColor,
                  controller: postController.tabController,
                  labelColor: Theme.of(context).primaryColorLight,
                  labelStyle: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                  labelPadding: EdgeInsets.zero,
                  tabs: [
                    SizedBox(
                      height: 45,
                      child: Center(
                        child: Text("new_request".tr, style: robotoMedium),
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      child: Center(
                        child: Text("my_bids".tr, style: robotoMedium),
                      ),
                    ),
                  ],

                  onTap: (index) {
                    if (index == 0) {
                      Get.find<PostController>().getCustomerPostList(
                        1,
                        "new_request",
                        fromBid: false,
                      );
                    } else {
                      Get.find<PostController>().getCustomerPostList(
                        1,
                        "placed_offer",
                        fromBid: true,
                      );
                    }
                  },
                ),
              ),

              Expanded(
                child: GetBuilder<PostController>(
                  builder: (postController) {
                    if (postController.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return CustomPostListview(
                        myPost: postController.tabController!.index == 0
                            ? postController.postList ?? []
                            : postController.bidPostList ?? [],
                        newRequest: postController.tabController!.index == 0
                            ? true
                            : false,
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
