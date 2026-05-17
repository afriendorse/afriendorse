import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/feature/provider/widgets/provider_filter_view.dart';
import 'package:afriendorse/feature/provider/widgets/provider_item_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class AllProviderView extends StatefulWidget {
  const AllProviderView({super.key});

  @override
  State<AllProviderView> createState() => _AllProviderViewState();
}

class _AllProviderViewState extends State<AllProviderView> {
  @override
  void initState() {
    super.initState();
    _loadDart();
  }

  Future<void> _loadDart() async {
    await Get.find<CategoryController>().getCategoryList(false);
    Get.find<ProviderBookingController>().resetProviderFilterData();
    Get.find<ProviderBookingController>().getProviderList(1, true);
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(
          title: 'provider_list'.tr,
          actionWidget: InkWell(
            onTap: () {
              showModalBottomSheet(
                useRootNavigator: true,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => const ProviderFilterView(),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
              ),
              child: Image.asset(Images.filter, width: 20, color: Colors.white),
            ),
          ),
        ),
        body: GetBuilder<ProviderBookingController>(
          builder: (providerBookingController) {
            return FooterBaseView(
              isScrollView: true,
              scrollController: scrollController,
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (ResponsiveHelper.isDesktop(context))
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeDefault,
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              useRootNavigator: true,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) => const ProviderFilterView(),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeLarge,
                              vertical: Dimensions.paddingSizeSmall,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  Images.filter,
                                  width: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),
                                Text(
                                  'filter'.tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    providerBookingController.providerModel != null &&
                            providerBookingController.providerList != null &&
                            providerBookingController.providerList!.isNotEmpty
                        ? PaginatedListView(
                            scrollController: scrollController,
                            totalSize: providerBookingController
                                .providerModel!
                                .content!
                                .total!,
                            onPaginate: (int offset) async =>
                                await providerBookingController.getProviderList(
                                  offset,
                                  false,
                                ),
                            offset: providerBookingController
                                .providerModel
                                ?.content
                                ?.currentPage,
                            itemView:
                                ResponsiveHelper.isDesktop(context) ||
                                    ResponsiveHelper.isTab(context)
                                ? GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              ResponsiveHelper.isDesktop(
                                                context,
                                              )
                                              ? 3
                                              : 2,
                                          mainAxisExtent:
                                              ResponsiveHelper.isDesktop(
                                                context,
                                              )
                                              ? 380
                                              : 360,
                                          mainAxisSpacing: 0,
                                          crossAxisSpacing: 0,
                                        ),
                                    itemCount: providerBookingController
                                        .providerList!
                                        .length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final provider = providerBookingController
                                          .providerList![index];
                                      return _ProviderFirestoreShell(
                                        provider: provider,
                                        index: index,
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(
                                      top: Dimensions.paddingSizeDefault,
                                    ),
                                    itemCount: providerBookingController
                                        .providerList!
                                        .length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final provider = providerBookingController
                                          .providerList![index];
                                      return _ProviderFirestoreShell(
                                        provider: provider,
                                        index: index,
                                      );
                                    },
                                  ),
                          )
                        : (providerBookingController.providerModel == null ||
                              providerBookingController.providerList == null)
                        ? SizedBox(
                            height: ResponsiveHelper.isDesktop(context)
                                ? Get.height * 0.75
                                : Get.height * 0.9,
                            child: const ProviderListViewShimmer(),
                          )
                        : SizedBox(
                            height: ResponsiveHelper.isDesktop(context)
                                ? Get.height * 0.5
                                : Get.height * 0.9,
                            child: Center(
                              child: Text(
                                'no_provider_found'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .color!
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Firestore shell: looks up athlete_profiles by owner email ────────────────
class _ProviderFirestoreShell extends StatelessWidget {
  final ProviderData provider;
  final int index;

  const _ProviderFirestoreShell({required this.provider, required this.index});

  DocumentReference<Map<String, dynamic>>? _profileRef() {
    final email = (provider.owner?.email ?? '').toString().trim();
    if (email.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('athletes')
        .doc(email.toLowerCase());
  }

  DocumentReference<Map<String, dynamic>>? _athleteRef() {
    final email = (provider.owner?.email ?? '').toString().trim();
    if (email.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('athletes')
        .doc(email.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final email = (provider.owner?.email ?? '').toString().trim();
    if (email.isEmpty) {
      return ProviderItemView(
        fromHomePage: false,
        providerData: provider,
        index: index,
        isVerticalLayout: true,
        athleteExtras: null,
      );
    }

    final profilesRef = FirebaseFirestore.instance
        .collection('athlete_profiles')
        .doc(email.toLowerCase());

    final athletesRef = FirebaseFirestore.instance
        .collection('athletes')
        .doc(email.toLowerCase());

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: profilesRef.snapshots(),
      builder: (context, pSnap) {
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: athletesRef.snapshots(),
          builder: (context, aSnap) {
            final merged = <String, dynamic>{
              ...(pSnap.data?.data() ?? const {}),
              ...(aSnap.data?.data() ?? const {}),
            };

            return ProviderItemView(
              fromHomePage: false,
              providerData: provider,
              index: index,
              isVerticalLayout: true,
              athleteExtras: merged.isEmpty ? null : merged,
            );
          },
        );
      },
    );
  }
}

// ─── Shimmer ──────────────────────────────────────────────────────────────────
class ProviderListViewShimmer extends StatelessWidget {
  const ProviderListViewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTab = ResponsiveHelper.isTab(context);

    Widget shimmerCard() => Container(
      margin: const EdgeInsets.only(
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
        bottom: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.black.withOpacity(0.07),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer(
        duration: const Duration(seconds: 1),
        interval: const Duration(seconds: 1),
        enabled: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover placeholder
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(color: Theme.of(context).shadowColor),
            ),
            // Details placeholder
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: name + chips
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 26,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Theme.of(context).shadowColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        height: 26,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).shadowColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row 2: location + rating
                  Row(
                    children: [
                      Container(
                        height: 12,
                        width: 130,
                        decoration: BoxDecoration(
                          color: Theme.of(context).shadowColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).shadowColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row 3: social pills
                  Row(
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          height: 28,
                          width: 72,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (isDesktop || isTab) {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 2,
          mainAxisExtent: isDesktop ? 380 : 360,
        ),
        itemCount: 6,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        itemBuilder: (_, __) => shimmerCard(),
      );
    }

    return ListView.builder(
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => shimmerCard(),
    );
  }
}
