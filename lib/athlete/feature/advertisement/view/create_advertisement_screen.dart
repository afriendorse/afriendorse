import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class CreateAdvertisementScreen extends StatefulWidget {
  final bool isEditScreen;
  final bool fromDetailsScreen;
  final bool isForResubmit;
  final AdvertisementData? advertisementData;
  const CreateAdvertisementScreen({
    super.key,
    required this.isEditScreen,
    this.advertisementData,
    this.fromDetailsScreen = false,
    this.isForResubmit = false,
  });
  @override
  State<CreateAdvertisementScreen> createState() =>
      _CreateAdvertisementScreenState();
}

class _CreateAdvertisementScreenState extends State<CreateAdvertisementScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode _validationFocus = FocusNode();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  TabController? multiLanguageTabController;

  List<TextEditingController> titleController = [];
  List<TextEditingController> descriptionController = [];

  List<Language> languageList =
      Get.find<SplashController>().configModel.content?.languageList ?? [];
  List<Widget> tabList = [];

  @override
  void initState() {
    if (languageList.first.fullName != "Default") {
      languageList.insert(
        0,
        Language(fullName: "Default", languageCode: "default"),
      );
    }
    multiLanguageTabController = TabController(
      length: languageList.length,
      initialIndex: 0,
      vsync: this,
    );

    for (var language in languageList) {
      titleController.add(TextEditingController());
      descriptionController.add(TextEditingController());
      tabList.add(
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
          ),
          child: Tab(text: "${language.fullName}"),
        ),
      );
    }

    if (widget.isEditScreen) {
      titleController[0].text = widget.advertisementData?.defaultTitle ?? "";
      descriptionController[0].text =
          widget.advertisementData?.defaultDescription ?? "";

      for (int index = 1; index < languageList.length; index++) {
        widget.advertisementData?.translationList?.forEach((element) {
          if (element.locale == languageList[index].languageCode &&
              element.key == "title") {
            titleController[index].text = element.value ?? "";
          } else if (element.locale == languageList[index].languageCode &&
              element.key == "description") {
            descriptionController[index].text = element.value ?? "";
          }
        });
      }

      AdvertisementController advertisementController = Get.find();
      advertisementController.initializeAdvertisementValues(
        widget.advertisementData!,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    Get.find<AdvertisementController>().videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(
      builder: (advertisementController) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: CustomAppBar(
            title: widget.isEditScreen && !widget.isForResubmit
                ? "edit_advertisement".tr
                : "create_new_advertisement".tr,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                      boxShadow: context.customThemeColors.lightShadow,
                      color: Theme.of(context).cardColor,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: 0,
                    ),
                    margin: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeSmall,
                      Dimensions.paddingSizeSmall,
                      Dimensions.paddingSizeSmall,
                      3,
                    ),

                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFieldTitle(
                            title: "ads_type".tr,
                            requiredMark: true,
                            isPadding: false,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: Get.width,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                          advertisementController
                                              .isDateRangeValid
                                          ? Theme.of(context).hintColor
                                          : Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    padding: EdgeInsets.zero,
                                    dropdownColor: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(5),
                                    elevation: 2,
                                    hint: Text(
                                      advertisementController
                                          .selectedAdsType
                                          .tr,
                                      style: robotoRegular.copyWith(
                                        color:
                                            advertisementController
                                                    .selectedAdsType ==
                                                ''
                                            ? Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color!
                                                  .withValues(alpha: 0.6)
                                            : Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color!
                                                  .withValues(alpha: 0.8),
                                        fontSize:
                                            advertisementController
                                                    .selectedAdsType ==
                                                ''
                                            ? Dimensions.fontSizeSmall
                                            : Dimensions.fontSizeDefault,
                                      ),
                                    ),
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: advertisementController.adsType.map((
                                      String items,
                                    ) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Row(
                                          children: [
                                            Text(
                                              items.tr,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color!
                                                    .withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      advertisementController.setAdsType(
                                        type: newValue!,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (!advertisementController.isDateRangeValid)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    'fill_required_field'.tr,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          InkWell(
                            onTap: () async {
                              DateTimeRange?
                              dateTimeRange = await showDateRangePicker(
                                //locale: Get.find<LocalizationController>().locale,
                                initialEntryMode: DatePickerEntryMode.calendar,
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(3000),
                                currentDate: DateTime.now(),
                              );

                              if (dateTimeRange != null) {
                                advertisementController.dateTimeRange =
                                    dateTimeRange;
                                advertisementController
                                    .validationController
                                    ?.text = advertisementController
                                    .modifyDateRange();
                              }
                              setState(() {
                                formKey.currentState!.validate();
                              });
                            },
                            child: CustomTextField(
                              inputType: TextInputType.text,
                              controller:
                                  advertisementController.validationController,
                              hintText: "validation".tr,
                              title: "validation".tr,
                              focusNode: _validationFocus,
                              capitalization: TextCapitalization.sentences,
                              inputAction: TextInputAction.done,
                              isEnabled: false,
                              suffixIcon: Images.customCalender,
                              onValidate: (value) {
                                if (value == null || value.isEmpty) {
                                  return "enter_validation".tr;
                                } else if (value.isNotEmpty) {
                                  if (widget.isEditScreen) {
                                    bool isNotValidTimeRange =
                                        advertisementController
                                            .validateTimeRange();
                                    if (isNotValidTimeRange) {
                                      return "Enter a valid date range";
                                    }
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.04),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeDefault,
                              horizontal: Dimensions.paddingSizeSmall,
                            ),

                            child: Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: TabBar(
                                    tabAlignment: TabAlignment.start,
                                    controller: multiLanguageTabController,
                                    unselectedLabelColor: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withValues(alpha: 0.5),
                                    indicatorColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    labelColor: Theme.of(
                                      context,
                                    ).primaryColorLight,
                                    labelStyle: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                    ),
                                    labelPadding: EdgeInsets.zero,
                                    isScrollable: true,
                                    dividerHeight: 0.2,
                                    dividerColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    tabs: tabList,
                                    onTap: (int? value) {
                                      setState(() {
                                        formKey.currentState!.validate();
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),

                                CustomTextFieldWidget(
                                  titleText:
                                      "${'title'.tr} (${languageList[multiLanguageTabController!.index].fullName})"
                                          .tr,
                                  controller:
                                      titleController[multiLanguageTabController!
                                          .index],
                                  focusNode: _titleFocus,
                                  nextFocus: _descriptionFocus,
                                  inputType: TextInputType.name,
                                  capitalization: TextCapitalization.words,
                                  labelText:
                                      '${'title'.tr} (${languageList[multiLanguageTabController!.index].fullName})',
                                  required:
                                      multiLanguageTabController!.index == 0,
                                  validator: (value) =>
                                      (multiLanguageTabController!.index == 0 &&
                                          (value == null || value.isEmpty))
                                      ? "enter_title".tr
                                      : null,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraMoreLarge,
                                ),
                                CustomTextFieldWidget(
                                  titleText:
                                      "${'description'.tr} ${languageList[multiLanguageTabController!.index].fullName}"
                                          .tr,
                                  controller:
                                      descriptionController[multiLanguageTabController!
                                          .index],
                                  focusNode: _descriptionFocus,
                                  inputType: TextInputType.text,
                                  capitalization: TextCapitalization.words,
                                  maxLines: 2,
                                  maxLength: 100,
                                  labelText:
                                      '${'description'.tr.replaceAll(":", "")}(${languageList[multiLanguageTabController!.index].fullName})',
                                  required:
                                      multiLanguageTabController!.index == 0,
                                  validator: (value) =>
                                      (multiLanguageTabController!.index == 0 &&
                                          (value == null || value.isEmpty))
                                      ? "enter_description".tr
                                      : null,
                                ),
                              ],
                            ),
                          ),

                          advertisementController.selectedAdsType !=
                                  'video_promotion'
                              ? TextFieldTitle(title: 'show_review_ratings'.tr)
                              : const SizedBox(),
                          advertisementController.selectedAdsType !=
                                  'video_promotion'
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                    vertical: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.paddingSizeSmall,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CustomCheckBox(
                                        value: advertisementController
                                            .isReviewChecked,
                                        title: 'review'.tr,
                                        onTap: () => advertisementController
                                            .toggleReviewChecked(),
                                      ),
                                      SizedBox(width: Get.size.width * 0.08),

                                      CustomCheckBox(
                                        value: advertisementController
                                            .isRatingsChecked,
                                        title: 'ratings'.tr,
                                        onTap: () => advertisementController
                                            .toggleRatingChecked(),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),

                          advertisementController.selectedAdsType !=
                                  'video_promotion'
                              ? const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                )
                              : const SizedBox(),

                          advertisementController.selectedAdsType !=
                                  'video_promotion'
                              ? TextFieldTitle(
                                  title: "logo/profile".tr,
                                  subtitle: "(1:1)".tr,
                                  requiredMark: true,
                                )
                              : const SizedBox(),

                          advertisementController.selectedAdsType !=
                                  'video_promotion'
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.4,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              advertisementController
                                                              .pickedProfileImage !=
                                                          null ||
                                                      advertisementController
                                                              .networkProfileImage !=
                                                          null
                                                  ? const CreateAdvertisementLogoView()
                                                  : DottedBorderBox(
                                                      height: 100,
                                                      width: 100,
                                                      showErrorBorder:
                                                          !advertisementController
                                                              .isLogoValid,
                                                      onTap: () =>
                                                          advertisementController
                                                              .pickProfileImage(
                                                                false,
                                                              ),
                                                    ),
                                            ],
                                          ),
                                        ),

                                        Expanded(
                                          child: Text(
                                            "image_validation_text_3".tr,
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                            maxLines: 5,
                                          ),
                                        ),
                                      ],
                                    ),

                                    !advertisementController.isLogoValid
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            child: Text(
                                              "provide_image_logo".tr,
                                              overflow: TextOverflow.ellipsis,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                )
                              : const SizedBox(),

                          advertisementController.selectedAdsType !=
                                  'video_promotion'
                              ? const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                )
                              : const SizedBox(),

                          advertisementController.selectedAdsType ==
                                  'video_promotion'
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFieldTitle(
                                      title: "upload_video".tr,
                                      subtitle: "(16/9)".tr,
                                      requiredMark: true,
                                    ),

                                    advertisementController.pickedVideoFile ==
                                                null &&
                                            advertisementController
                                                    .networkVideoFile ==
                                                null
                                        ? AspectRatio(
                                            aspectRatio: 16 / 9,
                                            child: DottedVideoBorder(
                                              showErrorBorder:
                                                  !advertisementController
                                                      .isVideoValid,
                                              text: 'upload_video_message'.tr,
                                              onTap: () =>
                                                  advertisementController
                                                      .pickVideoFile(false),
                                            ),
                                          )
                                        : advertisementController
                                              .videoPlayerController!
                                              .value
                                              .isInitialized
                                        ? Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              AspectRatio(
                                                aspectRatio:
                                                    advertisementController
                                                        .videoPlayerController!
                                                        .value
                                                        .aspectRatio,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        Dimensions
                                                            .radiusDefault,
                                                      ),
                                                  child: VideoPlayer(
                                                    advertisementController
                                                        .videoPlayerController!,
                                                  ),
                                                ),
                                              ),

                                              Positioned(
                                                top: 10,
                                                right: 10,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    Dimensions
                                                            .paddingSizeExtraSmall -
                                                        5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(
                                                      context,
                                                    ).cardColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault,
                                                        ),
                                                  ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      advertisementController
                                                          .pickVideoFile(true);
                                                    },
                                                    child: Icon(
                                                      Icons.close,
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.error,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              FloatingActionButton.small(
                                                backgroundColor: Colors.grey,
                                                onPressed: () {
                                                  setState(() {
                                                    advertisementController
                                                            .videoPlayerController!
                                                            .value
                                                            .isPlaying
                                                        ? advertisementController
                                                              .videoPlayerController!
                                                              .pause()
                                                        : advertisementController
                                                              .videoPlayerController!
                                                              .play();
                                                  });
                                                },
                                                child: Icon(
                                                  advertisementController
                                                          .videoPlayerController!
                                                          .value
                                                          .isPlaying
                                                      ? Icons.pause
                                                      : Icons.play_arrow,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const CreateAdvertisementVideoViewShimmer(),

                                    !advertisementController.isVideoValid
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            child: Text(
                                              "enter_video".tr,
                                              overflow: TextOverflow.ellipsis,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),

                                    Text(
                                      "video_validation_text_2".tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: 12,
                                        color: Theme.of(context).hintColor,
                                      ),
                                      maxLines: 5,
                                    ),

                                    const SizedBox(
                                      height:
                                          Dimensions.paddingSizeExtraMoreLarge,
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFieldTitle(
                                      title: "upload_cover_image".tr,
                                      subtitle: "(2:1)".tr,
                                      requiredMark: true,
                                    ),

                                    advertisementController.pickedCoverImage !=
                                                null ||
                                            advertisementController
                                                    .networkCoverImage !=
                                                null
                                        ? Stack(
                                            children: [
                                              AspectRatio(
                                                aspectRatio: 20 / 9,
                                                child:
                                                    advertisementController
                                                                .pickedCoverImage !=
                                                            null &&
                                                        advertisementController
                                                                .networkCoverImage ==
                                                            null
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        child: Image.file(
                                                          File(
                                                            advertisementController
                                                                .pickedCoverImage!
                                                                .path,
                                                          ),
                                                          fit: BoxFit.cover,
                                                          height: 100,
                                                          width: 100,
                                                        ),
                                                      )
                                                    : advertisementController
                                                                  .networkCoverImage !=
                                                              null &&
                                                          advertisementController
                                                                  .pickedCoverImage ==
                                                              null
                                                    ? AspectRatio(
                                                        aspectRatio: 20 / 9,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          child: CustomImage(
                                                            image:
                                                                "${advertisementController.networkCoverImage}",
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                              ),

                                              Positioned(
                                                top: -10,
                                                right: -10,
                                                child: IconButton(
                                                  onPressed: () =>
                                                      advertisementController
                                                          .pickCoverImage(true),
                                                  icon: const Icon(
                                                    Icons
                                                        .highlight_remove_rounded,
                                                    color: Colors.red,
                                                    size: 25,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : AspectRatio(
                                            aspectRatio: 20 / 9,
                                            child: DottedVideoBorder(
                                              showErrorBorder:
                                                  !advertisementController
                                                      .isCoverImageValid,
                                              text: 'upload_video_message'.tr,
                                              onTap: () =>
                                                  advertisementController
                                                      .pickCoverImage(false),
                                            ),
                                          ),

                                    !advertisementController.isCoverImageValid
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            child: Text(
                                              "enter_cover_image".tr,
                                              overflow: TextOverflow.ellipsis,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),
                                    Text(
                                      "cover_image_validation_text".tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: 12,
                                        color: Theme.of(context).hintColor,
                                      ),
                                      maxLines: 5,
                                    ),
                                    const SizedBox(
                                      height:
                                          Dimensions.paddingSizeExtraMoreLarge,
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      btnTxt: "reset".tr,
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                      textColor: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                      width: 100,
                      height: 40,
                      onPressed: () {
                        if (widget.isEditScreen) {
                          advertisementController.initializeAdvertisementValues(
                            advertisementController
                                .advertisementDetailsModel!
                                .advertisementData!,
                          );
                        } else {
                          advertisementController.resetAllValues(
                            shouldUpdate: true,
                          );
                        }
                      },
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    CustomButton(
                      btnTxt: widget.isEditScreen && !widget.isForResubmit
                          ? "re_submit".tr
                          : "submit".tr,
                      fontSize: Dimensions.fontSizeSmall,
                      width: 100,
                      height: 40,
                      isLoading: advertisementController.isLoading,
                      onPressed: () {
                        advertisementController.checkValidation();
                        if (widget.isEditScreen) {
                          if (advertisementController.selectedAdsType ==
                              'video_promotion') {
                            if (formKey.currentState!.validate() &&
                                advertisementController.isVideoValid) {
                              if (widget.isForResubmit) {
                                advertisementController.reSubmitAdvertisement(
                                  widget.advertisementData!,
                                  titleController: titleController,
                                  descriptionController: descriptionController,
                                  languageList: languageList,
                                );
                              } else {
                                advertisementController.editAdvertisement(
                                  widget.advertisementData!,
                                  isFromDetailsPage: widget.fromDetailsScreen,
                                  titleController: titleController,
                                  descriptionController: descriptionController,
                                  languageList: languageList,
                                );
                              }
                            }
                          } else {
                            if (formKey.currentState!.validate() &&
                                advertisementController.isCoverImageValid &&
                                advertisementController.isLogoValid) {
                              if (widget.isForResubmit) {
                                advertisementController.reSubmitAdvertisement(
                                  widget.advertisementData!,
                                  titleController: titleController,
                                  descriptionController: descriptionController,
                                  languageList: languageList,
                                );
                              } else {
                                advertisementController.editAdvertisement(
                                  widget.advertisementData!,
                                  isFromDetailsPage: widget.fromDetailsScreen,
                                  titleController: titleController,
                                  descriptionController: descriptionController,
                                  languageList: languageList,
                                );
                              }
                            }
                          }
                        } else {
                          if (advertisementController.selectedAdsType ==
                              'video_promotion') {
                            if (formKey.currentState!.validate() &&
                                advertisementController.isVideoValid) {
                              advertisementController.submitNewAdvertisement(
                                titleController: titleController,
                                descriptionController: descriptionController,
                                languageList: languageList,
                              );
                            }
                          } else {
                            if (formKey.currentState!.validate() &&
                                advertisementController.isCoverImageValid &&
                                advertisementController.isLogoValid) {
                              advertisementController.submitNewAdvertisement(
                                titleController: titleController,
                                descriptionController: descriptionController,
                                languageList: languageList,
                              );
                            }
                          }
                        }
                      },
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                  ],
                ),
              ),
            ],
          ),

          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: FloatingActionButton(
              heroTag: 'create_screen',
              shape: const CircleBorder(),
              elevation: 0,
              backgroundColor: Theme.of(context).primaryColor,

              onPressed: () {
                if (advertisementController.pickedVideoFile != null &&
                    advertisementController
                        .videoPlayerController!
                        .value
                        .isInitialized) {
                  advertisementController.videoPlayerController!.pause();
                }

                advertisementController.selectedAdsType == 'video_promotion'
                    ? showCustomDialog(
                        child: PreviewVideoDialogWidget(
                          title: titleController[0].text,
                          description: descriptionController[0].text,
                          validation: advertisementController
                              .validationController
                              ?.text,
                        ),
                        barrierDismissible: true,
                      )
                    : showCustomDialog(
                        child: PreviewProviderPromotionWidget(
                          title: titleController[0].text,
                          description: descriptionController[0].text,
                          validation: advertisementController
                              .validationController
                              ?.text,
                          pickedCoverImage:
                              advertisementController.pickedCoverImage?.path,
                          networkCoverImage:
                              advertisementController.networkCoverImage,
                          pickedProfileImage:
                              advertisementController.pickedProfileImage?.path,
                          networkProfileImage:
                              advertisementController.networkProfileImage,
                          isShowRatings:
                              advertisementController.isRatingsChecked,
                          isShowReview: advertisementController.isReviewChecked,
                        ),
                        barrierDismissible: true,
                      );
              },
              child: Icon(Icons.remove_red_eye_sharp, color: light.cardColor),
            ),
          ),
        );
      },
    );
  }
}
