import 'package:afriendorse/athlete/feature/booking_details/widget/repeat_booking/repeat_booking_details.dart';
import 'package:afriendorse/athlete/feature/booking_details/widget/repeat_booking/repeat_booking_service_log.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class RepeatBookingDetailsScreen extends StatefulWidget {
  final String bookingId;
  final String? fromPage;
  const RepeatBookingDetailsScreen({
    super.key,
    required this.bookingId,
    this.fromPage,
  });
  @override
  State<RepeatBookingDetailsScreen> createState() =>
      _RepeatBookingDetailsScreenState();
}

class _RepeatBookingDetailsScreenState extends State<RepeatBookingDetailsScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    Get.find<BookingDetailsController>().showHideExpandView(
      0,
      shouldUpdate: false,
    );
    super.initState();
    tabController = TabController(vsync: this, length: 2);
    Get.find<BookingDetailsController>().resetBookingDetailsValue(
      resetBookingDetails: true,
    );
    Get.find<BookingDetailsController>().getBookingDetails(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      onPopInvoked: () {
        if (widget.fromPage == 'fromNotification') {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(
          title: 'booking_details'.tr,
          onBackPressed: () {
            if (widget.fromPage == 'fromNotification') {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            } else {
              Get.back();
            }
          },
        ),

        body: SafeArea(
          bottom: false,
          child: GetBuilder<BookingDetailsController>(
            builder: (bookingDetailsController) {
              return ExpandableBottomSheet(
                expandableContent:
                    bookingDetailsController.bottomSheetHeight == 0
                    ? const SizedBox()
                    : AssignServicemanScreen(
                        servicemanList:
                            Get.find<ServicemanSetupController>()
                                .servicemanList ??
                            [],
                        bookingId: widget.bookingId,
                        isSubBooking: true,
                        reAssignServiceman:
                            bookingDetailsController
                                    .bookingDetails
                                    ?.content
                                    ?.serviceman !=
                                null
                            ? true
                            : false,
                      ),

                persistentContentHeight:
                    bookingDetailsController.bottomSheetHeight,

                background: Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  body: Column(
                    children: [
                      Container(
                        height: 45,
                        width: Get.width,
                        margin: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.7),
                              width: 1,
                            ),
                          ),
                        ),
                        child: TabBar(
                          unselectedLabelColor: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                          indicatorColor: Theme.of(context).primaryColor,
                          controller: tabController,
                          labelColor: Theme.of(context).primaryColorLight,
                          labelStyle: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                          labelPadding: EdgeInsets.zero,
                          onTap: (int? index) {
                            switch (index) {
                              case 0:
                                bookingDetailsController
                                    .updateServicePageCurrentState(
                                      BookingDetailsTabControllerState
                                          .bookingDetails,
                                    );
                                break;
                              case 1:
                                bookingDetailsController
                                    .updateServicePageCurrentState(
                                      BookingDetailsTabControllerState.status,
                                    );
                                bookingDetailsController.showHideExpandView(0);
                                break;
                            }
                          },
                          tabs: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Tab(text: 'booking_details'.tr),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Tab(text: 'service_log'.tr),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            RepeatBookingDetailsWidget(
                              bookingId: widget.bookingId,
                              tabController: tabController,
                              isSubBooking: true,
                            ),
                            RepeatBookingServiceLogWidget(
                              bookingId: widget.bookingId,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
