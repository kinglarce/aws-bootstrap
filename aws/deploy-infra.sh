#!/bin/bash

AWS_CLI_PROFILE=awsbootstrap
EC2_INSTANCE_TYPE=t2.micro
GITHUB_ACCESS_TOKEN=$(cat ~/.github/aws-bootstrap-access-token)
GITHUB_OWNER=$(cat ~/.github/aws-bootstrap-owner)
GITHUB_REPO=$(cat ~/.github/aws-bootstrap-repo)
GITHUB_BRANCH=master
REGION=ap-southeast-1
STACK_NAME=awsbootstrap
SETUP_STACK_NAME=$STACK_NAME-setup

AWS_ACCOUNT_ID=`aws sts get-caller-identity --profile ${AWS_CLI_PROFILE} --query "Account" --output text`
CLOUDFORMATION_BUCKET="$STACK_NAME-$REGION-cfn-$AWS_ACCOUNT_ID"
CODEPIPELINE_BUCKET="$STACK_NAME-$REGION-codepipeline-$AWS_ACCOUNT_ID"

deploy_setup_stack() {
    echo "deploying setup stack..."

    aws cloudformation deploy \
        --region $REGION \
        --profile $AWS_CLI_PROFILE \
        --stack-name $SETUP_STACK_NAME \
        --template-file setup.yml \
        --no-fail-on-empty-changeset \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameter-overrides \
            CodePipelineBucket=$CODEPIPELINE_BUCKET
}

deploy_stack() {
    deploy_setup_stack
    echo "deploying stack..."

    aws cloudformation deploy \
      --region $REGION \
      --profile $AWS_CLI_PROFILE \
      --stack-name $STACK_NAME \
      --template-file main.yml \
      --no-fail-on-empty-changeset \
      --capabilities CAPABILITY_NAMED_IAM \
      --parameter-overrides EC2InstanceType=$EC2_INSTANCE_TYPE \
        GitHubOwner=$GITHUB_OWNER \
        GitHubRepo=$GITHUB_REPO \
        GitHubBranch=$GITHUB_BRANCH \
        GitHubPersonalAccessToken=$GITHUB_ACCESS_TOKEN \
        CodePipelineBucket=$CODEPIPELINE_BUCKET

    # If the deploy succeeded, show the DNS name of the created instance
    if [ $? -eq 0 ]; then
      aws cloudformation list-exports \
        --profile awsbootstrap \
        --query "Exports[?starts_with(Name,'InstanceEndpoint')].Value"
    fi
}

check_stacks() {
    aws cloudformation describe-stacks --profile $AWS_CLI_PROFILE --stack-name $SETUP_STACK_NAME
    aws cloudformation describe-stacks --profile $AWS_CLI_PROFILE --stack-name $STACK_NAME
}

check_stacks_events() {
    aws cloudformation describe-stack-events --profile $AWS_CLI_PROFILE  --stack-name $STACK_NAME
}

delete_stack() {
    echo "deleting stack '$STACK_NAME'"
    aws cloudformation delete-stack --profile $AWS_CLI_PROFILE --stack-name $STACK_NAME
}

delete_setup_stack() {
    echo "deleting stack '$SETUP_STACK_NAME'"
    aws cloudformation delete-stack --profile $AWS_CLI_PROFILE --stack-name $SETUP_STACK_NAME
}

# ----------------------------------------------------------------------

# deploy_setup_stack
deploy_stack
# check_stacks
# delete_stack
# delete_setup_stack