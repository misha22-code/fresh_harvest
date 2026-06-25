abstract class ImageRepository {
  /// Opens gallery picker and returns a local file path, or null if cancelled.
  Future<String?> pickImageFromGallery();

  /// Uploads image at [localPath] and returns a publicly accessible URL.
  /// Local implementation may return the local path; cloud implementations
  /// (e.g. Firebase) should return the uploaded asset URL.
  Future<String> uploadImage(String localPath);
}
