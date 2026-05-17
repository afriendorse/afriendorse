import 'package:afriendorse/athlete/feature/booking_details/widget/booking_status_button_widget.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class RepeatBookingInformationView extends StatelessWidget {
  const RepeatBookingInformationView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        final bookingDetails = bookingDetailsController.bookingDetails?.content;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: context.customThemeColors.lightShadow,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeDefault,
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          '${'booking'.tr} # ${bookingDetails!.readableId}',
                          overflow: TextOverflow.ellipsis,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge!.color
                                ?.withValues(alpha: 0.9),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        if (bookingDetails.isRepeatBooking == 1)
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            padding: const EdgeInsets.all(2),
                            margin: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeExtraSmall,
                            ),
                            child: const Icon(
                              Icons.repeat,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  BookingStatusButtonWidget(
                    bookingStatus: bookingDetails.bookingStatus,
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              BookingItem(
                img: Images.iconCalendar,
                title: '${'booking_date'.tr} : ',
                subTitle: DateConverter.dateMonthYearTime(
                  DateConverter.isoUtcStringToLocalDate(
                    bookingDetails.createdAt!,
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              // BookingItem(
              //   img: Images.iconLocation,
              //   title: '${'service_address'.tr} : ${bookingDetails.serviceAddress !=null?''
              //       '${bookingDetails.serviceAddress!.address}'
              //       :'address_not_found'.tr
              //   }',
              //   subTitle: '',
              // ),
            ],
          ),
        );
      },
    );
  }
}

class MapUtils {
  MapUtils._();

  static Future<void> openMap(
    double destinationLatitude,
    double destinationLongitude,
    double userLatitude,
    double userLongitude,
  ) async {
    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$userLatitude,$userLongitude'
        '&destination=$destinationLatitude,$destinationLongitude&mode=d';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(
        Uri.parse(googleUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not open the map.';
    }
  }
}
