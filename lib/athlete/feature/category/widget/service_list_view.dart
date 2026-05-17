import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ServiceListView extends StatelessWidget {
  final List<ServiceModel> serviceList;
  const ServiceListView({super.key, required this.serviceList});

  @override
  Widget build(BuildContext context) {
    return serviceList.isNotEmpty
        ? Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              itemCount: serviceList.length,
              itemBuilder: (context, index) =>
                  ServiceItem(service: serviceList[index]),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 0,
                mainAxisSpacing: 5,
                mainAxisExtent: 245,
                crossAxisCount: ResponsiveHelper.isTab(context) ? 4 : 2,
              ),
              physics: const BouncingScrollPhysics(),
            ),
          )
        : Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: Get.height * .1),
              child: NoDataScreen(
                text: 'no_service_available'.tr,
                type: NoDataType.service,
              ),
            ),
          );
  }
}
