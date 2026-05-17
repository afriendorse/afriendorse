import 'package:afriendorse/athlete/feature/category/model/sub_category_model.dart';

class MySubscriptionModel {
  String? responseCode;
  String? message;
  SubscriptionModelContent? content;

  MySubscriptionModel({this.responseCode, this.message, this.content});

  MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content = json['content'] != null
        ? SubscriptionModelContent.fromJson(json['content'])
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

class SubscriptionModelContent {
  int? currentPage;
  List<SubscriptionModelData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  String? nextPageUrl;
  String? path;
  String? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  SubscriptionModelContent({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  SubscriptionModelContent.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <SubscriptionModelData>[];
      json['data'].forEach((v) {
        data!.add(SubscriptionModelData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class SubscriptionModelData {
  String? id;
  String? providerId;
  String? categoryId;
  String? subCategoryId;
  int? isSubscribed;
  String? createdAt;
  String? updatedAt;
  int? servicesCount;
  int? ongoingBookingCount;
  int? completedBookingCount;
  int? canceledBookingCount;
  ServiceSubCategoryModel? subCategory;

  SubscriptionModelData({
    this.id,
    this.providerId,
    this.categoryId,
    this.subCategoryId,
    this.isSubscribed,
    this.createdAt,
    this.updatedAt,
    this.subCategory,
    this.servicesCount,
    this.ongoingBookingCount,
    this.completedBookingCount,
    this.canceledBookingCount,
  });

  SubscriptionModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    isSubscribed = int.parse(json['is_subscribed'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    servicesCount = int.tryParse(json['services_count'].toString());
    ongoingBookingCount = int.tryParse(
      json['ongoing_booking_count'].toString(),
    );
    completedBookingCount = int.tryParse(
      json['completed_booking_count'].toString(),
    );
    canceledBookingCount = int.tryParse(
      json['canceled_booking_count'].toString(),
    );
    subCategory = json['sub_category'] != null
        ? ServiceSubCategoryModel.fromJson(json['sub_category'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['is_subscribed'] = isSubscribed;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['services_count'] = servicesCount;
    data['ongoing_booking_count'] = ongoingBookingCount;
    data['completed_booking_count'] = completedBookingCount;
    data['canceled_booking_count'] = canceledBookingCount;
    if (subCategory != null) {
      data['sub_category'] = subCategory!.toJson();
    }
    return data;
  }
}
