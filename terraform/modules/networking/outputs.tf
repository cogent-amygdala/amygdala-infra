output "workspaces_vpc_id" {
    	description = "ID of WorkSpaces VPC"
    	value       = aws_vpc.workspaces_vpc.id
}

output "ansanasfg_vpc_id" {
	description = "ID of ansanasfg VPC"
	value       = aws_vpc.ansanasfg_vpc.id
}

output "workspaces_subnet_ids" {
    	description = "WorkSpaces subnet IDs"
    	value = [
      		aws_subnet.workspaces_subnet_1a.id,
      		aws_subnet.workspaces_subnet_1c.id
	]
}

output "ansanasfg_subnet_ids" {
    	description = "ansanasfg subnet IDs"
    	value = [
      		aws_subnet.ansanasfg_subnet_1a.id,
      		aws_subnet.ansanasfg_subnet_1b.id,
      		aws_subnet.ansanasfg_subnet_1c.id
	]
}
