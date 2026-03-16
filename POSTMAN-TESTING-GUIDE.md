# 🧪 Postman Testing Guide - NAKick Auth Service

## 📥 Step 1: Import the Collection

1. Open **Postman**
2. Click **Import** button (top left)
3. Select **File** tab
4. Choose `NAKick-Auth-Service-Postman-Collection.json`
5. Click **Import**

---

## 🔧 Step 2: Configure Gmail (Required!)

Before testing, you **MUST** configure your Gmail credentials:

**Edit:** `service/auth-service/src/main/resources/application.properties`

```properties
spring.mail.username=your-email@gmail.com
spring.mail.password=your-app-password
```

**Then restart the service:**
```bash
docker compose restart auth-service
```

---

## ✅ Step 3: Test the Complete Flow

### **Request 1: Health Check**
- **Purpose:** Verify service is running
- **Method:** GET
- **URL:** `http://localhost:8081/api/auth/health`
- **Expected:** `Auth Service is running`

---

### **Request 2: Generate OTP** ⭐
- **Purpose:** Send OTP to email
- **Method:** POST
- **URL:** `http://localhost:8081/api/auth/generate-otp`
- **Body:**
  ```json
  {
    "email": "your-email@gmail.com"
  }
  ```
- **Expected Response:**
  ```json
  {
    "success": true,
    "message": "OTP sent successfully to your email",
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
  ```
- **Action:** 
  - ✅ Check your email inbox for the 6-digit OTP
  - ✅ The `token` is automatically saved to environment variable `{{temp_token}}`

---

### **Request 3: Verify OTP** ⭐
- **Purpose:** Verify the OTP code
- **Method:** POST
- **URL:** `http://localhost:8081/api/auth/verify-otp`
- **Body:**
  ```json
  {
    "tempToken": "{{temp_token}}",
    "otp": "123456"
  }
  ```
  **Replace `123456` with the actual OTP from your email!**

- **Expected Response:**
  ```json
  {
    "success": true,
    "message": "Email verified successfully",
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
  ```
- **Action:** 
  - ✅ The `token` is automatically saved to `{{verified_email_token}}`

---

### **Request 4: Register User** ⭐
- **Purpose:** Complete registration with verified email
- **Method:** POST
- **URL:** `http://localhost:8081/api/auth/register`
- **Body:**
  ```json
  {
    "verifiedEmailToken": "{{verified_email_token}}",
    "username": "johndoe",
    "email": "your-email@gmail.com",
    "password": "securePassword123",
    "firstName": "John",
    "lastName": "Doe"
  }
  ```
- **Expected Response:**
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "type": "Bearer",
    "username": "johndoe",
    "email": "your-email@gmail.com",
    "message": "User registered successfully"
  }
  ```
- **Action:** 
  - ✅ The `token` is automatically saved to `{{auth_token}}`

---

### **Request 5: Login** ⭐
- **Purpose:** Login with credentials
- **Method:** POST
- **URL:** `http://localhost:8081/api/auth/login`
- **Body:**
  ```json
  {
    "email": "your-email@gmail.com",
    "password": "securePassword123"
  }
  ```
- **Expected Response:**
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "type": "Bearer",
    "username": "johndoe",
    "email": "your-email@gmail.com",
    "message": "Login successful"
  }
  ```

---

### **Request 6: Validate Token**
- **Purpose:** Check if token is valid
- **Method:** GET
- **URL:** `http://localhost:8081/api/auth/validate`
- **Headers:**
  ```
  Authorization: Bearer {{auth_token}}
  ```
- **Expected Response:**
  ```json
  {
    "message": "Token is valid"
  }
  ```

---

## 🚪 Testing via API Gateway

The collection also includes requests through the API Gateway (port 8080):

- **Via Gateway Health:** `http://localhost:8080/auth-service/api/auth/health`
- **Via Gateway OTP:** `http://localhost:8080/auth-service/api/auth/generate-otp`

All requests work the same way, just prefix with `/auth-service`

---

## 🔄 Environment Variables

The collection automatically manages these variables:

| Variable | Description | Set By |
|----------|-------------|--------|
| `temp_token` | Temporary token with OTP | Request 2 |
| `verified_email_token` | Verified email token | Request 3 |
| `auth_token` | JWT authentication token | Request 4 & 5 |

You can view/edit these in **Postman Environment** settings.

---

## ❌ Common Errors & Solutions

### **Error: "Failed to send verification email"**
**Cause:** Gmail credentials not configured
**Solution:** 
- Configure `spring.mail.username` and `spring.mail.password`
- Restart: `docker compose restart auth-service`

### **Error: "Invalid OTP"**
**Cause:** Wrong OTP or OTP expired
**Solution:** 
- Check your email for the correct 6-digit code
- OTP expires after 5 minutes, generate a new one if needed

### **Error: "Email is already registered"**
**Cause:** Email already exists in database
**Solution:** 
- Use a different email
- Or login with existing credentials

### **Error: "Email not verified"**
**Cause:** Trying to login without completing email verification
**Solution:** 
- Complete the OTP verification flow first

### **Error: "Invalid or expired verification token"**
**Cause:** Verified email token expired (1 hour validity)
**Solution:** 
- Start from step 2 (Generate OTP) again

---

## 📊 Complete Flow Diagram

```
1. Generate OTP
   ↓
   📧 Email sent with 6-digit OTP
   ↓
2. Verify OTP
   ↓
   ✅ Email verified
   ↓
3. Register User
   ↓
   🎉 User created with verified email
   ↓
4. Login
   ↓
   🔐 JWT token returned
   ↓
5. Access Protected Routes (use token)
```

---

## 🎯 Testing Checklist

- [ ] Gmail credentials configured
- [ ] Auth service restarted
- [ ] Health check returns success
- [ ] OTP email received
- [ ] OTP verification successful
- [ ] Registration successful
- [ ] Login successful
- [ ] Token validation works

---

## 🔍 Debugging Tips

### **Check Service Logs:**
```bash
docker logs auth-service -f
```

### **Check Database:**
```bash
docker exec -it postgres-auth psql -U authuser -d authdb
```
```sql
-- Check users table
SELECT id, username, email, email_verified, created_at FROM users;
```

### **Test Direct Connection:**
```bash
# Test without Docker
curl http://localhost:8081/api/auth/health
```

---

## 🚀 Advanced Testing

### **Test with Multiple Users:**
1. Change email in Request 2
2. Run the complete flow
3. Verify multiple users can register

### **Test Token Expiration:**
1. Save a token
2. Wait 24 hours
3. Try to validate - should fail

### **Test Invalid Scenarios:**
- Invalid email format
- Wrong OTP
- Expired tokens
- Duplicate usernames
- Weak passwords

---

## 📞 Need Help?

If you encounter issues:

1. **Check logs:** `docker logs auth-service`
2. **Verify service status:** `docker ps`
3. **Check email config:** Ensure Gmail App Password is correct
4. **Review documentation:** `EMAIL-VERIFICATION-GUIDE.md`

---

## ✅ Success Criteria

When everything works, you should be able to:

✅ Receive OTP emails within seconds
✅ Verify OTP successfully
✅ Register new users with verified emails
✅ Login with credentials
✅ Receive valid JWT tokens
✅ Access protected endpoints with tokens

**Happy Testing! 🎉**
