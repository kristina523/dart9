import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cosmetics_catalog/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cosmetics_catalog/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cosmetics_catalog/features/auth/domain/repositories/auth_repository.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/login_usecase.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/register_usecase.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/logout_usecase.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/send_email_verification_usecase.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:cosmetics_catalog/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cosmetics_catalog/features/products/data/datasources/products_remote_datasource.dart';
import 'package:cosmetics_catalog/features/products/data/repositories/products_repository_impl.dart';
import 'package:cosmetics_catalog/features/products/domain/repositories/products_repository.dart';
import 'package:cosmetics_catalog/features/products/domain/usecases/get_products_usecase.dart';
import 'package:cosmetics_catalog/features/products/domain/usecases/get_product_by_id_usecase.dart';
import 'package:cosmetics_catalog/features/products/domain/usecases/create_product_usecase.dart';
import 'package:cosmetics_catalog/features/products/domain/usecases/update_product_usecase.dart';
import 'package:cosmetics_catalog/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:cosmetics_catalog/features/products/presentation/bloc/products_bloc.dart';
import 'package:cosmetics_catalog/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:cosmetics_catalog/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:cosmetics_catalog/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:cosmetics_catalog/features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:cosmetics_catalog/features/favorites/domain/usecases/add_to_favorites_usecase.dart';
import 'package:cosmetics_catalog/features/favorites/domain/usecases/remove_from_favorites_usecase.dart';
import 'package:cosmetics_catalog/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:cosmetics_catalog/features/settings/presentation/bloc/theme_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // Auth Feature
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => ResetPasswordUseCase(getIt()));
  getIt.registerLazySingleton(() => SendEmailVerificationUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdatePasswordUseCase(getIt()));

  // Bloc
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      logoutUseCase: getIt(),
      resetPasswordUseCase: getIt(),
      sendEmailVerificationUseCase: getIt(),
      updateProfileUseCase: getIt(),
      updatePasswordUseCase: getIt(),
      authRepository: getIt(),
    ),
  );

  // Products Feature
  // Data sources
  getIt.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetProductByIdUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateProductUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProductUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteProductUseCase(getIt()));

  // Bloc
  getIt.registerFactory(
    () => ProductsBloc(
      getProductsUseCase: getIt(),
      getProductByIdUseCase: getIt(),
      createProductUseCase: getIt(),
      updateProductUseCase: getIt(),
      deleteProductUseCase: getIt(),
    ),
  );

  // Favorites Feature
  // Data sources
  getIt.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetFavoritesUseCase(getIt()));
  getIt.registerLazySingleton(() => AddToFavoritesUseCase(getIt()));
  getIt.registerLazySingleton(() => RemoveFromFavoritesUseCase(getIt()));

  // Bloc
  getIt.registerFactory(
    () => FavoritesBloc(
      getFavoritesUseCase: getIt(),
      addToFavoritesUseCase: getIt(),
      removeFromFavoritesUseCase: getIt(),
    ),
  );

  // Settings Feature
  // Bloc
  getIt.registerFactory(() => ThemeBloc());
}

