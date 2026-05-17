import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class SubscriptionTransactionListScreen extends StatefulWidget {
  const SubscriptionTransactionListScreen({super.key});

  @override
  State<SubscriptionTransactionListScreen> createState() =>
      _SubscriptionTransactionListScreenState();
}

class _SubscriptionTransactionListScreenState
    extends State<SubscriptionTransactionListScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<BusinessSubscriptionController>().getSubscriptionTransactionList(
      1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessSubscriptionController>(
      builder: (businessSubscriptionController) {
        return businessSubscriptionController.transactionList != null
            ? Column(
                children: [
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  const BusinessTransactionSearchWidget(),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  businessSubscriptionController.searchedTransactionList ==
                              null &&
                          !businessSubscriptionController.isSearchComplete
                      ? const Expanded(child: BookingRequestItemShimmer())
                      : SubscriptionTransactionListview(
                          transactionList:
                              businessSubscriptionController.isSearchComplete
                              ? businessSubscriptionController
                                    .searchedTransactionList!
                              : businessSubscriptionController
                                        .transactionList ??
                                    [],
                        ),
                ],
              )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }
}
