# VPC Module

Creates a complete Virtual Private Cloud (VPC) infrastructure with public and private subnets across two Availability Zones.

##  Resources Created

- **AWS VPC** - Main VPC with configurable CIDR
- **Public Subnets** (2) - For load balancers and public resources
- **Private Subnets** (2) - For ECS tasks and private resources
- **Internet Gateway (IGW)** - Provides internet access to public subnets
- **NAT Gateway** - Provides outbound internet for private subnets (single-AZ, cost-optimized)
- **Route Tables** - Public (IGW route) and Private (NAT route)
- **Route Table Associations** - Associates all subnets with their respective route tables

##  Input Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `vpc_cidr` | `string` | Yes | - | CIDR block for the VPC (e.g., "10.0.0.0/16") |
| `public_subnet` | `string` | Yes | - | CIDR block for first public subnet (AZ-a) |
| `public_subnet_b` | `string` | Yes | - | CIDR block for second public subnet (AZ-b) |
| `private_subnet` | `string` | Yes | - | CIDR block for first private subnet (AZ-a) |
| `private_subnet_b` | `string` | Yes | - | CIDR block for second private subnet (AZ-b) |
| `az` | `string` | Yes | - | First Availability Zone (e.g., "ap-southeast-3a") |
| `az_2` | `string` | Yes | - | Second Availability Zone (e.g., "ap-southeast-3b") |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the created VPC |
| `public_subnet_ids` | List of public subnet IDs (2 subnets) |
| `private_subnet_ids` | List of private subnet IDs (2 subnets) |

##  Network Architecture

```
                            ┌─────────────────────┐
                            │     Internet        │
                            └──────────┬──────────┘
                                       │
                            ┌──────────▼──────────┐
                            │ Internet Gateway    │
                            └──────────┬──────────┘
                                       │
                    ┌──────────────────┴──────────────────┐
                    │       Public Subnets                │
                    │  ┌─────────────────────────────┐    │
                    │  │  Public Subnet A            │    │
                    │  │  10.0.0.0/22                │    │
                    │  │  └─► ALB (AZ-a)             │    │
                    │  └─────────────────────────────┘    │
                    │  ┌─────────────────────────────┐    │
                    │  │  Public Subnet B            │    │
                    │  │  10.0.4.0/22                │    │
                    │  │  └─► ALB (AZ-b)             │    │
                    │  └─────────────────────────────┘    │
                    └──────────────────┬─────────────────-┘
                                       │
                    ┌──────────────────▼──────────────────┐
                    │     NAT Gateway (single-AZ)         │
                    └──────────────────┬──────────────────┘
                                       │
                    ┌──────────────────▼──────────────────┐
                    │       Private Subnets               │
                    │  ┌─────────────────────────────┐    │
                    │  │  Private Subnet A           │    │
                    │  │  10.0.8.0/22                │    │
                    │  │  └─► ECS Tasks (AZ-a)       │←── ┘
                    │  └─────────────────────────────┘
                    │  ┌─────────────────────────────┐
                    │  │  Private Subnet B           │   |
                    │  │  10.0.12.0/22               │   |
                    │  │  └─► ECS Tasks (AZ-b)       │   |
                    │  └─────────────────────────────┘   |
                    └────────────────────────────────────┘
```

##  Usage Example

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr         = "10.0.0.0/16"
  public_subnet    = "10.0.0.0/22"
  public_subnet_b  = "10.0.4.0/22"
  private_subnet   = "10.0.8.0/22"
  private_subnet_b = "10.0.12.0/22"
  az               = "ap-southeast-3a"
  az_2             = "ap-southeast-3b"
}
```

##  Design Decisions

- **Single NAT Gateway**: Deployed in public subnet-a for cost optimization. Suitable for dev/staging. For production, consider NAT Gateway per AZ for high availability.
- **Public Subnets**: Used for internet-facing resources (ALB, bastion hosts)
- **Private Subnets**: Used for internal resources (ECS tasks, databases)
- **CIDR Allocation**: VPC /16 → Subnets /22 (each provides 1024 IP addresses, 5 reserved by AWS)
- **Multi-AZ**: Subnets distributed across two AZs for redundancy

##  Security Considerations

- Private subnets have no direct internet ingress (only outbound via NAT)
- ALB in public subnets with security group restrictions
- Resources in private subnets use internal IPs only

##  Notes

- Ensure CIDR blocks do not overlap with existing networks
- Public subnets must have `map_public_ip_on_launch = true` for ALB
- Private subnets have `map_public_ip_on_launch = false`
- NAT Gateway incurs hourly cost; consider using NAT instances for cost savings in non-production
