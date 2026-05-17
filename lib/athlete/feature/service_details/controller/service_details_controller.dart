import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/service_details/model/service_faq_model.dart';
import 'package:afriendorse/athlete/feature/service_details/model/variant_model.dart';

enum ServiceTabControllerState { serviceOverview, priceTable, faq, review }

class ServiceDetailsController extends GetxController
    with GetSingleTickerProviderStateMixin
    implements GetxService {
  final ServiceDetailsRepo serviceDetailsRepo;
  ServiceDetailsController({required this.serviceDetailsRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<VariantModel> _variantList = [];
  List<VariantModel> get variantList => _variantList;

  ServiceDetailsModel? serviceDetailsModel;
  ServiceFaqModel? serviceFaqModel;

  final List<Widget> myTabs = [
    Tab(text: 'overview'.tr),
    Tab(text: 'price_table'.tr),
    Tab(text: 'FAQs'.tr),
    Tab(text: 'review'.tr),
  ];

  TabController? controller;
  var servicePageCurrentState = ServiceTabControllerState.serviceOverview;

  Future<void> getServiceDetailsData(String serviceId) async {
    _isLoading = true;
    update();
    Response response = await serviceDetailsRepo.getServiceDetailsData(
      serviceId,
    );
    if (response.statusCode == 200) {
      serviceDetailsModel = ServiceDetailsModel.fromJson(response.body);
      _variantList = [];
      for (var element in serviceDetailsModel!.content!.variations!) {
        _variantList.add(
          VariantModel(variantName: element.variant!, price: element.price!),
        );
        _variantList.sort((a, b) => a.price.compareTo(b.price));
      }
      _isLoading = false;
      update();
    } else {
      _isLoading = false;
      update();
    }
  }

  Future<void> getServiceFAQData(String serviceId) async {
    Response response = await serviceDetailsRepo.getServiceFAQData(serviceId);
    if (response.statusCode == 200) {
      serviceFaqModel = ServiceFaqModel.fromJson(response.body);
    } else {}
  }

  void updateServicePageCurrentState(
    ServiceTabControllerState serviceDetailsTabControllerState, {
    bool shouldUpdate = true,
  }) {
    servicePageCurrentState = serviceDetailsTabControllerState;
    if (shouldUpdate) {
      update();
    } else {
      controller?.index = 0;
    }
  }

  @override
  void onInit() {
    super.onInit();
    controller = TabController(vsync: this, length: myTabs.length);
  }
}
