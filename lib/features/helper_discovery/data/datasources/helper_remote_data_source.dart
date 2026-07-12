import 'package:sanad/features/helper_discovery/data/models/helper_model.dart';
import 'package:sanad/features/helper_discovery/data/models/review_model.dart';

abstract class HelperRemoteDataSource {
  /// Returns all verified helpers, optionally filtered by specialty or name query.
  Future<List<HelperModel>> getHelpers({String? specialty, String? query});

  /// Returns a single helper's full profile by their Firestore document ID.
  Future<HelperModel> getHelperProfile(String helperId);

  Stream<HelperModel> getHelperProfileStream(String helperId);

  Stream<List<ReviewModel>> getHelperReviews(String helperId);
}
