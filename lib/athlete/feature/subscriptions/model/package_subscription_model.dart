import 'package:afriendorse/athlete/feature/profile/model/provider_model.dart';

class PackageSubscriptionModel {
  String? responseCode;
  String? message;
  List<SubscriptionPackage>? subscriptionPackages;

  PackageSubscriptionModel({
    this.responseCode,
    this.message,
    this.subscriptionPackages,
  });

  PackageSubscriptionModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    if (json['content'] != null) {
      subscriptionPackages = <SubscriptionPackage>[];
      json['content'].forEach((v) {
        subscriptionPackages!.add(SubscriptionPackage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (subscriptionPackages != null) {
      data['content'] = subscriptionPackages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubscriptionPackage {
  String? id;
  String? name;
  double? price;
  int? duration;
  int? isActive;
  String? description;
  String? createdAt;
  String? updatedAt;
  List<String>? featureList;
  FeatureLimit? featureLimit;

  SubscriptionPackage({
    this.id,
    this.name,
    this.price,
    this.duration,
    this.isActive,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.featureList,
    this.featureLimit,
  });

  SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = double.tryParse(json['price'].toString());
    duration = int.tryParse(json['duration'].toString());
    isActive = int.tryParse(json['is_active'].toString());
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    featureList = json['feature_list'].cast<String>();
    featureLimit = json['feature_limit'] != null
        ? FeatureLimit.fromJson(json['feature_limit'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['duration'] = duration;
    data['is_active'] = isActive;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['feature_list'] = featureList;
    if (featureLimit != null) {
      data['feature_limit'] = featureLimit!.toJson();
    }
    return data;
  }
}
