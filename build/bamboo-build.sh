#!/bin/bash

set -e
toolsAccountId="817467411022" # OldDev
repoName="sourceallies/separate-db-template-example"
imageName=$toolsAccountId.dkr.ecr.us-east-1.amazonaws.com/$repoName:$bamboo_buildNumber

echo "Creating ECR repository if necessary..."
if [ "0" == $(aws ecr describe-repositories --output text --query 'repositories[*][repositoryName]' | grep -c $repoName) ]; then
    aws ecr create-repository --repository-name $repoName
fi

echo "Setting repository policy..."
aws ecr set-repository-policy \
    --repository-name $repoName \
    --policy-text '{
        "Version": "2008-10-17",
        "Statement": [
            {
                "Sid": "new statement",
                "Effect": "Allow",
                "Principal": {
                    "AWS": [
                        "729161019481",
                        "035409092456",
                        "487696863217"
                    ]
                },
                "Action": [
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:BatchGetImage",
                    "ecr:GetAuthorizationToken",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:GetRepositoryPolicy",
                    "ecr:DescribeRepositories",
                    "ecr:ListImages"
                ]
            }
        ]
    }'

echo "Building Docker image..."
docker build -t $imageName .

eval "$(aws ecr get-login)"

echo "Pushing image $imageName to ECR..."
docker push $imageName

echo "Build finished!"
