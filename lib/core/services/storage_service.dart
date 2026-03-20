import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import 'auth_service.dart';

class StorageService {
  static const String baseUrl = ApiConstants.baseUrl;
  final AuthService _authService = AuthService();

  /// Uploads a generic file byte array and returns the download URL
  Future<String?> uploadFile({
    required String path,
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final token = await _authService.getToken();
      
      // Using a multipart request for file upload
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/storage/upload'));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['path'] = path;
      
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      );
      
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url'];
      } else {
        debugPrint('Upload failed with status: ${response.statusCode}');
        return null;
      }
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
}
