variable "region" {}
variable "rt_id" {}
variable "dest_subnet1_cidr_block" {}
variable "dest_subnet2_cidr_block" {}
variable "vpc_peering_connection_id" {}
variable "igw_id" {}

provider "aws" {
  region = "${var.region}"
}
