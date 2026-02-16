import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:cosmetics_catalog/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class UpdatePasswordUseCase {
  final AuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String currentPassword, String newPassword) async {
    if (currentPassword.isEmpty) {
      return Left(ValidationFailure('Введите текущий пароль'));
    }
    if (newPassword.isEmpty) {
      return Left(ValidationFailure('Введите новый пароль'));
    }
    if (newPassword.length < 6) {
      return Left(ValidationFailure('Пароль должен содержать минимум 6 символов'));
    }
    return await repository.updatePassword(currentPassword, newPassword);
  }
}

