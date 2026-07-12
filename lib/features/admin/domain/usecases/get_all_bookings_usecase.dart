import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/admin/domain/repositories/admin_repository.dart';

class GetAllBookingsUseCase {
  final AdminRepository repository;

  GetAllBookingsUseCase(this.repository);

  Stream<Either<Failure, List<BookingEntity>>> call() {
    return repository.getAllBookingsStream();
  }
}
