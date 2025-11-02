# IAM Outputs
output "user_arns" {
    	description = "Map of IAM user ARNs"
    	value = {
      		amygdala_admin     = aws_iam_user.amygdala_admin.arn
      		amygdala_dev       = aws_iam_user.amygdala_dev.arn
      		amygdala_terraform = aws_iam_user.amygdala_terraform.arn
      		johnc              = aws_iam_user.johnc.arn
      		samh               = aws_iam_user.samh.arn
	}
}

output "workspaces_role_arn" {
    	description = "WorkSpaces default role ARN"
	value       = data.aws_iam_role.workspaces_default.arn
}
