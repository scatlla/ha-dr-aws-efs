module "primary_vpc" {
  source = "aws/vpc"

  region = "${var.primary_region}"
  cidr_block = "${var.primary_cidr_block}"
  subnet1_cidr_block = "${var.primary_subnet1_cidr_block}"
  subnet2_cidr_block = "${var.primary_subnet2_cidr_block}"
  subnet1_az = "${var.primary_subnet1_az}"
  subnet2_az = "${var.primary_subnet2_az}"
  project_name = "${var.project_name}"
}

module "secondary_vpc" {
  source = "aws/vpc"

  region = "${var.secondary_region}"
  cidr_block = "${var.secondary_cidr_block}"
  subnet1_cidr_block = "${var.secondary_subnet1_cidr_block}"
  subnet2_cidr_block = "${var.secondary_subnet2_cidr_block}"
  subnet1_az = "${var.secondary_subnet1_az}"
  subnet2_az = "${var.secondary_subnet2_az}"
  project_name = "${var.project_name}"
}

module "vpc_peer" {
  source  = "aws/peer"
  request_region = "${module.primary_vpc.region}"
  request_vpc_id = "${module.primary_vpc.vpc_id}"
  accept_region = "${module.secondary_vpc.region}"
  accept_vpc_id = "${module.secondary_vpc.vpc_id}"
}

module "primary_routes" {
  source  = "aws/routes"

  region = "${var.primary_region}"

  rt_id = "${module.primary_vpc.route_table_id}"
  dest_subnet1_cidr_block = "${module.secondary_vpc.subnet1_cidr_block}"
  dest_subnet2_cidr_block = "${module.secondary_vpc.subnet2_cidr_block}"

  vpc_peering_connection_id = "${module.vpc_peer.vpc_peering_connection_id}"
  igw_id = "${module.primary_vpc.igw_id}"
}

module "secondary_routes" {
  source  = "aws/routes"

  region = "${var.secondary_region}"

  rt_id = "${module.secondary_vpc.route_table_id}"
  dest_subnet1_cidr_block = "${module.primary_vpc.subnet1_cidr_block}"
  dest_subnet2_cidr_block = "${module.primary_vpc.subnet2_cidr_block}"

  vpc_peering_connection_id = "${module.vpc_peer.vpc_peering_connection_id}"
  igw_id = "${module.secondary_vpc.igw_id}"
}

module "primary_efs" {
  source  = "aws/efs"

  region = "${var.primary_region}"
  mibs = "${var.efs_provisioned_throughput_mibs}"
  this_subnet1_id = "${module.primary_vpc.subnet1_subnet_id}"
  this_subnet2_id = "${module.primary_vpc.subnet2_subnet_id}"
  this_subnet1_cidr = "${module.primary_vpc.subnet1_cidr_block}"
  this_subnet2_cidr = "${module.primary_vpc.subnet2_cidr_block}"

  # We need these CIDRs to build the SG to allow traffic from other region
  that_subnet1_cidr = "${module.secondary_vpc.subnet1_cidr_block}"
  that_subnet2_cidr = "${module.secondary_vpc.subnet2_cidr_block}"

  vpc_id = "${module.primary_vpc.vpc_id}"
}

module "secondary_efs" {
  source  = "aws/efs"

  region = "${var.secondary_region}"
  mibs = "${var.efs_provisioned_throughput_mibs}"
  this_subnet1_id = "${module.secondary_vpc.subnet1_subnet_id}"
  this_subnet2_id = "${module.secondary_vpc.subnet2_subnet_id}"
  this_subnet1_cidr = "${module.secondary_vpc.subnet1_cidr_block}"
  this_subnet2_cidr = "${module.secondary_vpc.subnet2_cidr_block}"

  # We need these CIDRs to build the SG to allow traffic from other region
  that_subnet1_cidr = "${module.primary_vpc.subnet1_cidr_block}"
  that_subnet2_cidr = "${module.primary_vpc.subnet2_cidr_block}"

  vpc_id = "${module.secondary_vpc.vpc_id}"
}

module "primary_rds" {
  source = "aws/rds"

  region = "${var.primary_region}"

  rds_allocated_storage = "${var.rds_allocated_storage}"
  rds_storage_type = "${var.rds_storage_type}"
  rds_engine = "${var.rds_engine}"
  rds_engine_version = "${var.rds_engine_version}"
  rds_instance_class = "${var.rds_instance_class}"
  rds_db_name = "${var.rds_db_name}"
  rds_username = "${var.rds_username}"
  rds_password = "${var.rds_password}"
  rds_backup_retention_period = "${var.rds_backup_retention_period}"
  rds_apply_immediately = "${var.rds_apply_immediately}"
  rds_identifier = "primary"
  rds_skip_final_snapshot = "${var.rds_skip_final_snapshot}"
  rds_subnet_ids = ["${module.primary_vpc.subnet1_subnet_id}", "${module.primary_vpc.subnet2_subnet_id}"]
}

