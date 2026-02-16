import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:cosmetics_catalog/features/products/domain/entities/product_entity.dart';
import 'package:cosmetics_catalog/features/products/domain/repositories/products_repository.dart';
import 'package:dartz/dartz.dart';

class GetProductByIdUseCase {
  final ProductsRepository repository;

  GetProductByIdUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call(String id) async {
    if (id.isEmpty) {
      return Left(const ValidationFailure('ID продукта не может быть пустым'));
    }
    return await repository.getProductById(id);
  }
}

