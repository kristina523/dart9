import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cosmetics_catalog/features/products/domain/entities/product_entity.dart';
import 'package:cosmetics_catalog/features/products/domain/usecases/get_products_usecase.dart';
import 'package:cosmetics_catalog/features/products/domain/usecases/get_product_by_id_usecase.dart';
import 'package:cosmetics_catalog/features/products/domain/usecases/create_product_usecase.dart';
import 'package:cosmetics_catalog/features/products/domain/usecases/update_product_usecase.dart';
import 'package:cosmetics_catalog/features/products/domain/usecases/delete_product_usecase.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductByIdUseCase getProductByIdUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  ProductsBloc({
    required this.getProductsUseCase,
    required this.getProductByIdUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  }) : super(ProductsInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<GetProductByIdEvent>(_onGetProductById);
    on<FilterProductsEvent>(_onFilterProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onGetProducts(GetProductsEvent event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    final result = await getProductsUseCase(
      category: event.category,
      brand: event.brand,
      searchQuery: event.searchQuery,
      sortBy: event.sortBy,
    );
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onGetProductById(GetProductByIdEvent event, Emitter<ProductsState> emit) async {
    emit(ProductDetailLoading());
    final result = await getProductByIdUseCase(event.id);
    result.fold(
      (failure) => emit(ProductDetailError(failure.message)),
      (product) => emit(ProductDetailLoaded(product)),
    );
  }

  Future<void> _onFilterProducts(FilterProductsEvent event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    final result = await getProductsUseCase(
      category: event.category,
      brand: event.brand,
      sortBy: event.sortBy,
    );
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onSearchProducts(SearchProductsEvent event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    final result = await getProductsUseCase(
      searchQuery: event.query,
      sortBy: event.sortBy,
    );
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onCreateProduct(CreateProductEvent event, Emitter<ProductsState> emit) async {
    emit(ProductCreating());
    final result = await createProductUseCase(event.product);
    result.fold(
      (failure) => emit(ProductCreateError(failure.message)),
      (product) {
        emit(ProductCreateSuccess(product));
        // Обновить список продуктов
        add(const GetProductsEvent());
      },
    );
  }

  Future<void> _onUpdateProduct(UpdateProductEvent event, Emitter<ProductsState> emit) async {
    emit(ProductUpdating());
    final result = await updateProductUseCase(event.product);
    result.fold(
      (failure) => emit(ProductUpdateError(failure.message)),
      (product) {
        emit(ProductUpdateSuccess(product));
        // Обновить список продуктов и детали продукта
        add(const GetProductsEvent());
        add(GetProductByIdEvent(product.id));
      },
    );
  }

  Future<void> _onDeleteProduct(DeleteProductEvent event, Emitter<ProductsState> emit) async {
    emit(ProductDeleting());
    final result = await deleteProductUseCase(event.id);
    result.fold(
      (failure) => emit(ProductDeleteError(failure.message)),
      (_) {
        emit(ProductDeleteSuccess());
        // Обновить список продуктов
        add(const GetProductsEvent());
      },
    );
  }
}

