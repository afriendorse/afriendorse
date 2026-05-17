class SubscriptionTransactionModel {
  String? id;
  String? trxType;
  double? debit;
  double? credit;
  String? createdAt;
  String? updatedAt;
  PackageLog? packageLog;

  SubscriptionTransactionModel(
      {this.id,
        this.trxType,
        this.debit,
        this.credit,
        this.createdAt,
        this.updatedAt,
        this.packageLog});

  SubscriptionTransactionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    trxType = json['trx_type'];
    debit = double.tryParse(json['debit'].toString());
    credit = double.tryParse(json['credit'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    packageLog = json['package_log'] != null
        ? PackageLog.fromJson(json['package_log'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['trx_type'] = trxType;
    data['debit'] = debit;
    data['credit'] = credit;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (packageLog != null) {
      data['package_log'] = packageLog!.toJson();
    }
    return data;
  }
}

class PackageLog {
  String? subscriptionPackageId;
  String? packageName;
  String? packagePrice;
  String? startDate;
  String? endDate;
  double? vatPercentage;
  double? vatAmount;
  Payment? payment;

  PackageLog(
      {this.subscriptionPackageId,
        this.packageName,
        this.packagePrice,
        this.startDate,
        this.endDate,
        this.vatPercentage,
        this.vatAmount,
        this.payment});

  PackageLog.fromJson(Map<String, dynamic> json) {
    subscriptionPackageId = json['subscription_package_id'];
    packageName = json['package_name'];
    packagePrice = json['package_price'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    vatPercentage = double.tryParse(json['vat_percentage'].toString());
    vatAmount = double.tryParse(json['vat_amount'].toString());
    payment =
    json['payment'] != null ? Payment.fromJson(json['payment']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subscription_package_id'] = subscriptionPackageId;
    data['package_name'] = packageName;
    data['package_price'] = packagePrice;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['vat_percentage'] = vatPercentage;
    data['vat_amount'] = vatAmount;
    if (payment != null) {
      data['payment'] = payment!.toJson();
    }
    return data;
  }
}

class Payment {
  String? id;
  String? paymentAmount;
  String? currencyCode;
  String? paymentMethod;

  Payment({this.id, this.paymentAmount, this.currencyCode, this.paymentMethod});

  Payment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paymentAmount = json['payment_amount'];
    currencyCode = json['currency_code'];
    paymentMethod = json['payment_method'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['payment_amount'] = paymentAmount;
    data['currency_code'] = currencyCode;
    data['payment_method'] = paymentMethod;
    return data;
  }
}