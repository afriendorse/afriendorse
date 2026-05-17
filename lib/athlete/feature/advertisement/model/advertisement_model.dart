
class AdvertisementModel {
  String? responseCode;
  String? message;
  AdvertisementContent? advertisementContent;

  AdvertisementModel({this.responseCode, this.message, this.advertisementContent,});


  AdvertisementModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    advertisementContent =
    json['content'] != null ? AdvertisementContent.fromJson(json['content']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (advertisementContent != null) {
      data['content'] = advertisementContent!.toJson();
    }
    return data;
  }
}

class AdvertisementContent {
  int? currentPage;
  List<AdvertisementData>? advertisementData;
  int? lastPage;
  int? perPage;
  int? to;
  int? total;

  AdvertisementContent(
      {this.currentPage,
        this.advertisementData,
        this.lastPage,
        this.perPage,
        this.to,
        this.total});

  AdvertisementContent.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      advertisementData = <AdvertisementData>[];
      json['data'].forEach((v) {
        advertisementData!.add(AdvertisementData.fromJson(v));
      });
    }
    lastPage = json['last_page'];
    perPage = json['per_page'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (advertisementData != null) {
      data['data'] = advertisementData!.map((v) => v.toJson()).toList();
    }
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class AdvertisementData {
  String? id;
  String? readableId;
  String? title;
  String? description;
  String? providerId;
  int? priority;
  String? type;
  int? isPaid;
  String? startDate;
  String? endDate;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? promotionalVideo;
  String? promotionalVideoFullPath;
  String? providerCoverImage;
  String? providerCoverImageFullPath;
  String? providerProfileImage;
  String? providerProfileImageFullPath;
  String? providerReview;
  String? providerRating;
  String? additionalNote;
  String? defaultTitle;
  String? defaultDescription;
  List<AdvertisementTranslation>? translationList;


  AdvertisementData(
      {this.id,
        this.readableId,
        this.title,
        this.description,
        this.providerId,
        this.priority,
        this.type,
        this.isPaid,
        this.startDate,
        this.endDate,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.promotionalVideo,
        this.promotionalVideoFullPath,
        this.providerCoverImage,
        this.providerCoverImageFullPath,
        this.providerProfileImage,
        this.providerProfileImageFullPath,
        this.providerReview,
        this.providerRating,
        this.additionalNote,
        this.translationList,
        this.defaultTitle,
        this.defaultDescription,
      });

  AdvertisementData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    readableId = json['readable_id'];
    title = json['title'];
    description = json['description'];
    providerId = json['provider_id'];
    priority = int.tryParse(json['priority'].toString());
    type = json['type'];
    isPaid = int.tryParse(json['is_paid'].toString());
    startDate = json['start_date'];
    endDate = json['end_date'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    promotionalVideo = json['promotional_video'];
    promotionalVideoFullPath = json['promotional_video_full_path'];
    providerCoverImage = json['provider_cover_image'];
    providerCoverImageFullPath = json['provider_cover_image_full_path'];
    providerProfileImage = json['provider_profile_image'];
    providerProfileImageFullPath = json['provider_profile_image_full_path'];
    providerReview = json['provider_review'];
    providerRating = json['provider_rating'];
    additionalNote= json['additional_note'];
    defaultTitle = json['default_title'];
    defaultDescription = json['default_description'];
    if (json['translations'] != null) {
      translationList = <AdvertisementTranslation>[];
      json['translations'].forEach((v) {
        translationList!.add(AdvertisementTranslation.fromJson(v));
      });
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['readable_id'] = readableId;
    data['title'] = title;
    data['description'] = description;
    data['provider_id'] = providerId;
    data['priority'] = priority;
    data['type'] = type;
    data['is_paid'] = isPaid;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['promotional_video'] = promotionalVideo;
    data['promotional_video_full_path'] = promotionalVideoFullPath;
    data['provider_cover_image'] = providerCoverImage;
    data['provider_cover_image_full_path'] = providerCoverImageFullPath;
    data['provider_profile_image'] = providerProfileImage;
    data['provider_profile_image_full_path'] = providerProfileImageFullPath;
    data['provider_review'] = providerReview;
    data['provider_rating'] = providerRating;
    data['additional_note'] = additionalNote;
    data['default_title'] = defaultTitle;
    data['default_description'] = defaultDescription;
    if (translationList != null) {
      data['translations'] = translationList!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class AdvertisementTranslation {
  int? id;
  String? translationableType;
  String? translationableId;
  String? locale;
  String? key;
  String? value;

  AdvertisementTranslation(
      {this.id,
        this.translationableType,
        this.translationableId,
        this.locale,
        this.key,
        this.value
      });

  AdvertisementTranslation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    translationableType = json['translationable_type'];
    translationableId = json['translationable_id'];
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['translationable_type'] = translationableType;
    data['translationable_id'] = translationableId;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}




