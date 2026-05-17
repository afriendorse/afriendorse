/*
import 'package:afriendorse/athlete/feature/custom_post/model/post_model.dart';
import 'package:afriendorse/athlete/feature/dashboard/model/additional_info_count.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

enum EarningType { monthly, yearly }

class DashboardController extends GetxController
    with GetSingleTickerProviderStateMixin
    implements GetxService {
  final DashBoardRepo dashBoardRepo;

  DashboardController({required this.dashBoardRepo});

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: 2);
  }

  bool _isLeapYear = false;
  get isLeapYear => _isLeapYear;

  TabController? tabController;

  DashboardTopCards? dashboardTopCards;
  AdditionalInfoCount? additionalInfoCount;

  List<DashboardServicemanModel> dashboardServicemanList = [];
  List<DashboardRecentActivityModel> dashboardRecentActivityList = [];
  List<SubscriptionModelData> dashboardSubscriptionList = [];
  List<PostData> dashboardCustomizedPostList = [];

  bool _showNormalBooking = true;
  bool get showNormalBooking => _showNormalBooking;

  bool _showRecentActivityList = true;
  bool get showRecentActivityList => _showRecentActivityList;

  int _paymentMethodIndex = -1;

  EarningType _showMonthlyEarnStatisticsChart = EarningType.monthly;

  int get paymentMethodIndex => _paymentMethodIndex;

  EarningType get getChartType => _showMonthlyEarnStatisticsChart;

  void changeGraph(EarningType selectedType) {
    _showMonthlyEarnStatisticsChart = selectedType;
    _selectedYear = DateConverter.stringYear(DateTime.now());
    _selectedMonth = DateFormat('MMMM').format(DateTime.now());
    update();
  }

  void changeTypeOfShowBookingStatus({
    required bool status,
    bool shouldUpdate = true,
  }) {
    _showNormalBooking = status;
    if (status) {
      tabController?.index = 0;
    }
    if (shouldUpdate) {
      update();
    }
  }

  void changeRecentActivityView({bool? status, bool shouldUpdate = true}) {
    if (status != null) {
      _showRecentActivityList = status;
    } else {
      _showRecentActivityList = !_showRecentActivityList;
    }
    if (shouldUpdate) {
      update();
    }
  }

  Future<void> getDashboardData({bool reload = false}) async {
    if (reload) {
      dashboardTopCards = null;
    }

    Response response = await dashBoardRepo.getDashBoardData();

    if (response.statusCode == 200) {
      dashboardTopCards = DashboardTopCards.fromJson(
        response.body['content'][0]['top_cards'],
      );

      dashboardRecentActivityList = [];
      List<dynamic> resentList = response.body['content'][3]['recent_bookings'];
      for (var element in resentList) {
        dashboardRecentActivityList.add(
          DashboardRecentActivityModel.fromJson(element),
        );
      }

      dashboardSubscriptionList = [];
      List<dynamic> subscriptionList =
          response.body['content'][4]['subscriptions'];
      for (var element in subscriptionList) {
        dashboardSubscriptionList.add(SubscriptionModelData.fromJson(element));
      }

      dashboardServicemanList = [];
      List<dynamic> servicemanList =
          response.body['content'][5]['serviceman_list'];
      for (var element in servicemanList) {
        {
          if (element['user']['is_active'] == 1) {
            dashboardServicemanList.add(
              DashboardServicemanModel.fromJson(element),
            );
          }
        }
      }
      dashboardCustomizedPostList = [];
      List<dynamic> customizedPost =
          response.body['content'][6]['customized_post'];
      for (var element in customizedPost) {
        dashboardCustomizedPostList.add(PostData.fromJson(element));
      }

      additionalInfoCount = AdditionalInfoCount.fromJson(
        response.body['content'][7]['additional_info_count'],
      );

      if (dashboardRecentActivityList.isEmpty &&
          dashboardCustomizedPostList.isNotEmpty) {
        tabController?.index = 1;
        _showNormalBooking = false;
      }
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  void removeSubscriptionItem(String id, {bool shouldUpdate = true}) {
    dashboardSubscriptionList.removeWhere(
      (element) => element.subCategoryId == id,
    );
    if (shouldUpdate) {
      update();
    }
  }

  //Monthly Stats
  List<MonthlyStats> _monthlyStatsList = [];
  List<MonthlyStats> get monthlyStatsList => _monthlyStatsList;

  List<double> _mStatsList = [];
  List<double> get mStatsList => _mStatsList;

  List<FlSpot> _monthlyChartList = [];
  List<FlSpot> get monthlyChartList => _monthlyChartList;

  double _mmM = 0;
  double get mmM => _mmM;

  String _selectedYear = DateConverter.stringYear(DateTime.now());
  String get selectedYear => _selectedYear;
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String get selectedMonth => _selectedMonth;

  Future<void> getMonthlyBookingsDataForChart(String year, String month) async {
    _monthlyStatsList = [];
    _mStatsList = [];
    _monthlyChartList = [];
    _mmM = 0;
    _isLeapYear = false;

    Response response = await dashBoardRepo.getMonthlyDashBoardChartData(
      year,
      month,
    );

    if (response.statusCode == 200) {
      final List<dynamic> earningStats =
          response.body['content'][0]['earning_stats'];

      for (var element in earningStats) {
        _monthlyStatsList.add(MonthlyStats.fromJson(element));
      }

      int totalSlots;

      if (month == '2') {
        bool isLeapYear(int inputYear) =>
            (inputYear % 4 == 0) &&
            ((inputYear % 100 != 0) || (inputYear % 400 == 0));

        final parsedYear = int.tryParse(year) ?? DateTime.now().year;
        _isLeapYear = isLeapYear(parsedYear);

        // index 0 reserved + actual day positions
        totalSlots = _isLeapYear ? 30 : 29;
      } else if (month == '4' ||
          month == '6' ||
          month == '9' ||
          month == '11') {
        totalSlots = 31;
      } else {
        totalSlots = 32;
      }

      _mStatsList = List<double>.filled(totalSlots, 0);

      for (final stat in _monthlyStatsList) {
        final day = stat.day ?? 0;
        final amount = double.tryParse(stat.sums ?? '0') ?? 0;

        if (day >= 0 && day < _mStatsList.length) {
          _mStatsList[day] = amount;
        }
      }

      _monthlyChartList = _mStatsList.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value);
      }).toList();

      final sortedStats = List<double>.from(_mStatsList)..sort();
      _mmM = sortedStats.isNotEmpty ? sortedStats.last : 0;
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future<void> getYearlyBookingsDataForChart(String year) async {
    _yearlyStatsList = [];
    _yStatsList = [];
    _yearlyChartList = [];
    _mmY = 0;

    Response response = await dashBoardRepo.getYearlyDashBoardChartData(year);

    if (response.statusCode == 200) {
      final List<dynamic> yearlyDynamicList =
          response.body['content'][0]['earning_stats'];

      for (var element in yearlyDynamicList) {
        _yearlyStatsList.add(YearlyStats.fromJson(element));
      }

      // index 0 reserved, months 1..12
      _yStatsList = List<double>.filled(13, 0);

      for (final stat in _yearlyStatsList) {
        final monthIndex = monthMap[stat.month];
        final amount = double.tryParse(stat.sums ?? '0') ?? 0;

        if (monthIndex != null &&
            monthIndex >= 0 &&
            monthIndex < _yStatsList.length) {
          _yStatsList[monthIndex] = amount;
        }
      }

      _yearlyChartList = _yStatsList.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value);
      }).toList();

      final sortedStats = List<double>.from(_yStatsList)..sort();
      _mmY = sortedStats.isNotEmpty ? sortedStats.last : 0;
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  //yearly Stats
  List<YearlyStats> _yearlyStatsList = [];
  List<YearlyStats> get yearlyStatsList => _yearlyStatsList;

  List<double> _yStatsList = [];
  List<double> get yStatsList => _yStatsList;

  List<FlSpot> _yearlyChartList = [];
  List<FlSpot> get yearlyChartList => _yearlyChartList;

  double _mmY = 0;
  double get mmY => _mmY;

  void changeDashboardDropdownValue(
    String indexValue,
    String value,
    String type,
  ) {
    if (type == "Year") {
      _selectedYear = indexValue;
      if (_selectedYear != "Select") {
        if (_showMonthlyEarnStatisticsChart == EarningType.yearly) {
          getYearlyBookingsDataForChart(_selectedYear);
        } else {
          final monthIndex = DateFormat('MMMM').parse(_selectedMonth).month;
          getMonthlyBookingsDataForChart(_selectedYear, monthIndex.toString());
        }
      }
    } else if (type == "Month") {
      _selectedMonth = value;
      if (_selectedYear != "Select") {
        getMonthlyBookingsDataForChart(_selectedYear, indexValue);
      }
    }
    update();
  }

  void updateIndex(int index, {bool isUpdate = true}) {
    _paymentMethodIndex = index;
    if (isUpdate) {
      update();
    }
  }

  void removeServiceman(String id, {bool isUpdate = true}) {
    dashboardServicemanList.removeWhere((element) => element.id == id);
    if (isUpdate) {
      update();
    }
  }
}

*/

