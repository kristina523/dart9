import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:cosmetics_catalog/features/auth/domain/entities/user_entity.dart';
import 'package:cosmetics_catalog/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return Left(const ValidationFailure('Email и пароль не могут быть пустыми'));
    }
    return await repository.login(email, password);
  }
}

