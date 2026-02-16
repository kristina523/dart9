import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:cosmetics_catalog/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class SendEmailVerificationUseCase {
  final AuthRepository repository;

  SendEmailVerificationUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.sendEmailVerification();
  }
}

