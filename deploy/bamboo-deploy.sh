#!/bin/bash

set -e

toolsAccountId="817467411022" #OldDev
repoName="sourceallies/separate-db-template-example"
stackName="Separate-DB-Template-Example"
imageName=$toolsAccountId.dkr.ecr.us-east-1.amazonaws.com/$repoName:$bamboo_buildNumber
adminARN="$(printenv bamboo_SAI_${bamboo_deploy_environment}_ADMIN_ARN )"

#look up the ARN for the environment we are deploying into
echo "Assuming $bamboo_deploy_environment role $adminARN..."
source /bin/assumeRole $adminARN

defaultVpcId=`aws ec2 describe-vpcs \
    --filters "Name=isDefault,Values=true" \
    --query 'Vpcs[*].VpcId' \
    --output=text`

subnetIds=`aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$defaultVpcId" \
    --query "Subnets[*].SubnetId" \
    --output=text`

# Don't inline this with the above or it won't produce a commma separated list
subnetIds=`echo $subnetIds | tr ' ' '\,'`

# create or update the cloudformation stack
cloudFormationCreateOrUpdateStack $stackName \
    --template-body file://cloudformation.yml \
    --tags \
        Key=Customer,Value=Source_Allies \
        Key=Name,Value=$stackName \
        Key=Contact,Value=Darin_Webb \
        Key=ContactEmail,Value=dwebb@sourceallies.com \
        Key=Version,Value=$bamboo_deploy_version \
        Key=Environment,Value=$bamboo_deploy_environment \
    --parameters \
        ParameterKey=Image,ParameterValue=$imageName \
        ParameterKey=Version,ParameterValue=$bamboo_deploy_version \
        ParameterKey=HostedZone,ParameterValue=$bamboo_HostedZone \
        ParameterKey=DNSName,ParameterValue=$bamboo_DNSName \
        ParameterKey=DBPassword,ParameterValue=$bamboo_DBPassword \
        ParameterKey=VpcId,ParameterValue=$defaultVpcId \
        ParameterKey=SubnetIds,ParameterValue="'$subnetIds'"
