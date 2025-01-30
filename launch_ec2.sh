#!/bin/bash

# Variables - Adjust these as needed
AWS_REGION="ap-south-1"  # Your AWS region
AMI_ID="ami-00bb6a80f01f03502"   # Replace with the correct AMI ID
INSTANCE_TYPE="t2.micro"  # Change to desired instance type
KEY_PAIR_NAME="mykey1"  # Replace with your key pair name
SECURITY_GROUP_NAME="dipakgrp1"  # Replace with your security group name

# Create a new security group
echo "Creating security group..."
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME \
    --description "Security group for EC2 instance" --region $AWS_REGION --query 'GroupId' --output text)


# Check if the security group was created successfully
if [ "$SECURITY_GROUP_ID" == "None" ]; then
    echo "Error: Failed to create security group. Exiting."
    exit 1
fi


# Allow inbound SSH (port 22) access
echo "Allowing SSH access in security group..."
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $AWS_REGION

# Launch EC2 instance
echo "Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type $INSTANCE_TYPE \
    --key-name $KEY_PAIR_NAME --security-group-ids $SECURITY_GROUP_ID --count 1 --region $AWS_REGION \
    --query 'Instances[0].InstanceId' --output text)

# Wait until the instance is running
echo "Waiting for EC2 instance to start..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $AWS_REGION

# Get the public IP address of the instance
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $AWS_REGION \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

# Output instance details
echo "EC2 instance launched successfully!"
echo "Instance ID: $INSTANCE_ID"
echo "Public IP: $PUBLIC_IP"

echo "you can connect the instance through this command"
echo "ssh -i ./ssh/mykey1.pem ubuntu@<PublicIP>"

#chmod 400 .ssh/mykey1.pem


# SSH into the instance (Replace path with the correct private key file)
#echo "Connecting to the instance via SSH..."
#ssh -i .ssh/mykey1.pem ubuntu@$PUBLIC_IP

