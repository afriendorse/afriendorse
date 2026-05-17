import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:afriendorse/feature/conversation/widgets/conversation_list_shimmer.dart';
import 'package:afriendorse/feature/conversation/widgets/conversation_listview.dart';
import 'package:afriendorse/feature/conversation/widgets/conversation_search_shimmer.dart';
import 'package:afriendorse/feature/conversation/widgets/conversation_search_widget.dart';
import 'package:afriendorse/feature/conversation/widgets/conversation_tabview.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class ConversationListScreen extends StatefulWidget {
  final String? fromNotification;
  const ConversationListScreen({super.key, this.fromNotification});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Get.find<ConversationController>().clearSearchController(
      shouldUpdate: false,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    await Get.find<ConversationController>().getChannelList(
      1,
      type: "provider",
    );
    Get.find<ConversationController>().getChannelList(1, type: "serviceman");
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      onPopInvoked: () {
        Get.offNamed(RouteHelper.getMainRoute(RouteHelper.chatInbox));
      },
      isNavigationOnOnPop: true,
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(
          title: 'inbox'.tr,
          isBackButtonExist: true,
          onBackPressed: () {
            if (widget.fromNotification == "fromNotification" ||
                !Navigator.canPop(context)) {
              Get.offNamed(RouteHelper.getMainRoute(RouteHelper.chatInbox));
            } else {
              ConversationController conversationController = Get.find();
              if (conversationController.isActiveSuffixIcon &&
                  conversationController.isSearchComplete) {
                conversationController.clearSearchController();
              } else {
                Get.back();
              }
            }
          },
        ),
        body: GetBuilder<ConversationController>(
          builder: (conversationController) {
            return FooterBaseView(
              isScrollView: true,
              child: conversationController.providerChannelList != null
                  ? Center(
                      child: SizedBox(
                        height: ResponsiveHelper.isDesktop(context)
                            ? Get.height * 0.8
                            : Get.height,
                        width: Dimensions.webMaxWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),
                            const ConversationSearchWidget(),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  conversationController
                                              .adminConversationModel !=
                                          null
                                      ? ChannelItem(
                                          channelData: conversationController
                                              .adminConversationModel!,
                                          isAdmin: true,
                                        )
                                      : const SizedBox(),

                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),
                                  ConversationListTabview(
                                    tabController:
                                        conversationController.tabController,
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),

                                  // ── Chat List with Bottom Overlay ──────────
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        TabBarView(
                                          controller: conversationController
                                              .tabController,
                                          children: [
                                            conversationController
                                                            .searchedChannelList ==
                                                        null &&
                                                    !conversationController
                                                        .isSearchComplete
                                                ? const ConversationSearchShimmer()
                                                : ConversationListView(
                                                    channelList:
                                                        conversationController
                                                            .isSearchComplete
                                                        ? conversationController
                                                              .searchedProviderChannelList!
                                                        : conversationController
                                                                  .providerChannelList ??
                                                              [],
                                                    tabIndex: 0,
                                                  ),

                                            conversationController
                                                            .searchedChannelList ==
                                                        null &&
                                                    !conversationController
                                                        .isSearchComplete
                                                ? const ConversationSearchShimmer()
                                                : ConversationListView(
                                                    channelList:
                                                        conversationController
                                                            .isSearchComplete
                                                        ? conversationController
                                                              .searchedServicemanChannelList!
                                                        : conversationController
                                                                  .servicemanChannelList ??
                                                              [],
                                                    tabIndex: 1,
                                                  ),
                                          ],
                                        ),

                                        // ── Safety Banner Overlay ──────────
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: _buildSafetyBanner(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const ConversationListShimmer(),
            );
          },
        ),
      ),
    );
  }

  // ── Safety Reminder Banner (Bottom Overlay) ────────────────────────────

  Widget _buildSafetyBanner(BuildContext context) {
    final primary = Theme.of(context).colorScheme.error;

    return Container(
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: primary.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, size: 18, color: primary),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "disclaimer".tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  "chat_safety_reminder".tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
