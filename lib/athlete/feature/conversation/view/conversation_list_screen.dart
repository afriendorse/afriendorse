import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

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

  _loadData() async {
    await Get.find<ConversationController>().getChannelList(
      1,
      type: "serviceman",
    );
    Get.find<ConversationController>().getChannelList(1, type: "customer");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: 'inbox'.tr,
        onBackPressed: () {
          if (widget.fromNotification == "fromNotification") {
            Get.offNamed(RouteHelper.getInitialRoute());
          } else {
            if (Get.find<ConversationController>().isActiveSuffixIcon &&
                Get.find<ConversationController>().isSearchComplete) {
              Get.find<ConversationController>().clearSearchController();
            } else {
              Get.back();
            }
          }
        },
      ),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: () async =>
            Get.find<ConversationController>().getChannelList(1, reload: true),

        child: GetBuilder<ConversationController>(
          builder: (conversationController) {
            if (conversationController.customerChannelList != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  const ConversationSearchWidget(),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        conversationController.adminConversationModel != null
                            ? ChannelItem(
                                channelData: conversationController
                                    .adminConversationModel!,
                                isAdmin: true,
                              )
                            : const SizedBox(),

                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        ConversationListTabview(
                          tabController: conversationController.tabController,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        // ── Chat List with Bottom Overlay ──────────────────
                        Expanded(
                          child: Stack(
                            children: [
                              TabBarView(
                                controller:
                                    conversationController.tabController,
                                children: [
                                  conversationController.searchedChannelList ==
                                              null &&
                                          !conversationController
                                              .isSearchComplete
                                      ? const ConversationSearchShimmer()
                                      : ConversationListView(
                                          channelList:
                                              conversationController
                                                  .isSearchComplete
                                              ? conversationController
                                                    .searchedCustomerChannelList
                                              : conversationController
                                                    .customerChannelList!,
                                          tabIndex: 0,
                                        ),
                                ],
                              ),

                              // ── Safety Banner Overlay ────────────────────
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
              );
            } else {
              return const ConversationListShimmer();
            }
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
