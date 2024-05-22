# FastAPI Authentication Service
## Project Overview
### Objective
The objective of this project is to design and implement two RESTful HTTP APIs that handle account creation and verification processes using FastAPI. The system processes JSON payloads for input and output, ensuring robust error handling and input validation. The implementation utilizes FastAPI, MySQL as the database, and Pydantic for data validation. The application is containerized using Docker for deployment and distribution, and the Docker image is available on Docker Hub.

### Tools and Technologies
- `FastAPI`: A modern, high-performance web framework for building APIs.
- `MySQL`: Used as the backend database to store user data securely.
- `Pydantic`: Used for data validation by leveraging Python type annotations.
- `Docker`: Used to containerize the application, ensuring it can be easily deployed and run on any system.

### Wiki
- [API Documentation](https://github.com/CHIHCHIEH-LAI/fastapi-authentication-service/wiki/API-Documentation)
- [Running App with Docker Compose](https://github.com/CHIHCHIEH-LAI/fastapi-authentication-service/wiki/Running-App-with-Docker-Compose)

### Deployment
EC2 + RDS
![EC2_RDS_diagram](https://github.com/CHIHCHIEH-LAI/fastapi-authentication-service/blob/main/imgs/EC2_RDS_diagram.png)

### Resource
- [Using Terraform to Create EC2 and RDS Instances Inside a Custom VPC on AWS](https://medium.com/strategio/using-terraform-to-create-aws-vpc-ec2-and-rds-instances-c7f3aa416133)
- [AWS ECS Tutorial | Deploy a New Application from Scratch](https://www.youtube.com/watch?v=esISkPlnxL0&t=293s)
