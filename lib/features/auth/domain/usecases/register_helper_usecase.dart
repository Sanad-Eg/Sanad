import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';
import 'package:sanad/features/auth/domain/repositories/auth_repository.dart';

class RegisterHelperUseCase {
  final AuthRepository repository;
  RegisterHelperUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String aboutMe,
    required double hourlyRate,
    required List<String> specialties,
    required List<String> serviceAreas,
    required String idFrontPath,
    required String idBackPath,
    required String selfieWithIdPath,
  }) {
    return repository.registerHelper(
      name: name,
      phone: phone,
      email: email,
      password: password,
      aboutMe: aboutMe,
      hourlyRate: hourlyRate,
      specialties: specialties,
      serviceAreas: serviceAreas,
      idFrontPath: idFrontPath,
      idBackPath: idBackPath,
      selfieWithIdPath: selfieWithIdPath,
    );
  }
}
