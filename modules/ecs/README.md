# ECS Fargate Module

Creates an Amazon ECS cluster with Fargate launch type, task definition, service, IAM roles, and CloudWatch logging integration.

## 🏗️ Resources Created

### Compute Resources
- **`aws_ecs_cluster.main`** - ECS cluster with Container Insights enabled
- **`aws_ecs_task_definition.app`** - Fargate task definition with awsvpc networking
- **`aws_ecs_service.app`** - ECS service with desired count and load balancer integration

### IAM Resources
- **`aws_iam_role.ecs_execution_role`** - Allows ECS to pull images from ECR and write logs to CloudWatch
- **`aws_iam_role.ecs_task_role`** - Application-level AWS permissions (empty by default, add policies as needed)
- **`aws_iam_role_policy_attachment.ecs_execution_role_policy`** - Attaches `AmazonECSTaskExecutionRolePolicy` to execution role

### Logging Resources
- **`aws_cloudwatch_log_group.ecs`** - CloudWatch Logs group with 30-day retention

## 📥 Input Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `ecs_cluster_name` | `string` | Yes | - | Name of the ECS cluster |
| `ecs_task_family` | `string` | Yes | - | Family name for task definition (used in log group path) |
| `ecs_service_name` | `string` | Yes | - | Name of the ECS service |
| `ecs_container_name` | `string` | Yes | - | Container name within the task |
| `ecs_container_image` | `string` | Yes | - | ECR image URI (e.g., `[ACCOUNT_ID].dkr.ecr.ap-southeast-1.amazonaws.com/repo:tag`) |
| `ecs_container_port` | `number` | Yes | - | Container port that application listens on |
| `ecs_task_cpu` | `string` | Yes | - | CPU units for task (valid: "256", "512", "1024", "2048") |
| `ecs_task_memory` | `string` | Yes | - | Memory in MiB (valid: "512", "1024", "2048", "4096", etc.) |
| `ecs_desired_count` | `number` | No | `2` | Number of tasks to run simultaneously |
| `ecs_environment_variables` | `list(object)` | No | `[]` | List of environment variables: `[{name="KEY", value="value"}]` |
| `aws_region` | `string` | Yes | - | AWS region for CloudWatch logs |
| `private_subnet_ids` | `list(string)` | Yes | - | Private subnet IDs for task ENIs (from VPC module) |
| `ecs_security_group_id` | `string` | Yes | - | ECS security group ID (from security_group module) |
| `target_group_arn` | `string` | Yes | - | ALB target group ARN (from ALB module) |

## 🔗 Outputs

| Name | Description |
|------|-------------|
| `ecs_cluster_id` | ARN of the ECS cluster |
| `ecs_cluster_name` | Name of the ECS cluster |
| `ecs_service_id` | ARN of the ECS service |
| `ecs_service_name` | Name of the ECS service |
| `ecs_task_definition_arn` | ARN of the task definition |

## 📋 Task Definition JSON

The module generates the following container definition:

```json
{
  "family": "app-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::[ACCOUNT_ID]:role/app-gunawan-cluster-execution-role",
  "taskRoleArn": "arn:aws:iam::[ACCOUNT_ID]:role/app-gunawan-cluster-task-role",
  "containerDefinitions": [
    {
      "name": "app-tf",
      "image": "[ACCOUNT_ID].dkr.ecr.ap-southeast-1.amazonaws.com/apps-tf:development",
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {"name": "ENV", "value": "production"}
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/development/app-task",
          "awslogs-region": "ap-southeast-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "essential": true
    }
  ]
}
```

## 💡 Usage Example

```hcl
module "ecs" {
  source = "./modules/ecs"

  ecs_cluster_name      = "app-gunawan-cluster"
  ecs_task_family       = "app-task"
  ecs_service_name      = "app-service"
  ecs_container_name    = "app-tf"
  ecs_container_image   = "[ACCOUNT_ID].dkr.ecr.ap-southeast-1.amazonaws.com/apps-tf:development"
  ecs_container_port    = 8080
  ecs_task_cpu          = "256"
  ecs_task_memory       = "512"
  ecs_desired_count     = 2
  aws_region            = "ap-southeast-1"
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.sg.ecs_sg_id
  target_group_arn      = module.alb.target_group_arn

  ecs_environment_variables = [
    { name = "ENV", value = "production" },
    { name = "LOG_LEVEL", value = "info" }
  ]
}
```

## 🔐 IAM Roles & Permissions

### Execution Role (`ecs_execution_role`)
**Attached Policy:** `AmazonECSTaskExecutionRolePolicy` (AWS managed)

