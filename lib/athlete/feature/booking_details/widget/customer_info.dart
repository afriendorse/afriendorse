import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingDetailsCustomerInfo extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const BookingDetailsCustomerInfo({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: context.customThemeColors.lightShadow,
          ),
          margin: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeDefault,
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Customer_Info".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              BottomCard(
                name:
                    bookingDetails.serviceAddress?.contactPersonName ??
                    bookingDetails
                        .subBooking
                        ?.serviceAddress
                        ?.contactPersonName ??
                    "${bookingDetails.customer?.firstName ?? ""} ${bookingDetails.customer?.lastName ?? ""}",
                phone:
                    bookingDetails.serviceAddress?.contactPersonNumber ??
                    bookingDetails
                        .subBooking
                        ?.serviceAddress
                        ?.contactPersonNumber ??
                    bookingDetails.customer?.phone ??
                    bookingDetails.customer?.email ??
                    "",
                image:
                    bookingDetails.customer?.profileImageFullPath ??
                    bookingDetails.subBooking?.customer?.profileImageFullPath ??
                    "",
                address:
                    bookingDetails.serviceAddress?.address ??
                    bookingDetails.subBooking?.serviceAddress?.address ??
                    'address_not_found'.tr,
              ),
            ],
          ),
        );
      },
    );
  }
}
