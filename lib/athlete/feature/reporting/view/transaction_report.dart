import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/helper/help_me.dart';
import 'package:afriendorse/athlete/feature/reporting/model/transaction_report_model.dart';
import 'package:get/get.dart';

class TransactionReport extends StatefulWidget {
  const TransactionReport({super.key});

  @override
  State<TransactionReport> createState() => _TransactionReportState();
}

class _TransactionReportState extends State<TransactionReport> {
  @override
  void initState() {
    super.initState();
    Get.find<TransactionReportController>().getAllTransactionReportData(1);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionReportController>(
      builder: (transactionReportController) {
        return Scaffold(
          appBar: ReportAppBarView(
            title: 'transactions_report'.tr,
            fromPage: 'transaction',
            isFiltered: transactionReportController.isFiltered,
          ),
          body: transactionReportController.transactionReportModel != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    transactionReportController.isFiltered
                        ? const Padding(
                            padding: EdgeInsets.all(
                              Dimensions.paddingSizeDefault,
                            ),
                            child: TransactionFilteredWidget(),
                          )
                        : const SizedBox(),

                    TransactionReportStatistics(
                      accountInfo:
                          transactionReportController.accountInfo ??
                          TransactionReportAccountInfo(
                            balancePending: 0,
                            receivedBalance: 0,
                            accountPayable: 0,
                            accountReceivable: 0,
                            totalWithdrawn: 0,
                          ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? Theme.of(
                                  context,
                                ).cardColor.withValues(alpha: 0.5)
                              : Theme.of(context).cardColor,
                          boxShadow: context.customThemeColors.lightShadow,
                        ),
                        padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeSmall,
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 40,
                              width: Get.width,
                              margin: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: TabBar(
                                controller:
                                    transactionReportController.tabController,
                                unselectedLabelColor: Colors.grey,
                                isScrollable: true,
                                indicatorColor: Theme.of(context).primaryColor,
                                labelColor: Theme.of(context).primaryColor,
                                labelStyle: robotoMedium,
                                indicatorWeight: 2,
                                tabAlignment: TabAlignment.start,
                                indicatorSize: TabBarIndicatorSize.tab,
                                tabs: [
                                  SizedBox(
                                    height: 40,
                                    child: Center(child: Text("all".tr)),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: Center(child: Text("debit".tr)),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: Center(child: Text("credit".tr)),
                                  ),
                                ],

                                onTap: (index) async {
                                  if (isRedundentClick(DateTime.now())) {
                                    return;
                                  }
                                  if (index == 0) {
                                    Get.find<TransactionReportController>()
                                        .getAllTransactionReportData(1);
                                  } else if (index == 1) {
                                    Get.find<TransactionReportController>()
                                        .getDebitTransactionReportData(1);
                                  } else {
                                    Get.find<TransactionReportController>()
                                        .getCreditTransactionReportData(1);
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller:
                                    transactionReportController.tabController,
                                children: [
                                  TransactionReportListView(
                                    tabIndex: 0,
                                    transactionReportList:
                                        transactionReportController
                                            .allTransactionList,
                                  ),
                                  TransactionReportListView(
                                    tabIndex: 1,
                                    transactionReportList:
                                        transactionReportController
                                            .debitTransactionList,
                                  ),
                                  TransactionReportListView(
                                    tabIndex: 2,
                                    transactionReportList:
                                        transactionReportController
                                            .creditTransactionList,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(child: TransactionReportListShimmer()),
        );
      },
    );
  }
}