**Permissions:**
- `ecr:GetAuthorizationToken` - Pull images from ECR
- `ecr:BatchCheckLayerAvailability`, `ecr:GetDownloadUrlForLayer`, `ecr:BatchGetImage` - Download images
- `logs:CreateLogStream`, `logs:PutLogEvents` - Write to CloudWatch Logs
- `logs:CreateLogGroup` (if log group doesn't exist)

### Task Role (`ecs_task_role`)
**Default:** No policies attached

**Usage:** Add custom policies if your application needs AWS API access (e.g., S3, DynamoDB, SQS):

```hcl
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = module.ecs.ecs_task_role_name  # Note: output currently not defined
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
```

## 📊 Monitoring & Logs

### CloudWatch Logs
- **Log Group**: `/ecs/development/<ecs_task_family>`
- **Retention**: 30 days (configurable in `main.tf`)
- **Stream Prefix**: `ecs`
- **Full Log Name Example**: `/ecs/development/app-task/ecs/container-id`

### Viewing Logs
**Console:** CloudWatch → Logs → Log groups → `/ecs/development/app-task`

**CLI:**
```bash
aws logs get-log-events \
  --log-group-name "/ecs/development/app-task" \
  --log-stream-name "ecs/container-id" \
  --region ap-southeast-1
```

### ECS Console
View tasks, services, cluster state:
- **Cluster**: `app-gunawan-cluster`
- **Service**: `app-service`
- **Task Definition**: `app-task`

## 🩺 Health Checks

Health checks are performed by the ALB target group:

```
Health Check Flow:
┌──────────┐
│   ALB    │
│           │ 1. GET http://<task-ip>:8080/health
└─────┬────┘
      │
      ▼
┌──────────────┐
│ECS Task ENI  │ 2. App responds 200-399 (< 5s)
│10.0.x.x:8080 │
└──────┬───────┘
       │
       ▼
   ┌───────┐
   │200 OK │
   └───────┘
```

1. ALB requests `GET http://task-private-ip:8080/health`
2. Response code `200-399` → healthy
3. After **5 consecutive successes** → task marked healthy and receives traffic
4. After **2 consecutive failures** → task marked unhealthy and deregistered

**Task must:** Respond quickly (<5s timeout) to health checks or it will be marked unhealthy.

## 🔄 Service Lifecycle

- **Desired Count**: 2 tasks (configurable via `ecs_desired_count`)
- **Launch Type**: FARGATE (serverless, no EC2 management)
- **Network Mode**: `awsvpc` - each task gets its own ENI in private subnet
- **Deployment**: Rolling update (default), can configure deployment circuit breaker
- **Auto-Scaling**: Not configured by default (can be added separately)

## 🚨 Common Issues & Solutions

### Tasks stuck in `PROVISIONING` or `PENDING`
- **Check**: IAM execution role permissions
- **Fix**: Ensure `AmazonECSTaskExecutionRolePolicy` attached

### Tasks start but immediately stop
- **Check**: CloudWatch logs for application errors
- **Check**: Container image exists in ECR and is pullable
- **Check**: `ecs_container_port` matches application listening port

### ALB health checks failing → 502 errors
- **Check**: Security groups (ALB SG → ECS SG on `app_port`)
- **Check**: Health check endpoint returns 200-399
- **Check**: ECS tasks are in `RUNNING` state and healthy in target group

### Cannot pull image from ECR
- **Check**: Execution role has `ecr:GetAuthorizationToken`
- **Check**: ECR repository policy allows execution role
- **Check**: Image URI is correct (region, account, repo, tag)

## ⚙️ Fargate Platform Version

Uses **LATEST** platform version by default (recommended). Capabilities:
- `awsvpc` networking (each task gets ENI)
- PCI DSS, HIPAA, SOC, ISO compliance
- Graviton2/AMD64/ARM64 support (depends on image architecture)

## 📈 Scaling Considerations

To add auto-scaling:

```hcl
resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${module.ecs.ecs_cluster_name}/${module.ecs.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs" {
  name               = "cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
```

## 🧹 Cleanup

```bash
# Destroy ECS module only (recommended order: ECS first)
terraform destroy -target=module.ecs

# Destroy all modules
terraform destroy
```

**Order of deletion:**
1. ECS service (set desired_count = 0 first to avoid force delete)
2. Task definition (deregister)
3. IAM roles (detach policies first)
4. CloudWatch log group (optional)
5. VPC, ALB, security groups (via other modules)

## 🔗 Dependencies

This module depends on:
- `modules/vpc` - provides `private_subnet_ids`
- `modules/security_group` - provides `ecs_security_group_id`
- `modules/alb` - provides `target_group_arn`

**Order in root `main.tf`:**
```hcl
module "vpc"       # First
module "sg"        # Second (needs vpc_id)
module "alb"       # Third (needs vpc_id, sg)
module "ecs"       # Last (needs all above)
```

**Apply command with dependencies:**
```bash
# Apply dependencies first
terraform apply -target=module.vpc
terraform apply -target=module.sg
terraform apply -target=module.alb

# Then apply ECS
terraform apply -target=module.ecs
```
