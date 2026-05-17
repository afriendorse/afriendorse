class TransactionModel {
  String? responseCode;
  String? message;
  TransactionContent? content;


  TransactionModel(
      {this.responseCode, this.message, this.content});

  TransactionModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content =
    json['content'] != null ? TransactionContent.fromJson(json['content']) : null;

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

class TransactionContent {
  WithdrawRequests? withdrawRequests;
  String? totalCollectedCash;

  TransactionContent({this.withdrawRequests, this.totalCollectedCash});

  TransactionContent.fromJson(Map<String, dynamic> json) {
    withdrawRequests = json['withdraw_requests'] != null
        ? WithdrawRequests.fromJson(json['withdraw_requests'])
        : null;
    totalCollectedCash = json['total_collected_cash'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (withdrawRequests != null) {
      data['withdraw_requests'] = withdrawRequests!.toJson();
    }
    data['total_collected_cash'] = totalCollectedCash;
    return data;
  }
}

class WithdrawRequests {
  int? currentPage;
  List<TransactionData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;

  String? path;
  String? perPage;
  int? to;
  int? total;

  WithdrawRequests(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.path,
        this.perPage,
        this.to,
        this.total});

  WithdrawRequests.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <TransactionData>[];
      json['data'].forEach((v) {
        data!.add(TransactionData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    path = json['path'];
    perPage = json['per_page'];
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
    data['path'] = path;
    data['per_page'] = perPage;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class TransactionData {
  String? id;
  String? userId;
  String? requestUpdatedBy;
  String? amount;
  String? requestStatus;
  String? createdAt;
  String? updatedAt;
  int? isPaid;
  String? providerNote;
  String? adminNote;
  TransactionUser? user;
  RequestUpdater? requestUpdater;

  TransactionData(
      {this.id,
        this.userId,
        this.requestUpdatedBy,
        this.amount,
        this.requestStatus,
        this.createdAt,
        this.updatedAt,
        this.isPaid,
        this.providerNote,
        this.adminNote,
        this.user,
        this.requestUpdater
      });

  TransactionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    requestUpdatedBy = json['request_updated_by'];
    amount = json['amount'].toString();
    requestStatus = json['request_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isPaid = json['is_paid'];
    providerNote = json['note'];
    adminNote = json['admin_note'];
    user = json['user'] != null ? TransactionUser.fromJson(json['user']) : null;
    requestUpdater = json['request_updater'] != null ? RequestUpdater.fromJson(json['request_updater']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['request_updated_by'] = requestUpdatedBy;
    data['amount'] = amount;
    data['request_status'] = requestStatus;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_paid'] = isPaid;
    data['note'] = providerNote;
    data['admin_note'] = adminNote;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (requestUpdater != null) {
      data['request_updater'] = requestUpdater!.toJson();
    }
    return data;
  }
}

class TransactionUser {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? identificationNumber;
  String? identificationType;
  List<String>? identificationImage;
  String? gender;
  String? profileImage;
  int? isPhoneVerified;
  int? isEmailVerified;
  int? isActive;
  String? userType;
  String? createdAt;
  String? updatedAt;
  Account? account;

  TransactionUser(
      {this.id,
        this.firstName,
        this.lastName,
        this.email,
        this.phone,
        this.identificationNumber,
        this.identificationType,
        this.identificationImage,
        this.gender,
        this.profileImage,
        this.isPhoneVerified,
        this.isEmailVerified,
        this.isActive,
        this.userType,
        this.createdAt,
        this.updatedAt,
        this.account});

  TransactionUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    identificationNumber = json['identification_number'];
    identificationType = json['identification_type'];
    identificationImage = json['identification_image'].cast<String>();
    gender = json['gender'];
    profileImage = json['profile_image'];
    isPhoneVerified = json['is_phone_verified'];
    isEmailVerified = json['is_email_verified'];
    isActive = json['is_active'];
    userType = json['user_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    account =
    json['account'] != null ? Account.fromJson(json['account']) : null;
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
    data['gender'] = gender;
    data['profile_image'] = profileImage;
    data['is_phone_verified'] = isPhoneVerified;
    data['is_email_verified'] = isEmailVerified;
    data['is_active'] = isActive;
    data['user_type'] = userType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (account != null) {
      data['account'] = account!.toJson();
    }
    return data;
  }
}

class Account {
  String? id;
  String? userId;
  String? balancePending;
  String? receivedBalance;
  String? accountPayable;
  String? accountReceivable;
  String? totalWithdrawn;
  String? createdAt;
  String? updatedAt;

  Account(
      {this.id,
        this.userId,
        this.balancePending,
        this.receivedBalance,
        this.accountPayable,
        this.accountReceivable,
        this.totalWithdrawn,
        this.createdAt,
        this.updatedAt});

  Account.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    balancePending = json['balance_pending'].toString();
    receivedBalance = json['received_balance'].toString();
    accountPayable = json['account_payable'].toString();
    accountReceivable = json['account_receivable'].toString();
    totalWithdrawn = json['total_withdrawn'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['balance_pending'] = balancePending;
    data['received_balance'] = receivedBalance;
    data['account_payable'] = accountPayable;
    data['account_receivable'] = accountReceivable;
    data['total_withdrawn'] = totalWithdrawn;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class RequestUpdater {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? identificationType;
  String? gender;
  String? profileImage;
  int? isPhoneVerified;
  int? isEmailVerified;
  int? isActive;
  String? userType;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;
  Account? account;

  RequestUpdater(
      {this.id,
        this.firstName,
        this.lastName,
        this.email,
        this.phone,
        this.identificationType,
        this.gender,
        this.profileImage,
        this.isPhoneVerified,
        this.isEmailVerified,
        this.isActive,
        this.userType,
        this.deletedAt,
        this.createdAt,
        this.updatedAt,
        this.account});

  RequestUpdater.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    identificationType = json['identification_type'];
    gender = json['gender'];
    profileImage = json['profile_image'];
    isPhoneVerified = json['is_phone_verified'];
    isEmailVerified = json['is_email_verified'];
    isActive = json['is_active'];
    userType = json['user_type'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    account =
    json['account'] != null ? Account.fromJson(json['account']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['phone'] = phone;
    data['identification_type'] = identificationType;
    data['gender'] = gender;
    data['profile_image'] = profileImage;
    data['is_phone_verified'] = isPhoneVerified;
    data['is_email_verified'] = isEmailVerified;
    data['is_active'] = isActive;
    data['user_type'] = userType;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (account != null) {
      data['account'] = account!.toJson();
    }
    return data;
  }
}


