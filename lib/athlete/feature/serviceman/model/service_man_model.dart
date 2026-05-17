class ServicemanModel {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? identificationNumber;
  String? identificationType;
  List<String>? identificationImage;
  List<String>? identificationImageFullPath;
  String? gender;
  String? profileImage;
  String? profileImageFullPath;
  int? isPhoneVerified;
  int? isEmailVerified;
  int? isActive;
  String? userType;
  String? createdAt;
  String? updatedAt;
  Serviceman? serviceman;

  ServicemanModel(
      {this.id,
        this.firstName,
        this.lastName,
        this.email,
        this.phone,
        this.identificationNumber,
        this.identificationType,
        this.identificationImage,
        this.identificationImageFullPath,
        this.gender,
        this.profileImage,
        this.profileImageFullPath,
        this.isPhoneVerified,
        this.isEmailVerified,
        this.isActive,
        this.userType,
        this.createdAt,
        this.updatedAt,
        this.serviceman});

  ServicemanModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    identificationNumber = json['identification_number'];
    identificationType = json['identification_type'];
    identificationImage = json['identification_image'] !=null ? json['identification_image'].cast<String>() : [];
    identificationImageFullPath = json['identification_image_full_path'] !=null ? json['identification_image_full_path'].cast<String>() : [];
    gender = json['gender'];
    profileImage = json['profile_image'];
    profileImageFullPath = json['profile_image_full_path'];
    isPhoneVerified = json['is_phone_verified'];
    isEmailVerified = json['is_email_verified'];
    isActive = json['is_active'];
    userType = json['user_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    serviceman = json['serviceman'] != null
        ? Serviceman.fromJson(json['serviceman'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['phone'] = phone;
    data['identification_number'] = identificationNumber;
    data['identification_type'] = identificationType;
    data['identification_image'] = identificationImage;
    data['gender'] = gender;
    data['profile_image'] = profileImage;
    data['profile_image_full_path'] = profileImageFullPath;
    data['is_phone_verified'] = isPhoneVerified;
    data['is_email_verified'] = isEmailVerified;
    data['is_active'] = isActive;
    data['user_type'] = userType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (serviceman != null) {
      data['serviceman'] = serviceman!.toJson();
    }
    return data;
  }
}

class Serviceman {
  String? id;
  String? providerId;

  Serviceman(
      {this.id,
        this.providerId,
      });

  Serviceman.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    return data;
  }
}