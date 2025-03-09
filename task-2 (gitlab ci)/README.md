# CI/CD Pipeline Documentation

This repository contains a GitLab CI/CD pipeline configuration for automating the build, test, and deployment process of a web application. The pipeline is designed to run on the `main` branch and includes the following stages:

1. **Linting**: Runs a linting tool to ensure code quality.
2. **Testing**: Runs unit tests to verify the functionality of the application.
3. **Build**: Builds a Docker image and pushes it to AWS Elastic Container Registry (ECR).
4. **Deploy**: Deploys the Docker container to an AWS ECS cluster.

## Pipeline Variables

The following variables are used in the pipeline:

- `AWS_DEFAULT_REGION`: The AWS region where the ECR repository and ECS cluster are located.
- `AWS_ECR_REPO`: The name of the AWS ECR repository where the Docker image will be pushed.
- `AWS_ECS_CLUSTER`: The name of the AWS ECS cluster where the application will be deployed.
- `AWS_ECS_SERVICE`: The name of the AWS ECS service that will be updated during deployment.
- `DOCKER_IMAGE_TAG`: The tag for the Docker image (default is `latest`).

## How to Use

1. **Set up AWS credentials**: Ensure that your GitLab CI/CD environment has the necessary AWS credentials configured (e.g., `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).
2. **Update variables**: Replace the placeholder values in the `.gitlab-ci.yml` file with your actual AWS ECR repository name, ECS cluster name, and service name.
3. **Push to main branch**: The pipeline will automatically trigger when you push changes to the `main` branch.

## Example Commands

- **Linting**: `npm run lint`
- **Testing**: `npm test`
- **Build Docker image**: `docker build -t $AWS_ECR_REPO:$DOCKER_IMAGE_TAG .`
- **Push Docker image**: `docker push $AWS_ECR_REPO:$DOCKER_IMAGE_TAG`
- **Deploy to ECS**: `aws ecs update-service --cluster $AWS_ECS_CLUSTER --service $AWS_ECS_SERVICE --force-new-deployment --region $AWS_DEFAULT_REGION`

## Explanation of the Pipeline

1. **Linting Stage**: 
   - This stage ensures that the code follows the required coding standards. It uses a Node.js image to run the linting script (`npm run lint`).

2. **Testing Stage**:
   - This stage runs unit tests to ensure that the application functions as expected. It also uses a Node.js image to execute the tests (`npm test`).

3. **Build Stage**:
   - This stage builds a Docker image from the application code and pushes it to AWS ECR. It uses the `docker:dind` (Docker-in-Docker) service to build and push the image.

4. **Deploy Stage**:
   - This stage deploys the Docker container to an AWS ECS cluster. It uses the AWS CLI to force a new deployment of the ECS service.

## Best Practices

- **Environment Variables**: Sensitive information like AWS credentials should be stored in GitLab CI/CD environment variables, not in the code.
- **Branch Protection**: Ensure that the `main` branch is protected to prevent unauthorized changes.
- **Monitoring**: Set up monitoring for the ECS cluster to track CPU and memory usage.
- **Rollback Strategy**: Implement a rollback strategy in case of deployment failures.

---

This pipeline is a basic example and can be extended with additional stages (e.g., integration testing, security scanning) depending on the project requirements.