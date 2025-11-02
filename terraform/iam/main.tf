# IAM Configuration for AWS Account
# This manages admin and developer users with proper access controls

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Admin Group - Full access with MFA enforcement
resource "aws_iam_group" "admins" {
  name = "Admins"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "admin_access" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Developer Group - Limited access for development work
resource "aws_iam_group" "developers" {
  name = "Developers"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "dev_poweruser" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# Developer policy to allow IAM read access (PowerUserAccess doesn't include IAM)
resource "aws_iam_group_policy" "dev_iam_read" {
  name  = "IAMReadOnlyAccess"
  group = aws_iam_group.developers.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

# MFA enforcement policy - requires MFA for all actions
resource "aws_iam_policy" "enforce_mfa" {
  name        = "EnforceMFA"
  description = "Deny all actions if MFA is not enabled"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowViewAccountInfo"
        Effect = "Allow"
        Action = [
          "iam:GetAccountPasswordPolicy",
          "iam:ListVirtualMFADevices"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowManageOwnPasswords"
        Effect = "Allow"
        Action = [
          "iam:ChangePassword",
          "iam:GetUser"
        ]
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "AllowManageOwnAccessKeys"
        Effect = "Allow"
        Action = [
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:ListAccessKeys",
          "iam:UpdateAccessKey"
        ]
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "AllowManageOwnMFA"
        Effect = "Allow"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice"
        ]
        Resource = [
          "arn:aws:iam::*:mfa/$${aws:username}",
          "arn:aws:iam::*:user/$${aws:username}"
        ]
      },
      {
        Sid    = "DenyAllExceptListedIfNoMFA"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken",
          "iam:ChangePassword"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

# Attach MFA policy to both groups
resource "aws_iam_group_policy_attachment" "admin_mfa" {
  group      = aws_iam_group.admins.name
  policy_arn = aws_iam_policy.enforce_mfa.arn
}

resource "aws_iam_group_policy_attachment" "dev_mfa" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.enforce_mfa.arn
}

# Admin Users
resource "aws_iam_user" "admin1" {
  name = var.admin_users[0]
  path = "/"
  force_destroy = false

  tags = {
    Role        = "Admin"
    Environment = "Production"
  }
}

resource "aws_iam_user" "admin2" {
  name = var.admin_users[1]
  path = "/"
  force_destroy = false

  tags = {
    Role        = "Admin"
    Environment = "Production"
  }
}

resource "aws_iam_user_group_membership" "admin1_membership" {
  user = aws_iam_user.admin1.name
  groups = [
    aws_iam_group.admins.name
  ]
}

resource "aws_iam_user_group_membership" "admin2_membership" {
  user = aws_iam_user.admin2.name
  groups = [
    aws_iam_group.admins.name
  ]
}

# Developer Users
resource "aws_iam_user" "dev1" {
  name = var.dev_users[0]
  path = "/"
  force_destroy = false

  tags = {
    Role        = "Developer"
    Environment = "Production"
  }
}

resource "aws_iam_user" "dev2" {
  name = var.dev_users[1]
  path = "/"
  force_destroy = false

  tags = {
    Role        = "Developer"
    Environment = "Production"
  }
}

resource "aws_iam_user_group_membership" "dev1_membership" {
  user = aws_iam_user.dev1.name
  groups = [
    aws_iam_group.developers.name
  ]
}

resource "aws_iam_user_group_membership" "dev2_membership" {
  user = aws_iam_user.dev2.name
  groups = [
    aws_iam_group.developers.name
  ]
}

# Account password policy
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age              = 90
  password_reuse_prevention     = 5
}
