import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/payment.dart';
import '../models/cart_item.dart';
import '../services/payment_service.dart';
import '../services/cart_service.dart';
import '../payment_success_page.dart';

class StripePaymentPage extends StatefulWidget {
  final String orderId;
  final double totalAmount;
  final String currency;
  final String description;
  final List<CartItem> items;

  const StripePaymentPage({
    Key? key,
    required this.orderId,
    required this.totalAmount,
    this.currency = 'USD',
    this.description = 'NAKick Order',
    required this.items,
  }) : super(key: key);

  @override
  State<StripePaymentPage> createState() => _StripePaymentPageState();
}

class _StripePaymentPageState extends State<StripePaymentPage> {
  final _formKey = GlobalKey<FormState>();
  late PaymentService _paymentService;
  late CartService _cartService;
  
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  
  String _cardType = 'Visa';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    _cartService = CartService();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Create a payment intent first
      final payment = await _paymentService.createPayment(
        orderId: widget.orderId,
        totalAmount: widget.totalAmount,
        items: widget.items,
        currency: widget.currency,
        description: widget.description,
        paymentMethodId: 'pm_card_visa', // Mock ID
      );

      // 2. Complete payment (Backend Mock)
      final completedPayment = await _paymentService.executePayment(
        paymentId: payment.paymentId,
        orderId: widget.orderId,
      );

      // 3. REMOVE items from cart after successful payment
      for (final item in widget.items) {
        try {
          await _cartService.removeItem(item.id);
        } catch (e) {
          debugPrint('Error removing item ${item.id} after payment: $e');
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              paymentId: completedPayment.paymentId,
              orderId: widget.orderId,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = "Payment process failed: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Credit/Debit Card', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Preview
              _buildCardPreview(),
              const SizedBox(height: 32),
              
              const Text('Card Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildCardTypeOption('Visa', Icons.credit_card),
                  const SizedBox(width: 12),
                  _buildCardTypeOption('MasterCard', Icons.payment),
                ],
              ),
              const SizedBox(height: 24),
              
              const Text('Card Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              
              // Cardholder Name
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Cardholder Name', Icons.person_outline),
                validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              
              // Card Number
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                decoration: _inputDecoration('Card Number', Icons.credit_card),
                validator: (val) => val == null || val.length < 16 ? 'Valid card number is required' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  // Expiry
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryFormatter(),
                      ],
                      decoration: _inputDecoration('Expiry (MM/YY)', Icons.calendar_today_outlined),
                      validator: (val) => val == null || val.length < 5 ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // CVV
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: _inputDecoration('CVV', Icons.lock_outline),
                      validator: (val) => val == null || val.length < 3 ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
                
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    shadowColor: Colors.redAccent.withOpacity(0.4),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Pay \$${widget.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              
              const SizedBox(height: 16),
              const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Secure end-to-end encrypted payment', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _cardType == 'Visa' 
            ? [const Color(0xFF1A1F71), const Color(0xFF0055B8)] // Visa Navy/Blue
            : [const Color(0xFFEB001B), const Color(0xFFF79E1B)], // MasterCard Red/Orange
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_cardType == 'Visa' ? const Color(0xFF1A1F71) : const Color(0xFFEB001B)).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.credit_card, color: Colors.amber, size: 40),
              Text(
                _cardType.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _cardNumberController.text.isEmpty ? 'XXXX XXXX XXXX XXXX' : _cardNumberController.text,
            style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CARD HOLDER', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(
                    _nameController.text.isEmpty ? 'FULL NAME' : _nameController.text.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('EXPIRES', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(
                    _expiryController.text.isEmpty ? 'MM/YY' : _expiryController.text,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardTypeOption(String type, IconData icon) {
    bool isSelected = _cardType == type;
    Color activeColor = type == 'Visa' ? const Color(0xFF1A1F71) : const Color(0xFFEB001B);
    
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _cardType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? activeColor : Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(type, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) {
    var text = newV.text;
    if (newV.selection.baseOffset == 0) return newV;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonSpaceLength = i + 1;
      if (nonSpaceLength % 4 == 0 && nonSpaceLength != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newV.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) {
    var text = newV.text;
    if (newV.selection.baseOffset == 0) return newV;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 2 == 0 && (i + 1) != text.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newV.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}
