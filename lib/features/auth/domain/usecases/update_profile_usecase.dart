import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:cosmetics_catalog/features/auth/domain/entities/user_entity.dart';
import 'package:cosmetics_catalog/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    String? displayName,
    String? email,
    String? password,
  }) async {
    if (displayName != null && displayName.trim().isEmpty) {
      return Left(ValidationFailure('Имя не может быть пустым'));
    }
    if (email != null && !email.contains('@')) {
      return Left(ValidationFailure('Некорректный email адрес'));
    }
    return await repository.updateProfile(displayName: displayName, email: email, password: password);
  }
}

