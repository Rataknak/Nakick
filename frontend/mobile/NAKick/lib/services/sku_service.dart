import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/sku.dart';

class SkuService {
  static String get _host {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {}
    return 'localhost';
  }

  static String baseServerUrl = 'http://$_host:8080/shoes-service';
  static String baseUrl = '$baseServerUrl/api';

  Future<List<Sku>> getAllSkus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/skus'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((e) {
          final item = e as Map<String, dynamic>;
          // fix image url
          String imageUrl = item['imageUrl'] ?? item['image_url'] ?? '';
          if (imageUrl.startsWith('/')) imageUrl = '$baseServerUrl$imageUrl';
          if (!kIsWeb && imageUrl.contains('localhost')) imageUrl = imageUrl.replaceFirst('localhost', _host);
          item['imageUrl'] = imageUrl;
          return Sku.fromJson(item);
        }).toList();
      } else {
        throw Exception('Failed to load skus: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching skus: $e');
      throw Exception('Error fetching skus: $e');
    }
  }

  Future<Sku> getSkuById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/skus/$id'));
      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(response.body);
        String imageUrl = body['imageUrl'] ?? body['image_url'] ?? '';
        if (imageUrl.startsWith('/')) imageUrl = '$baseServerUrl$imageUrl';
        if (!kIsWeb && imageUrl.contains('localhost')) imageUrl = imageUrl.replaceFirst('localhost', _host);
        body['imageUrl'] = imageUrl;
        return Sku.fromJson(body);
      } else {
        throw Exception('Failed to load sku: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching sku: $e');
      throw Exception('Error fetching sku: $e');
    }
  }

  Future<List<Sku>> getSkusByProduct(String productId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/skus/product/$productId'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((e) {
          final item = e as Map<String, dynamic>;
          String imageUrl = item['imageUrl'] ?? item['image_url'] ?? '';
          if (imageUrl.startsWith('/')) imageUrl = '$baseServerUrl$imageUrl';
          if (!kIsWeb && imageUrl.contains('localhost')) imageUrl = imageUrl.replaceFirst('localhost', _host);
          item['imageUrl'] = imageUrl;
          return Sku.fromJson(item);
        }).toList();
      } else {
        throw Exception('Failed to load skus by product: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching skus by product: $e');
      throw Exception('Error fetching skus by product: $e');
    }
  }

  Future<List<Sku>> getAvailableSkus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/skus/available'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((e) {
          final item = e as Map<String, dynamic>;
          String imageUrl = item['imageUrl'] ?? item['image_url'] ?? '';
          if (imageUrl.startsWith('/')) imageUrl = '$baseServerUrl$imageUrl';
          if (!kIsWeb && imageUrl.contains('localhost')) imageUrl = imageUrl.replaceFirst('localhost', _host);
          item['imageUrl'] = imageUrl;
          return Sku.fromJson(item);
        }).toList();
      } else {
        throw Exception('Failed to load available skus: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching available skus: $e');
      throw Exception('Error fetching available skus: $e');
    }
  }

  Future<List<Sku>> searchSkus({String? color, String? size}) async {
    try {
      final Map<String, String> q = {};
      if (color != null && color.isNotEmpty) q['color'] = color;
      if (size != null && size.isNotEmpty) q['size'] = size;
      String url = '$baseUrl/skus/search';
      if (q.isNotEmpty) {
        final qp = q.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&');
        url = '$url?$qp';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((e) {
          final item = e as Map<String, dynamic>;
          String imageUrl = item['imageUrl'] ?? item['image_url'] ?? '';
          if (imageUrl.startsWith('/')) imageUrl = '$baseServerUrl$imageUrl';
          if (!kIsWeb && imageUrl.contains('localhost')) imageUrl = imageUrl.replaceFirst('localhost', _host);
          item['imageUrl'] = imageUrl;
          return Sku.fromJson(item);
        }).toList();
      } else {
        throw Exception('Failed to search skus: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching skus: $e');
      throw Exception('Error searching skus: $e');
    }
  }

  Future<bool> checkAvailability({required String skuId, required int quantity}) async {
    try {
      final url = '$baseUrl/skus/check-availability?skuId=${Uri.encodeQueryComponent(skuId)}&quantity=$quantity';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final body = response.body.trim();
        // backend returns true/false
        if (body.toLowerCase() == 'true' || body == '1') return true;
        if (body.toLowerCase() == 'false' || body == '0') return false;
        // try json decode
        final val = jsonDecode(response.body);
        if (val is bool) return val;
        return false;
      } else {
        throw Exception('Failed to check availability: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error checking availability: $e');
      throw Exception('Error checking availability: $e');
    }
  }

  Future<Map<String, dynamic>> getProductSkuStats(String productId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/skus/product/$productId/stats'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load product sku stats: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching product sku stats: $e');
      throw Exception('Error fetching product sku stats: $e');
    }
  }
}
