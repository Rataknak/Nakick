import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';

class CartService {
  static String get _host {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {}
    return 'localhost';
  }

  static String baseServerUrl = 'http://$_host:8080/cart-service';
  static String baseUrl = '$baseServerUrl/api/cart';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Cart> getCart() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Fix image URLs in items
        if (data['items'] != null) {
          for (var item in data['items']) {
            String imageUrl = item['imageUrl'] ?? '';
            if (imageUrl.startsWith('/')) {
              imageUrl = '$baseServerUrl$imageUrl';
            } else if (!kIsWeb && imageUrl.contains('localhost')) {
              imageUrl = imageUrl.replaceFirst('localhost', _host);
            }
            item['imageUrl'] = imageUrl;
          }
        }
        
        return Cart.fromJson(data);
      } else {
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching cart: $e');
      throw Exception('Error fetching cart: $e');
    }
  }

  Future<void> addToCart(String skuId, int quantity) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.post(
        Uri.parse('$baseUrl/items'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'skuId': skuId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add item to cart: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      throw Exception('Error adding to cart: $e');
    }
  }

  Future<void> updateItemQuantity(String itemId, int quantity) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.put(
        Uri.parse('$baseUrl/items/$itemId?quantity=$quantity'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update item quantity: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating item quantity: $e');
      throw Exception('Error updating item quantity: $e');
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.delete(
        Uri.parse('$baseUrl/items/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove item: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error removing item: $e');
      throw Exception('Error removing item: $e');
    }
  }
}
