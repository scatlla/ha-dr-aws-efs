provider "aws" {
  region = "${var.primary_region}"
}

variable project_name {
  default = "efs-ha-dr"
}

variable provisioner {
  default = "Terraform"
}

variable account_id {
  default = ""
}

variable "primary_region" {
  default = "us-east-1"
}

variable "secondary_region" {
  default = "us-east-2"
}

variable "environment" {
  default = "development"
}

data "aws_availability_zones" "region_azs" {}

data "aws_region" "current_region" {}

variable "primary_key_name" {
  default = "dr-us-east-1"
}

variable "secondary_key_name" {
  default = "dr-us-east-2"
}

variable "volume_type" {
  default = "gp2"
}

variable "volume_size" {
  default = "1000"
}

variable "primary_cidr_block" {
  default = "10.1.0.0/16"
}

variable "primary_subnet1_cidr_block" {
  default = "10.1.1.0/24"
}

variable "primary_subnet2_cidr_block" {
  default = "10.1.2.0/24"
}

variable "primary_subnet1_az" {
  default = "us-east-1a"
}

variable "primary_subnet2_az" {
  default = "us-east-1b"
}

variable "secondary_cidr_block" {
  default = "10.2.0.0/16"
}

variable "secondary_subnet1_cidr_block" {
  default = "10.2.1.0/24"
}

variable "secondary_subnet2_cidr_block" {
  default = "10.2.2.0/24"
}

variable "secondary_subnet1_az" {
  default = "us-east-2a"
}

variable "secondary_subnet2_az" {
  default = "us-east-2b"
}

variable "efs_provisioned_throughput_mibs" {
  default = "50"
}

variable "rds_instance_class" {
  default = "db.m5.large"
}

variable "rds_allocated_storage" {
  default = 20
}

variable "rds_storage_type" {
  default = "gp2"
}

variable "rds_engine" {
  default = "mysql"
}

variable "rds_engine_version" {
  default = "5.7"
}

variable "rds_db_name" {
  default = "test_db"
}

variable "rds_username" {
  default = "root"
}

variable "rds_password" {
  default = "password"
}

variable "rds_backup_retention_period" {
  default = 1
}

variable "rds_apply_immediately" {
  default = true
}

variable "rds_skip_final_snapshot" {
  default = true
}
