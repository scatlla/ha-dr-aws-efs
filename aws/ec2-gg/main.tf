variable "region" {}
variable "name_prefix" {}
variable "min" {}
variable "max" {}
variable "desired" {}
variable "key_name" {}
variable "vpc_id" {}
variable "user_data" {}
variable "azs" {
  type = "list"
}
variable "subnets" {
  type = "list"
}

provider "aws" {
  region = "${var.region}"
}

data "aws_ami" "amzn" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]

}

resource "aws_security_group" "gg_ec2" {
  name = "gg-ec2"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "gg_ec2_public" {
  to_port = 22
  from_port = 22
  protocol = "tcp"
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.gg_ec2.id}"
}

resource "aws_security_group_rule" "efs_ec2_to_world" {
  to_port = -1
  from_port = -1
  protocol = "-1"
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.gg_ec2.id}"
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "${var.name_prefix}-"
  image_id      = "${data.aws_ami.amzn.id}"
  instance_type = "m5.large"
  key_name      = "${var.key_name}"
  security_groups = ["${aws_security_group.gg_ec2.id}"]
  associate_public_ip_address = true
  user_data = "${var.user_data}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.name_prefix}-asg"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  min_size             = "${var.min}"
  max_size             = "${var.max}"
  desired_capacity     = "${var.desired}"
  availability_zones   = ["${var.azs}"]
  wait_for_capacity_timeout = "5m"
  vpc_zone_identifier = ["${var.subnets}"]
  health_check_grace_period = 10
  tag {
    key = "Name"
    value = "gg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "gg_ec2_sg_id" {
  value = "${aws_security_group.gg_ec2.id}"
}
