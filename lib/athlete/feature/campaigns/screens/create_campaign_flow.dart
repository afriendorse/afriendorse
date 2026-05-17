// lib/athlete/feature/campaigns/screens/create_campaign_flow.dart

import 'dart:io';
import 'package:afriendorse/athlete/feature/campaigns/service/campaign_deep_link_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/campaigns/model/campaign_model.dart';
import 'package:afriendorse/athlete/feature/campaigns/controller/campaign_controller.dart';
import 'package:afriendorse/athlete/feature/groups/controller/group_controller.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/campaigns/widgets/campaign_widgets.dart';
import 'package:intl/intl.dart';

// Entry point — call this to open the wizard
void showCreateCampaignFlow(BuildContext context) {
  // Ensure the controller is registered before the wizard tries to find it
  if (!Get.isRegistered<AltCampaignController>()) {
    Get.put(AltCampaignController());
  } else {
    // Already registered — reset it so the wizard starts fresh every time
    Get.find<AltCampaignController>().reset();
  }

  Get.bottomSheet(
    const _CreateCampaignWizard(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    ignoreSafeArea: false,
  );
}

class _CreateCampaignWizard extends StatefulWidget {
  const _CreateCampaignWizard();

  @override
  State<_CreateCampaignWizard> createState() => _CreateCampaignWizardState();
}

class _CreateCampaignWizardState extends State<_CreateCampaignWizard>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  late AltCampaignController _ctrl;
  late AnimationController _progressAnim;
  late Animation<double> _progressValue;

  int _currentStep = 0;
  final int _totalSteps = 4;
  bool _celebrating = false;

  // Available sports/tags for chips
  final List<String> _availableTags = [
    'Football',
    'Basketball',
    'Athletics',
    'Swimming',
    'Tennis',
    'Boxing',
    'Cycling',
    'Wrestling',
    'Volleyball',
    'Rugby',
    'Training Equipment',
    'Competition Fees',
    'Travel',
    'Medical',
    'Education',
    'Coaching',
    'Kit & Gear',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AltCampaignController>();

    _progressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressValue = Tween<double>(
      begin: 0,
      end: 1 / _totalSteps,
    ).animate(CurvedAnimation(parent: _progressAnim, curve: Curves.easeOut));
    _progressAnim.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _progressAnim.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _progressValue = Tween<double>(
        begin: _progressValue.value,
        end: (_currentStep + 1) / _totalSteps,
      ).animate(CurvedAnimation(parent: _progressAnim, curve: Curves.easeOut));
      _progressAnim
        ..reset()
        ..forward();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    final id = await _ctrl.createCampaign();
    if (id != null) {
      final goal = double.tryParse(_ctrl.goalController.text) ?? 0;

      final campaign = CampaignModel(
        id: id,
        title: _ctrl.titleController.text.trim(),
        description: _ctrl.descriptionController.text.trim(),
        story: _ctrl.storyController.text.trim(),
        type: _ctrl.campaignType.value,
        status: CampaignStatus.active,
        creatorId: _ctrl.currentUserId.trim().toLowerCase(), // ← fix here
        creatorName: _ctrl.currentUserName,
        goalAmount: goal,
        raisedAmount: 0,
        donorCount: 0,
        recurringDonorCount: 0,
        mediaUrls: const [],
        startDate: DateTime.now(),
        endDate: _ctrl.campaignEndDate.value,
        createdAt: DateTime.now(),
        milestones: CampaignModel.autoMilestones(goal),
        viewCount: 0,
        tags: List<String>.from(_ctrl.selectedTags),
        allowAnonymous: _ctrl.allowAnonymous.value,
        minimumDonation:
            double.tryParse(_ctrl.minDonationController.text) ?? 500,
      );

      await _showLaunchSuccess(campaign);
      Get.back();
    }
  }

  Future<void> _showLaunchSuccess(CampaignModel campaign) async {
    setState(() => _celebrating = true);
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) =>
          _LaunchSuccessDialog(campaign: campaign), // ← pass campaign
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return ConfettiBurst(
      trigger: _celebrating,
      child: Container(
        height: screenH * 0.92,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Progress
            _buildProgressBar(),
            // Steps
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1TypeCover(ctrl: _ctrl, tags: _availableTags),
                  _Step2BasicInfo(ctrl: _ctrl),
                  _Step3Story(ctrl: _ctrl),
                  _Step4GoalReview(ctrl: _ctrl),
                ],
              ),
            ),
            // Navigation
            _buildNavRow(context),
          ],
        ),
      ),
    );
  }

  //
  Widget _buildHeader(BuildContext context) {
    final labels = [
      'Type & Cover',
      'Basic Info',
      'Your Story',
      'Goal & Review',
    ];
    final icons = ['🎯', '📝', '📖', '🚀'];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF045F25).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              icons[_currentStep],
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels[_currentStep],
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (i) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i <= _currentStep
                        ? const Color(0xFF045F25)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNavRow(BuildContext context) {
    final isLast = _currentStep == _totalSteps - 1;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Obx(
                () => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: _ctrl.isCreating.value
                        ? null
                        : (isLast ? _submit : _nextStep),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF045F25),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFF045F25,
                      ).withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: _ctrl.isCreating.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            isLast ? '🚀 Launch Campaign' : 'Continue',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Step 1 — Type & Cover
