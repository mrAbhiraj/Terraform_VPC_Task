aws_region           = "us-west-2"
vpc_cidr             = "10.0.0.0/16"
vpc_name             = "dev-vpc"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones   = ["us-west-2a", "us-west-2b"]
nat_gateway_count    = 1

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
