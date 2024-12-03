pipeline {
    agent {
        docker {
            image 'amazonlinux:2'
            // Remove the --privileged flag and use root user
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        REPO_NAME = "864923301006.dkr.ecr.ap-southeast-2.amazonaws.com/support-automations"
        AWS_REGION = "ap-southeast-2"
        DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER}"
        GIT_REPO_URL = "https://github.com/SUDARAJ/IMB_OS_updates.git"
    }
    stages {
        stage('Prepare Environment') {
            steps {
                sh '''
                # Update package manager and install dependencies
                yum update -y > /dev/null 2>&1
                yum install -y sudo aws-cli docker git > /dev/null 2>&1
                '''
            }
        }
        stage('Clone Repository') {
            steps {
                echo 'Cloning GitHub repository...'
                git branch: 'main', url: "${env.GIT_REPO_URL}"
            }
        }
        stage('Login to AWS ECR') {
            steps {
                echo 'Logging in to AWS ECR...'
                sh """
                # Configure AWS CLI
                aws configure set aws_access_key_id AKIA4SYLSGSHHXB5P6NA
                aws configure set aws_secret_access_key 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
                aws configure set region ap-southeast-2
                
                # Login to ECR
                aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${REPO_NAME}
                
                # Verify ECR repository exists
                aws ecr describe-repositories --repository-names support-automations
                """
            }
        }
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image with tag: ${DOCKER_IMAGE_TAG}..."
                sh "docker build -t ${REPO_NAME}:${DOCKER_IMAGE_TAG} ."
            }
        }
        stage('Push Docker Image to ECR') {
            steps {
                echo "Pushing Docker image to ECR with tag: ${DOCKER_IMAGE_TAG}..."
                sh "docker push ${REPO_NAME}:${DOCKER_IMAGE_TAG}"
            }
        }
    }
    post {
        always {
            echo "Pipeline execution completed! Docker image tagged with: ${DOCKER_IMAGE_TAG}"
        }
    }
}
