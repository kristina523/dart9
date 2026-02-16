import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cosmetics_catalog/features/favorites/domain/entities/favorite_entity.dart';
import 'package:cosmetics_catalog/features/products/domain/entities/product_entity.dart';

class FavoriteModel extends FavoriteEntity {
  const FavoriteModel({
    required super.id,
    required super.userId,
    required super.productId,
    required super.addedAt,
    super.product,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json, {ProductEntity? product}) {
    DateTime addedAt;
    if (json['addedAt'] is Timestamp) {
      addedAt = (json['addedAt'] as Timestamp).toDate();
    } else {
      addedAt = DateTime.now();
    }
    
    return FavoriteModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      addedAt: addedAt,
      product: product,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}

