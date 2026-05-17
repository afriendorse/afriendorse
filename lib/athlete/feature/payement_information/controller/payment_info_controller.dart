import 'package:afriendorse/athlete/feature/payement_information/model/payment_method_list_model.dart';
import 'package:afriendorse/athlete/feature/payement_information/repository/payment_info_repo.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class PaymentInfoController extends GetxController implements GetxService {
  final PaymentInfoRepo paymentInfoRepo;
  PaymentInfoController({required this.paymentInfoRepo});

  int? _status = 0;
  int? get status => _status;
  PaymentMethodListModel? _paymentMethodListModel;
  PaymentMethodListModel? get paymentMethodListModel => _paymentMethodListModel;

  bool loading = false;

  Future<void> getPaymentMethods({
    bool isUpdate = true,
    bool isReload = true,
  }) async {
    _paymentMethodListModel = null;
    if (isUpdate || isReload) {
      update();
    }
    final response = await paymentInfoRepo.getPaymentMethods();
    if (response.statusCode == 200 && response.body != null) {
      _paymentMethodListModel = PaymentMethodListModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future<void> storePaymentMethod(
    Map<String, dynamic> paymentMethodBody,
  ) async {
    loading = true;
    update();

    final response = await paymentInfoRepo.storePaymentInfo(paymentMethodBody);
    if (response.statusCode == 200) {
      await getPaymentMethods();
      Get.back();
      showCustomSnackBar(
        'payment_method_added_successfully'.tr,
        type: ToasterMessageType.success,
      );
    } else {
      ApiChecker.checkApi(response);
    }

    loading = false;
    update();
  }

  Future<void> updatePaymentMethod(
    Map<String, dynamic> paymentMethodBody, {
    String? methodId,
  }) async {
    loading = true;
    update();

    final response = await paymentInfoRepo.updatePaymentInfo(
      paymentMethodBody,
      methodId,
    );
    if (response.statusCode == 200) {
      await getPaymentMethods();
      Get.back();
      showCustomSnackBar(
        'payment_method_updated_successfully'.tr,
        type: ToasterMessageType.success,
      );
    } else {
      ApiChecker.checkApi(response);
    }

    loading = false;
    update();
  }

  Future<void> statusUpdatePaymentMethod({
    String? methodId,
    bool? status,
    int? index,
  }) async {
    final response = await paymentInfoRepo.statusUpdatePaymentMethod(methodId);
    if (response.statusCode == 200) {
      _paymentMethodListModel?.content?[index!].isActive = status;
      showCustomSnackBar(
        'payment_method_updated_successfully'.tr,
        type: ToasterMessageType.success,
      );
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> markPaymentMethodAsDefault(String? methodId) async {
    final response = await paymentInfoRepo.markPaymentMethodAsDefault(methodId);
    if (response.statusCode == 200) {
      await getPaymentMethods();
      showCustomSnackBar(
        'payment_method_updated_successfully'.tr,
        type: ToasterMessageType.success,
      );
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> deletePaymentMethod(String? methodId) async {
    final response = await paymentInfoRepo.deletePaymentMethod(methodId);
    if (response.statusCode == 200) {
      await getPaymentMethods();
      showCustomSnackBar(
        'payment_method_deleted_successfully'.tr,
        type: ToasterMessageType.success,
      );
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void updateStatus(int value, {bool isUpdate = true}) {
    _status = value;
    if (isUpdate) {
      update();
    }
  }
}
