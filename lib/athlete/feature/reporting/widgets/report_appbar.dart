import 'package:afriendorse/athlete/feature/reporting/view/report_search_filter.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ReportAppBarView extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? centerTitle;
  final Function()? onPressed;
  final String fromPage;
  final bool isFiltered;
  const ReportAppBarView({
    super.key,
    this.title,
    this.centerTitle = false,
    this.onPressed,
    required this.fromPage,
    this.isFiltered = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 5,
      titleSpacing: 0,
      surfaceTintColor: Theme.of(context).cardColor,
      backgroundColor: Theme.of(context).cardColor,
      shadowColor: Get.isDarkMode
          ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
          : Theme.of(context).primaryColor.withValues(alpha: 0.1),
      centerTitle: centerTitle,
      title: Text(
        title!,
        style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          color: Theme.of(context).primaryColorLight,
        ),
      ),
      leading: IconButton(
        onPressed:
            onPressed ??
            () {
              Get.back();
            },
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).primaryColorLight,
          size: 20,
        ),
      ),
      actions: [
        InkWell(
          onTap: () {
            Get.to(() => ReportSearchFilter(fromPage: fromPage));
          },
          child: Container(
            padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 10,
                  color: Get.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topRight,
              children: [
                Image.asset(Images.reportFilterIcon, height: 25, width: 25),
                isFiltered
                    ? Positioned(
                        top: -5,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                          color: Theme.of(context).cardColor,
                          child: const Icon(
                            Icons.circle,
                            size: 10,
                            color: Colors.red,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
      ],
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 55);
}
