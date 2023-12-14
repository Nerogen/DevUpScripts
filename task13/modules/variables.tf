variable "vpc-cidr" {
  default = "192.168.0.0/16"
}

variable "public_subnet_cidr" {
  default = "192.168.0.0/24"
}

variable "private_subnet_cidr" {
  default = "192.168.1.0/24"
}

variable "aval_zone" {
  default = ["us-east-1a", "us-east-1b"]
}