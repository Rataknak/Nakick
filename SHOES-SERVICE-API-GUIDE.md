# Shoes Service API Guide

## Base URL
```
http://localhost:8080/api/shoes  (via API Gateway)
http://localhost:8083/api/shoes  (direct access)
```

## Endpoints

### 1. Create a Shoe
**POST** `/api/shoes`

**Request Body:**
```json
{
  "brand": "Nike",
  "model": "Air Max 270",
  "size": 42,
  "price": 150.00,
  "color": "Black/White",
  "stock": 25,
  "description": "Comfortable running shoes with excellent cushioning",
  "category": "Running",
  "imageUrl": "https://example.com/nike-air-max-270.jpg"
}
```

**Response:** `201 CREATED`
```json
{
  "id": "65a1b2c3d4e5f6g7h8i9j0k1",
  "brand": "Nike",
  "model": "Air Max 270",
  "size": 42,
  "price": 150.00,
  "color": "Black/White",
  "stock": 25,
  "description": "Comfortable running shoes with excellent cushioning",
  "category": "Running",
  "imageUrl": "https://example.com/nike-air-max-270.jpg",
  "createdAt": "2026-02-26T00:45:00",
  "updatedAt": "2026-02-26T00:45:00"
}
```

---

### 2. Get All Shoes
**GET** `/api/shoes`

**Response:** `200 OK`
```json
[
  {
    "id": "65a1b2c3d4e5f6g7h8i9j0k1",
    "brand": "Nike",
    "model": "Air Max 270",
    "size": 42,
    "price": 150.00,
    "color": "Black/White",
    "stock": 25,
    "description": "Comfortable running shoes",
    "category": "Running",
    "imageUrl": "https://example.com/nike-air-max-270.jpg",
    "createdAt": "2026-02-26T00:45:00",
    "updatedAt": "2026-02-26T00:45:00"
  }
]
```

---

### 3. Get Shoe by ID
**GET** `/api/shoes/{id}`

**Response:** `200 OK`
```json
{
  "id": "65a1b2c3d4e5f6g7h8i9j0k1",
  "brand": "Nike",
  "model": "Air Max 270",
  "size": 42,
  "price": 150.00,
  "color": "Black/White",
  "stock": 25,
  "description": "Comfortable running shoes",
  "category": "Running",
  "imageUrl": "https://example.com/nike-air-max-270.jpg",
  "createdAt": "2026-02-26T00:45:00",
  "updatedAt": "2026-02-26T00:45:00"
}
```

---

### 4. Filter Shoes (Query Parameters)
**GET** `/api/shoes?brand=Nike`
**GET** `/api/shoes?category=Running`
**GET** `/api/shoes?size=42`

**Response:** `200 OK` - Returns array of matching shoes

---

### 5. Update a Shoe
**PUT** `/api/shoes/{id}`

**Request Body:**
```json
{
  "brand": "Nike",
  "model": "Air Max 270 React",
  "size": 42,
  "price": 160.00,
  "color": "Black/White/Red",
  "stock": 30,
  "description": "Updated description",
  "category": "Running",
  "imageUrl": "https://example.com/nike-air-max-270-react.jpg"
}
```

**Response:** `200 OK` - Returns updated shoe object

---

### 6. Delete a Shoe
**DELETE** `/api/shoes/{id}`

**Response:** `204 NO CONTENT`

---

## Validation Rules

| Field | Required | Constraints |
|-------|----------|-------------|
| brand | Yes | Cannot be blank |
| model | Yes | Cannot be blank |
| size | Yes | Must be positive number |
| price | Yes | Must be greater than 0 |
| color | Yes | Cannot be blank |
| stock | Yes | Must be >= 0 |
| description | No | Optional |
| category | No | Optional (e.g., Running, Basketball, Casual, Formal) |
| imageUrl | No | Optional |

---

## Sample Postman Requests

### Create Nike Shoe
```json
POST http://localhost:8080/api/shoes
Content-Type: application/json

{
  "brand": "Nike",
  "model": "Air Jordan 1",
  "size": 43,
  "price": 180.00,
  "color": "Red/Black/White",
  "stock": 15,
  "description": "Classic basketball shoe",
  "category": "Basketball"
}
```

### Create Adidas Shoe
```json
POST http://localhost:8080/api/shoes
Content-Type: application/json

{
  "brand": "Adidas",
  "model": "Ultraboost 22",
  "size": 41,
  "price": 140.00,
  "color": "White/Black",
  "stock": 20,
  "description": "Premium running experience",
  "category": "Running"
}
```

---

## Error Responses

### Validation Error (400)
```json
{
  "message": "Validation failed",
  "status": 400,
  "timestamp": "2026-02-26T00:45:00",
  "errors": {
    "brand": "Brand is required",
    "price": "Price must be greater than 0"
  }
}
```

### Not Found (404)
```json
{
  "message": "Shoe not found with id: 65a1b2c3d4e5f6g7h8i9j0k1",
  "status": 404,
  "timestamp": "2026-02-26T00:45:00"
}
```
