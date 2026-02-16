part of 'products_bloc.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<ProductEntity> products;

  const ProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object> get props => [message];
}

class ProductDetailLoading extends ProductsState {}

class ProductDetailLoaded extends ProductsState {
  final ProductEntity product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object> get props => [product];
}

class ProductDetailError extends ProductsState {
  final String message;

  const ProductDetailError(this.message);

  @override
  List<Object> get props => [message];
}

class ProductCreating extends ProductsState {}

class ProductCreateSuccess extends ProductsState {
  final ProductEntity product;

  const ProductCreateSuccess(this.product);

  @override
  List<Object> get props => [product];
}

class ProductCreateError extends ProductsState {
  final String message;

  const ProductCreateError(this.message);

  @override
  List<Object> get props => [message];
}

class ProductUpdating extends ProductsState {}

class ProductUpdateSuccess extends ProductsState {
  final ProductEntity product;

  const ProductUpdateSuccess(this.product);

  @override
  List<Object> get props => [product];
}

class ProductUpdateError extends ProductsState {
  final String message;

  const ProductUpdateError(this.message);

  @override
  List<Object> get props => [message];
}

class ProductDeleting extends ProductsState {}

class ProductDeleteSuccess extends ProductsState {}

class ProductDeleteError extends ProductsState {
  final String message;

  const ProductDeleteError(this.message);

  @override
  List<Object> get props => [message];
}

