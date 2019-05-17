resource "aws_efs_file_system" "efs" {
  creation_token = "primary_efs"
  encrypted = true
  performance_mode = "maxIO"
  throughput_mode = "provisioned"
  provisioned_throughput_in_mibps = "${var.mibs}"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_security_group" "sg" {
  name = "efs-sg-allow-from-other-region"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "inbound" {
  from_port = -1
  to_port = -1
  protocol = "-1"
  security_group_id = "${aws_security_group.sg.id}"
  type = "ingress"
  cidr_blocks = ["${var.that_subnet1_cidr}", "${var.that_subnet2_cidr}", "${var.this_subnet1_cidr}", "${var.this_subnet2_cidr}"]
}

resource "aws_efs_mount_target" "efs_tg_subnet1" {
  file_system_id = "${aws_efs_file_system.efs.id}"
  subnet_id = "${var.this_subnet1_id}"
  security_groups = ["${aws_security_group.sg.id}"]
}

resource "aws_efs_mount_target" "efs_tg_subnet2" {
  file_system_id = "${aws_efs_file_system.efs.id}"
  subnet_id = "${var.this_subnet2_id}"
  security_groups = ["${aws_security_group.sg.id}"]
}

output "efs_target1_ip" {
  value = "${aws_efs_mount_target.efs_tg_subnet1.ip_address}"
}

output "efs_target2_ip" {
  value = "${aws_efs_mount_target.efs_tg_subnet2.ip_address}"
}
