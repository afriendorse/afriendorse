/* when pending from the cart was in use

import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/feature/booking/widget/booking_item_card.dart';
import 'package:afriendorse/feature/booking/widget/booking_status_tabs.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class BookingListScreen extends StatefulWidget {
  final bool isFromMenu;
  const BookingListScreen({super.key, this.isFromMenu = false});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  @override
  void initState() {
    Get.find<ServiceBookingController>().getAllBookingService(
      offset: 1,
      bookingStatus: "all",
      isFromPagination: false,
      serviceType: "all",
    );
    Get.find<ServiceBookingController>().updateBookingStatusTabs(
      BookingStatusTabs.all,
      firstTimeCall: false,
    );
    Get.find<ServiceBookingController>().updateSelectedServiceType();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController bookingScreenScrollController = ScrollController();
    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(
          isBackButtonExist: widget.isFromMenu ? true : false,
          onBackPressed: () => Get.back(),
          title: "my_bookings".tr,
          actionWidget: const FilterPopUpMenuWidget(),
        ),
        body: GetBuilder<ServiceBookingController>(
          builder: (serviceBookingController) {
            List<BookingModel>? bookingList =
                serviceBookingController.bookingList;
            return RefreshIndicator(
              onRefresh: () async {
                await serviceBookingController.getAllBookingService(
                  offset: 1,
                  bookingStatus: serviceBookingController
                      .selectedBookingStatus
                      .name
                      .toLowerCase(),
                  isFromPagination: false,
                  serviceType:
                      serviceBookingController.selectedServiceType.name,
                );
              },
              child: CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                controller: bookingScreenScrollController,
                slivers: [
                  if (serviceBookingController.selectedServiceType !=
                          ServiceType.all &&
                      !ResponsiveHelper.isDesktop(context))
                    SliverPersistentHeader(
                      delegate: ServiceRequestTopTitle(),
                      pinned: true,
                      floating: true,
                    ),

                  SliverPersistentHeader(
                    delegate: ServiceRequestSectionMenu(),
                    pinned: true,
                    floating: true,
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: ResponsiveHelper.isDesktop(context)
                          ? Dimensions.paddingSizeDefault
                          : 0,
                    ),
                  ),

                  serviceBookingController.bookingList != null
                      ? SliverToBoxAdapter(
                          child:
                              bookingList!.isNotEmpty &&
                                  !serviceBookingController.isTabLoading
                              ? Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: Dimensions.webMaxWidth,
                                      minHeight: Get.height * 0.7,
                                    ),
                                    child: PaginatedListView(
                                      scrollController:
                                          bookingScreenScrollController,
                                      totalSize: serviceBookingController
                                          .bookingContent!
                                          .total!,
                                      onPaginate: (int offset) async =>
                                          await serviceBookingController
                                              .getAllBookingService(
                                                offset: offset,
                                                bookingStatus:
                                                    serviceBookingController
                                                        .selectedBookingStatus
                                                        .name
                                                        .toLowerCase(),
                                                isFromPagination: true,
                                                serviceType:
                                                    serviceBookingController
                                                        .selectedServiceType
                                                        .name,
                                              ),
                                      offset: serviceBookingController
                                          .bookingContent
                                          ?.currentPage,
                                      itemView: GridView.builder(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              ResponsiveHelper.isDesktop(
                                                context,
                                              )
                                              ? 0
                                              : Dimensions.paddingSizeDefault,
                                        ),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount:
                                                  ResponsiveHelper.isDesktop(
                                                    context,
                                                  )
                                                  ? 2
                                                  : 1,
                                              mainAxisExtent:
                                                  Get.find<
                                                        LocalizationController
                                                      >()
                                                      .isLtr
                                                  ? 140
                                                  : 175,
                                              crossAxisSpacing:
                                                  Dimensions.paddingSizeDefault,
                                              mainAxisSpacing:
                                                  Dimensions.paddingSizeDefault,
                                            ),
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: bookingList.length,
                                        itemBuilder: (context, index) {
                                          return BookingItemCard(
                                            bookingModel: bookingList.elementAt(
                                              index,
                                            ),
                                            index: index,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: SizedBox(
                                    height: Get.height * 0.7,
                                    width: Dimensions.webMaxWidth,
                                    child: NoDataScreen(
                                      text: 'no_booking_request_available'.tr,
                                      type: NoDataType.bookings,
                                    ),
                                  ),
                                ),
                        )
                      : const SliverToBoxAdapter(
                          child: Center(
                            child: SizedBox(
                              width: Dimensions.webMaxWidth,
                              child: BookingListItemShimmer(),
                            ),
                          ),
                        ),

                  SliverToBoxAdapter(
                    child: ResponsiveHelper.isDesktop(context)
                        ? const FooterView()
                        : const SizedBox(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class BookingListItemShimmer extends StatelessWidget {
  const BookingListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 2 : 1,
        mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 130 : 120,
        crossAxisSpacing: Dimensions.paddingSizeDefault,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeSmall
            : Dimensions.paddingSizeExtraSmall,
      ),
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall - 3,
            horizontal: ResponsiveHelper.isDesktop(context)
                ? 0
                : Dimensions.paddingSizeDefault,
          ),
          child: Shimmer(
            child: Container(
              height: 90,
              width: Get.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).cardColor,
                boxShadow: Get.isDarkMode
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.grey[300]!,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 17,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).shadowColor,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Container(
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).shadowColor,
                          ),
                        ),

                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Container(
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).shadowColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Expanded(child: SizedBox()),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 17,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Container(
                        height: 15,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ServiceRequestTopTitle extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return GetBuilder<ServiceBookingController>(
      builder: (serviceBookingController) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              serviceBookingController.selectedServiceType ==
                      ServiceType.regular
                  ? "regular_booking".tr
                  : "repeat_booking".tr,
            ),
          ),
        );
      },
    );
  }

  @override
  double get maxExtent => 30;

  @override
  double get minExtent => 30;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class FilterPopUpMenuWidget extends StatelessWidget {
  const FilterPopUpMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceBookingController>(
      builder: (serviceBookingController) {
        List<String> bookingFilterList = [
          'all_booking',
          "regular_booking",
          "repeat_booking",
        ];

        return PopupMenuButton<String>(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(Dimensions.radiusSmall),
            ),
            side: BorderSide(
              color: Theme.of(context).hintColor.withValues(alpha: 0.1),
            ),
          ),
          surfaceTintColor: Theme.of(context).cardColor,
          position: PopupMenuPosition.under,
          elevation: 8,
          shadowColor: Theme.of(context).hintColor.withValues(alpha: 0.3),

          padding: EdgeInsets.zero,
          menuPadding: EdgeInsets.zero,
          itemBuilder: (BuildContext context) {
            return bookingFilterList.map((String option) {
              ServiceType type = option == "regular_booking"
                  ? ServiceType.regular
                  : option == "repeat_booking"
                  ? ServiceType.repeat
                  : ServiceType.all;
              return PopupMenuItem<String>(
                value: option,
                padding: EdgeInsets.zero,
                height: 45,
                child: serviceBookingController.selectedServiceType == type
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).colorScheme.primary
                              .withValues(alpha: Get.isDarkMode ? 0.2 : 0.08),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option.tr,
                              style: robotoRegular.copyWith(
                                color: Get.isDarkMode
                                    ? Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        child: Text(
                          option.tr,
                          style: robotoRegular.copyWith(
                            color: Get.isDarkMode
                                ? Theme.of(context).hintColor
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                onTap: () {
                  Get.find<ServiceBookingController>()
                      .updateSelectedServiceType(
                        type: option == "regular_booking"
                            ? ServiceType.regular
                            : option == "repeat_booking"
                            ? ServiceType.repeat
                            : ServiceType.all,
                      );
                },
              );
            }).toList();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Stack(
              alignment: AlignmentDirectional.center,
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.filter_list,
                  color: ResponsiveHelper.isDesktop(context) && !Get.isDarkMode
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                if (serviceBookingController.selectedServiceType !=
                    ServiceType.all)
                  Positioned(
                    right: -5,
                    bottom: ResponsiveHelper.isDesktop(context) ? 0 : 13,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.circle, size: 13, color: Colors.white),
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
*/

