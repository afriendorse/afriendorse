import 'package:afriendorse/athlete/common/widgets/custom_switch_widget.dart';
import 'package:afriendorse/athlete/feature/payement_information/controller/payment_info_controller.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class AddPaymentInfoScreen extends StatefulWidget {
  final int? index;
  final String? methodName;
  final String? methodId;
  final bool? isActive;
  final bool isDefault;
  const AddPaymentInfoScreen({
    super.key,
    this.methodName,
    this.index,
    this.methodId,
    required this.isActive,
    this.isDefault = false,
  });

  @override
  State<AddPaymentInfoScreen> createState() => _AddPaymentInfoScreenState();
}

class _AddPaymentInfoScreenState extends State<AddPaymentInfoScreen> {
  TextEditingController shopNameController = TextEditingController();
  bool isEdit = false;
  bool isResetPressed = false;

  String _selectedMethodId = '';
  String _selectedMethodName = '';
  List<MethodField>? _fieldList;
  List<MethodField>? _gridFieldList;
  Map<String, TextEditingController> _textControllers = {};
  Map<String, String?> countryCodeMap = {};
  final Map<String, FocusNode> _textControllersFocus = {};
  Map<String, TextEditingController> _gridTextController = {};
  final Map<String, FocusNode> _gridTextControllerFocus = {};

  Future<void> selectPaymentMethodField(
    String id,
    String name,
    TransactionController transactionMoneyController,
  ) async {
    _selectedMethodId = id;
    _selectedMethodName = name;
    _gridFieldList = [];
    _fieldList = [];
    _textControllers = {};
    _gridTextController = {};

    for (var method
        in transactionMoneyController.withdrawModel!.withdrawalMethods!
            .firstWhere((method) => method.id.toString() == id)
            .methodFields!) {
      _gridFieldList!.addIf(
        method.inputName!.toLowerCase().contains('cvv') ||
            method.inputType!.toLowerCase() == 'date',
        method,
      );
    }

    for (var method
        in transactionMoneyController.withdrawModel!.withdrawalMethods!
            .firstWhere((method) => method.id.toString() == id)
            .methodFields!) {
      _fieldList!.addIf(
        !method.inputName!.toLowerCase().contains('cvv') &&
            method.inputType != 'date',
        method,
      );
    }

    for (var method in _fieldList!) {
      _textControllers[method.inputName!] = TextEditingController();
      if (isEdit && !isResetPressed) {
        _textControllers[method.inputName!]?.text =
            Get.find<PaymentInfoController>()
                .paymentMethodListModel
                ?.content?[widget.index!]
                .methodFieldData?[method.inputName!] ??
            '';
      }
      _textControllersFocus[method.inputName!] = FocusNode();
    }

    for (var method in _gridFieldList!) {
      _gridTextController[method.inputName!] = TextEditingController();
      if (isEdit && !isResetPressed) {
        _gridTextController[method.inputName!]?.text =
            Get.find<PaymentInfoController>()
                .paymentMethodListModel
                ?.content?[widget.index!]
                .methodFieldData?[method.inputName!] ??
            '';
      }
      _gridTextControllerFocus[method.inputName!] = FocusNode();
    }

    transactionMoneyController.update();
  }

  @override
  void initState() {
    super.initState();

    loadData();

    if (widget.methodName != null &&
        widget.index != null &&
        widget.methodId != null &&
        widget.isActive != null) {
      isEdit = true;
      Get.find<PaymentInfoController>().updateStatus(
        widget.isActive! ? 1 : 0,
        isUpdate: false,
      );
    } else {
      Get.find<PaymentInfoController>().updateStatus(1, isUpdate: false);
    }
  }

  void loadData() async {
    final transactionController = Get.find<TransactionController>();

    await transactionController.getWithdrawMethods(isReload: true);

    if (!isEdit) {
      defaultSetup();
    } else {
      final matchedMethod = transactionController
          .withdrawModel
          ?.withdrawalMethods
          ?.firstWhere(
            (method) => method.methodName == widget.methodName,
            orElse: () => WithdrawalMethod(id: '', methodName: ''),
          );

      _selectedMethodId = matchedMethod?.id ?? '';
      _selectedMethodName = matchedMethod?.methodName ?? '';
      selectPaymentMethodField(
        _selectedMethodId,
        _selectedMethodName,
        transactionController,
      );
    }
  }

  void defaultSetup() {
    final transactionController = Get.find<TransactionController>();
    _selectedMethodId = transactionController.defaultPaymentMethodId!;
    _selectedMethodName = transactionController.defaultPaymentMethodName!;
    selectPaymentMethodField(
      _selectedMethodId,
      _selectedMethodName,
      transactionController,
    );
  }

