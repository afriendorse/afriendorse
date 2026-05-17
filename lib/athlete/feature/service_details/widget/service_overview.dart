import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class ServiceOverview extends StatelessWidget {
  final ServiceDetailsController serviceDetailsController;
  const ServiceOverview({super.key, required this.serviceDetailsController});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Center(
          child: HtmlWidget(
            serviceDetailsController.serviceDetailsModel!.content!.description!,
            textStyle: robotoMedium.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
