import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/domain/repositories/booking_repository.dart';

class GetHelperBookingsUseCase {
  final BookingRepository _repository;

  GetHelperBookingsUseCase(this._repository);

  Stream<Either<Failure, List<BookingEntity>>> call(String helperId) {
    return _repository.getHelperBookingsStream(helperId);
  }
}
