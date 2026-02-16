part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class GetFavoritesEvent extends FavoritesEvent {
  final String userId;

  const GetFavoritesEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddToFavoritesEvent extends FavoritesEvent {
  final String userId;
  final String productId;

  const AddToFavoritesEvent(this.userId, this.productId);

  @override
  List<Object> get props => [userId, productId];
}

class RemoveFromFavoritesEvent extends FavoritesEvent {
  final String userId;
  final String productId;

  const RemoveFromFavoritesEvent(this.userId, this.productId);

  @override
  List<Object> get props => [userId, productId];
}

