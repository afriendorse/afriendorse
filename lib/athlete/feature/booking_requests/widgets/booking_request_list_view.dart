import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingRequestListview extends StatelessWidget {
  const BookingRequestListview({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingRequestController>(
      builder: (bookingRequestController) {
        return Column(
          children: [
            bookingRequestController.bookingRequestList!.isNotEmpty
                ? Expanded(
                    child: RefreshIndicator(
                      color: Theme.of(context).primaryColorLight,
                      backgroundColor: Theme.of(context).cardColor,
                      onRefresh: () async {
                        Get.find<BookingRequestController>()
                            .getBookingRequestList(
                              Get.find<BookingRequestController>()
                                  .bookingRequestStatusList[Get.find<
                                    BookingRequestController
                                  >()
                                  .currentIndex],
                              1,
                            );
                      },
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: ClampingScrollPhysics(),
                        ),
                        controller: bookingRequestController.scrollController,
                        itemCount:
                            bookingRequestController.bookingRequestList?.length,
                        padding: EdgeInsets.only(
                          bottom: bookingRequestController.isLoading
                              ? 0
                              : Dimensions.paddingSizeLarge,
                        ),
                        itemBuilder: (ctx, index) => BookingRequestItem(
                          booking: bookingRequestController
                              .bookingRequestList![index],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),

            bookingRequestController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
