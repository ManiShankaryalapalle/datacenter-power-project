terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
resource "aws_instance" "machine" {
  count                = 3
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name
  user_data_replace_on_change = true
  user_data = <<-EOF
              #!/bin/bash
              # v2 - ensure ssm and sshd are running
              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent
              systemctl enable sshd
              systemctl start sshd
              EOF

  tags = {
    Name = "datacenter-machine-${count.index}"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}
