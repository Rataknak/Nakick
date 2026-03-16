# Email Verification with OTP - Implementation Guide

## Overview

The Auth Service now supports **email verification using OTP (One-Time Password)** sent via Gmail SMTP. Users must verify their email before completing registration.

## Configuration

### 1. Update `application.properties`

Replace the placeholder values with your actual Gmail credentials:

```properties
# Email Configuration (Gmail SMTP)
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your-email@gmail.com
spring.mail.password=your-app-password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true

# OTP Configuration
otp.expiration=300000  # 5 minutes in milliseconds
```

### 2. Generate Gmail App Password

1. Go to your Google Account settings
2. Navigate to **Security** → **2-Step Verification**
3. Scroll to **App passwords**
4. Generate a new app password for "Mail"
5. Copy the 16-character password and use it in `spring.mail.password`

**Important:** Never commit your actual email credentials to version control!

## Registration Flow

### Step 1: Generate OTP

**Endpoint:** `POST /api/auth/generate-otp`

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP sent successfully to your email",
  "token": "eyJhbGciOiJIUzI1NiJ9..." // Temporary token
}
```

The user will receive a 6-digit OTP via email, valid for 5 minutes.

---

### Step 2: Verify OTP

**Endpoint:** `POST /api/auth/verify-otp`

**Request:**
```json
{
  "tempToken": "eyJhbGciOiJIUzI1NiJ9...", // Token from Step 1
  "otp": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Email verified successfully",
  "token": "eyJhbGciOiJIUzI1NiJ9..." // Verified email token
}
```

---

### Step 3: Complete Registration

**Endpoint:** `POST /api/auth/register`

**Request:**
```json
{
  "verifiedEmailToken": "eyJhbGciOiJIUzI1NiJ9...", // Token from Step 2
  "username": "johndoe",
  "email": "user@example.com", // Optional - extracted from token
  "password": "securePassword123",
  "firstName": "John",
  "lastName": "Doe"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...", // JWT auth token
  "type": "Bearer",
  "username": "johndoe",
  "email": "user@example.com",
  "message": "User registered successfully"
}
```

---

## Login Flow

**Endpoint:** `POST /api/auth/login`

**Request:**
```json
{
  "username": "johndoe",
  "password": "securePassword123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "type": "Bearer",
  "username": "johndoe",
  "email": "user@example.com",
  "message": "Login successful"
}
```

**Note:** Login will fail if email is not verified.

---

## Token Types

### 1. OTP Token (Temporary - 5 minutes)
- **Purpose:** Store email and OTP for verification
- **Claims:** `email`, `otp`, `type: "otp-verification"`
- **Validity:** 5 minutes (configurable)

### 2. Verified Email Token (1 hour)
- **Purpose:** Prove email has been verified
- **Claims:** `email`, `emailVerified: true`, `type: "verified-email"`
- **Validity:** 1 hour

### 3. Auth Token (24 hours)
- **Purpose:** Authenticate user for API access
- **Claims:** `username`, `authorities`
- **Validity:** 24 hours (configurable)

---

## Security Features

✅ **Email Uniqueness Check** - Prevents duplicate emails
✅ **OTP Expiration** - OTPs expire after 5 minutes
✅ **Token-Based Flow** - Stateless verification process
✅ **Password Encryption** - BCrypt password hashing
✅ **Email Verification Required** - Users must verify email before login
✅ **JWT Token Security** - Signed tokens with HS256 algorithm

---

## Database Schema Changes

The `User` entity now includes:

```java
@Column(name = "email_verified")
private Boolean emailVerified = false;

@Column(name = "verification_code")
private String verificationCode;

@Column(name = "code_expiry")
private LocalDateTime codeExpiry;
```

PostgreSQL will automatically create these columns when the application starts (with `spring.jpa.hibernate.ddl-auto=update`).

---

## Error Handling

### Common Errors:

**1. Email already registered:**
```json
{
  "message": "Email is already registered. Please login or reset your password.",
  "details": "OTP generation failed"
}
```

**2. Invalid OTP:**
```json
{
  "message": "Invalid OTP. Please try again.",
  "details": "OTP verification failed"
}
```

**3. Expired token:**
```json
{
  "message": "Invalid or expired verification token",
  "details": "Registration failed"
}
```

**4. Email not verified on login:**
```json
{
  "message": "Email not verified. Please verify your email to login.",
  "details": "Login failed"
}
```

---

## Testing with Postman/cURL

### Example: Complete Registration Flow

```bash
# Step 1: Generate OTP
curl -X POST http://localhost:8081/api/auth/generate-otp \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'

# Step 2: Verify OTP (check your email for OTP)
curl -X POST http://localhost:8081/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"tempToken": "TOKEN_FROM_STEP_1", "otp": "123456"}'

# Step 3: Register
curl -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "verifiedEmailToken": "TOKEN_FROM_STEP_2",
    "username": "johndoe",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe"
  }'

# Step 4: Login
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "johndoe", "password": "password123"}'
```

---

## API Gateway Access

When using API Gateway (Port 8080), prefix all endpoints with the service name:

```
http://localhost:8080/auth-service/api/auth/generate-otp
http://localhost:8080/auth-service/api/auth/verify-otp
http://localhost:8080/auth-service/api/auth/register
http://localhost:8080/auth-service/api/auth/login
```

---

## Future Enhancements (Optional)

- **OAuth2 Social Login** (Google, Facebook, GitHub)
- **SMS OTP** verification
- **Password Reset** with email verification
- **Resend OTP** functionality
- **Rate Limiting** for OTP generation
- **HTML Email Templates** with styling

---

## Troubleshooting

### Issue: Emails not sending

**Check:**
1. Gmail SMTP credentials are correct
2. App password is enabled (not regular password)
3. Firewall allows outbound connections on port 587
4. Check application logs for detailed error messages

### Issue: "Invalid credentials" error

**Solution:**
- Regenerate Gmail app password
- Ensure 2-Step Verification is enabled in Google Account
- Use app password, not your regular Gmail password

---

## Support

For questions or issues, check the logs:
```bash
docker compose logs -f auth-service
```
