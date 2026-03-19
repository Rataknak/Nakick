import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/shoe.dart';

class ShoeService {
  // For Android Emulator, use 10.0.2.2. For iOS Simulator/Web, use localhost.
  static String get _host {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {}
    return 'localhost';
  }

  static String baseServerUrl = 'http://$_host:8080/shoes-service';
  static String baseUrl = '$baseServerUrl/api';

  // Accept optional filters for brand and category
  Future<List<Shoe>> getShoes({String? brand, String? category}) async {
    try {
      // Build query params if provided
      final queryParams = <String, String>{};
      if (brand != null && brand.isNotEmpty) queryParams['brand'] = brand;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;

      String url = '$baseUrl/shoes';
      if (queryParams.isNotEmpty) {
        final qp = queryParams.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&');
        url = '$url?$qp';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) {
          // Fix image URL if it's a local path or localhost
          String imageUrl = item['imageUrl'] ?? item['image_url'] ?? '';
          if (imageUrl.startsWith('/')) {
            imageUrl = '$baseServerUrl$imageUrl';
          } else if (!kIsWeb && imageUrl.contains('localhost')) {
            imageUrl = imageUrl.replaceFirst('localhost', _host);
          }
          item['imageUrl'] = imageUrl;

          return Shoe.fromJson(item);
        }).toList();
      } else {
        throw Exception('Failed to load shoes: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching shoes: $e');
      throw Exception('Error fetching shoes: $e');
    }
  }

  Future<Shoe> getShoeById(String id, {bool includeSkus = false}) async {
    try {
      String url = '$baseUrl/shoes/$id';
      if (includeSkus) {
        url += '?includeSkus=true';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(response.body);

        // Fix image URL if it's a local path or localhost
        String imageUrl = body['imageUrl'] ?? body['image_url'] ?? '';
        if (imageUrl.startsWith('/')) {
          imageUrl = '$baseServerUrl$imageUrl';
        } else if (!kIsWeb && imageUrl.contains('localhost')) {
          imageUrl = imageUrl.replaceFirst('localhost', _host);
        }
        body['imageUrl'] = imageUrl;

        return Shoe.fromJson(body);
      } else {
        throw Exception('Failed to load shoe: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching shoe: $e');
      throw Exception('Error fetching shoe: $e');
    }
  }
}
