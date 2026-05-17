import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/service_details/model/service_faq_model.dart';
import 'package:afriendorse/athlete/feature/service_details/widget/empty_faq_widget.dart';
import 'package:get/get.dart';

class FaqScreen extends StatelessWidget {
  final List<ServiceFAQData>? faqList;
  const FaqScreen({super.key, required this.faqList});
  @override
  Widget build(BuildContext context) {
    return faqList != null && faqList!.isNotEmpty
        ? SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: faqList!.length,
                itemBuilder: (context, index) {
                  return CustomExpansionTile(
                    collapsedTextColor: dark.colorScheme.surface,
                    title: Text(
                      faqList![index].question ?? "",
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Get.isDarkMode
                            ? Theme.of(context).primaryColorLight
                            : Colors.black,
                      ),
                    ),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 5,
                            ),
                            child: Text(
                              faqList![index].answer ?? "",
                              textAlign: TextAlign.start,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        : const EmptyFAQWidget();
  }
}
