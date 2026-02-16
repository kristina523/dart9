import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cosmetics_catalog/core/theme/app_theme.dart';
import 'package:cosmetics_catalog/core/widgets/error_snackbar.dart';
import 'package:cosmetics_catalog/core/widgets/success_snackbar.dart';
import 'package:cosmetics_catalog/core/widgets/loading_overlay.dart';
import 'package:cosmetics_catalog/features/products/presentation/bloc/products_bloc.dart';
import 'package:cosmetics_catalog/features/products/domain/entities/product_entity.dart';
import 'package:go_router/go_router.dart';

class AddProductPage extends StatefulWidget {
  final ProductEntity? product;

  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _brandController = TextEditingController();
  final _tagsController = TextEditingController();

  String _selectedCategory = 'Декоративная косметика';
  double _rating = 4.0;
  int _reviewCount = 0;
  bool _inStock = true;

  final List<String> _categories = [
    'Декоративная косметика',
    'Уход за кожей',
    'Уход за волосами',
    'Парфюмерия',
    'Уход за телом',
    'Уход за ногтями',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      // Режим редактирования - заполняем поля
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _imageUrlController.text = widget.product!.imageUrl;
      _selectedCategory = widget.product!.category;
      _brandController.text = widget.product!.brand;
      _rating = widget.product!.rating;
      _reviewCount = widget.product!.reviewCount;
      _inStock = widget.product!.inStock;
      _tagsController.text = widget.product!.tags.join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _brandController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final product = ProductEntity(
        id: widget.product?.id ?? '', // Используем существующий ID при редактировании
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: _imageUrlController.text.trim(),
        category: _selectedCategory,
        brand: _brandController.text.trim(),
        rating: _rating,
        reviewCount: _reviewCount,
        inStock: _inStock,
        tags: tags,
      );

      if (widget.product != null) {
        // Режим редактирования
        context.read<ProductsBloc>().add(UpdateProductEvent(product));
      } else {
        // Режим создания
        context.read<ProductsBloc>().add(CreateProductEvent(product));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Редактировать продукт' : 'Добавить продукт'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductCreateSuccess) {
            showSuccessSnackBar(context, 'Продукт успешно добавлен!');
            context.pop();
          } else if (state is ProductCreateError) {
            showErrorSnackBar(context, state.message);
          } else if (state is ProductUpdateSuccess) {
            showSuccessSnackBar(context, 'Продукт успешно обновлен!');
            context.pop();
          } else if (state is ProductUpdateError) {
            showErrorSnackBar(context, state.message);
          }
        },
        child: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            final isLoading = state is ProductCreating || state is ProductUpdating;
            return LoadingOverlay(
              isLoading: isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Название продукта *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите название продукта';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Описание *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите описание';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Цена *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите цену';
                          }
                          final price = double.tryParse(value.trim());
                          if (price == null || price <= 0) {
                            return 'Введите корректную цену';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL изображения *',
                          border: OutlineInputBorder(),
                          hintText: 'https://example.com/image.jpg',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите URL изображения';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Категория *',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(
                          labelText: 'Бренд *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите бренд';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Рейтинг: ${_rating.toStringAsFixed(1)}'),
                          ),
                          Expanded(
                            flex: 3,
                            child: Slider(
                              value: _rating,
                              min: 0,
                              max: 5,
                              divisions: 50,
                              label: _rating.toStringAsFixed(1),
                              onChanged: (value) {
                                setState(() {
                                  _rating = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: TextEditingController(text: _reviewCount.toString()),
                        decoration: const InputDecoration(
                          labelText: 'Количество отзывов',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _reviewCount = int.tryParse(value) ?? 0;
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('В наличии'),
                        value: _inStock,
                        onChanged: (value) {
                          setState(() {
                            _inStock = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Теги (через запятую)',
                          border: OutlineInputBorder(),
                          hintText: 'блеск, матовый, долговечный',
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.product != null ? 'Сохранить изменения' : 'Добавить продукт',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

