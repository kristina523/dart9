import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:cosmetics_catalog/features/auth/domain/entities/user_entity.dart';
import 'package:cosmetics_catalog/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password, String displayName) async {
    if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
      return Left(const ValidationFailure('Все поля обязательны для заполнения'));
    }
    if (password.length < 6) {
      return Left(const ValidationFailure('Пароль должен содержать минимум 6 символов'));
    }
    if (!_isValidEmail(email)) {
      return Left(const ValidationFailure('Некорректный формат email'));
    }
    return await repository.register(email, password, displayName);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

