import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:cosmetics_catalog/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:cosmetics_catalog/features/favorites/domain/entities/favorite_entity.dart';
import 'package:cosmetics_catalog/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:dartz/dartz.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites(String userId) async {
    try {
      final favorites = await remoteDataSource.getFavorites(userId);
      return Right(favorites);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(String userId, String productId) async {
    try {
      await remoteDataSource.addToFavorites(userId, productId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String userId, String productId) async {
    try {
      await remoteDataSource.removeFromFavorites(userId, productId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String userId, String productId) async {
    try {
      final isFav = await remoteDataSource.isFavorite(userId, productId);
      return Right(isFav);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

