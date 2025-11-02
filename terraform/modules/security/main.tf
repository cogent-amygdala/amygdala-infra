# KMS Key for WorkSpaces
resource "aws_kms_key" "workspaces" {
    	description             = "KMS key for WorkSpaces encryption"
    	deletion_window_in_days = 30
    	enable_key_rotation     = true

    	tags = {
      		Name = "workspaces-encryption-key"
	}
}

resource "aws_kms_alias" "workspaces" {
    	name          = "alias/aws/workspaces"
	target_key_id = aws_kms_key.workspaces.key_id
}

# Security Group - WorkSpaces Members
resource "aws_security_group" "workspaces_members" {
    	name        = "d-9067b141e8_workspacesMembers"
    	description = "Amazon WorkSpaces Security Group"
    	vpc_id      = var.workspaces_vpc_id

    	egress {
      		from_port   = 0
      		to_port     = 0
      		protocol    = "-1"
      		cidr_blocks = ["0.0.0.0/0"]
    	}

    	tags = {
      		Name  = "d-9067b141e8_workspacesMembers"
      		Key   = "Created by Amazon WorkSpaces"
      		Value = "Amazon WorkSpaces"
	}
}

