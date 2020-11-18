#!/usr/bin/bash


aws rds describe-db-instances | jq -Cr '.[] | .[] | select(.DBInstanceArn | contains("pjalajas"))'

#aws ec2 request-spot-instances --availability-zone-group us-east-1a --dry-run help

#https://docs.docker.com/engine/context/ecs-integration/
#docker context create ecs myecscontext

#sleep 3s

#docker context ls
#[pjalajas@sup-pjalajas-2 ~]$ aws ecs help
#[pjalajas@sup-pjalajas-2 ~]$ echo ecs-cli configure --cluster test --default-launch-type FARGATE --config-name test --region eu-west-1
#ecs-cli configure --cluster test --default-launch-type FARGATE --config-name test --region eu-west-1
#aws ecs create-capacity-provider --name fargate --auto-scaling-group-provider (structure) help
#aws ecs help #create-capacity-provider --name fargate --auto-scaling-group-provider (structure) help
#aws ecs list-clusters #create-capacity-provider --name fargate --auto-scaling-group-provider (structure) help
eksctl create cluster \
--name pjalajas-eks-cluster1 \
--region us-east-1 \
--fargate
# --version <1.18> \
