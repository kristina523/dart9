part of 'products_bloc.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class GetProductsEvent extends ProductsEvent {
  final String? category;
  final String? brand;
  final String? searchQuery;
  final String? sortBy;

  const GetProductsEvent({
    this.category,
    this.brand,
    this.searchQuery,
    this.sortBy,
  });

  @override
  List<Object?> get props => [category, brand, searchQuery, sortBy];
}

class GetProductByIdEvent extends ProductsEvent {
  final String id;

  const GetProductByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

class FilterProductsEvent extends ProductsEvent {
  final String? category;
  final String? brand;
  final String? sortBy;

  const FilterProductsEvent({
    this.category,
    this.brand,
    this.sortBy,
  });

  @override
  List<Object?> get props => [category, brand, sortBy];
}

class SearchProductsEvent extends ProductsEvent {
  final String query;
  final String? sortBy;

  const SearchProductsEvent(this.query, {this.sortBy});

  @override
  List<Object?> get props => [query, sortBy];
}

class CreateProductEvent extends ProductsEvent {
  final ProductEntity product;

  const CreateProductEvent(this.product);

  @override
  List<Object> get props => [product];
}

class UpdateProductEvent extends ProductsEvent {
  final ProductEntity product;

  const UpdateProductEvent(this.product);

  @override
  List<Object> get props => [product];
}

class DeleteProductEvent extends ProductsEvent {
  final String id;

  const DeleteProductEvent(this.id);

  @override
  List<Object> get props => [id];
}

