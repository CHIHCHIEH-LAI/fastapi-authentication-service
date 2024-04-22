# FastAPI Authentication Service
## Project Overview
### Objective
The objective of this project is to design and implement two RESTful HTTP APIs that handle account creation and verification processes using FastAPI. The system processes JSON payloads for input and output, ensuring robust error handling and input validation. The implementation utilizes FastAPI, MySQL as the database, and Pydantic for data validation. The application is containerized using Docker for deployment and distribution, and the Docker image is available on Docker Hub.

### Tools and Technologies
- `FastAPI`: A modern, high-performance web framework for building APIs.
- `MySQL`: Used as the backend database to store user data securely.
- `Pydantic`: Used for data validation by leveraging Python type annotations.
- `Docker`: Used to containerize the application, ensuring it can be easily deployed and run on any system.

## API Documentation
This document outlines the usage of the APIs for creating and verifying accounts within our system. Each endpoint is detailed with required parameters, expected responses, and potential error codes.

### Endpoints
#### Create Account
- URL: `/create_account`
- Method: `POST`
- Description: Creates a new user account
- Inputs:
    - `username`: A string that must be between 3 and 32 characters long.
    - `password`: A string that must be between 8 and 32 characters long and include at least one uppercase letter, one lowercase letter, and one number.
- Outputs:
    - `success`: A boolean indicating whether the account creation was successful.
    - `reason`: A string detailing why account creation failed, if applicable (e.g., "Username already exists").
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
- Example Request:
```
curl -X POST http://localhost/create_account \
    -H "Content-Type: application/json" \
    -d '{"username": "newuser", "password": "securePassword123"}'
```

#### Verify Account
- URL: `/verify_account`
- Method: `POST`
- Description: Verifies user login credentials.
- Inputs:
    - `username`: A string representing the username of the account being accessed.
    - `password`: A string that must be between 8 and 32 characters long and include at least one uppercase letter, one lowercase letter, and one number.
- Outputs:
    - `success`: A boolean indicating whether the account creation was successful.
    - `reason`: A string representing the password being used to access the account.
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
    - Code: 422 Unprocessable Entity
    - Content:
    ```
    {
        "success": false,
        "reason": "Username must be between 3 and 32 characters"
    }
    ```
- Example Request:
```
curl -X POST http://localhost/verify_account \
    -H "Content-Type: application/json" \
    -d '{"username": "newuser", "password": "securePassword123"}'
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
Other files in the repo are not needed.

### Running the Containers
1. Start the Services 

Run the following command in the directory containing docker-compose.yml to start all configured services:
```
docker compose up
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
docker compose stop
```
To restart the services:
```
docker compose restart
```
To stop and remove all related Docker containers, networks, and volumes:
```
docker compose down
```

### Troubleshooting
- `Port Conflicts`: Ensure no other service is using the ports specified in docker-compose.yml.