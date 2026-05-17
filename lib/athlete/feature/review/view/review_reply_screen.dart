import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ReviewReplyScreen extends StatefulWidget {
  final Review? review;
  final String? fromPage;
  const ReviewReplyScreen({super.key, this.review, this.fromPage});

  @override
  State<ReviewReplyScreen> createState() => _ReviewReplyScreenState();
}

class _ReviewReplyScreenState extends State<ReviewReplyScreen> {
  var replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    replyController.text = widget.review?.reviewReply?.reply ?? "";
  }

  @override
  Widget build(BuildContext context) {
    var config = Get.find<SplashController>().configModel.content;

    return Scaffold(
      appBar: CustomAppBar(
        title: "review_reply".tr,
        subtitle: "# ${widget.review?.readableId ?? ""}",
      ),
      body: GetBuilder<ReviewController>(
        builder: (reviewController) {
          return Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),
                            ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(Dimensions.radiusSmall),
                              ),
                              child: CustomImage(
                                height: 70,
                                width: 70,
                                image:
                                    widget.review?.service?.thumbnailFullPath ??
                                    "",
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeDefault,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "booking_id".tr,
                                        style: robotoRegular.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeSmall + 1,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: Dimensions.paddingSizeExtraSmall,
                                      ),

                                      Text(
                                        " # ${widget.review?.booking?.readableId ?? ""}",
                                        style: robotoRegular.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeSmall + 1,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.review?.service?.name ?? "",
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall + 1,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                          ?.withValues(alpha: 0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  SizedBox(
                                    height: 15,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            RatingBar(
                                              rating:
                                                  widget.review?.reviewRating ??
                                                  0,
                                            ),
                                            const SizedBox(
                                              width: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            Text(
                                              widget.review?.reviewRating!
                                                      .toString() ??
                                                  "",
                                              style: robotoBold.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(
                                                  context,
                                                ).hintColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeLarge,
                          ),
                          child: ReadMoreText(
                            widget.review?.reviewComment ?? "",
                            trimCollapsedText: "see_more".tr,
                            trimExpandedText: "  ${"see_less".tr}",
                            trimMode: TrimMode.Line,
                            trimLines: 5,
                            style: robotoRegular.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.justify,
                            moreStyle: robotoMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                            lessStyle: robotoMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        CustomTextFormField(
                          enabled:
                              config?.providerCanReplyReview == 1 &&
                              widget.review?.isActive == 1,
                          hintText: "write_your_reply_here".tr,
                          inputType: TextInputType.text,
                          maxLines: 4,
                          borderRadius: Dimensions.radiusSmall,
                          controller: replyController,
                          fillColor: Theme.of(context).cardColor,
                        ),

                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        config?.providerCanReplyReview == 0 ||
                                widget.review?.isActive == 0
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.warning_rounded,
                                    color: Theme.of(context).colorScheme.error,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  Flexible(
                                    child: Text(
                                      config?.providerCanReplyReview == 0
                                          ? 'you_cant_reply_because_admin_turn_off_reply_option'
                                                .tr
                                          : "you_cant_reply_because_admin_turn_off_this_review"
                                                .tr,
                                      maxLines: 5,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),

                        const SizedBox(
                          height: Dimensions.paddingSizeExtraMoreLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: CustomButton(
                    isLoading: reviewController.isLoading,
                    btnTxt: widget.review?.reviewReply != null
                        ? "update_reply".tr
                        : "submit".tr,
                    onPressed:
                        config?.providerCanReplyReview == 1 &&
                            widget.review?.isActive == 1
                        ? () async {
                            if (replyController.text.trim().isEmpty) {
                              showCustomSnackBar("please_write_a_reply".tr);
                            } else {
                              await reviewController
                                  .replyReview(
                                    reviewId: widget.review!.id!,
                                    reviewContent: replyController.text.trim(),
                                    fromPage: widget.fromPage,
                                    serviceId: widget.review?.service?.id,
                                  )
                                  .then((value) {
                                    if (value.isSuccess!) {
                                      if (widget.review?.reviewReply?.reply !=
                                          null) {
                                        showCustomSnackBar(
                                          "reply_edit_successfully".tr,
                                          type: ToasterMessageType.success,
                                        );
                                      } else {
                                        showCustomSnackBar(
                                          "replied_successfully".tr,
                                          type: ToasterMessageType.success,
                                        );
                                      }
                                    } else {
                                      showCustomSnackBar(value.message!);
                                    }
                                  });
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
