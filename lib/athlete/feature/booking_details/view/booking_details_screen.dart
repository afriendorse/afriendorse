import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String? bookingId;
  final String? subBookingId;
  final String? fromPage;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
    this.fromPage,
    this.subBookingId,
  });
  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen>
    with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    Get.find<BookingDetailsController>().showHideExpandView(
      0,
      shouldUpdate: false,
    );
    super.initState();
    controller = TabController(vsync: this, length: 2);

    var bookingDetailsController = Get.find<BookingDetailsController>();
    bool isRegularBooking =
        widget.bookingId != null && widget.bookingId != "null";

    bookingDetailsController.resetBookingDetailsValue(
      resetBookingDetails: isRegularBooking,
      clearPhotos: false, // ← DON'T clear photos on screen entry
    );

    if (isRegularBooking) {
      bookingDetailsController.getBookingDetails(widget.bookingId!);
    } else {
      bookingDetailsController.getBookingSubDetails(widget.subBookingId!);
    }

    Get.find<ServicemanSetupController>().getAllServicemanList(
      1,
      reload: false,
      status: 'active',
    );
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
          child: GetBuilder<BookingDetailsController>(
            builder: (bookingDetailsController) {
              bool isSubBooking =
                  widget.subBookingId != null && widget.subBookingId != "null";
              BookingDetailsContent? bookingDetails =
                  bookingDetailsController.bookingDetails?.content;
              BookingDetailsContent? subBookingDetails =
                  bookingDetailsController.subBookingDetails?.content;

              return ExpandableBottomSheet(
                expandableContent:
                    bookingDetailsController.bottomSheetHeight == 0
                    ? const SizedBox()
                    : AssignServicemanScreen(
                        servicemanList:
                            Get.find<ServicemanSetupController>()
                                .servicemanList ??
                            [],
                        bookingId: widget.bookingId!,
                        isSubBooking: isSubBooking,
                        reAssignServiceman: isSubBooking
                            ? subBookingDetails?.serviceman != null
                            : bookingDetails?.serviceman != null,
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
                          controller: controller,
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
                              child: Tab(text: 'status'.tr),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: TabBarView(
                          controller: controller,
                          children: [
                            BookingDetailsWidget(
                              bookingId: widget.bookingId,
                              subBookingId: widget.subBookingId,
                              isSubBooking: isSubBooking,
                              tabController: controller,
                            ),
                            BookingStatus(
                              bookingId: widget.bookingId,
                              isSubBooking: isSubBooking,
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
