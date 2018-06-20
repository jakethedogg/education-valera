 output "vpc_id" {

	value = "${aws_vpc.main.id}"
}

 output "vpc_cidr_block" {

        value = "${aws_vpc.main.cidr_block}"
}

 output "InternetGW" {

        value = "${aws_internet_gateway.gateway.id}"
}


output "PublicSubnet" {

        value = "${aws_subnet.public.id}"
}

output "PrivateSubnet" {

        value = "${aws_subnet.private.id}"
}

output "RouteTable" {

        value = "${aws_route_table.rtable.id}"
}

output "EllasticId" {

        value = "${aws_eip.praceip.id}"
}

output "NATid" {

        value = "${aws_nat_gateway.nat.id}"
}

