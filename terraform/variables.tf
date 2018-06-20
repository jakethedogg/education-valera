 variable "access_key" {}
 variable "secret_key" {}
 variable "region" {
	default = "us-east-1" 
}
 variable "vpc_cidr" {
	default = "10.0.0.0/16"
}

 variable "public_cidr" {
	default = "10.0.0.0/24"
}


 variable "private_cidr" {
	default = "10.0.1.0/24"
}
