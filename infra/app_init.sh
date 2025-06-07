#! /usr/bin/sh

# --- Script Body ---
echo "Starting application initialization script."
yum update -y
yum install docker -y
service docker start
usermod -a -G docker ec2-user

echo "install git"
yum install git -y
echo "install jq"
yum install jq -y
echo "install python3-pip"
yum install python3-pip -y