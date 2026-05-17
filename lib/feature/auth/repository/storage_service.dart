import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadBrandDocument({
    required String email,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final safeEmail = email.trim().toLowerCase();
    final ref = _storage.ref().child('brand_documents/$safeEmail/$fileName');
    final uploadTask = await ref.putData(fileBytes);
    return await uploadTask.ref.getDownloadURL();
  }
}
