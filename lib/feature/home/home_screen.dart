import 'package:afriendorse/athlete/feature/groups/controller/group_controller.dart';
import 'package:afriendorse/athlete/feature/groups/models/group_models.dart';
import 'package:afriendorse/athlete/feature/groups/screens/group_detail_screen.dart';
import 'package:afriendorse/athlete/feature/groups/screens/groups_list_screen.dart';
import 'package:afriendorse/feature/home/athletes_by_sport_screen.dart';
import 'package:afriendorse/feature/home/widget/app_bar.dart';
import 'package:afriendorse/feature/home/widget/nearby_provider_listview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

/*
class HomeScreen extends StatefulWidget {
  static Future<void> loadData(
    bool reload, {
    int availableServiceCount = 1,
  }) async {
    if (availableServiceCount == 0) {
      Get.find<BannerController>().getBannerList(reload);
    } else {
      await Future.wait([
        Get.find<ServiceController>().getRecommendedSearchList(),
        Get.find<ServiceController>().getAllServiceList(1, reload),
        Get.find<BannerController>().getBannerList(reload),
        Get.find<AdvertisementController>().getAdvertisementList(reload),
        Get.find<CategoryController>().getCategoryList(reload),
        Get.find<ServiceController>().getPopularServiceList(1, reload),
        Get.find<ServiceController>().getTrendingServiceList(1, reload),
        Get.find<ProviderBookingController>().getProviderList(1, reload),
        Get.find<NearbyProviderController>().getProviderList(1, reload),
        Get.find<CampaignController>().getCampaignList(reload),
        Get.find<ServiceController>().getRecommendedServiceList(1, reload),
        Get.find<CheckOutController>().getOfflinePaymentMethod(
          false,
          shouldUpdate: false,
        ),
        Get.find<ServiceController>().getFeatherCategoryList(reload),
        if (Get.find<AuthController>().isLoggedIn())
          Get.find<AuthController>().updateToken(),
        if (Get.find<AuthController>().isLoggedIn())
          Get.find<ServiceController>().getRecentlyViewedServiceList(1, reload),
      ]);

      Get.find<BookingDetailsController>().manageDialog();
    }
  }

  final AddressModel? addressModel;
  final bool showServiceNotAvailableDialog;
  const HomeScreen({
    super.key,
    this.addressModel,
    required this.showServiceNotAvailableDialog,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AddressModel? _previousAddress;
  int availableServiceCount = 0;

  @override
  void initState() {
    super.initState();

    Get.find<LocalizationController>().filterLanguage(shouldUpdate: false);
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo();
      Get.find<LocationController>().getAddressList();
    }
    if (Get.find<LocationController>().getUserAddress() != null) {
      availableServiceCount = Get.find<LocationController>()
          .getUserAddress()!
          .availableServiceCountInZone!;
    }
    HomeScreen.loadData(false, availableServiceCount: availableServiceCount);

    _previousAddress = widget.addressModel;

    if (_previousAddress != null &&
        availableServiceCount == 0 &&
        widget.showServiceNotAvailableDialog) {
      Future.delayed(const Duration(microseconds: 1000), () {
        Get.dialog(
          ServiceNotAvailableDialog(
            address: _previousAddress,
            forCard: false,
            showButton: true,
            onBackPressed: () {
              Get.back();
              Get.find<LocationController>().setZoneContinue('false');
            },
          ),
        );
      });
    }
  }

  PreferredSizeWidget homeAppBar({
    GlobalKey<CustomShakingWidgetState>? signInShakeKey,
  }) {
    if (ResponsiveHelper.isDesktop(context)) {
      return WebMenuBar(signInShakeKey: signInShakeKey);
    } else {
      return const AddressAppBar(backButton: false);
    }
  }

  final ScrollController scrollController = ScrollController();
  final signInShakeKey = GlobalKey<CustomShakingWidgetState>();
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: 'AfriEndorse',
        onMessageTap: () => Get.toNamed(RouteHelper.getInboxScreenRoute()),
        onNotificationTap: () =>
            Get.toNamed(RouteHelper.getNotificationRoute()),
      ),
      //  appBar: homeAppBar(signInShakeKey: signInShakeKey),
      drawer: ResponsiveHelper.isDesktop(context)
          ? const AddressSelectionDrawer()
          : null,
      endDrawer: ResponsiveHelper.isDesktop(context)
          ? const MenuDrawer()
          : null,
      body: ResponsiveHelper.isDesktop(context)
          ? WebHomeScreen(
              scrollController: scrollController,
              availableServiceCount: availableServiceCount,
              signInShakeKey: signInShakeKey,
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (availableServiceCount > 0) {
                    Get.find<SplashController>().getConfigData();
                    await Get.find<ServiceController>().getAllServiceList(
                      1,
                      true,
                    );
                    await Get.find<BannerController>().getBannerList(true);
                    await Get.find<AdvertisementController>()
                        .getAdvertisementList(true);
                    await Get.find<CategoryController>().getCategoryList(true);
                    await Get.find<ServiceController>()
                        .getRecommendedServiceList(1, true);
                    await Get.find<ProviderBookingController>().getProviderList(
                      1,
                      true,
                    );
                    await Get.find<ServiceController>().getPopularServiceList(
                      1,
                      true,
                    );
                    await Get.find<ServiceController>().getTrendingServiceList(
                      1,
                      true,
                    );
                    await Get.find<CampaignController>().getCampaignList(true);
                    await Get.find<ServiceController>().getFeatherCategoryList(
                      true,
                    );
                    await Get.find<CartController>().getCartListFromServer();
                    if (Get.find<AuthController>().isLoggedIn()) {
                      await Get.find<ServiceController>()
                          .getRecentlyViewedServiceList(1, true);
                    }
                  } else {
                    await Get.find<BannerController>().getBannerList(true);
                  }
                },
                child: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: GetBuilder<SplashController>(
                    builder: (splashController) {
                      return GetBuilder<ProviderBookingController>(
                        builder: (providerController) {
                          return GetBuilder<ServiceController>(
                            builder: (serviceController) {
                              bool isAvailableProvider =
                                  providerController.providerList != null &&
                                  providerController.providerList!.isNotEmpty;
                              int? providerBooking = splashController
                                  .configModel
                                  .content
                                  ?.directProviderBooking;
                              bool isLtr =
                                  Get.find<LocalizationController>().isLtr;

                              return CustomScrollView(
                                controller: scrollController,
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: ClampingScrollPhysics(),
                                ),

                                /*  slivers: [
                                  const SliverToBoxAdapter(
                                    child: SizedBox(
                                      height: Dimensions.paddingSizeSmall,
                                    ),
                                  ),

                                  // const HomeSearchWidget(),
                                  SliverToBoxAdapter(
                                    child: Center(
                                      child: SizedBox(
                                        width: Dimensions.webMaxWidth,
                                        child: Column(
                                          children: [
                                            const BannerView(),
                                            availableServiceCount > 0
                                                ? Column(
                                                    children: [
                                                      const Padding(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeDefault,
                                                        ),
                                                        child: CategoryView(),
                                                      ),

                                                      const Padding(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeDefault,
                                                        ),
                                                        child:
                                                            HighlightProviderWidget(),
                                                      ),

                                                      /* const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeLarge,
                                                      ), */

                                                      /*  HorizontalScrollServiceView(
                                                        fromPage:
                                                            'popular_services',
                                                        serviceList:
                                                            serviceController
                                                                .popularServiceList,
                                                      ), */
                                                      const RandomCampaignView(),

                                                      /* const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeLarge,
                                                      ),
                                                      RecommendedServiceView(
                                                        height: isLtr
                                                            ? 210
                                                            : 225,
                                                      ), */
                                                      /*  SizedBox(
                                                        height:
                                                            (providerBooking ==
                                                                    1 &&
                                                                (isAvailableProvider ||
                                                                    providerController
                                                                            .providerList ==
                                                                        null))
                                                            ? Dimensions
                                                                  .paddingSizeLarge
                                                            : 0,
                                                      ), */
                                                      //provider near you #1
                                                      /*
                                                      (providerBooking == 1 &&
                                                              (isAvailableProvider ||
                                                                  providerController
                                                                          .providerList ==
                                                                      null))
                                                          ? NearbyProviderListview(
                                                              height: isLtr
                                                                  ? 190
                                                                  : 205,
                                                            )
                                                          : const SizedBox(), */

                                                      //explore pro
                                                      /*
                                                      (providerBooking == 1 &&
                                                              (isAvailableProvider ||
                                                                  providerController
                                                                          .providerList ==
                                                                      null))
                                                          ? Padding(
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeDefault,
                                                                vertical: Dimensions
                                                                    .paddingSizeLarge,
                                                              ),
                                                              child: SizedBox(
                                                                height: 160,
                                                                child: ExploreProviderCard(
                                                                  showShimmer:
                                                                      providerController
                                                                          .providerList ==
                                                                      null,
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox(), */
                                                      if (Get.find<
                                                                SplashController
                                                              >()
                                                              .configModel
                                                              .content
                                                              ?.directProviderBooking ==
                                                          1)
                                                        //recommended experts for you
                                                        const HomeRecommendProvider(
                                                          height: 1920,
                                                        ),

                                                      if (Get.find<
                                                                SplashController
                                                              >()
                                                              .configModel
                                                              .content
                                                              ?.biddingStatus ==
                                                          1)
                                                        (serviceController
                                                                        .allService !=
                                                                    null &&
                                                                serviceController
                                                                    .allService!
                                                                    .isNotEmpty)
                                                            ? const Padding(
                                                                padding: EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      Dimensions
                                                                          .paddingSizeDefault,
                                                                  vertical:
                                                                      Dimensions
                                                                          .paddingSizeLarge,
                                                                ),
                                                                child:
                                                                    HomeCreatePostView(
                                                                      showShimmer:
                                                                          false,
                                                                    ),
                                                              )
                                                            : const SizedBox(),

                                                      if (Get.find<
                                                            AuthController
                                                          >()
                                                          .isLoggedIn())
                                                        /*  HorizontalScrollServiceView(
                                                          fromPage:
                                                              'recently_view_services',
                                                          serviceList:
                                                              serviceController
                                                                  .recentlyViewServiceList,
                                                        ), */
                                                        const CampaignView(),

                                                      /*  HorizontalScrollServiceView(
                                                        fromPage:
                                                            'trending_services',
                                                        serviceList:
                                                            serviceController
                                                                .trendingServiceList,
                                                      ), */
                                                      const FeatheredCategoryView(),

                                                      /*
                                                      (serviceController
                                                                      .allService !=
                                                                  null &&
                                                              serviceController
                                                                  .allService!
                                                                  .isNotEmpty)
                                                          ? (ResponsiveHelper.isMobile(
                                                                      context,
                                                                    ) ||
                                                                    ResponsiveHelper.isTab(
                                                                      context,
                                                                    ))
                                                                ? Padding(
                                                                    padding: const EdgeInsets.fromLTRB(
                                                                      Dimensions
                                                                          .paddingSizeDefault,
                                                                      15,
                                                                      Dimensions
                                                                          .paddingSizeDefault,
                                                                      Dimensions
                                                                          .paddingSizeSmall,
                                                                    ),
                                                                    child: TitleWidget(
                                                                      textDecoration:
                                                                          TextDecoration
                                                                              .underline,
                                                                      title:
                                                                          'all_service'
                                                                              .tr,
                                                                      onTap: () =>
                                                                          Get.toNamed(
                                                                            RouteHelper.getSearchResultRoute(),
                                                                          ),
                                                                    ),
                                                                  )
                                                                : const SizedBox.shrink()
                                                          : const SizedBox.shrink(), */
                                                      /*  PaginatedListView(
                                                        scrollController:
                                                            scrollController,
                                                        totalSize:
                                                            serviceController
                                                                .serviceContent
                                                                ?.total,
                                                        offset:
                                                            serviceController
                                                                .serviceContent
                                                                ?.currentPage,
                                                        onPaginate:
                                                            (
                                                              int offset,
                                                            ) async =>
                                                                await serviceController
                                                                    .getAllServiceList(
                                                                      offset,
                                                                      false,
                                                                    ),
                                                        showBottomSheet: true,
                                                        itemView: ServiceViewVertical(
                                                          service:
                                                              serviceController
                                                                      .serviceContent !=
                                                                  null
                                                              ? serviceController
                                                                    .allService
                                                              : null,
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal:
                                                                ResponsiveHelper.isDesktop(
                                                                  context,
                                                                )
                                                                ? Dimensions
                                                                      .paddingSizeExtraSmall
                                                                : Dimensions
                                                                      .paddingSizeDefault,
                                                            vertical:
                                                                ResponsiveHelper.isDesktop(
                                                                  context,
                                                                )
                                                                ? Dimensions
                                                                      .paddingSizeExtraSmall
                                                                : 0,
                                                          ),
                                                          type: 'others',
                                                          noDataType:
                                                              NoDataType.home,
                                                        ),
                                                      ), */
                                                    ],
                                                  )
                                                : SizedBox(
                                                    height:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.height *
                                                        .6,
                                                    child:
                                                        const ServiceNotAvailableScreen(),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                             */

                                // Inside _HomeScreenState build() method -> CustomScrollView -> slivers:
                                slivers: [
                                  /*   const SliverToBoxAdapter(
                                    child: SizedBox(
                                      height: Dimensions.paddingSizeLarge,
                                    ),
                                  ), */

                                  // 1. Premium Search Bar
                                  /*  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeDefault,
                                      ),
                                      child: InkWell(
                                        onTap: () => Get.toNamed(
                                          RouteHelper.getSearchResultRoute(),
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFF045F25,
                                              ).withOpacity(0.1),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.04,
                                                ),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.search_rounded,
                                                color: Colors.grey[500],
                                                size: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Search athletes...',
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
*/
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 14),
                                  ),

                                  // 2. Firestore Sports Categories
                                  const SliverToBoxAdapter(
                                    child: _FirestoreSportsCategories(),
                                  ),

                                  // 3. Firestore Groups Horizontal  ← ADD THIS
                                  const SliverToBoxAdapter(
                                    child: _FirestoreGroupsHorizontal(),
                                  ),

                                  /* const SliverToBoxAdapter(
                                    child: SizedBox(height: 14),
                                  ), */

                                  // 3. Recommended Athletes (Your Existing Widget)
                                  SliverToBoxAdapter(
                                    child: availableServiceCount > 0
                                        ? Column(
                                            children: [
                                              if (Get.find<SplashController>()
                                                      .configModel
                                                      .content
                                                      ?.directProviderBooking ==
                                                  1)
                                                const HomeRecommendProvider(
                                                  height: 1920,
                                                ),
                                            ],
                                          )
                                        : SizedBox(
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                .6,
                                            child:
                                                const ServiceNotAvailableScreen(),
                                          ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}

class _FirestoreSportsCategories extends StatelessWidget {
  const _FirestoreSportsCategories();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Text(
            'Explore Athlete by Sports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: StreamBuilder<QuerySnapshot>(
            // Assuming your sports collection is named 'sports'
            stream: FirebaseFirestore.instance
                .collection('sports')
                .where('isActive', isEqualTo: true)
                .orderBy('order')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading sports'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF045F25)),
                );
              }

              final sports = snapshot.data?.docs ?? [];

              if (sports.isEmpty) {
                return const Center(child: Text('No sports found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: sports.length,
                itemBuilder: (context, index) {
                  final sport = sports[index].data() as Map<String, dynamic>;
                  final sportId = sports[index].id;
                  final name = sport['name'] ?? 'Unknown';
                  final icon = sport['icon'] ?? '🏆'; // Emoji fallback

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _SportCategoryCard(
                      name: name,
                      icon: icon,
                      onTap: () {
                        Get.to(
                          () => AthletesBySportScreen(
                            sportId: sportId,
                            sportName: name,
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SportCategoryCard extends StatelessWidget {
  final String name;
  final String icon;
  final VoidCallback onTap;

  const _SportCategoryCard({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF045F25).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _FirestoreGroupsHorizontal extends StatelessWidget {
  const _FirestoreGroupsHorizontal();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Athlete Groups',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const GroupsListScreen()),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF045F25),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 185,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .where('isPublic', isEqualTo: true)
                .orderBy('memberCount', descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading groups'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (_, __) => Container(
                    width: 155,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                );
              }

              final groups = snapshot.data?.docs ?? [];

              if (groups.isEmpty) {
                return const Center(
                  child: Text(
                    'No groups yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: _HomeGroupCard(doc: groups[index]),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _HomeGroupCard extends StatelessWidget {
  final DocumentSnapshot doc;

  const _HomeGroupCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final groupId = doc.id;

    final name = data['name'] as String? ?? 'Unknown Group';
    final sport = data['sport'] as String? ?? '';
    final coverImage = data['coverImage'] as String? ?? '';
    final memberCount = (data['memberCount'] as num?)?.toInt() ?? 0;
    final totalDonations = (data['totalDonations'] as num?)?.toDouble() ?? 0.0;
    final activeCampaignCount =
        (data['activeCampaignCount'] as num?)?.toInt() ?? 0;
    final hasActiveCampaign = activeCampaignCount > 0;

    return GestureDetector(
      onTap: () {
        final controller = Get.put(GroupController());
        controller.loadGroupDetails(groupId); // ← this is what was missing
        Get.to(
          () => GroupDetailScreen(
            groupId: groupId,
            group: GroupModel.fromDoc(doc),
          ),
        );
      },
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover image ──────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  // Cover or fallback
                  coverImage.isNotEmpty
                      ? Image.network(
                          coverImage,
                          height: 95,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _GroupCardCoverFallback(),
                        )
                      : const _GroupCardCoverFallback(),

                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Sport chip — top left
                  if (sport.isNotEmpty)
                    Positioned(
                      top: 7,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          sport,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // Campaign live badge — top right
                  if (hasActiveCampaign)
                    Positioned(
                      top: 7,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF045F25).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.campaign, size: 9, color: Colors.white),
                            SizedBox(width: 3),
                            Text(
                              'Live',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Member count — bottom left
                  Positioned(
                    bottom: 6,
                    left: 8,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 10,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$memberCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Info section ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 11,
                        color: Color(0xFF045F25),
                      ),
                      Text(
                        '${Currency.symbol}${totalDonations.toStringAsFixed(0)} raised',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF045F25),
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
    );
  }
}

class _GroupCardCoverFallback extends StatelessWidget {
  const _GroupCardCoverFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF045F25).withOpacity(0.25),
            const Color(0xFF045F25).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.groups,
          size: 38,
          color: const Color(0xFF045F25).withOpacity(0.35),
        ),
      ),
    );
  }
}

*/

// ─────────────────────────────────────────────────────────────────────────────
// 🎨 BACKGROUND CONFIGURATION — tweak these constants to taste
// ─────────────────────────────────────────────────────────────────────────────

/// Opacity of the green radial bloom near the top of the screen.
/// 0.0 = invisible  |  0.16 = default  |  0.30 = rich/bold
const double kBloomOpacity = 0.16;

/// Radius of the green radial bloom (1.0 = ~screen width, larger = softer).
const double kBloomRadius = 2.15;

/// Opacity of the geometric line mesh drawn over the background.
/// 0.0 = no lines  |  0.10 = subtle  |  0.22 = clearly visible
const double kMeshOpacity = 0.10;

/// Stroke width of the mesh lines in logical pixels.
const double kMeshStrokeWidth = 1.0;

// ─────────────────────────────────────────────────────────────────────────────

const Color _kGreen = Color(0xFF045F25);

class HomeScreen extends StatefulWidget {
  static Future<void> loadData(
    bool reload, {
    int availableServiceCount = 1,
  }) async {
    if (availableServiceCount == 0) {
      Get.find<BannerController>().getBannerList(reload);
    } else {
      await Future.wait([
        Get.find<ServiceController>().getRecommendedSearchList(),
        Get.find<ServiceController>().getAllServiceList(1, reload),
        Get.find<BannerController>().getBannerList(reload),
        Get.find<AdvertisementController>().getAdvertisementList(reload),
        Get.find<CategoryController>().getCategoryList(reload),
        Get.find<ServiceController>().getPopularServiceList(1, reload),
        Get.find<ServiceController>().getTrendingServiceList(1, reload),
        Get.find<ProviderBookingController>().getProviderList(1, reload),
        Get.find<NearbyProviderController>().getProviderList(1, reload),
        Get.find<CampaignController>().getCampaignList(reload),
        Get.find<ServiceController>().getRecommendedServiceList(1, reload),
        Get.find<CheckOutController>().getOfflinePaymentMethod(
          false,
          shouldUpdate: false,
        ),
        Get.find<ServiceController>().getFeatherCategoryList(reload),
        if (Get.find<AuthController>().isLoggedIn())
          Get.find<AuthController>().updateToken(),
        if (Get.find<AuthController>().isLoggedIn())
          Get.find<ServiceController>().getRecentlyViewedServiceList(1, reload),
      ]);
      Get.find<BookingDetailsController>().manageDialog();
    }
  }

  final AddressModel? addressModel;
  final bool showServiceNotAvailableDialog;
  const HomeScreen({
    super.key,
    this.addressModel,
    required this.showServiceNotAvailableDialog,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AddressModel? _previousAddress;
  int availableServiceCount = 0;

  final ScrollController scrollController = ScrollController();
  final signInShakeKey = GlobalKey<CustomShakingWidgetState>();

  @override
  void initState() {
    super.initState();

    Get.find<LocalizationController>().filterLanguage(shouldUpdate: false);

    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo();
      Get.find<LocationController>().getAddressList();

      // ✅ Initialize WalletController for logged-in brand/fan users
      _initializeWalletController();
      // Ensure WalletRepo is registered for withdrawal processing
      if (!Get.isRegistered<WalletRepo>()) {
        Get.lazyPut(
          () =>
              WalletRepo(apiClient: Get.find(), sharedPreferences: Get.find()),
        );
      }
    }

    if (Get.find<LocationController>().getUserAddress() != null) {
      availableServiceCount = Get.find<LocationController>()
          .getUserAddress()!
          .availableServiceCountInZone!;
    }

    HomeScreen.loadData(false, availableServiceCount: availableServiceCount);
    _previousAddress = widget.addressModel;

    if (_previousAddress != null &&
        availableServiceCount == 0 &&
        widget.showServiceNotAvailableDialog) {
      Future.delayed(const Duration(microseconds: 1000), () {
        Get.dialog(
          ServiceNotAvailableDialog(
            address: _previousAddress,
            forCard: false,
            showButton: true,
            onBackPressed: () {
              Get.back();
              Get.find<LocationController>().setZoneContinue('false');
            },
          ),
        );
      });
    }
  }

  /// Initialize WalletController if not already registered
  void _initializeWalletController() {
    if (!Get.isRegistered<WalletController>()) {
      try {
        Get.put(
          WalletController(
            walletRepo: WalletRepo(
              apiClient: Get.find<ApiClient>(),
              sharedPreferences: Get.find<SharedPreferences>(),
            ),
          ),
          permanent: true, // Keep alive for entire session
        );
        if (kDebugMode) {
          print('✅ WalletController initialized successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to initialize WalletController: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('ℹ️ WalletController already registered');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      // Transparent so _PremiumBackgroundLight shows through everywhere
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: false,
      appBar: MainAppBar(
        title: 'AfriEndorse',
        onMessageTap: () => Get.toNamed(RouteHelper.getInboxScreenRoute()),
        onNotificationTap: () =>
            Get.toNamed(RouteHelper.getNotificationRoute()),
      ),
      drawer: ResponsiveHelper.isDesktop(context)
          ? const AddressSelectionDrawer()
          : null,
      endDrawer: ResponsiveHelper.isDesktop(context)
          ? const MenuDrawer()
          : null,
      body: Stack(
        children: [
          // ── Layer 1: Premium background (bloom + mesh) ──────────────────
          const Positioned.fill(child: PremiumFaChatPatternBackground()),

          // ── Layer 2: Scrollable page content ────────────────────────────
          ResponsiveHelper.isDesktop(context)
              ? WebHomeScreen(
                  scrollController: scrollController,
                  availableServiceCount: availableServiceCount,
                  signInShakeKey: signInShakeKey,
                )
              : SafeArea(
                  child: RefreshIndicator(
                    color: _kGreen,
                    onRefresh: () async {
                      if (availableServiceCount > 0) {
                        Get.find<SplashController>().getConfigData();
                        await Future.wait([
                          Get.find<ServiceController>().getAllServiceList(
                            1,
                            true,
                          ),
                          Get.find<BannerController>().getBannerList(true),
                          Get.find<AdvertisementController>()
                              .getAdvertisementList(true),
                          Get.find<CategoryController>().getCategoryList(true),
                          Get.find<ServiceController>()
                              .getRecommendedServiceList(1, true),
                          Get.find<ProviderBookingController>().getProviderList(
                            1,
                            true,
                          ),
                          Get.find<ServiceController>().getPopularServiceList(
                            1,
                            true,
                          ),
                          Get.find<ServiceController>().getTrendingServiceList(
                            1,
                            true,
                          ),
                          Get.find<CampaignController>().getCampaignList(true),
                          Get.find<ServiceController>().getFeatherCategoryList(
                            true,
                          ),
                          Get.find<CartController>().getCartListFromServer(),
                          if (Get.find<AuthController>().isLoggedIn())
                            Get.find<ServiceController>()
                                .getRecentlyViewedServiceList(1, true),
                        ]);
                      } else {
                        await Get.find<BannerController>().getBannerList(true);
                      }
                    },
                    child: GestureDetector(
                      onTap: () =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      child: GetBuilder<SplashController>(
                        builder: (splashController) {
                          return GetBuilder<ProviderBookingController>(
                            builder: (providerController) {
                              return GetBuilder<ServiceController>(
                                builder: (serviceController) {
                                  return CustomScrollView(
                                    controller: scrollController,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(
                                          parent: ClampingScrollPhysics(),
                                        ),
                                    slivers: [
                                      const SliverToBoxAdapter(
                                        child: SizedBox(height: 14),
                                      ),

                                      // 1 ── Sports categories
                                      const SliverToBoxAdapter(
                                        child: _FirestoreSportsCategories(),
                                      ),

                                      const SliverToBoxAdapter(
                                        child: SizedBox(height: 14),
                                      ),

                                      SliverToBoxAdapter(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeDefault,
                                          ),
                                          child: HomeCreatePostView(
                                            showShimmer: false,
                                          ),
                                        ),
                                      ),

                                      // 2 ── Groups horizontal
                                      const SliverToBoxAdapter(
                                        child: _FirestoreGroupsHorizontal(),
                                      ),

                                      // 3 ── Recommended athletes / fallback
                                      SliverToBoxAdapter(
                                        child: availableServiceCount > 0
                                            ? Column(
                                                children: [
                                                  if (Get.find<
                                                            SplashController
                                                          >()
                                                          .configModel
                                                          .content
                                                          ?.directProviderBooking ==
                                                      1)
                                                    const HomeRecommendProvider(
                                                      height: 1920,
                                                    ),
                                                ],
                                              )
                                            : SizedBox(
                                                height: screenH * 0.6,
                                                child:
                                                    const ServiceNotAvailableScreen(),
                                              ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM BACKGROUND  (ported from PortalScreen._PremiumBackgroundLight)
// ─────────────────────────────────────────────────────────────────────────────

// pubspec.yaml
// dependencies:
//   font_awesome_flutter: ^10.7.0

class PremiumFaChatPatternBackground extends StatelessWidget {
  const PremiumFaChatPatternBackground({super.key});

  // Your brand green
  static const Color _kGreen = Color(0xFF045F25);

  // Base + bloom
  static const double _bloomOpacity = 0.16;
  static const double _bloomRadius = 2.4;

  // Pattern (denser + more visible)
  static const double _patternOpacity = 0.07; // try 0.07–0.11
  static const double _tile = 54; // try 64–84
  static const int _seed = 13;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1) Soft base gradient
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF6FAF7), Color(0xFFFFFFFF)],
            ),
          ),
        ),

        // 2) Green bloom near top
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.95),
                radius: _bloomRadius,
                colors: [
                  _kGreen.withOpacity(_bloomOpacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // 3) Full-screen repeating FontAwesome-only icon pattern
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _FaOnlyPatternPainter(
                icons: const <FaIconData>[
                  FontAwesomeIcons.futbol,
                  FontAwesomeIcons.basketball,
                  FontAwesomeIcons.volleyball,
                  FontAwesomeIcons.baseball,
                  FontAwesomeIcons.tableTennisPaddleBall,
                  FontAwesomeIcons.personRunning,
                  FontAwesomeIcons.personBiking,
                  FontAwesomeIcons.dumbbell,
                  FontAwesomeIcons.stopwatch,
                  FontAwesomeIcons.trophy,
                  FontAwesomeIcons.medal,
                  FontAwesomeIcons.football, // American football
                  FontAwesomeIcons.hockeyPuck, // Ice hockey
                  FontAwesomeIcons.golfBallTee, // Golf
                  FontAwesomeIcons.bowlingBall, // Bowling
                  FontAwesomeIcons.swimmer, // Swimming
                  FontAwesomeIcons.personSwimming, // Swimming (alt)
                  FontAwesomeIcons.personSkiing, // Skiing
                  FontAwesomeIcons.personSnowboarding, // Snowboarding
                  FontAwesomeIcons.personSkating, // Skating
                  FontAwesomeIcons.personWalking, // Walking/Hiking
                  FontAwesomeIcons.personHiking, // Hiking
                  FontAwesomeIcons.heartPulse, // Cardio/fitness
                  FontAwesomeIcons.fireFlameCurved, // Calories/burn
                  FontAwesomeIcons.bullseye, // Archery/target sports
                  FontAwesomeIcons.flagCheckered, // Racing/finish line
                  FontAwesomeIcons.bicycle, // Cycling (alt)
                  FontAwesomeIcons.motorcycle, // Motorsports
                  FontAwesomeIcons.car, // Racing
                  FontAwesomeIcons.gaugeHigh, // Speed/performance
                  FontAwesomeIcons.calendarCheck, // Scheduled events
                  FontAwesomeIcons.clipboardList, // Training plans
                  FontAwesomeIcons.chartLine, // Progress tracking
                  FontAwesomeIcons.shoePrints, // Steps/tracking
                  FontAwesomeIcons.locationDot, // Location/venues
                  FontAwesomeIcons.users, // Teams
                  FontAwesomeIcons.userGroup, // Teams (alt)
                  FontAwesomeIcons.sitemap, // League structure
                  FontAwesomeIcons.circlePlay, // Start activity
                  FontAwesomeIcons.pause, // Pause
                  FontAwesomeIcons.circleStop, // Stop
                  FontAwesomeIcons.rotateRight, // Reset/retry
                  FontAwesomeIcons.star, // Favorites
                  FontAwesomeIcons.bookmark, // Saved events
                  FontAwesomeIcons.shareNodes, // Share results
                  FontAwesomeIcons.camera, // Photos/videos
                  FontAwesomeIcons.video, // Recordings
                  FontAwesomeIcons.mountain, // Outdoor sports
                  FontAwesomeIcons.campground, // Outdoor activities
                  FontAwesomeIcons.water, // Water sports
                  FontAwesomeIcons.wind, // Wind sports
                  FontAwesomeIcons.sun, // Outdoor conditions
                  FontAwesomeIcons.cloudSun, // Weather
                  FontAwesomeIcons.temperatureHalf, // Body temp/conditions
                  FontAwesomeIcons.droplet, // Hydration
                  FontAwesomeIcons.appleWhole, // Nutrition
                  FontAwesomeIcons.burger, // Diet/cheat meals
                  FontAwesomeIcons.bed, // Rest/recovery
                  FontAwesomeIcons.moon, // Sleep tracking
                  FontAwesomeIcons.bell, // Notifications/reminders
                  FontAwesomeIcons.circleExclamation, // Alerts
                  FontAwesomeIcons.circleInfo, // Info
                  FontAwesomeIcons.gear, // Settings
                  FontAwesomeIcons.sliders, // Preferences
                  FontAwesomeIcons.magnifyingGlass, // Search
                  FontAwesomeIcons.filter, // Filter results
                  FontAwesomeIcons.arrowRightArrowLeft,
                ],
                color: _kGreen,
                opacity: _patternOpacity,
                tile: _tile,
                seed: _seed,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FaOnlyPatternPainter extends CustomPainter {
  final List<FaIconData> icons;
  final Color color;
  final double opacity;
  final double tile;
  final int seed;

  const _FaOnlyPatternPainter({
    required this.icons,
    required this.color,
    required this.opacity,
    required this.tile,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed);

    // Fixed sizes look cleaner + less “noisy”
    const sizesMain = <double>[16, 18, 20, 22, 24, 26];
    const sizesSmall = <double>[12, 14, 16, 18];

    for (double y = -tile; y < size.height + tile; y += tile) {
      final row = (y / tile).round();
      final rowShift = row.isEven ? tile * 0.35 : 0.0; // wallpaper-like offset

      for (double x = -tile; x < size.width + tile; x += tile) {
        // Main icon per tile
        _drawFa(
          canvas: canvas,
          rnd: rnd,
          icon: icons[rnd.nextInt(icons.length)],
          origin: Offset(x + rowShift + tile / 2, y + tile / 2),
          size: sizesMain[rnd.nextInt(sizesMain.length)],
          opacityScale: 1.0,
        );

        // Optional second smaller icon for density
        if (rnd.nextDouble() < 0.55) {
          _drawFa(
            canvas: canvas,
            rnd: rnd,
            icon: icons[rnd.nextInt(icons.length)],
            origin: Offset(
              x + rowShift + tile * (0.25 + rnd.nextDouble() * 0.5),
              y + tile * (0.25 + rnd.nextDouble() * 0.5),
            ),
            size: sizesSmall[rnd.nextInt(sizesSmall.length)],
            opacityScale: 0.85,
          );
        }
      }
    }
  }

  void _drawFa({
    required Canvas canvas,
    required Random rnd,
    required FaIconData icon,
    required Offset origin,
    required double size,
    required double opacityScale,
  }) {
    final angle = (rnd.nextDouble() - 0.5) * 0.55; // subtle rotation
    final jitter = Offset(
      (rnd.nextDouble() - 0.5) * 10,
      (rnd.nextDouble() - 0.5) * 10,
    );

    // Slight alpha variation so it feels organic
    final alpha = (opacity * opacityScale) * (0.75 + rnd.nextDouble() * 0.5);

    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          color: color.withOpacity(alpha.clamp(0.0, 1.0)),
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
    )..layout();

    canvas.save();
    canvas.translate(origin.dx + jitter.dx, origin.dy + jitter.dy);
    canvas.rotate(angle);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FaOnlyPatternPainter old) {
    return old.opacity != opacity ||
        old.tile != tile ||
        old.color != color ||
        old.seed != seed ||
        old.icons != icons;
  }
}

class _PremiumBackgroundLight extends StatelessWidget {
  const _PremiumBackgroundLight();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Soft off-white base — avoids flat, lifeless white
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAF8), Color(0xFFFFFFFF)],
            ),
          ),
        ),

        // 2. Green radial bloom centred near the top edge.
        //    Intensity → kBloomOpacity  |  Spread → kBloomRadius
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.95),
                radius: kBloomRadius,
                colors: [
                  _kGreen.withOpacity(kBloomOpacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // 3. Geometric line mesh for subtle depth/texture.
        //    Opacity → kMeshOpacity  |  Weight → kMeshStrokeWidth
        Positioned.fill(
          child: CustomPaint(
            painter: _LineMeshPainter(
              color: _kGreen.withOpacity(kMeshOpacity),
              strokeWidth: kMeshStrokeWidth,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LINE MESH PAINTER  (ported from PortalScreen._LineMeshPainter)
// Extended with a strokeWidth parameter for easy tuning.
// ─────────────────────────────────────────────────────────────────────────────

class _LineMeshPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _LineMeshPainter({required this.color, this.strokeWidth = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      // Row 1 — near top of screen
      ..moveTo(size.width * 0.08, size.height * 0.12)
      ..lineTo(size.width * 0.46, size.height * 0.05)
      ..lineTo(size.width * 0.92, size.height * 0.18)
      // Row 2 — upper-mid
      ..moveTo(size.width * 0.12, size.height * 0.36)
      ..lineTo(size.width * 0.60, size.height * 0.28)
      ..lineTo(size.width * 0.90, size.height * 0.42)
      // Row 3 — lower-mid
      ..moveTo(size.width * 0.06, size.height * 0.62)
      ..lineTo(size.width * 0.52, size.height * 0.52)
      ..lineTo(size.width * 0.94, size.height * 0.68);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineMeshPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// SPORTS CATEGORIES
// ─────────────────────────────────────────────────────────────────────────────

class _FirestoreSportsCategories extends StatelessWidget {
  const _FirestoreSportsCategories();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Text(
            'Explore Athletes by Sport',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('sports')
                .where('isActive', isEqualTo: true)
                .orderBy('order')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading sports'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _kGreen),
                );
              }
              final sports = snapshot.data?.docs ?? [];
              if (sports.isEmpty) {
                return const Center(child: Text('No sports found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: sports.length,
                itemBuilder: (context, index) {
                  final sport = sports[index].data() as Map<String, dynamic>;
                  final sportId = sports[index].id;
                  final name = sport['name'] ?? 'Unknown';
                  final icon = sport['icon'] ?? '🏆';
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _SportCategoryCard(
                      name: name,
                      icon: icon,
                      onTap: () => Get.to(
                        () => AthletesBySportScreen(
                          sportId: sportId,
                          sportName: name,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SportCategoryCard extends StatelessWidget {
  final String name;
  final String icon;
  final VoidCallback onTap;

  const _SportCategoryCard({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        decoration: BoxDecoration(
          // Semi-transparent so the bloom/mesh texture peeks through
          color: Colors.white.withOpacity(0.82),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kGreen.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: _kGreen.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: _kGreen.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GROUPS HORIZONTAL
// ─────────────────────────────────────────────────────────────────────────────

class _FirestoreGroupsHorizontal extends StatelessWidget {
  const _FirestoreGroupsHorizontal();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Athlete Groups',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const GroupsListScreen()),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 135,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .where('isPublic', isEqualTo: true)
                .orderBy('memberCount', descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading groups'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (_, __) => Container(
                    width: 155,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                );
              }
              final groups = snapshot.data?.docs ?? [];
              if (groups.isEmpty) {
                return const Center(
                  child: Text(
                    'No groups yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: _HomeGroupCard(doc: groups[index]),
                  );
                },
              );
            },
          ),
        ),
        // const SizedBox(height: 6),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GROUP CARD
// ─────────────────────────────────────────────────────────────────────────────

class _HomeGroupCard extends StatelessWidget {
  final DocumentSnapshot doc;
  const _HomeGroupCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final groupId = doc.id;
    final name = data['name'] as String? ?? 'Unknown Group';
    final sport = data['sport'] as String? ?? '';
    final coverImage = data['coverImage'] as String? ?? '';
    final memberCount = (data['memberCount'] as num?)?.toInt() ?? 0;
    final totalDonations = (data['totalDonations'] as num?)?.toDouble() ?? 0.0;
    final activeCampaignCount =
        (data['activeCampaignCount'] as num?)?.toInt() ?? 0;
    final hasActiveCampaign = activeCampaignCount > 0;

    return GestureDetector(
      onTap: () {
        final controller = Get.put(GroupController());
        controller.loadGroupDetails(groupId);
        Get.to(
          () => GroupDetailScreen(
            groupId: groupId,
            group: GroupModel.fromDoc(doc),
          ),
        );
      },
      child: Container(
        width: 155,
        height: 0,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  coverImage.isNotEmpty
                      ? Image.network(
                          coverImage,
                          height: 95,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const _GroupCardCoverFallback(),
                        )
                      : const _GroupCardCoverFallback(),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (sport.isNotEmpty)
                    Positioned(
                      top: 7,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          sport,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (hasActiveCampaign)
                    Positioned(
                      top: 7,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _kGreen.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.campaign, size: 9, color: Colors.white),
                            SizedBox(width: 3),
                            Text(
                              'Live',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 6,
                    left: 8,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 10,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$memberCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              // Single text — no Column needed, minimal padding
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            /*  Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                    const SizedBox(height: 5),
                  Row(
                    children: [
                      //  const Icon(Icons.attach_money, size: 11, color: _kGreen),
                      Text(
                        '${Currency.symbol}${totalDonations.toStringAsFixed(0)} raised',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _kGreen,
                        ),
                      ),
                    ],
                  ), 
                ],
              ),
            ), */
          ],
        ),
      ),
    );
  }
}

class _GroupCardCoverFallback extends StatelessWidget {
  const _GroupCardCoverFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kGreen.withOpacity(0.25), _kGreen.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.groups, size: 38, color: _kGreen.withOpacity(0.35)),
      ),
    );
  }
}
