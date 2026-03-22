# 🛒 Payment Service Integration Guide - NAKick Flutter App

## 📦 What's Been Added

### **New Files Created:**

1. **Models**
   - `lib/models/payment.dart` - Payment data model

2. **Services**
   - `lib/services/payment_service.dart` - Payment API integration service

3. **Pages**
   - `lib/pages/payment_page.dart` - Payment checkout page
   - `lib/pages/cart_page.dart` - Shopping cart with payment integration

---

## 🚀 Quick Start

### **Step 1: Update Your Navigation**

In your navigation/cart access, add a route to the payment page:

```dart
// In your main.dart or navigation file
import 'pages/payment_page.dart';
import 'pages/cart_page.dart';

// Add route to cart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const CartPage()),
);
```

### **Step 2: Verify Dependencies**

Your `pubspec.yaml` already has everything needed:
- ✅ `http: ^1.1.0` - For API calls
- ✅ `shared_preferences: ^2.5.4` - For storing auth tokens
- ✅ `flutter: sdk: flutter` - Core Flutter

No additional packages needed!

### **Step 3: Ensure Services are Running**

```bash
# In your NAKick-micro directory
docker compose up -d

# Verify payment service is running on port 8085
curl http://localhost:8085/api/payments/health
```

---

## 🔌 How It Works

### **Payment Flow:**

```
1. User views cart → CartPage
   ↓
2. Click "Proceed to Checkout" → PaymentPage
   ↓
3. PaymentService.createPayment()
   → Backend creates payment
   ↓
4. User approves payment
   ↓
5. PaymentService.executePayment()
   → Backend completes transaction
   ↓
6. Success message & return to cart
```

---

## 📝 Usage Examples

### **Example 1: Navigate to Cart**

```dart
// From any page
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const CartPage()),
);
```

### **Example 2: Direct Payment (Without Cart)**

```dart
// Manual payment for a specific order
import 'pages/payment_page.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaymentPage(
      orderId: 'ORD123456',
      totalAmount: 99.99,
      currency: 'USD',
      description: 'Nike Shoes Bundle',
    ),
  ),
);
```

### **Example 3: Handle Payment Result**

```dart
final payment = await Navigator.push<Payment>(
  context,
  MaterialPageRoute(
    builder: (context) => PaymentPage(
      orderId: _cart.id,
      totalAmount: _cart.totalAmount,
    ),
  ),
);

if (payment != null && payment.status == 'COMPLETED') {
  print('Payment successful!');
  // Clear cart, show order confirmation, etc.
} else {
  print('Payment cancelled or failed');
}
```

---

## 🔧 Payment Service API

### **PaymentService Methods:**

#### **1. Create Payment**
```dart
final payment = await paymentService.createPayment(
  orderId: 'ORD123',
  totalAmount: 99.99,
  items: cartItems,
  currency: 'USD',
  description: 'Order',
);
```

#### **2. Execute Payment**
```dart
final payment = await paymentService.executePayment(
  paymentId: payment.paymentId,
  payerId: 'PAY123456789',
  orderId: 'ORD123',
);
```

#### **3. Get Payment Details**
```dart
final payment = await paymentService.getPaymentDetails('PAYID-123');
```

#### **4. Health Check**
```dart
final isHealthy = await paymentService.checkHealth();
```

---

## 🎨 Customization

### **Change Payment Page Colors**

Edit `lib/pages/payment_page.dart`:

```dart
// Line ~194 - Change status colors
Color _getStatusColor(String? status) {
  switch (status?.toUpperCase()) {
    case 'COMPLETED':
      return Colors.green;      // ← Customize here
    case 'FAILED':
    case 'CANCELLED':
      return Colors.red;         // ← Or here
    case 'APPROVED':
      return Colors.blue;        // ← Or here
    default:
      return Colors.orange;      // ← Or here
  }
}
```

### **Change Backend URL**

Edit `lib/services/payment_service.dart`:

```dart
// Line 18-19 - Change base URL
static String baseServerUrl = 'http://$_host:8080/payment-service';
static String baseUrl = '$baseServerUrl/api/payments';
```

### **Add Custom Order ID Generation**

```dart
import 'package:uuid/uuid.dart';

String generateOrderId() {
  return 'ORD-${const Uuid().v4().split('-')[0]}';
}
```

---

## ⚠️ Testing

### **Test 1: Create Payment**

```bash
curl -X POST http://localhost:8085/api/payments/create \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORD123",
    "amount": 99.99,
    "currency": "USD",
    "description": "Test Order"
  }'
```

### **Test 2: Execute Payment**

```bash
curl -X POST "http://localhost:8085/api/payments/execute?paymentId=PAYID-123&payerId=PAY123&orderId=ORD123"
```

### **Test 3: In Flutter**

