import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cosmetics_catalog/features/favorites/domain/entities/favorite_entity.dart';
import 'package:cosmetics_catalog/features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:cosmetics_catalog/features/favorites/domain/usecases/add_to_favorites_usecase.dart';
import 'package:cosmetics_catalog/features/favorites/domain/usecases/remove_from_favorites_usecase.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavoritesUseCase;
  final AddToFavoritesUseCase addToFavoritesUseCase;
  final RemoveFromFavoritesUseCase removeFromFavoritesUseCase;

  FavoritesBloc({
    required this.getFavoritesUseCase,
    required this.addToFavoritesUseCase,
    required this.removeFromFavoritesUseCase,
  }) : super(FavoritesInitial()) {
    on<GetFavoritesEvent>(_onGetFavorites);
    on<AddToFavoritesEvent>(_onAddToFavorites);
    on<RemoveFromFavoritesEvent>(_onRemoveFromFavorites);
  }

  Future<void> _onGetFavorites(GetFavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    final result = await getFavoritesUseCase(event.userId);
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (favorites) => emit(FavoritesLoaded(favorites)),
    );
  }

  Future<void> _onAddToFavorites(AddToFavoritesEvent event, Emitter<FavoritesState> emit) async {
    final result = await addToFavoritesUseCase(event.userId, event.productId);
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (_) {
        // Reload favorites
        add(GetFavoritesEvent(event.userId));
      },
    );
  }

  Future<void> _onRemoveFromFavorites(RemoveFromFavoritesEvent event, Emitter<FavoritesState> emit) async {
    final result = await removeFromFavoritesUseCase(event.userId, event.productId);
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (_) {
        // Reload favorites
        add(GetFavoritesEvent(event.userId));
      },
    );
  }
}

