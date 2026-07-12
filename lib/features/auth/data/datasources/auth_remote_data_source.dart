import 'package:sanad/features/auth/data/models/user_model.dart';

/// Contract for all remote Firebase operations related to authentication.
/// The Domain layer never sees this — only the repository implementation uses it.
abstract class AuthRemoteDataSource {
  /// Persists a newly-created [userModel] to the Firestore `users` collection.
  Future<void> createUserInFirestore(UserModel userModel);

  /// Fetches a user document from Firestore by [uid].
  /// Returns `null` when the document does not exist.
  Future<UserModel?> getUserFromFirestore(String uid);

  /// Uploads helper verification documents (ID front, ID back, selfie) to
  /// Firebase Storage and returns a map of download URLs.
  ///
  /// Keys: `idFrontUrl`, `idBackUrl`, `selfieUrl`.
  Future<Map<String, String>> uploadVerificationDocs({
    required String uid,
    required String idFrontPath,
    required String idBackPath,
    required String selfieWithIdPath,
  });

  /// Uploads a profile picture to Firebase Storage and returns the download URL.
  Future<String> uploadProfileImage({
    required String uid,
    required String filePath,
  });

  /// Updates specific fields on a user's Firestore document (merge).
  Future<void> updateUserFields({
    required String uid,
    required Map<String, dynamic> data,
  });

  /// Streams the current user's document from Firestore.
  Stream<UserModel?> watchCurrentUser(String uid);
}
