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

                            # Configure AWS CLI
                            cat << EOF > ${WORKSPACE}/.aws/credentials
                            [default]
                            aws_access_key_id = ${AWS_ACCESS_KEY_ID}
                            aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
                            region = ${AWS_REGION}
                            EOF

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
                            aws ecr-public get-login-password --region ${AWS_REGION} > /tmp/ecr_password
                            cat /tmp/ecr_password | sudo podman login --username AWS --password-stdin ${ECR_REGISTRY}
                            rm -f /tmp/ecr_password

                            # Build and push
                            sudo buildah bud --format=docker -t ${IMAGE_NAME}:${IMAGE_TAG} .
                            sudo podman push ${IMAGE_NAME}:${IMAGE_TAG}
                            sudo podman rmi ${IMAGE_NAME}:${IMAGE_TAG} || true
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
