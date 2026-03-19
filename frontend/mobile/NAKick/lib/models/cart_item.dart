class CartItem {
  final String id;
  final String skuId;
  final String productId;
  final String brand;
  final String model;
  final String size;
  final String color;
  final double price;
  final int quantity;
  final String imageUrl;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.skuId,
    required this.productId,
    required this.brand,
    required this.model,
    required this.size,
    required this.color,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? '',
      skuId: json['skuId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      size: json['size']?.toString() ?? '',
      color: json['color'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      addedAt: json['addedAt'] != null ? DateTime.parse(json['addedAt']) : DateTime.now(),
    );
  }
}
