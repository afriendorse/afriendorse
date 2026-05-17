import 'package:afriendorse/athlete/feature/booking_requests/widgets/pending_tab_bids_content.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingRequestScreen extends StatefulWidget {
  const BookingRequestScreen({super.key});
  @override
  State<BookingRequestScreen> createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen> {
  @override
  void initState() {
    super.initState();

    Get.find<UserProfileController>().getProviderInfo(reload: true);

    // Set to index 0 (first tab - pending)
    Get.find<BookingRequestController>().updateBookingRequestIndex(0);
    Get.find<BookingRequestController>().updateSelectedServiceType();

    // Load 'pending' data to match index 0
    Get.find<BookingRequestController>().getBookingRequestList(
      'pending',
      1,
      reload: true,
      isFirst: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: MainAppBar(
        title: 'booking_requests'.tr,
        color: Theme.of(context).primaryColor,
        fromBookingRequest: true,
      ),
      body: GetBuilder<UserProfileController>(
        builder: (userController) {
          return GetBuilder<BookingRequestController>(
            builder: (bookingRequestController) {
              return Column(
                children: [
                  const BookingRequestMenuBar(),

                  Expanded(
                    child: TabBarView(
                      controller: bookingRequestController.tabController,
                      dragStartBehavior: DragStartBehavior.down,
                      children: const [
                        //   BookingRequestList(),
                        BookingRequestList(),
                        BookingRequestList(),
                        BookingRequestList(),
                        BookingRequestList(),
                        BookingRequestList(),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class SubscriptionCanceledView extends StatelessWidget {
  const SubscriptionCanceledView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "your_subscription_plan_has_been_cancelled_you_will_not_able_to_accept_any_booking_request"
                  .tr,
              style: robotoRegular.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            CustomButton(
              btnTxt: 'choose_plan'.tr,
              width: 180,
              height: 45,
              radius: Dimensions.radiusLarge,
              onPressed: () {
                Get.toNamed(RouteHelper.getBusinessPlanScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TurnOnServiceAvailability extends StatelessWidget {
  const TurnOnServiceAvailability({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "service_availability_option_has_turned_off".tr,
              style: robotoRegular.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            InkWell(
              onTap: () => Get.to(const BusinessSettingScreen()),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Dimensions.radiusExtraLarge,
                  ),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall - 3,
                ),
                child: Text(
                  "go_to_business_settings".tr,
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingRequestList extends StatefulWidget {
  const BookingRequestList({super.key});

  @override
  State<BookingRequestList> createState() => _BookingRequestListState();
}

class _BookingRequestListState extends State<BookingRequestList> {
  int value = 1;

  @override
  void initState() {
    super.initState();

    Get.find<BookingRequestController>().tabController?.addListener(() {
      if (value == 1) {
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.find<BookingRequestController>().menuScrollController
              ?.scrollToIndex(
                Get.find<BookingRequestController>().tabController!.index,
                preferPosition: AutoScrollPosition.middle,
                duration: const Duration(milliseconds: 500),
              );
          Get.find<BookingRequestController>().menuScrollController?.highlight(
            Get.find<BookingRequestController>().tabController!.index,
          );
          Get.find<BookingRequestController>().updateBookingRequestIndex(
            Get.find<BookingRequestController>().tabController!.index,
          );

          Get.find<BookingRequestController>().getBookingRequestList(
            Get.find<BookingRequestController>()
                .bookingRequestStatusList[Get.find<BookingRequestController>()
                .tabController!
                .index],
            1,
            reload: true,
          );
        });

        value--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        return GetBuilder<BookingRequestController>(
          builder: (bookingRequestController) {
            // ✅ Pending tab (index 1) → replaced entirely with My Bids content
            if (bookingRequestController.currentIndex == 0) {
              return const PendingTabBidsContent();
            }

            return bookingRequestController.bookingRequestList == null
                ? const BookingRequestItemShimmer()
                : bookingRequestController.currentIndex == 1 &&
                      userProfileController
                              .providerModel
                              ?.content
                              ?.providerInfo
                              ?.serviceAvailability ==
                          0
                ? Center(
                    child: SizedBox(
                      height: Get.height * 0.7,
                      child: const TurnOnServiceAvailability(),
                    ),
                  )
                : bookingRequestController.currentIndex == 1 &&
                      userProfileController
                              .providerModel
                              ?.content
                              ?.subscriptionInfo
                              ?.subscribedPackageDetails
                              ?.isCanceled ==
                          1
                ? Center(
                    child: SizedBox(
                      height: Get.height * 0.7,
                      child: const SubscriptionCanceledView(),
                    ),
                  )
                : bookingRequestController.bookingRequestList!.isEmpty
                ? Center(
                    child: SizedBox(
                      height: Get.height * 0.7,
                      child: NoDataScreen(
                        text: bookingRequestController.currentIndex == 0
                            ? "you_do_not_have_any_booking_request_yet".tr
                            : '${'you_have_not'.tr} ${bookingRequestController.bookingStatus.tr.toLowerCase()} ${"request_yet".tr}',
                        type: NoDataType.request,
                      ),
                    ),
                  )
                : const BookingRequestListview();
          },
        );
      },
    );
  }
}
