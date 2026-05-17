import 'package:afriendorse/athlete/feature/settings/business/model/picked_identity_image_model.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class IdentityController extends GetxController implements GetxService {
  String? _selectedIdentityType;
  String? get selectedIdentityType => _selectedIdentityType;

  List<PickedIdentityImageModel?>? _replacedIdentityImages;
  List<PickedIdentityImageModel?>? get replacedIdentityImages =>
      _replacedIdentityImages;

  List<XFile?>? _identityImages;
  List<XFile?>? get identityImages => _identityImages;

  List<String?> _currentIdentityImages = [];
  List<String?> get currentIdentityImages => _currentIdentityImages;

  List<String?> _deletedIdentityImages = [];
  List<String?> get deletedIdentityImages => _deletedIdentityImages;

  void onChangeIdentityType(String? type, {bool isUpdate = true}) {
    _selectedIdentityType = type;
    if (isUpdate) {
      update();
    }
  }

  void initializeCurrentImage(List<String?> currentImages) =>
      _currentIdentityImages = currentImages.toList();

  void removeCurrentImage(int index) {
    _deletedIdentityImages.add(_currentIdentityImages[index]);
    _currentIdentityImages.removeAt(index);
    initializeCurrentImage(_currentIdentityImages);
    update();
  }

  void identityImagePickInitialize() {
    _identityImages = [];
    _deletedIdentityImages = [];
    _replacedIdentityImages = List.generate(
      _currentIdentityImages.length,
      (index) => null,
      growable: true,
    );
  }

  void pickIdentityImage({int? index, bool isRemoved = false}) async {
    if (isRemoved) {
      _identityImages?.removeAt(index!);
    } else {
      final XFile pickedImage = (await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      ))!;
      final double imageSize = await ImageSize.getImageSizeFromXFile(
        pickedImage,
      );

      if (imageSize > AppConstants.limitOfPickedImageSizeInMB) {
        showCustomSnackBar(
          "image_size_greater_than".tr,
          type: ToasterMessageType.info,
        );
      } else if (pickedImage.path.contains('.gif')) {
        showCustomSnackBar(
          'can_not_upload_gif_file'.tr,
          type: ToasterMessageType.info,
        );
      } else {
        if (index != null) {
          _identityImages?[index] = pickedImage;
        } else {
          _identityImages?.add(pickedImage);
        }
      }
    }
    update();
  }

  void onReplacePickIdentityImage({
    required int index,
    bool isRemoved = false,
  }) async {
    if (isRemoved) {
      _replacedIdentityImages?[index] = null;
    } else {
      final XFile pickedImage = (await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      ))!;
      final double imageSize = await ImageSize.getImageSizeFromXFile(
        pickedImage,
      );

      if (imageSize > AppConstants.limitOfPickedImageSizeInMB) {
        showCustomSnackBar(
          "image_size_greater_than".tr,
          type: ToasterMessageType.info,
        );
      } else if (pickedImage.path.contains('.gif')) {
        showCustomSnackBar(
          'can_not_upload_gif_file'.tr,
          type: ToasterMessageType.info,
        );
      } else {
        _replacedIdentityImages?[index] = PickedIdentityImageModel(
          imageFile: pickedImage,
          imageUrl: _currentIdentityImages[index],
        );
      }
    }
    update();
  }

  List<XFile> getUploadedImageFiles() => [
    for (final image in _replacedIdentityImages ?? [])
      if (image?.imageFile != null) image!.imageFile!,
    ...?_identityImages?.whereType<XFile>(),
  ];

  List<String> getDeletedImageUrls() {
    for (int i = 0; i < (_replacedIdentityImages?.length ?? 0); i++) {
      if (_replacedIdentityImages != null &&
          _replacedIdentityImages![i] != null) {
        _deletedIdentityImages.add(_replacedIdentityImages![i]!.imageUrl);
      }
    }

    return _deletedIdentityImages
        .whereType<String>()
        .map((url) => url.split('/').last)
        .toList();
  }

  bool isUploadEmpty() =>
      _currentIdentityImages.isEmpty && getUploadedImageFiles().isEmpty;
}
