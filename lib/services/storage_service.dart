import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;

  /// Uploads a profile photo to `users/{userId}/profile.jpg`.
  static Future<String> uploadProfilePhoto(
    File image,
    String userId, {
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref().child('users/$userId/profile.jpg');
    final task = ref.putFile(image);
    if (onProgress != null) {
      task.snapshotEvents.listen((s) {
        if (s.totalBytes > 0) onProgress(s.bytesTransferred / s.totalBytes);
      });
    }
    final snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  /// Uploads a single gallery photo for a given slot index.
  /// Using a slot-based path means re-uploading the same slot overwrites it.
  static Future<String> uploadGalleryPhoto(
    File image,
    String userId,
    int slot, {
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref().child('users/$userId/gallery_$slot.jpg');
    final task = ref.putFile(image);
    if (onProgress != null) {
      task.snapshotEvents.listen((s) {
        if (s.totalBytes > 0) onProgress(s.bytesTransferred / s.totalBytes);
      });
    }
    final snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  /// Uploads multiple gallery photos sequentially.
  static Future<List<String>> uploadGalleryPhotos(
    List<File> images,
    String userId, {
    void Function(int index, double progress)? onProgress,
  }) async {
    final urls = <String>[];
    for (int i = 0; i < images.length; i++) {
      final url = await uploadGalleryPhoto(
        images[i],
        userId,
        i,
        onProgress: (p) => onProgress?.call(i, p),
      );
      urls.add(url);
    }
    return urls;
  }

  /// Deletes a photo from Firebase Storage by its download URL.
  static Future<void> deletePhoto(String photoUrl) async {
    try {
      await _storage.refFromURL(photoUrl).delete();
    } catch (_) {}
  }
}
