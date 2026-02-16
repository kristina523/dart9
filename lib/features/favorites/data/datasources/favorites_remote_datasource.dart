import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cosmetics_catalog/features/favorites/data/models/favorite_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoriteModel>> getFavorites(String userId);
  Future<void> addToFavorites(String userId, String productId);
  Future<void> removeFromFavorites(String userId, String productId);
  Future<bool> isFavorite(String userId, String productId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final FirebaseFirestore firestore;

  FavoritesRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<FavoriteModel>> getFavorites(String userId) async {
    try {
      // Используем только where, сортировку делаем в памяти
      final snapshot = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      final favorites = snapshot.docs.map((doc) {
        try {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          // Если addedAt отсутствует, используем текущую дату
          if (data['addedAt'] == null) {
            data['addedAt'] = DateTime.now();
          }
          return FavoriteModel.fromJson(data);
        } catch (e) {
          // Если ошибка парсинга, пропускаем этот документ
          return null;
        }
      }).whereType<FavoriteModel>().toList();

      // Сортировка в памяти по дате добавления (новые первыми)
      favorites.sort((a, b) => b.addedAt.compareTo(a.addedAt));

      return favorites;
    } catch (e) {
      throw Exception('Не удалось загрузить избранное: ${e.toString()}');
    }
  }

  @override
  Future<void> addToFavorites(String userId, String productId) async {
    try {
      // Проверяем существование в памяти после получения всех избранных пользователя
      final allFavorites = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      // Проверяем в памяти, есть ли уже этот продукт
      final existing = allFavorites.docs.where((doc) {
        final data = doc.data();
        return data['productId'] == productId;
      });

      if (existing.isNotEmpty) {
        return; // Уже в избранном
      }

      await firestore.collection('favorites').add({
        'userId': userId,
        'productId': productId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Не удалось добавить в избранное: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFromFavorites(String userId, String productId) async {
    try {
      // Получаем все избранные пользователя и фильтруем в памяти
      final snapshot = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      // Фильтруем в памяти по productId
      final docsToDelete = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['productId'] == productId;
      });

      if (docsToDelete.isEmpty) {
        return; // Не найдено
      }

      final batch = firestore.batch();
      for (var doc in docsToDelete) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Не удалось удалить из избранного: ${e.toString()}');
    }
  }

  @override
  Future<bool> isFavorite(String userId, String productId) async {
    try {
      // Получаем все избранные пользователя и проверяем в памяти
      final snapshot = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      // Проверяем в памяти, есть ли этот продукт
      return snapshot.docs.any((doc) {
        final data = doc.data();
        return data['productId'] == productId;
      });
    } catch (e) {
      throw Exception('Не удалось проверить статус избранного: ${e.toString()}');
    }
  }
}

