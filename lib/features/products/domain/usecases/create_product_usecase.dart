import 'package:cosmetics_catalog/core/errors/failures.dart';
import 'package:cosmetics_catalog/features/products/domain/entities/product_entity.dart';
import 'package:cosmetics_catalog/features/products/domain/repositories/products_repository.dart';
import 'package:dartz/dartz.dart';

class CreateProductUseCase {
  final ProductsRepository repository;

  CreateProductUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call(ProductEntity product) async {
    if (product.name.isEmpty) {
      return const Left(ValidationFailure('Название продукта не может быть пустым'));
    }
    if (product.price <= 0) {
      return const Left(ValidationFailure('Цена должна быть больше нуля'));
    }
    if (product.category.isEmpty) {
      return const Left(ValidationFailure('Категория не может быть пустой'));
    }
    if (product.brand.isEmpty) {
      return const Left(ValidationFailure('Бренд не может быть пустым'));
    }
    return await repository.createProduct(product);
  }
}

