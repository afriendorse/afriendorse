class PaymentMethodListModel {
  final String? responseCode;
  final String? message;
  final List<PaymentMethodItem>? content;
  final List<dynamic>? errors;

  PaymentMethodListModel({
    this.responseCode,
    this.message,
    this.content,
    this.errors,
  });

  factory PaymentMethodListModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodListModel(
      responseCode: json['response_code'],
      message: json['message'],
      content: json['content'] != null
          ? List<PaymentMethodItem>.from(
          json['content'].map((x) => PaymentMethodItem.fromJson(x)))
          : null,
      errors: json['errors'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_code': responseCode,
      'message': message,
      'content': content?.map((x) => x.toJson()).toList(),
      'errors': errors,
    };
  }
}

class PaymentMethodItem {
  final String? id;
  final String? providerId;
  final String? withdrawalMethodId;
  final String? methodName;
  final Map<String, dynamic>? methodFieldData;
  final bool? isDefault;
  bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentMethodItem({
    this.id,
    this.providerId,
    this.withdrawalMethodId,
    this.methodName,
    this.methodFieldData,
    this.isDefault,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentMethodItem.fromJson(Map<String, dynamic> json) {
    return PaymentMethodItem(
      id: json['id'],
      providerId: json['provider_id'],
      withdrawalMethodId: json['withdrawal_method_id'],
      methodName: json['method_name'],
      methodFieldData: Map<String, dynamic>.from(json['method_field_data'] ?? {}),
      isDefault: json['is_default'],
      isActive: json['is_active'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'withdrawal_method_id': withdrawalMethodId,
      'method_name': methodName,
      'method_field_data': methodFieldData,
      'is_default': isDefault,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

