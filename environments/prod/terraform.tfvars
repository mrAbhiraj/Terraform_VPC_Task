aws_region           = "us-east-1"
vpc_cidr             = "10.1.0.0/16"
vpc_name             = "prod-vpc"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]
nat_gateway_count    = 2
key_name             = "your-key-pair-name"

tags = {
  Environment = "prod"
  ManagedBy   = "Terraform"
}
