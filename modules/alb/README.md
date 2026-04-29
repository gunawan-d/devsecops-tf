# Application Load Balancer (ALB) Module

Creates an AWS Application Load Balancer with HTTP/HTTPS listeners, target group, health checks, and optional SSL/TLS certificate integration.

## 🏗️ Resources Created

- **`aws_lb.alb`** - Internet-facing Application Load Balancer
- **`aws_lb_target_group.tg`** - Target group with IP-based target registration and health checks
- **`aws_lb_listener.http`** - HTTP listener on port 80 (always created)
- **`aws_lb_listener.https`** - HTTPS listener on port 443 (created only if `ssl_certificate_arn` is provided)
- **`aws_lb_listener_rule.http_to_https`** - Redirect rule from HTTP to HTTPS (301 status code, created only if SSL enabled)

## 📥 Input Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `vpc_id` | `string` | Yes | - | VPC ID where ALB will be deployed |
| `public_subnet_ids` | `list(string)` | Yes | - | List of public subnet IDs for ALB (minimum 2 for high availability) |
| `security_group_id` | `string` | Yes | - | ALB security group ID (from security_group module) |
| `alb_name` | `string` | No | `"app-alb"` | Name tag for the ALB |
| `target_group_name` | `string` | No | `"app-tg"` | Name for the target group |
| `target_group_port` | `number` | No | `8080` | Port number for target group routing (should match container port) |
| `target_group_protocol` | `string` | No | `"HTTP"` | Protocol for target group (HTTP or HTTPS) |
| `health_check_path` | `string` | No | `"/health"` | Endpoint path for health checks |
| `health_check_matcher` | `string` | No | `"200-399"` | HTTP status codes considered healthy |
| `ssl_certificate_arn` | `string` | No | `null` | ACM certificate ARN (enables HTTPS listener if provided) |

## 🔗 Outputs

| Name | Description |
|------|-------------|
| `alb_arn` | ARN of the Application Load Balancer |
| `alb_dns_name` | DNS name of the ALB (use for Cloudflare CNAME) |
| `target_group_arn` | ARN of the target group (use for ECS service) |
| `target_group_name` | Name of the target group |

## 💡 Usage Example

### HTTP Only (no SSL):
```hcl
module "alb" {
  source = "./modules/alb"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  security_group_id     = module.sg.alb_sg_id
  alb_name              = "app-alb"
  target_group_name     = "app-tg"
  target_group_port     = 8080
  target_group_protocol = "HTTP"
  health_check_path     = "/health"
  health_check_matcher  = "200-399"
  # ssl_certificate_arn not set → HTTP only
}
```

### With HTTPS (using terraform.tfvars):
```hcl
# terraform.tfvars
ssl_certificate_arn = "arn:aws:acm:ap-southeast-1:[ACCOUNT_ID]:certificate/..."

# main.tf
module "alb" {
  source = "./modules/alb"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  security_group_id     = module.sg.alb_sg_id
  alb_name              = "app-alb"
  target_group_name     = "app-tg"
  target_group_port     = 8080
  target_group_protocol = "HTTP"
  health_check_path     = "/health"
  health_check_matcher  = "200-399"
  ssl_certificate_arn   = var.ssl_certificate_arn
}
```

### With HTTPS (using environment variable):
```bash
export TF_VAR_ssl_certificate_arn="arn:aws:acm:ap-southeast-1:[ACCOUNT_ID]:certificate/..."
terraform apply -target=module.alb
```

## 🔐 SSL/TLS Configuration

### Prerequisites
1. ACM certificate requested/imported in **same region** as ALB (ap-southeast-1)
2. Certificate domain must match your custom domain (e.g., `devsecops.igunawan.com`)
3. Certificate status must be **ISSUED** (not pending validation)

### DNS Validation (if requesting new certificate)
When requesting a new ACM certificate with DNS validation:

1. ACM provides a CNAME record for validation
2. Add this CNAME to Cloudflare DNS with **DNS Only** (grey cloud), **not Proxied**
3. Wait 5-30 minutes for ACM to validate
4. Certificate status changes to **ISSUED**

