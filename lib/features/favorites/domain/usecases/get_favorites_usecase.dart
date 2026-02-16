import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:cosmetics_catalog/features/favorites/domain/entities/favorite_entity.dart';
import 'package:cosmetics_catalog/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:dartz/dartz.dart';

class GetFavoritesUseCase {
  final FavoritesRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<Either<Failure, List<FavoriteEntity>>> call(String userId) async {
    if (userId.isEmpty) {
      return Left(const ValidationFailure('ID пользователя не может быть пустым'));
    }
    return await repository.getFavorites(userId);
  }
}

