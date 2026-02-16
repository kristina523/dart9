// Скрипт для добавления тестовых продуктов в Firestore
// Запуск: dart scripts/add_sample_products.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

// Тестовые продукты с переведенными категориями
final sampleProducts = [
  {
    'name': 'Матовый блеск для губ',
    'description': 'Долговечный матовый блеск для губ с насыщенным цветом. Идеален для носки в течение всего дня.',
    'price': 12.99,
    'imageUrl': 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400',
    'category': 'Декоративная косметика',
    'brand': 'Maybelline',
    'rating': 4.5,
    'reviewCount': 234,
    'inStock': true,
    'tags': ['блеск для губ', 'матовый', 'долговечный'],
  },
  {
    'name': 'Увлажняющий крем для лица',
    'description': 'Глубоко увлажняющий крем для лица с гиалуроновой кислотой. Подходит для всех типов кожи.',
    'price': 24.99,
    'imageUrl': 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400',
    'category': 'Уход за кожей',
    'brand': 'L\'Oreal',
    'rating': 4.7,
    'reviewCount': 456,
    'inStock': true,
    'tags': ['увлажняющий', 'гиалуроновая кислота', 'крем'],
  },
  {
    'name': 'Объемная тушь для ресниц',
    'description': 'Удлиняющая и объемная тушь для драматичных ресниц.',
    'price': 9.99,
    'imageUrl': 'https://images.unsplash.com/photo-1631214558662-a2c4c76b8f3e?w=400',
    'category': 'Декоративная косметика',
    'brand': 'Revlon',
    'rating': 4.3,
    'reviewCount': 189,
    'inStock': true,
    'tags': ['тушь', 'объемная', 'удлиняющая'],
  },
  {
    'name': 'Набор шампунь и кондиционер',
    'description': 'Питательный набор шампуня и кондиционера для здоровых и блестящих волос.',
    'price': 18.99,
    'imageUrl': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400',
    'category': 'Уход за волосами',
    'brand': 'L\'Oreal',
    'rating': 4.6,
    'reviewCount': 312,
    'inStock': true,
    'tags': ['шампунь', 'кондиционер', 'уход за волосами'],
  },
  {
    'name': 'Парфюм Eau de Parfum',
    'description': 'Элегантный цветочный аромат с нотами розы и жасмина.',
    'price': 49.99,
    'imageUrl': 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=400',
    'category': 'Парфюмерия',
    'brand': 'Estee Lauder',
    'rating': 4.8,
    'reviewCount': 567,
    'inStock': true,
    'tags': ['парфюм', 'цветочный', 'элегантный'],
  },
  {
    'name': 'Набор лаков для ногтей',
    'description': 'Набор из 6 ярких лаков для ногтей с долговечной формулой.',
    'price': 15.99,
    'imageUrl': 'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=400',
    'category': 'Уход за ногтями',
    'brand': 'Revlon',
    'rating': 4.4,
    'reviewCount': 278,
    'inStock': true,
    'tags': ['лак для ногтей', 'набор', 'долговечный'],
  },
  {
    'name': 'BB крем',
    'description': 'Универсальный BB крем с SPF 30. Обеспечивает покрытие и защиту от солнца.',
    'price': 16.99,
    'imageUrl': 'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=400',
    'category': 'Декоративная косметика',
    'brand': 'Maybelline',
    'rating': 4.5,
    'reviewCount': 423,
    'inStock': true,
    'tags': ['bb крем', 'spf', 'покрытие'],
  },
  {
    'name': 'Лосьон для тела',
    'description': 'Увлажняющий лосьон для тела с маслом ши и витамином E.',
    'price': 11.99,
    'imageUrl': 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400',
    'category': 'Уход за телом',
    'brand': 'NARS',
    'rating': 4.6,
    'reviewCount': 345,
    'inStock': true,
    'tags': ['лосьон для тела', 'увлажняющий', 'масло ши'],
  },
];

Future<void> main() async {
  print('🚀 Инициализация Firebase...');
  
  try {
    // Используем конфигурацию из firebase_options.dart
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBzmUGSa9gkRoGsMkVU-NYsH9TeSKGrbfw',
        appId: '1:1072681341830:web:84bc63b5ff82c0491e9207',
        messagingSenderId: '1072681341830',
        projectId: 'cosmetics-catalog-3c357',
        authDomain: 'cosmetics-catalog-3c357.firebaseapp.com',
        storageBucket: 'cosmetics-catalog-3c357.firebasestorage.app',
        measurementId: 'G-8DFDS5C2K4',
      ),
    );
    
    print('✅ Firebase инициализирован');
    print('📦 Добавление продуктов в Firestore...');
    
    final firestore = FirebaseFirestore.instance;
    int added = 0;
    
    for (var product in sampleProducts) {
      try {
        await firestore.collection('products').add(product);
        added++;
        print('✅ Добавлен: ${product['name']}');
      } catch (e) {
        print('❌ Ошибка при добавлении ${product['name']}: $e');
      }
    }
    
    print('\n🎉 Готово! Добавлено продуктов: $added из ${sampleProducts.length}');
    
  } catch (e) {
    print('❌ Ошибка: $e');
    print('\n⚠️  Убедитесь, что:');
    print('1. Вы заменили конфигурацию Firebase в скрипте');
    print('2. Firestore Database создана в Firebase Console');
    print('3. Правила безопасности разрешают запись');
  }
  
  exit(0);
}

