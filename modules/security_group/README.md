# Security Group Module

Creates two security groups: one for the Application Load Balancer (ALB) and one for ECS tasks.

## 🏗️ Resources Created

### `aws_security_group.alb`
Security group for the ALB with inbound rules for HTTP and HTTPS from the internet.

**Ingress Rules:**
- Port 80 (TCP) - Source: 0.0.0.0/0 (anywhere)
- Port 443 (TCP) - Source: 0.0.0.0/0 (anywhere)

**Egress Rules:**
- All ports, all protocols, all destinations

### `aws_security_group.ecs`
Security group for ECS tasks that only allows traffic from the ALB.

**Ingress Rules:**
- Port `app_port` (default 8080, TCP) - Source: ALB security group only

**Egress Rules:**
- All ports, all protocols, all destinations

## 📥 Input Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `vpc_id` | `string` | Yes | - | ID of the VPC where security groups will be created |
| `app_port` | `number` | Yes | - | Application container port on ECS tasks (1-65535) |
| `alb_sg_name` | `string` | No | `"alb-sg"` | Name tag for ALB security group |
| `ecs_sg_name` | `string` | No | `"ecs-sg"` | Name tag for ECS security group |
| `tags` | `map(string)` | No | `{}` | Global tags applied to both security groups (Name tags set by module) |

## 🔗 Outputs

| Name | Description |
|------|-------------|
| `alb_sg_id` | ID of the ALB security group |
| `ecs_sg_id` | ID of the ECS security group |

## 💡 Usage Example

```hcl
module "sg" {
  source = "./modules/security_group"

  vpc_id     = module.vpc.vpc_id
  app_port   = 8080
  alb_sg_name = "app-alb-sg"
  ecs_sg_name = "app-ecs-sg"
}
```

## 🛡️ Security Model

```
   Internet Traffic Flow:
   ┌─────────┐    ┌──────────────┐    ┌──────────┐    ┌─────────┐
   │ Internet│───▶│  ALB SG      │───▶│   ALB    │───▶│ECS SG   │
   │ (Any)   │    │  80/443      │    │          │    │  8080   │
   │         │    │  Any → ALB   │    │          │    │ALB→ECS  │
   └─────────┘    └──────────────┘    └──────────┘    └─────────┘
                                                           │
                                                           ▼
                                                    ┌─────────┐
                                                    │ECS Task │
                                                    └─────────┘
```

**Key Security Principle:** ECS tasks are completely isolated from the internet. Only the ALB can initiate connections to ECS tasks on the application port.

## ⚠️ Important Notes

- **ECS security group** uses a **security group reference** (not CIDR) for inbound rule, ensuring only traffic from the ALB is allowed
- ALB security group must allow both HTTP (80) and HTTPS (443) for the redirect and SSL to work
- Ensure `app_port` matches the container port defined in the ECS task definition
- Security groups are VPC-scoped; you must provide a valid `vpc_id`

## 🔄 Relationship with Other Modules

- **Depends on:** `modules/vpc` (requires `vpc_id`)
- **Used by:** `modules/alb` (provides `alb_sg_id`), `modules/ecs` (provides `ecs_sg_id`)

## 🚀 Applying This Module

### Apply standalone (after VPC)
```bash
terraform apply -target=module.vpc   # First, create VPC
terraform apply -target=module.sg    # Then, create security groups
```

### Apply with dependencies
```bash
# Apply VPC and SG together (recommended)
terraform apply -target=module.vpc -target=module.sg

# Apply all modules in correct order
terraform apply -target=module.vpc -target=module.sg -target=module.alb -target=module.ecs
```

**Note:** Security groups depend on VPC. Always apply VPC module before SG module.
