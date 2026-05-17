import 'package:afriendorse/athlete/feature/booking_details/model/bookings_details_model.dart';
import 'package:afriendorse/athlete/feature/service_details/model/service_details_model.dart';

class PostModel {
  String? responseCode;
  String? message;
  Content? content;

  PostModel({this.responseCode, this.message, this.content});

  PostModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content = json['content'] != null
        ? Content.fromJson(json['content'])
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

class Content {
  int? currentPage;
  List<PostData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  String? path;
  String? perPage;
  int? to;
  int? total;

  Content({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  Content.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <PostData>[];
      json['data'].forEach((v) {
        data!.add(PostData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    path = json['path'];
    to = json['to'];
    total = int.tryParse(json['total'].toString());
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
    data['path'] = path;
    data['per_page'] = perPage;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class PostData {
  String? id;
  String? serviceDescription;
  String? bookingSchedule;
  int? isBooked;
  String? customerUserId;
  String? serviceId;
  String? categoryId;
  String? subCategoryId;
  String? serviceAddressId;
  String? bookingId;
  String? createdAt;
  String? updatedAt;
  String? distance;
  // NEW: null = open post (all athletes), set = targeted at specific athlete
  String? targetProviderId;
  List<AdditionInstructions>? additionInstructions;
  ServiceModel? service;
  Category? category;
  SubCategory? subCategory;
  Customer? customer;

  PostData({
    this.id,
    this.serviceDescription,
    this.bookingSchedule,
    this.isBooked,
    this.customerUserId,
    this.serviceId,
    this.categoryId,
    this.subCategoryId,
    this.serviceAddressId,
    this.bookingId,
    this.createdAt,
    this.updatedAt,
    this.distance,
    this.targetProviderId,
    this.additionInstructions,
    this.service,
    this.category,
    this.subCategory,
    this.customer,
  });

  PostData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceDescription = json['service_description'];
    bookingSchedule = json['booking_schedule'];
    isBooked = int.tryParse(json['is_booked'].toString());
    customerUserId = json['customer_user_id'];
    serviceId = json['service_id'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    serviceAddressId = json['service_address_id'];
    bookingId = json['booking_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    distance = json['distance'];
    // NEW: safely read target_provider_id — null if not present
    targetProviderId = json['target_provider_id'];
    if (json['addition_instructions'] != null) {
      additionInstructions = <AdditionInstructions>[];
      json['addition_instructions'].forEach((v) {
        additionInstructions!.add(AdditionInstructions.fromJson(v));
      });
    }
    service = json['service'] != null
        ? ServiceModel.fromJson(json['service'])
        : null;
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;
    subCategory = json['sub_category'] != null
        ? SubCategory.fromJson(json['sub_category'])
        : null;
    customer = json['customer'] != null
        ? Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['service_description'] = serviceDescription;
    data['booking_schedule'] = bookingSchedule;
    data['is_booked'] = isBooked;
    data['customer_user_id'] = customerUserId;
    data['service_id'] = serviceId;
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['service_address_id'] = serviceAddressId;
    data['booking_id'] = bookingId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['distance'] = distance;
    data['target_provider_id'] = targetProviderId; // NEW
    if (additionInstructions != null) {
      data['addition_instructions'] = additionInstructions!
          .map((v) => v.toJson())
          .toList();
    }
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (subCategory != null) {
      data['sub_category'] = subCategory!.toJson();
    }
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    return data;
  }
}

class Service {
  String? id;
  String? name;
  String? shortDescription;
  String? description;
  String? coverImage;
  String? thumbnail;
  String? categoryId;
  String? subCategoryId;
  double? tax;
  int? orderCount;
  int? isActive;
  int? ratingCount;
  double? avgRating;
  String? minBiddingPrice;
  String? createdAt;
  String? updatedAt;
  List<ServiceDiscount>? serviceDiscount;
  List<ServiceDiscount>? campaignDiscount;

  Service({
    this.id,
    this.name,
    this.shortDescription,
    this.description,
    this.coverImage,
    this.thumbnail,
    this.categoryId,
    this.subCategoryId,
    this.tax,
    this.orderCount,
    this.isActive,
    this.ratingCount,
    this.avgRating,
    this.minBiddingPrice,
    this.createdAt,
    this.updatedAt,
    this.serviceDiscount,
    this.campaignDiscount,
  });

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    shortDescription = json['short_description'];
    description = json['description'];
    coverImage = json['cover_image'];
    thumbnail = json['thumbnail'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    tax = double.tryParse(json['tax'].toString());
    orderCount = int.tryParse(json['order_count'].toString());
    isActive = int.tryParse(json['is_active'].toString());
    ratingCount = int.tryParse(json['rating_count'].toString());
    avgRating = double.tryParse(json['avg_rating'].toString());
    minBiddingPrice = json['min_bidding_price'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['service_discount'] != null) {
      serviceDiscount = <ServiceDiscount>[];
      json['service_discount'].forEach((v) {
        serviceDiscount!.add(ServiceDiscount.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['short_description'] = shortDescription;
    data['description'] = description;
    data['cover_image'] = coverImage;
    data['thumbnail'] = thumbnail;
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['tax'] = tax;
    data['order_count'] = orderCount;
    data['is_active'] = isActive;
    data['rating_count'] = ratingCount;
    data['avg_rating'] = avgRating;
    data['min_bidding_price'] = minBiddingPrice;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (serviceDiscount != null) {
      data['service_discount'] = serviceDiscount!
          .map((v) => v.toJson())
          .toList();
    }
    if (campaignDiscount != null) {
      data['campaign_discount'] = campaignDiscount!
          .map((v) => v.toJson())
          .toList();
    }
    return data;
  }
}

class ServiceDiscount {
  int? id;
  String? discountId;
  String? discountType;
  String? typeWiseId;
  String? createdAt;
  String? updatedAt;
  Discount? discount;

  ServiceDiscount({
    this.id,
    this.discountId,
    this.discountType,
    this.typeWiseId,
    this.createdAt,
    this.updatedAt,
    this.discount,
  });

  ServiceDiscount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    discountId = json['discount_id'];
    discountType = json['discount_type'];
    typeWiseId = json['type_wise_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    discount = json['discount'] != null
        ? Discount.fromJson(json['discount'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['discount_id'] = discountId;
    data['discount_type'] = discountType;
    data['type_wise_id'] = typeWiseId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (discount != null) {
      data['discount'] = discount!.toJson();
    }
    return data;
  }
}

class Discount {
  String? id;
  String? discountTitle;
  String? discountType;
  int? discountAmount;
  String? discountAmountType;
  int? minPurchase;
  int? maxDiscountAmount;
  int? limitPerUser;
  String? promotionType;
  int? isActive;
  String? startDate;
  String? endDate;
  String? createdAt;
  String? updatedAt;

  Discount({
    this.id,
    this.discountTitle,
    this.discountType,
    this.discountAmount,
    this.discountAmountType,
    this.minPurchase,
    this.maxDiscountAmount,
    this.limitPerUser,
    this.promotionType,
    this.isActive,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  Discount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    discountTitle = json['discount_title'];
    discountType = json['discount_type'];
    discountAmount = json['discount_amount'];
    discountAmountType = json['discount_amount_type'];
    minPurchase = json['min_purchase'];
    maxDiscountAmount = json['max_discount_amount'];
    limitPerUser = json['limit_per_user'];
    promotionType = json['promotion_type'];
    isActive = json['is_active'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['discount_title'] = discountTitle;
    data['discount_type'] = discountType;
    data['discount_amount'] = discountAmount;
    data['discount_amount_type'] = discountAmountType;
    data['min_purchase'] = minPurchase;
    data['max_discount_amount'] = maxDiscountAmount;
    data['limit_per_user'] = limitPerUser;
    data['promotion_type'] = promotionType;
    data['is_active'] = isActive;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Category {
  String? id;
  String? parentId;
  String? name;
  String? image;
  int? position;
  String? description;
  int? isActive;
  int? isFeatured;
  String? createdAt;
  String? updatedAt;

  Category({
    this.id,
    this.parentId,
    this.name,
    this.image,
    this.position,
    this.description,
    this.isActive,
    this.isFeatured,
    this.createdAt,
    this.updatedAt,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    name = json['name'];
    image = json['image'];
    position = int.tryParse(json['position'].toString());
    description = json['description'];
    isActive = int.tryParse(json['is_active'].toString());
    isFeatured = int.tryParse(json['is_featured'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['parent_id'] = parentId;
    data['name'] = name;
    data['image'] = image;
    data['position'] = position;
    data['description'] = description;
    data['is_active'] = isActive;
    data['is_featured'] = isFeatured;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class SubCategory {
  String? id;
  String? parentId;
  String? name;
  String? image;
  int? position;
  String? description;
  int? isActive;
  int? isFeatured;
  String? createdAt;
  String? updatedAt;

  SubCategory({
    this.id,
    this.parentId,
    this.name,
    this.image,
    this.position,
    this.description,
    this.isActive,
    this.isFeatured,
    this.createdAt,
    this.updatedAt,
  });

  SubCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    name = json['name'];
    image = json['image'];
    position = int.tryParse(json['position'].toString());
    description = json['description'];
    isActive = int.tryParse(json['is_active'].toString());
    isFeatured = int.tryParse(json['is_featured'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['parent_id'] = parentId;
    data['name'] = name;
    data['image'] = image;
    data['position'] = position;
    data['description'] = description;
    data['is_active'] = isActive;
    data['is_featured'] = isFeatured;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class AdditionInstructions {
  String? id;
  String? details;
  String? postId;
  String? createdAt;
  String? updatedAt;

  AdditionInstructions({
    this.id,
    this.details,
    this.postId,
    this.createdAt,
    this.updatedAt,
  });

  AdditionInstructions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    details = json['details'];
    postId = json['post_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['details'] = details;
    data['post_id'] = postId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
