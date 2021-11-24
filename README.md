# terraform
This repo is to store the terraform scripts

## Phase1

In this phase, creating the terraform scripts for AWS.

Authentication to AWS via Terraform:

- For Terraform to be able to make changes in your AWS account, you will need to set the AWS credentials for the IAM user you created earlier as the environment variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
- In addition to environment variables, Terraform supports the same authentication mechanisms as all AWS CLI and SDK tools. Therefore, it’ll also be able to use credentials in $HOME/.aws/credentials, which are automatically generated if you run the configure command on the AWS CLI, or IAM Roles, which you can add to almost any resource in AWS.

## Phase2

Creating some resources on GCP

