/*
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/feature/provider/widgets/provider_item_view.dart';
import 'package:get/get.dart';

class HomeRecommendProvider extends StatelessWidget {
  final double height;
  final GlobalKey<CustomShakingWidgetState>? signInShakeKey;
  const HomeRecommendProvider({
    super.key,
    required this.height,
    this.signInShakeKey,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProviderBookingController>(
      builder: (providerBookingController) {
        return providerBookingController.providerList != null &&
                providerBookingController.providerList!.isNotEmpty
            ? Container(
                color: Get.isDarkMode
                    ? Colors.grey.shade900
                    : Theme.of(context).primaryColor.withValues(alpha: 0.12),
                child: Stack(
                  children: [
                    // Background image at top
                    Image.asset(
                      Images.homeProviderBackground,
                      width: Get.width,
                      height: height * 0.3, // Adjust as needed
                      fit: BoxFit.cover,
                    ),

                    // Main content column
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          // Header section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              Dimensions.paddingSizeDefault,
                              15,
                              Dimensions.paddingSizeDefault,
                              Dimensions.paddingSizeSmall,
                            ),
                            child: TitleWidget(
                              textDecoration: TextDecoration.underline,
                              title: 'recommended_experts_for_you'.tr,
                              onTap: () => Get.toNamed(
                                RouteHelper.getAllProviderRoute(),
                              ),
                            ),
                          ),

                          // Vertical ListView - Facebook style posts
                          Expanded(
                            child: ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              scrollDirection:
                                  Axis.vertical, // Changed to vertical
                              padding: const EdgeInsets.symmetric(
                                horizontal:
                                    Dimensions.paddingSizeExtraSmall + 2,
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                              itemCount: providerBookingController
                                  .providerList
                                  ?.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                  ),
                                  child: ProviderItemView(
                                    providerData: providerBookingController
                                        .providerList![index],
                                    index: index,
                                    signInShakeKey: signInShakeKey,
                                    isVerticalLayout:
                                        true, // Pass this to widget
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : providerBookingController.providerList != null &&
                  providerBookingController.providerList!.isEmpty
            ? const SizedBox()
            : HomeRecommendedProviderShimmer(height: height);
      },
    );
  }
}

class HomeRecommendedProviderShimmer extends StatelessWidget {
  final double height;
  const HomeRecommendedProviderShimmer({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
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
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Column(
        children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 15,
                width: 130,
                color: Theme.of(context).shadowColor,
              ),
              Container(
                height: 15,
                width: 80,
                color: Theme.of(context).shadowColor,
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Vertical shimmer list
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical, // Changed to vertical
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeDefault,
                    left: Dimensions.paddingSizeSmall,
                    right: Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: Get.isDarkMode
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.grey[200]!,
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                  ),
                  child: Shimmer(
                    duration: const Duration(seconds: 1),
                    interval: const Duration(seconds: 1),
                    enabled: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full width rectangular image placeholder
                        Container(
                          height: 200, // Facebook-style image height
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(Dimensions.radiusSmall),
                              topRight: Radius.circular(Dimensions.radiusSmall),
                            ),
                          ),
                        ),

                        // Text details below
                        Padding(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title/name
                              Container(
                                height: 18,
                                width: double.infinity,
                                color: Theme.of(context).shadowColor,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              // Subtitle/description
                              Container(
                                height: 12,
                                width: double.infinity,
                                color: Theme.of(context).shadowColor,
                              ),
                              const SizedBox(height: 5),
                              Container(
                                height: 12,
                                width: Get.width * 0.7,
                                color: Theme.of(context).shadowColor,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              // Rating/price row
                              Row(
                                children: [
                                  Container(
                                    height: 15,
                                    width: 80,
                                    color: Theme.of(context).shadowColor,
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeDefault,
                                  ),
                                  Container(
                                    height: 15,
                                    width: 60,
                                    color: Theme.of(context).shadowColor,
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

*/

import 'dart:math';
import 'package:afriendorse/feature/provider/widgets/provider_item_view.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomeRecommendProvider extends StatefulWidget {
  final double height;
  final GlobalKey<CustomShakingWidgetState>? signInShakeKey;
  const HomeRecommendProvider({
    super.key,
    required this.height,
    this.signInShakeKey,
  });

  @override
  State<HomeRecommendProvider> createState() => _HomeRecommendProviderState();
}

class _HomeRecommendProviderState extends State<HomeRecommendProvider> {
  Future<Map<String, Map<String, dynamic>>>? _extrasFuture;
  String _sig = '';

