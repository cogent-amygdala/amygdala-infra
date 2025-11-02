# VPC for WorkSpaces (d-9067b141e8)
resource "aws_vpc" "workspaces_vpc" {
 	cidr_block           = "172.16.0.0/16"
	enable_dns_hostnames = true
	enable_dns_support   = true

    	tags = {
      		Name = "workspaces-vpc"
    	}
}

# VPC for ansanasfg (d-9067b17d47)
resource "aws_vpc" "ansanasfg_vpc" {
	cidr_block           = "172.16.0.0/16"
    	enable_dns_hostnames = true
    	enable_dns_support   = true

    	tags = {
      		Name               = "ansanasfg-vpc"
      		"aws:zocalo:alias" = "ansanasfg"
    	}
}

# Default VPC (keeping reference only, won't manage it)
data "aws_vpc" "default" {
  	default = true
}

# Internet Gateway for WorkSpaces VPC
resource "aws_internet_gateway" "workspaces_igw" {
	vpc_id = aws_vpc.workspaces_vpc.id

    	tags = {
      		Name               = "workspaces-igw"
      		AWSServiceAccount  = "697148468905"
    	}
}

# Internet Gateway for Default VPC (data source only)
data "aws_internet_gateway" "default" {
	filter {
      		name   = "attachment.vpc-id"
      		values = [data.aws_vpc.default.id]
    	}
}

# Subnets for WorkSpaces VPC
resource "aws_subnet" "workspaces_subnet_1a" {
	vpc_id            = aws_vpc.workspaces_vpc.id
    	cidr_block        = "172.16.1.0/24"
    	availability_zone = "us-east-1a"
        
    	tags = {
  		Name              = "workspaces-subnet-1a"
  		AWSServiceAccount = "697148468905"
	}
}

resource "aws_subnet" "workspaces_subnet_1c" {
	vpc_id            = aws_vpc.workspaces_vpc.id
    	cidr_block        = "172.16.0.0/24"
    	availability_zone = "us-east-1c"

    	tags = {
      		Name              = "workspaces-subnet-1c"
      		AWSServiceAccount = "697148468905"
	}
}

# Subnets for ansanasfg VPC
resource "aws_subnet" "ansanasfg_subnet_1a" {
	vpc_id            = aws_vpc.ansanasfg_vpc.id
  	cidr_block        = "172.16.0.0/24"
	availability_zone = "us-east-1a"

    	tags = {
      		Name               = "ansanasfg-subnet-1a"
      		"aws:zocalo:alias" = "ansanasfg"
    	}
}

resource "aws_subnet" "ansanasfg_subnet_1b" {
	vpc_id            = aws_vpc.ansanasfg_vpc.id
    	cidr_block        = "172.16.1.0/24"
    	availability_zone = "us-east-1b"

    	tags = {
      		Name               = "ansanasfg-subnet-1b"
      		"aws:zocalo:alias" = "ansanasfg"
    	}
}

resource "aws_subnet" "ansanasfg_subnet_1c" {
	vpc_id            = aws_vpc.ansanasfg_vpc.id
    	cidr_block        = "172.16.2.0/24"
    	availability_zone = "us-east-1c"

    	tags = {
      		Name               = "ansanasfg-subnet-1c"
      		"aws:zocalo:alias" = "ansanasfg"
    	}
}

# Route Tables for WorkSpaces VPC
	resource "aws_route_table" "workspaces_main" {
    	vpc_id = aws_vpc.workspaces_vpc.id

    	tags = {
      		Name = "workspaces-main-rt"
    	}
}

resource "aws_route_table" "workspaces_public" {
	vpc_id = aws_vpc.workspaces_vpc.id

    	route {
      		cidr_block = "0.0.0.0/0"
      		gateway_id = aws_internet_gateway.workspaces_igw.id
    	}

   	tags = {
      		Name              = "workspaces-public-rt"
      		AWSServiceAccount = "697148468905"
    	}
}

# Route Table Associations for WorkSpaces
resource "aws_route_table_association" "workspaces_1a" {
	subnet_id      = aws_subnet.workspaces_subnet_1a.id
    	route_table_id = aws_route_table.workspaces_public.id
}

resource "aws_route_table_association" "workspaces_1c" {
	subnet_id      = aws_subnet.workspaces_subnet_1c.id
    	route_table_id = aws_route_table.workspaces_public.id
}

# Route Table for ansanasfg VPC (main only, no internet gateway)
resource "aws_route_table" "ansanasfg_main" {
	vpc_id = aws_vpc.ansanasfg_vpc.id

    	tags = {
      		Name = "ansanasfg-main-rt"
    	}
}

# IAM Users
resource "aws_iam_user" "amygdala_admin" {
    	name = "amygdala-admin"
    	path = "/"

    	tags = {
      		Description = "Amygdala admin service account"
  	}
}

resource "aws_iam_user" "amygdala_dev" {
    	name = "amygdala-dev"
    	path = "/"

    	tags = {
      		Description = "Amygdala developer service account"
	}
}

resource "aws_iam_user" "amygdala_terraform" {
    	name = "amygdala-terraform"
    	path = "/"

    	tags = {
      		Description = "Amygdala Terraform automation account"
	}
}

resource "aws_iam_user" "johnc" {
    	name = "johnc"
    	path = "/"

    	tags = {
      		Description = "John Costello - Admin"
	}
}

resource "aws_iam_user" "samh" {
	name = "samh"
    	path = "/"

    	tags = {
      		Description = "Samantha Hoffman - Admin"
	}
}

# Policy Attachments
resource "aws_iam_user_policy_attachment" "amygdala_admin_policy" {
    	user       = aws_iam_user.amygdala_admin.name
    	policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user_policy_attachment" "amygdala_dev_policy" {
    	user       = aws_iam_user.amygdala_dev.name
	policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_user_policy_attachment" "amygdala_terraform_policy" {
    	user       = aws_iam_user.amygdala_terraform.name
	policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_user_policy_attachment" "johnc_policy" {
    	user       = aws_iam_user.johnc.name
	policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user_policy_attachment" "samh_policy" {
    	user       = aws_iam_user.samh.name
	policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# WorkSpaces Default Role (existing, reference only)
data "aws_iam_role" "workspaces_default" {
	name = "workspaces_DefaultRole"
}
