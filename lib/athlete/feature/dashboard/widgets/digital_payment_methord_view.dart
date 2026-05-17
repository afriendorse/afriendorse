import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class DigitalPaymentMethodView extends StatelessWidget {
  final List<DigitalPaymentMethod> paymentList;
  final JustTheController tooltipController;
  final String fromPage;
  const DigitalPaymentMethodView({
    super.key,
    required this.paymentList,
    required this.tooltipController,
    required this.fromPage,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        return SingleChildScrollView(
          child: ListView.builder(
            itemCount: paymentList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  dashboardController.updateIndex(index);
                },
                child: DigitalPaymentButtonWidget(
                  isSelected: dashboardController.paymentMethodIndex == index,
                  paymentMethod: paymentList[index],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
