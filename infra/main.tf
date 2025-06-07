

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

    app_instances_primary = [
            {
                name   = "app-instance-primary"
                zone   = "${var.region1}a"
            }
    ]
}

resource "aws_instance" "app_instances_primary"{
    ami = var.ami_id_primary
    instance_type = var.instance_type
    user_data = file("${path.module}/app_init.sh")
    availability_zone = local.app_instances_primary[0].zone
    subnet_id = aws_subnet.public_subnet_region1[0].id
    vpc_security_group_ids = [aws_security_group.app_sg_region1.id,
    aws_security_group.ssm_sg_region1.id,
    aws_security_group.allow_ssh.id]
    iam_instance_profile = aws_iam_instance_profile.session_manager_profile.name
    key_name = aws_key_pair.ssh_key_pair1.key_name
    tags = {
        Name        = local.app_instances_primary[0].name
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        application = "app"
        cost_center = var.cost_center
    }
    provider = aws.primary_region
}

resource "aws_instance" "postgres_instances_primary" {
    count         = length(local.postgres_instances_primary)
    ami           = var.ami_id_primary
    instance_type = var.instance_type
    user_data = file("${path.module}/init.sh")
    availability_zone = local.postgres_instances_primary[count.index].zone
    subnet_id = aws_subnet.private_subnet_region1[count.index].id
    vpc_security_group_ids = [aws_security_group.postgres_sg_region1.id, 
    aws_security_group.ssm_sg_region1.id,
    aws_security_group.etcd_sg_region1.id,
    aws_security_group.patroni_sg_region1.id,
    aws_security_group.app_sg_region1.id]
    iam_instance_profile = aws_iam_instance_profile.session_manager_profile.name
    key_name = aws_key_pair.ssh_key_pair1.key_name
    tags = {
        Name        = local.postgres_instances_primary[count.index].name
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        application = "postgres"
        etcd = "node-${var.region1}-${count.index + 1}"
        cost_center = var.cost_center
    }
    depends_on = [aws_security_group.postgres_sg_region1, 
    aws_security_group.ssm_sg_region1,
    aws_security_group.etcd_sg_region1,
    aws_security_group.patroni_sg_region1]
    provider = aws.primary_region
}

resource "aws_instance" "postgres_instances_secondary" {
    count         = length(local.postgres_instances_secondary)
    ami           = var.ami_id_secondary
    instance_type = var.instance_type
    user_data = file("${path.module}/init.sh")
    availability_zone = local.postgres_instances_secondary[count.index].zone
    subnet_id = aws_subnet.private_subnet_region2[count.index].id
    vpc_security_group_ids = [aws_security_group.postgres_sg_region2.id, 
    aws_security_group.ssm_sg_region2.id,
    aws_security_group.etcd_sg_region2.id,
    aws_security_group.patroni_sg_region2.id]
    iam_instance_profile = aws_iam_instance_profile.session_manager_profile.name
    key_name = aws_key_pair.ssh_key_pair2.key_name


    tags = {
        Name        = local.postgres_instances_secondary[count.index].name
        project     = "Revolut"
        environment = var.env2
        region      = var.region2
        owner       = var.owner
        application = "postgres"
        etcd = "node-${var.region2}-${count.index + 1}"
        cost_center = var.cost_center
    }

    provider = aws.secondary_region
}


