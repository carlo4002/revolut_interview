#! /usr/bin/sh
exec &> /tmp/app_init.log

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
echo "Attempting to install nmap-ncat"
sudo dnf install nmap-ncat -y

REPO_URL="github.com/carlo4002/revolut_interview.git"
GITHUB_USERNAME="carlo4002"
PERSONAL_ACCESS_TOKEN=`aws secretsmanager get-secret-value --secret-id tokengithub --query SecretString --output text | jq -r '."tokengithub"'`
CLONE_URL="https://${GITHUB_USERNAME}:${PERSONAL_ACCESS_TOKEN}@${REPO_URL}"
TARGET_DIR="/opt/app"
mkdir -p "$TARGET_DIR"
echo "Changing directory to ${TARGET_DIR}..."
cd "$TARGET_DIR"
echo "Attempting to clone repository into ${TARGET_DIR}..."

git clone "${CLONE_URL}"

if [ $? -ne 0 ]; then
    echo "Failed to clone repository. Please check the URL and your credentials."
    exit 1
fi

echo "Getting public IP for local instance..."
PUBLIC_IP=`aws ec2 describe-instances \
    --instance-ids ${INSTANCE_ID} \
    --query "Reservations[].Instances[].PublicIpAddress" \
    --output text`

PRIVATE_IP=`aws ec2 describe-instances \
    --instance-ids ${INSTANCE_ID} \
    --query "Reservations[].Instances[].PrivateIpAddress" \
    --output text`

echo "run the next commands "

echo "cd ${TARGET_DIR}/revolut_interview/app"

echo "#building docker image..."
echo "docker build -t app ."
echo "docker run -t -i -p 5000:5000 app"