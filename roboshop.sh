#!/bin/bash

SG_ID="sg-0cbd61e0717109130"  
AMI_ID="ami-0220d79f3f480ecf5" 

for insatnce in $@
do 
  INSTANCE_ID=$( aws ec2 run-instances \
   --image-id $AMI_ID \
   --instance-type t3.micro \
   --security-group-ids $SG_ID \
   --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=mango}]" \
   --query 'instances[0].Instanceid[]' \  
   --output text )  
done




  