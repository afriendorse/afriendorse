class DashboardServicemanModel {
  String? id;
  String? providerId;
  String? userId;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  BookingsCount? bookingsCount;
  User? user;

  DashboardServicemanModel(
      {this.id,
        this.providerId,
        this.userId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.bookingsCount,
        this.user});

  DashboardServicemanModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    bookingsCount = json['bookings_count'] != null ? BookingsCount.fromJson(json['bookings_count']) : null;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    data['user_id'] = userId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (bookingsCount != null) {
      data['bookings_count'] = bookingsCount!.toJson();
    }
    return data;
  }
}

class User {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? identificationNumber;
  String? identificationType;
  List<String>? identificationImage;
  List<String>? identificationImageFullPath;
  String? dateOfBirth;
  String? gender;
  String? profileImage;
  String? profileImageFullPath;
  String? fcmToken;
  int? isPhoneVerified;
  int? isEmailVerified;
  String? phoneVerifiedAt;
  String? emailVerifiedAt;
  int? isActive;
  String? userType;
  String? rememberToken;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;

  User(
      {this.id,
        this.firstName,
        this.lastName,
        this.email,
        this.phone,
        this.identificationNumber,
        this.identificationType,
        this.identificationImage,
        this.identificationImageFullPath,
        this.dateOfBirth,
        this.gender,
        this.profileImage,
        this.profileImageFullPath,
        this.fcmToken,
        this.isPhoneVerified,
        this.isEmailVerified,
        this.phoneVerifiedAt,
        this.emailVerifiedAt,
        this.isActive,
        this.userType,
        this.rememberToken,
        this.deletedAt,
        this.createdAt,
        this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    identificationNumber = json['identification_number'];
    identificationType = json['identification_type'];
    identificationImage = json['identification_image'] != null ? json['identification_image'].cast<String>() : [];
    identificationImageFullPath = json['identification_image_full_path'] != null ? json['identification_image_full_path'].cast<String>() : [];
    dateOfBirth = json['date_of_birth'];
    gender = json['gender'];
    profileImage = json['profile_image'];
    profileImageFullPath = json['profile_image_full_path'];
    fcmToken = json['fcm_token'];
    isPhoneVerified = int.tryParse(json['is_phone_verified'].toString());
    isEmailVerified = int.tryParse(json['is_email_verified'].toString());
    phoneVerifiedAt = json['phone_verified_at'];
    emailVerifiedAt = json['email_verified_at'];
    isActive = int.tryParse(json['is_active'].toString());
    userType = json['user_type'];
    rememberToken = json['remember_token'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
    data['identification_image_full_path'] = identificationImageFullPath;
    data['date_of_birth'] = dateOfBirth;
    data['gender'] = gender;
    data['profile_image'] = profileImage;
    data['profile_image_full_path'] = profileImageFullPath;
    data['fcm_token'] = fcmToken;
    data['is_phone_verified'] = isPhoneVerified;
    data['is_email_verified'] = isEmailVerified;
    data['phone_verified_at'] = phoneVerifiedAt;
    data['email_verified_at'] = emailVerifiedAt;
    data['is_active'] = isActive;
    data['user_type'] = userType;
    data['remember_token'] = rememberToken;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}


class BookingsCount {
  int? ongoing;
  int? completed;
  int? canceled;

  BookingsCount({this.ongoing, this.completed, this.canceled});

  BookingsCount.fromJson(Map<String, dynamic> json) {
    ongoing = int.tryParse(json['ongoing'].toString());
    completed = int.tryParse(json['completed'].toString());
    canceled = int.tryParse(json['canceled'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ongoing'] = ongoing;
    data['completed'] = completed;
    data['canceled'] = canceled;
    return data;
  }
}