  @override
  void dispose() {
    shopNameController.dispose();
    _textControllers.forEach((key, textController) {
      textController.dispose();
    });
    _gridTextController.forEach((key, textController) {
      textController.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: isEdit
            ? 'update_payment_information'.tr
            : 'add_payment_information'.tr,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: GetBuilder<AuthController>(
          builder: (authController) {
            return GetBuilder<TransactionController>(
              builder: (transactionMoneyController) {
                return GetBuilder<PaymentInfoController>(
                  builder: (paymentInfoController) {
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiary.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeSmall,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info,
                                color: Theme.of(
                                  context,
                                ).colorScheme.tertiary.withValues(alpha: 0.8),
                                size: Dimensions.paddingSizeLarge,
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),

                              Flexible(
                                child: Text(
                                  'verify_payment_info_warning'.tr,
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withValues(alpha: 0.70),
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Dimensions.paddingSizeLarge),

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeSmall,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(
                                Dimensions.paddingSizeSmall,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: Dimensions.paddingSizeSmall),

                                  DropdownButton<WithdrawalMethod>(
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                    ),
                                    underline: Divider(
                                      color: Theme.of(
                                        context,
                                      ).hintColor.withValues(alpha: 0.4),
                                      thickness: 1,
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    isExpanded: true,
                                    hint: _selectedMethodName.isNotEmpty
                                        ? Text(
                                            _selectedMethodName,
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withValues(alpha: 0.8),
                                            ),
                                          )
                                        : Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "select_payment_method"
                                                      .tr,
                                                  style: robotoRegular,
                                                ),

                                                TextSpan(
                                                  text: " *",
                                                  style: robotoRegular.copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.error,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    items: transactionMoneyController.withdrawModel?.withdrawalMethods!.map((
                                      WithdrawalMethod withdraw,
                                    ) {
                                      return DropdownMenuItem(
                                        alignment: AlignmentDirectional.center,
                                        value: withdraw,
                                        child: withdraw.isActive == 1
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    withdraw.methodName ??
                                                        'no method'.tr,
                                                    style: robotoRegular
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                        ),
                                                  ),

                                                  if (withdraw.isDefault == 1)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: Dimensions
                                                                .paddingSizeSmall,
                                                            vertical: 3,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              50,
                                                            ),
                                                        border: Border.all(
                                                          color: Theme.of(
                                                            context,
                                                          ).primaryColorLight,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "default".tr,
                                                        style: robotoRegular
                                                            .copyWith(
                                                              color: Theme.of(
                                                                context,
                                                              ).primaryColorLight,
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                            ),
                                                      ),
                                                    ),
                                                ],
                                              )
                                            : const SizedBox(),
                                      );
                                    }).toList(),
                                    onChanged: (WithdrawalMethod? withdraw) {
                                      _selectedMethodName = withdraw!.methodName
                                          .toString();
                                      _selectedMethodId = withdraw.id
                                          .toString();
                                      selectPaymentMethodField(
                                        withdraw.id.toString(),
                                        withdraw.methodName.toString(),
                                        transactionMoneyController,
                                      );
                                    },
                                  ),
                                  SizedBox(height: Dimensions.paddingSizeLarge),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("status".tr),

                                      Transform.translate(
                                        offset: Offset(10, 0),
                                        child: IgnorePointer(
                                          ignoring: widget.isDefault,
                                          child: CustomSwitchWidget(
                                            value:
                                                paymentInfoController.status ==
                                                1,
                                            activeColor: widget.isDefault
                                                ? Theme.of(
                                                    context,
                                                  ).disabledColor
                                                : Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            onChanged: (value) {
                                              paymentInfoController
                                                  .updateStatus(
                                                    value ? 1 : 0,
                                                    isUpdate: true,
                                                  );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Divider(
                                    color: Theme.of(
                                      context,
                                    ).hintColor.withValues(alpha: 0.4),
                                    thickness: 1,
                                    height: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  SizedBox(
                                    height: Dimensions.paddingSizeExtraLarge,
                                  ),

                                  if (_fieldList != null &&
                                      _fieldList!.isNotEmpty)
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _fieldList!.length,
                                      padding: const EdgeInsets.symmetric(
                                        vertical:
                                            Dimensions.paddingSizeExtraSmall,
                                        horizontal: 0,
                                      ),
                                      itemBuilder: (context, index) =>
                                          FieldItemView(
                                            methodField: _fieldList![index],
                                            textControllers: _textControllers,
                                            focusNodes: _textControllersFocus,
                                          ),
                                    ),

                                  if (_gridFieldList != null &&
                                      _gridFieldList!.isNotEmpty)
                                    GridView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        vertical:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 2,
                                            crossAxisSpacing: 20,
                                            mainAxisSpacing: 20,
                                          ),
                                      itemCount: _gridFieldList!.length,
                                      itemBuilder: (context, index) =>
                                          FieldItemView(
                                            methodField: _gridFieldList![index],
                                            textControllers:
                                                _gridTextController,
                                            focusNodes:
                                                _gridTextControllerFocus,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: Dimensions.paddingSizeSmall,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  btnTxt: "reset".tr,
                                  onPressed: () {
                                    loadData();

                                    if (widget.methodName != null &&
                                        widget.index != null &&
                                        widget.methodId != null &&
                                        widget.isActive != null) {
                                      isEdit = true;
                                      Get.find<PaymentInfoController>()
                                          .updateStatus(
                                            widget.isActive! ? 1 : 0,
                                            isUpdate: false,
                                          );
                                    } else {
                                      Get.find<PaymentInfoController>()
                                          .updateStatus(1, isUpdate: false);
                                    }
                                  },
                                  textColor: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                  color: Theme.of(
                                    context,
                                  ).hintColor.withValues(alpha: 0.3),
                                ),
                              ),
                              SizedBox(width: Dimensions.paddingSizeDefault),

                              Expanded(
                                child: CustomButton(
                                  isLoading: paymentInfoController.loading,
                                  btnTxt: isEdit ? "update".tr : "submit".tr,
                                  onPressed: () async {
                                    WithdrawalMethod withdrawMethod =
                                        transactionMoneyController
                                            .withdrawModel!
                                            .withdrawalMethods!
                                            .firstWhere(
                                              (method) =>
                                                  _selectedMethodId ==
                                                  method.id.toString(),
                                            );

                                    Map<String, String> methodFieldValue = {};

                                    String? message = validateMethodSubmission(
                                      transactionMoneyController,
                                      withdrawMethod,
                                      methodFieldValue,
                                    );

                                    if (message != null) {
                                      showCustomSnackBar(message);
                                      message = null;
                                    } else {
                                      Map<String, dynamic> paymentMethodBody = {
                                        'withdrawal_method_id':
                                            '${withdrawMethod.id}',
                                        'method_field_data': methodFieldValue,
                                        'is_active':
                                            '${paymentInfoController.status}',
                                      };

                                      if (isEdit) {
                                        await paymentInfoController
                                            .updatePaymentMethod(
                                              paymentMethodBody,
                                              methodId: widget.methodId,
                                            );
                                      } else {
                                        await paymentInfoController
                                            .storePaymentMethod(
                                              paymentMethodBody,
                                            );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  String? validateMethodSubmission(
    TransactionController transactionMoneyController,
    WithdrawalMethod withdrawMethod,
    Map<String, String> methodFieldValue,
  ) {
    String? message;

    final Map<String, String> fieldTypeMap = {};

    for (var method in withdrawMethod.methodFields!) {
      if (method.inputName != null && method.inputType != null) {
        fieldTypeMap[method.inputName!] = method.inputType!;
        fieldTypeMap['${method.inputName}_is_required'] = method.isRequired
            .toString();
      }
    }

    _textControllers.forEach((key, textController) {
      methodFieldValue[key] = textController.text;

      final inputType = fieldTypeMap[key];

      if (inputType == 'email' && !GetUtils.isEmail(textController.text)) {
        message = 'please_provide_valid_email'.tr;
      } else if (inputType == 'date' && textController.text.isEmpty) {
        message = 'please_provide_valid_date'.tr;
      }
      if (textController.text.isEmpty && !_isValidDate(textController.text)) {
        message =
            '${'please_fill'.tr} ${key.replaceAll('_', ' ')} ${'field'.tr}';
      }
    });

    _gridTextController.forEach((key, textController) {
      methodFieldValue[key] = textController.text;

      final inputType = fieldTypeMap[key];
      final bool isRequired = fieldTypeMap['${key}_is_required'] == '1';

      if (inputType == 'date' && !_isValidDate(textController.text)) {
        message = 'please_provide_valid_date'.tr;
      }
      if (textController.text.isEmpty && message == null && isRequired) {
        message = 'Please fill ${key.replaceAll('_', ' ')} field';
      }
    });
    return message;
  }

  bool _isValidDate(String input) {
    final onlyDigits = input.replaceAll(RegExp(r'\D'), '');
    return onlyDigits.length == 6;
  }
}
