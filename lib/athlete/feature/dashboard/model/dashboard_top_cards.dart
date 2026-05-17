
import 'dart:convert';

DashboardTopCards dashboardTopCardsFromJson(String str) => DashboardTopCards.fromJson(json.decode(str));

String dashboardTopCardsToJson(DashboardTopCards data) => json.encode(data.toJson());

class DashboardTopCards {
  DashboardTopCards({
    this.totalEarning,
    this.totalSubscribedServices,
    this.totalServiceMan,
    this.totalBookingServed,
  });

  double? totalEarning;
  int? totalSubscribedServices;
  int? totalServiceMan;
  int? totalBookingServed;

  factory DashboardTopCards.fromJson(Map<String, dynamic> json) => DashboardTopCards(
    totalEarning: json["total_earning"].toDouble(),
    totalSubscribedServices: json["total_subscribed_services"],
    totalServiceMan: json["total_service_man"],
    totalBookingServed: json["total_booking_served"],
  );

  Map<String, dynamic> toJson() => {
    "total_earning": totalEarning,
    "total_subscribed_services": totalSubscribedServices,
    "total_service_man": totalServiceMan,
    "total_booking_served": totalBookingServed,
  };
}