// ─────────────────────────────────────────────

class _Step1TypeCover extends StatefulWidget {
  final AltCampaignController ctrl;
  final List<String> tags;

  const _Step1TypeCover({required this.ctrl, required this.tags});

  @override
  State<_Step1TypeCover> createState() => _Step1TypeCoverState();
}

class _Step1TypeCoverState extends State<_Step1TypeCover> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign type
          const Text(
            'What type of campaign?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Row(
              children: CampaignType.values.map((t) {
                final selected = widget.ctrl.campaignType.value == t;
                final isGroup = t == CampaignType.group;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.ctrl.campaignType.value = t,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(right: !isGroup ? 8 : 0),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF045F25)
                            : Colors.grey.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF045F25)
                              : Colors.grey.withOpacity(0.15),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isGroup ? '🏟' : '🧑',
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isGroup
                                ? 'Group\nCampaign'
                                : 'Individual\nCampaign',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isGroup ? 'For your group' : 'For yourself',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white70
                                  : Colors.grey.shade500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Group selector (if group type)
          Obx(() {
            if (widget.ctrl.campaignType.value != CampaignType.group) {
              return const SizedBox.shrink();
            }
            GroupController? groupCtrl;
            try {
              groupCtrl = Get.find<GroupController>();
            } catch (_) {}
            if (groupCtrl == null || groupCtrl.myGroups.isEmpty) {
              return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Text(
                  '⚠️ You need to be a group admin to create a group campaign. Create or join a group first.',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                const Text(
                  'Select your group',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: widget.ctrl.selectedGroupId.value.isNotEmpty == true
                      ? widget.ctrl.selectedGroupId.value
                      : null,
                  hint: const Text('Choose a group'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.group),
                  ),
                  items: groupCtrl.myGroups
                      .where((g) => g.creatorId == groupCtrl!.currentUserId)
                      .map(
                        (g) =>
                            DropdownMenuItem(value: g.id, child: Text(g.name)),
                      )
                      .toList(),
                  onChanged: (id) {
                    widget.ctrl.selectedGroupId.value = id ?? '';
                    final group = groupCtrl!.myGroups.firstWhereOrNull(
                      (g) => g.id == id,
                    );
                    widget.ctrl.selectedGroupName.value = group?.name ?? '';
                  },
                ),
              ],
            );
          }),

          const SizedBox(height: 20),

          // Cover photo
          const Text(
            'Campaign cover photo',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Obx(
            () => GestureDetector(
              onTap: widget.ctrl.pickCoverImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.ctrl.coverImageFile.value != null
                        ? const Color(0xFF045F25)
                        : Colors.grey.shade300,
                    width: widget.ctrl.coverImageFile.value != null ? 2 : 1,
                  ),
                  image: widget.ctrl.coverImageFile.value != null
                      ? DecorationImage(
                          image: FileImage(widget.ctrl.coverImageFile.value!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.ctrl.coverImageFile.value == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 36,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add a cover photo',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'A great image increases donations by 3×',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tags
          const Text(
            'Campaign tags',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Help supporters find your campaign',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.tags.map((tag) {
                final selected = widget.ctrl.selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    if (selected) {
                      widget.ctrl.selectedTags.remove(tag);
                    } else if (widget.ctrl.selectedTags.length < 5) {
                      widget.ctrl.selectedTags.add(tag);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF045F25)
                          : Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF045F25)
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Step 2 — Basic Info
// ─────────────────────────────────────────────

class _Step2BasicInfo extends StatelessWidget {
  final AltCampaignController ctrl;
  const _Step2BasicInfo({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel('Campaign title *'),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl.titleController,
            maxLength: 80,
            decoration: _inputDeco(
              'e.g. "Help me compete at the National Championships"',
              Icons.title,
            ),
          ),
          const SizedBox(height: 4),
          _FieldLabel('Short description *'),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl.descriptionController,
            maxLines: 3,
            maxLength: 200,
            decoration: _inputDeco(
              'A brief summary shown on the campaign card',
              Icons.description_outlined,
            ),
          ),
          const SizedBox(height: 4),
          _FieldLabel('Campaign end date *'),
          const SizedBox(height: 8),
          Obx(
            () => GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: ctrl.campaignEndDate.value,
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF045F25),
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) ctrl.campaignEndDate.value = picked;
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF045F25),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${ctrl.campaignEndDate.value.day}/${ctrl.campaignEndDate.value.month}/${ctrl.campaignEndDate.value.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      '${ctrl.campaignEndDate.value.difference(DateTime.now()).inDays} days',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Anonymous donations toggle
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.withOpacity(0.12)),
            ),
            child: Obx(
              () => Row(
                children: [
                  const Text('🦸', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Allow anonymous donations',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Supporters can donate without showing their name',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: ctrl.allowAnonymous.value,
                    onChanged: (v) => ctrl.allowAnonymous.value = v,
                    activeColor: const Color(0xFF045F25),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF045F25), width: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Step 3 — Story
// ─────────────────────────────────────────────

class _Step3Story extends StatelessWidget {
  final AltCampaignController ctrl;
  const _Step3Story({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF045F25).withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: const [
                Text('💡', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'A compelling story gets 4× more donations. Share your journey, your challenges, and what this campaign means to you.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FieldLabel('Your campaign story'),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl.storyController,
            maxLines: 12,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText:
                  'Tell supporters who you are, why you\'re running this campaign, '
                  'and exactly how the funds will be used...',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF045F25),
                  width: 2,
                ),
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Step 4 — Goal & Review
// ─────────────────────────────────────────────
//
//  Uses StatefulWidget + TextEditingController.addListener so that the
//  milestone preview and summary card rebuild reactively as the user types.
//  Obx() cannot watch plain TextEditingControllers — that was the bug.

class _Step4GoalReview extends StatefulWidget {
  final AltCampaignController ctrl;
  const _Step4GoalReview({required this.ctrl});

  @override
  State<_Step4GoalReview> createState() => _Step4GoalReviewState();
}

class _Step4GoalReviewState extends State<_Step4GoalReview> {
  // Cached so we don't re-parse on every keystroke unnecessarily
  double _goal = 0;

  @override
  void initState() {
    super.initState();
    // Seed initial value
    _goal = double.tryParse(widget.ctrl.goalController.text) ?? 0;
    // Listen to goal field so milestone preview + summary update live
    widget.ctrl.goalController.addListener(_onGoalChanged);
    // Also listen to title so summary card updates
    widget.ctrl.titleController.addListener(_rebuild);
  }

  void _onGoalChanged() {
    final parsed = double.tryParse(widget.ctrl.goalController.text) ?? 0;
    if (parsed != _goal) {
      setState(() => _goal = parsed);
    }
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.ctrl.goalController.removeListener(_onGoalChanged);
    widget.ctrl.titleController.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel('Fundraising goal (${Currency.symbol}) *'),
          const SizedBox(height: 8),
          TextField(
            controller: widget.ctrl.goalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '500,000',
              prefixIcon: const Icon(Icons.flag_outlined),
              prefixText: '${Currency.symbol} ',
              prefixStyle: TextStyle(
                color: Colors.grey[400], // Matches hint text color
                fontSize: 16,
              ),
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF045F25),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _FieldLabel('Minimum donation (${Currency.symbol})'),
          const SizedBox(height: 8),
          TextField(
            controller: widget.ctrl.minDonationController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '500',
              prefixIcon: const Icon(Icons.attach_money),
              // prefixText: '${Currency.symbol} ',
              prefixStyle: TextStyle(
                color: Colors.grey[400], // Matches hint text color
                fontSize: 16,
              ),
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF045F25),
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Milestone preview ──────────────────────
          // Rebuilds via setState when _goal changes — no Obx needed
          if (_goal > 0) ...[
            const Text(
              '🏅 Auto-generated milestones',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...CampaignModel.autoMilestones(
              _goal,
            ).map((m) => _ReviewMilestone(milestone: m)),
            const SizedBox(height: 14),
          ],

          // ── Campaign summary card ──────────────────
          // Reads plain controller .text directly — safe inside setState build
          _buildSummaryCard(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final ctrl = widget.ctrl;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF056B2A), Color(0xFF045F25)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF045F25).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🚀', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Campaign Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: 'Title',
            value: ctrl.titleController.text.isNotEmpty
                ? ctrl.titleController.text
                : '—',
          ),
          // For campaign type we DO use Obx because ctrl.campaignType is Rx
          Obx(
            () => _SummaryRow(
              label: 'Type',
              value: ctrl.campaignType.value == CampaignType.group
                  ? 'Group Campaign'
                  : 'Individual Campaign',
            ),
          ),
          _SummaryRow(
            label: 'Goal',
            value: _goal > 0 ? '${Currency.symbol}${_fmt(_goal)}' : '—',
          ),
          // campaignEndDate is Rx — safe in Obx
          Obx(
            () => _SummaryRow(
              label: 'End Date',
              value:
                  '${ctrl.campaignEndDate.value.day}/${ctrl.campaignEndDate.value.month}/${ctrl.campaignEndDate.value.year}',
            ),
          ),
          // selectedTags is RxList — safe in Obx
          Obx(
            () => _SummaryRow(
              label: 'Tags',
              value: ctrl.selectedTags.isNotEmpty
                  ? ctrl.selectedTags.join(', ')
                  : 'None',
            ),
          ),
          // allowAnonymous is RxBool — safe in Obx
          Obx(
            () => _SummaryRow(
              label: 'Anon Donations',
              value: ctrl.allowAnonymous.value ? 'Allowed' : 'Disabled',
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    final formatter = NumberFormat('#,##0.##');
    if (v >= 1000000) return '${formatter.format(v / 1000000)}M';
    if (v >= 1000) return '${formatter.format(v / 1000)}K';
    return formatter.format(v);
  }
}

// ─── Small shared widgets ─────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    );
  }
}

class _ReviewMilestone extends StatelessWidget {
  final CampaignMilestone milestone;
  const _ReviewMilestone({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.star_border, size: 14, color: Color(0xFFFFD700)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(milestone.title, style: const TextStyle(fontSize: 12)),
          ),
          Text(
            '${Currency.symbol}${_fmt(milestone.targetAmount)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Color(0xFF045F25),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Launch Success Dialog  (shown after campaign created)
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
//  Launch Success Dialog  (shown after campaign created)
//  UPDATED: Added share button so athletes can immediately share
// ─────────────────────────────────────────────

class _LaunchSuccessDialog extends StatefulWidget {
  final CampaignModel campaign; // ← NEW

  const _LaunchSuccessDialog({required this.campaign}); // ← NEW

  @override
  State<_LaunchSuccessDialog> createState() => _LaunchSuccessDialogState();
}

class _LaunchSuccessDialogState extends State<_LaunchSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _shareCampaign() {
    CampaignDeepLinkService.shareCampaign(
      campaignId: widget.campaign.id,
      campaignTitle: widget.campaign.title,
      creatorName: widget.campaign.creatorName,
      coverImage: widget.campaign.coverImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF045F25).withOpacity(0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated trophy
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF056B2A), Color(0xFF033D18)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF045F25).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🚀', style: TextStyle(fontSize: 42)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Campaign Launched!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF045F25),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Your campaign is now live.\nShare it with your supporters to start raising funds!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // ── SHARE BUTTON ─────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _shareCampaign,
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text(
                      'Share Campaign',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF045F25),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                      shadowColor: const Color(0xFF045F25).withOpacity(0.4),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── SKIP / CLOSE ─────────────────────────────
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    'Maybe later',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
