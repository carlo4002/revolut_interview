resource "aws_instance" "example_instance" {
    ami           = var.ami_id # Replace with your infra_user's AMI ID
    instance_type = "t2.micro"

    tags = {
        project = "Revolut"
    }
}


