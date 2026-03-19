import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'services/cart_service.dart';
import 'services/shoe_service.dart';
import 'models/cart.dart';
import 'models/cart_item.dart';
import 'product_detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final CartService _cartService = CartService();
  final ShoeService _shoeService = ShoeService();
  Cart? _cart;
  bool _isLoading = true;
  String? _error;

  final Set<String> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final cart = await _cartService.getCart();
      setState(() {
        _cart = cart;
        _isLoading = false;
        _selectedItemIds.removeWhere((id) => !cart.items.any((item) => item.id == id));
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  double get _selectedTotal {
    if (_cart == null) return 0.0;
    double total = 0.0;
    for (var item in _cart!.items) {
      if (_selectedItemIds.contains(item.id)) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  int get _selectedCount => _selectedItemIds.length;

  void _toggleSelectAll() {
    setState(() {
      if (_selectedItemIds.length == (_cart?.items.length ?? 0)) {
        _selectedItemIds.clear();
      } else {
        _selectedItemIds.addAll(_cart?.items.map((e) => e.id) ?? []);
      }
    });
  }

  Future<void> _updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity < 1) {
      _showDeleteConfirmation(itemId);
      return;
    }
    try {
      await _cartService.updateItemQuantity(itemId, newQuantity);
      _loadCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quantity: $e')),
        );
      }
    }
  }

  Future<void> _removeItem(String itemId) async {
    try {
      await _cartService.removeItem(itemId);
      setState(() => _selectedItemIds.remove(itemId));
      _loadCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: $e')),
        );
      }
    }
  }

  Future<void> _editItem(CartItem item) async {
    try {
      final shoe = await _shoeService.getShoeById(item.productId);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: shoe.toJson()),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading product details: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Remove from cart?'),
          content: const Text('This item will be removed from your shopping bag.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _removeItem(itemId);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 35),
            const SizedBox(width: 8),
            const Text(
              'NAKick',
              style: TextStyle(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[800], size: 22),
            onPressed: _loadCart,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : _error != null
              ? _buildErrorState()
              : (_cart == null || _cart!.items.isEmpty)
                  ? _buildEmptyState()
                  : _buildCartContent(),
      bottomNavigationBar: _cart != null && _cart!.items.isNotEmpty
          ? _buildCheckoutBottomBar()
          : null,
    );
  }

  Widget _buildCartContent() {
    bool allSelected = _selectedItemIds.length == (_cart?.items.length ?? 0) && (_cart?.items.isNotEmpty ?? false);

    return Column(
      children: [
        // Selection Header Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
          ),
          child: Row(
            children: [
              Checkbox(
                value: allSelected,
                activeColor: Colors.redAccent,
                shape: const CircleBorder(),
                onChanged: (val) => _toggleSelectAll(),
              ),
              const Text(
                'Select All Items',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (_selectedCount > 0)
                TextButton(
                  onPressed: () {
                    // Logic to delete all selected items could go here
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
            ],
          ),
        ),

        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _cart!.items.length,
            itemBuilder: (context, index) {
              final item = _cart!.items[index];
              return _buildCartCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartCard(CartItem item) {
    bool isSelected = _selectedItemIds.contains(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              onPressed: (context) => _editItem(item),
              backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
              foregroundColor: Colors.blueAccent,
              icon: Icons.edit_outlined,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (context) => _showDeleteConfirmation(item.id),
              backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
              foregroundColor: Colors.redAccent,
              icon: Icons.delete_outline,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? Colors.redAccent.withValues(alpha: 0.3) : Colors.grey[100]!),
          ),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                activeColor: Colors.redAccent,
                shape: const CircleBorder(),
                onChanged: (val) {
                  setState(() {
                    if (isSelected) {
                      _selectedItemIds.remove(item.id);
                    } else {
                      _selectedItemIds.add(item.id);
                    }
                  });
                },
              ),
              const SizedBox(width: 4),
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.imageUrl.startsWith('http')
                      ? Image.network(item.imageUrl, fit: BoxFit.contain)
                      : Image.asset('assets/images/sh1.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.brand} ${item.model}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Size: ${item.size} | Color: ${item.color}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.redAccent),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 14),
                                onPressed: () => _updateQuantity(item.id, item.quantity - 1),
                                constraints: const BoxConstraints(minWidth: 28),
                                padding: EdgeInsets.zero,
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 14, color: Colors.redAccent),
                                onPressed: () => _updateQuantity(item.id, item.quantity + 1),
                                constraints: const BoxConstraints(minWidth: 28),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount (${_selectedCount})',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${_selectedTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedCount > 0 ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey[200],
                ),
                child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('Something went wrong\n$_error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          TextButton(onPressed: _loadCart, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 20),
          const Text('Your shopping bag is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Go Shopping'),
          ),
        ],
      ),
    );
  }
}
