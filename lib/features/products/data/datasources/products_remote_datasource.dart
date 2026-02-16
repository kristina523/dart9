import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cosmetics_catalog/features/products/data/models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? category,
    String? brand,
    String? searchQuery,
    String? sortBy,
  });
  Future<ProductModel> getProductById(String id);
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductsRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? brand,
    String? searchQuery,
    String? sortBy,
  }) async {
    try {
      Query query = firestore.collection('products');

      // Apply filters - только один фильтр за раз, чтобы избежать составных индексов
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      } else if (brand != null && brand.isNotEmpty) {
        query = query.where('brand', isEqualTo: brand);
      }

      // Apply sorting - только если нет фильтров, требующих индекс
      // Если есть фильтр, сортировка будет выполнена в памяти
      bool sortInMemory = false;
      if (category != null && category.isNotEmpty || brand != null && brand.isNotEmpty) {
        sortInMemory = true;
      } else {
        // Сортировка в Firestore только если нет фильтров
        if (sortBy != null && sortBy.isNotEmpty) {
          switch (sortBy) {
            case 'price_asc':
              query = query.orderBy('price', descending: false);
              break;
            case 'price_desc':
              query = query.orderBy('price', descending: true);
              break;
            case 'rating':
              query = query.orderBy('rating', descending: true);
              break;
            case 'name':
              query = query.orderBy('name', descending: false);
              break;
          }
        } else {
          query = query.orderBy('name', descending: false);
        }
      }

      final snapshot = await query.get();
      List<ProductModel> products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ProductModel.fromJson(data);
      }).toList();

      // Apply filters in memory if multiple filters were requested
      if (category != null && category.isNotEmpty && brand != null && brand.isNotEmpty) {
        products = products.where((product) => product.brand == brand).toList();
      }

      // Apply sorting in memory if needed
      if (sortInMemory && sortBy != null && sortBy.isNotEmpty) {
        switch (sortBy) {
          case 'price_asc':
            products.sort((a, b) => a.price.compareTo(b.price));
            break;
          case 'price_desc':
            products.sort((a, b) => b.price.compareTo(a.price));
            break;
          case 'rating':
            products.sort((a, b) => b.rating.compareTo(a.rating));
            break;
          case 'name':
            products.sort((a, b) => a.name.compareTo(b.name));
            break;
        }
      } else if (sortInMemory) {
        // Default sort by name if no sort specified
        products.sort((a, b) => a.name.compareTo(b.name));
      }

      // Apply search filter in memory (Firestore doesn't support full-text search)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        products = products.where((product) {
          return product.name.toLowerCase().contains(lowerQuery) ||
              product.description.toLowerCase().contains(lowerQuery) ||
              product.brand.toLowerCase().contains(lowerQuery) ||
              product.category.toLowerCase().contains(lowerQuery);
        }).toList();
      }

      return products;
    } catch (e) {
      throw Exception('Не удалось загрузить продукты: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final doc = await firestore.collection('products').doc(id).get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('Продукт не найден');
      }
      final data = doc.data()!;
      final productData = Map<String, dynamic>.from(data);
      productData['id'] = doc.id;
      return ProductModel.fromJson(productData);
    } catch (e) {
      throw Exception('Не удалось загрузить продукт: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      // Создаем JSON без id, так как Firestore создаст его автоматически
      final productJson = product.toJson();
      productJson.remove('id');
      
      final docRef = await firestore.collection('products').add(productJson);
      final doc = await docRef.get();
      final data = doc.data()!;
      final productData = Map<String, dynamic>.from(data);
      productData['id'] = doc.id;
      return ProductModel.fromJson(productData);
    } catch (e) {
      throw Exception('Не удалось создать продукт: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final productJson = product.toJson();
      productJson.remove('id'); // Удаляем id из данных перед сохранением
      
      await firestore.collection('products').doc(product.id).update(productJson);
      
      final doc = await firestore.collection('products').doc(product.id).get();
      final data = doc.data()!;
      final productData = Map<String, dynamic>.from(data);
      productData['id'] = doc.id;
      return ProductModel.fromJson(productData);
    } catch (e) {
      throw Exception('Не удалось обновить продукт: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await firestore.collection('products').doc(id).delete();
    } catch (e) {
      throw Exception('Не удалось удалить продукт: ${e.toString()}');
    }
  }
}

