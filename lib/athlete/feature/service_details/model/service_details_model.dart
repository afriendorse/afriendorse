class ServiceDetailsModel {
  String? responseCode;
  String? message;
  ServiceModel? content;


  ServiceDetailsModel(
      {this.responseCode, this.message, this.content});

  ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content =
    json['content'] != null ? ServiceModel.fromJson(json['content']) : null;

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

class ServiceModel {
  String? id;
  String? name;
  String? shortDescription;
  String? description;
  String? coverImage;
  String? coverImageFullPath;
  String? thumbnail;
  String? thumbnailFullPath;
  String? categoryId;
  String? subCategoryId;
  double? tax;
  int? orderCount;
  int? isActive;
  int? ratingCount;
  double? avgRating;
  double? minBiddingPrice;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;
  List<VariationsReactFormat>? variationsReactFormat;
  List<Variations>? variations;
  List<ServiceDiscount>? serviceDiscount;
  List<ServiceDiscount>? campaignDiscount;

  ServiceModel(
      {this.id,
        this.name,
        this.shortDescription,
        this.description,
        this.coverImage,
        this.coverImageFullPath,
        this.thumbnail,
        this.thumbnailFullPath,
        this.categoryId,
        this.subCategoryId,
        this.tax,
        this.orderCount,
        this.isActive,
        this.ratingCount,
        this.avgRating,
        this.minBiddingPrice,
        this.deletedAt,
        this.createdAt,
        this.updatedAt,
        this.variationsReactFormat,
        this.variations,
        this.serviceDiscount,
        this.campaignDiscount});

  ServiceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    shortDescription = json['short_description'];
    description = json['description'];
    coverImage = json['cover_image'];
    coverImageFullPath = json['cover_image_full_path'];
    thumbnail = json['thumbnail'];
    thumbnailFullPath = json['thumbnail_full_path'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    tax = double.tryParse(json['tax'].toString());
    orderCount = int.tryParse(json['order_count'].toString());
    isActive = int.tryParse(json['is_active'].toString());
    ratingCount = int.tryParse(json['rating_count'].toString());
    avgRating = double.tryParse(json['avg_rating'].toString());
    minBiddingPrice = double.tryParse(json['min_bidding_price'].toString());
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['variations_react_format'] != null) {
      variationsReactFormat = <VariationsReactFormat>[];
      json['variations_react_format'].forEach((v) {
        variationsReactFormat!.add(VariationsReactFormat.fromJson(v));
      });
    }
    if (json['variations'] != null) {
      variations = <Variations>[];
      json['variations'].forEach((v) {
        variations!.add(Variations.fromJson(v));
      });
    }
    if (json['service_discount'] != null) {
      serviceDiscount = <ServiceDiscount>[];
      json['service_discount'].forEach((v) {
        serviceDiscount!.add(ServiceDiscount.fromJson(v));
      });
    }
    if (json['campaign_discount'] != null) {
      campaignDiscount = <ServiceDiscount>[];
      json['campaign_discount'].forEach((v) {
        campaignDiscount!.add(ServiceDiscount.fromJson(v));
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
    data['cover_image_full_path'] = coverImageFullPath;
    data['thumbnail'] = thumbnail;
    data['thumbnail_full_path'] = thumbnailFullPath;
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['tax'] = tax;
    data['order_count'] = orderCount;
    data['is_active'] = isActive;
    data['rating_count'] = ratingCount;
    data['avg_rating'] = avgRating;
    data['min_bidding_price'] = minBiddingPrice;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (variationsReactFormat != null) {
      data['variations_react_format'] =
          variationsReactFormat!.map((v) => v.toJson()).toList();
    }

    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (serviceDiscount != null) {
      data['service_discount'] =
          serviceDiscount!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class VariationsReactFormat {
  String? variationName;
  double? variationPrice;
  List<ZoneWiseVariations>? zoneWiseVariations;

  VariationsReactFormat(
      {this.variationName, this.variationPrice, this.zoneWiseVariations});

  VariationsReactFormat.fromJson(Map<String, dynamic> json) {
    variationName = json['variationName'];
    variationPrice = double.tryParse(json['variationPrice'].toString());
    if (json['zoneWiseVariations'] != null) {
      zoneWiseVariations = <ZoneWiseVariations>[];
      json['zoneWiseVariations'].forEach((v) {
        zoneWiseVariations!.add(ZoneWiseVariations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variationName'] = variationName;
    data['variationPrice'] = variationPrice;
    if (zoneWiseVariations != null) {
      data['zoneWiseVariations'] =
          zoneWiseVariations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ZoneWiseVariations {
  String? id;
  double? price;

  ZoneWiseVariations({this.id, this.price});

  ZoneWiseVariations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    price = double.tryParse(json['price'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['price'] = price;
    return data;
  }
}


class Children {
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

  Children(
      {this.id,
        this.parentId,
        this.name,
        this.image,
        this.position,
        this.description,
        this.isActive,
        this.isFeatured,
        this.createdAt,
        this.updatedAt});

  Children.fromJson(Map<String, dynamic> json) {
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

class Variations {
  int? id;
  String? variant;
  String? variantKey;
  String? serviceId;
  String? zoneId;
  double? price;
  String? createdAt;
  String? updatedAt;
  int quantity = 0;

  Variations(
      {this.id,
        this.variant,
        this.variantKey,
        this.serviceId,
        this.zoneId,
        this.price,
        this.createdAt,
        this.updatedAt,
        required this.quantity,
      });

  Variations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    variant = json['variant'];
    variantKey = json['variant_key'];
    serviceId = json['service_id'];
    zoneId = json['zone_id'];
    price = double.tryParse(json['price'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['variant'] = variant;
    data['variant_key'] = variantKey;
    data['service_id'] = serviceId;
    data['zone_id'] = zoneId;
    data['price'] = price;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;

    data['quantity'] = quantity;
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

  ServiceDiscount(
      {this.id,
        this.discountId,
        this.discountType,
        this.typeWiseId,
        this.createdAt,
        this.updatedAt,
        this.discount});

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
  double? discountAmount;
  String? discountAmountType;
  double? minPurchase;
  double? maxDiscountAmount;
  int? limitPerUser;
  String? promotionType;
  int? isActive;
  String? startDate;
  String? endDate;
  String? createdAt;
  String? updatedAt;

  Discount(
      {this.id,
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
        this.updatedAt});

  Discount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    discountTitle = json['discount_title'];
    discountType = json['discount_type'];
    discountAmount = double.tryParse(json['discount_amount'].toString());
    discountAmountType = json['discount_amount_type'];
    minPurchase = double.tryParse(json['min_purchase'].toString());
    maxDiscountAmount = double.tryParse(json['max_discount_amount'].toString());
    limitPerUser = int.tryParse(json['limit_per_user'].toString());
    promotionType = json['promotion_type'];
    isActive = int.tryParse(json['is_active'].toString());
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
