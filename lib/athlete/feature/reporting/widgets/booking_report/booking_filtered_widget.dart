import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class BookingReportFilteredWidget extends StatelessWidget {
  const BookingReportFilteredWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingReportController>(
      builder: (bookingReportController) {
        return Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          children: [
            if (bookingReportController.selectedZoneName != null)
              FilterRemoveItem(
                title: "${bookingReportController.selectedZoneName}".tr,
                onTap: () async {
                  bookingReportController.removeFilteredItem(
                    removeItem: "zone",
                  );
                  showCustomDialog(child: const CustomLoader());
                  await bookingReportController.getBookingReportData(
                    1,
                    reload: false,
                  );
                  Get.back();
                },
              ),

            if (bookingReportController.selectedCategoryName != null)
              FilterRemoveItem(
                title: "${bookingReportController.selectedCategoryName}".tr,
                onTap: () async {
                  bookingReportController.removeFilteredItem(
                    removeItem: "category",
                  );
                  showCustomDialog(child: const CustomLoader());
                  await bookingReportController.getBookingReportData(
                    1,
                    reload: false,
                  );
                  Get.back();
                },
              ),

            if (bookingReportController.selectedSubcategoryName != null)
              FilterRemoveItem(
                title: "${bookingReportController.selectedSubcategoryName}".tr,
                onTap: () async {
                  bookingReportController.removeFilteredItem(
                    removeItem: "subCategory",
                  );
                  showCustomDialog(child: const CustomLoader());
                  await bookingReportController.getBookingReportData(
                    1,
                    reload: false,
                  );
                  Get.back();
                },
              ),

            if (bookingReportController.selectedBookingStatus != null)
              FilterRemoveItem(
                title: "${bookingReportController.selectedBookingStatus}".tr,
                onTap: () async {
                  bookingReportController.removeFilteredItem(
                    removeItem: "status",
                  );
                  showCustomDialog(child: const CustomLoader());
                  await bookingReportController.getBookingReportData(
                    1,
                    reload: false,
                  );
                  Get.back();
                },
              ),

            if (bookingReportController.dateRange != null &&
                bookingReportController.dateRange != "custom_date")
              FilterRemoveItem(
                title: "${bookingReportController.dateRange}".tr,
                onTap: () async {
                  bookingReportController.removeFilteredItem(
                    removeItem: "date_range",
                  );
                  showCustomDialog(child: const CustomLoader());
                  await bookingReportController.getBookingReportData(
                    1,
                    reload: false,
                  );
                  Get.back();
                },
              ),

            if (bookingReportController.dateRange == "custom_date" &&
                bookingReportController.endDate != null &&
                bookingReportController.startDate != null)
              FilterRemoveItem(
                title:
                    "${bookingReportController.dateFormat.format(bookingReportController.startDate!).toString()} "
                    "- ${bookingReportController.dateFormat.format(bookingReportController.endDate!).toString()}",
                onTap: () async {
                  bookingReportController.removeFilteredItem(
                    removeItem: "date_range",
                  );
                  showCustomDialog(child: const CustomLoader());
                  await bookingReportController.getBookingReportData(
                    1,
                    reload: false,
                  );
                  Get.back();
                },
              ),
          ],
        );
      },
    );
  }
}
