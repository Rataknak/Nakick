class Shoe {
  final String id;
  final String brand;
  final String model;
  final String description;
  final String category;
  final double basePrice;
  final String imageUrl;
  final double minPrice;
  final double maxPrice;
  final int totalStock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<dynamic>? skus;

  Shoe({
    required this.id,
    required this.brand,
    required this.model,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.imageUrl,
    required this.minPrice,
    required this.maxPrice,
    required this.totalStock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.skus,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory Shoe.fromJson(Map<String, dynamic> json) {
    // Try basePrice, then base_price, then price for maximum compatibility
    double priceValue = _toDouble(json['basePrice'] ?? json['base_price'] ?? json['price']);
    
    return Shoe(
      id: json['id']?.toString() ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      basePrice: priceValue,
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      minPrice: _toDouble(json['minPrice'] ?? json['min_price']),
      maxPrice: _toDouble(json['maxPrice'] ?? json['max_price']),
      totalStock: json['totalStock'] ?? json['total_stock'] ?? 0,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      skus: json['skus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'description': description,
      'category': category,
      'basePrice': basePrice,
      'imageUrl': imageUrl,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'totalStock': totalStock,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'skus': skus,
    };
  }

  Map<String, dynamic> toLegacyMap() {
    return {
      'name': '$brand $model',
      'price': '\$${basePrice.toStringAsFixed(2)}',
      'image': imageUrl,
      'rating': 4.5,
      'description': description,
      'category': category,
      'brand': brand,
      'model': model,
      'stock': totalStock,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
    };
  }
}
