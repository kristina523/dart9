import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:cosmetics_catalog/features/favorites/domain/entities/favorite_entity.dart';
import 'package:dartz/dartz.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites(String userId);
  Future<Either<Failure, void>> addToFavorites(String userId, String productId);
  Future<Either<Failure, void>> removeFromFavorites(String userId, String productId);
  Future<Either<Failure, bool>> isFavorite(String userId, String productId);
}

