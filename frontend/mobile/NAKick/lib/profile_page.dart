import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "No authentication token found. Please login again.";
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8080/auth-service/api/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _profileData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load profile (Code: ${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Connection error. Is backend running?";
      });
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "Unknown";
    try {
      final date = DateTime.parse(dateStr);
      final months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
      return "Member since ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return "Member since $dateStr";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 35,
            ),
            const SizedBox(width: 8),
            const Text(
              'NAKick',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[800]),
            onPressed: _fetchProfile,
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.grey[800]),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
        : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: _fetchProfile, child: const Text("Retry"))
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Classic Profile Header
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    child: Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_profileData?['firstName'] ?? ''} ${_profileData?['lastName'] ?? ''}'.trim().isNotEmpty 
                        ? '${_profileData?['firstName']} ${_profileData?['lastName']}' 
                        : (_profileData?['username'] ?? 'User'),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profileData?['email'] ?? 'No email',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(_profileData?['createdAt']),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),

                  // Stats Section
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildClassicStatCard('24', 'Orders'),
                        _buildDivider(),
                        _buildClassicStatCard('12', 'Wishlist'),
                        _buildDivider(),
                        _buildClassicStatCard('18', 'Reviews'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  Divider(thickness: 1, color: Colors.grey[300]),

                  // Menu List
                  _buildClassicMenuItem(
                    Icons.shopping_bag_outlined,
                    'My Orders',
                    () {},
                  ),
                  _buildClassicMenuItem(
                    Icons.favorite_border,
                    'Wishlist',
                    () {},
                  ),
                  _buildClassicMenuItem(
                    Icons.location_on_outlined,
                    'Addresses',
                    () {},
                  ),
                  _buildClassicMenuItem(
                    Icons.payment_outlined,
                    'Payment Methods',
                    () {},
                  ),
                  
                  Divider(thickness: 1, color: Colors.grey[300]),

                  _buildClassicMenuItem(
                    Icons.notifications_outlined,
                    'Notifications',
                    () {},
                  ),
                  _buildClassicMenuItem(
                    Icons.security_outlined,
                    'Security',
                    () {},
                  ),
                  _buildClassicMenuItem(
                    Icons.language_outlined,
                    'Language',
                    () {},
                  ),
                  
                  Divider(thickness: 1, color: Colors.grey[300]),

                  _buildClassicMenuItem(
                    Icons.help_outline,
                    'Help & Support',
                    () {},
                  ),
                  _buildClassicMenuItem(
                    Icons.info_outline,
                    'About NAKick',
                    () {},
                  ),
                  _buildClassicMenuItem(
                    Icons.description_outlined,
                    'Terms & Conditions',
                    () {},
                  ),
                  _buildClassicMenuItem(
                    Icons.privacy_tip_outlined,
                    'Privacy Policy',
                    () {},
                  ),

                  const SizedBox(height: 30),
                  
                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: OutlinedButton(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent, width: 2),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildClassicStatCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey[300],
    );
  }

  Widget _buildClassicMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey[700],
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout from your account?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}