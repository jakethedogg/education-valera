provider "aws" {

	access_key = "${var.access_key}"
	secret_key = "${var.secret_key}"
 	 region    = "${var.region}"
}


resource "aws_vpc" "main" {

	cidr_block = "${var.vpc_cidr}"
	assign_generated_ipv6_cidr_block = "true"

   tags {
	
	Name = "Terraform-VPC"
	}
}

resource "aws_internet_gateway" "gateway" {

	vpc_id="${aws_vpc.main.id}"
   tags {
	Name = "Terraform-internetGW"
	}
}


resource "aws_subnet" "public" {

	vpc_id = "${aws_vpc.main.id}"
	cidr_block = "${var.public_cidr}"
	map_public_ip_on_launch = "true"
   tags {
	Name = "Public subnet"
	}
}

resource "aws_subnet" "private" {

        vpc_id = "${aws_vpc.main.id}"
        cidr_block = "${var.private_cidr}"
   tags {
        Name = "Private subnet"
        }
}

resource "aws_route_table" "rtable" {

	vpc_id = "${aws_vpc.main.id}"
	
   route {
	cidr_block = "0.0.0.0/0"
	gateway_id = "${aws_internet_gateway.gateway.id}"
	}
   tags {
	Name = "Route Table"
	}
}

resource "aws_route_table_association" "rpublic" {
	subnet_id = "${aws_subnet.public.id}"
	route_table_id = "${aws_route_table.rtable.id}"
}

resource "aws_eip" "praceip" {
	vpc = "true"
	depends_on = ["aws_internet_gateway.gateway"]
}

resource "aws_nat_gateway" "nat" {

	allocation_id = "${aws_eip.praceip.id}"
	subnet_id = "${aws_subnet.public.id}"
	depends_on = ["aws_internet_gateway.gateway"]
}

resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.private_cidr}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.private_cidr}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "NATSG"
    }
}



