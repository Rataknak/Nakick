import 'cart_item.dart';

class Cart {
  final String id;
  final String userId;
  final String userEmail;
  final List<CartItem> items;
  final double totalAmount;
  final int totalItems;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;

  Cart({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.totalAmount,
    required this.totalItems,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userEmail: json['userEmail'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      totalItems: json['totalItems'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      status: json['status'] ?? 'ACTIVE',
    );
  }
}
