resource "aws_route" "requestor1" {
  route_table_id = "${var.rt_id}"
  destination_cidr_block = "${var.dest_subnet1_cidr_block}"
  vpc_peering_connection_id = "${var.vpc_peering_connection_id}"
}

resource "aws_route" "requestor2" {
  route_table_id = "${var.rt_id}"
  destination_cidr_block = "${var.dest_subnet2_cidr_block}"
  vpc_peering_connection_id = "${var.vpc_peering_connection_id}"
}
