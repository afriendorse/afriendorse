import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/profile/view/bank_information/model/bank_info_nodel.dart';

class BankInfoController extends GetxController implements GetxService {
  final BankInfoRepo bankInfoRepo;
  BankInfoController({required this.bankInfoRepo});

  final GlobalKey<FormState> bankInformationFormKey = GlobalKey<FormState>();
  TextEditingController? bankNameController,
      branchNameController,
      accountNoController,
      accountHolderNameController,
      routingNumberController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  BankInfoModel? bankInfoModel;

  @override
  void onInit() {
    super.onInit();
    bankNameController = TextEditingController();
    branchNameController = TextEditingController();
    accountNoController = TextEditingController();
    accountHolderNameController = TextEditingController();
    routingNumberController = TextEditingController();
    //getBankInfoData();
  }

  @override
  void onClose() {
    bankNameController!.dispose();
    branchNameController!.dispose();
    accountNoController!.dispose();
    accountHolderNameController!.dispose();
  }

  Future<void> getBankInfoData() async {
    Response response = await bankInfoRepo.getBankInfoData();

    if (response.statusCode == 200) {
      bankInfoModel = BankInfoModel.fromJson(response.body);
      if (bankInfoModel!.content != null) {
        bankNameController!.text = bankInfoModel!.content!.bankName.toString();
        branchNameController!.text = bankInfoModel!.content!.branchName
            .toString();
        accountNoController!.text = bankInfoModel!.content!.accNo.toString();
        accountHolderNameController!.text = bankInfoModel!
            .content!
            .accHolderName
            .toString();
        routingNumberController!.text = bankInfoModel!.content!.routingNumber
            .toString();
      }
    } else {}
    update();
  }

  Future<void> updateBankInfo() async {
    _isLoading = true;
    update();
    Response response = await bankInfoRepo.updateBankInfo(
      bankNameController!.text,
      branchNameController!.text,
      accountNoController!.text,
      accountHolderNameController!.text,
      routingNumberController!.text,
    );

    if (response.statusCode == 200) {
      showCustomSnackBar(
        "bank_information_updated_successfully".tr,
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar(response.body['errors'][0]['message']);
    }
    _isLoading = false;
    update();
  }

  Future<void> withdrawRequest(String amount, String note) async {
    _isLoading = true;
    update();
    Response response = await bankInfoRepo.withdrawRequest(amount, note);

    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_200') {
      Get.find<UserProfileController>().getProviderInfo();
      Get.back();
      showCustomSnackBar(
        "with_draw_request".tr,
        type: ToasterMessageType.success,
      );
    } else {
      Get.back();
      showCustomSnackBar(response.body['errors'][0]['message']);
    }
    _isLoading = false;
    update();
  }

  String? validateEmptyText(String value) {
    if (value.isEmpty) {
      return "Enter valid information";
    }
    return null;
  }

  bool checkValidation() {
    final isValid = bankInformationFormKey.currentState!.validate();
    if (!isValid) {
      return false;
    }
    bankInformationFormKey.currentState!.save();

    return true;
  }
}
