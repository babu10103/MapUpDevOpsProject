## 1. GitHub Repository Setup:
* Initialize a GitHub public repository with a sample python application that prints "Hello, World!" to the console.
* Included a docker file for the above sample application.

## 2. Docker Image Creation:
For running my simple python application,vconfigured my Dockerfile in such a way that it will be lightweight and builds very quickly. Below foctors are the reasons my docker image is light in weight.
* Base Image:
  Use Alpine as base image. Alpine Linux is known for its lightweight nature, making it a good choice for minimizing the size of the final Docker image.
* Number of layers:
  The size of a Docker image is the sum of it’s layers. Since there are minimal number of layers, the resulting image size will also be small
* Dependencies:
  The number and size of dependencies and libraries required by your application contribute to the image size. This is also one factor as my application has no dependencies.

## 3. AWS ECR Setup:

### Create am IAM User:
1. Create an IAM user
2. Create a custom policy that allows the users to perform create, manage, delete docker images in the ECR repository. For Example, refer below sample IAM Policy which give the user sufficient permissions to create, manage, and delete Docker image repositories in Amazon ECR as well as perform other necessary actions related to image management.
	```{
	    "Version": "2012-10-17",
	    "Statement": [
		{
		    "Effect": "Allow",
		    "Action": [
			"ecr:CreateRepository",
			"ecr:DeleteRepository",
			"ecr:DescribeRepositories",
			"ecr:GetAuthorizationToken",
			"ecr:GetDownloadUrlForLayer",
			"ecr:GetLifecyclePolicy",
			"ecr:GetRepositoryPolicy",
			"ecr:ListImages",
			"ecr:PutImage",
			"ecr:TagResource",
			"ecr:UntagResource"
		    ],
		    "Resource": [
			"arn:aws:ecr:<region>:<account-id>:repository/<repository-name>",
			"arn:aws:ecr:<region>:<account-id>:repository/<repository-name>/*"
		    ]
		}
	    ]
	}
	```
 3. Create Access Keys for the user
	

### Create an AWS ECR repository to store Docker images.
**a. Confiuration for aws cli:** Execute `aws configure` command for setting access key id, access key secret, region and output format.

**b. Authenticate to your default registry:** To authenticate Docker to an Amazon ECR registry with get-login-password, run the aws ecr `get-login-password` command.
```
"aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com"
```

**c. Create repocitory:** Create a ecr image repo using below command
```
aws ecr create-repository \
	--repository-name <reponame> \
	--region <region>
	ECR registry link: 910802444738.dkr.ecr.ap-south-1.amazonaws.com/babumapupdevopsproject
```

## GitHub Actions Workflow:
* The workflow triggers on push or pull request events targeting the main branch.
* The `docker/setup-buildx-action action` is used to set up Docker Buildx, which is a CLI plugin that extends the capabilities of Docker Engine to support multiple platforms.
* The `actions/cache` action is used to cache Docker layers to speed up subsequent workflow runs. The cache key is generated based on the Dockerfile(s) in the repository.
* The Docker image is built using the specified Dockerfile, and it's pushed to the specified AWS ECR repository.
* The workflow uses environment variables for AWS ECR details and secrets for AWS credentials.

## Security and Best Practices:
Use GitHub secrets feature for storing Sensitive data like Access Keys and ECR repocitory details.

