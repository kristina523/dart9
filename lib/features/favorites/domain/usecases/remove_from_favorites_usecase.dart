import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:cosmetics_catalog/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:dartz/dartz.dart';

class RemoveFromFavoritesUseCase {
  final FavoritesRepository repository;

  RemoveFromFavoritesUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId, String productId) async {
    if (userId.isEmpty || productId.isEmpty) {
      return Left(const ValidationFailure('ID пользователя и ID продукта не могут быть пустыми'));
    }
    return await repository.removeFromFavorites(userId, productId);
  }
}

