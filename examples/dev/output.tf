output "consul_lb_sg_id" {
  value = "${module.consul_lb_aws.consul_lb_sg_id}"
}

output "consul_lb_dns" {
  value = "${module.consul_lb_aws.consul_lb_dns}"
}

output "consul_tg_http_8500_arn" {
  value = "${module.consul_lb_aws.consul_tg_http_8500_arn}"
}
