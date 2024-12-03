pipeline {
    agent {
        docker { 
            image 'docker:latest' 
            args '--privileged -v /var/run/docker.sock:/var/run/docker.sock' 
        }
    }
    environment {
        REPO_NAME = "your-aws-account-id.dkr.ecr.your-region.amazonaws.com/your-repo-name"
        AWS_REGION = "your-region"
        DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER}" // Or use 'latest'
        GIT_REPO_URL = "https://github.com/your-username/your-repo.git"
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
                aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REPO_NAME}
                """
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${REPO_NAME}:${DOCKER_IMAGE_TAG} ."
            }
        }
        stage('Push Docker Image to ECR') {
            steps {
                echo 'Pushing Docker image to AWS ECR...'
                sh "docker push ${REPO_NAME}:${DOCKER_IMAGE_TAG}"
            }
        }
    }
    post {
        always {
            echo 'Pipeline execution completed!'
        }
    }
}
