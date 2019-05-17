variable "region" {}
variable "mibs" {}
variable "this_subnet1_id" {}
variable "this_subnet2_id" {}
variable "that_subnet1_cidr" {}
variable "that_subnet2_cidr" {}
variable "this_subnet1_cidr" {}
variable "this_subnet2_cidr" {}
variable "vpc_id" {}

provider "aws" {
  region = "${var.region}"
}
