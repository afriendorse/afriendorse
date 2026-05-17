import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class CustomDropDownButton extends StatelessWidget {
  final List<String> itemList;
  final String type;
  final String title;

  const CustomDropDownButton({
    super.key,
    required this.itemList,
    required this.type,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        final currentValue = widgetValue(dashboardController, type, itemList);

        return _PremiumDropDown(
          label: title,
          value: currentValue,
          items: itemList,
          onChanged: (String? value) {
            if (value == null) return;

            if (type == "Month") {
              final index = itemList.indexOf(value) + 1;
              dashboardController.changeDashboardDropdownValue(
                index.toString(),
                value,
                type,
              );
            } else if (type == "Year") {
              dashboardController.changeDashboardDropdownValue(
                value,
                value,
                type,
              );
            }
          },
        );
      },
    );
  }

  String? widgetValue(
    DashboardController dashboardController,
    String type,
    List<String> itemList,
  ) {
    if (type == "Year") {
      return itemList.contains(dashboardController.selectedYear)
          ? dashboardController.selectedYear
          : null;
    } else {
      return itemList.contains(dashboardController.selectedMonth)
          ? dashboardController.selectedMonth
          : null;
    }
  }
}

class _PremiumDropDown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _PremiumDropDown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AthleteDashboardColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AthleteDashboardColors.textSecondary,
          ),
          borderRadius: BorderRadius.circular(16),
          style: robotoMedium.copyWith(
            fontSize: 13,
            color: AthleteDashboardColors.textPrimary,
          ),
          hint: Text(
            label.tr,
            style: robotoRegular.copyWith(
              fontSize: 12,
              color: AthleteDashboardColors.textSecondary,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item.tr,
                overflow: TextOverflow.ellipsis,
                style: robotoMedium.copyWith(
                  color: AthleteDashboardColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
