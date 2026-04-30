# Data source to get current AWS account and region information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "codebuild_role" {
  name = format("%s-codebuild-role", var.project_name)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(var.tags, { Name = format("%s-codebuild-role", var.project_name) })
}

# IAM policy with least privilege - scoped to specific resources
resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # CloudWatch Logs permissions - scoped to this project's log group
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/codebuild/${var.project_name}*"
      },
      # ECR permissions - scoped to specific repository
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
        # ECR token-based actions require "*" resource
      },
      # S3 permissions - scoped to CodePipeline bucket (will be created by CodePipeline module)
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-codepipeline-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::${var.project_name}-codepipeline-${data.aws_caller_identity.current.account_id}/*"
        ]
      },
      # CodeBuild BatchGetBuilds and StartBuild - scoped to this project
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/${var.project_name}-codebuild"
      }
    ]
  })
}

resource "aws_codebuild_project" "codebuild" {
  name          = format("%s-codebuild", var.project_name)
  description   = "CodeBuild project for ${var.project_name}"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.build_compute_type
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.image_repo_name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = var.image_tag
    }

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = "PLAINTEXT"
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
  }

  logs_config {
    cloudwatch_logs {
      group_name  = format("/codebuild/%s", var.project_name)
      stream_name = "build-log-stream"
    }
  }

  tags = merge(var.tags, { Name = format("%s-codebuild", var.project_name) })
}