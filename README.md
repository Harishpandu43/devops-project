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

Note: Jenkins is deployed using helm charts on the EKS cluster. Get the password from jenkins pod "cat /var/jenkins_home/secrets/initialAdminPassword" and get the loadbalancer url to connect from browser from the jenkins-ingress in the eks cluster.

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

### Notes:

- Change your AWS ECR regsitry in jenkinsfile and accordingly in helm/sampleapp/values.yaml.

- Install Docker, github, kubernetes and other required plugins on jenkins.

- Jenkins pipeline will take agents from EKS pods. dockeragent folder has the agent image which is used to create the jenkins-agents pods in EKS.

- Build the job to push the docker image to ECR repo and deploy the sample nodejs app in kubernetes using helm charts.

- We have atomic argument added to helm install hence if anything fails it will be automatically rollback the deployment.

- [If required] Please add required permissions to jenkins-role created via terraform scripts [ EKS, STS, ECR-PUBLIC]

- Create test user in IAM USER service in AWS to add it's accesskey and secretkey in aws-credentials in jenkins dashboard to have access to the AWS. Make sure this IAM User have all the neccessary permissions to take action on EKS cluster.

- Update your aws-auth configmap to allow this user to perform actions.
    ```    
    mapUsers:
        - userarn: arn:aws:iam::058264295523:user/test
          username: admin
          groups:
          - system:masters
    ```

- [Optional] We can also enable github webhooks with poll scm to automate the cicd process whenever there is a commit it will automatically triggers the build.

- After the deployment is successfull you will get the ingress link where you can access your nodejs application.

- Once after the infra is deployed you can make any changes to your source code and just push it to the github and trigger the build latest code will be deployed in EKS cluster.
