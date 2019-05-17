variable "cidr_block" {}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags {
    Name = "HA-DR"
  }
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

variable "subnet1_cidr_block" {}
variable "subnet2_cidr_block" {}
variable "subnet1_az" {}
variable "subnet2_az" {}
variable "project_name" {}

resource "aws_subnet" "subnet1" {
  cidr_block = "${var.subnet1_cidr_block}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${var.subnet1_az}"
  tags {
    Name = "${var.project_name}-subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  cidr_block = "${var.subnet2_cidr_block}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${var.subnet2_az}"
  tags {
    Name = "${var.project_name}-subnet2"
  }
}

output "subnet1_cidr_block" {
  value = "${aws_subnet.subnet1.cidr_block}"
}

output "subnet2_cidr_block" {
  value = "${aws_subnet.subnet2.cidr_block}"
}

output "subnet1_subnet_id" {
  value = "${aws_subnet.subnet1.id}"
}

output "subnet2_subnet_id" {
  value = "${aws_subnet.subnet2.id}"
}

resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table_association" "rt_assoc_1" {
  route_table_id = "${aws_route_table.rt.id}"
  subnet_id = "${aws_subnet.subnet1.id}"
}

resource "aws_route_table_association" "rt_assoc_2" {
  route_table_id = "${aws_route_table.rt.id}"
  subnet_id = "${aws_subnet.subnet2.id}"
}

output "route_table_id" {
  value = "${aws_route_table.rt.id}"
}

output "region" {
  value = "${var.region}"
}
