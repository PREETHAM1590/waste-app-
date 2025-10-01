import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/design_tokens.dart';
import '../models/product.dart';
import '../widgets/shared/shared_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedImageIndex = 0;
  bool _isFavorite = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme),
          _buildProductInfo(theme),
          _buildTabSection(theme),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    final images = widget.product.images.isNotEmpty
        ? widget.product.images
        : [widget.product.imageUrl].whereType<String>().toList();

    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => GoRouter.of(context).pop(),
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_outline,
            color: _isFavorite ? Colors.red : null,
          ),
          onPressed: () => setState(() => _isFavorite = !_isFavorite),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: images.isNotEmpty
            ? Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _selectedImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage(theme);
                        },
                      );
                    },
                  ),
                  if (images.length > 1) ...[
                    Positioned(
                      bottom: DesignTokens.space16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: images.asMap().entries.map((entry) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: EdgeInsets.symmetric(horizontal: DesignTokens.space4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: entry.key == _selectedImageIndex
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              )
            : _buildPlaceholderImage(theme),
      ),
    );
  }

  Widget _buildPlaceholderImage(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.eco_outlined,
          size: 80,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildProductInfo(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: DesignTokens.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand and Title
            if (widget.product.brand.isNotEmpty) ...[
              Text(
                widget.product.brand.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              DesignTokens.space8.height,
            ],
            
            Text(
              widget.product.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            
            DesignTokens.space8.height,
            
            // Price and Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _buildRatingWidget(theme),
              ],
            ),
            
            DesignTokens.space16.height,
            
            // Sustainability Score
            WastewiseProgressCard(
              title: 'Sustainability Score',
              value: '${widget.product.sustainabilityScore.round()}%',
              subtitle: 'Eco-friendly rating',
              progress: widget.product.sustainabilityScore / 100,
              progressColor: DesignTokens.success,
              icon: const Icon(Icons.eco, color: DesignTokens.success),
            ),
            
            DesignTokens.space16.height,
            
            // Tags
            if (widget.product.tags.isNotEmpty) ...[
              Wrap(
                spacing: DesignTokens.space8,
                runSpacing: DesignTokens.space8,
                children: widget.product.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    labelStyle: theme.textTheme.labelSmall,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              DesignTokens.space16.height,
            ],
            
            // Stock Status
            _buildStockStatus(theme),
            
            DesignTokens.space16.height,
          ],
        ),
      ),
    );
  }

  Widget _buildRatingWidget(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: 20,
          color: Colors.amber,
        ),
        DesignTokens.space4.width,
        Text(
          widget.product.rating.toStringAsFixed(1),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        DesignTokens.space4.width,
        Text(
          '(${widget.product.reviewCount})',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStockStatus(ThemeData theme) {
    final inStock = widget.product.stockQuantity > 0;
    
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: inStock ? DesignTokens.success : DesignTokens.error,
          ),
        ),
        DesignTokens.space8.width,
        Text(
          inStock 
              ? 'In Stock (${widget.product.stockQuantity} available)'
              : 'Out of Stock',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: inStock ? DesignTokens.success : DesignTokens.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection(ThemeData theme) {
    return SliverFillRemaining(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Description'),
              Tab(text: 'Specifications'),
              Tab(text: 'Reviews'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDescriptionTab(theme),
                _buildSpecificationsTab(theme),
                _buildReviewsTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: DesignTokens.paddingMD,
      child: Text(
        widget.product.description,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildSpecificationsTab(ThemeData theme) {
    if (widget.product.specifications.isEmpty) {
      return const Center(
        child: Text('No specifications available'),
      );
    }
    
    return ListView.separated(
      padding: DesignTokens.paddingMD,
      itemCount: widget.product.specifications.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final entry = widget.product.specifications.entries.elementAt(index);
        return Padding(
          padding: EdgeInsets.symmetric(vertical: DesignTokens.space8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  entry.key,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  entry.value,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(ThemeData theme) {
    return const Center(
      child: Text('Reviews coming soon!'),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    final canAddToCart = widget.product.stockQuantity > 0;
    
    return Container(
      padding: DesignTokens.paddingMD,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector
            if (canAddToCart) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      icon: const Icon(Icons.remove),
                      iconSize: 20,
                    ),
                    Text(
                      _quantity.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: _quantity < widget.product.stockQuantity 
                          ? () => setState(() => _quantity++) 
                          : null,
                      icon: const Icon(Icons.add),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              DesignTokens.space16.width,
            ],
            
            // Add to Cart Button
            Expanded(
              child: ElevatedButton(
                onPressed: canAddToCart ? () => _addToCart() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: DesignTokens.space16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                  ),
                ),
                child: Text(
                  canAddToCart 
                      ? 'Add to Cart (\$${(widget.product.price * _quantity).toStringAsFixed(2)})'
                      : 'Out of Stock',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${widget.product.title} to cart'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            // Navigate to cart screen
          },
        ),
      ),
    );
  }
}
