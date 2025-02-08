# EKS Jenkins CI/CD Infrastructure

This repository contains Terraform configurations for setting up a Jenkins CI/CD environment on Amazon EKS cluster.

# CI/CD Process Overview

## Architecture and Workflow
```ascii
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  GitHub  │────►│  Jenkins │────►│  Docker  │────►│   EKS    │
│   Push   │     │ Pipeline │     │Registry  │     │ Cluster  │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
                      │                                   ▲
                      │                                   │
                      └───────────── Helm ───────────────┘
```


### Prerequisites:
    - AWS CLI configured with appropriate credentials
    - Terraform (version >= 1.0.0)
    - kubectl installed
    - Helm installed
    - Access to an AWS account with necessary permissions

## Steps to run:

### EKS Cluster setup:
1. Connect your terminal to AWS account. Make sure you have terraform downloaded and installed in your local machine.
2. Download and Run the terraform-scripts/eks-cluster - terraform init, terraform plan (check for the resources), terraform apply.

### Jenkins setup on kubernetes cluster:
1. Download and Run the terraform-scripts/jenkins - terraform init, terraform plan (check for the resources), terraform apply.

#### Skipping backend configuration to my terraform-scripts as it needs to create s3 and dynamodb table for lock and versioning. We can do this a best practice to ensure secured backend files.

Note: Jenkins is deployed using helm charts on the EKS cluster. Get the password from jenkins pod "cat /var/jenkins_home/secrets/initialAdminPassword" and get the loadbalancer url to connect from browser from the jenkins ingress in the eks cluster.

You can now able to login to dashboard with the credentials we provided in the jenkins/values.yaml file.

### Components Deployed:
    - EKS Cluster with managed node groups
    - Jenkins server deployed on EKS
    - AWS Load Balancer Controller
    - Necessary IAM roles and policies
    - Jenkins configuration with predefined plugins
    
    
### Jenkins Configuration:
    Accessing Jenkins
    After deployment, get the Jenkins URL:

    - kubectl get ingress -n jenkins


    
### Default credentials:

    Username: admin
    Password: admin123 (change this in production)
    Available Jenkins Agents
    The setup includes the following agent templates:

    Default Agent with:
    AWS CLI
    `kubectl
    Helm
    Docker support
    
### Using the CI/CD Pipeline
    Create a New Pipeline

    - Go to Jenkins Dashboard
    - New Item → Pipeline
    - Configure Git repository
    - Use the sample Jenkinsfile provided

> change your AWS ECR repo in jenkinsfile

> Install Docker, github, kubernetes and other required plugins.

> Jenkins pipeline will take agents from EKS pods.

> Please add a pipeline in Jenkins with github repository URL.

> Build the job to push the docker image to ECR repo and deploy in kubernetes.

> We have atomic argument added to helm install hence if anything fails it will be automatically rollback the deployment.

Added permissions to jenkins-role 
create test user to add aws-creds in jenkins file

edit cm to add your user in mapuser
mapUsers:
----
- userarn: arn:aws:iam::058264295523:user/test
  username: admin
  groups:
  - system:masters