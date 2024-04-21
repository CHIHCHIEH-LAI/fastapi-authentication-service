# fastapi-authentication-service

## API Documentation
### Endpoints
#### Create Account
- URL: `/create_account`
- Method: `POST`
- Description: Creates a new user account
- Request Body (JSON):
```
{
    "username": "newuser",
    "password": "SecurePass123"
}
```
- Success Response:
    - Code: 201 Created
    - Content:
    ```
    {
        "success": true,
        "reason": "Account created"
    }
    ```
- Error Responses:
    - Code: 409 Conflict
    - Content:
    ```
    {
        "success": false,
        "reason": "Username already exists"
    }
    ```
    - Code: 422 Unprocessable Entity
    - Content:
    ```
    {
        "success": false,
        "reason": "Username must be between 3 and 32 characters"
    }
    ```
#### Verify Account
- URL: `/verify_account`
- Method: `POST`
- Description: Verifies user login credentials.
- Request Body (JSON):
```
{
    "username": "existinguser",
    "password": "CorrectPassword123"
}
```
- Success Responses:
    - Code: 200 OK
    - Content:
    ```
    {
        "success": true,
        "reason": "Account verified"
    }
    ```
- Error Responses:
    - Code: 404 Not Found
    - Content:
    ```
    {
        "success": false,
        "reason": "Username not found"
    }
    ```
    - Code: 401 Unauthorized
    - Content:
    ```
    {
        "success": false,
        "reason": "Invalid password"
    }
    ```
    - Code: 429 Too Many Requests
    - Content
    ```
    {
        "success": false,
        "reason": "Too many failed attempts. Try again in 60 seconds"
    }
    ```
### Models
#### Account
Fields:
- `username`: Must be between 3 and 32 characters long.
- `password`: Must be between 8 and 32 characters long and include at least one lowercase letter, one uppercase letter and one number.

### Error Codes
- `401 Unauthorized`: Credentials provided are incorrect.
- `404 Not Found`: Specified resource was not found
- `409 Conflict`: Resource conflict, such as an existing username.
- `422 Unprocessable Entity`: Validation errors in the provided data.
- `499 Too Many Requests`: Rate limit exceeded; try again later.