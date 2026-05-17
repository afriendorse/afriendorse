import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/reporting/model/booking_report_model.dart';
import 'package:get/get.dart';

class BookingReportListView extends StatelessWidget {
  final List<BookingFilterData> bookingFilterData;
  const BookingReportListView({super.key, required this.bookingFilterData});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingReportController>(
      builder: (bookingReportController) {
        return Column(
          children: [
            SizedBox(height: Dimensions.paddingSizeDefault),
            bookingFilterData.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeExtraSmall,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('booking_list'.tr, style: robotoMedium),
                        PopupMenuButton<String>(
                          onSelected: (String value) async {
                            bookingReportController.setSelectedDropdownValue(
                              value,
                              type: 'booking_status',
                            );
                            await bookingReportController.getBookingReportData(
                              1,
                            );
                          },
                          itemBuilder: (BuildContext context) {
                            return bookingReportController.bookingStatus.map((
                              String value,
                            ) {
                              return PopupMenuItem<String>(
                                value: value,
                                child: Text(
                                  value.tr,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.7),
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusExtraLarge,
                              ),
                              border: Border.all(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!
                                    .withValues(alpha: 0.4),
                                width: 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: Dimensions.paddingSizeExtraSmall - 2,
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall,
                                ),
                                Text(
                                  bookingReportController
                                          .selectedBookingStatus
                                          ?.tr ??
                                      "all".tr,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.7),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down_outlined,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),

            bookingFilterData.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookingFilterData.length,
                    itemBuilder: (context, index) {
                      return BookingReportListItem(
                        bookingFilterData: bookingFilterData[index],
                      );
                    },
                  )
                : SizedBox(
                    height: Get.height * 0.33,
                    child: Center(
                      child: Text(
                        'no_data_found'.tr,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                    ),
                  ),
            if (Get.find<BookingReportController>().isLoading)
              const CircularProgressIndicator(),
          ],
        );
      },
    );
  }
}

class BookingReportListItem extends StatelessWidget {
  final BookingFilterData bookingFilterData;
  const BookingReportListItem({super.key, required this.bookingFilterData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeExtraSmall,
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Container(
        width: Get.width,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusSmall),
                  topRight: Radius.circular(Dimensions.radiusSmall),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'booking_id'.tr,
                            style: robotoMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                          Text(
                            " #${bookingFilterData.readableId.toString()}",
                            style: robotoMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          Text(
                            '${'booking_date'.tr} : ',
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeExtraSmall,
                            ),
                          ),
                          Text(
                            DateConverter.dateMonthYearLocalTime(
                              DateTime.parse(bookingFilterData.createdAt!),
                            ),
                            style: robotoMedium.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeExtraSmall,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: Dimensions.paddingSizeLarge),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'customer'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        Text(
                          "${bookingFilterData.customer?.firstName ?? ""} ${bookingFilterData.customer?.lastName ?? ""}",
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyLarge!.color!
                                .withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
                bottom: Dimensions.paddingSizeDefault,
              ),
              child: Container(
                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'total_booking_amount'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.8),
                              ),
                            ),

                            Text(
                              ' (${bookingFilterData.isPaid == 1 ? 'paid'.tr : 'unpaid'.tr})',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),

                        Text(
                          PriceConverter.convertPrice(
                            double.tryParse(
                              bookingFilterData.totalBookingAmount.toString(),
                            ),
                          ),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
