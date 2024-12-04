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
                amazon-linux-extras enable docker
                yum install -y sudo aws-cli docker git > /dev/null 2>&1
                # Start Docker daemon
                echo "Starting Docker daemon..."
                dockerd &

                echo "Verifying Docker installation..."
                docker --version
                '''
            }
        }
        stage('Clone Repository') {
            steps {
                echo 'Cloning GitHub repository...'
                git branch: 'main', url: "${env.GIT_REPO_URL}"
            }
        }
        stage('Configure AWS CLI') {
            steps {
                echo 'Logging in to AWS ECR...'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']]) {
                    sh """
                    # Configure AWS CLI
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    aws configure set region ap-southeast-2	
                    """
                }
            }
        }
        stage('Login to ECR') {
            steps {
                sh """
                # Login to ECR
                aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${REPO_NAME}
					
                # Verify ECR repository exists
                aws ecr describe-repositories --repository-names support-automations
                """
            }
        }

	stage('Install kubectl') {
    		steps {
        		sh '''
        		# Install kubectl
        		echo "Installing kubectl..."
        		curl -LO "https://dl.k8s.io/release/v1.27.4/bin/linux/amd64/kubectl"
        		chmod +x ./kubectl
        		mv ./kubectl /usr/local/bin/kubectl
        
        		# Verify kubectl installation
        		kubectl version --client
        		'''
    			}
		}

	stage('Connect to EKS Cluster') {
    		steps {
        		sh '''
        		# Configure kubectl to use the EKS cluster
        		echo "Connecting to EKS cluster..."
        		aws eks --region ${AWS_REGION} update-kubeconfig --name stg-eks
        
        		# Verify kubectl connection
        		kubectl get nodes
        		'''
    		}
		}    
    
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image with tag: ${DOCKER_IMAGE_TAG}..."
                //sh "docker build -t ${REPO_NAME}:${DOCKER_IMAGE_TAG} ."
            }
        }
        stage('Push Docker Image to ECR') {
            steps {
                echo "Pushing Docker image to ECR with tag: ${DOCKER_IMAGE_TAG}..."
                //sh "docker push ${REPO_NAME}:${DOCKER_IMAGE_TAG}"
            }
        }
        
    }
    post {
        always {
            echo "Pipeline execution completed! Docker image tagged with: ${DOCKER_IMAGE_TAG}"
        }
    }
}
