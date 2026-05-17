import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class BusinessReportFilteredWidget extends StatelessWidget {
  const BusinessReportFilteredWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessReportController>(
      builder: (businessReportController) {
        return Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          children: [
            if (businessReportController.selectedZoneName != null)
              FilterRemoveItem(
                title: "${businessReportController.selectedZoneName}".tr,
                onTap: () async {
                  businessReportController.removeFilteredItem(
                    removeItem: "zone",
                  );
                  showCustomDialog(child: const CustomLoader());
                  await loadData(businessReportController);
                  Get.back();
                },
              ),

            if (businessReportController.selectedCategoryName != null)
              FilterRemoveItem(
                title: "${businessReportController.selectedCategoryName}".tr,
                onTap: () async {
                  businessReportController.removeFilteredItem(
                    removeItem: "category",
                  );
                  showCustomDialog(child: const CustomLoader());
                  await loadData(businessReportController);
                  Get.back();
                },
              ),

            if (businessReportController.selectedSubcategoryName != null)
              FilterRemoveItem(
                title: "${businessReportController.selectedSubcategoryName}".tr,
                onTap: () async {
                  businessReportController.removeFilteredItem(
                    removeItem: "subCategory",
                  );
                  showCustomDialog(child: const CustomLoader());
                  await loadData(businessReportController);
                  Get.back();
                },
              ),

            if (businessReportController.dateRange != null &&
                businessReportController.dateRange != "custom_date")
              FilterRemoveItem(
                title: "${businessReportController.dateRange}".tr,
                onTap: () async {
                  businessReportController.removeFilteredItem(
                    removeItem: "date_range",
                  );
                  showCustomDialog(child: const CustomLoader());
                  await loadData(businessReportController);
                  Get.back();
                },
              ),

            if (businessReportController.dateRange == "custom_date" &&
                businessReportController.endDate != null &&
                businessReportController.startDate != null)
              FilterRemoveItem(
                title:
                    "${businessReportController.dateFormat.format(businessReportController.startDate!).toString()} "
                    "- ${businessReportController.dateFormat.format(businessReportController.endDate!).toString()}",
                onTap: () async {
                  businessReportController.removeFilteredItem(
                    removeItem: "date_range",
                  );
                  showCustomDialog(child: const CustomLoader());
                  await loadData(businessReportController);
                  Get.back();
                },
              ),
          ],
        );
      },
    );
  }
}

Future<void> loadData(BusinessReportController controller) async {
  if (controller.businessReportTabController?.index == 1) {
    await controller.getBusinessReportEarningData(1, reload: true);
  } else if (controller.businessReportTabController?.index == 2) {
    await controller.getBusinessReportExpenseData(1, reload: true);
  } else {
    await controller.getBusinessReportOverviewData(1, reload: true);
  }
}
