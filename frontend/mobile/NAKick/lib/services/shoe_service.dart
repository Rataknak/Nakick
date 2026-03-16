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

  Future<List<Shoe>> getShoes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/shoes'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) {
          // Fix image URL if it's a local path or localhost
          String imageUrl = item['imageUrl'] ?? '';
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
}
