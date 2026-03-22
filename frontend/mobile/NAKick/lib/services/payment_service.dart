import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';

class PaymentService {
  static String get _host {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {}
    return 'localhost';
  }

  static String baseServerUrl = 'http://$_host:8085';
  static String baseUrl = '$baseServerUrl/api/payments';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Create a payment from cart items
  Future<Payment> createPayment({
    required String orderId,
    required double totalAmount,
    required List<CartItem> items,
    String currency = 'USD',
    String description = 'NAKick Order',
    String? returnUrl,
    String? cancelUrl,
    String paymentMethodId = 'pm_card_visa', // Default to visa test card
  }) async {
    try {
      final token = await _getToken();
      
      // Convert cart items to payment format
      final paymentItems = items
          .map((item) => {
                'name': '${item.brand} ${item.model}',
                'sku': item.skuId,
                'quantity': item.quantity,
                'unitPrice': item.price,
              })
          .toList();

      final response = await http.post(
        Uri.parse('$baseUrl/initiate'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'orderId': orderId,
          'amount': totalAmount,
          'currency': currency,
          'description': description,
          'paymentMethod': 'STRIPE',
          'items': paymentItems,
          'paymentMethodId': paymentMethodId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data);
      } else {
        throw Exception('Failed to initiate payment: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error initiating payment: $e');
      throw Exception('Error initiating payment: $e');
    }
  }

  /// Execute/approve a payment (Stripe - only needs paymentId)
  Future<Payment> executePayment({
    required String paymentId,
    required String orderId,
  }) async {
    try {
      final token = await _getToken();

      // Stripe service only needs paymentId parameter
      final response = await http.post(
        Uri.parse('$baseUrl/complete?paymentId=$paymentId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data);
      } else {
        throw Exception('Failed to complete payment: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error completing payment: $e');
      throw Exception('Error completing payment: $e');
    }
  }

  /// Get payment details
  Future<Payment> getPaymentDetails(String paymentId) async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/$paymentId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data);
      } else {
        throw Exception('Failed to get payment details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching payment details: $e');
      throw Exception('Error fetching payment details: $e');
    }
  }

  /// Handle payment success callback (Stripe)
  Future<Payment> handleSuccessCallback({
    required String paymentId,
    required String orderId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/success?payment_intent=$paymentId'),
      );

      if (response.statusCode == 200) {
        return await getPaymentDetails(paymentId);
      } else {
        throw Exception('Payment success callback failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error handling payment success: $e');
      throw Exception('Error handling payment success: $e');
    }
  }
}
