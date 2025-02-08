pipeline {
    agent { label 'devops-tools' }

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = "public.ecr.aws/q2t9c0i7"
        APP_NAME = 'sampleapp'
        IMAGE_NAME = "${ECR_REGISTRY}/${APP_NAME}"
        IMAGE_TAG = "latest"
        NAMESPACE = 'sampleapp'
        EKS_CLUSTER_NAME = 'myDevcluster'
        KUBE_CONFIG = "${WORKSPACE}/.kube/config"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Harishpandu43/devops-project']])
                sh '''
                    pwd
                    ls -la
                    if [ -f Dockerfile ]; then
                        echo "Dockerfile exists"
                        cat Dockerfile
                    else
                        echo "Dockerfile not found!"
                        exit 1
                    fi
                '''
            }
        }

        stage('Configure AWS and kubectl') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        
                        sh """
                            # Create directories
                            mkdir -p ${WORKSPACE}/.kube
                            mkdir -p ${WORKSPACE}/.aws
        
                            # Configure AWS CLI - Note the proper formatting here
                            echo '[default]' > ${WORKSPACE}/.aws/credentials
                            echo "aws_access_key_id = ${AWS_ACCESS_KEY_ID}" >> ${WORKSPACE}/.aws/credentials
                            echo "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> ${WORKSPACE}/.aws/credentials
                            echo "region = ${AWS_REGION}" >> ${WORKSPACE}/.aws/credentials
        
                            # Set proper permissions
                            chmod 600 ${WORKSPACE}/.aws/credentials
        
                            # Set AWS credentials path
                            export AWS_SHARED_CREDENTIALS_FILE=${WORKSPACE}/.aws/credentials
        
                            # Verify AWS authentication
                            aws sts get-caller-identity
        
                            # Configure kubectl
                            aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME} --kubeconfig ${KUBE_CONFIG}
                            
                            # Verify kubectl
                            export KUBECONFIG=${KUBE_CONFIG}
                            kubectl get nodes
                        """
                    }
                }
            }
        }
        
        stage('Build & Push Image') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        
                sh """
                    export AWS_SHARED_CREDENTIALS_FILE=${WORKSPACE}/.aws/credentials

                    # ECR Login
                    aws ecr-public get-login-password --region us-east-1 | sudo podman login --username AWS --password-stdin ${ECR_REGISTRY}
                    
                    pwd
                    
                    # Build and push using podman
                    sudo podman build --storage-driver=vfs -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    sudo podman push --storage-driver=vfs ${IMAGE_NAME}:${IMAGE_TAG}
                    sudo podman rmi --storage-driver=vfs ${IMAGE_NAME}:${IMAGE_TAG} || true
                """
                    }
                }
            }
        }

        stage('Deploy with Helm') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        
                        sh """
                            export AWS_SHARED_CREDENTIALS_FILE=${WORKSPACE}/.aws/credentials
                            export KUBECONFIG=${KUBE_CONFIG}

                            # Create namespace
                            kubectl create namespace ${NAMESPACE} || true

                            # Deploy using Helm
                            helm upgrade --install ${APP_NAME} ${WORKSPACE}/sampleapp/helm/sampleapp \
                                --namespace ${NAMESPACE} \
                                --set image.repository=${IMAGE_NAME} \
                                --set image.tag=${IMAGE_TAG} \
                                --wait \
                                --timeout 100s \
                                --atomic
                        """
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        
                        sh """
                            export AWS_SHARED_CREDENTIALS_FILE=${WORKSPACE}/.aws/credentials
                            export KUBECONFIG=${KUBE_CONFIG}

                            kubectl rollout status deployment/${APP_NAME} -n ${NAMESPACE}
                            kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=${APP_NAME}
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            sh """
                sudo podman system prune -f || true
                rm -rf ${WORKSPACE}/.kube || true
                rm -rf ${WORKSPACE}/.aws || true
            """
        }
        success {
            script {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-credentials',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    
                    sh """
                        export KUBECONFIG=${KUBE_CONFIG}
                        albUrl=\$(kubectl get ingress/${APP_NAME} -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
                        echo "Deployment Successful!"
                        echo "Application URL: http://\${albUrl}"
                        echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
                    """
                }
            }
        }
        failure {
            echo "Deployment failed! Automatic rollback will be triggered by --atomic flag"
        }
    }
}
