import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class BusinessTransactionSearchWidget extends StatelessWidget {
  const BusinessTransactionSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessSubscriptionController>(
      builder: (businessSubscriptionController) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          businessSubscriptionController.searchController,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        fontSize: Dimensions.fontSizeDefault,
                      ),

                      cursorColor: Theme.of(context).hintColor,
                      autofocus: false,
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.search,
                      onChanged: (text) => businessSubscriptionController
                          .showSuffixIcon(context, text),
                      onSubmitted: (text) {
                        if (text.isNotEmpty) {
                          businessSubscriptionController.clearSearchController(
                            clearTextController: false,
                          );
                          businessSubscriptionController
                              .getSearchedSubscriptionTransactionList(
                                queryText: text,
                                startDate: "",
                                endDate: "",
                              );
                        }
                        FocusScope.of(context).unfocus();
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 22,
                        ),
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(10),
                            left: Radius.circular(10),
                          ),
                          borderSide: BorderSide(
                            width: 0.5,
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.0),
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(10),
                            left: Radius.circular(10),
                          ),
                          borderSide: BorderSide(
                            width: 0.5,
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.0),
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(10),
                            left: Radius.circular(10),
                          ),
                          borderSide: BorderSide(
                            width: 0.5,
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(10),
                            left: Radius.circular(10),
                          ),
                          borderSide: BorderSide(
                            width: 0.5,
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.0),
                          ),
                        ),

                        isDense: true,
                        hintText: 'search'.tr,
                        hintStyle: Theme.of(context).textTheme.bodySmall!
                            .copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).hintColor,
                            ),
                        filled: true,
                        suffixIcon:
                            businessSubscriptionController.isActiveSuffixIcon
                            ? IconButton(
                                color: Get.isDarkMode
                                    ? light.cardColor.withValues(alpha: 0.8)
                                    : Theme.of(context).colorScheme.primary,
                                onPressed: () {
                                  if (businessSubscriptionController
                                      .searchController
                                      .text
                                      .trim()
                                      .isNotEmpty) {
                                    businessSubscriptionController
                                        .clearSearchController();
                                  }
                                  FocusScope.of(context).unfocus();
                                },
                                icon: Icon(
                                  Icons.cancel_outlined,
                                  size: 18,
                                  color: Theme.of(context).hintColor,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                ),
                                child: Icon(
                                  Icons.search_outlined,
                                  color: Theme.of(context).hintColor,
                                  size: 22,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  InkWell(
                    onTap: () async {
                      DateTimeRange? dateTimeRange = await showDateRangePicker(
                        //locale: Get.find<LocalizationController>().locale,
                        initialEntryMode: DatePickerEntryMode.calendar,
                        context: context,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(3000),
                        currentDate: DateTime.now(),
                      );
                      if (dateTimeRange != null) {
                        businessSubscriptionController.dateTimeRange =
                            dateTimeRange;
                        businessSubscriptionController.clearSearchController(
                          shouldUpdate: false,
                          clearDate: false,
                        );
                        businessSubscriptionController
                            .getSearchedSubscriptionTransactionList(
                              queryText: "",
                              startDate: DateConverter.dateTimeStringToDate(
                                dateTimeRange.start.toString(),
                              ),
                              endDate: DateConverter.dateTimeStringToDate(
                                dateTimeRange.end.toString(),
                              ),
                            );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                        color: Theme.of(context).cardColor,
                      ),
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault - 2,
                      ),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.7),
                        size: 23,
                      ),
                    ),
                  ),
                ],
              ),

              businessSubscriptionController.dateTimeRange != null
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusExtraLarge,
                        ),
                        border: Border.all(color: Theme.of(context).hintColor),
                      ),
                      margin: const EdgeInsets.only(
                        top: Dimensions.paddingSizeDefault,
                      ),

                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeExtraSmall,
                      ),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${DateConverter.dateStringMonthYear(businessSubscriptionController.dateTimeRange!.start)} - ${DateConverter.dateStringMonthYear(businessSubscriptionController.dateTimeRange!.end)},",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),
                          InkWell(
                            onTap: () => businessSubscriptionController
                                .clearSearchController(),
                            child: Icon(
                              Icons.close,
                              color: Theme.of(context).hintColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }
}
