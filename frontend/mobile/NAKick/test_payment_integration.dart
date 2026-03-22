import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const baseUrl = 'http://localhost:8085/api/payments';
  
  print('🧪 Testing Payment Service Integration...\n');
  
  // Test 1: Create a payment intent
  print('1. Creating payment intent...');
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/initiate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'orderId': 'TEST-ORDER-123',
        'amount': 29.99,
        'currency': 'USD',
        'description': 'Test Payment - Nike Shoes',
      }),
    );
    
    print('   Status Code: ${response.statusCode}');
    print('   Response: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('   ✅ Payment created successfully!');
      print('   📝 Payment ID: ${data['paymentId']}');
      print('   🔑 Client Secret: ${data['clientSecret']?.toString().substring(0, 20)}...');
      
      // Test 2: Get payment details
      print('\n2. Getting payment details...');
      final paymentId = data['paymentId'];
      final getResponse = await http.get(Uri.parse('$baseUrl/$paymentId'));
      
      print('   Status Code: ${getResponse.statusCode}');
      print('   Response: ${getResponse.body}');
      
      if (getResponse.statusCode == 200) {
        print('   ✅ Payment details retrieved successfully!');
      } else {
        print('   ❌ Failed to get payment details');
      }
      
    } else {
      print('   ❌ Failed to create payment');
    }
    
  } catch (e) {
    print('   ❌ Error: $e');
  }
  
  print('\n🎯 Integration test completed!');
  print('📱 Your Flutter app can now connect to the payment service!');
}
