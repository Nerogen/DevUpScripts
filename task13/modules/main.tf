# Creating a VPC!
resource "aws_vpc" "main" {

  # IP Range for the VPC
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  tags                 = {
    Name = "My main vpc"
  }
}

# Creating Public subnet!
resource "aws_subnet" "public_subnet" {
  depends_on = [
    aws_vpc.main
  ]

  # VPC in which subnet has to be created!
  vpc_id = aws_vpc.main.id

  # IP Range of this subnet
  cidr_block = var.public_subnet_cidr

  # Data Center of this subnet.
  availability_zone = var.aval_zone[0]

  # Enabling automatic public IP assignment on instance launch!
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

# Creating Public subnet!
resource "aws_subnet" "private_subnet" {
  depends_on = [
    aws_vpc.main,
    aws_subnet.public_subnet
  ]

  # VPC in which subnet has to be created!
  vpc_id = aws_vpc.main.id

  # IP Range of this subnet
  cidr_block = var.private_subnet_cidr

  # Data Center of this subnet.
  availability_zone = var.aval_zone[1]

  tags = {
    Name = "Private Subnet"
  }
}

# Creating an Internet Gateway for the VPC
resource "aws_internet_gateway" "Internet_Gateway" {
  depends_on = [
    aws_vpc.main,
    aws_subnet.public_subnet,
    aws_subnet.private_subnet
  ]

  # VPC in which it has to be created!
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IG-Public-&-Private-VPC"
  }
}

# Creating an Route Table for the public subnet!
resource "aws_route_table" "Public-Subnet-RT" {
  depends_on = [
    aws_vpc.main,
    aws_internet_gateway.Internet_Gateway
  ]

  # VPC ID
  vpc_id = aws_vpc.main.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gateway.id
  }

  tags = {
    Name = "Route Table for Internet Gateway"
  }
}

# Creating a resource for the Route Table Association!
resource "aws_route_table_association" "RT-IG-Association" {

  depends_on = [
    aws_vpc.main,
    aws_subnet.public_subnet,
    aws_subnet.private_subnet,
    aws_route_table.Public-Subnet-RT
  ]

  # Public Subnet ID
  subnet_id = aws_subnet.public_subnet.id

  #  Route Table ID
  route_table_id = aws_route_table.Public-Subnet-RT.id
}

# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "Nat-Gateway-EIP" {
  depends_on = [
    aws_route_table_association.RT-IG-Association
  ]
  vpc = true
}

# Creating a NAT Gateway!
resource "aws_nat_gateway" "NAT_GATEWAY" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP
  ]

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.Nat-Gateway-EIP.id

  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.public_subnet.id
  tags      = {
    Name = "Nat-Gateway_Project"
  }
}

# Creating a Route Table for the Nat Gateway!
resource "aws_route_table" "NAT-Gateway-RT" {
  depends_on = [
    aws_nat_gateway.NAT_GATEWAY
  ]

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_GATEWAY.id
  }

  tags = {
    Name = "Route Table for NAT Gateway"
  }

}

# Creating an Route Table Association of the NAT Gateway route
# table with the Private Subnet!
resource "aws_route_table_association" "Nat-Gateway-RT-Association" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]

  #  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  subnet_id = aws_subnet.private_subnet.id

  # Route Table ID
  route_table_id = aws_route_table.NAT-Gateway-RT.id
}

# Creating a Security Group for private host
resource "aws_security_group" "private_host_security_group" {

  depends_on = [
    aws_vpc.main,
    aws_subnet.public_subnet,
    aws_subnet.private_subnet
  ]

  description = "HTTP, PING, SSH"

  # Name of the security Group!
  name = "webserver-sg"

  # VPC ID in which Security group has to be created!
  vpc_id = aws_vpc.main.id

  # Created an inbound rule for SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22

    # Here adding tcp instead of ssh, because ssh in part of tcp only!
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outward Network Traffic for the WordPress
  egress {
    description = "output from webserver"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Creating security group for Bastion Host/Jump Box
resource "aws_security_group" "public_host_security_group" {

  depends_on = [
    aws_vpc.main,
    aws_subnet.public_subnet,
    aws_subnet.private_subnet
  ]

  description = "MySQL Access only from the Webserver Instances!"
  name        = "bastion-host-sg"
  vpc_id      = aws_vpc.main.id

  # Created an inbound rule for Bastion Host SSH
  ingress {
    description = "Bastion Host SG"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "output from Bastion Host"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Creating an AWS instance for the Bastion Host, It should be launched in the public Subnet!
resource "aws_instance" "Bastion-Host" {

  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id

  # Keyname and security group are obtained from the reference of their instances created above!
  key_name = "Task4"

  # Security group ID's
  vpc_security_group_ids = [aws_security_group.public_host_security_group.id]
  tags                   = {
    Name = "Bastion_Host_From_Terraform"
  }
}

# Creating an AWS instance for the Bastion Host, It should be launched in the public Subnet!
resource "aws_instance" "Private-Host" {

  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id

  # Keyname and security group are obtained from the reference of their instances created above!
  key_name = "Task4"

  # Security group ID's
  vpc_security_group_ids = [aws_security_group.private_host_security_group.id]
  tags                   = {
    Name = "Private_Host_From_Terraform"
  }
}

# Creating security group for Bastion Host/Jump Box
resource "aws_security_group" "db_security_group" {

  depends_on = [
    aws_vpc.main,
    aws_subnet.public_subnet,
    aws_subnet.private_subnet
  ]

  description = "Postgres Access"
  name        = "Postgres"
  vpc_id      = aws_vpc.main.id

  # Created an inbound rule for Bastion Host SSH
  ingress {
    description = "Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "output from rds Host"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet" {
  name       = "database subnets"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.public_subnet.id]
}

resource "aws_db_instance" "my_rds" {
  allocated_storage      = 20
  db_name                = "mydb"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "db.t3.micro"

  availability_zone      = "us-east-1a"
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.id
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  tags =  {
  Name = "rds_public_access"
}
}

#resource "aws_db_instance" "dsdj-postgres-db-instance" {
#  allocated_storage    = 20
#  multi_az             = false
#  db_subnet_group_name = aws_db_subnet_group.rds_subnet.id
#  engine               = "postgres"
#  engine_version       = "13.8"
#  identifier           = "dsdj-postgres-db"
#  instance_class       = "db.t2.micro"
#  password             = "mypostgrespassword"
#  skip_final_snapshot  = true
#  storage_encrypted    = false
#  publicly_accessible  = true
#  username             = "postgres"
#  apply_immediately    = true
#}

