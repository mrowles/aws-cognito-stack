#!/usr/bin/env bash

echo "Deploying stack"

export BASEDIR=$(dirname "$0")
echo "BASEDIR [$BASEDIR]"

echo "Deploying cloudformation stack [$STACK_NAME]"
shopt -s failglob
set -eu -o pipefail

echo "Setting up AWS credentials and CLI"
pip install awscli
aws configure set default.aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set default.aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_REGION"

echo "Checking if stack exists ..."

if ! aws cloudformation describe-stacks --region "$AWS_REGION" --stack-name "$STACK_NAME"; then

  echo -e "\nStack does not exist, creating ..."
  aws cloudformation create-stack \
    --region "$AWS_REGION" \
    --stack-name "$STACK_NAME" \
    --template-body "file://$BASEDIR/cloudformation.yml" \
    --capabilities CAPABILITY_IAM \
    --parameters "ParameterKey=CognitoUserPoolName,ParameterValue=$COGNITO_USER_POOL_NAME" \
    "ParameterKey=CognitoClientName,ParameterValue=$COGNITO_USER_POOL_CLIENT_NAME" \
    "ParameterKey=CognitoIdentityPoolName,ParameterValue=$COGNITO_IDENTITY_POOL_NAME" \
    "ParameterKey=ClientDomain,ParameterValue=$CLIENT_DOMAIN" \
    "ParameterKey=AppNiceName,ParameterValue=$APP_NICE_NAME" \
    "ParameterKey=BranchName,ParameterValue=$BRANCH_NAME" \
    "ParameterKey=SesDomainArn,ParameterValue=$SES_DOMAIN_ARN"

  echo "Waiting for stack to be created ..."
  aws cloudformation wait stack-create-complete \
    --region "$AWS_REGION" \
    --stack-name "$STACK_NAME"

else

  echo -e "\nStack exists, attempting update ..."

  set +e
  update_output=$(aws cloudformation update-stack \
    --region "$AWS_REGION" \
    --stack-name "$STACK_NAME" \
    --template-body "file://$BASEDIR/cloudformation.yml" \
    --capabilities CAPABILITY_IAM \
    --parameters "ParameterKey=CognitoUserPoolName,ParameterValue=$COGNITO_USER_POOL_NAME" \
    "ParameterKey=CognitoClientName,ParameterValue=$COGNITO_USER_POOL_CLIENT_NAME" \
    "ParameterKey=CognitoIdentityPoolName,ParameterValue=$COGNITO_IDENTITY_POOL_NAME" \
    "ParameterKey=ClientDomain,ParameterValue=$CLIENT_DOMAIN" \
    "ParameterKey=AppNiceName,ParameterValue=$APP_NICE_NAME" \
    "ParameterKey=BranchName,ParameterValue=$BRANCH_NAME" \
    "ParameterKey=SesDomainArn,ParameterValue=$SES_DOMAIN_ARN" 2>&1)
  status=$?
  set -e

  echo "$update_output"

  if [ $status -ne 0 ]; then

    # Don't fail for no-op update
    if [[ $update_output == *"ValidationError"* && $update_output == *"No updates"* ]]; then
      echo -e "\nFinished create/update - no updates to be performed"
      exit 0
    else
      exit $status
    fi

  fi

  echo "Waiting for stack update to complete ..."
  aws cloudformation wait stack-update-complete \
    --region "$AWS_REGION" \
    --stack-name "$STACK_NAME"

fi

echo "Finished create/update cloudformation stack successfully!"

echo "Complete"
