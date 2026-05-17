import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/reporting/model/booking_report_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingReportController extends GetxController implements GetxService {
  final ReportRepo reportRepo;
  BookingReportController({required this.reportRepo});

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

  String? _dateRange;
  String? get dateRange => _dateRange;

  List<String> bookingStatus = [
    'all',
    'accepted',
    'ongoing',
    'completed',
    'canceled',
  ];
  String? _selectedBookingStatus;
  String? get selectedBookingStatus => _selectedBookingStatus;

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

  List<String> _subcategoryNameList = [];
  List<SubCategories> _subcategoriesList = [];
  List<String> get subcategoryNameList => _subcategoryNameList;
  String? _selectedSubcategoryName;
  String? get selectedSubcategoryName => _selectedSubcategoryName;
  String? _selectedSubcategoryId;
  String? get selectedSubcategoryId => _selectedSubcategoryId;

  BookingReportModel? _bookingReportModel;
  BookingReportModel? get bookingReportModel => _bookingReportModel;

  List<BookingFilterData> _bookingReportFilterData = [];
  List<BookingFilterData> get bookingReportFilterData =>
      _bookingReportFilterData;

  ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> barChartData = [];

  bool _isFiltered = false;
  bool get isFiltered => _isFiltered;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _fromDate;
  String? _toDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-d');
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  DateFormat get dateFormat => _dateFormat;

  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (_offset < _pageSize!) {
          getBookingReportData(offset + 1, reload: true);
        }
      }
    });
  }

  Future<void> getBookingReportData(int offset, {bool reload = false}) async {
    _offset = offset;
    resetDropDownValue();
    if (reload) {
      _isLoading = true;
      update();
    }

    Map<String, dynamic> data = {
      "booking_status": _selectedBookingStatus ?? "all",
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

    Response response = await reportRepo.getBookingReportData(offset, data);
    if (response.statusCode == 200) {
      _bookingReportModel = BookingReportModel.fromJson(response.body);
      if (_bookingReportModel?.content != null) {
        _pageSize = _bookingReportModel?.content?.filterData?.lastPage;
        if (_zonesList.isEmpty) {
          _zonesList.addAll(_bookingReportModel!.content!.zones!);
        }
        if (_categoriesList.isEmpty) {
          _categoriesList.addAll(_bookingReportModel!.content!.categories!);
        }
        if (_subcategoriesList.isEmpty) {
          _subcategoriesList.addAll(
            _bookingReportModel!.content!.subCategories!,
          );
        }
        if (_offset == 1) {
          _bookingReportFilterData = [];
          _bookingReportFilterData.addAll(
            _bookingReportModel!.content!.filterData!.data!,
          );
        } else {
          _bookingReportFilterData.addAll(
            _bookingReportModel!.content!.filterData!.data!,
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
          i < _bookingReportModel!.content!.chartData!.timeline!.length;
          i++
        ) {
          String timeline = _bookingReportModel!
              .content!
              .chartData!
              .timeline![i]
              .toString();
          String taxAmount = _bookingReportModel!
              .content!
              .chartData!
              .taxAmount![i]
              .toString();
          String adminCommission = _bookingReportModel!
              .content!
              .chartData!
              .adminCommission![i]
              .toString();
          double? bookingAmount =
              _bookingReportModel!.content!.chartData!.bookingAmount![i];

          if (bookingAmount > 0) {
            barChartData.add({
              'timeline': timeline,
              'Amount': bookingAmount,
              'tax': PriceConverter.convertPrice(double.tryParse(taxAmount)),
              'commission': PriceConverter.convertPrice(
                double.tryParse(adminCommission),
              ),
            });
          }
        }
      }
    } else {
      _bookingReportModel = null;
      _bookingReportFilterData = [];
      barChartData = [];
    }
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

  void getSubcategoryList() {
    _subcategoryNameList = [];
    for (var element in _subcategoriesList) {
      if (element.parentId == _selectedCategoryId) {
        _subcategoryNameList.add(element.name!);
        _selectedSubcategoryName = element.name;
      }
    }

    if (_subcategoryNameList.length > 1) {
      _subcategoryNameList.insert(0, 'all');
      _selectedSubcategoryName = 'all';
    } else if (_subcategoryNameList.length == 1) {
      _selectedSubcategoryName = _subcategoryNameList[0];
    }
    update();
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
    } else if (type == 'booking_status') {
      _selectedBookingStatus = dropdownValue;
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
    _selectedBookingStatus = null;
    _isFiltered = false;
    update();
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
    } else if (removeItem == 'status') {
      _selectedBookingStatus = null;
    } else if (removeItem == "date_range") {
      _startDate = null;
      _endDate = null;
      _dateRange = null;
    }

    if (_selectedZoneName == null &&
        _dateRange == null &&
        _selectedCategoryName == null &&
        _selectedSubcategoryName == null &&
        _selectedBookingStatus == null) {
      _isFiltered = false;
    }
    update();
  }

  updatedIsFilteredValue({bool shouldUpdate = true}) {
    if (_selectedZoneName == null &&
        _dateRange == null &&
        _selectedCategoryName == null &&
        _selectedSubcategoryName == null &&
        _selectedBookingStatus == null) {
      _isFiltered = false;
    } else {
      _isFiltered = true;
    }

    if (shouldUpdate) {
      update();
    }
  }
}
