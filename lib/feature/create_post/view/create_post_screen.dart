/* 
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class CreatePostScreen extends StatefulWidget {
  // NEW: null = open post (from homepage banner)
  //      set  = targeted post (from athlete details page)
  final String? targetProviderId;
  const CreatePostScreen({super.key, this.targetProviderId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late JustTheController tooltipController;
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Get.find<CategoryController>().getCategoryList(false);
    Get.find<ScheduleController>().resetSchedule();
    tooltipController = JustTheController();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScheduleController>(
      builder: (scheduleController) {
        return Scaffold(
          drawer: ResponsiveHelper.isDesktop(context)
              ? const AddressSelectionDrawer()
              : null,

          endDrawer: ResponsiveHelper.isDesktop(context)
              ? const MenuDrawer()
              : null,
          appBar: CustomAppBar(
            title: "create_post".tr,
            isBackButtonExist: true,
            onBackPressed: () {
              if (Navigator.canPop(context)) {
                Get.back();
              } else {
                Get.offAllNamed(RouteHelper.getMainRoute("home"));
              }
            },
          ),


          body: FooterBaseView(
            child: WebShadowWrap(
              child: GetBuilder<CategoryController>(
                builder: (categoryController) {
                  return GetBuilder<CreatePostController>(
                    builder: (createPostController) {
                      return Padding(
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeDefault,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ServiceSchedule(),

                            const CustomerLocationInfo(),

                            TextFieldTitle(
                              title: "service_category".tr,
                              requiredMark: true,
                            ),
                            Container(
                              width: Get.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeSmall,
                                ),
                                border: Border.all(
                                  color: Theme.of(context).disabledColor,
                                  width: 1,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  isExpanded: true,
                                  dropdownColor: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(5),
                                  elevation: 2,
                                  onTap: () {
                                    createPostController.updateSelectedService(
                                      null,
                                    );
                                  },

                                  hint: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeLarge,
                                    ),
                                    child: Text(
                                      createPostController
                                                  .selectedCategoryName ==
                                              ''
                                          ? "select_category".tr
                                          : createPostController
                                                .selectedCategoryName,
                                      style: robotoRegular.copyWith(
                                        color:
                                            createPostController
                                                    .selectedCategoryName ==
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
                                      ),
                                    ),
                                  ),
                                  icon: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeLarge,
                                    ),
                                    child: Icon(Icons.keyboard_arrow_down),
                                  ),
                                  items: categoryController.categoryList?.map((
                                    CategoryModel items,
                                  ) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Text(
                                        items.name ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color!
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (CategoryModel? newValue) {
                                    createPostController.selectCategory(
                                      newValue?.id ?? "",
                                    );
                                    showModalBottomSheet(
                                      useRootNavigator: true,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (context) =>
                                          SubcategoryServiceView(
                                            categorySlug: newValue?.slug ?? "",
                                          ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (createPostController.selectedService != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFieldTitle(
                                    title: "service".tr,
                                    requiredMark: false,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.05),
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeExtraSmall,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusSmall,
                                          ),
                                          child: CustomImage(
                                            image:
                                                '${createPostController.selectedService!.thumbnailFullPath}',
                                            height: 50,
                                            width: 50,
                                          ),
                                        ),
                                        SizedBox(
                                          width: Dimensions.fontSizeLarge,
                                        ),
                                        Expanded(
                                          child: Text(
                                            createPostController
                                                    .selectedService!
                                                    .name ??
                                                "",
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),

                            Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextFieldTitle(
                                          title:
                                              "provide_service_description".tr,
                                          requiredMark: false,
                                        ),
                                        JustTheTooltip(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).primaryColorDark,
                                          controller: tooltipController,
                                          preferredDirection: AxisDirection.up,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(
                                              Dimensions.radiusExtraLarge,
                                            ),
                                          ),
                                          tailLength: 14,
                                          tailBaseWidth: 20,

                                          content: Padding(
                                            padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeDefault,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "create_service_request_instruction"
                                                      .tr,
                                                  textAlign: TextAlign.center,
                                                  style: robotoRegular.copyWith(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              tooltipController.showTooltip();
                                            },
                                            icon: Icon(
                                              Icons.info_outline,
                                              color: Get.isDarkMode
                                                  ? Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color
                                                  : Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                CustomTextFormField(
                                  outlineInputBorderRadius:
                                      Dimensions.paddingSizeExtraSmall,
                                  hintText: "",
                                  outlineInputBorderColor: Theme.of(
                                    context,
                                  ).hintColor,
                                  maxLines: 5,
                                  controller: createPostController
                                      .descriptionController,
                                  isShowBorder: true,
                                ),
                              ],
                            ),

                            if (createPostController
                                .additionalInstruction
                                .isNotEmpty)
                              ListView.builder(
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall,
                                      ),
                                      color: Get.isDarkMode
                                          ? Theme.of(
                                              context,
                                            ).hintColor.withValues(alpha: 0.1)
                                          : Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.05),
                                      border: Border.all(
                                        color: Get.isDarkMode
                                            ? Theme.of(
                                                context,
                                              ).textTheme.bodyMedium!.color!
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeDefault,
                                    ),
                                    margin: const EdgeInsets.only(
                                      top: Dimensions.paddingSizeSmall,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            createPostController
                                                .additionalInstruction[index],
                                            style: robotoRegular.copyWith(
                                              color: Get.isDarkMode
                                                  ? Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color
                                                  : Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                          width: Dimensions.paddingSizeDefault,
                                        ),
                                        GestureDetector(
                                          onTap: () => createPostController
                                              .removeAdditionalInstruction(
                                                index,
                                              ),
                                          child: Container(
                                            color: Get.isDarkMode
                                                ? Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium?.color
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.15),
                                            padding: const EdgeInsets.all(2),
                                            child: Center(
                                              child: Icon(
                                                Icons.close,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                itemCount: createPostController
                                    .additionalInstruction
                                    .length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              ),

                            const SizedBox(
                              height: Dimensions.paddingSizeExtraLarge,
                            ),
                            InkWell(
                              onTap: () =>
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const AdditionalInstructionDialog();
                                    },
                                  ).then(
                                    (value) =>
                                        createPostController
                                                .additionalInstructionController
                                                .text =
                                            '',
                                  ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    createPostController.selectedService != null
                                        ? 'add_additional_instruction'.tr
                                        : 'add_any_specific_requests_here'.tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Get.isDarkMode
                                          ? Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  Container(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.2),
                                    child: Icon(
                                      Icons.add,
                                      color: Get.isDarkMode
                                          ? Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: Get.height * 0.08),

                            createPostController.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : CustomButton(
                                    buttonText: "create_post".tr,
                                    height: ResponsiveHelper.isDesktop(context)
                                        ? 50
                                        : 40,
                                    width: 200,
                                    radius: Dimensions.radiusExtraMoreLarge,
                                    onPressed: () {
                                      _createPost(
                                        createPostController,
                                        scheduleController,
                                      );
                                    },
                                  ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        
        
        );
      },
    );
  }

  void _createPost(
    CreatePostController createPostController,
    ScheduleController scheduleController,
  ) {
    AddressModel? addressModel =
        Get.find<LocationController>().selectedAddress ??
        Get.find<LocationController>().getUserAddress();
    String? schedule = scheduleController.scheduleTime;
    ConfigModel configModel = Get.find<SplashController>().configModel;

    if (schedule == null &&
        scheduleController.selectedScheduleType != ScheduleType.asap) {
      customSnackBar(
        "select_your_preferable_booking_time".tr,
        type: ToasterMessageType.info,
      );
    } else if (scheduleController.selectedScheduleType ==
            ScheduleType.schedule &&
        configModel.content?.scheduleBookingTimeRestriction == 1 &&
        scheduleController.checkValidityOfTimeRestriction(
              Get.find<SplashController>().configModel.content!.advanceBooking!,
            ) !=
            null) {
      customSnackBar(
        scheduleController.checkValidityOfTimeRestriction(
          Get.find<SplashController>().configModel.content!.advanceBooking!,
        ),
      );
    } else if (addressModel == null) {
      customSnackBar('add_address_first'.tr, type: ToasterMessageType.info);
    } else if ((addressModel.contactPersonName == "null" ||
            addressModel.contactPersonName == null ||
            addressModel.contactPersonName!.isEmpty) ||
        (addressModel.contactPersonNumber == "null" ||
            addressModel.contactPersonNumber == null ||
            addressModel.contactPersonNumber!.isEmpty)) {
      customSnackBar(
        "please_input_contact_person_name_and_phone_number".tr,
        type: ToasterMessageType.info,
      );
    } else if (createPostController.selectedService == null) {
      customSnackBar(
        "select_your_desired_service".tr,
        type: ToasterMessageType.info,
      );
    } else if (createPostController.descriptionController.text.isEmpty) {
      customSnackBar(
        "enter_service_description".tr,
        type: ToasterMessageType.info,
      );
    } else {
      if (scheduleController.selectedScheduleType == ScheduleType.asap) {
        scheduleController.buildSchedule(scheduleType: ScheduleType.asap);
      }
      // NEW: pass targetProviderId through — null for open posts, set for targeted
      createPostController.createCustomPost(
        schedule,
        serviceAddress: addressModel,
        targetProviderId: widget.targetProviderId,
      );
    }
  }
}
*/

