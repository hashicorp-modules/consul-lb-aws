module "consul_lb_aws" {
  # source = "github.com/hashicorp-modules/consul-lb-aws"
  source = "../../../consul-lb-aws"

  create      = false
  vpc_id      = ""
  cidr_blocks = []
  subnet_ids  = []
}
