import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cosmetics_catalog/features/products/presentation/bloc/products_bloc.dart';
import 'package:cosmetics_catalog/features/products/presentation/widgets/product_card.dart';
import 'package:cosmetics_catalog/features/products/presentation/widgets/product_filter_sheet.dart';
import 'package:cosmetics_catalog/core/widgets/loading_overlay.dart';
import 'package:cosmetics_catalog/core/widgets/error_snackbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Все';
  String _selectedBrand = 'Все';
  String _sortBy = 'name';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    context.read<ProductsBloc>().add(
      GetProductsEvent(
        category: _selectedCategory == 'Все' ? null : _selectedCategory,
        brand: _selectedBrand == 'Все' ? null : _selectedBrand,
        sortBy: _sortBy,
      ),
    );
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      _loadProducts();
    } else {
      context.read<ProductsBloc>().add(
        SearchProductsEvent(query, sortBy: _sortBy),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог Косметики'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/add-product'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Добавить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () => context.push('/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-product'),
        tooltip: 'Добавить продукт',
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductsError) {
            showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is ProductsLoading,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Поиск продуктов...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _loadProducts();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: _searchProducts,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilterChip(
                              label: Text(_selectedCategory),
                              selected: _selectedCategory != 'Все',
                              onSelected: (selected) async {
                                final result = await showModalBottomSheet<String>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => ProductFilterSheet(
                                    type: 'category',
                                    currentValue: _selectedCategory,
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    _selectedCategory = result;
                                  });
                                  _loadProducts();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilterChip(
                              label: Text(_selectedBrand),
                              selected: _selectedBrand != 'Все',
                              onSelected: (selected) async {
                                final result = await showModalBottomSheet<String>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => ProductFilterSheet(
                                    type: 'brand',
                                    currentValue: _selectedBrand,
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    _selectedBrand = result;
                                  });
                                  _loadProducts();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.sort),
                            onSelected: (value) {
                              setState(() {
                                _sortBy = value;
                              });
                              _loadProducts();
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'name', child: Text('По названию')),
                              const PopupMenuItem(value: 'price_asc', child: Text('Цена: по возрастанию')),
                              const PopupMenuItem(value: 'price_desc', child: Text('Цена: по убыванию')),
                              const PopupMenuItem(value: 'rating', child: Text('По рейтингу')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state is ProductsLoaded
                      ? state.products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Продукты не найдены',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            )
                          : FadeTransition(
                              opacity: _animationController,
                              child: GridView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.7,
                                ),
                                itemCount: state.products.length,
                                itemBuilder: (context, index) {
                                  return ProductCard(
                                    product: state.products[index],
                                    onTap: () {
                                      context.push('/product/${state.products[index].id}');
                                    },
                                  );
                                },
                              ),
                            )
                      : const SizedBox(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

