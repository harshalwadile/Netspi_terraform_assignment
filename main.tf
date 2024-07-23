provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
}

module "roles" {
  source = "./modules/roles"

}

resource "aws_s3_bucket" "net_bucket" {
  bucket = "netspi-test-bucket"
}
resource "aws_s3_bucket_ownership_controls" "net_control" {
  bucket = aws_s3_bucket.net_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "net_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.net_control]

  bucket = aws_s3_bucket.net_bucket.id
  acl    = "private"
}

resource "aws_efs_file_system" "net_efs" {
  creation_token = "net-efs-volume"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
}
resource "aws_key_pair" "net_keypair" {
  key_name   = "net-keypair"
  public_key = file("./net_public_key") 
}

data "aws_eip" "net_eip" {
  filter {
    name   = "tag:Project"
    values = ["NetSPI_EIP"]
  }
}

resource "aws_instance" "net_ec2" {
  ami           = "ami-0427090fd1714168b"
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnet_id

  associate_public_ip_address = true
  ebs_optimized               = true
  key_name                    = aws_key_pair.net_keypair.key_name
  iam_instance_profile	      = module.roles.net_inst_profile

  user_data = <<-EOF
    #!/bin/bash
    yum install -y amazon-efs-utils
    mkdir -p /data/test
    echo '${aws_efs_file_system.net_efs.dns_name}:/ /data/test efs _netdev,tls 0 0' >> /etc/fstab
    mount -a -t efs
  EOF

  vpc_security_group_ids = [module.vpc.security_group_id]

  tags = {
    Name = "net-ec2-instance"
  }
}

resource "aws_eip_association" "net_eip_association" {
  instance_id   = aws_instance.net_ec2.id
  allocation_id = data.aws_eip.net_eip.id
}

output "net_bucket_id" {
  value = aws_s3_bucket.net_bucket.id
}

output "efs_volume_id" {
  value = aws_efs_file_system.net_efs.id
}

output "ec2_instance_id" {
  value = aws_instance.net_ec2.id
}

output "security_group_id" {
  value = module.vpc.security_group_id
}

output "subnet_id" {
  value = module.vpc.public_subnet_id
}