```dart
// Run this in main.dart or a test page
void testPaymentFlow() async {
  final service = PaymentService();
  
  // Check health
  final healthy = await service.checkHealth();
  print('Payment service healthy: $healthy');
  
  // Create test payment
  final payment = await service.createPayment(
    orderId: 'TEST-ORD-001',
    totalAmount: 49.99,
    items: [],
  );
  print('Payment created: ${payment.paymentId}');
}
```

---

## 🐛 Debugging

### **Enable Verbose Logging**

Add to `lib/services/payment_service.dart`:

```dart
debugPrint('REQUEST: ${Uri.parse(url)}');
debugPrint('RESPONSE: ${response.statusCode}');
debugPrint('BODY: ${response.body}');
```

### **Check Android Emulator Network**

If using Android emulator, ensure:
- API calls use `10.0.2.2` instead of `localhost` ✅ (Already handled in code)
- Device has internet permission ✅

### **Common Issues**

| Issue | Solution |
|-------|----------|
| "No auth token found" | Ensure user is logged in and token is saved |
| Connection timeout | Verify backend services are running |
| 500 error from backend | Check payment service logs: `docker logs payment-service` |
| Payment not persisting | This is expected (mock implementation) |

---

## 🔐 Security Notes

### **Current Security (Development)**
- ✅ Auth token from SharedPreferences
- ✅ HTTPS ready (production configuration)
- ⚠️ Mock PayPal credentials (replace with real ones)

### **For Production:**

1. **Externalize Secrets**
   ```dart
   // Load from environment or secure storage
   const paypalClientId = String.fromEnvironment('PAYPAL_CLIENT_ID');
   ```

2. **Use Secure Storage**
   ```dart
   // Replace SharedPreferences with flutter_secure_storage
   import 'package:flutter_secure_storage/flutter_secure_storage.dart';
   ```

3. **Add Certificate Pinning**
   ```dart
   // Pin SSL certificates for PayPal domain
   ```

---

## 📊 Integration Checklist

- [ ] Payment model created ✅
- [ ] Payment service created ✅
- [ ] Payment page UI created ✅
- [ ] Cart page with checkout created ✅
- [ ] All routes connected
- [ ] Backend service running
- [ ] Auth token properly saved
- [ ] Test payment flow end-to-end
- [ ] Handle errors gracefully
- [ ] Update app theme colors if needed
- [ ] Test on Android emulator
- [ ] Test on physical device
- [ ] Test on iOS (if applicable)

---

## 🚀 Next Steps

### **Phase 1: Basic Integration (Now)**
- ✅ Connect cart → payment flow
- ✅ Handle successful payments
- ✅ Show error messages

### **Phase 2: Enhancement**
- Add WebView for real PayPal approval
- Add payment history/receipts
- Add multiple payment methods
- Add order tracking

### **Phase 3: Production**
- Real PayPal API integration
- Database persistence verification
- PCI compliance
- Testing & QA
- App store submission

---

## 📞 API Reference

### **Payment Model**

```dart
class Payment {
  final String paymentId;           // Unique payment identifier
  final String orderId;              // Associated order ID
  final double amount;               // Payment amount
  final String currency;             // Currency code (USD, EUR, etc.)
  final String status;               // CREATED, APPROVED, COMPLETED, FAILED, CANCELLED
  final String? approvalUrl;         // PayPal approval URL
  final String? payerId;             // PayPal payer ID
  final String paymentMethod;        // Payment method (PAYPAL, CARD, etc.)
  final DateTime? createdAt;         // Creation timestamp
  final DateTime? updatedAt;         // Last update timestamp
}
```

### **Payment Status Values**

| Status | Meaning |
|--------|---------|
| `CREATED` | Payment initialized but not approved |
| `APPROVED` | User approved on PayPal |
| `COMPLETED` | Payment successfully processed |
| `FAILED` | Payment processing failed |
| `CANCELLED` | User cancelled payment |
| `REFUNDED` | Payment refunded to user |

---

## 📚 File Structure

```
lib/
├── models/
│   ├── payment.dart                 ← Payment data model
│   ├── cart.dart
│   └── ...
├── services/
│   ├── payment_service.dart         ← Payment API client
│   ├── cart_service.dart
│   └── ...
├── pages/
│   ├── payment_page.dart            ← Checkout UI
│   ├── cart_page.dart               ← Cart UI with payment
│   └── ...
└── main.dart
```

---

## ✅ Success Criteria

You'll know it's working when:

✅ App loads successfully with no errors
✅ Clicking "View Cart" shows `CartPage`
✅ Clicking "Proceed to Checkout" shows `PaymentPage`
✅ Payment service responds with payment ID
✅ Clicking "Complete Payment" processes successfully
✅ Success message appears on completion
✅ Error handling works gracefully

---

## 🎉 You're Ready!

Everything is set up and ready to go. Start by navigating to the cart page and testing the complete payment flow.

For issues or questions, check the logs:

```bash
# Flutter app logs
flutter logs

# Backend service logs
docker logs payment-service -f
```

Happy Coding! 🚀
