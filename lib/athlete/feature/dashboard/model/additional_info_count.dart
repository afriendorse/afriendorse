class AdditionalInfoCount {
  int? customizedPostCount;
  int? advertisementCount;
  int? pendingBookingCount;

  AdditionalInfoCount(
      {this.customizedPostCount,
        this.advertisementCount,
        this.pendingBookingCount});

  AdditionalInfoCount.fromJson(Map<String, dynamic> json) {
    customizedPostCount = int.tryParse(json['customized_post_count'].toString());
    advertisementCount = int.tryParse(json['advertisement_count'].toString());
    pendingBookingCount = int.tryParse(json['pending_booking_count'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customized_post_count'] = customizedPostCount;
    data['advertisement_count'] = advertisementCount;
    data['pending_booking_count'] = pendingBookingCount;
    return data;
  }
}
