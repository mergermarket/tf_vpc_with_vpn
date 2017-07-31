module "vpc" {
  source = "github.com/mergermarket/tf_aws_vpc"

  name = "${var.name_prefix}-vpc"

  cidr            = "${var.vpc_cidr}"
  private_subnets = ["${var.private_subnet_cidrs}"]
  public_subnets  = ["${var.public_subnet_cidrs}"]

  enable_nat_gateway   = "true"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  azs = ["${var.azs}"]
}

module "vpn" {
  source = "github.com/mergermarket/tf_aws_vpn_gw"

  name   = "${var.name_prefix}-vpn"
  vpc_id = "${module.vpc.vpc_id}"
}

module "leg_a_customer_gateway" {
  source = "github.com/mergermarket/tf_aws_customer_gw"

  name                        = "${var.name_prefix}-${var.leg_a_name}"
  vpn_gateway_id              = "${module.vpn.vgw_id}"
  ip_address                  = "${var.leg_a_ip_address}"
  bgp_asn                     = "${var.leg_a_bgp_asn}"
  destination_cidr_blocks     = []
  route_table_ids             = ["${concat(module.vpc.public_route_table_ids, module.vpc.private_route_table_ids)}"]
  route_table_count           = "${var.route_table_count}"
  static_routes_only          = "false"
  add_static_routes_to_tables = "false"
}

module "leg_b_customer_gateway" {
  source = "github.com/mergermarket/tf_aws_customer_gw"

  name                        = "${var.name_prefix}-${var.leg_b_name}"
  vpn_gateway_id              = "${module.vpn.vgw_id}"
  ip_address                  = "${var.leg_b_ip_address}"
  bgp_asn                     = "${var.leg_b_bgp_asn}"
  destination_cidr_blocks     = []
  route_table_ids             = ["${concat(module.vpc.public_route_table_ids, module.vpc.private_route_table_ids)}"]
  route_table_count           = "${var.route_table_count}"
  static_routes_only          = "false"
  add_static_routes_to_tables = "false"
}
