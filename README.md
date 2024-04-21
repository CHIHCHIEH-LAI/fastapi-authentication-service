# fastapi-authentication-service
This document provides detailed information on how to interact with the APIs for creating and verifying accounts. Each endpoint is describe with necessary details such as HTTP.

## API Documentation
### Overview
This document outlines the usage of the APIs for creating and verifying accounts within our system. Each endpoint is detailed with required parameters, expected responses, and potential error codes.

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

## Running App with Docker Compose
This guide explains how to use Docker Compose to run a containerized application with separate MySQL database service. The application and database services are defined in the [docker-compose.yml](https://github.com/CHIHCHIEH-LAI/fastapi-authentication-service/blob/main/docker-compose.yml) file.

### Prerequisites
Before you begin, ensure you have the following installed:

- `Git`: Ensure Git is installed on your machine. If not, you can download and install it from Git's official site.
- `Docker`: Download and install Docker from Docker's official website.
- `Docker Compose`: Typically installed with Docker Desktop for Windows and Mac, but may require separate installation on Linux.

### Getting Started
1. Clone the Repository
This command downloads the project files into a directory named fastapi-authentication-service and changes into that directory.
```
git clone https://github.com/CHIHCHIEH-LAI/fastapi-authentication-service.git
cd fastapi-authentication-service
```

2. Review the Project Structure
Make sure the project directory is structured properly. Here is an overview
```
|-- docker-compose.yml # The Docker Compose configuration file.
|-- db/
    |-- init.sql       # SQL script to initialize the database schema
```

### Running the Containers
1. Start the Services
Run the following command in the directory containing docker-compose.yml to start all configured services:
```
docker-compose up
```
This command pulls the necessary Docker images and starts the containers.

2. Access the Application Docs
After the containers have started, access the FastAPI application docs via:
```
http://localhost:8000/docs
```

3. Manage the Services
To stop all services without removing them:
```
docker-compose stop
```
To restart the services:
```
docker-compose restart
```
To stop and remove all related Docker containers, networks, and volumes:
```
docker-compose down
```

### Troubleshooting
- `Port Conflicts`: Ensure no other service is using the ports specified in docker-compose.yml.