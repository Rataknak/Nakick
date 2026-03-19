import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:logger/logger.dart';
import '../models/payment_model.dart';
import '../config/api_config.dart';

class PayPalService {
  static final Dio _dio = Dio();
  static final Logger _logger = Logger();

  // PayPal Configuration
  static const String _clientId = 'AdVcFivKk1XGdSqWpN3PZv3s3o7Q_pOTU9zMLwqthTkzGLGnGu6-3IvIzjLFz-WKYgH0eqb8bQeCjXNr';
  static const String _sandboxMode = 'sandbox';
  

  static Future<PaymentResponse?> createPayment({
    required String orderId,
    required double amount,
    required String description,
    List<CartItem>? items,
  }) async {
    try {
      // First create payment on backend
      final paymentRequest = {
        'orderId': orderId,
        'amount': amount,
        'currency': 'USD',
        'description': description,
        'items': items?.map((item) => item.toJson()).toList(),
      };

      final response = await _dio.post(
        '${ApiConfig.paymentServiceUrl}/api/payments/create',
        data: paymentRequest,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${await _getAuthToken()}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final paymentData = response.data;
        return PaymentResponse.fromJson(paymentData);
      } else {
        _logger.e('Failed to create payment: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error creating payment: $e');
      return null;
    }
  }

  static Future<PaymentResponse?> executePayment({
    required String paymentId,
    required String payerId,
    required String orderId,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.paymentServiceUrl}/api/payments/execute',
        data: {
          'paymentId': paymentId,
          'payerId': payerId,
          'orderId': orderId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ${await _getAuthToken()}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final paymentData = response.data;
        return PaymentResponse.fromJson(paymentData);
      } else {
        _logger.e('Failed to execute payment: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error executing payment: $e');
      return null;
    }
  }

  static Future<PaymentDetails?> getPaymentDetails(String paymentId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.paymentServiceUrl}/api/payments/$paymentId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAuthToken()}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final paymentData = response.data;
        return PaymentDetails.fromJson(paymentData);
      } else {
        _logger.e('Failed to get payment details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error getting payment details: $e');
      return null;
    }
  }

  static Future<String> _getAuthToken() async {
    // Get auth token from shared preferences
    // This should be implemented based on your auth flow
    return 'your-auth-token-here';
  }

  static Future<Map<String, dynamic>> checkoutWithPayPal({
    required List<CartItem> items,
    required double totalAmount,
    required String orderId,
  }) async {
    try {
      // Step 1: Create payment on backend
      final paymentResponse = await createPayment(
        orderId: orderId,
        amount: totalAmount,
        description: 'NAKick Shoes Purchase',
        items: items,
      );

      if (paymentResponse == null) {
        return {'success': false, 'error': 'Failed to create payment'};
      }

      // Step 2: Return approval URL for the UI to handle PayPal checkout.
      // Use the approvalUrl (e.g., with the package's UsePaypal widget or a WebView) to complete payment in the UI layer.
      return {
        'success': true,
        'paymentId': paymentResponse.paymentId,
        'approvalUrl': paymentResponse.approvalUrl,
      };
    } catch (e) {
      _logger.e('PayPal checkout error: $e');
      return {
        'success': false,
        'error': 'Payment processing failed',
      };
    }
  }
}
