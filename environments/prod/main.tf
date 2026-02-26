module "vpc" {
  source               = "../../modules/vpc"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = module.vpc.vpc_id
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}

module "public_subnets" {
  source                  = "../../modules/subnets"
  vpc_id                  = module.vpc.vpc_id
  subnet_cidrs            = var.public_subnet_cidrs
  availability_zones      = var.availability_zones
  subnet_name             = "${var.vpc_name}-public"
  map_public_ip_on_launch = true
  tags                    = var.tags
}

module "private_subnets" {
  source             = "../../modules/subnets"
  vpc_id             = module.vpc.vpc_id
  subnet_cidrs       = var.private_subnet_cidrs
  availability_zones = var.availability_zones
  subnet_name        = "${var.vpc_name}-private"
  tags               = var.tags
}

module "nat_gateway" {
  source             = "../../modules/nat"
  nat_gateway_count  = var.nat_gateway_count
  public_subnet_ids  = module.public_subnets.subnet_ids
  nat_name           = "${var.vpc_name}-nat"
  tags               = var.tags
}

module "public_route_table" {
  source           = "../../modules/route-tables"
  vpc_id           = module.vpc.vpc_id
  route_table_name = "${var.vpc_name}-public-rt"
  routes = [
    {
      destination_cidr_block = "0.0.0.0/0"
      gateway_id             = aws_internet_gateway.igw.id
    }
  ]
  subnet_ids = module.public_subnets.subnet_ids
  tags       = var.tags
}

module "private_route_table" {
  source           = "../../modules/route-tables"
  vpc_id           = module.vpc.vpc_id
  route_table_name = "${var.vpc_name}-private-rt"
  routes = [
    {
      destination_cidr_block = "0.0.0.0/0"
      nat_gateway_id         = module.nat_gateway.nat_gateway_ids[0]
    }
  ]
  subnet_ids = module.private_subnets.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "public_sg" {
  name        = "Public-Instance-SG"
  description = "Security group for public instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "Public-Instance-SG" })
}

resource "aws_security_group" "private_sg" {
  name        = "Private-Instance-SG"
  description = "Security group for private instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "Private-Instance-SG" })
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "public" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = module.public_subnets.subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = var.key_name

  tags = merge(var.tags, { Name = "Public-Instance-${count.index + 1}" })
}

resource "aws_instance" "private" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = module.private_subnets.subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = var.key_name

  tags = merge(var.tags, { Name = "Private-Instance-${count.index + 1}" })
}
