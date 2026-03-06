import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a generic file byte array and returns the download URL
  Future<String?> uploadFile({
    required String path,
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('$path/$fileName');

      // Specify content type to ensure it loads properly in browsers
      final metadata = SettableMetadata(contentType: _getContentType(fileName));

      final uploadTask = await ref.putData(bytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  /// Uploads a profile picture for a specific user
  Future<String?> uploadProfilePicture(
    String uid,
    Uint8List bytes,
    String fileName,
  ) async {
    return await uploadFile(
      path: 'users/$uid/profile',
      bytes: bytes,
      fileName: fileName,
    );
  }

  /// Uploads an Aadhar picture for a specific user
  Future<String?> uploadAadharPicture(
    String uid,
    Uint8List bytes,
    String fileName,
  ) async {
    return await uploadFile(
      path: 'users/$uid/aadhar',
      bytes: bytes,
      fileName: fileName,
    );
  }

  /// Uploads a PAN picture for a specific user
  Future<String?> uploadPanPicture(
    String uid,
    Uint8List bytes,
    String fileName,
  ) async {
    return await uploadFile(
      path: 'users/$uid/pan',
      bytes: bytes,
      fileName: fileName,
    );
  }

  String _getContentType(String fileName) {
    if (fileName.toLowerCase().endsWith('.png')) return 'image/png';
    if (fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (fileName.toLowerCase().endsWith('.webp')) return 'image/webp';
    return 'application/octet-stream'; // Default fallback
  }
}
