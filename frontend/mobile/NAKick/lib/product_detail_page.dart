import 'package:flutter/material.dart';
import 'favorite_page.dart';
import 'models/shoe.dart';
import 'services/sku_service.dart';
import 'services/shoe_service.dart';
import 'services/cart_service.dart';
import 'models/sku.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  String? _selectedColor;
  String? _selectedSize;
  String? _selectedSkuId;
  Sku? _selectedSku;
  bool _isLoadingSkus = false;
  List<Sku> _skus = [];

  final ShoeService _shoeService = ShoeService();
  final SkuService _skuService = SkuService();
  final CartService _cartService = CartService();

  List<String> get _uniqueColors => _skus.map((s) => s.color).toSet().toList();
  
  List<String> _getSizesForColor(String color) => 
      _skus.where((s) => s.color == color).map((s) => s.size).toSet().toList();

  void _updateSelectedSku() {
    if (_selectedColor != null && _selectedSize != null) {
      final sku = _skus.firstWhere(
        (s) => s.color == _selectedColor && s.size == _selectedSize,
        orElse: () => _skus.firstWhere((s) => s.color == _selectedColor, orElse: () => _skus.first),
      );
      setState(() {
        _selectedSku = sku;
        _selectedSkuId = sku.id;
        if (_quantity > sku.stock) _quantity = sku.stock;
        if (_quantity < 1) _quantity = 1;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final id = widget.product['id']?.toString();
    if (id != null && id.isNotEmpty) {
      _loadSkus(id);
    }
  }

  Future<void> _loadSkus(String productId) async {
    setState(() {
      _isLoadingSkus = true;
      _skus = [];
    });

    try {
      final skus = await _skuService.getSkusByProduct(productId);
      setState(() {
        _skus = skus;
        if (_skus.isNotEmpty) {
          _selectedSku = _skus.first;
          _selectedColor = _selectedSku!.color;
          _selectedSize = _selectedSku!.size;
          _selectedSkuId = _selectedSku!.id;
        }
      });
    } catch (e) {
      debugPrint('Failed to load SKUs: $e');
    } finally {
      setState(() => _isLoadingSkus = false);
    }
  }

  void _showSelectionBottomSheet(BuildContext context, {required bool isBuyNow}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Handle empty SKUs case
          if (_skus.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.info_outline, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'No Data Available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This product has no available options yet',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }

          final sku = _skus.firstWhere(
            (s) => s.color == _selectedColor && s.size == _selectedSize,
            orElse: () => _skus.firstWhere((s) => s.color == _selectedColor, orElse: () => _skus.first),
          );

          String displayImageUrl = sku.imageUrl;
          if (displayImageUrl.isEmpty) {
            displayImageUrl = widget.product['image'] ?? 'assets/images/sh1.png';
          }

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: displayImageUrl.startsWith('http')
                            ? Image.network(displayImageUrl, fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.directions_run, size: 50, color: Colors.grey))
                            : Image.asset(displayImageUrl, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${sku.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                          const SizedBox(height: 4),
                          Text('Stock: ${sku.stock}', style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 4),
                          Text(
                            'Selected: ${_selectedColor ?? ""}, ${_selectedSize ?? ""}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Color Selection
                const Text('Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 45,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _uniqueColors.map((color) {
                      final isSelected = _selectedColor == color;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedColor = color;
                              final sizes = _getSizesForColor(color);
                              if (!sizes.contains(_selectedSize)) _selectedSize = sizes.first;
                            });
                            setState(() => _updateSelectedSku());
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.redAccent : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? Colors.redAccent : Colors.grey[300]!),
                            ),
                            child: Text(
                              color,
                              style: TextStyle(color: isSelected ? Colors.white : Colors.grey[800], fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Size Selection
                const Text('Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 45,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _getSizesForColor(_selectedColor ?? "").map((size) {
                      final isSelected = _selectedSize == size;
                      final currentSku = _skus.firstWhere((s) => s.color == _selectedColor && s.size == size);
                      final inStock = currentSku.inStock && currentSku.stock > 0;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: inStock ? () {
                            setModalState(() => _selectedSize = size);
                            setState(() => _updateSelectedSku());
                          } : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.redAccent : (inStock ? Colors.grey[100] : Colors.grey[50]),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? Colors.redAccent : Colors.grey[300]!),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                color: isSelected ? Colors.white : (inStock ? Colors.grey[800] : Colors.grey[400]),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Quantity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _quantity > 1 ? () {
                              setModalState(() => _quantity--);
                              setState(() {});
                            } : null,
                          ),
                          Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _quantity < sku.stock ? () {
                              setModalState(() => _quantity++);
                              setState(() {});
                            } : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final available = await _skuService.checkAvailability(skuId: sku.id, quantity: _quantity);
                        if (!available) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Selected quantity not available'), backgroundColor: Colors.redAccent),
                            );
                          }
                          return;
                        }

                        if (isBuyNow) {
                          // Handle Buy Now
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Proceeding to checkout...'), backgroundColor: Colors.green),
                          );
                        } else {
                          // Add to Cart
                          await _cartService.addToCart(sku.id, _quantity);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart!'), backgroundColor: Colors.green),
                            );
                          }
                        }
                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isBuyNow ? 'Confirm Buy Now' : 'Confirm Add to Cart',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine which price to show
    String displayPrice = widget.product['price'] ?? '\$0';
    if (_selectedSku != null) {
      displayPrice = '\$${_selectedSku!.price.toStringAsFixed(2)}';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back, color: Colors.grey[800]),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.grey[800],
                  ),
                ),
                onPressed: () {
                  // Navigate to cart page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritePage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.grey[50],
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: widget.product['image'] != null && (widget.product['image'].startsWith('http') || widget.product['image'].startsWith('/'))
                        ? Image.network(
                            widget.product['image'],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading detail image: $error');
                              return Icon(
                                Icons.directions_run,
                                size: 120,
                                color: Colors.redAccent.withValues(alpha: 0.3),
                              );
                            },
                          )
                        : Image.asset(
                            widget.product['image'] ?? 'assets/images/sh1.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.directions_run,
                                size: 120,
                                color: Colors.redAccent.withValues(alpha: 0.3),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product['name'] ?? 'Product Name',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.product['rating'] ?? 4.5}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(120 reviews)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          displayPrice,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.product['description'] ??
                          'Experience ultimate comfort and style with these premium shoes. '
                              'Designed with cutting-edge technology and superior materials, '
                              'they provide exceptional support for all-day wear.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Features
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.product['category'] != null)
                      _buildFeatureItem(Icons.category, 'Category: ${widget.product['category']}'),
                    if (widget.product['brand'] != null)
                      _buildFeatureItem(Icons.branding_watermark, 'Brand: ${widget.product['brand']}'),
                    if (_selectedSku?.color != null && _selectedSku!.color.isNotEmpty)
                      _buildFeatureItem(Icons.color_lens, 'Color: ${_selectedSku!.color}'),
                    if (_selectedSku?.color == null && widget.product['color'] != null)
                      _buildFeatureItem(Icons.color_lens, 'Color: ${widget.product['color']}'),
                    _buildFeatureItem(Icons.check_circle, 'Premium quality materials'),
                    _buildFeatureItem(Icons.check_circle, 'Breathable mesh upper'),
                    _buildFeatureItem(Icons.check_circle, 'Cushioned sole for comfort'),
                    _buildFeatureItem(Icons.check_circle, 'Durable rubber outsole'),

                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Buy Now Button
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showSelectionBottomSheet(context, isBuyNow: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Buy Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Add to Cart Button
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showSelectionBottomSheet(context, isBuyNow: false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.redAccent, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_shopping_cart, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
