import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/domain/repositories/booking_repository.dart';

class GetClientBookingsUseCase {
  final BookingRepository _repository;

  GetClientBookingsUseCase(this._repository);

  Stream<Either<Failure, List<BookingEntity>>> call(String clientId) {
    return _repository.getClientBookingsStream(clientId);
  }
}
