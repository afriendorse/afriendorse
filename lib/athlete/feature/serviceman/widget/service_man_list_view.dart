import 'package:afriendorse/athlete/feature/serviceman/view/serviceman_details.dart';
import 'package:afriendorse/athlete/feature/serviceman/widget/serviceman_card_view.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ServiceManListview extends StatelessWidget {
  const ServiceManListview({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicemanSetupController>(
      builder: (servicemanController) {
        return servicemanController.servicemanList != null &&
                servicemanController.servicemanList!.isEmpty
            ? const SizedBox()
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.isDesktop(context)
                      ? 6
                      : ResponsiveHelper.isTab(context)
                      ? 4
                      : 2,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      servicemanController.updateIndex(-1);
                      Get.to(
                        () => ServicemanDetails(
                          id: servicemanController
                              .servicemanList![index]
                              .serviceman!
                              .id!,
                          fromDashboard: false,
                        ),
                      );
                    },
                    child: ServicemanCardView(
                      serviceman: servicemanController.servicemanList?[index],
                      index: index,
                    ),
                  );
                },
                itemCount: servicemanController.servicemanList?.length,
              );
      },
    );
  }
}
