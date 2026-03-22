class Payment {
  final String paymentId;
  final String orderId;
  final double amount;
  final String currency;
  final String status;
  final String? approvalUrl;
  final String? clientSecret;
  final String? payerId;
  final String paymentMethod;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Payment({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.status,
    this.approvalUrl,
    this.clientSecret,
    this.payerId,
    required this.paymentMethod,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'] ?? '',
      orderId: json['orderId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'CREATED',
      approvalUrl: json['approvalUrl'],
      clientSecret: json['clientSecret'],
      payerId: json['payerId'],
      paymentMethod: json['paymentMethod'] ?? 'PAYPAL',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'approvalUrl': approvalUrl,
      'clientSecret': clientSecret,
      'payerId': payerId,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

enum PaymentStatus {
  created,
  approved,
  completed,
  failed,
  cancelled,
  refunded
}
