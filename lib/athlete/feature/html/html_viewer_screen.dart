import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HtmlViewerScreen extends StatefulWidget {
  final HtmlType? type;
  final String? pageKey;
  const HtmlViewerScreen({super.key, this.type, this.pageKey});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  @override
  Widget build(BuildContext context) {
    final double weight = MediaQuery.of(context).size.width;
    String? data;
    String? image;
    return GetBuilder<HtmlViewController>(
      initState: (state) {
        Get.find<HtmlViewController>().getPagesContent(
          widget.pageKey ?? widget.type?.value ?? '',
        );
      },
      builder: (htmlViewController) {
        data = htmlViewController.pageDetailsModel?.content?.replaceAll(
          'href=',
          'target="_blank" href=',
        );

        image = htmlViewController.pageDetailsModel?.image;

        return Skeletonizer(
          enabled: htmlViewController.pageDetailsModel == null,
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: CustomAppBar(
              title: htmlViewController.pageDetailsModel?.title ?? '',
            ),
            body: Center(
              child: Container(
                width: Dimensions.webMaxWidth,
                height: MediaQuery.of(context).size.height,
                color: GetPlatform.isWeb
                    ? Colors.white
                    : Theme.of(
                        context,
                      ).cardColor.withValues(alpha: Get.isDarkMode ? 0.5 : 1),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: Dimensions.paddingSizeSmall),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                        child: CustomImage(
                          height: weight / 7,
                          width: weight,
                          fit: BoxFit.cover,
                          image: image ?? "",
                          placeholder: Images.businessPagePlaceholder,
                        ),
                      ),

                      (data?.isNotEmpty ??
                              false ||
                                  htmlViewController.pageDetailsModel == null)
                          ? Container(
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeDefault,
                              ),
                              margin: EdgeInsets.only(
                                top: Dimensions.paddingSizeDefault,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(1, 1),
                                    blurRadius: 5,
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.12),
                                  ),
                                ],
                              ),
                              child: HtmlWidget(
                                data ?? '',
                                textStyle: robotoRegular.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            )
                          : NoDataScreen(text: 'no_data_found'.tr),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
