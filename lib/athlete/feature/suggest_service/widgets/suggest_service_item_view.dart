import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/suggest_service/model/suggest_service_model.dart';
import 'package:afriendorse/athlete/feature/suggest_service/widgets/admin_feedback.dart';
import 'package:get/get.dart';

class SuggestServiceItemView extends StatelessWidget {
  final SuggestedService suggestedService;
  final int index;

  const SuggestServiceItemView({
    super.key,
    required this.suggestedService,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (suggestedService.category != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: CustomImage(
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                      image: suggestedService.category?.imageFullPath ?? "",
                    ),
                  ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Text(
                      suggestedService.category?.name ?? "",
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                Tooltip(
                  message:
                      suggestedService.adminFeedback ??
                      suggestedService.status.toString().tr,
                  child: InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (ctx) => AdminFeedbackDialog(index: index),
                    ),
                    child: Image.asset(
                      Images.approvedStatusIcon,
                      width: 25,
                      color: suggestedService.status == "pending"
                          ? Theme.of(context).primaryColor
                          : suggestedService.status == "denied"
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                Dimensions.paddingSizeDefault,
                0,
                Dimensions.paddingSizeExtraSmall,
              ),
              child: Text(
                "suggested_service".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(
                    context,
                  ).secondaryHeaderColor.withValues(alpha: 0.8),
                ),
              ),
            ),
            Text(
              suggestedService.serviceName ?? "",
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                Dimensions.paddingSizeDefault,
                0,
                Dimensions.paddingSizeExtraSmall,
              ),
              child: Text(
                "description".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(
                    context,
                  ).secondaryHeaderColor.withValues(alpha: 0.8),
                ),
              ),
            ),

            Text(
              suggestedService.serviceDescription ?? "",
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.justify,
              maxLines: 100,
            ),
          ],
        ),
      ),
    );
  }
}
