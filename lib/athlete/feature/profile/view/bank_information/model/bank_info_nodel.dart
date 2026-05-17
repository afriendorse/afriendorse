class BankInfoModel {
  String? responseCode;
  String? message;
  Content? content;


  BankInfoModel({this.responseCode, this.message, this.content});

  BankInfoModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content =
    json['content'] != null ? Content.fromJson(json['content']) : null;
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
  String? id;
  String? providerId;
  String? bankName;
  String? branchName;
  String? accNo;
  String? accHolderName;
  String? routingNumber;
  String? createdAt;
  String? updatedAt;

  Content(
      {this.id,
        this.providerId,
        this.bankName,
        this.branchName,
        this.accNo,
        this.accHolderName,
        this.createdAt,
        this.updatedAt,
        this.routingNumber
      });

  Content.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    bankName = json['bank_name'];
    branchName = json['branch_name'];
    accNo = json['acc_no'];
    accHolderName = json['acc_holder_name'];
    routingNumber = json['routing_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    data['bank_name'] = bankName;
    data['branch_name'] = branchName;
    data['acc_no'] = accNo;
    data['acc_holder_name'] = accHolderName;
    data['routing_number'] = routingNumber;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}