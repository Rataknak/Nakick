const express = require('express');
const app = express();
const port = 8080;

// Handle PayPal success redirect
app.get('/payment/success', (req, res) => {
  const { paymentId, orderId, token, PayerID } = req.query;
  
  console.log('PayPal Success:', {
    paymentId,
    orderId,
    token,
    PayerID
  });
  
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
        <title>Payment Successful</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
            .success { color: #28a745; font-size: 24px; margin-bottom: 20px; }
            .details { background: #f8f9fa; padding: 20px; border-radius: 8px; display: inline-block; }
        </style>
    </head>
    <body>
        <div class="success">✅ Payment Successful!</div>
        <div class="details">
            <strong>Order ID:</strong> ${orderId}<br>
            <strong>Payment ID:</strong> ${paymentId}<br>
            <strong>Token:</strong> ${token}<br>
            <strong>Payer ID:</strong> ${PayerID}<br><br>
            <em>You can now close this window and return to your app.</em>
        </div>
    </body>
    </html>
  `);
});

// Handle PayPal cancel redirect
app.get('/payment/cancel', (req, res) => {
  const { paymentId, orderId, token } = req.query;
  
  console.log('PayPal Cancel:', {
    paymentId,
    orderId,
    token
  });
  
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
        <title>Payment Cancelled</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
            .cancel { color: #dc3545; font-size: 24px; margin-bottom: 20px; }
            .details { background: #f8f9fa; padding: 20px; border-radius: 8px; display: inline-block; }
        </style>
    </head>
    <body>
        <div class="cancel">❌ Payment Cancelled</div>
        <div class="details">
            <strong>Order ID:</strong> ${orderId}<br>
            <strong>Payment ID:</strong> ${paymentId}<br>
            <strong>Token:</strong> ${token}<br><br>
            <em>You can now close this window and return to your app.</em>
        </div>
    </body>
    </html>
  `);
});

// Root endpoint
app.get('/', (req, res) => {
  res.send('PayPal Redirect Server is running!');
});

app.listen(port, () => {
  console.log(`PayPal redirect server running on port ${port}`);
  console.log('Tunnel URL will be: https://nimrataknak-test.loca.lt');
});
