import 'package:afriendorse/athlete/feature/reporting/widgets/booking_report/booking_amount_widget.dart';
import 'package:afriendorse/athlete/feature/reporting/widgets/booking_report/booking_count_widget.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class BookingReport extends StatefulWidget {
  const BookingReport({super.key});
  @override
  State<BookingReport> createState() => _BookingReportState();
}

class _BookingReportState extends State<BookingReport> {
  @override
  void initState() {
    super.initState();
    Get.find<BookingReportController>().getBookingReportData(1);
  }

  @override
  Widget build(BuildContext context) {
    JustTheController dueTooltipController = JustTheController();
    JustTheController settledTooltipController = JustTheController();

    return GetBuilder<BookingReportController>(
      builder: (bookingReportController) {
        return Scaffold(
          backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.97),
          appBar: ReportAppBarView(
            title: 'booking_report'.tr,
            fromPage: 'booking',
            isFiltered: bookingReportController.isFiltered,
          ),
          body: bookingReportController.bookingReportModel != null
              ? CustomScrollView(
                  controller: bookingReportController.scrollController,
                  slivers: [
                    bookingReportController.isFiltered
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(
                                Dimensions.paddingSizeDefault,
                              ),
                              child: BookingReportFilteredWidget(),
                            ),
                          )
                        : const SliverToBoxAdapter(child: SizedBox()),

                    SliverToBoxAdapter(
                      child: BookingCountWidget(
                        totalBookings:
                            bookingReportController
                                .bookingReportModel
                                ?.content
                                ?.bookingsCount
                                ?.totalBookings
                                .toString() ??
                            "",
                        ongoing:
                            bookingReportController
                                .bookingReportModel
                                ?.content
                                ?.bookingsCount
                                ?.ongoing
                                .toString() ??
                            "",
                        completed:
                            bookingReportController
                                .bookingReportModel
                                ?.content
                                ?.bookingsCount
                                ?.completed
                                .toString() ??
                            "",
                        canceled:
                            bookingReportController
                                .bookingReportModel
                                ?.content
                                ?.bookingsCount
                                ?.canceled
                                .toString() ??
                            "",
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: BookingAmountWidget(
                        totalBookingAmount:
                            bookingReportController
                                .bookingReportModel
                                ?.content
                                ?.bookingAmount
                                ?.totalBookingAmount
                                .toString() ??
                            "",
                        dueAmount:
                            bookingReportController
                                .bookingReportModel
                                ?.content
                                ?.bookingAmount
                                ?.totalUnpaidBookingAmount
                                .toString() ??
                            "",
                        settledAmount:
                            bookingReportController
                                .bookingReportModel
                                ?.content
                                ?.bookingAmount
                                ?.totalPaidBookingAmount
                                .toString() ??
                            "",
                        dueTooltipController: dueTooltipController,
                        settledTooltipController: settledTooltipController,
                      ),
                    ),

                    const SliverToBoxAdapter(child: BookingReportBarChart()),

                    SliverToBoxAdapter(
                      child: BookingReportListView(
                        bookingFilterData:
                            bookingReportController.bookingReportFilterData,
                      ),
                    ),
                  ],
                )
              : const BookingReportShimmer(),
        );
      },
    );
  }
}
