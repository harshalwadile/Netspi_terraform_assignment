resource "aws_vpc" "net_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "net-vpc"
  }
}

resource "aws_internet_gateway" "net_igw" {
  vpc_id = aws_vpc.net_vpc.id
}


resource "aws_route" "net_route_to_igw" {
  route_table_id         = aws_vpc.net_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.net_igw.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.net_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_security_group" "net_security_group" {
  	vpc_id = aws_vpc.net_vpc.id
	name = "net_security_group"
}

resource "aws_security_group_rule" "ssh_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.net_security_group.id
}

resource "aws_security_group_rule" "ssh_egress" {
  type        = "egress"
  from_port   = 22
  to_port     = 22
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.net_security_group.id
}
output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "security_group_id" {
  value = aws_security_group.net_security_group.id
}

