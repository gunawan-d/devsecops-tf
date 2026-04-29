# DevSecOps Terraform

Terraform infrastructure for deploying applications on AWS: **VPC → ALB (HTTPS) → ECS Fargate**.

## 🚀 Quick Start

```bash
terraform init
terraform apply
```

Access: `https://devsecops.igunawan.com`

##  Modules

| Module | Purpose |
|--------|---------|
| `modules/vpc` | VPC with 2 public + 2 private subnets (multi-AZ) |
| `modules/security_group` | Firewall rules for ALB (80/443) and ECS (8080) |
| `modules/alb` | Application Load Balancer with HTTPS + HTTP→HTTPS redirect |
| `modules/ecs` | ECS Fargate cluster, service, task definition, IAM roles |

## ⚙️ Configuration

Edit `terraform.tfvars`:

```hcl
# VPC Network
vpc_cidr         = "10.0.0.0/16"
public_subnet    = "10.0.0.0/22"
public_subnet_b  = "10.0.4.0/22"
private_subnet   = "10.0.8.0/22"
private_subnet_b = "10.0.12.0/22"
az               = "ap-southeast-3a"
az_2             = "ap-southeast-3b"

# Application
ecs_container_image = "[ACCOUNT_ID].dkr.ecr.ap-southeast-3.amazonaws.com/apps-tf:development"

# SSL (optional - leave null for HTTP only)
ssl_certificate_arn = "arn:aws:acm:ap-southeast-3:[ACCOUNT_ID]:certificate/[...]"
```

> **Note:** Replace `[ACCOUNT_ID]` with your AWS account ID. Keep `terraform.tfvars` out of version control if it contains sensitive values.

##  SSL Setup

1. Request ACM certificate for `devsecops.igunawan.com` (DNS validation)
2. Add CNAME validation record in Cloudflare (**DNS Only**, grey cloud)
3. After certificate status = **Issued**, run `terraform apply`
4. HTTP automatically redirects to HTTPS

##  Project Structure

```
devsecops-tf/
├── main.tf               # Root module (calls all sub-modules)
├── variables.tf          # Variable definitions
├── outputs.tf            # Output values
├── terraform.tfvars      # Variable assignments (do not commit if sensitive)
├── .gitignore            # Ignore state/plan files
├── modules/
│   ├── vpc/             # Networking (VPC, subnets, IGW, NAT)
│   ├── security_group/  # ALB & ECS security groups
│   ├── alb/             # Load balancer + listeners
│   └── ecs/             # Fargate cluster + service
└── README.md            # This file
```

##  Troubleshooting

**ALB health checks failing?**  
Check target group health: `aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)`

**ACM certificate stuck in pending?**  
Ensure CNAME record in Cloudflare is **DNS Only** (not Proxied). Wait 5-30 minutes for validation.

**ECS tasks not running?**  
Check CloudWatch logs: `/ecs/development/app-task`  
Verify ECR image exists and IAM roles have permissions.

**HTTPS not working?**  
Confirm ALB security group allows port 443 (included in module).

##  Cleanup

```bash
terraform destroy
```

This will delete all AWS resources (VPC, ALB, ECS, etc.).
