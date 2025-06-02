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

resource "aws_instance" "postgres_instances_primary" {
    count         = length(local.postgres_instances_primary)
    ami           = var.ami_id_primary
    instance_type = "t2.micro" 
    availability_zone = local.postgres_instances_primary[count.index].zone
    subnet_id = aws_subnet.private_subnet_region1[count.index].id
    vpc_security_group_ids = [aws_security_group.postgres_sg_region1.id]

    tags = {
        Name        = local.postgres_instances_primary[count.index].name
        project     = "Revolut"
        environment = "primary"
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
    instance_type = "t2.micro" 
    availability_zone = local.postgres_instances_secondary[count.index].zone
    subnet_id = aws_subnet.private_subnet_region2[count.index].id
    vpc_security_group_ids = [aws_security_group.postgres_sg_region2.id]

    tags = {
        Name        = local.postgres_instances_secondary[count.index].name
        project     = "Revolut"
        environment = "secondary"
        region      = var.region2
        owner       = var.owner
        application = "postgres"
        cost_center = var.cost_center
    }

    provider = aws.secondary_region
}


