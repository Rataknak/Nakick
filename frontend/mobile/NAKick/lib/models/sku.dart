class Sku {
  final String id;
  final String productId;
  final String color;
  final String size;
  final double price;
  final int stock;
  final String imageUrl;
  final String skuCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool inStock;

  Sku({
    required this.id,
    required this.productId,
    required this.color,
    required this.size,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.skuCode,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.inStock,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory Sku.fromJson(Map<String, dynamic> json) {
    return Sku(
      id: json['id']?.toString() ?? '',
      productId: json['productId'] ?? json['product_id'] ?? '',
      color: json['color'] ?? '',
      size: json['size']?.toString() ?? '',
      price: _toDouble(json['price']),
      stock: json['stock'] ?? 0,
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      skuCode: json['skuCode'] ?? json['sku_code'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      inStock: json['inStock'] ?? json['in_stock'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'color': color,
      'size': size,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'skuCode': skuCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'inStock': inStock,
    };
  }
}
