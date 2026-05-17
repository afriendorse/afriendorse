import 'package:afriendorse/athlete/utils/core_export.dart';

class AdvertisementDetailsModel {
  String? responseCode;
  String? message;
  AdvertisementData? advertisementData;

  AdvertisementDetailsModel({
    this.responseCode,
    this.message,
    this.advertisementData,
  });

  AdvertisementDetailsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    advertisementData = json['content'] != null
        ? AdvertisementData.fromJson(json['content'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (advertisementData != null) {
      data['content'] = advertisementData!.toJson();
    }
    return data;
  }
}
