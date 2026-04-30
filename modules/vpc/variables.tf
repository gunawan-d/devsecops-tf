variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g., \"10.0.0.0/16\")"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR block (e.g., \"10.0.0.0/16\")."
  }
}

variable "public_subnet" {
  description = "CIDR block for the first public subnet in AZ-a (e.g., \"10.0.0.0/22\")"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.public_subnet))
    error_message = "public_subnet must be a valid CIDR block."
  }
}

variable "public_subnet_b" {
  description = "CIDR block for the second public subnet in AZ-b (e.g., \"10.0.4.0/22\")"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.public_subnet_b))
    error_message = "public_subnet_b must be a valid CIDR block."
  }
}

variable "private_subnet" {
  description = "CIDR block for the first private subnet in AZ-a (e.g., \"10.0.8.0/22\")"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.private_subnet))
    error_message = "private_subnet must be a valid CIDR block."
  }
}

variable "private_subnet_b" {
  description = "CIDR block for the second private subnet in AZ-b (e.g., \"10.0.12.0/22\")"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.private_subnet_b))
    error_message = "private_subnet_b must be a valid CIDR block."
  }
}

variable "az" {
  description = "First Availability Zone (e.g., \"us-east-1a\")"
  type        = string
}

variable "az_2" {
  description = "Second Availability Zone (e.g., \"us-east-1b\")"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}