### Cloudflare Configuration
```
# Main domain (CNAME, Proxied OK)
devsecops.igunawan.com  →  app-alb-xxxx.elb.amazonaws.com

# ACM validation (CNAME, MUST be DNS Only)
_xxxxxxxx.devsecops.igunawan.com  →  _yyyyyyyy.acm-validations.aws.
```

### Enabling HTTPS

**Option 1: Via terraform.tfvars**
```hcl
ssl_certificate_arn = "arn:aws:acm:ap-southeast-1:account:certificate/..."
```
Then: `terraform apply -target=module.alb`

**Option 2: Via environment variable**
```bash
export TF_VAR_ssl_certificate_arn="arn:aws:acm:ap-southeast-1:account:certificate/..."
terraform apply -target=module.alb
```

**Option 3: Update existing ALB (add HTTPS to existing HTTP-only ALB)**
```bash
export TF_VAR_ssl_certificate_arn="..."
terraform apply -target=module.alb
```
This adds HTTPS listener without recreating ALB.

## 🩺 Health Check Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| Path | `/health` | Endpoint health check URL |
| Port | `target_group_port` | Port to check (same as target group port) |
| Protocol | `target_group_protocol` | HTTP or HTTPS |
| Matcher | `200-399` | HTTP status codes considered healthy |
| Interval | 30 seconds | Time between health checks |
| Timeout | 5 seconds | Wait time for response |
| Healthy threshold | 5 | Consecutive successes to mark healthy |
| Unhealthy threshold | 2 | Consecutive failures to mark unhealthy |

### Health Check Best Practices
- Create a `/health` endpoint that returns 200 OK quickly
- Avoid heavy database queries or external API calls
- Return 200 only when app is ready to serve traffic

## 📊 Monitoring & Logging

Access logs are NOT enabled by default. To enable ALB access logs:

```hcl
resource "aws_lb" "alb" {
  # ... existing config
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket_name
    prefix  = "alb-logs"
    enabled = true
  }
}
```

## 🔄 Traffic Flow

```
User Request Flow:
┌─────────────┐
│  User       │
│  Browser    │
└──────┬──────┘
       │ HTTPS Request
       ▼
┌─────────────────────┐
│  Cloudflare         │ (DNS + CDN)
│  devsecops....com   │
└──────────┬──────────┘
           │
           ▼
    ┌──────────────┐
    │   ALB        │ (HTTPS Listener:443)
    │  ┌─────────┐ │
    │  │ SSL     │ │ ← Termination
    │  │ Offload │ │
    │  └─────────┘ │
    └──────┬───────┘
           │ HTTP (port 8080)
           ▼
    ┌──────────────┐
    │ Target Group │
    │  (Health:    │
    │   /health)   │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │  ECS Task    │ (Private Subnet)
    │  app:8080    │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │ Application  │
    │  Response    │
    └──────────────┘
```

HTTP requests (port 80) are automatically redirected to HTTPS (301) before reaching target group.

## ⚠️ Important Notes

- **Target Type**: `ip` (required for Fargate awsvpc networking mode)
- **Cross-Zone Load Balancing**: Enabled by default for ALB (no extra cost)
- **Internal vs Internet-facing**: `internal = false` (internet-facing)
- **Listener Priority**: HTTP→HTTPS redirect rule uses priority 1
- **SSL Policy**: `ELBSecurityPolicy-2016-08` (TLS 1.2)
- If `ssl_certificate_arn = null`, only HTTP listener is created (no HTTPS)
- **Module Dependencies:** Must be applied after `module.vpc` and `module.sg`

## 🛠️ Troubleshooting

### ALB returns 502 Bad Gateway
- Check target group health: unhealthy targets will cause 502
- Verify ECS tasks are running and security groups allow traffic from ALB SG

### HTTPS not working after apply
- Certificate ARN must be in same region as ALB
- Certificate must be in `ISSUED` status
- ALB security group must allow port 443

### Health checks failing
- Health check path must return 2xx/3xx status
- ECS tasks must be listening on `target_group_port`
- Security groups must allow health check traffic (from ALB IP ranges)

### Cannot apply ALB module alone
- Ensure VPC and Security Group modules are applied first:
  ```bash
  terraform apply -target=module.vpc -target=module.sg -target=module.alb
  ```
