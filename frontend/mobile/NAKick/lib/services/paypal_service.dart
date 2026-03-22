import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class PayPalService {
  static String get _host {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {}
    return 'localhost';
  }

  // Route through Payment Service directly
  static String baseUrl = 'http://$_host:8085/api/payments';
  final Dio _dio = Dio();

  PayPalService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {'Content-Type': 'application/json'};
  }

  Future<Map<String, dynamic>> createPayment({
    required String orderId,
    required double amount,
    required String currency,
    required String description,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      // Use /initiate instead of /create
      final response = await _dio.post('/initiate', data: {
        'orderId': orderId,
        'amount': amount,
        'currency': currency,
        'description': description,
        'paymentMethod': 'PAYPAL',
        'items': items.map((item) => {
          'name': item['productName'],
          'sku': item['skuCode'],
          'quantity': item['quantity'],
          'unitPrice': item['unitPrice'],
        }).toList(),
      });
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to initiate payment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Payment initiation failed: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Payment initiation error: $e');
    }
  }

  Future<Map<String, dynamic>> executePayment({
    required String paymentId,
    required String payerId,
    required String orderId,
  }) async {
    try {
      // Use /complete instead of /execute
      final response = await _dio.post('/complete', queryParameters: {
        'paymentId': paymentId,
        'payerId': payerId,
      });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to complete payment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Payment completion failed: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Payment completion error: $e');
    }
  }

  Future<Map<String, dynamic>> getPaymentDetails(String paymentId) async {
    try {
      final response = await _dio.get('/$paymentId');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get payment details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get payment details: ${e.message}');
    } catch (e) {
      throw Exception('Payment details error: $e');
    }
  }

  Future<bool> launchPayPalUrl(String approvalUrl) async {
    try {
      final uri = Uri.parse(approvalUrl);
      if (await canLaunchUrl(uri)) {
        // Use LaunchMode.externalApplication to open in system browser
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        throw Exception('Could not launch PayPal URL: $approvalUrl');
      }
    } catch (e) {
      throw Exception('Failed to launch PayPal: $e');
    }
  }
}
