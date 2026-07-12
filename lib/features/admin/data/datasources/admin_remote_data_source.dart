import 'package:sanad/features/auth/data/models/user_model.dart';
import 'package:sanad/features/booking/data/models/booking_model.dart';

abstract class AdminRemoteDataSource {
  Stream<List<UserModel>> getPendingHelpers();
  Stream<List<UserModel>> getUsersStream();
  Stream<List<BookingModel>> getAllBookingsStream();
  Future<void> updateHelperVerificationStatus({
    required String helperId,
    required String status,
  });
  Future<void> approveHelper(String uid);
}
