import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cosmetics_catalog/features/products/presentation/bloc/products_bloc.dart';
import 'package:cosmetics_catalog/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:cosmetics_catalog/core/widgets/loading_overlay.dart';
import 'package:cosmetics_catalog/core/widgets/error_snackbar.dart';
import 'package:cosmetics_catalog/core/widgets/success_snackbar.dart';
import 'package:cosmetics_catalog/core/services/notification_service.dart';
import 'package:go_router/go_router.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    context.read<ProductsBloc>().add(GetProductByIdEvent(widget.productId));
    
    // Загружаем избранное для проверки статуса
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<FavoritesBloc>().add(GetFavoritesEvent(user.uid));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context, product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить продукт?'),
        content: const Text('Вы уверены, что хотите удалить этот продукт? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProductsBloc>().add(DeleteProductEvent(product.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(String userId) {
    if (_isFavorite) {
      context.read<FavoritesBloc>().add(
        RemoveFromFavoritesEvent(userId, widget.productId),
      );
    } else {
      context.read<FavoritesBloc>().add(
        AddToFavoritesEvent(userId, widget.productId),
      );
      NotificationService.instance.showFavoriteNotification(
        productName: 'Product',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final priceFormat = NumberFormat.currency(
      locale: 'ru_RU',
      symbol: 'руб',
      decimalDigits: 0,
    );

    return Scaffold(
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductDetailError) {
            showErrorSnackBar(context, state.message);
          } else if (state is ProductUpdateSuccess) {
            showSuccessSnackBar(context, 'Продукт успешно обновлен!');
          } else if (state is ProductUpdateError) {
            showErrorSnackBar(context, state.message);
          } else if (state is ProductDeleteSuccess) {
            showSuccessSnackBar(context, 'Продукт удален');
            Navigator.pop(context);
          } else if (state is ProductDeleteError) {
            showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is ProductDetailLoaded) {
            return LoadingOverlay(
              isLoading: false,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 300,
                      pinned: true,
                      floating: false,
                      snap: false,
                      flexibleSpace: FlexibleSpaceBar(
                        background: CachedNetworkImage(
                          imageUrl: state.product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      actions: [
                        if (user != null)
                          BlocListener<FavoritesBloc, FavoritesState>(
                            listener: (context, favState) {
                              if (favState is FavoritesLoaded) {
                                final favoriteIds = favState.favorites
                                    .map((f) => f.productId)
                                    .toList();
                                final wasFavorite = _isFavorite;
                                setState(() {
                                  _isFavorite = favoriteIds.contains(widget.productId);
                                });
                                // Показываем сообщение только если статус изменился (после действия пользователя)
                                if (_isFavorite && !wasFavorite && wasFavorite == false) {
                                  showSuccessSnackBar(
                                    context,
                                    'Добавлено в избранное!',
                                  );
                                } else if (!_isFavorite && wasFavorite && wasFavorite == true) {
                                  showSuccessSnackBar(
                                    context,
                                    'Удалено из избранного',
                                  );
                                }
                              } else if (favState is FavoritesError) {
                                // Показываем ошибку только если это не первая загрузка
                                // (чтобы не показывать ошибку при открытии страницы, если избранное пустое)
                                if (_isFavorite || favState.message.contains('index')) {
                                  // Не показываем ошибку индекса, так как мы уже исправили запрос
                                  return;
                                }
                              }
                            },
                            child: IconButton(
                              icon: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.white,
                              ),
                              onPressed: () => _toggleFavorite(user.uid),
                            ),
                          ),
                        // Меню редактирования/удаления всегда видно
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                          color: Colors.white,
                          onSelected: (value) {
                            if (value == 'edit') {
                              context.push('/edit-product', extra: state.product);
                            } else if (value == 'delete') {
                              _showDeleteDialog(context, state.product);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Color(0xFFE91E63)),
                                  SizedBox(width: 12),
                                  Text('Редактировать'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 12),
                                  Text('Удалить'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.product.brand,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        state.product.name,
                                        style: Theme.of(context).textTheme.displaySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                if (state.product.rating > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${state.product.rating.toStringAsFixed(1)} (${state.product.reviewCount})',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              priceFormat.format(state.product.price),
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: const Color(0xFFE91E63),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              children: [
                                Chip(
                                  label: Text(state.product.category),
                                  backgroundColor: const Color(0xFFFFC1CC),
                                ),
                                if (!state.product.inStock)
                                  const Chip(
                                    label: Text('Нет в наличии'),
                                    backgroundColor: Colors.red,
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Кнопки редактирования и удаления
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      context.push('/edit-product', extra: state.product);
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Редактировать'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE91E63),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _showDeleteDialog(context, state.product);
                                    },
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Удалить'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Описание',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.product.description,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            if (state.product.tags.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Text(
                                'Теги',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: state.product.tags.map((tag) {
                                  return Chip(
                                    label: Text(tag),
                                    backgroundColor: Colors.grey[200],
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ProductDetailLoading) {
            return const LoadingOverlay(
              isLoading: true,
              child: SizedBox(),
            );
          } else {
            return const Center(
              child: Text('Продукт не найден'),
            );
          }
        },
      ),
    );
  }
}

