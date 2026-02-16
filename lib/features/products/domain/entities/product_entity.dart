import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String brand;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final List<String> tags;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.brand,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        category,
        brand,
        rating,
        reviewCount,
        inStock,
        tags,
      ];
}

