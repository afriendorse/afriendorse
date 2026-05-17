import 'dart:convert';
ServiceCategoryModel serviceCategoryModelFromJson(String str) => ServiceCategoryModel.fromJson(json.decode(str));
String serviceCategoryModelToJson(ServiceCategoryModel data) => json.encode(data.toJson());

class ServiceCategoryModel {
  ServiceCategoryModel({
    this.id,
    this.parentId,
    this.name,
    this.image,
    this.imageFullPath,
    this.position,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });
  String? id;
  String? parentId;
  String? name;
  String? image;
  String? imageFullPath;
  int? position;
  String? description;
  int? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) => ServiceCategoryModel(
    id: json["id"],
    parentId: json["parent_id"],
    name: json["name"],
    image: json["image"],
    imageFullPath : json["image_full_path"],
    position: int.parse(json["position"].toString()),
    description: json["description"],
    isActive: int.parse(json["is_active"].toString()),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "parent_id": parentId,
    "name": name,
    "image": image,
    "image_full_path": imageFullPath,
    "position": position,
    "description": description,
    "is_active": isActive,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}
