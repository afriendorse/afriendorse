import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ConversationListView extends StatelessWidget {
  final List<ChannelData> channelList;
  final int tabIndex;
  const ConversationListView({
    super.key,
    required this.channelList,
    this.tabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(
      builder: (conversationController) {
        return channelList.isEmpty
            ? EmptyConversationWidget(
                fromSearch:
                    conversationController.isActiveSuffixIcon &&
                    conversationController.isSearchComplete,
              )
            : RefreshIndicator(
                color: Theme.of(context).primaryColorLight,
                backgroundColor: Theme.of(context).cardColor,
                onRefresh: () async {
                  conversationController.getChannelList(
                    1,
                    type: tabIndex == 0 ? "customer" : "serviceman",
                  );
                },
                child: ListView.builder(
                  controller: tabIndex == 0
                      ? Get.find<ConversationController>()
                            .channelScrollController1
                      : Get.find<ConversationController>()
                            .channelScrollController2,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: channelList.length,
                  itemBuilder: (context, index) {
                    return ChannelItem(channelData: channelList[index]);
                  },
                ),
              );
      },
    );
  }
}
