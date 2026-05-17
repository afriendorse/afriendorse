import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DateConverter {
  static String stringYear(DateTime? dateTime) {
    return DateFormat('y').format(dateTime!);
  }

  static String dateTimeStringToDateTime(String dateTime) {
    return DateFormat(
      'dd MMM yyyy  ${_timeFormatter()}',
    ).format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static String convertStringDateTo24HourFormat(String dateTime) {
    return DateFormat('HH:mm').format(DateFormat('hh:mm a').parse(dateTime));
  }

  static String dateToDateAndTime(DateTime? dateTime) {
    return DateFormat('yyyy-MM-dd ${_timeFormatter()}').format(dateTime!);
  }

  static String dateTimeStringToDateOnly(String dateTime) {
    return DateFormat(
      _timeFormatter(),
    ).format(DateFormat('hh:mm').parse(dateTime));
  }

  static String dateTimeStringToDate(String dateTime) {
    return DateFormat('yyyy-MM-dd').format(DateTime.parse(dateTime).toLocal());
  }

  // FIXED: Removed comma, consistent spacing
  static String stringToLocalDateOnly(String dateTime) {
    return _localDateFormatter(
      'dd MMM yyyy',
    ).format(DateTime.parse(dateTime).toLocal());
  }

  static String timeToTimeString(TimeOfDay time) {
    DateTime dateTime = DateTime(2000, 01, 01, time.hour, time.minute);
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  static DateTime dateTimeString(String dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime);
  }

  static DateTime isoStringToLocalDate(String dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(dateTime);
  }

  static DateTime isoUtcStringToLocalDate(String dateTime) {
    return DateFormat(
      'yyyy-MM-ddTHH:mm:ss.SSS',
    ).parse(dateTime, true).toLocal();
  }

  static DateTime isoUtcStringToLocalDateOnly(String dateTime) {
    return DateFormat('yyyy-MM-dd').parse(dateTime, true).toLocal();
  }

  static DateTime isoUtcStringToLocalTimeOnly(String dateTime) {
    return DateFormat(
      'yyyy-MM-ddTHH:mm:ss.SSS',
    ).parse(dateTime, true).toLocal();
  }

  static String isoStringToLocalDateAndTime(String dateTime) {
    return DateFormat(
      'dd MMM yyyy \'at\' ${_timeFormatter()}',
    ).format(isoUtcStringToLocalDate(dateTime));
  }

  // FIXED: Removed comma
  static String isoStringToLocalDateOnly(String dateTime) {
    return _localDateFormatter(
      'dd MMM yyyy',
    ).format(isoStringToLocalDate(dateTime));
  }

  static String localDateToIsoString(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dateTime);
  }

  static String convertStringTimeToDate(DateTime time) {
    return DateFormat('EEE \'at\' ${_timeFormatter()}').format(time.toLocal());
  }

  static String convertStringTimeOnly(DateTime time) {
    return DateFormat(_timeFormatter()).format(time);
  }

  // FIXED: Proper spacing - "1 Jan 2024 02:30 PM"
  static String dateMonthYearTime(DateTime? dateTime) {
    return _localDateFormatter('d MMM y ${_timeFormatter()}').format(dateTime!);
  }

  // FIXED: Default format without comma
  static String dateStringMonthYear(
    DateTime? dateTime, {
    String format = "d MMM y",
  }) {
    return _localDateFormatter(format).format(dateTime ?? DateTime.now());
  }

  static String convert24HourTimeTo12HourTimeWithDay(
    DateTime time,
    bool isToday,
  ) {
    if (isToday) {
      return DateFormat('\'Today at\' ${_timeFormatter()}').format(time);
    } else {
      return DateFormat('\'Yesterday at\' ${_timeFormatter()}').format(time);
    }
  }

  static String convert24HourTimeTo12HourTime(DateTime? time) {
    return DateFormat(_timeFormatter()).format(time ?? DateTime.now());
  }

  static String formatDate(DateTime date) => DateFormat.yMd().format(date);

  // You can keep this as-is or update if needed
  static String dateMonthYearLocalTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  static int countDays({DateTime? dateTime, DateTime? endDate}) {
    final start = DateTime(
      dateTime?.year ?? DateTime.now().year,
      dateTime?.month ?? DateTime.now().month,
      dateTime?.day ?? DateTime.now().day,
    );
    final end = DateTime(
      endDate?.year ?? DateTime.now().year,
      endDate?.month ?? DateTime.now().month,
      endDate?.day ?? DateTime.now().day,
    );
    final difference = end.difference(start).inDays + 1;
    return difference;
  }

  static String _timeFormatter() {
    return Get.find<SplashController>().configModel.content?.timeFormat == '24'
        ? 'HH:mm'
        : 'hh:mm a';
  }

  static DateFormat _localDateFormatter(String format) {
    return DateFormat(format);
    // Uncomment when LocalizationController is available:
    // return DateFormat(
    //   format,
    //   Get.find<LocalizationController>().locale.languageCode,
    // );
  }

  static String convertDateTimeRangeToString(
    DateTimeRange dateRange, {
    String format = 'dd / MM / yy',
  }) {
    final startDate = DateFormat(format).format(dateRange.start);
    final endDate = DateFormat(format).format(dateRange.end);
    if (startDate == endDate) {
      return startDate;
    }
    return '$startDate  -  $endDate';
  }

  static String convertDateTimeToTime(DateTime time) {
    return DateFormat(_timeFormatter()).format(time);
  }
}
