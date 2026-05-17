import 'package:afriendorse/athlete/feature/profile/model/provider_model.dart';

class PackageSubscriptionDetailsModel {
  String? responseCode;
  String? message;
  SubscribedPackageDetails? content;

  PackageSubscriptionDetailsModel({
    this.responseCode,
    this.message,
    this.content,
  });

  PackageSubscriptionDetailsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content = json['content'] != null
        ? SubscribedPackageDetails.fromJson(json['content'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (content != null) {
      data['content'] = content!.toJson();
    }
    return data;
  }
}
