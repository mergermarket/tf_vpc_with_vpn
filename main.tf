locals {
  private = {
    private = "true"
    public  = "false"
    access  = "private"
  }
  public = {
    public  = "true"
    private = "false"
    access  = "public"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.60.0"
  
  name = "${var.name_prefix}-vpc"

  cidr                     = "${var.vpc_cidr}"
  private_subnets          = ["${var.private_subnet_cidrs}"]
  public_subnets           = ["${var.public_subnet_cidrs}"]

  enable_nat_gateway   = "true"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  private_subnet_tags = "${local.private}"
  public_subnet_tags = "${local.public}"

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
  destination_cidr_blocks     = [
            "10.2.0.0/24",
            "10.3.0.152/32",
            "10.12.0.0/24",
            "10.151.0.0/16",
            "10.151.112.0/24",
            "10.151.132.0/22",
            "10.151.133.6/32",
            "10.151.133.104/29",
            "10.151.200.0/22",
            "10.151.214.0/24",
            "10.158.0.0/16",
            "193.132.119.0/24",
        ]
  route_table_ids             = ["${concat(module.vpc.public_route_table_ids, module.vpc.private_route_table_ids)}"]
  route_table_count           = "${var.route_table_count}"
  static_routes_only          = "true"
  add_static_routes_to_tables = "true"
}

module "leg_b_customer_gateway" {
  source = "github.com/mergermarket/tf_aws_customer_gw"

  name                        = "${var.name_prefix}-${var.leg_b_name}"
  vpn_gateway_id              = "${module.vpn.vgw_id}"
  ip_address                  = "${var.leg_b_ip_address}"
  bgp_asn                     = "${var.leg_b_bgp_asn}"
  destination_cidr_blocks     = [
            "10.2.0.0/24",
            "10.3.0.152/32",
            "10.12.0.0/24",
            "10.151.0.0/16",
            "10.151.112.0/24",
            "10.151.132.0/22",
            "10.151.133.6/32",
            "10.151.133.104/29",
            "10.151.200.0/22",
            "10.151.214.0/24",
            "10.158.0.0/16",
            "193.132.119.0/24",
        ]
  route_table_ids             = ["${concat(module.vpc.public_route_table_ids, module.vpc.private_route_table_ids)}"]
  route_table_count           = "${var.route_table_count}"
  static_routes_only          = "true"
  add_static_routes_to_tables = "true"
}