module "secondary_rds" {
  source = "aws/rds"
  region = "${var.secondary_region}"

  rds_allocated_storage = "${var.rds_allocated_storage}"
  rds_storage_type = "${var.rds_storage_type}"
  rds_engine = "${var.rds_engine}"
  rds_engine_version = "${var.rds_engine_version}"
  rds_instance_class = "${var.rds_instance_class}"
  rds_identifier = "secondary"
  rds_skip_final_snapshot = "${var.rds_skip_final_snapshot}"
  rds_subnet_ids = ["${module.secondary_vpc.subnet1_subnet_id}", "${module.secondary_vpc.subnet2_subnet_id}"]
  rds_replicate_source_db = "${module.primary_rds.rds_db_instance_arn}"
}

module "efs_ec2_ha_primary" {
  source = "aws/ec2-efs-rsync"
  region = "${var.primary_region}"

  min = 1
  max = 1
  desired = 1
  name_prefix = "efs-primary"
  azs = ["${var.primary_subnet1_az}", "${var.primary_subnet2_az}"]
  subnets = ["${module.primary_vpc.subnet1_subnet_id}", "${module.primary_vpc.subnet2_subnet_id}"]
  key_name = "${var.primary_key_name}"
  vpc_id = "${module.primary_vpc.vpc_id}"

  user_data = <<-EOF
      #!/bin/bash
      yum update -y
      yum install -y gcc
      mkdir /EFS-HA
      mkdir /EFS-DR
      echo "${module.primary_efs.efs_target1_ip}:/  /EFS-HA nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2  0 0" >> /etc/fstab
      echo "${module.secondary_efs.efs_target1_ip}:/  /EFS-DR nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2  0 0" >> /etc/fstab
      mount /EFS-HA; chmod a+w /EFS-HA
      mount /EFS-DR; chmod a+w /EFS-DR
      (crontab -l; echo '@reboot    while [[ 1 == 1 ]]; do rsync -av /EFS-HA/ /EFS-DR/ 1>/dev/null 2>&1; sleep 300; done') | crontab -
      reboot
    EOF
}

module "efs_ec2_ha_secondary" {
  source = "aws/ec2-efs-rsync"
  region = "${var.secondary_region}"

  min = 1
  max = 1
  desired = 1
  name_prefix = "efs-secondary"
  azs = ["${var.secondary_subnet1_az}", "${var.secondary_subnet2_az}"]
  subnets = ["${module.secondary_vpc.subnet1_subnet_id}", "${module.secondary_vpc.subnet2_subnet_id}"]
  key_name = "${var.secondary_key_name}"
  vpc_id = "${module.secondary_vpc.vpc_id}"

  user_data = <<-EOF
      #!/bin/bash
      sudo yum install -y gcc
      mkdir /EFS-HA
      mkdir /EFS-DR
      echo "${module.secondary_efs.efs_target1_ip}:/  /EFS-HA nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2  0 0" >> /etc/fstab
      echo "${module.primary_efs.efs_target1_ip}:/  /EFS-DR nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2  0 0" >> /etc/fstab
      mount /EFS-HA
      mount /EFS-DR
      #(crontab -l; echo '@reboot    while [[ 1 == 1 ]]; do rsync -av /EFS-HA/ /EFS-DR/ 1>/dev/null 2>&1; sleep 300; done') | crontab -
      #reboot
    EOF
}

module "gg_instance" {
  source = "aws/ec2-gg"

  region = "${var.primary_region}"

  min = 1
  max = 1
  desired = 1
  name_prefix = "gg-primary"
  azs = ["${var.primary_subnet1_az}", "${var.primary_subnet2_az}"]
  subnets = ["${module.primary_vpc.subnet1_subnet_id}", "${module.primary_vpc.subnet2_subnet_id}"]
  key_name = "${var.primary_key_name}"
  vpc_id = "${module.primary_vpc.vpc_id}"

  user_data = <<-EOF
      #!/bin/bash
      sudo yum install -y gcc
      mkdir /EFS
      echo "${module.primary_efs.efs_target1_ip}:/  /EFS nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2  0 0" >> /etc/fstab
      mount /EFS; chmod a+w /EFS
    EOF
}
