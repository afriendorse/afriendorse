import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class TimePickerWidget extends StatefulWidget {
  final String title;
  final String? time;
  final Function(String?) onTimeChanged;
  const TimePickerWidget({
    super.key,
    required this.title,
    required this.time,
    required this.onTimeChanged,
  });

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  String? _myTime;

  @override
  void initState() {
    super.initState();
    _myTime = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        Get.find<UserProfileController>().trialWidgetShow(route: "show-dialog");
        TimeOfDay? time = await showCustomTimePicker();
        Get.find<UserProfileController>().trialWidgetShow(route: "");
        if (time != null) {
          setState(() {
            _myTime = DateConverter.convert24HourTimeTo12HourTime(
              DateTime(DateTime.now().year, 1, 1, time.hour, time.minute),
            );
          });
          widget.onTimeChanged(_myTime);
        }
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(
            color: Theme.of(
              context,
            ).textTheme.bodySmall!.color!.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Text(
              _myTime != null ? _myTime! : 'pick_time'.tr,
              style: robotoRegular,
              maxLines: 1,
            ),

            const SizedBox(width: Dimensions.paddingSizeSmall),

            const Icon(Icons.access_time, size: 20),
          ],
        ),
      ),
    );
  }
}
