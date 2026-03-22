import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'services/cart_service.dart';
import 'services/shoe_service.dart';
import 'services/payment_service.dart';
import 'services/paypal_service.dart';
import 'models/cart.dart';
import 'models/cart_item.dart';
import 'models/payment.dart';
import 'product_detail_page.dart';
import 'pages/payment_page.dart';
import 'pages/stripe_payment_page.dart';
import 'payment_success_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final CartService _cartService = CartService();
  final ShoeService _shoeService = ShoeService();
  final PaymentService _paymentService = PaymentService();
  final PayPalService _paypalService = PayPalService();
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

  Future<void> _clearSelectedItems() async {
    if (_selectedItemIds.isEmpty) return;

    final itemsToRemove = List<String>.from(_selectedItemIds);
    
    try {
      for (final itemId in itemsToRemove) {
        await _cartService.removeItem(itemId);
      }
      
      if (mounted) {
        setState(() {
          _selectedItemIds.clear();
        });
        await _loadCart();
      }
    } catch (e) {
      debugPrint('Error clearing items: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating cart: $e')),
        );
      }
    }
  }

  Future<void> _proceedToCheckout() async {
    if (_selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select items to checkout')),
      );
      return;
    }

    if (_cart == null) return;

    // Calculate total for selected items
    double selectedTotal = 0.0;
    List<CartItem> selectedItems = [];
    for (var item in _cart!.items) {
      if (_selectedItemIds.contains(item.id)) {
        selectedTotal += item.price * item.quantity;
        selectedItems.add(item);
      }
    }

    // Show Order Summary Dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: Column(
          children: [
            Image.asset('assets/images/logo.png', height: 60),
            const SizedBox(height: 12),
            const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const Text('Please review your items', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.normal)),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 32),
              // Items List
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedItems.length,
                    itemBuilder: (context, index) {
                      final item = selectedItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
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
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildDetailBadge('Size', item.size),
                                      const SizedBox(width: 8),
                                      _buildDetailBadge('Color', item.color),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Qty: ${item.quantity}',
                                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                      Text(
                                        '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.redAccent),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[800])),
                  Text(
                    '\$${selectedTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Stripe Button (Main Color)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _payWithStripe(selectedItems, selectedTotal);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: Colors.redAccent.withOpacity(0.4),
                  ),
                  child: const Text('PROCEED TO PAYMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.2)),
                ),
              ),
              const SizedBox(height: 8),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Back to Cart', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11, color: Colors.black87),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Future<void> _payWithStripe(List<CartItem> selectedItems, double total) async {
    final String orderId = 'ORD-STRIPE-${DateTime.now().millisecondsSinceEpoch}';

    try {
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StripePaymentPage(
              orderId: orderId,
              totalAmount: total,
              description: 'NAKick Stripe Order - ${selectedItems.length} items',
              items: selectedItems,
            ),
          ),
        );

        // Clear selection since items were either paid for or we just want to reset
        setState(() {
          _selectedItemIds.clear();
        });
        await _loadCart();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stripe payment error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _payWithPayPal(List<CartItem> selectedItems, double total) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.redAccent),
              SizedBox(width: 20),
              Text('Initializing PayPal...'),
            ],
          ),
        ),
      );

      final String orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      // Create items list for PayPal
      List<Map<String, dynamic>> paypalItems = selectedItems.map((item) => {
        'productId': item.productId,
        'productName': '${item.brand} ${item.model}',
        'skuCode': item.skuId,
        'quantity': item.quantity,
        'unitPrice': item.price,
      }).toList();

      // Create payment request
      final paymentData = await _paypalService.createPayment(
        orderId: orderId,
        amount: total,
        currency: 'USD',
        description: 'NAKick Order - ${selectedItems.length} items',
        items: paypalItems,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to PaymentPage with the created payment
      if (mounted) {
        final result = await Navigator.push<Payment>(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              orderId: orderId,
              totalAmount: total,
              description: 'NAKick Order - ${selectedItems.length} items',
              items: selectedItems,
              initialPayment: Payment.fromJson(paymentData),
            ),
          ),
        );

        if (result != null && (result.status == 'COMPLETED' || result.status == 'succeeded')) {
          // Success! Now clear these items from the backend cart
          await _clearSelectedItems();
          
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentSuccessPage(
                  paymentId: result.paymentId,
                  orderId: result.orderId,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PayPal initialization failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
                  onPressed: _clearSelectedItems,
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
                onPressed: _selectedCount > 0 ? _proceedToCheckout : null,
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
