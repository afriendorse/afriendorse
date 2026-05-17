import 'package:afriendorse/athlete/common/model/api_response_model.dart';
import 'package:afriendorse/athlete/feature/payement_information/controller/payment_info_controller.dart';
import 'package:afriendorse/athlete/feature/transaction/model/dropdown_method_method.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class TransactionController extends GetxController implements GetxService {
  final TransactionRepo transactionRepo;
  TransactionController({required this.transactionRepo});

  int? _pageSize;
  int _offset = 1;

  int get offset => _offset;
  int? get pageSize => _pageSize;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool? _paginationLoading = false;
  bool? get paginationLoading => _paginationLoading;

  List<TransactionData>? _transactionsList = [];
  List<TransactionData>? get transactionsList => _transactionsList;

  String? _defaultPaymentMethodId;
  String? _defaultPaymentMethodName;

  String? get defaultPaymentMethodId => _defaultPaymentMethodId;
  String? get defaultPaymentMethodName => _defaultPaymentMethodName;

  WithdrawModel? _withdrawModel;
  WithdrawModel? get withdrawModel => _withdrawModel;

  List<WithdrawalMethod>? _withdrawalMethods;
  List<WithdrawalMethod>? get withdrawalMethods => _withdrawalMethods;

  String? _selectAmount;
  String? get selectAmount => _selectAmount;
  int _transactionTypeIndex = -1;
  int get transactionTypeIndex => _transactionTypeIndex;

  final ScrollController scrollController = ScrollController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (_offset < _pageSize!) {
          getWithdrawRequestList(offset + 1, true, shouldUpdate: false);
        }
      }
    });
  }

  Future<void> getWithdrawRequestList(
    int offset,
    bool isFormPagination, {
    bool shouldUpdate = true,
  }) async {
    _offset = offset;

    if (!isFormPagination) {
      _transactionsList = [];
      _isLoading = true;
    } else {
      _paginationLoading = true;
    }
    Response response = await transactionRepo.getTransactionsList(offset);
    if (response.statusCode == 200) {
      _pageSize = response.body['content']['withdraw_requests']['last_page'];
      List<dynamic> transactionList =
          response.body['content']['withdraw_requests']['data'];
      for (var element in transactionList) {
        transactionsList!.add(TransactionData.fromJson(element));
      }
    } else if (response.statusCode == 401) {
      ApiChecker.checkApi(response);
    }
    _paginationLoading = false;
    _isLoading = false;
    update();
  }

  Future<void> withDrawRequest({Map<String, String>? placeBody}) async {
    _isLoading = true;
    update();
    Response response = await transactionRepo.withdrawRequest(
      placeBody: placeBody,
    );

    if (response.statusCode == 200 &&
        response.body["response_code"] == 'default_200') {
      await Get.find<UserProfileController>().getProviderInfo(reload: true);

      Get.back();
      Get.back();
      showCustomSnackBar(
        'withdraw_request_send_successful'.tr,
        type: ToasterMessageType.success,
      );
    } else if (response.statusCode == 400) {
      Get.back();
      showCustomSnackBar(response.body['errors'][0]['message']);
    } else {
      Get.back();
      showCustomSnackBar(response.statusText);
    }
    _isLoading = false;
    update();
  }

  Future<void> getWithdrawMethods({bool isReload = false}) async {
    if (_withdrawModel == null || isReload) {
      Response response = await transactionRepo.getWithdrawMethods();
      ResponseModelApi responseApi = ResponseModelApi.fromJson(response.body);

      if (responseApi.responseCode == 'default_200' &&
          responseApi.content != null) {
        _withdrawModel = WithdrawModel.fromJson(response.body);

        _withdrawModel?.withdrawalMethods?.forEach((element) {
          if (element.isDefault == 1) {
            _defaultPaymentMethodId = element.id;
            _defaultPaymentMethodName = element.methodName;
          }
        });
      } else {
        _withdrawModel = WithdrawModel(withdrawalMethods: []);
        ApiChecker.checkApi(response);
      }
    }
    update();
  }

  Future<void> adjustTransaction() async {
    _isLoading = true;
    update();
    Response response = await transactionRepo.adjustTransaction();

    if (response.statusCode == 200) {
      await Get.find<UserProfileController>().getProviderInfo(reload: true);
      showCustomSnackBar(
        response.body['message'],
        type: ToasterMessageType.success,
      );
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  void setIndex(int index, String amount) {
    _transactionTypeIndex = index;
    _selectAmount = amount;
    update();
  }

  void selectAmountSet(String value) {
    _selectAmount = value;
    update(['inputAmountListController']);
  }

  List<DropdownMethodModel> othersMethodList = [];
  List<DropdownMethodModel> savedMethodList = [];
  DropdownMethodModel? selectedMethod;

  void onChangeMethod(DropdownMethodModel? method, {bool isUpdate = true}) {
    selectedMethod = method;

    if (isUpdate) {
      update();
    }
  }

  void getDropdownMethodList() {
    _clearMethodLists();
    _processWithdrawalMethods();
    _processSavedPaymentMethods();
  }

  void _clearMethodLists() {
    savedMethodList.clear();
    othersMethodList.clear();
  }

  void _processWithdrawalMethods() {
    for (final WithdrawalMethod method
        in _withdrawModel?.withdrawalMethods ?? []) {
      final dropdownMethod = DropdownMethodModel(
        id: method.id,
        inputName: method.methodName,
        type: MethodType.others,
        methodFields: method.methodFields,
        isDefault: method.isDefault == 1,
        withdrawalMethod: method,
      );

      othersMethodList.add(dropdownMethod);
      _setDefaultMethod(dropdownMethod, method.isDefault == 1);
    }
  }

  void _processSavedPaymentMethods() {
    for (final element
        in Get.find<PaymentInfoController>().paymentMethodListModel?.content ??
            []) {
      final dropdownMethod = DropdownMethodModel(
        id: element.withdrawalMethodId,
        inputName: element.methodName,
        type: MethodType.myMethods,
        isDefault: element.isDefault ?? false,
        methodInfo: element.methodFieldData,
        paymentMethod: element,
      );

      savedMethodList.add(dropdownMethod);
      _setDefaultMethod(dropdownMethod, element.isDefault == true);
    }
  }

  void _setDefaultMethod(DropdownMethodModel method, bool isDefault) {
    if (isDefault) {
      onChangeMethod(method, isUpdate: false);
    }
  }
}
