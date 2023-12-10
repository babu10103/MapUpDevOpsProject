# MapUpDevOpsProject


## 1. GitHub Repository Setup:
	1. I initialized a GitHub public repository with a sample python application that prints "Hello, World!" to the console.
	2. Included a docker file for the above sample application.

## 2. Docker Image Creation:

    For running my simple python application, I configured my Dockerfile in such a way that it will be lightweight and builds very quickly. Below foctors are the reasons my docker image is light in weight.

    a. Base Image:
        I used Alpine as base image. Alpine Linux is known for its lightweight nature, making it a good choice for minimizing the size of the final Docker image. 
    b. Number of layers:
        The size of a Docker image is the sum of it’s layers. Since there are minimal number of layers, the resulting image size will also be small
    c. Dependencies:
        The number and size of dependencies and libraries required by your application contribute to the image size. This is also one factor as my application has no dependencies.

## 3. AWS ECR Setup:

### 1. Create an AWS ECR repository to store Docker images.
    a. Create Access keys:
        1. Navigate to AWS Console, and sign in with your AWS account.
        2. click on root user in navigation bar
        3. click on Security Credentials.
        4. Got to "Access keys" section.
        5. Click on the "Create access key" button.
        **NOTE**: it's essential to handle root user credentials with extreme care due to their elevated privileges.

    b. Confiuration for aws cli:
        1. Execute `aws configure` command for setting access key id, access key secret, region and output format.

    c. Authenticate to your default registry: To authenticate Docker to an Amazon ECR registry with get-login-password, run the aws ecr `get-login-password` command.
        "aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com"

    d. Create repocitory: Create a ecr image repo using below command
        aws ecr create-repository \
        --repository-name <reponame> \
        --region <region>
    ECR registry link: 910802444738.dkr.ecr.ap-south-1.amazonaws.com/babumapupdevopsproject

### 2. Configure necessary IAM roles and policies for access management:
    As I created access keys as a root user, I did not had to create IAM roles and Policies, and this not a recommended also. But below I documented how we can create a policy and attach it to a role.

    ecr-policy.json:
        {
            "Version":"2012-10-17",
            {
                "Sid":"ManageRepositoryContents",
                "Effect":"Allow",
                "Principal": {
                    "AWS": [
                        "arn:aws:iam::account-id:user/push-pull-user-1",
                        "arn:aws:iam::account-id:user/push-pull-user-2"
                    ]
                },
                "Action":[
                        "ecr:BatchCheckLayerAvailability",
             :           "ecr:GetDownloadUrlForLayer",
                        "ecr:GetRepositoryPolicy",
                        "ecr:DescribeRepositories",
                        "ecr:ListImages",
                        "ecr:DescribeImages",
                        "ecr:BatchGetImage",
                        "ecr:InitiateLayerUpload",
                        "ecr:UploadLayerPart",
                        "ecr:CompleteLayerUpload",
                        "ecr:PutImage"
                ],
                "Resource":"arn:aws:ecr:<region>:<account-id>:repository/<repocitory-name>"
            }
        }

    trust-policy.json:
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
                }
            ]
        }

    Explanation:
        1. Create an IAM policy for ECR access.
        2. Create an IAM role with a trust policy for EC2 instances.
        3. Attach the IAM policy to the IAM role.

## GitHub Actions Workflow:
    The workflow triggers on push or pull request events targeting the main branch.

    The `docker/setup-buildx-action action` is used to set up Docker Buildx, which is a CLI plugin that extends the capabilities of Docker Engine to support multiple platforms.

    The `actions/cache` action is used to cache Docker layers to speed up subsequent workflow runs. The cache key is generated based on the Dockerfile(s) in the repository.

    The Docker image is built using the specified Dockerfile, and it's pushed to the specified AWS ECR repository.

    The workflow uses environment variables for AWS ECR details and secrets for AWS credentials.

## Security and Best Practices:
    I used GitHub secrets feature for storing Sensitive data like Access Keys and ECR repocitory details.

## Documentation:
    Provided the README.md file which explains the setup and how the workflow functions. Also included the prerequisites needed to replicate the setup.

## Bonus Tasks:
    1. Included a step in workflow to scan the image for vulnerabilities by using `alexjurkiewicz/ecr-scan-image@v1.5.0` action 
    2. As a last step in the workflow, I included email notification, which uses `dawidd6/action-send-mail@v2` action. The email will be triggered always. The email body will contain the job status and also number of vulnerabilities found in Image scan Step.

## Screenshots:
    1. All Workflows:
        ![workflows](https://github.com/babu10103/MapUpDevOpsProject/assets/64721017/b53b1800-dfdf-4071-914e-05b5a3b163f2)
    2. Build:
    	![build](https://github.com/babu10103/MapUpDevOpsProject/assets/64721017/075a819e-43af-40c6-9f6d-13952ef2ee01)
    3. Email Notification:
    	![Screenshot 2023-12-10 102628](https://github.com/babu10103/MapUpDevOpsProject/assets/64721017/8864bb7d-fa03-4ed7-a546-363879e0f7b9)
