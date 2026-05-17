import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/serviceman/widget/add_new_serviceman_acount_info.dart';

class AddNewServicemanScreen extends StatefulWidget {
  final bool? isEditScreen;
  const AddNewServicemanScreen({super.key, this.isEditScreen = false});
  @override
  State<AddNewServicemanScreen> createState() => _AddNewServicemanScreenState();
}

class _AddNewServicemanScreenState extends State<AddNewServicemanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: widget.isEditScreen!
            ? "edit_service_man".tr
            : "add_new_service_man".tr,
      ),
      body: GetBuilder<ServicemanSetupController>(
        builder: (serviceManSetupController) {
          return Column(
            children: [
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Container(
                height: 45,
                width: Get.width,
                margin: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.7),
                      width: 1,
                    ),
                  ),
                ),
                child: TabBar(
                  unselectedLabelColor: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                  indicatorColor: Theme.of(context).primaryColor,
                  controller: serviceManSetupController.controller,
                  labelColor: Theme.of(context).primaryColorLight,
                  labelStyle: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                  labelPadding: EdgeInsets.zero,
                  tabs: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Tab(text: 'general_info'.tr),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Tab(text: 'account_info'.tr),
                    ),
                  ],
                  onTap: (int index) {
                    switch (index) {
                      case 0:
                        serviceManSetupController.updateTabControllerValue(
                          ServicemanTabControllerState.generalInfo,
                        );
                        break;
                      case 1:
                        serviceManSetupController.updateTabControllerValue(
                          ServicemanTabControllerState.accountIno,
                        );
                        break;
                    }
                  },
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: serviceManSetupController.controller,
                  children: [
                    ServiceManGeneralInfo(
                      isFromEditScreen: widget.isEditScreen!,
                    ),
                    ServicemanAccountInfo(
                      isFromEditScreen: widget.isEditScreen!,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
