import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/payment.dart';
import '../models/cart_item.dart';
import '../services/payment_service.dart';
import '../payment_success_page.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;
  final double totalAmount;
  final String currency;
  final String description;
  final List<CartItem> items;
  final Payment? initialPayment;

  const PaymentPage({
    Key? key,
    required this.orderId,
    required this.totalAmount,
    this.currency = 'USD',
    this.description = 'NAKick Order',
    required this.items,
    this.initialPayment,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late PaymentService _paymentService;
  Payment? _payment;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    if (widget.initialPayment != null) {
      _payment = widget.initialPayment;
    } else {
      _initializePayment();
    }
  }

  Future<void> _initializePayment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final payment = await _paymentService.createPayment(
        orderId: widget.orderId,
        totalAmount: widget.totalAmount,
        items: widget.items,
        currency: widget.currency,
        description: widget.description,
      );

      setState(() {
        _payment = payment;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchPayPal() async {
    if (_payment?.approvalUrl == null) return;
    
    final url = Uri.parse(_payment!.approvalUrl!);
    
    try {
      await launchUrl(
        url, 
        mode: LaunchMode.inAppBrowserView,
      );
    } catch (e) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _completePayment() async {
    if (_payment == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // For Stripe, we just call complete on the backend
      final completedPayment = await _paymentService.executePayment(
        paymentId: _payment!.paymentId,
        orderId: widget.orderId,
      );
      
      setState(() {
        _payment = completedPayment;
      });
      
      if (completedPayment.status == 'succeeded' || completedPayment.status == 'COMPLETED') {
        if (mounted) _navigateToSuccess();
      } else {
        setState(() {
          _error = "Payment status: ${completedPayment.status}. Please check your payment method.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "We couldn't verify your payment. Error: $e";
        _isLoading = false;
      });
    }
  }

  void _navigateToSuccess() {
    // Instead of pushReplacement, pop the successful payment result back to FavoritePage
    // so FavoritePage can handle clearing the cart and then show the success screen.
    Navigator.pop(context, _payment);
  }

  @override
  Widget build(BuildContext context) {
    bool isPending = _payment?.status == 'CREATED' || _payment?.status == 'PENDING';
    bool isStripe = _payment?.paymentId.startsWith('pi_') ?? false;
    bool requiresAction = _payment?.status == 'requires_confirmation' || 
                          _payment?.status == 'requires_payment_method' ||
                          _payment?.status == 'requires_action';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Order Summary', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildRow('Order ID', widget.orderId),
                        const SizedBox(height: 16),
                        _buildRow('Description', widget.description),
                        const Divider(height: 32),
                        _buildRow('Total Amount', '${widget.currency} ${widget.totalAmount.toStringAsFixed(2)}', isBold: true, valueColor: Colors.redAccent),
                      ],
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 20),
                    Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13), textAlign: TextAlign.center),
                  ],

                  const Spacer(),
                  
                  if (isStripe)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _completePayment,
                        icon: Icon(requiresAction ? Icons.credit_card : Icons.check_circle, size: 20),
                        label: Text(
                          requiresAction ? 'Pay Now with Card' : 'Verify & Complete Order', 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  else ...[
                    if (isPending) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _launchPayPal,
                          icon: const Icon(Icons.payment, size: 20),
                          label: const Text('Pay with PayPal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0070BA),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _completePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Verify & Complete Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel Order', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Expanded(
          child: Text(
            value, 
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
              fontSize: isBold ? 16 : 14,
              color: valueColor
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
