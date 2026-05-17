import 'package:afriendorse/athlete/utils/dimensions.dart';
import 'package:afriendorse/athlete/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingCountWidget extends StatelessWidget {
  final String totalBookings;
  final String ongoing;
  final String completed;
  final String canceled;

  const BookingCountWidget({
    super.key,
    required this.totalBookings,
    required this.ongoing,
    required this.completed,
    required this.canceled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'booking'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            children: [
              Expanded(
                child: InfoCard(
                  count: totalBookings,
                  title: 'total'.tr,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: InfoCard(
                  count: ongoing,
                  title: 'ongoing'.tr,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: InfoCard(
                  count: completed,
                  title: 'completed'.tr,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: InfoCard(
                  count: canceled,
                  title: 'canceled'.tr,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String count;
  final String title;
  final Color color;

  const InfoCard({
    super.key,
    required this.count,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraSmall,
        vertical: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: color.withValues(alpha: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            count,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
            maxLines: 1,
          ),
          SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            title,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
