import 'package:cosmetics_catalog/features/products/domain/entities/product_entity.dart';
import 'package:equatable/equatable.dart';

class FavoriteEntity extends Equatable {
  final String id;
  final String userId;
  final String productId;
  final DateTime addedAt;
  final ProductEntity? product; // Optional, loaded separately

  const FavoriteEntity({
    required this.id,
    required this.userId,
    required this.productId,
    required this.addedAt,
    this.product,
  });

  @override
  List<Object?> get props => [id, userId, productId, addedAt, product];
}

