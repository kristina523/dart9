import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:cosmetics_catalog/features/products/domain/entities/product_entity.dart';
import 'package:cosmetics_catalog/features/products/domain/repositories/products_repository.dart';
import 'package:dartz/dartz.dart';

class GetProductsUseCase {
  final ProductsRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call({
    String? category,
    String? brand,
    String? searchQuery,
    String? sortBy,
  }) async {
    return await repository.getProducts(
      category: category,
      brand: brand,
      searchQuery: searchQuery,
      sortBy: sortBy,
    );
  }
}

