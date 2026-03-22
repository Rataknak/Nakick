import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'login_page.dart';
import 'payment_success_page.dart';
import 'payment_cancel_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe with your publishable key
  // For testing, use a test key. In production, use your live key
  Stripe.publishableKey = 'pk_test_51234567890abcdef'; // Replace with your actual test key
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nakick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F3460),
          primary: const Color(0xFF0F3460),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        '/payment/success': (context) => const PaymentSuccessPage(),
        '/payment/cancel': (context) => const PaymentCancelPage(),
      },
    );
  }
}
