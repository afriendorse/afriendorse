import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ProviderReviewScreen extends StatefulWidget {
  const ProviderReviewScreen({super.key});

  @override
  State<ProviderReviewScreen> createState() => _ProviderReviewScreenState();
}

class _ProviderReviewScreenState extends State<ProviderReviewScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<ReviewController>().getProviderReview(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'reviews'.tr),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColorLight,
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: () async {
          await Get.find<ReviewController>().getProviderReview(1);
        },
        child: GetBuilder<ReviewController>(
          builder: (reviewController) {
            return reviewController.providerReviewList != null
                ? CustomScrollView(
                    controller: reviewController.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault,
                          ),
                          child: Column(
                            children: [
                              ReviewHeading(
                                rating: reviewController.providerRating,
                                showTitle: true,
                              ),

                              const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),
                              ReviewLinearChart(
                                rating:
                                    reviewController.providerRating ??
                                    Rating(
                                      ratingCount: 0,
                                      averageRating: 0,
                                      ratingGroupCount: [],
                                    ),
                              ),

                              const SizedBox(
                                height: Dimensions.paddingSizeLarge,
                              ),
                              Divider(
                                height: 0.5,
                                color: Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.5),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeLarge,
                              ),
                              reviewController.providerReviewList != null &&
                                      reviewController
                                          .providerReviewList!
                                          .isNotEmpty
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: reviewController
                                          .providerReviewList!
                                          .length,
                                      itemBuilder: (context, index) {
                                        return ReviewItem(
                                          review: reviewController
                                              .providerReviewList!
                                              .elementAt(index),
                                          backgroundColor: Theme.of(
                                            context,
                                          ).cardColor,
                                        );
                                      },
                                    )
                                  : const EmptyReviewWidget(),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Center(
                          child: reviewController.isLoading
                              ? const CircularProgressIndicator()
                              : const SizedBox(),
                        ),
                      ),
                    ],
                  )
                : const ProviderReviewShimmer();
          },
        ),
      ),
    );
  }
}