import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/feature/booking/widget/booking_item_card.dart';
import 'package:afriendorse/feature/booking/widget/booking_status_tabs.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';
import 'package:afriendorse/feature/my_post/widgets/my_post_view.dart';

class BookingListScreen extends StatefulWidget {
  final bool isFromMenu;
  const BookingListScreen({super.key, this.isFromMenu = false});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  // FIX #1: ScrollController moved here so it is created once and properly disposed.
  late final ScrollController _bookingScreenScrollController;

  @override
  void initState() {
    super.initState();
    _bookingScreenScrollController = ScrollController();

    final controller = Get.find<ServiceBookingController>();

    // FIX #3: Call getAllBookingService directly. We skip updateBookingStatusTabs
    // because the default is already .pending, which would cause the early-return
    // guard to fire and do nothing useful.
    controller.getAllBookingService(
      offset: 1,
      bookingStatus: BookingStatusTabs.pending.name.toLowerCase(),
      isFromPagination: false,
      serviceType: ServiceType.all.name,
    );

    // Force-set the selected tab state without triggering a redundant API call.
    controller.setSelectedTabSilently(BookingStatusTabs.pending);
    controller.updateSelectedServiceType();
  }

  @override
  void dispose() {
    // FIX #1: Properly dispose the controller.
    _bookingScreenScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(
          isBackButtonExist: widget.isFromMenu ? true : false,
          onBackPressed: () => Get.back(),
          title: "my_bookings".tr,
        ),
        body: GetBuilder<ServiceBookingController>(
          builder: (serviceBookingController) {
            List<BookingModel>? bookingList =
                serviceBookingController.bookingList;

            final isPendingTab =
                serviceBookingController.selectedBookingStatus ==
                BookingStatusTabs.pending;

            return RefreshIndicator(
              onRefresh: () async {
                if (isPendingTab) {
                  // FIX #2: Refresh for pending tab only fetches posts; no
                  // duplicate getAllBookingService call here.
                  await Get.find<CreatePostController>().getMyPostList(
                    1,
                    reload: true,
                  );
                } else {
                  await serviceBookingController.getAllBookingService(
                    offset: 1,
                    bookingStatus: serviceBookingController
                        .selectedBookingStatus
                        .name
                        .toLowerCase(),
                    isFromPagination: false,
                    serviceType:
                        serviceBookingController.selectedServiceType.name,
                  );
                }
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _bookingScreenScrollController, // FIX #1: use field
                slivers: [
                  if (serviceBookingController.selectedServiceType !=
                          ServiceType.all &&
                      !ResponsiveHelper.isDesktop(context))
                    SliverPersistentHeader(
                      delegate: ServiceRequestTopTitle(),
                      pinned: true,
                      floating: true,
                    ),

                  SliverPersistentHeader(
                    delegate: ServiceRequestSectionMenu(),
                    pinned: true,
                    floating: true,
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: ResponsiveHelper.isDesktop(context)
                          ? Dimensions.paddingSizeDefault
                          : 0,
                    ),
                  ),

                  // ── PENDING TAB → show bid/post list ──────────────────────
                  if (isPendingTab)
                    const SliverToBoxAdapter(child: _BidListView()),

                  // ── ALL OTHER TABS → show normal booking list ─────────────
                  if (!isPendingTab)
                    serviceBookingController.bookingList != null
                        ? SliverToBoxAdapter(
                            child:
                                bookingList!.isNotEmpty &&
                                    !serviceBookingController.isTabLoading
                                ? Center(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: Dimensions.webMaxWidth,
                                        minHeight: Get.height * 0.7,
                                      ),
                                      child: PaginatedListView(
                                        scrollController:
                                            _bookingScreenScrollController, // FIX #1
                                        totalSize: serviceBookingController
                                            .bookingContent!
                                            .total!,
                                        onPaginate: (int offset) async =>
                                            await serviceBookingController
                                                .getAllBookingService(
                                                  offset: offset,
                                                  bookingStatus:
                                                      serviceBookingController
                                                          .selectedBookingStatus
                                                          .name
                                                          .toLowerCase(),
                                                  isFromPagination: true,
                                                  serviceType:
                                                      serviceBookingController
                                                          .selectedServiceType
                                                          .name,
                                                ),
                                        offset: serviceBookingController
                                            .bookingContent
                                            ?.currentPage,
                                        itemView: GridView.builder(
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                ResponsiveHelper.isDesktop(
                                                  context,
                                                )
                                                ? 0
                                                : Dimensions.paddingSizeDefault,
                                          ),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    ResponsiveHelper.isDesktop(
                                                      context,
                                                    )
                                                    ? 2
                                                    : 1,
                                                mainAxisExtent:
                                                    Get.find<
                                                          LocalizationController
                                                        >()
                                                        .isLtr
                                                    ? 200
                                                    : 235,
                                                crossAxisSpacing: Dimensions
                                                    .paddingSizeDefault,
                                                mainAxisSpacing: Dimensions
                                                    .paddingSizeDefault,
                                              ),
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: bookingList.length,
                                          itemBuilder: (context, index) {
                                            return BookingItemCard(
                                              bookingModel: bookingList
                                                  .elementAt(index),
                                              index: index,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: SizedBox(
                                      height: Get.height * 0.7,
                                      width: Dimensions.webMaxWidth,
                                      child: NoDataScreen(
                                        text: 'no_booking_request_available'.tr,
                                        type: NoDataType.bookings,
                                      ),
                                    ),
                                  ),
                          )
                        : const SliverToBoxAdapter(
                            child: Center(
                              child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: BookingListItemShimmer(),
                              ),
                            ),
                          ),

                  SliverToBoxAdapter(
                    child: ResponsiveHelper.isDesktop(context)
                        ? const FooterView()
                        : const SizedBox(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Bid / Post list shown in the Pending tab ───────────────────────────────────
class _BidListView extends StatefulWidget {
  const _BidListView();

  @override
  State<_BidListView> createState() => _BidListViewState();
}

class _BidListViewState extends State<_BidListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // FIX #2: Only fetch if data isn't already loaded (avoids duplicate call
    // from BookingListScreen.initState which may have already triggered this
    // via a parent rebuild). Using reload: false here; the parent's
    // RefreshIndicator handles explicit user-pull-to-refresh.
    final createPostController = Get.find<CreatePostController>();
    if (createPostController.dateList.isEmpty) {
      createPostController.getMyPostList(1, reload: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreatePostController>(
      builder: (createPostController) {
        // ── Loading state ────────────────────────────────────────────────────
        if (createPostController.isLoading) {
          return GridView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeDefault,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: Dimensions.paddingSizeLarge,
              mainAxisSpacing: Dimensions.paddingSizeSmall,
              crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
              mainAxisExtent: ResponsiveHelper.isMobile(context) ? 175 : 185,
            ),
            itemCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, __) =>
                const SubCategoryShimmer(isEnabled: true, hasDivider: false),
          );
        }

        // ── FIX #1 (main bug): Build a flat list of only unbooked posts.
        // Posts with isBooked == 1 have an accepted booking and belong in the
        // Accepted / Ongoing tabs — they must NOT appear on the Pending tab.
        final List<({String date, dynamic post})> unbookedEntries = [];
        if (createPostController.listOfMyPost != null) {
          for (int di = 0; di < createPostController.dateList.length; di++) {
            for (final post in createPostController.listOfMyPost![di]) {
              if ((post.isBooked ?? 0) != 1) {
                unbookedEntries.add((
                  date: createPostController.dateList[di],
                  post: post,
                ));
              }
            }
          }
        }

        // ── Empty state ──────────────────────────────────────────────────────
        if (unbookedEntries.isEmpty) {
          return Center(
            child: SizedBox(
              height: Get.height * 0.7,
              width: Dimensions.webMaxWidth,
              child: NoDataScreen(
                text: 'no_post_found'.tr,
                type: NoDataType.bookings,
              ),
            ),
          );
        }

        // ── Data state ───────────────────────────────────────────────────────
        // Rebuild a grouped structure from the filtered entries so date headers
        // are only shown when there is at least one unbooked post in that group.
        // FIX #4: Empty date groups are automatically skipped because we only
        // add a group header when there are posts to show for it.
        final Map<String, List<dynamic>> groupedPosts = {};
        for (final entry in unbookedEntries) {
          groupedPosts.putIfAbsent(entry.date, () => []).add(entry.post);
        }
        final List<String> filteredDates = groupedPosts.keys.toList();

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Dimensions.webMaxWidth,
              minHeight: Get.height * 0.7,
            ),
            child: PaginatedListView(
              scrollController: _scrollController,
              totalSize: createPostController.postModel?.content?.total,
              onPaginate: (int offset) async => await createPostController
                  .getMyPostList(offset, reload: false),
              offset: createPostController.postModel?.content?.currentPage,
              itemView: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredDates.length,
                itemBuilder: (context, dateIndex) {
                  final date = filteredDates[dateIndex];
                  final posts = groupedPosts[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      // ── Date group header ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeExtraSmall,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        child: Text(
                          date,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge!.color!
                                .withValues(alpha: 0.5),
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ),

                      // ── Post cards grid for this date group ────────────────
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: Dimensions.paddingSizeLarge,
                          mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                              ? Dimensions.paddingSizeDefault
                              : Dimensions.paddingSizeSmall,
                          crossAxisCount: ResponsiveHelper.isMobile(context)
                              ? 1
                              : ResponsiveHelper.isTab(context)
                              ? 2
                              : 3,
                          mainAxisExtent: ResponsiveHelper.isMobile(context)
                              ? 175
                              : 185,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return MyPostView(postData: posts[index]);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Shimmer placeholder for the normal booking list ───────────────────────────
class BookingListItemShimmer extends StatelessWidget {
  const BookingListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 2 : 1,
        mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 160 : 140,
        crossAxisSpacing: Dimensions.paddingSizeDefault,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeSmall
            : Dimensions.paddingSizeExtraSmall,
      ),
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall - 3,
            horizontal: ResponsiveHelper.isDesktop(context)
                ? 0
                : Dimensions.paddingSizeDefault,
          ),
          child: Shimmer(
            child: Container(
              height: 90,
              width: Get.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).cardColor,
                boxShadow: Get.isDarkMode
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.grey[300]!,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 17,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).shadowColor,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Container(
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).shadowColor,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Container(
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).shadowColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 17,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Container(
                        height: 15,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Sticky header shown when a service type filter is active ──────────────────
class ServiceRequestTopTitle extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return GetBuilder<ServiceBookingController>(
      builder: (serviceBookingController) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              serviceBookingController.selectedServiceType ==
                      ServiceType.regular
                  ? "regular_booking".tr
                  : "repeat_booking".tr,
            ),
          ),
        );
      },
    );
  }

  @override
  double get maxExtent => 30;

  @override
  double get minExtent => 30;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

// ── Filter popup menu (all / regular / repeat) ────────────────────────────────
class FilterPopUpMenuWidget extends StatelessWidget {
  const FilterPopUpMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceBookingController>(
      builder: (serviceBookingController) {
        List<String> bookingFilterList = [
          'all_booking',
          "regular_booking",
          "repeat_booking",
        ];

        return PopupMenuButton<String>(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(Dimensions.radiusSmall),
            ),
            side: BorderSide(
              color: Theme.of(context).hintColor.withValues(alpha: 0.1),
            ),
          ),
          surfaceTintColor: Theme.of(context).cardColor,
          position: PopupMenuPosition.under,
          elevation: 8,
          shadowColor: Theme.of(context).hintColor.withValues(alpha: 0.3),
          padding: EdgeInsets.zero,
          menuPadding: EdgeInsets.zero,
          itemBuilder: (BuildContext context) {
            return bookingFilterList.map((String option) {
              ServiceType type = option == "regular_booking"
                  ? ServiceType.regular
                  : option == "repeat_booking"
                  ? ServiceType.repeat
                  : ServiceType.all;
              return PopupMenuItem<String>(
                value: option,
                padding: EdgeInsets.zero,
                height: 45,
                child: serviceBookingController.selectedServiceType == type
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).colorScheme.primary
                              .withValues(alpha: Get.isDarkMode ? 0.2 : 0.08),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option.tr,
                              style: robotoRegular.copyWith(
                                color: Get.isDarkMode
                                    ? Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        child: Text(
                          option.tr,
                          style: robotoRegular.copyWith(
                            color: Get.isDarkMode
                                ? Theme.of(context).hintColor
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                onTap: () {
                  Get.find<ServiceBookingController>()
                      .updateSelectedServiceType(
                        type: option == "regular_booking"
                            ? ServiceType.regular
                            : option == "repeat_booking"
                            ? ServiceType.repeat
                            : ServiceType.all,
                      );
                },
              );
            }).toList();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Stack(
              alignment: AlignmentDirectional.center,
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.filter_list,
                  color: ResponsiveHelper.isDesktop(context) && !Get.isDarkMode
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                if (serviceBookingController.selectedServiceType !=
                    ServiceType.all)
                  Positioned(
                    right: -5,
                    bottom: ResponsiveHelper.isDesktop(context) ? 0 : 13,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.circle, size: 13, color: Colors.white),
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
