pipeline {
    agent {
        docker {
            image 'amazonlinux:2'  
            // Securely run as root with Docker socket access
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock' 
        }
    }
    
    environment {
        // ECR Repository details
        REPO_NAME = "864923301006.dkr.ecr.ap-southeast-2.amazonaws.com/support-automations"
        AWS_REGION = "ap-southeast-2"
        
        // Use build number for versioning, with additional timestamp for uniqueness
        DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER}-${new Date().format('yyyyMMdd-HHmmss')}"
        
        // GitHub repository details
        GIT_REPO_URL = "https://github.com/SUDARAJ/IMB_OS_updates.git"
        GIT_BRANCH = "main"
    }
    
    stages {
        stage('Prepare Environment') {
            steps {
                sh '''
                # Update and install necessary tools
                yum update -y
                yum install -y sudo aws-cli docker git wget unzip
                
                # Verify installed versions
                aws --version
                docker --version
                git --version
                '''
            }
        }
        
        stage('Clone Repository') {
            steps {
                script {
                    try {
                        echo "Cloning repository from: ${env.GIT_REPO_URL}"
                        git branch: "${env.GIT_BRANCH}", 
                            url: "${env.GIT_REPO_URL}",
                            // Optional: Add credentials if it's a private repo
                            // credentialsId: 'github-credentials'
                        
                        // Show the latest commit details
                        sh 'git log -1'
                    } catch (Exception e) {
                        echo "Repository cloning failed: ${e.getMessage()}"
                        error "Could not clone the repository"
                    }
                }
            }
        }
        
        stage('Validate Dockerfile') {
            steps {
                script {
                    // Check if Dockerfile exists and is readable
                    def dockerfileExists = fileExists 'Dockerfile'
                    if (!dockerfileExists) {
                        error "Dockerfile not found in the repository"
                    }
                    
                    // Optional: Basic dockerfile lint
                    sh 'cat Dockerfile'
                }
            }
        }
        
        stage('Login to AWS ECR') {
            steps {
                echo 'Logging in to AWS ECR...'
                withCredentials([
                    aws(credentialsId: 'aws-credentials', 
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh """
                    # Configure AWS CLI
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    aws configure set region ${AWS_REGION}
                    
                    # Login to ECR
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REPO_NAME}
                    
                    # Verify ECR repository exists
                    aws ecr describe-repositories --repository-names support-automations
                    """
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        echo "Building Docker image with tag: ${DOCKER_IMAGE_TAG}"
                        sh """
                        docker build \
                            -t ${REPO_NAME}:${DOCKER_IMAGE_TAG} \
                            -t ${REPO_NAME}:latest \
                            --label "build-number=${env.BUILD_NUMBER}" \
                            --label "git-commit=${env.GIT_COMMIT}" \
                            .
                        
                        # Scan image for vulnerabilities (if trivy is installed)
                        # trivy image ${REPO_NAME}:${DOCKER_IMAGE_TAG} || true
                        """
                        
                        // Optional: Docker image size check
                        sh "docker images ${REPO_NAME}"
                    } catch (Exception e) {
                        echo "Docker build failed: ${e.getMessage()}"
                        error "Could not build Docker image"
                    }
                }
            }
        }
        
        stage('Push Docker Image to ECR') {
            steps {
                script {
                    try {
                        echo "Pushing Docker images to ECR"
                        sh """
                        docker push ${REPO_NAME}:${DOCKER_IMAGE_TAG}
                        docker push ${REPO_NAME}:latest
                        """
                    } catch (Exception e) {
                        echo "Docker push failed: ${e.getMessage()}"
                        error "Could not push Docker image to ECR"
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Cleanup steps
            sh """
            docker rmi ${REPO_NAME}:${DOCKER_IMAGE_TAG} || true
            docker rmi ${REPO_NAME}:latest || true
            """
            
            echo "Pipeline execution completed! Docker image tagged with: ${DOCKER_IMAGE_TAG}"
        }
        
        success {
            echo "Docker image successfully built and pushed to ECR"
            
            // Optional: Send notification (e.g., Slack)
            // slackSend color: 'good', message: "Build ${env.BUILD_NUMBER} successful!"
        }
        
        failure {
            echo "Pipeline failed. Check logs for details."
            
            // Optional: Send failure notification
            // slackSend color: 'danger', message: "Build ${env.BUILD_NUMBER} failed!"
        }
    }
}
