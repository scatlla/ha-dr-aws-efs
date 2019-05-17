resource "aws_route" "world" {
  route_table_id = "${var.rt_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${var.igw_id}"
}
