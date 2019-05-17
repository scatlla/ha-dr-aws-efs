variable "region" {}
variable "rds_allocated_storage" {
  default = 0
}
variable "rds_storage_type" {
  default = ""
}
variable "rds_engine" {
  default = ""
}
variable "rds_engine_version" {
  default = ""
}
variable "rds_instance_class" {
  default = ""
}
variable "rds_db_name" {
  default = ""
}
variable "rds_username" {
  default = ""
}
variable "rds_password" {
  default = ""
}
variable "rds_backup_retention_period" {
  default = 0
}
variable "rds_apply_immediately" {
  default = ""
}
variable "rds_skip_final_snapshot" {
  default = ""
}
variable "rds_identifier" {}
variable "rds_subnet_ids" {
  type = "list"
}
variable "rds_replicate_source_db" {
  default = ""
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_db_subnet_group" "main" {
  name = "${var.rds_identifier}"
  subnet_ids = ["${var.rds_subnet_ids}"]
}

resource "aws_db_instance" "main" {
  allocated_storage = "${var.rds_allocated_storage}"
  storage_type = "${var.rds_storage_type}"
  engine = "${var.rds_engine}"
  engine_version = "${var.rds_engine_version}"
  instance_class = "${var.rds_instance_class}"
  name = "${var.rds_db_name}"
  username = "${var.rds_username}"
  password = "${var.rds_password}"
  backup_retention_period = "${var.rds_backup_retention_period}"
  apply_immediately = "${var.rds_apply_immediately}"
  db_subnet_group_name = "${aws_db_subnet_group.main.name}"
  identifier = "${var.rds_identifier}"
  skip_final_snapshot = "${var.rds_skip_final_snapshot}"
  replicate_source_db = "${var.rds_replicate_source_db}"
}

output "rds_db_instance_identifier" {
  value = "${aws_db_instance.main.identifier}"
}

output "rds_db_instance_arn" {
  value = "${aws_db_instance.main.arn}"
}
