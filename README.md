# devops-project

## Steps to run:

### EKS Cluster setup:
1. Connect your terminal to AWS account. Make sure you have terraform downloaded and installed in your local machine.
2. Download and Run the terraform-scripts/eks-cluster - terraform init, terraform plan (check for the resources), terraform apply.

### Jenkins setup on kubernetes cluster:
1. Download and Run the terraform-scripts/jenkins - terraform init, terraform plan (check for the resources), terraform apply.

#### Skipping backend configuration to my terraform-scripts as it needs to create s3 and dynamodb table for lock and versioning. We can do this a best practice to ensure secured backend files.

Note: Jenkins is deployed using helm charts on the EKS cluster. Get the password from jenkins pod "cat /var/jenkins_home/secrets/initialAdminPassword" and get the loadbalancer url to connect from browser from the jenkins ingress in the eks cluster.

You can now able to login to dashboard with the credentials we provided in the jenkins/values.yaml file.

> change your AWS ECR repo in jenkinsfile

> Install Docker, github, kubernetes and other required plugins.

> Jenkins pipeline will take agents from EKS pods.

> Please add a pipeline in Jenkins with github repository URL.

> Build the job to push the docker image to ECR repo and deploy in kubernetes.

> We have atomic argument added to helm install hence if anything fails it will be automatically rollback the deployment.

> 
