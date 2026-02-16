import 'package:cosmetics_catalog/features/auth/domain/entities/user_entity.dart';
import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(String email, String password, String displayName);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> sendEmailVerification();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, UserEntity>> updateProfile({String? displayName, String? email, String? password});
  Future<Either<Failure, void>> updatePassword(String currentPassword, String newPassword);
}

