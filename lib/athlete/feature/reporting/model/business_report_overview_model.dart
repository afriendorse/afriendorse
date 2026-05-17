import 'package:afriendorse/athlete/feature/reporting/model/booking_report_model.dart';

class BusinessReportOverviewModel {
  Content? content;
  BusinessReportOverviewModel({this.content});

  BusinessReportOverviewModel.fromJson(Map<String, dynamic> json) {
    content = json['content'] != null
        ? Content.fromJson(json['content'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (content != null) {
      data['content'] = content!.toJson();
    }
    return data;
  }
}

class Content {
  List<ZonesList>? zones;
  List<Categories>? categories;
  List<SubCategories>? subCategories;
  List<Amounts>? amounts;
  ChartData? chartData;
  TotalPromotionalCost? totalPromotionalCost;
  String? deterministic;

  Content({
    this.zones,
    this.categories,
    this.subCategories,
    this.amounts,
    this.chartData,
    this.totalPromotionalCost,
    this.deterministic,
  });

  Content.fromJson(Map<String, dynamic> json) {
    if (json['zones'] != null) {
      zones = <ZonesList>[];
      json['zones'].forEach((v) {
        zones!.add(ZonesList.fromJson(v));
      });
    }
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
    if (json['sub_categories'] != null) {
      subCategories = <SubCategories>[];
      json['sub_categories'].forEach((v) {
        subCategories!.add(SubCategories.fromJson(v));
      });
    }
    if (json['amounts'] != null) {
      amounts = <Amounts>[];
      json['amounts'].forEach((v) {
        amounts!.add(Amounts.fromJson(v));
      });
    }
    chartData = json['chart_data'] != null
        ? ChartData.fromJson(json['chart_data'])
        : null;
    totalPromotionalCost = json['total_promotional_cost'] != null
        ? TotalPromotionalCost.fromJson(json['total_promotional_cost'])
        : null;
    deterministic = json['deterministic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (zones != null) {
      data['zones'] = zones!.map((v) => v.toJson()).toList();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (subCategories != null) {
      data['sub_categories'] = subCategories!.map((v) => v.toJson()).toList();
    }
    if (amounts != null) {
      data['amounts'] = amounts!.map((v) => v.toJson()).toList();
    }
    if (chartData != null) {
      data['chart_data'] = chartData!.toJson();
    }
    if (totalPromotionalCost != null) {
      data['total_promotional_cost'] = totalPromotionalCost!.toJson();
    }
    data['deterministic'] = deterministic;
    return data;
  }
}

class Amounts {
  double? serviceUnitCost;
  double? discountByAdmin;
  double? serviceTax;
  double? discountByProvider;
  double? couponDiscountByAdmin;
  double? couponDiscountByProvider;
  double? campaignDiscountByAdmin;
  double? campaignDiscountByProvider;
  double? adminCommission;
  double? providerEarning;
  int? year;

  Amounts({
    this.serviceUnitCost,
    this.discountByAdmin,
    this.serviceTax,
    this.discountByProvider,
    this.couponDiscountByAdmin,
    this.couponDiscountByProvider,
    this.campaignDiscountByAdmin,
    this.campaignDiscountByProvider,
    this.adminCommission,
    this.providerEarning,
    this.year,
  });

  Amounts.fromJson(Map<String, dynamic> json) {
    serviceUnitCost = double.tryParse(json['service_unit_cost'].toString());
    discountByAdmin = double.tryParse(json['discount_by_admin'].toString());
    serviceTax = double.tryParse(json['service_tax'].toString());
    discountByProvider = double.tryParse(
      json['discount_by_provider'].toString(),
    );
    couponDiscountByAdmin = double.tryParse(
      json['coupon_discount_by_admin'].toString(),
    );
    couponDiscountByProvider = double.tryParse(
      json['coupon_discount_by_provider'].toString(),
    );
    campaignDiscountByAdmin = double.tryParse(
      json['campaign_discount_by_admin'].toString(),
    );
    campaignDiscountByProvider = double.tryParse(
      json['campaign_discount_by_provider'].toString(),
    );
    providerEarning = double.tryParse(json['provider_earning'].toString());
    adminCommission = double.tryParse(json['admin_commission'].toString());
    year = json['year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_unit_cost'] = serviceUnitCost;
    data['discount_by_admin'] = discountByAdmin;
    data['service_tax'] = serviceTax;
    data['discount_by_provider'] = discountByProvider;
    data['coupon_discount_by_admin'] = couponDiscountByAdmin;
    data['coupon_discount_by_provider'] = couponDiscountByProvider;
    data['campaign_discount_by_admin'] = campaignDiscountByAdmin;
    data['campaign_discount_by_provider'] = campaignDiscountByProvider;
    data['admin_commission'] = adminCommission;
    data['provider_earning'] = providerEarning;
    data['year'] = year;
    return data;
  }
}

class ChartData {
  List<double>? earnings;
  List<double>? expenses;
  List<int>? timeline;

  ChartData({this.earnings, this.expenses, this.timeline});

  ChartData.fromJson(Map<String, dynamic> json) {
    if (json['earnings'] != null) {
      earnings = [];
      json['earnings'].forEach((v) {
        earnings?.add(double.parse(v.toString()));
      });
    }
    if (json['expenses'] != null) {
      expenses = [];
      json['expenses'].forEach((v) {
        expenses?.add(double.parse(v.toString()));
      });
    }
    timeline = json['timeline'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['earnings'] = earnings;
    data['expenses'] = expenses;
    data['timeline'] = timeline;
    return data;
  }
}

class TotalPromotionalCost {
  double? discount;
  double? coupon;
  double? campaign;

  TotalPromotionalCost({this.discount, this.coupon, this.campaign});

  TotalPromotionalCost.fromJson(Map<String, dynamic> json) {
    discount = double.tryParse(json['discount'].toString());
    coupon = double.tryParse(json['coupon'].toString());
    campaign = double.tryParse(json['campaign'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['discount'] = discount;
    data['coupon'] = coupon;
    data['campaign'] = campaign;
    return data;
  }
}