  Future<Map<String, Map<String, dynamic>>> _fetchAthleteExtrasByMysqlIds(
    List<String> ids,
  ) async {
    final out = <String, Map<String, dynamic>>{};
    if (ids.isEmpty) return out;

    // Firestore whereIn max = 30
    for (var i = 0; i < ids.length; i += 30) {
      final chunk = ids.sublist(i, min(i + 30, ids.length));
      final qs = await FirebaseFirestore.instance
          .collection('athletes')
          .where('mysqlAthleteId', whereIn: chunk)
          .get();

      for (final d in qs.docs) {
        final data = d.data();
        final mysqlId = (data['mysqlAthleteId'] ?? '').toString().trim();
        if (mysqlId.isNotEmpty) out[mysqlId] = data;
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProviderBookingController>(
      builder: (c) {
        final list = c.providerList;

        if (list == null) {
          return HomeRecommendedProviderShimmer(height: widget.height);
        }
        if (list.isEmpty) return const SizedBox();

        // Build signature so we only refetch when ids change
        final ids = list
            .map((p) => (p.id ?? '').toString().trim())
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();

        ids.sort();
        final newSig = ids.join('|');

        if (_extrasFuture == null || newSig != _sig) {
          _sig = newSig;
          _extrasFuture = _fetchAthleteExtrasByMysqlIds(ids);
        }
        return Container(
          color: Get.isDarkMode
              ? Colors.grey.shade900
              : Colors.transparent, // ← clean white/card background
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // ← stop trying to expand infinitely
            children: [
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault,
                  15,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeSmall,
                ),
                child: TitleWidget(
                  // textDecoration: TextDecoration.underline,
                  title: 'recommended_experts_for_you'.tr,
                  onTap: () => Get.toNamed(RouteHelper.getAllProviderRoute()),
                ),
              ),

              FutureBuilder<Map<String, Map<String, dynamic>>>(
                // ← no Expanded wrapper
                future: _extrasFuture,
                builder: (context, snap) {
                  final extras = snap.data ?? const {};

                  return ListView.builder(
                    shrinkWrap: true, // ← key fix
                    physics:
                        const NeverScrollableScrollPhysics(), // ← let parent scroll
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeExtraSmall + 2,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    itemCount: list.length.clamp(
                      0,
                      3,
                    ), // show max 10 on home screen
                    itemBuilder: (context, index) {
                      final p = list[index];
                      final mysqlId = (p.id ?? '').toString().trim();

                      return ProviderItemView(
                        providerData: p,
                        index: index,
                        signInShakeKey: widget.signInShakeKey,
                        isVerticalLayout: true,
                        athleteExtras: extras[mysqlId],
                      );
                    },
                  );
                },
              ),
              // After the FutureBuilder, add:
              if (list.length > 3)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: GestureDetector(
                    onTap: () => Get.toNamed(RouteHelper.getAllProviderRoute()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF045F25).withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF045F25).withOpacity(0.05),
                      ),
                      child: const Text(
                        'See all athletes →',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF045F25),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
        /* return Container(
          color: Get.isDarkMode
              ? Colors.grey.shade900
              : Theme.of(context).primaryColor.withValues(alpha: 0.12),
          child: Stack(
            children: [
              Image.asset(
                Images.createPostBackgroundImage,
                width: Get.width,
                height: widget.height * 0.3,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: Column(
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeDefault,
                        15,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeSmall,
                      ),
                      child: TitleWidget(
                        textDecoration: TextDecoration.underline,
                        title: 'recommended_experts_for_you'.tr,
                        onTap: () =>
                            Get.toNamed(RouteHelper.getAllProviderRoute()),
                      ),
                    ),

                    Expanded(
                      child: FutureBuilder<Map<String, Map<String, dynamic>>>(
                        future: _extrasFuture,
                        builder: (context, snap) {
                          final extras = snap.data ?? const {};

                          return ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeExtraSmall + 2,
                              vertical: Dimensions.paddingSizeSmall,
                            ),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final p = list[index];
                              final mysqlId = (p.id ?? '').toString().trim();

                              return ProviderItemView(
                                providerData: p,
                                index: index,
                                signInShakeKey: widget.signInShakeKey,
                                isVerticalLayout: true,

                                // ✅ pass Firestore athlete listing doc (if found)
                                athleteExtras: extras[mysqlId],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      */
      },
    );
  }
}

class HomeRecommendedProviderShimmer extends StatelessWidget {
  final double height;
  const HomeRecommendedProviderShimmer({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
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
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Column(
        children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 15,
                width: 130,
                color: Theme.of(context).shadowColor,
              ),
              Container(
                height: 15,
                width: 80,
                color: Theme.of(context).shadowColor,
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Vertical shimmer list
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical, // Changed to vertical
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeDefault,
                    left: Dimensions.paddingSizeSmall,
                    right: Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: Get.isDarkMode
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.grey[200]!,
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                  ),
                  child: Shimmer(
                    duration: const Duration(seconds: 1),
                    interval: const Duration(seconds: 1),
                    enabled: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full width rectangular image placeholder
                        Container(
                          height: 200, // Facebook-style image height
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(Dimensions.radiusSmall),
                              topRight: Radius.circular(Dimensions.radiusSmall),
                            ),
                          ),
                        ),

                        // Text details below
                        Padding(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title/name
                              Container(
                                height: 18,
                                width: double.infinity,
                                color: Theme.of(context).shadowColor,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              // Subtitle/description
                              Container(
                                height: 12,
                                width: double.infinity,
                                color: Theme.of(context).shadowColor,
                              ),
                              const SizedBox(height: 5),
                              Container(
                                height: 12,
                                width: Get.width * 0.7,
                                color: Theme.of(context).shadowColor,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              // Rating/price row
                              Row(
                                children: [
                                  Container(
                                    height: 15,
                                    width: 80,
                                    color: Theme.of(context).shadowColor,
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeDefault,
                                  ),
                                  Container(
                                    height: 15,
                                    width: 60,
                                    color: Theme.of(context).shadowColor,
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
