import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cosmetics_catalog/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:cosmetics_catalog/features/products/presentation/bloc/products_bloc.dart';
import 'package:cosmetics_catalog/features/products/presentation/widgets/product_card.dart';
import 'package:cosmetics_catalog/core/widgets/loading_overlay.dart';
import 'package:cosmetics_catalog/core/widgets/error_snackbar.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои избранные'),
      ),
      body: user == null
          ? const Center(
              child: Text('Пожалуйста, войдите в систему для просмотра избранного'),
            )
          : BlocConsumer<FavoritesBloc, FavoritesState>(
              listener: (context, state) {
                if (state is FavoritesError) {
                  showErrorSnackBar(context, state.message);
                }
              },
              builder: (context, state) {
                return LoadingOverlay(
                  isLoading: state is FavoritesLoading,
                  child: state is FavoritesLoaded
                      ? state.favorites.isEmpty
                          ? FadeTransition(
                              opacity: _fadeAnimation,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.favorite_border,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Пока нет избранных',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Начните добавлять продукты в избранное!',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : FadeTransition(
                              opacity: _fadeAnimation,
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  context.read<FavoritesBloc>().add(
                                        GetFavoritesEvent(user.uid),
                                      );
                                },
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.7,
                                  ),
                                  itemCount: state.favorites.length,
                                  itemBuilder: (context, index) {
                                    final favorite = state.favorites[index];
                                    // Load product details
                                    context.read<ProductsBloc>().add(
                                          GetProductByIdEvent(favorite.productId),
                                        );
                                    return BlocBuilder<ProductsBloc, ProductsState>(
                                      builder: (context, productState) {
                                        if (productState is ProductDetailLoaded &&
                                            productState.product.id == favorite.productId) {
                                          return ProductCard(
                                            product: productState.product,
                                            onTap: () {
                                              context.push('/product/${favorite.productId}');
                                            },
                                          );
                                        }
                                        return const Card(
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            )
                      : const SizedBox(),
                );
              },
            ),
    );
  }
}

