pipeline {
    agent { label 'devops-tools' }

    environment {
        AWS_ACCOUNT_ID = ''  // Will be set after AWS CLI installation
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = "public.ecr.aws/q2t9c0i7"
        APP_NAME = 'sampleapp'
        IMAGE_NAME = "${ECR_REGISTRY}/${APP_NAME}"
        IMAGE_TAG = "${BUILD_NUMBER}"
        NAMESPACE = 'sampleapp'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Harishpandu43/devops-project']])
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {

                    // Login to ECR
                    sh """
                        aws ecr-public get-login-password --region ${AWS_REGION} | podman login --username AWS --password-stdin ${ECR_REGISTRY}
                    """

                    // Build and push Docker image
                    sh """
                        podman build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        podman push ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Configure kubectl') {
            steps {
                script {
                    // Update kubeconfig for EKS
                    sh """
                        aws eks update-kubeconfig --region ${AWS_REGION} --name myDevcluster
                        kubectl config current-context
                    """
                }
            }
        }

        stage('Deploy with Helm') {
            steps {
                script {
                    // Create namespace if it doesn't exist
                    sh "kubectl create namespace ${NAMESPACE} || true"

                    // Deploy using Helm
                    sh """
                        helm upgrade --install ${APP_NAME} ./helm/sampleapp \
                            --namespace ${NAMESPACE} \
                            --set image.repository=${IMAGE_NAME} \
                            --set image.tag=${IMAGE_TAG} \
                            --wait \
                            --timeout 300s \
                            --atomic
                    """
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sh """
                        kubectl rollout status deployment/${APP_NAME} -n ${NAMESPACE}
                        kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=${APP_NAME}
                    """
                }
            }
        }
    }

    post {
        success {
            script {
                def albUrl = sh(
                    script: "kubectl get ingress/${APP_NAME} -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'",
                    returnStdout: true
                ).trim()
                
                echo """
                    Deployment Successful!
                    Application URL: http://${albUrl}
                    Image: ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }
        failure {
            echo "Deployment failed! Automatic rollback will be triggered by --atomic flag"
        }
    }
}
