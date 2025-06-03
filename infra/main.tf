

locals {
    postgres_instances_primary = [
        for key, instance in var.postgres_instances_primary : {
            name   = instance.name
            zone   = "${var.region1}${instance.zone}"
        }
    ]

    postgres_instances_secondary = [
        for key, instance in var.postgres_instances_secondary : {
            name   = instance.name
            zone   = "${var.region2}${instance.zone}"
        }
    ]
}

variable "ssm_user_data" {
  default = <<-EOF
    #!/bin/bash
    exec &> /tmp/init.log
    if [ -f /etc/system-release ]; then
      yum install -y amazon-ssm-agent
      systemctl enable amazon-ssm-agent
      systemctl start amazon-ssm-agent
      
    elif [ -f /etc/debian_version ]; then
      apt-get update
      apt-get install -y amazon-ssm-agent
      systemctl enable amazon-ssm-agent
      systemctl start amazon-ssm-agent
    fi
    echo "SSM Agent installed and started successfully."
    # Additional commands can be added here
    "
  EOF
}

resource "aws_iam_role" "session_manager_role" {
    name               = "session-manager-role"
    assume_role_policy = jsonencode({
        Version   = "2012-10-17"
        Statement = [
            {
                Effect      = "Allow"
                Principal   = {
                        Service = "ec2.amazonaws.com"
                }
                Action      = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        Name        = "Session Manager Role"
        project     = "Revolut"
        environment = "global"
        owner       = var.owner
        cost_center = var.cost_center
    }
}

resource "aws_iam_role_policy_attachment" "session_manager_attach" {
    role       = aws_iam_role.session_manager_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" // AWS-managed policy for Systems Manager
}

resource "aws_iam_role_policy_attachment" "EC2RoleforSSM_attach" {
    role       = aws_iam_role.session_manager_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM" 
}

resource "aws_iam_instance_profile" "session_manager_profile" {
    name = "session-manager-instance-profile"
    role = aws_iam_role.session_manager_role.name
}

resource "aws_instance" "postgres_instances_primary" {
    count         = length(local.postgres_instances_primary)
    ami           = var.ami_id_primary
    instance_type = var.instance_type
    user_data = var.ssm_user_data
    availability_zone = local.postgres_instances_primary[count.index].zone
    subnet_id = aws_subnet.private_subnet_region1[count.index].id
    vpc_security_group_ids = [aws_security_group.postgres_sg_region1.id, aws_security_group.ssm_sg_region1.id]
    iam_instance_profile = aws_iam_instance_profile.session_manager_profile.name

    tags = {
        Name        = local.postgres_instances_primary[count.index].name
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        application = "postgres"
        cost_center = var.cost_center
    }
    
    provider = aws.primary_region
}

resource "aws_instance" "postgres_instances_secondary" {
    count         = length(local.postgres_instances_secondary)
    ami           = var.ami_id_secondary
    instance_type = var.instance_type
    user_data = var.ssm_user_data
    availability_zone = local.postgres_instances_secondary[count.index].zone
    subnet_id = aws_subnet.private_subnet_region2[count.index].id
    vpc_security_group_ids = [aws_security_group.postgres_sg_region2.id, aws_security_group.ssm_sg_region2.id]
    iam_instance_profile = aws_iam_instance_profile.session_manager_profile.name
    

    tags = {
        Name        = local.postgres_instances_secondary[count.index].name
        project     = "Revolut"
        environment = var.env2
        region      = var.region2
        owner       = var.owner
        application = "postgres"
        cost_center = var.cost_center
    }

    provider = aws.secondary_region
}


