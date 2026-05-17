import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class TransactionFilteredWidget extends StatelessWidget {
  const TransactionFilteredWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionReportController>(
      builder: (transactionController) {
        return Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          children: [
            if (transactionController.selectedZoneName != null)
              FilterRemoveItem(
                title: "${transactionController.selectedZoneName}".tr,
                onTap: () async {
                  transactionController.removeFilteredItem(removeItem: "zone");
                  showCustomDialog(child: const CustomLoader());
                  await _loadData(transactionController);
                  Get.back();
                },
              ),

            if (transactionController.dateRange != null &&
                transactionController.dateRange != "custom_date")
              FilterRemoveItem(
                title: "${transactionController.dateRange}".tr,
                onTap: () async {
                  transactionController.removeFilteredItem(
                    removeItem: "date_range",
                  );
                  showCustomDialog(child: const CustomLoader());
                  await _loadData(transactionController);
                  Get.back();
                },
              ),

            if (transactionController.dateRange == "custom_date" &&
                transactionController.endDate != null &&
                transactionController.startDate != null)
              FilterRemoveItem(
                title:
                    "${transactionController.dateFormat.format(transactionController.startDate!).toString()} "
                    "- ${transactionController.dateFormat.format(transactionController.endDate!).toString()}",
                onTap: () async {
                  transactionController.removeFilteredItem(
                    removeItem: "date_range",
                  );
                  showCustomDialog(child: const CustomLoader());
                  await _loadData(transactionController);
                  Get.back();
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _loadData(
    TransactionReportController transactionReportController,
  ) async {
    if (transactionReportController.tabController!.index == 0) {
      await transactionReportController.getAllTransactionReportData(1);
    } else if (transactionReportController.tabController!.index == 1) {
      await transactionReportController.getDebitTransactionReportData(1);
    } else {
      await transactionReportController.getCreditTransactionReportData(1);
    }
  }
}
