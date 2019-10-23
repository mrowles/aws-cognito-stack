#!/usr/bin/env bash

echo "Setting up environment variables"

source ../.env

export ENV="${ENV}"
export AWS_REGION="xxx"
export AWS_ACCESS_KEY_ID="xxx"
export APP_NICE_NAME="xxx"
export APP_SYS_NAME="xxx"
export CLIENT_DOMAIN="xxx"
export BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
export STACK_NAME="${APP_SYS_NAME}-auth-${BRANCH_NAME}"
export COGNITO_USER_POOL_NAME="${APP_SYS_NAME}-${BRANCH_NAME}"
export COGNITO_USER_POOL_CLIENT_NAME="${APP_SYS_NAME}-client-${BRANCH_NAME}"
export COGNITO_IDENTITY_POOL_NAME="${APP_NICE_NAME}${BRANCH_NAME}Identity"
# TODO - automate this
export SES_DOMAIN_ARN="xxx"

echo "Complete"
