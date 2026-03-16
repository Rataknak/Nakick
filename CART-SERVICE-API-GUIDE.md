# 🛒 Cart Service API Guide

## Overview
The Cart Service manages shopping carts for users in the NAKick microservices architecture. It handles cart creation, item management, and cart operations with MongoDB persistence.

## Service Details
- **Port**: 8084
- **Base URL**: `http://localhost:8080/api/cart` (via API Gateway)
- **Direct URL**: `http://localhost:8084/api/cart`
- **Database**: MongoDB (cartdb)

## Authentication
All cart endpoints (except health) require a valid **Bearer Token (JWT)** in the Authorization header.

**Header Format:**
```
Authorization: Bearer <your_jwt_token>
```

The service automatically extracts the User ID and Email from the token to manage the correct cart.

## API Endpoints

### 1. Get User Cart
```http
GET /api/cart
```
**Auth:** Bearer Token required
**Response:** Returns the active cart for the authenticated user.

### 2. Add Item to Cart
```http
POST /api/cart/items
```
**Auth:** Bearer Token required
**Body (JSON):**
```json
{
  "shoeId": "shoe456",
  "brand": "Adidas",
  "model": "Ultra Boost",
  "size": 43.0,
  "color": "Core Black",
  "price": 189.99,
  "quantity": 1,
  "imageUrl": "https://example.com/ultra-boost.jpg"
}
```
**Response:** Returns updated cart.

### 3. Update Cart Item Quantity
```http
PUT /api/cart/items/{itemId}?quantity=3
```
**Auth:** Bearer Token required
**Response:** Returns updated cart.

### 4. Remove Item from Cart
```http
DELETE /api/cart/items/{itemId}
```
**Auth:** Bearer Token required
**Response:** Returns updated cart.

### 5. Clear Cart
```http
DELETE /api/cart
```
**Auth:** Bearer Token required
**Response:** Returns empty cart.

### 6. Delete Cart Data
```http
DELETE /api/cart/delete
```
**Auth:** Bearer Token required
**Response:** `204 No Content`

---

## 🧪 Testing with Postman

### Step 1: Login to get Token
1. Call `POST http://localhost:8081/api/auth/login`
2. Copy the `token` from the response.

### Step 2: Use Token in Cart Request
1. Create a new request (e.g., `POST http://localhost:8084/api/cart/items`).
2. Go to the **Auth** tab.
3. Select **Type**: `Bearer Token`.
4. Paste your token.
5. Send the request.

---

## Business Rules
- **Duplicate Items**: If adding the same shoe/size/color, quantity increases automatically.
- **One Active Cart**: Each user has only one active cart at a time.
- **Auto-calculation**: Total amount and items are calculated by the service.

## Error Responses
- **401 Unauthorized**: Missing or invalid Bearer Token.
- **400 Bad Request**: Validation failed (e.g., missing shoeId).
- **404 Not Found**: Cart item not found.
