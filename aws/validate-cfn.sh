#!/bin/bash

CLI_PROFILE=awsbootstrap

# Validate the CloudFormation template

# setup s3 code pipeline
aws cloudformation validate-template \
  --profile $CLI_PROFILE \
  --template-body file://setup.yml \

# main cloud formation deploy
aws cloudformation validate-template \
  --profile $CLI_PROFILE \
  --template-body file://main.yml \
