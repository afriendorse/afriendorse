class MonthlyStats {
  String? sums;
  int? year;
  String? month;
  int? day;

  MonthlyStats({this.sums, this.year, this.month, this.day});

  MonthlyStats.fromJson(Map<String, dynamic> json) {
    sums = json['sums'].toString();
    year = int.parse(json['year'].toString());
    month = json['month'].toString();
    day = int.parse(json['day'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sums'] = sums;
    data['year'] = year;
    data['month'] = month;
    data['day'] = day;
    return data;
  }
}

class YearlyStats {
  String? sums;
  int? year;
  String? month;

  YearlyStats({this.sums, this.year, this.month});

  YearlyStats.fromJson(Map<String, dynamic> json) {
    sums = json['sums'].toString();
    year = int.parse(json['year'].toString());
    month = json['month'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sums'] = sums;
    data['year'] = year;
    data['month'] = month;
    return data;
  }
}

