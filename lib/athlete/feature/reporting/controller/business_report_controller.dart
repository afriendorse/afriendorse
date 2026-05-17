import 'package:afriendorse/athlete/feature/reporting/model/business_report_earning_model.dart';
import 'package:afriendorse/athlete/feature/reporting/model/booking_report_model.dart';
import 'package:afriendorse/athlete/feature/reporting/model/business_report_expense_model.dart';
import 'package:afriendorse/athlete/feature/reporting/model/business_report_overview_model.dart';
import 'package:afriendorse/athlete/feature/reporting/model/chart_model.dart';
import 'package:afriendorse/athlete/feature/reporting/repository/report_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BusinessReportController extends GetxController
    with GetSingleTickerProviderStateMixin
    implements GetxService {
  final ReportRepo reportRepo;
  BusinessReportController({required this.reportRepo});

  List<String> dateRangeDropdownValue = [
    'all_time',
    'this_week',
    "last_week",
    "last_15_days",
    "this_month",
    "last_month",
    "this_year",
    "last_year",
    "this_year_1st_quarter",
    "this_year_2nd_quarter",
    "this_year_3rd_quarter",
    "this_year_4th_quarter",
    "custom_date",
  ];

  int? _pageSize;
  int _offset = 1;

  int get offset => _offset;
  int? get pageSize => _pageSize;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _loading = false;
  bool get loading => _loading;

  bool _isFiltered = false;
  bool get isFiltered => _isFiltered;

  String? _dateRange;
  String? get dateRange => _dateRange;

  final List<String> _zoneNameList = [];
  List<ZonesList> _zonesList = [];
  List<String> get zoneNameList => _zoneNameList;
  String? _selectedZoneName;
  String? get selectedZoneName => _selectedZoneName;
  String? _selectedZoneId;
  String? get selectedZoneId => _selectedZoneId;

  final List<String> _categoryNameList = [];
  List<Categories> _categoriesList = [];
  List<String> get categoryNameList => _categoryNameList;
  String? _selectedCategoryName;
  String? get selectedCategoryName => _selectedCategoryName;
  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  final List<String> _subcategoryNameList = [];
  List<SubCategories> _subcategoriesList = [];
  List<String> get subcategoryNameList => _subcategoryNameList;
  String? _selectedSubcategoryName;
  String? get selectedSubcategoryName => _selectedSubcategoryName;
  String? _selectedSubcategoryId;
  String? get selectedSubcategoryId => _selectedSubcategoryId;

  BusinessReportOverviewModel? _businessReportOverviewModel;
  BusinessReportOverviewModel? get businessReportOverviewModel =>
      _businessReportOverviewModel;

  BusinessReportEarningModel? _businessReportEarningModel;
  BusinessReportEarningModel? get businessReportEarningModel =>
      _businessReportEarningModel;

  BusinessReportExpenseModel? _businessReportExpenseModel;
  BusinessReportExpenseModel? get businessReportExpenseModel =>
      _businessReportExpenseModel;

  List<Amounts> _businessReportFilterOverviewData = [];
  List<Amounts> get businessReportFilterOverviewData =>
      _businessReportFilterOverviewData;

  List<BusinessReportEarningFilterData> _businessReportFilterEarningData = [];
  List<BusinessReportEarningFilterData> get businessReportFilterEarningData =>
      _businessReportFilterEarningData;

  List<BusinessReportFilterData> _businessReportFilterExpenseData = [];
  List<BusinessReportFilterData> get businessReportFilterExpenseData =>
      _businessReportFilterExpenseData;

  ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> barChartData = [];

  DateTime? _startDate;
  DateTime? _endDate;
  String? _fromDate;
  String? _toDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-d');
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  DateFormat get dateFormat => _dateFormat;

  TabController? businessReportTabController;

  @override
  void onInit() {
    super.onInit();
    businessReportTabController = TabController(vsync: this, length: 3);

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (_offset < _pageSize!) {
          if (businessReportTabController!.index == 0) {
            getBusinessReportOverviewData(offset + 1, reload: true);
          } else if (businessReportTabController!.index == 1) {
            getBusinessReportEarningData(offset + 1, reload: true);
          } else {
            getBusinessReportExpenseData(offset + 1, reload: true);
          }
        }
      }
    });
  }

  Future<void> getBusinessReportOverviewData(
    int offset, {
    bool reload = false,
  }) async {
    resetDropDownValue();
    _offset = offset;

    if (reload) {
      _isLoading = true;
      update();
    } else {
      _loading = true;
    }

    Map<String, dynamic> data = {
      "date_range": _dateRange ?? "all_time",
      "from": _fromDate,
      "to": _toDate,
    };
    if (_selectedZoneId != null) {
      data.addAll({
        "zone_ids": [_selectedZoneId],
      });
    }
    if (_selectedCategoryId != null) {
      data.addAll({
        "category_ids": [_selectedCategoryId],
      });
    }
    if (_selectedSubcategoryId != null) {
      data.addAll({
        "sub_category_ids": [_selectedSubcategoryId],
      });
    }

    Response response = await reportRepo.getBusinessReportOverviewData(
      offset,
      data,
    );
    if (response.statusCode == 200) {
      _businessReportOverviewModel = BusinessReportOverviewModel.fromJson(
        response.body,
      );
      if (_businessReportOverviewModel!.content!.chartData != null) {
        getOverViewChartData(
          _businessReportOverviewModel!.content!.deterministic.toString(),
        );
      }

      if (_businessReportOverviewModel?.content != null) {
        _zonesList.addAll(_businessReportOverviewModel!.content!.zones!);
        _categoriesList.addAll(
          _businessReportOverviewModel!.content!.categories!,
        );
        _subcategoriesList.addAll(
          _businessReportOverviewModel!.content!.subCategories!,
        );
        if (offset == 1) {
          _businessReportFilterOverviewData = [];
          _businessReportFilterOverviewData.addAll(
            _businessReportOverviewModel!.content!.amounts!,
          );
        } else {
          _businessReportFilterOverviewData.addAll(
            _businessReportOverviewModel!.content!.amounts!,
          );
        }

        if (_zoneNameList.isEmpty) {
          for (var element in _zonesList) {
            _zoneNameList.add(element.name!);
          }
        }
        if (_categoryNameList.isEmpty) {
          for (var element in _categoriesList) {
            _categoryNameList.add(element.name!);
          }
        }
        if (_subcategoryNameList.isEmpty) {
          for (var element in _subcategoriesList) {
            _subcategoryNameList.add(element.name!);
          }
        }
      }
    } else {
      _businessReportFilterOverviewData = [];
      _businessReportOverviewModel = null;
      overviewExpenseChart = [];
      overviewEarningChart = [];
    }
    _loading = false;
    _isLoading = false;
    update();
  }

  Future<void> getBusinessReportEarningData(
    int offset, {
    bool reload = false,
  }) async {
    resetDropDownValue();
    _offset = offset;

    if (reload) {
      _isLoading = true;
      update();
    } else {
      _loading = true;
    }
    Map<String, dynamic> data = {
      "date_range": _dateRange ?? "all_time",
      "from": _fromDate,
      "to": _toDate,
    };
    if (_selectedZoneId != null) {
      data.addAll({
        "zone_ids": [_selectedZoneId],
      });
    }
    if (_selectedCategoryId != null) {
      data.addAll({
        "category_ids": [_selectedCategoryId],
      });
    }
    if (_selectedSubcategoryId != null) {
      data.addAll({
        "sub_category_ids": [_selectedSubcategoryId],
      });
    }

    Response response = await reportRepo.getBusinessReportEarningData(
      offset,
      data,
    );
    if (response.statusCode == 200) {
      _businessReportEarningModel = BusinessReportEarningModel.fromJson(
        response.body,
      );

      if (_businessReportEarningModel!.content!.chartData != null) {
        getEarningChartData(
          _businessReportEarningModel!.content!.deterministic.toString(),
        );
      }
      if (_businessReportEarningModel?.content != null) {
        _zonesList.addAll(_businessReportEarningModel!.content!.zones!);
        _categoriesList.addAll(
          _businessReportEarningModel!.content!.categories!,
        );
        _subcategoriesList.addAll(
          _businessReportEarningModel!.content!.subCategories!,
        );
        _pageSize = _businessReportEarningModel!.content!.bookings!.lastPage!;
        if (offset == 1) {
          _businessReportFilterEarningData = [];
          _businessReportFilterEarningData.addAll(
            _businessReportEarningModel!.content!.bookings!.filterData!,
          );
        } else {
          _businessReportFilterEarningData.addAll(
            _businessReportEarningModel!.content!.bookings!.filterData!,
          );
        }

        if (_zoneNameList.isEmpty) {
          for (var element in _zonesList) {
            _zoneNameList.add(element.name!);
          }
        }
        if (_categoryNameList.isEmpty) {
          for (var element in _categoriesList) {
            _categoryNameList.add(element.name!);
          }
        }
        if (_subcategoryNameList.isEmpty) {
          for (var element in _subcategoriesList) {
            _subcategoryNameList.add(element.name!);
          }
        }
      }
    } else {
      _businessReportFilterExpenseData = [];
      _businessReportEarningModel = null;
      earningNetProfitChart = [];
      earningTotalEarningChart = [];
      earningExpenseChart = [];
    }
    _loading = false;
    _isLoading = false;
    update();
  }

  Future<void> getBusinessReportExpenseData(
    int offset, {
    bool reload = false,
  }) async {
    resetDropDownValue();
    _offset = offset;
    barChartData = [];
    if (reload) {
      _isLoading = true;
      update();
    } else {
      _loading = true;
    }
    Map<String, dynamic> data = {
      "date_range": _dateRange ?? "all_time",
      "from": _fromDate,
      "to": _toDate,
    };
    if (_selectedZoneId != null) {
      data.addAll({
        "zone_ids": [_selectedZoneId],
      });
    }
    if (_selectedCategoryId != null) {
      data.addAll({
        "category_ids": [_selectedCategoryId],
      });
    }
    if (_selectedSubcategoryId != null) {
      data.addAll({
        "sub_category_ids": [_selectedSubcategoryId],
      });
    }
    Response response = await reportRepo.getBusinessReportExpenseData(
      offset,
      data,
    );
    if (response.statusCode == 200) {
      _businessReportExpenseModel = BusinessReportExpenseModel.fromJson(
        response.body,
      );
      if (_businessReportExpenseModel?.content != null) {
        _zonesList.addAll(_businessReportExpenseModel!.content!.zones!);
        _categoriesList.addAll(
          _businessReportExpenseModel!.content!.categories!,
        );
        _subcategoriesList.addAll(
          _businessReportExpenseModel!.content!.subCategories!,
        );
        _pageSize = _businessReportExpenseModel!
            .content!
            .filteredBookingAmounts!
            .lastPage;
        if (offset == 1) {
          _businessReportFilterExpenseData = [];
          _businessReportFilterExpenseData.addAll(
            _businessReportExpenseModel!.content!.filteredBookingAmounts!.data!,
          );
        } else {
          _businessReportFilterExpenseData.addAll(
            _businessReportExpenseModel!.content!.filteredBookingAmounts!.data!,
          );
        }

        if (_zoneNameList.isEmpty) {
          for (var element in _zonesList) {
            _zoneNameList.add(element.name!);
          }
        }
        if (_categoryNameList.isEmpty) {
          for (var element in _categoriesList) {
            _categoryNameList.add(element.name!);
          }
        }
        if (_subcategoryNameList.isEmpty) {
          for (var element in _subcategoriesList) {
            _subcategoryNameList.add(element.name!);
          }
        }
        barChartData = [];
        for (
          int i = 0;
          i < _businessReportExpenseModel!.content!.chartData!.timeline!.length;
          i++
        ) {
          double amount = businessReportExpenseModel!
              .content!
              .chartData!
              .expenses![i]
              .toDouble()
              .toPrecision(1);

          if (amount > 0) {
            barChartData.add({
              'timeline': businessReportExpenseModel!
                  .content!
                  .chartData!
                  .timeline![i]
                  .toString(),
              'Amount': amount,
            });
          }
        }
      }
    } else {
      _businessReportExpenseModel = null;
      _businessReportFilterExpenseData = [];
      barChartData = [];
    }
    _loading = false;
    _isLoading = false;
    update();
  }

  void selectDate(String type, BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    ).then((date) {
      if (type == 'start') {
        _startDate = date;
        _fromDate = _dateFormat.format(_startDate!).toString();
      } else {
        _endDate = date;
        _toDate = _dateFormat.format(_endDate!).toString();
      }
      if (date == null) {}
      update();
    });
  }

  void setSelectedDropdownValue(String dropdownValue, {String? type}) {
    if (type == 'zone') {
      for (var element in _zonesList) {
        if (element.name == dropdownValue) {
          _selectedZoneId = element.id!;
          _selectedZoneName = dropdownValue;
        }
      }
    } else if (type == 'category') {
      for (var element in _categoriesList) {
        if (element.name == dropdownValue) {
          _selectedCategoryId = element.id!;
          _selectedCategoryName = dropdownValue;
        }
      }
    } else if (type == 'subcategory') {
      for (var element in _subcategoriesList) {
        if (element.name == dropdownValue) {
          _selectedSubcategoryId = element.id!;
          _selectedSubcategoryName = dropdownValue;
        }
      }
    } else if (type == 'date_range') {
      _dateRange = dropdownValue;
    }
    update();
  }

  void resetDropDownValue() {
    _zonesList = [];
    _categoriesList = [];
    _subcategoriesList = [];
  }

  void resetValue() {
    businessReportTabController?.index = 0;
    _toDate = null;
    _fromDate = null;
    _startDate = null;
    _endDate = null;
    _dateRange = null;
    _selectedCategoryId = null;
    _selectedCategoryName = null;
    _selectedSubcategoryId = null;
    _selectedSubcategoryName = null;
    _selectedZoneId = null;
    _selectedZoneName = null;
    update();
  }

  List<ChartDataModel> earningNetProfitChart = [];
  List<ChartDataModel> earningTotalEarningChart = [];
  List<ChartDataModel> earningExpenseChart = [];

  void getEarningChartData(String type) {
    earningExpenseChart = [];
    earningTotalEarningChart = [];
    earningNetProfitChart = [];

    if (type != 'year') {
      List<int> timeLine = [];
      List<double> netProfit = [];
      List<double> earning = [];
      List<double> expense = [];

      timeLine.addAll(
        _businessReportEarningModel!.content!.chartData!.timeline!,
      );
      netProfit.addAll(
        _businessReportEarningModel!.content!.chartData!.netProfit!,
      );
      earning.addAll(
        _businessReportEarningModel!.content!.chartData!.totalEarning!,
      );
      expense.addAll(
        _businessReportEarningModel!.content!.chartData!.totalExpense!,
      );

      timeLine.sort();

      for (int i = 0; i < timeLine.length; i++) {
        earningExpenseChart.add(
          ChartDataModel(timeLine[i].toString(), expense[i]),
        );
        earningTotalEarningChart.add(
          ChartDataModel(timeLine[i].toString(), earning[i]),
        );
        earningNetProfitChart.add(
          ChartDataModel(timeLine[i].toString(), netProfit[i]),
        );
      }
    } else {
      for (int i = 2020; i < 2030; i++) {
        for (
          int j = 0;
          j < _businessReportEarningModel!.content!.chartData!.timeline!.length;
          j++
        ) {
          if (_businessReportEarningModel!.content!.chartData!.timeline![j] ==
              i) {
            earningNetProfitChart.add(
              ChartDataModel(
                i.toString(),
                _businessReportEarningModel!.content!.chartData!.netProfit![j]
                    .toDouble(),
              ),
            );
            earningTotalEarningChart.add(
              ChartDataModel(
                i.toString(),
                _businessReportEarningModel!
                    .content!
                    .chartData!
                    .totalEarning![j]
                    .toDouble(),
              ),
            );
            earningExpenseChart.add(
              ChartDataModel(
                i.toString(),
                _businessReportEarningModel!
                    .content!
                    .chartData!
                    .totalExpense![j]
                    .toDouble(),
              ),
            );
          } else {
            earningNetProfitChart.add(ChartDataModel(i.toString(), 0));
            earningTotalEarningChart.add(ChartDataModel(i.toString(), 0));
            earningExpenseChart.add(ChartDataModel(i.toString(), 0));
          }
        }
      }
    }
  }

  List<ChartDataModel> overviewExpenseChart = [];
  List<ChartDataModel> overviewEarningChart = [];
  void getOverViewChartData(String type) {
    overviewExpenseChart = [];
    overviewEarningChart = [];
    if (type != 'year') {
      List<int> timeLine = [];
      List<double> expense = [];
      List<double> earning = [];

      earning.addAll(
        _businessReportOverviewModel!.content!.chartData!.earnings!,
      );
      expense.addAll(
        _businessReportOverviewModel!.content!.chartData!.expenses!,
      );
      timeLine.addAll(
        _businessReportOverviewModel!.content!.chartData!.timeline!,
      );

      timeLine.sort();

      for (int i = 0; i < timeLine.length; i++) {
        overviewExpenseChart.add(
          ChartDataModel(timeLine[i].toString(), expense[i]),
        );
        overviewEarningChart.add(
          ChartDataModel(timeLine[i].toString(), earning[i]),
        );
      }
    } else {
      for (int i = 2020; i < 2030; i++) {
        for (
          int j = 0;
          j <
              _businessReportOverviewModel!
                  .content!
                  .chartData!
                  .timeline!
                  .length;
          j++
        ) {
          if (_businessReportOverviewModel!.content!.chartData!.timeline![j] ==
              i) {
            overviewExpenseChart.add(
              ChartDataModel(
                i.toString(),
                _businessReportOverviewModel!.content!.chartData!.expenses![j]
                    .toDouble(),
              ),
            );
            overviewEarningChart.add(
              ChartDataModel(
                i.toString(),
                _businessReportOverviewModel!.content!.chartData!.earnings![j]
                    .toDouble(),
              ),
            );
          } else {
            overviewExpenseChart.add(ChartDataModel(i.toString(), 0));
            overviewEarningChart.add(ChartDataModel(i.toString(), 0));
          }
        }
      }
    }
  }

  removeFilteredItem({required String removeItem}) {
    if (removeItem == "zone") {
      _selectedZoneName = null;
      _selectedZoneId = null;
    } else if (removeItem == 'category') {
      _selectedCategoryName = null;
      _selectedCategoryId = null;
    } else if (removeItem == 'subCategory') {
      _selectedSubcategoryId = null;
      _selectedSubcategoryName = null;
    } else if (removeItem == "date_range") {
      _startDate = null;
      _endDate = null;
      _dateRange = null;
    }

    if (_selectedZoneName == null &&
        _dateRange == null &&
        _selectedCategoryName == null &&
        _selectedSubcategoryName == null) {
      _isFiltered = false;
    }
    update();
  }

  updatedIsFilteredValue({bool shouldUpdate = true}) {
    if (_selectedZoneName == null &&
        _dateRange == null &&
        _selectedCategoryName == null &&
        _selectedSubcategoryName == null) {
      _isFiltered = false;
    } else {
      _isFiltered = true;
    }
    if (shouldUpdate) {
      update();
    }
  }
}
