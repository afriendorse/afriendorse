import 'package:afriendorse/athlete/feature/payement_information/model/payment_method_list_model.dart';
import 'package:afriendorse/athlete/feature/transaction/model/withdraw_method_model.dart';

class DropdownMethodModel {
  String? id;
  String? inputName;
  MethodType? type;
  List<MethodField>? methodFields;
  bool? isDefault;
  Map<String, dynamic>? methodInfo;
  PaymentMethodItem? paymentMethod;
  WithdrawalMethod? withdrawalMethod;

  DropdownMethodModel({
    this.id,
    this.inputName,
    this.type,
    this.methodFields,
    this.methodInfo,
    this.isDefault,
    this.paymentMethod,
    this.withdrawalMethod,
  });

  DropdownMethodModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    inputName = json['input_name'];
    type = MethodType.fromValue(json['type']);
    methodFields = List<MethodField>.from(
      json["method_fields"].map((x) => MethodField.fromJson(x)),
    );
    methodInfo = json['method_info'] != null
        ? Map<String, dynamic>.from(json['method_info'])
        : null;
    isDefault = json['is_default'];
    paymentMethod = json['payment_method'] != null
        ? PaymentMethodItem.fromJson(json['payment_method'])
        : null;
    withdrawalMethod = WithdrawalMethod.fromJson(json['withdrawal_method']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['input_name'] = inputName;
    data['type'] = type;
    if (methodFields != null) {
      data["method_fields"] = List<dynamic>.from(
        (methodFields ?? []).map((x) => x.toJson()),
      );
    }

    if (methodInfo != null) {
      data['method_info'] = methodInfo;
    }
    data['is_default'] = isDefault;
    if (paymentMethod != null) {
      data['payment_method'] = paymentMethod!.toJson();
    }
    if (withdrawalMethod != null) {
      data['withdrawal_method'] = withdrawalMethod?.toJson();
    }
    return data;
  }
}

enum MethodType {
  myMethods('my_methods'),
  others('others');

  final String value;

  const MethodType(this.value);

  static MethodType fromValue(String value) {
    return MethodType.values.firstWhere((e) => e.value == value);
  }

  @override
  String toString() => value;
}
