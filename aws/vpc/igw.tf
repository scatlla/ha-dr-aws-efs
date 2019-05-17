resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

output "igw_id" {
  value = "${aws_internet_gateway.gw.id}"
}
