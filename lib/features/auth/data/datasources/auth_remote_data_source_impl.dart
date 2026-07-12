import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:sanad/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sanad/features/auth/data/models/user_model.dart';

/// Firestore implementation of [AuthRemoteDataSource].
/// All Firebase I/O for the auth feature is isolated here.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';

  AuthRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  })  : _firestore = firestore;

  @override
  Future<void> createUserInFirestore(UserModel userModel) async {
    await _firestore
        .collection(_usersCollection)
        .doc(userModel.id)
        .set(userModel.toJson());
  }

  @override
  Future<UserModel?> getUserFromFirestore(String uid) async {
    final doc =
        await _firestore.collection(_usersCollection).doc(uid).get();

    if (!doc.exists || doc.data() == null) return null;

    return UserModel.fromJson(doc.data()!);
  }

  @override
  Future<Map<String, String>> uploadVerificationDocs({
    required String uid,
    required String idFrontPath,
    required String idBackPath,
    required String selfieWithIdPath,
  }) async {
    final idFrontUrl = await _uploadFile(idFrontPath);
    final idBackUrl = await _uploadFile(idBackPath);
    final selfieUrl = await _uploadFile(selfieWithIdPath);

    return {
      'idFrontUrl': idFrontUrl,
      'idBackUrl': idBackUrl,
      'selfieUrl': selfieUrl,
    };
  }

  /// Uploads a single file to ImgBB and returns its URL.
  Future<String> _uploadFile(String filePath) async {
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=cfb10ee032ca7b13d88242687564b3ea');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', filePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      return jsonResponse['data']['url'] as String;
    } else {
      throw Exception('Failed to upload image to ImgBB: ${response.statusCode}');
    }
  }

  @override
  Future<String> uploadProfileImage({
    required String uid,
    required String filePath,
  }) async {
    return await _uploadFile(filePath);
  }

  @override
  Future<void> updateUserFields({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .update(data);
  }

  @override
  Stream<UserModel?> watchCurrentUser(String uid) {
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromJson(snapshot.data()!);
    });
  }
}
