import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'image_repository.dart';

class LocalImageRepository implements ImageRepository {
  LocalImageRepository._();
  static final LocalImageRepository instance = LocalImageRepository._();

  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pickImageFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    return file?.path;
  }

  @override
  Future<String> uploadImage(String localPath) async {
    // Local implementation: return the local file path as "URL".
    // Replace with Firebase Storage upload later.
    if (localPath.isEmpty) throw ArgumentError('localPath cannot be empty');
    // Ensure file exists
    final file = File(localPath);
    if (!await file.exists()) throw Exception('File not found: $localPath');
    return localPath;
  }
}
