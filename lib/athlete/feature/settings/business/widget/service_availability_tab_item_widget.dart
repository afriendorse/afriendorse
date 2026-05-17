import 'package:afriendorse/athlete/feature/settings/notification/view/notification_settings_screen.dart';
import 'package:afriendorse/athlete/feature/tutorial/controller/tutorial_controller.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ServiceAvailabilityTabItemWidget extends StatefulWidget {
  const ServiceAvailabilityTabItemWidget({super.key});

  @override
  State<ServiceAvailabilityTabItemWidget> createState() =>
      _ServiceAvailabilityTabItemWidgetState();
}

class _ServiceAvailabilityTabItemWidgetState
    extends State<ServiceAvailabilityTabItemWidget> {
  // ── tooltip controller lives with the State, not rebuilt on every frame ──
  final JustTheController _tooltipController = JustTheController();

  static const kGreen = Color(0xFF045F25);

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessSettingController>(
      builder: (ctrl) {
        final isAvailable = ctrl.serviceAvailabilitySettings;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeSmall,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Master toggle card ─────────────────────────
                    _AvailabilityToggleCard(
                      isAvailable: isAvailable,
                      onToggle: (_) => ctrl.toggleServiceAvailabilitySettings(),
                    ),

                    const SizedBox(height: 16),

                    // ── 2. Schedule card (dims when unavailable) ──────
                    AnimatedOpacity(
                      opacity: isAvailable ? 1.0 : 0.42,
                      duration: const Duration(milliseconds: 280),
                      child: IgnorePointer(
                        ignoring: !isAvailable,
                        child: _ScheduleCard(
                          ctrl: ctrl,
                          tooltipController: _tooltipController,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Sticky save bar ───────────────────────────────────────
            _SaveBar(ctrl: ctrl),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Availability toggle card
// ─────────────────────────────────────────────────────────────────────────────

class _AvailabilityToggleCard extends StatelessWidget {
  final bool isAvailable;
  final void Function(bool) onToggle;

  const _AvailabilityToggleCard({
    required this.isAvailable,
    required this.onToggle,
  });

  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAvailable
              ? kGreen.withOpacity(0.40)
              : Colors.grey.withOpacity(0.25),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAvailable ? kGreen : Colors.black).withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── header row ──────────────────────────────────────────
            Row(
              children: [
                // Status icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isAvailable ? kGreen : Colors.grey).withOpacity(
                      0.12,
                    ),
                  ),
                  child: Icon(
                    isAvailable
                        ? Icons.check_circle_rounded
                        : Icons.pause_circle_rounded,
                    color: isAvailable ? kGreen : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'service_availability'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          isAvailable
                              ? 'You are currently accepting deals'
                              : 'You are not accepting deals',
                          key: ValueKey(isAvailable),
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: isAvailable
                                ? kGreen.withOpacity(0.80)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Toggle
                FlutterSwitch(
                  width: 46,
                  height: 26,
                  valueFontSize: Dimensions.fontSizeExtraSmall,
                  showOnOff: false,
                  activeColor: kGreen,
                  value: isAvailable,
                  padding: 2,
                  toggleSize: 22,
                  onToggle: onToggle,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── hint text ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isAvailable ? kGreen : Colors.grey).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: isAvailable ? kGreen : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'service_availability_hint'.tr,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: Dimensions.fontSizeSmall,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Schedule card
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduleCard extends StatelessWidget {
  final BusinessSettingController ctrl;
  final JustTheController tooltipController;

  const _ScheduleCard({required this.ctrl, required this.tooltipController});

  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── card header ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: kGreen,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'availability_schedule'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Set your working hours and days',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.black.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tooltip
                JustTheTooltip(
                  backgroundColor: Colors.black87,
                  controller: tooltipController,
                  preferredDirection: AxisDirection.down,
                  tailLength: 14,
                  tailBaseWidth: 20,
                  content: Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    child: Text(
                      'service_availability_hint_text'.tr,
                      style: robotoRegular.copyWith(color: Colors.white),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => tooltipController.showTooltip(),
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.black.withOpacity(0.07)),

          // ── Working hours ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _SectionLabel(
              icon: Icons.access_time_rounded,
              label: 'service_providing_time'.tr,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _TimeRangeRow(ctrl: ctrl),
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.black.withOpacity(0.07)),

          // ── Days off / weekend ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _SectionLabel(
              icon: Icons.event_busy_rounded,
              label: 'weekend'.tr,
            ),
          ),

          _DaysGrid(ctrl: ctrl),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label helper
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF045F25)),
        const SizedBox(width: 6),
        Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(
              context,
            ).textTheme.bodyLarge?.color?.withOpacity(0.80),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Time range row  — stacks vertically on very small screens
// ─────────────────────────────────────────────────────────────────────────────

class _TimeRangeRow extends StatelessWidget {
  final BusinessSettingController ctrl;
  const _TimeRangeRow({required this.ctrl});

  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          // ── From ────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'from'.tr.toUpperCase(),
                  style: robotoRegular.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.42),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TimePickerWidget(
                  title: 'open_time'.tr,
                  time: ctrl.serviceStartTime,
                  onTimeChanged: (t) => ctrl.setServiceStartTime = t,
                ),
              ],
            ),
          ),

          // Arrow separator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                const SizedBox(height: 18), // align with picker
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: kGreen,
                  ),
                ),
              ],
            ),
          ),

          // ── Till ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'till'.tr.toUpperCase(),
                  style: robotoRegular.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.42),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TimePickerWidget(
                  title: 'close_time'.tr,
                  time: ctrl.serviceEndTime,
                  onTimeChanged: (t) => ctrl.setServiceEndTime = t,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Days grid  — chip-based, wraps responsively
// ─────────────────────────────────────────────────────────────────────────────

class _DaysGrid extends StatelessWidget {
  final BusinessSettingController ctrl;
  const _DaysGrid({required this.ctrl});

  static const kGreen = Color(0xFF045F25);

  // Short 3-letter abbreviations
  static const List<String> _abbrevs = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(ctrl.daysList.length, (i) {
          final selected = ctrl.daysCheckList[i];
          // Use short name if available, else fall back to full name
          final label = i < _abbrevs.length ? _abbrevs[i] : ctrl.daysList[i];

          return GestureDetector(
            onTap: () => ctrl.toggleDaysCheckedValue(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? kGreen : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? kGreen : Colors.black.withOpacity(0.10),
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: kGreen.withOpacity(0.22),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                label,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: selected
                      ? Colors.white
                      : Colors.black.withOpacity(0.60),
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky save bar
// ─────────────────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final BusinessSettingController ctrl;
  const _SaveBar({required this.ctrl});

  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        12,
        Dimensions.paddingSizeDefault,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.07))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF045F25), Color(0xFF0A7A33)],
            ),
            boxShadow: [
              BoxShadow(
                color: kGreen.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: ctrl.isLoading
                ? null
                : () {
                    final tutorialData = Get.find<UserProfileController>()
                        .providerModel
                        ?.content
                        ?.providerInfo
                        ?.tutorialData;

                    if (tutorialData?[AppConstants
                                .serviceAvailabilityTutorialKey]
                            ?.contains('0') ??
                        true) {
                      Get.find<TutorialController>().updateTutorial(
                        key: AppConstants.serviceAvailabilityTutorialKey,
                      );
                    }

                    ctrl.updateServiceAvailabilitySettingsIntoServer();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: ctrl.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.save_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'save_information'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
