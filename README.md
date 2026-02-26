# AWS VPC Infrastructure with Terraform

> A complete guide to building a production-ready, secure multi-tier VPC architecture on AWS using Terraform Infrastructure as Code (IaC).

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture Mind Map](#architecture-mind-map)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [SSH Key Setup](#ssh-key-setup)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## 🎯 Overview

This project demonstrates how to build a secure, scalable AWS VPC infrastructure using Terraform. It implements industry best practices for network segmentation, security, and high availability.

### What You'll Build:

- ✅ 1 Custom VPC with CIDR 10.0.0.0/16
- ✅ 2 Public Subnets across multiple Availability Zones
- ✅ 2 Private Subnets across multiple Availability Zones
- ✅ Internet Gateway for public internet access
- ✅ NAT Gateway for private subnet outbound connectivity
- ✅ Custom Route Tables for traffic management
- ✅ Security Groups for network-level security
- ✅ 4 EC2 Ubuntu instances (2 public, 2 private)

## 🧠 Architecture Mind Map

```
AWS VPC Infrastructure
│
├── VPC (10.0.0.0/16)
│   ├── Internet Gateway (IGW)
│   │   └── Provides internet access to public subnets
│   │
│   ├── Public Subnets (Multi-AZ)
│   │   ├── Subnet 1: 10.0.1.0/24 (AZ-a)
│   │   │   ├── Public EC2 Instance 1
│   │   │   └── Has Public IP
│   │   │
│   │   ├── Subnet 2: 10.0.2.0/24 (AZ-b)
│   │   │   ├── Public EC2 Instance 2
│   │   │   └── Has Public IP
│   │   │
│   │   ├── Public Route Table
│   │   │   └── Route: 0.0.0.0/0 → IGW
│   │   │
│   │   └── Security Group: Public-Instance-SG
│   │       ├── Inbound: SSH (22), HTTP (80), ICMP
│   │       └── Outbound: All traffic
│   │
│   ├── NAT Gateway
│   │   ├── Located in Public Subnet
│   │   ├── Has Elastic IP
│   │   └── Provides internet for private subnets
│   │
│   └── Private Subnets (Multi-AZ)
│       ├── Subnet 1: 10.0.3.0/24 (AZ-a)
│       │   ├── Private EC2 Instance 1
│       │   └── No Public IP
│       │
│       ├── Subnet 2: 10.0.4.0/24 (AZ-b)
│       │   ├── Private EC2 Instance 2
│       │   └── No Public IP
│       │
│       ├── Private Route Table
│       │   └── Route: 0.0.0.0/0 → NAT Gateway
│       │
│       └── Security Group: Private-Instance-SG
│           ├── Inbound: SSH (22), HTTP (80), ICMP from VPC only
│           └── Outbound: All traffic
│
└── Traffic Flow
    ├── Public Instance: User → IGW → Public Subnet → EC2
    └── Private Instance: EC2 → NAT Gateway → IGW → Internet
```

## 🛠️ Prerequisites

Before you begin, ensure you have:

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
   ```bash
   aws configure
   ```
3. **Terraform** installed (v1.0+)
   ```bash
   terraform --version
   ```
4. **SSH client** (OpenSSH for Windows/Linux/Mac)

## 🚀 Quick Start

### Step 1: Clone the Repository

```bash
git clone <your-repo-url>
cd Terraform_VPC_Code
```

### Step 2: Generate SSH Key Pair

**Windows (PowerShell):**
```powershell
ssh-keygen -t rsa -b 2048 -f C:\Users\<username>\.ssh\id_rsa
```

**Linux/Mac:**
```bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
```

This creates:
- `id_rsa` - Private key (keep secret)
- `id_rsa.pub` - Public key (uploaded to AWS)

### Step 3: Navigate to Environment

```bash
cd environments/dev
```

### Step 4: Initialize Terraform

```bash
terraform init
```

### Step 5: Review the Plan

```bash
terraform plan
```

### Step 6: Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted, or use `-auto-approve` flag.

### Step 7: Get Instance IPs

After deployment, note the public IPs from AWS Console:
- EC2 Dashboard → Instances

### Step 8: Connect to Public Instance

```bash
ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC_IP>
```

### Step 9: Clean Up (When Done)

```bash
terraform destroy
```

## 📖 Project Structure

```
terraform-aws-network/
├── environments/
│   ├── dev/
│   │   ├── provider.tf        # AWS provider configuration
│   │   ├── main.tf            # Main infrastructure code
│   │   ├── variables.tf       # Variable definitions
│   │   ├── terraform.tfvars   # Variable values
│   │   └── backend.tf         # State management
│   │
│   └── prod/
│       └── (same structure as dev)
│
└── modules/
    ├── vpc/                   # VPC creation module
    ├── subnets/               # Subnet creation module
    ├── nat/                   # NAT Gateway module
    └── route-tables/          # Route table module
```

## ⚙️ Configuration

Edit `environments/dev/terraform.tfvars`:

```hcl
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
  Project     = "VPC-Demo"
}
```

## 🔑 SSH Key Setup

### Terraform-Managed Keys (Recommended)

**Steps:**

```bash
# Generate key pair
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa

# Terraform automatically uploads public key (configured in main.tf)
# Connect using private key
ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC_IP>
```

**Note:** The Terraform code in main.tf automatically uploads your public key to AWS.

## 🧪 Testing

### Connect to Public Instance

```bash
ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC_IP>
ping -c 4 google.com
```

### Connect to Private Instance (via Bastion)

```bash
# Jump through public instance
ssh -i ~/.ssh/id_rsa -J ubuntu@<PUBLIC_IP> ubuntu@<PRIVATE_IP>
ping -c 4 google.com
```

## 🛠️ Troubleshooting

### SSH Permission Denied
```bash
chmod 600 ~/.ssh/id_rsa
# Windows: icacls id_rsa /inheritance:r && icacls id_rsa /grant:r "%username%:R"
```

### Connection Timeout
- Verify instance is running in AWS Console
- Check security group allows SSH (port 22)
- Confirm correct region in terraform.tfvars

### Terraform Apply Fails (InvalidKeyPair)
```bash
# Generate SSH key if missing
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
terraform apply
```

### Can't Access Private Instance
Private instances have no public IP. Use bastion:
```bash
ssh -i ~/.ssh/id_rsa -J ubuntu@<PUBLIC_IP> ubuntu@<PRIVATE_IP>
```

## 📚 Best Practices

### Security
- Never commit private keys (add `*.pem`, `*.key`, `.ssh/` to .gitignore)
- Restrict SSH access to your IP instead of 0.0.0.0/0
- Enable VPC Flow Logs for traffic monitoring
- Use IAM roles for EC2 instead of access keys

### High Availability
- Deploy across multiple AZs (already implemented)
- Use 2+ NAT Gateways in production
- Implement Auto Scaling Groups
- Add health checks and monitoring

### Infrastructure as Code
- Use remote state (S3 + DynamoDB locking)
- Tag all resources consistently
- Use Terraform workspaces for environments
- Keep modules reusable and DRY

### Cost Optimization
- Use 1 NAT Gateway in dev (already configured)
- Stop instances when not in use
- Consider Spot Instances for non-critical workloads
- Always run `terraform destroy` after testing

---

## ⚠️ Important Notes

- Never commit `*.pem`, `*.key`, `.ssh/` or `terraform.tfstate` files
- Always run `terraform destroy` after testing to avoid charges
- Set up AWS billing alerts
- Keep Terraform updated: `terraform init -upgrade`

---

**Happy Learning! 🚀**
