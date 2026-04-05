#!/bin/bash
set -e

# Make sure you already logged in with access key or ~/.aws/credentials 

# =============================================
# CONFIG - change these if needed
# =============================================
INSTANCE_TYPE="t3.medium"
KEY_NAME="x"
SECURITY_GROUP_NAME="MySecurityGroup"
REGION="us-east-1"
SYSTEMS=$(cat <<"EOF"
FileServer_ProxyServer
DNSServer_DHCPServer
VPNServer_TerminalServer
WebServer_MailServer
DatabaseServer
FTPServer_Container
BackupServer_LoadBalancing
FailoverCluster
DomainController
EOF
)

# =============================================
# Create key pair
# =============================================
if ! aws ec2 describe-key-pairs --key-names "$KEY_NAME" >/dev/null 2>&1; then
    echo "Key pair $KEY_NAME does not exist. Creating it..."
    rm -f "$KEY_NAME.pem"
    aws ec2 create-key-pair \
        --key-name "$KEY_NAME" \
        --query 'KeyMaterial' \
        --output text > "${KEY_NAME}.pem"
    chmod 400 "${KEY_NAME}.pem"
else
    echo "Key pair $KEY_NAME already exists. Skipping creation."
fi

# =============================================
# Create security group
# =============================================
# 1. Get the VPC ID
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text)
# 2. Try to find an existing Security Group ID by name
SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=$SECURITY_GROUP_NAME" "Name=vpc-id,Values=$VPC_ID" \
  --query "SecurityGroups[0].GroupId" \
  --output text)
# 3. If SG_ID is "None" or empty, create it
if [ "$SG_ID" == "None" ] || [ -z "$SG_ID" ]; then
  echo "Security group does not exist. Creating..."
  SG_ID=$(aws ec2 create-security-group \
    --group-name "$SECURITY_GROUP_NAME" \
    --description "My security group" \
    --vpc-id "$VPC_ID" \
    --query "GroupId" \
    --output text)
else
  echo "Security group already exists with ID: $SG_ID"
fi
# 4. Authorize ingress (using '|| true' to ignore error if rule already exists)
# Note: For 'all' protocols, use '-1' and omit the port range.
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol all \
  --port all \
  --cidr 0.0.0.0/0 2>/dev/null >/dev/null || echo "Ingress rule already exists."

# =============================================
# Fetch latest Amazon Linux 2023 AMI
# =============================================
echo "Fetching latest Amazon Linux 2023 AMI..."
# AMI_ID=$(aws ssm get-parameter \
#   --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
#   --region "$REGION" \
#   --query "Parameter.Value" \
#   --output text)
AMI_ID="ami-01b14b7ad41e17ba4"
echo "Using AMI: $AMI_ID"

# =============================================
# BaseUserData script 
# =============================================
BASE_USER_DATA=$(cat <<'EOF'
#!/bin/bash -ex
# redirect stdout/stderr to a file
exec >logfile.txt 2>&1

dnf update -y
dnf install -y spal-release
dnf install -y docker-compose git
systemctl enable --now docker
usermod -aG docker ec2-user
su ec2-user -c "git -C /home/ec2-user clone https://github.com/james5635/linux-server-assignment"
cd /home/ec2-user/linux-server-assignment
EOF
)

FTP_PRIVATE_IP=""

# =============================================
# Launch instances one by one
# =============================================
for i in $SYSTEMS; do
    
  USER_DATA="$BASE_USER_DATA"$'\n'

  case "$i" in
    "FileServer_ProxyServer")
      USER_DATA+=$(cat <<'EOF'
      docker compose up -d file_server
      docker compose up -d proxy_server

      dnf groupinstall "Desktop" -y
      dnf install -y tigervnc-server
      su ec2-user -c 'echo -e "dog@123\ndog@123" | vncpasswd'
      echo ':1=ec2-user' > /etc/tigervnc/vncserver.users
      echo -e "session=gnome\nsecuritytypes=vncauth,tlsvnc\ngeometry=1280x720\nlocalhost\nalwaysshared" > /etc/tigervnc/vncserver-config-defaults
      systemctl enable --now vncserver@:1
      echo "finished vncserver"
EOF
      )
      ;;
    "DNSServer_DHCPServer")
      USER_DATA+=$(cat <<'EOF'
      docker compose up -d dns_server
      docker compose up -d dhcp_server
EOF
      )
      ;;
    "VPNServer_TerminalServer")
      USER_DATA+=$(cat <<'EOF'
      docker compose up -d vpn_server
      docker compose up -d terminal_server
EOF
      )
      ;;
    "WebServer_MailServer")
      USER_DATA+=$(cat <<'EOF'
      docker compose up -d web_server
      docker compose up -d mail_server
EOF
      )
      ;;
    "DatabaseServer")
      USER_DATA+=$(cat <<'EOF'
      docker compose up -d database_server
EOF
      )
      ;;
    "BackupServer_LoadBalancing")
      USER_DATA+=$(cat <<EOF
      sed -i "s/FTP_SERVER_IP_PLACEHOLDER/$FTP_PRIVATE_IP/g" src/backup_server/backup_server.sh
      docker compose up -d backup_server
      docker compose up -d load_balancing
EOF
      )
      ;;
    "FailoverCluster")
      USER_DATA+=$(cat <<'EOF'
      docker compose up -d failover_cluster
EOF
      )
      ;;
    "FTPServer_Container")
      USER_DATA+=$(cat <<'EOF'
      docker compose up -d ftp_server
      docker compose up -d docker
EOF
      )
      ;;
    "DomainController")
      USER_DATA+=$(cat <<'EOF'
      docker compose up -d domain_controller
EOF
      )
      ;;
    *)
      echo "$i is not valid!"
      ;;
  esac
    
  echo ""
  echo "Launching instance $i"

  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-groups "$SECURITY_GROUP_NAME" \
    --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":35,"VolumeType":"gp2","DeleteOnTermination":true}}]' \
    --user-data "$USER_DATA" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i},{Key=Environment,Value=DockerDemo}]" \
    --region "$REGION" \
    --query "Instances[0].InstanceId" \
    --output text)

  echo "  Instance $i launched: $INSTANCE_ID"

  # echo "  Waiting for instance $i to be running..."
  # aws ec2 wait instance-running \
  #   --instance-ids "$INSTANCE_ID" \
  #   --region "$REGION"

  PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --region "$REGION" \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text)

  echo "  Instance $i is running!"
  echo "  Public IP: $PUBLIC_IP"
  echo "  SSH: ssh -i $KEY_NAME.pem ec2-user@$PUBLIC_IP"
  
  # If this was the FTP server, save the private IP for the next iterations
  if [ "$i" == "FTPServer_Container" ]; then
    FTP_PRIVATE_IP=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --region "$REGION" \
      --query "Reservations[0].Instances[0].PrivateIpAddress" \
      --output text)
    echo "  Captured FTP Private IP: $FTP_PRIVATE_IP"
  fi
  
done

echo ""
echo "All instances launched successfully!"
