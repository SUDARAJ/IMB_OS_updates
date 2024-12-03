pipeline {
    agent {
        docker {
            image 'amazonlinux:2'  // Use Amazon Linux 2 which includes AWS CLI
            args '--privileged -v /var/run/docker.sock:/var/run/docker.sock' 
        }
    }
    environment {
        REPO_NAME = "864923301006.dkr.ecr.ap-southeast-2.amazonaws.com/support-automations"
        AWS_REGION = "ap-southeast-2"
        DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER}" // Build number used as the image tag
        GIT_REPO_URL = "https://github.com/SUDARAJ/IMB_OS_updates.git"
    }
    stages {
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
                # Install AWS CLI on Amazon Linux container
                yum install -y sudo
                sudo yum install -y aws-cli
                aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REPO_NAME}
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
