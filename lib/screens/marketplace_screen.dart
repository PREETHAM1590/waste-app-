import 'package:flutter/material.dart';

import '../core/design_tokens.dart';
import '../services/mock_data_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with TickerProviderStateMixin {
  final MarketplaceService _marketplaceService = MarketplaceService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  List<Map<String, dynamic>> _products = [];
  List<String> _categories = [];
  String _selectedCategory = 'all';
  bool _isLoading = true;
  bool _showFilters = false;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final categories = _marketplaceService.getCategories();
      final products = await _marketplaceService.getItems(
        category: _selectedCategory,
        maxPrice: _maxPrice,
        searchQuery: _searchController.text,
      );
      
      setState(() {
        _categories = categories;
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(theme),
            _buildSearchSliver(theme),
            _buildTabBarSliver(theme),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAllProductsTab(theme),
            _buildFeaturedTab(theme),
            _buildSustainableTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      snap: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      title: Text(
        'Marketplace',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune),
          onPressed: () {
            setState(() => _showFilters = !_showFilters);
          },
          tooltip: 'Filter',
        ),
        IconButton(
          icon: const Icon(Icons.favorite_outline),
          onPressed: () {},
          tooltip: 'Wishlist',
        ),
      ],
    );
  }

  Widget _buildSearchSliver(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: DesignTokens.paddingMD,
        child: Column(
          children: [
            // Search Bar
            SearchBar(
              controller: _searchController,
              hintText: 'Search eco-friendly products...',
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(horizontal: DesignTokens.space16),
              ),
              onSubmitted: (_) => _loadData(),
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _loadData();
                    },
                  ),
              ],
            ),
            
            // Category Filter Chips
            DesignTokens.space16.height,
            SizedBox(
              height: DesignTokens.chipM3Height + DesignTokens.space8,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => DesignTokens.space8.width,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  
                  return FilterChip(
                    label: Text(category.toUpperCase()),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                      _loadData();
                    },
                    backgroundColor: theme.colorScheme.surfaceContainerLow,
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.outline,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarSliver(ThemeData theme) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 2,
      toolbarHeight: 0,
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'All Products'),
          Tab(text: 'Featured'),
          Tab(text: 'Sustainable'),
        ],
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall,
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }

  Widget _buildAllProductsTab(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            DesignTokens.space16.height,
            Text(
              'No products found',
              style: theme.textTheme.headlineSmall,
            ),
            DesignTokens.space8.height,
            Text(
              'Try adjusting your search or filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: DesignTokens.paddingMD,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: DesignTokens.space12,
        mainAxisSpacing: DesignTokens.space16,
        childAspectRatio: 0.75,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_products[index], theme);
      },
    );
  }

  Widget _buildFeaturedTab(ThemeData theme) {
    return const Center(
      child: Text('Featured products coming soon!'),
    );
  }

  Widget _buildSustainableTab(ThemeData theme) {
    return const Center(
      child: Text('Sustainable picks coming soon!'),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, ThemeData theme) {
    return Card(
      elevation: DesignTokens.cardElevated,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
              ),
              child: product['imageUrl'] != null
                  ? Image.network(
                      product['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage(theme);
                      },
                    )
                  : _buildPlaceholderImage(theme),
            ),
          ),
          
          // Product Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: DesignTokens.paddingSM,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    product['title'] ?? 'Product',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  DesignTokens.space4.height,
                  
                  // Description
                  Text(
                    product['description'] ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(),
                  
                  // Price and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.eco,
                            size: 16,
                            color: DesignTokens.primaryGreen,
                          ),
                          DesignTokens.space4.width,
                          Text(
                            '${product['sustainabilityScore'] ?? 90}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: DesignTokens.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
      ),
      child: Icon(
        Icons.eco_outlined,
        size: 48,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
