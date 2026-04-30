# AWS CodeBuild Module

Creates an AWS CodeBuild project for building Docker images and pushing to Amazon ECR. Designed to integrate with CodePipeline or trigger manually.

## 🏗️ Resources Created

- **`aws_iam_role.codebuild_role`** - IAM role for CodeBuild with scoped permissions
- **`aws_iam_role_policy.codebuild_policy`** - Least-privilege IAM policy allowing ECR, S3, CloudWatch, and CodeBuild actions
- **`aws_codebuild_project.codebuild`** - The build project with environment variables and source from CodePipeline

## 📥 Input Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `project_name` | `string` | Yes | - | Project name (used for naming resources) |
| `image_repo_name` | `string` | Yes | - | ECR repository name for Docker images |
| `image_tag` | `string` | No | `"latest"` | Docker image tag to build |
| `build_timeout` | `number` | No | `60` | Build timeout in minutes |
| `build_compute_type` | `string` | No | `"BUILD_GENERAL1_SMALL"` | CodeBuild compute type |
| `build_image` | `string` | No | `"aws/codebuild/standard:5.0"` | CodeBuild Docker image |
| `buildspec` | `string` | No | `"buildspec.yml"` | Path to buildspec file in repository |
| `environment_variables` | `list(object)` | No | `[]` | Additional env vars: `[{name="KEY",value="value"}]` |
| `tags` | `map(string)` | No | `{}` | Tags to apply to all resources |

## 🔗 Outputs

| Name | Description |
|------|-------------|
| `codebuild_project_id` | CodeBuild project ID |
| `codebuild_project_name` | CodeBuild project name |

## 💡 Usage Example

```hcl
module "codebuild" {
  source = "./modules/codebuild"

  project_name       = "myapp"
  image_repo_name    = "myapp-repo"
  image_tag          = "latest"
  build_timeout      = 30
  build_compute_type = "BUILD_GENERAL1_MEDIUM"
  build_image        = "aws/codebuild/standard:5.0"
  buildspec          = "buildspec.yml"

  environment_variables = [
    { name = "NODE_ENV", value = "production" }
  ]

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## 🐳 Build Process (Docker & ECR)

The buildspec performs these steps:

1. **Login to ECR** - Uses AWS credentials to authenticate Docker to ECR
2. **Build Docker image** - `docker build -t $REPOSITORY_URI:$IMAGE_TAG .`
3. **Push to ECR** - `docker push $REPOSITORY_URI:$IMAGE_TAG`
4. **Generate imagedefinitions.json** - Output file required by CodePipeline ECS deploy action

### buildspec.yml (default path: `buildspec.yml` in repo root)

The repository should include a `buildspec.yml` file. A recommended default is provided in the root of this Terraform project.

If you prefer a custom location, set the `buildspec` variable to the relative path (e.g., `"ci/buildspec.yml"`).

## 🔐 IAM Permissions (Least Privilege)

The module creates an IAM role with a policy scoped to:

- **CloudWatch Logs**: Write to `/codebuild/<project_name>*` log groups
- **ECR**: Full push/pull permissions (ECR uses token-based auth requiring `Resource: "*"`)
- **S3**: Read/write to the CodePipeline artifact bucket (specific ARN)
- **CodeBuild**: Start and describe builds for this project only

```json
{
  "Effect": "Allow",
  "Action": ["codebuild:BatchGetBuilds", "codebuild:StartBuild"],
  "Resource": "arn:aws:codebuild:region:account:project/project-name"
}
```

## 🌍 Region & Account Handling

Region and AWS Account ID are automatically detected using Terraform data sources:

- `data.aws_region.current.name`
- `data.aws_caller_identity.current.account_id`

No need to pass these as variables.

## 📊 Monitoring & Logs

Build logs go to CloudWatch Logs group: `/codebuild/<project_name>`

View logs in AWS Console → CodeBuild → Build details → View logs in CloudWatch.

## 🚨 Common Issues & Solutions

### Build fails: "Cannot pull image"
- Check CodeBuild service role permissions (ECR actions)
- Ensure ECR repository exists and image is accessible

### Authentication errors
- Verify CodeBuild execution role has `ecr:GetAuthorizationToken`
- Ensure AWS credentials are available in the build environment

### buildspec.yml not found
- Confirm the file exists at the repository root (or custom path set in `buildspec` variable)
- Check GitHub branch being built contains the file

### Permission denied on S3 bucket
- Ensure CodeBuild role has S3 read/write on the CodePipeline artifact bucket
- Bucket is created by CodePipeline module with proper ARN

## 🧹 Cleanup

```bash
terraform destroy -target=module.codebuild
```

The IAM role and CodeBuild project will be deleted. Associated S3 bucket and other resources remain if managed by other modules.

## 🔄 Dependencies

This module has **no dependencies** on other Terraform modules. It can be deployed standalone. Typically used together with `codepipeline` module.

**Dependent modules:**
- `modules/codepipeline` (references this project's name)

## 📝 Integration with CodePipeline

The output `codebuild_project_name` should be passed to `codepipeline` module:

```hcl
module "codepipeline" {
  codebuild_project_name = module.codebuild.codebuild_project_name
  # ... other variables
}
```

This ensures the pipeline's Build stage knows which CodeBuild project to trigger.

## ⚙️ Customization

### Increase Compute Resources
```hcl
build_compute_type = "BUILD_GENERAL1_LARGE"  # More CPU/RAM
```

### Custom Build Image
```hcl
build_image = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
```

### Add Environment Variables
```hcl
environment_variables = [
  { name = "DB_HOST", value = "db.example.com" },
  { name = "API_KEY", value = var.secret_api_key }
]
```

## 🔐 Sensitive Data

- `github_oauth_token` is marked `sensitive = true` and will not appear in logs
- Store token in environment variable: `export TF_VAR_github_oauth_token="your_pat"`

Never commit tokens to version control.