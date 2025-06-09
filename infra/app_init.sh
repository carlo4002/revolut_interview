#! /usr/bin/sh
exec &> /tmp/app_init.log

# --- Script Body ---
echo "Starting application initialization script."
yum update -y
yum install docker -y
service docker start
usermod -a -G docker ec2-user
dnf install postgresql15 -y
echo "install git"
yum install git -y
echo "install jq"
yum install jq -y
echo "install python3-pip"
yum install python3-pip -y
echo "Attempting to install nmap-ncat"
dnf install nmap-ncat -y

REPO_URL="github.com/carlo4002/revolut_interview.git"
GITHUB_USERNAME="carlo4002"
PERSONAL_ACCESS_TOKEN=`aws secretsmanager get-secret-value --secret-id tokengithub --query SecretString --output text | jq -r '."tokengithub"'`
CLONE_URL="https://${GITHUB_USERNAME}:${PERSONAL_ACCESS_TOKEN}@${REPO_URL}"
TARGET_DIR="/opt/app"
mkdir -p "$TARGET_DIR"
echo "Changing directory to ${TARGET_DIR}..."
cd "$TARGET_DIR"
echo "Attempting to clone repository into ${TARGET_DIR}..."
rm -rf ${TARGET_DIR}/revolut_interview
git clone "${CLONE_URL}"

if [ $? -ne 0 ]; then
    echo "Failed to clone repository. Please check the URL and your credentials."
    exit 1
fi

echo "Getting public IP for local instance..."


PRIVATE_IP_HAPROXY=`aws ec2 describe-instances \
    --query "Reservations[].Instances[].PrivateIpAddress" \
    --filters "Name=tag:application,Values=haproxy" "Name=instance-state-name,Values=running" \
    --output text`

if [ -z "$PRIVATE_IP_HAPROXY" ]; then
    echo "No haproxy instance found. Please check the tag and instance state."
    exit 1
fi
echo "changing directory to ${TARGET_DIR}/revolut_interview/app"
cd ${TARGET_DIR}/revolut_interview/app

echo "building docker image..."
docker build -t app .
if [ $? -ne 0 ]; then
    echo "Failed to build Docker image. Please check the Dockerfile and build context."
    exit 1
fi
echo "Docker image built successfully."
echo "Create the user and tables"
PGPASSWORD=postgres_password psql -h ${PRIVATE_IP_HAPROXY} -U postgres -f /opt/app/revolut_interview/app/init_db.sql
if [ $? -ne 0 ]; then
    echo "Failed to execute init.sql. Please check the SQL script and database connection."
    exit 1
fi
echo "Running the application in a Docker container..."
docker run -e TARGET_IP_ADDRESS=${PRIVATE_IP_HAPROXY} -d -p 5000:5000 app 
