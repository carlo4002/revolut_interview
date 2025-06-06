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

resource "aws_iam_policy" "deployment_policy" {
  name        = "deployment-policy"
  description = "Allows the configuration of the cluster postres"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
        ],
        Resource = [
          "arn:aws:secretsmanager:eu-west-1:154983253182:secret:tokengithub-oYjwGg",
          "arn:aws:secretsmanager:eu-west-3:154983253182:secret:tokengithub-j4UPpD"
        ],
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
        ],
        Resource = [
          "*"
        ],
      }
    ],
  })
  tags = {
        Name        = "Session Manager Role"
        project     = "Revolut"
        environment = "global"
        owner       = var.owner
        cost_center = var.cost_center
  }
}

resource "aws_iam_role_policy_attachment" "attach_secrets_read_policy" {
  role       = aws_iam_role.session_manager_role.name
  policy_arn = aws_iam_policy.deployment_policy.arn
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
