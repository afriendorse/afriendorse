import 'package:image_picker/image_picker.dart';

class PickedIdentityImageModel{
  final XFile? imageFile;
  final String? imageUrl;

  PickedIdentityImageModel({required this.imageFile, required this.imageUrl});
}