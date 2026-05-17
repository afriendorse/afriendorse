import 'package:afriendorse/athlete/feature/reporting/model/booking_report_model.dart';
import 'package:afriendorse/athlete/feature/reporting/model/transaction_report_model.dart';
import 'package:afriendorse/athlete/feature/reporting/repository/report_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransactionReportController extends GetxController
    with GetSingleTickerProviderStateMixin
    implements GetxService {
  final ReportRepo reportRepo;
  TransactionReportController({required this.reportRepo});

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

  String? _dateRange;
  String? get dateRange => _dateRange;

  bool _isFiltered = false;
  bool get isFiltered => _isFiltered;

  final List<String> _zoneNameList = [];
  List<ZonesList> _zonesList = [];
  List<String> get zoneNameList => _zoneNameList;
  String? _selectedZoneName;
  String? get selectedZoneName => _selectedZoneName;
  String? _selectedZoneId;
  String? get selectedZoneId => _selectedZoneId;

  TransactionReportModel? _allTransactionReportModel;
  TransactionReportModel? _debitTransactionReportModel;
  TransactionReportModel? _creditTransactionReportModel;
  TransactionReportModel? get transactionReportModel =>
      _allTransactionReportModel;
  TransactionReportModel? get debitTransactionReportModel =>
      _debitTransactionReportModel;
  TransactionReportModel? get creditTransactionReportModel =>
      _creditTransactionReportModel;
  TransactionReportAccountInfo? _accountInfo;
  TransactionReportAccountInfo? get accountInfo => _accountInfo;

  List<TransactionReportData> _allTransactionList = [];
  List<TransactionReportData> get allTransactionList => _allTransactionList;

  List<TransactionReportData> _debitTransactionList = [];
  List<TransactionReportData> get debitTransactionList => _debitTransactionList;

  List<TransactionReportData> _creditTransactionList = [];
  List<TransactionReportData> get creditTransactionList =>
      _creditTransactionList;

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

  TabController? tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    getDebitTransactionReportData(1);
    getCreditTransactionReportData(1);
    tabController!.addListener(() {
      if (tabController!.index == 0) {
        getAllTransactionReportData(1);
      } else if (tabController!.index == 1) {
        getDebitTransactionReportData(1);
      } else {
        getCreditTransactionReportData(1);
      }
      update();
    });

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (_offset < _pageSize!) {
          if (tabController!.index == 0) {
            getAllTransactionReportData(offset + 1, reload: true);
          } else if (tabController!.index == 1) {
            getDebitTransactionReportData(offset + 1, reload: true);
          } else {
            getCreditTransactionReportData(offset + 1, reload: true);
          }
        }
      }
    });
  }

  Future<void> getAllTransactionReportData(
    int offset, {
    bool reload = false,
  }) async {
    _offset = offset;
    _zonesList = [];

    if (reload) {
      _isLoading = true;
      update();
    }
    {
      _loading = true;
    }
    Map<String, dynamic> data = {
      "transaction_type": 'all',
      "date_range": _dateRange ?? "all_time",
      "from": _fromDate,
      "to": _toDate,
    };
    if (_selectedZoneId != null) {
      data.addAll({
        "zone_ids": [_selectedZoneId],
      });
    }
    Response response = await reportRepo.getTransactionReportData(offset, data);

    if (response.statusCode == 200) {
      _allTransactionReportModel = TransactionReportModel.fromJson(
        response.body,
      );

      if (_allTransactionReportModel?.content != null) {
        _pageSize =
            _allTransactionReportModel?.content?.filteredTransactions?.lastPage;
        _zonesList.addAll(_allTransactionReportModel?.content?.zones ?? []);
        _accountInfo = _allTransactionReportModel!.content!.accountInfo!;

        if (_allTransactionReportModel!
            .content!
            .filteredTransactions!
            .data!
            .isEmpty) {
          _accountInfo = null;
        }
        if (_offset == 1) {
          _allTransactionList = [];
          _allTransactionList.addAll(
            _allTransactionReportModel!.content!.filteredTransactions!.data!,
          );
        } else {
          _allTransactionList.addAll(
            _allTransactionReportModel!.content!.filteredTransactions!.data!,
          );
        }
        if (_zoneNameList.isEmpty) {
          for (var element in _zonesList) {
            _zoneNameList.add(element.name!);
          }
        }
      }
    } else {
      _allTransactionList = [];
      _accountInfo = null;
      _allTransactionReportModel = null;
    }
    _isLoading = false;
    _loading = false;
    update();
  }

  Future<void> getDebitTransactionReportData(
    int offset, {
    bool reload = false,
  }) async {
    _offset = offset;
    _zonesList = [];

    if (reload) {
      _isLoading = true;
      update();
    } else {
      _loading = true;
    }

    Map<String, dynamic> data = {
      "transaction_type": 'debit',
      "date_range": _dateRange ?? "all_time",
      "from": _fromDate,
      "to": _toDate,
    };
    if (_selectedZoneId != null) {
      data.addAll({
        "zone_ids": [_selectedZoneId],
      });
    }

    Response response = await reportRepo.getTransactionReportData(offset, data);

    if (response.statusCode == 200) {
      _debitTransactionReportModel = TransactionReportModel.fromJson(
        response.body,
      );

      if (_debitTransactionReportModel?.content != null) {
        _pageSize = _debitTransactionReportModel
            ?.content
            ?.filteredTransactions
            ?.lastPage;
        _zonesList.addAll(_debitTransactionReportModel?.content?.zones ?? []);
        _accountInfo = _debitTransactionReportModel!.content!.accountInfo!;
        if (_debitTransactionReportModel!
            .content!
            .filteredTransactions!
            .data!
            .isEmpty) {
          _accountInfo = null;
        }
        if (_offset == 1) {
          _debitTransactionList = [];
          _debitTransactionList.addAll(
            _debitTransactionReportModel!.content!.filteredTransactions!.data!,
          );
        } else {
          _debitTransactionList.addAll(
            _debitTransactionReportModel!.content!.filteredTransactions!.data!,
          );
        }
        if (_zoneNameList.isEmpty) {
          for (var element in _zonesList) {
            _zoneNameList.add(element.name!);
          }
        }
      }
    } else {
      _debitTransactionList = [];
      _accountInfo = null;
      _debitTransactionReportModel = null;
    }
    _isLoading = false;
    _loading = false;
    update();
  }

  Future<void> getCreditTransactionReportData(
    int offset, {
    bool reload = false,
  }) async {
    _offset = offset;
    _zonesList = [];

    if (reload) {
      _isLoading = true;
      update();
    } else {
      _loading = true;
    }

    Map<String, dynamic> data = {
      "transaction_type": 'credit',
      "date_range": _dateRange ?? "all_time",
      "from": _fromDate,
      "to": _toDate,
    };
    if (_selectedZoneId != null) {
      data.addAll({
        "zone_ids": [_selectedZoneId],
      });
    }

    Response response = await reportRepo.getTransactionReportData(offset, data);

    if (response.statusCode == 200) {
      _creditTransactionReportModel = TransactionReportModel.fromJson(
        response.body,
      );

      if (_creditTransactionReportModel?.content != null) {
        _pageSize = _creditTransactionReportModel
            ?.content
            ?.filteredTransactions
            ?.lastPage;
        _zonesList.addAll(_creditTransactionReportModel!.content!.zones!);
        _accountInfo = _creditTransactionReportModel!.content!.accountInfo!;

        if (_creditTransactionReportModel!
            .content!
            .filteredTransactions!
            .data!
            .isEmpty) {
          _accountInfo = null;
        }
        if (_offset == 1) {
          _creditTransactionList = [];
          _creditTransactionList.addAll(
            _creditTransactionReportModel!.content!.filteredTransactions!.data!,
          );
        } else {
          _creditTransactionList.addAll(
            _creditTransactionReportModel!.content!.filteredTransactions!.data!,
          );
        }

        if (_zoneNameList.isEmpty) {
          for (var element in _zonesList) {
            _zoneNameList.add(element.name!);
          }
        }
      }
    } else {
      _creditTransactionList = [];
      _accountInfo = null;
      _creditTransactionReportModel = null;
    }
    _isLoading = false;
    _loading = false;
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
    } else if (type == 'date_range') {
      _dateRange = dropdownValue;
    }

    update();
  }

  void resetFilterValue({bool updateTabControllerValue = true}) {
    if (updateTabControllerValue) {
      tabController?.index = 0;
    }
    _dateRange = null;
    _toDate = null;
    _fromDate = null;
    _startDate = null;
    _endDate = null;
    update();
  }

  updatedIsFilteredValue({bool shouldUpdate = true}) {
    if (_selectedZoneName == null && _dateRange == null) {
      _isFiltered = false;
    } else {
      _isFiltered = true;
    }

    if (shouldUpdate) {
      update();
    }
  }

  removeFilteredItem({required String removeItem}) {
    if (removeItem == "zone") {
      _selectedZoneName = null;
      _selectedZoneId = null;
    } else if (removeItem == "date_range") {
      _startDate = null;
      _endDate = null;
      _dateRange = null;
    }

    if (_selectedZoneName == null && _dateRange == null) {
      _isFiltered = false;
    }
    update();
  }
}
