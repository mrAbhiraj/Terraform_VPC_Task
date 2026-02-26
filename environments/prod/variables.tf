variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "nat_gateway_count" {
  type = number
}

variable "tags" {
  type = map(string)
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name"
}
