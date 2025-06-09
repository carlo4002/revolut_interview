#! /usr/bin/sh

# --- Script Body ---

exec &> /tmp/init.log
REPO_NAME="deployment_postgres"
REPO_URL="github.com/carlo4002/${REPO_NAME}.git"
GITHUB_USERNAME="carlo4002"
PERSONAL_ACCESS_TOKEN=`aws secretsmanager get-secret-value --secret-id tokengithub --query SecretString --output text | jq -r '."tokengithub"'`
CLONE_URL="https://${GITHUB_USERNAME}:${PERSONAL_ACCESS_TOKEN}@${REPO_URL}"
TARGET_DIR="/usr/local/bin/"


echo "Starting Ansible installation script."
echo "Running as user: $(whoami)"

yum update -y
echo "Attempting to install nmap-ncat"
sudo dnf install nmap-ncat -y

echo "Attempting to install pip"
dnf install python3-pip mlocate -y
echo "Attempting to install ansible using pip..."
pip install ansible==6.7.0
# Uncomment the following lines if you want to install ansible-core using dnf
# echo "Attempting to install ansible-core using dnf..."
# dnf install -y ansible-core
echo "Attempting to install git using dnf..."
dnf install -y git
echo "Installing amazon.aws."
/usr/local/bin/ansible-galaxy collection install amazon.aws
echo "Instaling psycopg2-binary"
pip install psycopg2-binary
pip install python-etcd
rm -rf ${TARGET_DIR}/${REPO_NAME}

echo "Changing directory to ${TARGET_DIR}..."
cd "$TARGET_DIR"
echo "Attempting to clone repository into ${TARGET_DIR}..."

git clone "${CLONE_URL}"

if [ $? -ne 0 ]; then
    echo "Failed to clone repository. Please check the URL and your credentials."
    exit 1
fi
echo "Repository cloned successfully."
echo "Changing directory to ${REPO_NAME}..."
cd ${TARGET_DIR}/${REPO_NAME}
echo "Running main.sh script..."
bash main.sh   > /tmp/main.log 2>&1 &

# Get the PID of the last background job
pid=$!

# Wait for the background job to finish
wait $pid
# Check if the main.sh script executed successfully

if [ $? -ne 0 ]; then
    echo "main.sh script failed. Please check /tmp/main.log for details."
    exit 1
fi


TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
echo "Instance ID: $INSTANCE_ID"