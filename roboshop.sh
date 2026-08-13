#!/bin/bash

SG_ID="sg-0cbd61e0717109130"  
AMI_ID="ami-0220d79f3f480ecf5" 
ZONE_ID="Z02925721AYKY0N0DT9IV"  
DOMAIN_NAME="daws88a.online"


for instance in $@
do 
    INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query "Instances[0].InstanceId" \
    --output text )

  if [ "$instance" == "frontend" ]; then 
      IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[].Instances[].PublicIpAddress" \
    --output text)
    RECORD_NAME="$DOMAIN_NAME"  # daws88a.online
    
    else
    
      IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[].Instances[].PrivateIpAddress" \
    --output text) 
    RECORD_NAME="$INSTANCE.$DOMAIN_NAME" # mango.daws88a.online
  fi 
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
  {
    "Comment": "Update frontend record",         
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'$RECORD_NAME'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [
            {
              "Value": "'$IP'"
            }
          ]
        }
      }
    ]
  }
'

done






  