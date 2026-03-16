import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Phase handling
  int _currentPhase = 1; // 1: Email (OTP), 2: Verify OTP, 3: Details
  bool _isLoading = false;

  // Controllers
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Tokens
  String? _tempToken;
  String? _verifiedEmailToken;

  final String _baseUrl = 'http://localhost:8080/auth-service/api/auth';

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // Phase 1: Generate OTP
  Future<void> _generateOTP() async {
    if (_emailController.text.isEmpty) {
      _showError("Please enter your email");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final body = jsonEncode({'email': _emailController.text.trim()});
      debugPrint("OTP Request: $body");
      
      final response = await http.post(
        Uri.parse('$_baseUrl/generate-otp'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint("OTP Response (${response.statusCode}): ${response.body}");
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _tempToken = data['token'];
          _currentPhase = 2;
        });
      } else {
        _showError(data['message'] ?? "Failed to send OTP");
      }
    } catch (e) {
      debugPrint("OTP Error: $e");
      _showError("Connection error. Is backend running?");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Phase 2: Verify OTP
  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      _showError("Please enter 6-digit OTP");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final body = jsonEncode({
        'tempToken': _tempToken,
        'otp': _otpController.text.trim(),
      });
      debugPrint("Verify Request: $body");

      final response = await http.post(
        Uri.parse('$_baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint("Verify Response (${response.statusCode}): ${response.body}");
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _verifiedEmailToken = data['token'];
          _currentPhase = 3;
        });
      } else {
        _showError(data['message'] ?? "OTP Verification failed");
      }
    } catch (e) {
      debugPrint("Verify Error: $e");
      _showError("Connection error.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Phase 3: Final Registration
  Future<void> _register() async {
    if (_passwordController.text.isEmpty || _firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      _showError("Please fill in all required fields");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> registrationData = {
        "verifiedEmailToken": _verifiedEmailToken,
        "password": _passwordController.text,
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
      };

      debugPrint("Register Request: ${jsonEncode(registrationData)}");

      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registrationData),
      );

      debugPrint("Register Response (${response.statusCode}): ${response.body}");
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration Successful
        final String? token = data['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account created successfully!"), backgroundColor: Colors.green),
          );
          // Navigate directly to the main app and clear navigation stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
          );
        }
      } else {
        // More robust error reporting
        String errorMsg = data['message'] ?? data['error'] ?? data['detail'] ?? "Registration failed";
        _showError("$errorMsg (Code: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("Register Error: $e");
      _showError("Registration failed. Check connection.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Column(
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "NAKick",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 15),

              // Dynamic Phase Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _currentPhase == 1 ? "Verify Email" : (_currentPhase == 2 ? "Enter OTP" : "Final Details"),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _currentPhase == 1 
                      ? "We'll send you an OTP code" 
                      : (_currentPhase == 2 ? "Check your email for 6-digit code" : "Complete your profile"),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic Content based on phase
              if (_currentPhase == 1) _buildEmailPhase(),
              if (_currentPhase == 2) _buildOTPPhase(),
              if (_currentPhase == 3) _buildDetailsPhase(),

              const SizedBox(height: 20),

              // Divider & Social buttons (Only show in phase 1 & 3 to save space)
              if (_currentPhase != 2) ...[
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Or sign up with", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialBtn(Icons.g_translate, Colors.black),
                    const SizedBox(width: 20),
                    _buildSocialBtn(Icons.facebook, Colors.blue.shade800),
                    const SizedBox(width: 20),
                    _buildSocialBtn(Icons.apple, Colors.black),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // UI Components for Phases
  Widget _buildEmailPhase() {
    return Column(
      children: [
        _buildShadowField(_emailController, Icons.email_outlined, "Email Address", ktype: TextInputType.emailAddress),
        const SizedBox(height: 20),
        _buildButton("SEND OTP", _generateOTP),
      ],
    );
  }

  Widget _buildOTPPhase() {
    return Column(
      children: [
        _buildShadowField(_otpController, Icons.lock_clock_outlined, "6-Digit OTP Code", ktype: TextInputType.number),
        const SizedBox(height: 20),
        _buildButton("VERIFY OTP", _verifyOTP),
        TextButton(
          onPressed: () => setState(() => _currentPhase = 1),
          child: const Text("Change Email", style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }

  Widget _buildDetailsPhase() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildShadowField(_firstNameController, Icons.badge_outlined, "First Name")),
            const SizedBox(width: 12),
            Expanded(child: _buildShadowField(_lastNameController, Icons.badge_outlined, "Last Name")),
          ],
        ),
        const SizedBox(height: 12),
        _buildShadowField(_passwordController, Icons.lock_outline, "Password", isPass: true),
        const SizedBox(height: 12),
        _buildShadowField(_confirmPasswordController, Icons.lock_reset_outlined, "Confirm Password", isPass: true),
        const SizedBox(height: 20),
        _buildButton("REGISTER", _register),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
        ),
        child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildShadowField(TextEditingController controller, IconData icon, String hint, {bool isPass = false, TextInputType? ktype}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        keyboardType: ktype,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.redAccent, size: 22),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSocialBtn(IconData icon, Color bg) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}