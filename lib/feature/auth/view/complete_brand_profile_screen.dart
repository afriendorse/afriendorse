import 'dart:typed_data';
import 'package:afriendorse/feature/auth/repository/firestore_sync_service.dart';
import 'package:afriendorse/feature/auth/repository/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

class CompleteBrandProfileScreen extends StatefulWidget {
  final String email;
  final String? redirectUrl;

  const CompleteBrandProfileScreen({
    super.key,
    required this.email,
    this.redirectUrl,
  });

  @override
  State<CompleteBrandProfileScreen> createState() =>
      _CompleteBrandProfileScreenState();
}

class _CompleteBrandProfileScreenState
    extends State<CompleteBrandProfileScreen> {
  final brandNameController = TextEditingController();
  final industryController = TextEditingController();
  final cacNumberController = TextEditingController();
  final brandDescriptionController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  PlatformFile? selectedFile;
  bool isLoading = false;

  static const Color primaryGreen = Color(0xFF045F25);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGreen = Color(0xFFE8F5E9);

  @override
  void dispose() {
    brandNameController.dispose();
    industryController.dispose();
    cacNumberController.dispose();
    brandDescriptionController.dispose();
    super.dispose();
  }

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  Future<void> submitBrandProfile() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedFile == null || selectedFile!.bytes == null) {
      customSnackBar('Please upload CAC document');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final Uint8List fileBytes = selectedFile!.bytes!;
      final String fileName = selectedFile!.name;

      final String downloadUrl = await StorageService.uploadBrandDocument(
        email: widget.email,
        fileBytes: fileBytes,
        fileName: fileName,
      );

      await FirestoreSyncService.completeBrandProfile(
        email: widget.email,
        brandName: brandNameController.text.trim(),
        industry: industryController.text.trim(),
        cacNumber: cacNumberController.text.trim(),
        brandDescription: brandDescriptionController.text.trim(),
        cacDocumentUrl: downloadUrl,
      );

      customSnackBar(
        'Brand profile submitted successfully. Verification is pending.',
        type: ToasterMessageType.success,
      );

      Get.offAllNamed(RouteHelper.home);
    } catch (e) {
      customSnackBar('Failed to complete brand profile: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget _buildUploadBox() {
    return InkWell(
      onTap: pickDocument,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lightGreen,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryGreen.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.upload_file_rounded,
              color: primaryGreen,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              selectedFile == null ? 'Upload CAC Document' : selectedFile!.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: pureBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (selectedFile == null) ...[
              const SizedBox(height: 4),
              Text(
                'Accepted: JPG, PNG, PDF',
                style: TextStyle(
                  color: pureBlack.withOpacity(0.55),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : submitBrandProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: pureWhite,
                  strokeWidth: 2.4,
                ),
              )
            : const Text(
                'Submit Brand Profile',
                style: TextStyle(
                  color: pureWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureWhite,
      appBar: AppBar(
        backgroundColor: pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: primaryGreen),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Complete Brand Profile',
          style: TextStyle(color: pureBlack),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextField(
                  title: 'Brand Name',
                  hintText: 'Enter brand name',
                  controller: brandNameController,
                  onValidate: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Brand name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  title: 'Industry',
                  hintText: 'Enter industry',
                  controller: industryController,
                  onValidate: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Industry is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  title: 'CAC Number',
                  hintText: 'Enter CAC number',
                  controller: cacNumberController,
                  onValidate: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'CAC number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  title: 'Brand Description',
                  hintText: 'Tell us about your brand',
                  controller: brandDescriptionController,
                  maxLines: 4,
                  onValidate: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Brand description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildUploadBox(),
                const SizedBox(height: 28),

                _buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
