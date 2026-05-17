import 'package:afriendorse/athlete/feature/service_details/model/service_details_model.dart';

class ServiceSubCategoryModel {
  String? id;
  String? parentId;
  String? name;
  String? image;
  String? imageFullPath;
  int? position;
  String? description;
  int? isActive;
  String? createdAt;
  String? updatedAt;
  int? isSubscribed;
  List<ServiceModel>? services;
  int? servicesCount;

  ServiceSubCategoryModel({
    String? id,
    String? parentId,
    String? name,
    String? image,
    String? imageFullPath,
    int? position,
    String? description,
    int? isActive,
    String? createdAt,
    String? updatedAt,
    int? isSubscribed,
    List<ServiceModel>? services,
    int? servicesCount,
  }) {
    if (id != null) {
      id = id;
    }
    if (parentId != null) {
      parentId = parentId;
    }
    if (name != null) {
      name = name;
    }
    if (image != null) {
      image = image;
    }
    if (imageFullPath != null) {
      imageFullPath = imageFullPath;
    }
    if (position != null) {
      position = position;
    }
    if (description != null) {
      description = description;
    }
    if (isActive != null) {
      isActive = isActive;
    }
    if (createdAt != null) {
      createdAt = createdAt;
    }
    if (updatedAt != null) {
      updatedAt = updatedAt;
    }
    if (isSubscribed != null) {
      isSubscribed = isSubscribed;
    }
    if (services != null) {
      services = services;
    }
    if (servicesCount != null) {
      servicesCount = servicesCount;
    }
  }

  ServiceSubCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    name = json['name'];
    image = json['image'];
    imageFullPath = json['image_full_path'];
    position = int.parse(json['position'].toString());
    description = json['description'];
    isActive = int.parse(json['is_active'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isSubscribed = json['is_subscribed'];
    if (json['services'] != null) {
      services = <ServiceModel>[];
      json['services'].forEach((v) {
        services!.add(ServiceModel.fromJson(v));
      });
    }
    servicesCount = int.tryParse(json['services_count'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['parent_id'] = parentId;
    data['name'] = name;
    data['image'] = image;
    data['image_full_path'] = imageFullPath;
    data['position'] = position;
    data['description'] = description;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_subscribed'] = isSubscribed;
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    data['services_count'] = servicesCount;
    return data;
  }
}