import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class CreatePostScreen extends StatefulWidget {
  // null = open post (from homepage banner)
  /// set  = targeted post (from athlete details page)
  final String? targetProviderId;
  const CreatePostScreen({super.key, this.targetProviderId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late JustTheController tooltipController;
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Get.find<CategoryController>().getCategoryList(false);
    Get.find<ScheduleController>().resetSchedule();
    tooltipController = JustTheController();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScheduleController>(
      builder: (scheduleController) {
        return Scaffold(
          drawer: ResponsiveHelper.isDesktop(context)
              ? const AddressSelectionDrawer()
              : null,
          endDrawer: ResponsiveHelper.isDesktop(context)
              ? const MenuDrawer()
              : null,
          appBar: CustomAppBar(
            title: "create_post".tr,
            isBackButtonExist: true,
            onBackPressed: () {
              if (Navigator.canPop(context)) {
                Get.back();
              } else {
                Get.offAllNamed(RouteHelper.getMainRoute("home"));
              }
            },
          ),
          body: FooterBaseView(
            child: WebShadowWrap(
              child: GetBuilder<CategoryController>(
                builder: (categoryController) {
                  return GetBuilder<CreatePostController>(
                    builder: (createPostController) {
                      return Stack(
                        children: [
                          // ── Scrollable campaign builder ───────────────────────────────
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              Dimensions.paddingSizeDefault,
                              Dimensions.paddingSizeDefault,
                              Dimensions.paddingSizeDefault,
                              110, // space for sticky action bar
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _BuilderCard(
                                  title: 'Timing',
                                  subtitle: 'Choose when this should happen',
                                  child: const ServiceSchedule(),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),
                                /* _BuilderCard(
                                  title: 'Location',
                                  subtitle: 'Where should it happen?',
                                  child: const CustomerLocationInfo(),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault, 
                                ),*/
                                _BuilderCard(
                                  title: 'Category & Service',
                                  subtitle: 'Pick what fits your campaign',
                                  child: _buildCategoryAndServicePicker(
                                    context,
                                    categoryController,
                                    createPostController,
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),
                                _BuilderCard(
                                  title: 'Campaign Brief',
                                  subtitle:
                                      'Explain what you want them to create',
                                  right: _InfoPill(
                                    text: 'Tips',
                                    onTap: () =>
                                        tooltipController.showTooltip(),
                                  ),
                                  child: _buildBriefSection(
                                    context,
                                    createPostController,
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),
                                _BuilderCard(
                                  title: 'Deliverables',
                                  subtitle: 'Use presets or add your own',
                                  child: _buildDeliverablesSection(
                                    context,
                                    createPostController,
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge,
                                ),
                              ],
                            ),
                          ),

                          // ── Sticky bottom actions ────────────────────────────────────
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _BottomActionBar(
                              isLoading: createPostController.isLoading,
                              onPreview: () => _openPreviewSheet(
                                context,
                                createPostController,
                                scheduleController,
                              ),
                              onSubmit: () => _createPost(
                                createPostController,
                                scheduleController,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isTargetedProposal() {
    return widget.targetProviderId != null &&
        widget.targetProviderId!.trim().isNotEmpty;
  }

  String _targetAthleteName() {
    if (_isTargetedProposal()) {
      return 'this athlete';
    }
    return 'the athlete';
  }

  // ───────────────────────────────────────────────────────────────────────────
  // UI sections
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildCategoryAndServicePicker(
    BuildContext context,
    CategoryController categoryController,
    CreatePostController createPostController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldTitle(title: "service_category".tr, requiredMark: true),
        Container(
          width: Get.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
            border: Border.all(
              color: Theme.of(context).disabledColor,
              width: 1,
            ),
            color: Theme.of(context).cardColor,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              elevation: 2,
              onTap: () => createPostController.updateSelectedService(null),
              hint: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: Text(
                  createPostController.selectedCategoryName == ''
                      ? "select_category".tr
                      : createPostController.selectedCategoryName,
                  style: robotoRegular.copyWith(
                    color: createPostController.selectedCategoryName == ''
                        ? Theme.of(
                            context,
                          ).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)
                        : Theme.of(
                            context,
                          ).textTheme.bodyLarge!.color!.withValues(alpha: 0.85),
                  ),
                ),
              ),
              icon: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: Icon(Icons.keyboard_arrow_down),
              ),
              items: categoryController.categoryList?.map((
                CategoryModel items,
              ) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(
                    items.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withValues(alpha: 0.85),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (CategoryModel? newValue) {
                createPostController.selectCategory(newValue?.id ?? "");
                showModalBottomSheet(
                  useRootNavigator: true,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) => SubcategoryServiceView(
                    categorySlug: newValue?.slug ?? "",
                  ),
                );
              },
            ),
          ),
        ),
        if (createPostController.selectedService != null) ...[
          const SizedBox(height: Dimensions.paddingSizeDefault),
          TextFieldTitle(title: "service".tr, requiredMark: false),
          _SelectedServiceTile(createPostController: createPostController),

          /*  if (_isTargetedProposal()) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),

            _MiniInfoCard(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: Theme.of(context).colorScheme.primary,
              backgroundTint: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.08),
              borderColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.16),
              text:
                  'You will be able to chat with ${_targetAthleteName()} after your proposal has been accepted.',
            ),

            const SizedBox(height: 10),

            _MiniInfoCard(
              icon: Icons.error_outline_rounded,
              iconColor: const Color(0xFFD97706),
              backgroundTint: const Color(0xFFD97706).withValues(alpha: 0.08),
              borderColor: const Color(0xFFD97706).withValues(alpha: 0.18),
              text:
                  'NCAA rules require that you receive a service or product in return for payment.',
            ),
          ], */
        ],
      ],
    );
  }

  Widget _buildBriefSection(
    BuildContext context,
    CreatePostController createPostController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt chips (campaign-builder vibe)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PromptChip(
              label: 'Goal',
              onTap: () => _appendToBrief(createPostController, 'Goal: '),
            ),
            _PromptChip(
              label: 'Key message',
              onTap: () =>
                  _appendToBrief(createPostController, 'Key message: '),
            ),
            _PromptChip(
              label: 'Must include',
              onTap: () =>
                  _appendToBrief(createPostController, 'Must include: '),
            ),
            _PromptChip(
              label: 'Tone',
              onTap: () => _appendToBrief(createPostController, 'Tone: '),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Keep your tooltip + title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFieldTitle(
                title: "provide_service_description".tr,
                requiredMark: false,
              ),
            ),
            JustTheTooltip(
              backgroundColor: Theme.of(context).primaryColorDark,
              controller: tooltipController,
              preferredDirection: AxisDirection.up,
              borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.radiusExtraLarge),
              ),
              tailLength: 14,
              tailBaseWidth: 20,
              content: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Text(
                  "create_service_request_instruction".tr,
                  style: robotoRegular.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
              child: IconButton(
                onPressed: () => tooltipController.showTooltip(),
                icon: Icon(
                  Icons.info_outline,
                  color: Get.isDarkMode
                      ? Theme.of(context).textTheme.bodyMedium?.color
                      : Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),

        CustomTextFormField(
          outlineInputBorderRadius: Dimensions.paddingSizeExtraSmall,
          hintText: "",
          outlineInputBorderColor: Theme.of(context).hintColor,
          maxLines: 6,
          controller: createPostController.descriptionController,
          isShowBorder: true,
        ),
      ],
    );
  }

  void _appendToBrief(CreatePostController c, String text) {
    final current = c.descriptionController.text;
    if (current.trim().isEmpty) {
      c.descriptionController.text = text;
    } else if (current.endsWith('\n')) {
      c.descriptionController.text = '$current$text';
    } else {
      c.descriptionController.text = '$current\n$text';
    }
    c.descriptionController.selection = TextSelection.collapsed(
      offset: c.descriptionController.text.length,
    );
  }

  Widget _buildDeliverablesSection(
    BuildContext context,
    CreatePostController createPostController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Presets
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _DeliverablePreset(
                label: 'IG Story',
                onTap: () =>
                    _openDeliverableDialog(context, prefill: 'IG Story ×1'),
              ),
              _DeliverablePreset(
                label: 'IG Post',
                onTap: () =>
                    _openDeliverableDialog(context, prefill: 'IG Post ×1'),
              ),
              _DeliverablePreset(
                label: 'Reel / TikTok',
                onTap: () =>
                    _openDeliverableDialog(context, prefill: 'Reel/TikTok ×1'),
              ),
              _DeliverablePreset(
                label: 'YouTube',
                onTap: () => _openDeliverableDialog(
                  context,
                  prefill: 'YouTube Short ×1',
                ),
              ),
              _DeliverablePreset(
                label: 'Appearance',
                onTap: () => _openDeliverableDialog(
                  context,
                  prefill: 'Appearance (1 hour)',
                ),
              ),
              _DeliverablePreset(
                label: 'Other',
                onTap: () => _openDeliverableDialog(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Render deliverables
        if (createPostController.additionalInstruction.isNotEmpty)
          ListView.builder(
            itemCount: createPostController.additionalInstruction.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final text = createPostController.additionalInstruction[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.14),
                  ),
                  boxShadow: Get.find<ThemeController>().darkTheme
                      ? null
                      : cardShadow,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _deliverableIcon(text),
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => createPostController
                          .removeAdditionalInstruction(index),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              'Add deliverables like IG Story, Reel/TikTok, Appearance…',
              style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
            ),
          ),

        const SizedBox(height: Dimensions.paddingSizeDefault),

        Center(
          child: InkWell(
            onTap: () => _openDeliverableDialog(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  createPostController.selectedService != null
                      ? 'add_additional_instruction'.tr
                      : 'add_any_specific_requests_here'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Get.isDarkMode
                        ? Theme.of(context).textTheme.bodyMedium?.color
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Get.isDarkMode
                        ? Theme.of(context).textTheme.bodyMedium?.color
                        : Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: Dimensions.paddingSizeLarge),

        if (_isTargetedProposal()) ...[
          _MiniInfoCard(
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: Theme.of(context).colorScheme.primary,
            backgroundTint: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),
            borderColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.16),
            text:
                'You will be able to chat with this athlete after your proposal has been accepted.',
          ),
          const SizedBox(height: 10),
        ],

        _MiniInfoCard(
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFD97706),
          backgroundTint: const Color(0xFFD97706).withValues(alpha: 0.08),
          borderColor: const Color(0xFFD97706).withValues(alpha: 0.18),
          text:
              'NCAA rules require that you receive a service or product in return for payment.',
        ),
      ],
    );
  }

  IconData _deliverableIcon(String text) {
    final t = text.toLowerCase();
    if (t.contains('tiktok')) return Icons.music_note;
    if (t.contains('reel')) return Icons.video_library_outlined;
    if (t.contains('youtube')) return Icons.smart_display_outlined;
    if (t.contains('ig') || t.contains('instagram')) {
      return Icons.camera_alt_outlined;
    }
    if (t.contains('appearance') || t.contains('event')) {
      return Icons.event_available_outlined;
    }
    return Icons.checklist_outlined;
  }

  Future<void> _openDeliverableDialog(
    BuildContext context, {
    String? prefill,
  }) async {
    final ctrl = Get.find<CreatePostController>();

    // Prefill the existing input controller used by AdditionalInstructionDialog
    ctrl.additionalInstructionController.text = prefill ?? '';

    await showDialog(
      context: context,
      builder: (_) => const AdditionalInstructionDialog(),
    );

    // Clear after
    ctrl.additionalInstructionController.text = '';
  }

  void _openPreviewSheet(
    BuildContext context,
    CreatePostController createPostController,
    ScheduleController scheduleController,
  ) {
    final deliverables = createPostController.additionalInstruction;
    final brief = createPostController.descriptionController.text.trim();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 32,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── Drag Handle ─────────────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),

                  // ── Header ─────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.preview_outlined,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Campaign Preview',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Review before submitting',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.dividerColor.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    color: theme.dividerColor.withValues(alpha: 0.12),
                    height: 1,
                  ),

                  // ── Scrollable Content ─────────────────────────────────────
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // ── Quick Info Cards ───────────────────────────────────
                        Row(
                          children: [
                            _PreviewInfoCard(
                              icon: Icons.category_outlined,
                              label: 'Category',
                              value:
                                  createPostController
                                      .selectedCategoryName
                                      .isEmpty
                                  ? 'Not selected'
                                  : createPostController.selectedCategoryName,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            _PreviewInfoCard(
                              icon: Icons.schedule_outlined,
                              label: 'Timing',
                              value:
                                  scheduleController.selectedScheduleType ==
                                      ScheduleType.asap
                                  ? 'ASAP'
                                  : (scheduleController.scheduleTime ??
                                        'Not set'),
                              color: const Color(0xFF10B981),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Service Section ──────────────────────────────────
                        if (createPostController.selectedService != null) ...[
                          _PreviewSectionHeader(
                            icon: Icons.design_services_outlined,
                            title: 'Selected Service',
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.06,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CustomImage(
                                    image:
                                        '${createPostController.selectedService?.thumbnailFullPath}',
                                    height: 56,
                                    width: 56,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        createPostController
                                                .selectedService
                                                ?.name ??
                                            '',
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        createPostController
                                            .selectedCategoryName,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: theme.hintColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // ── Deliverables Section ─────────────────────────────
                        _PreviewSectionHeader(
                          icon: Icons.checklist_outlined,
                          title: 'Deliverables',
                          badge: deliverables.isNotEmpty
                              ? '${deliverables.length}'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        if (deliverables.isEmpty)
                          _PreviewEmptyState(
                            message: 'No deliverables added yet',
                            icon: Icons.inventory_2_outlined,
                          )
                        else
                          Column(
                            children: deliverables.asMap().entries.map((entry) {
                              final index = entry.key;
                              final d = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color:
                                      colorScheme.surfaceContainerHighest
                                          ?.withValues(alpha: 0.4) ??
                                      theme.cardColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: _getDeliverableColor(
                                          d,
                                        ).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        _deliverableIcon(d),
                                        size: 20,
                                        color: _getDeliverableColor(d),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        d,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '#${index + 1}',
                                        style: robotoMedium.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 24),

                        // ── Brief Section ────────────────────────────────────
                        _PreviewSectionHeader(
                          icon: Icons.description_outlined,
                          title: 'Campaign Brief',
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: brief.isEmpty
                                ? theme.dividerColor.withValues(alpha: 0.05)
                                : colorScheme.surfaceContainerHighest
                                          ?.withValues(alpha: 0.4) ??
                                      theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: brief.isEmpty
                                  ? theme.dividerColor.withValues(alpha: 0.2)
                                  : theme.dividerColor.withValues(alpha: 0.1),
                            ),
                          ),
                          child: brief.isEmpty
                              ? _PreviewEmptyState(
                                  message: 'No brief provided',
                                  icon: Icons.edit_note_outlined,
                                  compact: true,
                                )
                              : Text(
                                  brief,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    height: 1.6,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.9,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),

                  // ── Bottom Actions ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: Text('Edit', style: robotoMedium),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _createPost(
                                  createPostController,
                                  scheduleController,
                                );
                              },
                              icon: const Icon(Icons.send_outlined, size: 18),
                              label: Text(
                                'Submit Campaign',
                                style: robotoMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper method for deliverable colors
  Color _getDeliverableColor(String text) {
    final t = text.toLowerCase();
    if (t.contains('tiktok')) return const Color(0xFF000000);
    if (t.contains('reel')) return const Color(0xFFE1306C);
    if (t.contains('youtube')) return const Color(0xFFFF0000);
    if (t.contains('ig') || t.contains('instagram') || t.contains('story')) {
      return const Color(0xFFE1306C);
    }
    if (t.contains('appearance') || t.contains('event')) {
      return const Color(0xFF8B5CF6);
    }
    return const Color(0xFF3B82F6);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Original create logic (unchanged)
  // ───────────────────────────────────────────────────────────────────────────

  void _createPost(
    CreatePostController createPostController,
    ScheduleController scheduleController,
  ) {
    AddressModel? addressModel =
        Get.find<LocationController>().selectedAddress ??
        Get.find<LocationController>().getUserAddress();
    String? schedule = scheduleController.scheduleTime;
    ConfigModel configModel = Get.find<SplashController>().configModel;

    if (schedule == null &&
        scheduleController.selectedScheduleType != ScheduleType.asap) {
      customSnackBar(
        "select_your_preferable_booking_time".tr,
        type: ToasterMessageType.info,
      );
    } else if (scheduleController.selectedScheduleType ==
            ScheduleType.schedule &&
        configModel.content?.scheduleBookingTimeRestriction == 1 &&
        scheduleController.checkValidityOfTimeRestriction(
              Get.find<SplashController>().configModel.content!.advanceBooking!,
            ) !=
            null) {
      customSnackBar(
        scheduleController.checkValidityOfTimeRestriction(
          Get.find<SplashController>().configModel.content!.advanceBooking!,
        ),
      );
    } else if (addressModel == null) {
      customSnackBar('add_address_first'.tr, type: ToasterMessageType.info);
    } else if ((addressModel.contactPersonName == "null" ||
            addressModel.contactPersonName == null ||
            addressModel.contactPersonName!.isEmpty) ||
        (addressModel.contactPersonNumber == "null" ||
            addressModel.contactPersonNumber == null ||
            addressModel.contactPersonNumber!.isEmpty)) {
      customSnackBar(
        "please_input_contact_person_name_and_phone_number".tr,
        type: ToasterMessageType.info,
      );
    } else if (createPostController.selectedService == null) {
      customSnackBar(
        "select_your_desired_service".tr,
        type: ToasterMessageType.info,
      );
    } else if (createPostController.descriptionController.text.isEmpty) {
      customSnackBar(
        "enter_service_description".tr,
        type: ToasterMessageType.info,
      );
    } else {
      if (scheduleController.selectedScheduleType == ScheduleType.asap) {
        scheduleController.buildSchedule(scheduleType: ScheduleType.asap);
      }
      createPostController.createCustomPost(
        schedule,
        serviceAddress: addressModel,
        targetProviderId: widget.targetProviderId,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small UI components used by CreatePostScreen
// ─────────────────────────────────────────────────────────────────────────────

class _BuilderCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? right;

  const _BuilderCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
        ),
        boxShadow: Get.find<ThemeController>().darkTheme ? null : cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (right != null) right!,
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          child,
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PromptChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.18),
          ),
        ),
        child: Text(
          label,
          style: robotoMedium.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
      ),
    );
  }
}

class _DeliverablePreset extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DeliverablePreset({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
            ),
          ),
          child: Text(label, style: robotoMedium),
        ),
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundTint;
  final Color borderColor;
  final String text;

  const _MiniInfoCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundTint,
    required this.borderColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: backgroundTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                height: 1.4,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedServiceTile extends StatelessWidget {
  final CreatePostController createPostController;

  const _SelectedServiceTile({required this.createPostController});

  @override
  Widget build(BuildContext context) {
    final service = createPostController.selectedService!;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImage(
              image: '${service.thumbnailFullPath}',
              height: 54,
              width: 54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              service.name ?? "",
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _InfoPill({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: robotoMedium.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPreview;
  final VoidCallback onSubmit;

  const _BottomActionBar({
    required this.isLoading,
    required this.onPreview,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onPreview,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.35),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Preview'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: onSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text("create_post".tr),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final String title;
  final String value;

  const _PreviewTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: robotoMedium.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// New helper widgets for the preview
class _PreviewInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _PreviewInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;

  const _PreviewSectionHeader({
    required this.icon,
    required this.title,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge!,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PreviewEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool compact;

  const _PreviewEmptyState({
    required this.message,
    required this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return compact
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: theme.hintColor),
              const SizedBox(width: 8),
              Text(
                message,
                style: robotoRegular.copyWith(
                  color: theme.hintColor,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: theme.hintColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: robotoRegular.copyWith(
                  color: theme.hintColor,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ],
          );
  }
}