import 'package:afriendorse/athlete/feature/custom_post/model/post_model.dart';
import 'package:afriendorse/athlete/feature/dashboard/model/additional_info_count.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

enum EarningType { monthly, yearly }

class DashboardController extends GetxController
    with GetSingleTickerProviderStateMixin
    implements GetxService {
  final DashBoardRepo dashBoardRepo;

  DashboardController({required this.dashBoardRepo});

  @override
  void onInit() {
    super.onInit();
    // 2 active tabs:
    //   index 0 → Targeted requests  (brands who booked this athlete directly)
    //   index 1 → Open requests      (brands posting to all athletes)
    //
    // Standard/Normal booking tab is commented out below — restore when needed:
    // tabController = TabController(vsync: this, length: 3);
    tabController = TabController(vsync: this, length: 2);
  }

  bool _isLeapYear = false;
  get isLeapYear => _isLeapYear;

  TabController? tabController;

  DashboardTopCards? dashboardTopCards;
  AdditionalInfoCount? additionalInfoCount;

  List<DashboardServicemanModel> dashboardServicemanList = [];
  List<DashboardRecentActivityModel> dashboardRecentActivityList = [];
  List<SubscriptionModelData> dashboardSubscriptionList = [];

  // Split lists — replaces the old single dashboardCustomizedPostList
  List<PostData> dashboardTargetedPostList =
      []; // target_provider_id == this athlete
  List<PostData> dashboardOpenPostList = []; // target_provider_id is null

  // Kept for backwards compatibility with any widget still referencing the old name
  List<PostData> get dashboardCustomizedPostList => [
    ...dashboardTargetedPostList,
    ...dashboardOpenPostList,
  ];

  // Tracks which sub-tab (targeted vs open) is active inside the customized section
  int _activeTabIndex = 0;
  int get activeTabIndex => _activeTabIndex;

  void setActiveTab(int index) {
    _activeTabIndex = index;
    update();
  }

  bool _showNormalBooking = true;
  bool get showNormalBooking => _showNormalBooking;

  bool _showRecentActivityList = true;
  bool get showRecentActivityList => _showRecentActivityList;

  int _paymentMethodIndex = -1;

  EarningType _showMonthlyEarnStatisticsChart = EarningType.monthly;

  int get paymentMethodIndex => _paymentMethodIndex;

  EarningType get getChartType => _showMonthlyEarnStatisticsChart;

  void changeGraph(EarningType selectedType) {
    _showMonthlyEarnStatisticsChart = selectedType;
    _selectedYear = DateConverter.stringYear(DateTime.now());
    _selectedMonth = DateFormat('MMMM').format(DateTime.now());
    update();
  }

  void changeTypeOfShowBookingStatus({
    required bool status,
    bool shouldUpdate = true,
  }) {
    _showNormalBooking = status;
    if (status) {
      tabController?.index = 0;
    }
    if (shouldUpdate) {
      update();
    }
  }

  void changeRecentActivityView({bool? status, bool shouldUpdate = true}) {
    if (status != null) {
      _showRecentActivityList = status;
    } else {
      _showRecentActivityList = !_showRecentActivityList;
    }
    if (shouldUpdate) {
      update();
    }
  }

  Future<void> getDashboardData({bool reload = false}) async {
    if (reload) {
      dashboardTopCards = null;
    }

    Response response = await dashBoardRepo.getDashBoardData();

    if (response.statusCode == 200) {
      dashboardTopCards = DashboardTopCards.fromJson(
        response.body['content'][0]['top_cards'],
      );

      dashboardRecentActivityList = [];
      List<dynamic> resentList = response.body['content'][3]['recent_bookings'];
      for (var element in resentList) {
        dashboardRecentActivityList.add(
          DashboardRecentActivityModel.fromJson(element),
        );
      }

      dashboardSubscriptionList = [];
      List<dynamic> subscriptionList =
          response.body['content'][4]['subscriptions'];
      for (var element in subscriptionList) {
        dashboardSubscriptionList.add(SubscriptionModelData.fromJson(element));
      }

      dashboardServicemanList = [];
      List<dynamic> servicemanList =
          response.body['content'][5]['serviceman_list'];
      for (var element in servicemanList) {
        if (element['user']['is_active'] == 1) {
          dashboardServicemanList.add(
            DashboardServicemanModel.fromJson(element),
          );
        }
      }

      // ── Split customized posts into targeted vs open ──────────────────────
      dashboardTargetedPostList = [];
      dashboardOpenPostList = [];

      // The backend already filters — it only returns posts this provider
      // should see (open posts OR targeted at them). We split them here
      // purely for the two-tab UI.
      final currentProviderId =
          Get.find<UserProfileController>()
              .providerModel
              ?.content
              ?.providerInfo
              ?.id ??
          "";

      List<dynamic> customizedPost =
          response.body['content'][6]['customized_post'];

      for (var element in customizedPost) {
        final post = PostData.fromJson(element);
        final targetId = post.targetProviderId ?? '';

        if (targetId.isNotEmpty) {
          // Targeted post — backend guarantees it's ours, but double-check
          // in case currentProviderId is empty (profile not yet loaded)
          if (targetId == currentProviderId || currentProviderId.isEmpty) {
            dashboardTargetedPostList.add(post);
          }
        } else {
          // Open post — visible to all athletes
          dashboardOpenPostList.add(post);
        }
      }
      // ─────────────────────────────────────────────────────────────────────

      additionalInfoCount = AdditionalInfoCount.fromJson(
        response.body['content'][7]['additional_info_count'],
      );

      // Auto-switch to customized tabs if no normal bookings exist
      if (dashboardRecentActivityList.isEmpty &&
          (dashboardTargetedPostList.isNotEmpty ||
              dashboardOpenPostList.isNotEmpty)) {
        tabController?.index = 0; // go to targeted tab first
        _showNormalBooking = false;
      }
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  void removeSubscriptionItem(String id, {bool shouldUpdate = true}) {
    dashboardSubscriptionList.removeWhere(
      (element) => element.subCategoryId == id,
    );
    if (shouldUpdate) {
      update();
    }
  }

  // ── Monthly Stats ─────────────────────────────────────────────────────────
  List<MonthlyStats> _monthlyStatsList = [];
  List<MonthlyStats> get monthlyStatsList => _monthlyStatsList;

  List<double> _mStatsList = [];
  List<double> get mStatsList => _mStatsList;

  List<FlSpot> _monthlyChartList = [];
  List<FlSpot> get monthlyChartList => _monthlyChartList;

  double _mmM = 0;
  double get mmM => _mmM;

  String _selectedYear = DateConverter.stringYear(DateTime.now());
  String get selectedYear => _selectedYear;
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String get selectedMonth => _selectedMonth;

  Future<void> getMonthlyBookingsDataForChart(String year, String month) async {
    _monthlyStatsList = [];
    _mStatsList = [];
    _monthlyChartList = [];
    _mmM = 0;
    _isLeapYear = false;

    Response response = await dashBoardRepo.getMonthlyDashBoardChartData(
      year,
      month,
    );

    if (response.statusCode == 200) {
      final List<dynamic> earningStats =
          response.body['content'][0]['earning_stats'];

      for (var element in earningStats) {
        _monthlyStatsList.add(MonthlyStats.fromJson(element));
      }

      int totalSlots;

      if (month == '2') {
        bool isLeapYear(int inputYear) =>
            (inputYear % 4 == 0) &&
            ((inputYear % 100 != 0) || (inputYear % 400 == 0));

        final parsedYear = int.tryParse(year) ?? DateTime.now().year;
        _isLeapYear = isLeapYear(parsedYear);
        totalSlots = _isLeapYear ? 30 : 29;
      } else if (month == '4' ||
          month == '6' ||
          month == '9' ||
          month == '11') {
        totalSlots = 31;
      } else {
        totalSlots = 32;
      }

      _mStatsList = List<double>.filled(totalSlots, 0);

      for (final stat in _monthlyStatsList) {
        final day = stat.day ?? 0;
        final amount = double.tryParse(stat.sums ?? '0') ?? 0;
        if (day >= 0 && day < _mStatsList.length) {
          _mStatsList[day] = amount;
        }
      }

      _monthlyChartList = _mStatsList.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value);
      }).toList();

      final sortedStats = List<double>.from(_mStatsList)..sort();
      _mmM = sortedStats.isNotEmpty ? sortedStats.last : 0;
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future<void> getYearlyBookingsDataForChart(String year) async {
    _yearlyStatsList = [];
    _yStatsList = [];
    _yearlyChartList = [];
    _mmY = 0;

    Response response = await dashBoardRepo.getYearlyDashBoardChartData(year);

    if (response.statusCode == 200) {
      final List<dynamic> yearlyDynamicList =
          response.body['content'][0]['earning_stats'];

      for (var element in yearlyDynamicList) {
        _yearlyStatsList.add(YearlyStats.fromJson(element));
      }

      _yStatsList = List<double>.filled(13, 0);

      for (final stat in _yearlyStatsList) {
        final monthIndex = monthMap[stat.month];
        final amount = double.tryParse(stat.sums ?? '0') ?? 0;
        if (monthIndex != null &&
            monthIndex >= 0 &&
            monthIndex < _yStatsList.length) {
          _yStatsList[monthIndex] = amount;
        }
      }

      _yearlyChartList = _yStatsList.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value);
      }).toList();

      final sortedStats = List<double>.from(_yStatsList)..sort();
      _mmY = sortedStats.isNotEmpty ? sortedStats.last : 0;
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  // ── Yearly Stats ──────────────────────────────────────────────────────────
  List<YearlyStats> _yearlyStatsList = [];
  List<YearlyStats> get yearlyStatsList => _yearlyStatsList;

  List<double> _yStatsList = [];
  List<double> get yStatsList => _yStatsList;

  List<FlSpot> _yearlyChartList = [];
  List<FlSpot> get yearlyChartList => _yearlyChartList;

  double _mmY = 0;
  double get mmY => _mmY;

  void changeDashboardDropdownValue(
    String indexValue,
    String value,
    String type,
  ) {
    if (type == "Year") {
      _selectedYear = indexValue;
      if (_selectedYear != "Select") {
        if (_showMonthlyEarnStatisticsChart == EarningType.yearly) {
          getYearlyBookingsDataForChart(_selectedYear);
        } else {
          final monthIndex = DateFormat('MMMM').parse(_selectedMonth).month;
          getMonthlyBookingsDataForChart(_selectedYear, monthIndex.toString());
        }
      }
    } else if (type == "Month") {
      _selectedMonth = value;
      if (_selectedYear != "Select") {
        getMonthlyBookingsDataForChart(_selectedYear, indexValue);
      }
    }
    update();
  }

  void updateIndex(int index, {bool isUpdate = true}) {
    _paymentMethodIndex = index;
    if (isUpdate) {
      update();
    }
  }

  void removeServiceman(String id, {bool isUpdate = true}) {
    dashboardServicemanList.removeWhere((element) => element.id == id);
    if (isUpdate) {
      update();
    }
  }
}
