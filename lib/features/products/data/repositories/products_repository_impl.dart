import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:cosmetics_catalog/features/products/data/datasources/products_remote_datasource.dart';
import 'package:cosmetics_catalog/features/products/data/models/product_model.dart';
import 'package:cosmetics_catalog/features/products/domain/entities/product_entity.dart';
import 'package:cosmetics_catalog/features/products/domain/repositories/products_repository.dart';
import 'package:dartz/dartz.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? brand,
    String? searchQuery,
    String? sortBy,
  }) async {
    try {
      final products = await remoteDataSource.getProducts(
        category: category,
        brand: brand,
        searchQuery: searchQuery,
        sortBy: sortBy,
      );
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final product = await remoteDataSource.getProductById(id);
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(ProductEntity product) async {
    try {
      final productModel = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        category: product.category,
        brand: product.brand,
        rating: product.rating,
        reviewCount: product.reviewCount,
        inStock: product.inStock,
        tags: product.tags,
      );
      final createdProduct = await remoteDataSource.createProduct(productModel);
      return Right(createdProduct);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product) async {
    try {
      final productModel = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        category: product.category,
        brand: product.brand,
        rating: product.rating,
        reviewCount: product.reviewCount,
        inStock: product.inStock,
        tags: product.tags,
      );
      final updatedProduct = await remoteDataSource.updateProduct(productModel);
      return Right(updatedProduct);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

