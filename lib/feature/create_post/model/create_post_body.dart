class CreatePostBody {
  String? serviceId;
  String? categoryId;
  String? subCategoryId;
  String? addressId;
  String? serviceDescription;
  String? serviceSchedule;
  String? serviceAddress;
  List<String>? additionDescriptions;
  String? targetProviderId;

  CreatePostBody({
    this.serviceId,
    this.categoryId,
    this.subCategoryId,
    this.addressId,
    this.serviceDescription,
    this.serviceSchedule,
    this.additionDescriptions,
    this.serviceAddress,
    this.targetProviderId,
  });

  CreatePostBody.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    addressId = json['service_address_id'];
    serviceAddress = json['service_address'];
    serviceDescription = json['service_description'];
    serviceSchedule = json['booking_schedule'];
    additionDescriptions = json['additional_instructions'].cast<String>();
    targetProviderId = json['target_provider_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_id'] = serviceId;
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['service_address_id'] = addressId;
    data['service_address'] = serviceAddress;
    data['service_description'] = serviceDescription;
    data['booking_schedule'] = serviceSchedule;
    data['additional_instructions'] = additionDescriptions;
    // Only send if set — null means open post, backend treats absence as open
    if (targetProviderId != null && targetProviderId!.isNotEmpty) {
      data['target_provider_id'] = targetProviderId;
    }
    return data;
  }
}
