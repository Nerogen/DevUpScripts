output "vpc_id" {
  value = "aws_vpc.id"
}

output "vpc_cidr" {
  value = "aws_vpc.main.cird_block"
}

output "public_sidr_ids" {
  value = "aws_subnet.public_subnet.id"
}

output "private_sidr_ids" {
  value = "aws_subnet.private_subnet.id"
}
