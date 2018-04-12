output "zREADME" {
  value = <<README

LB DNS: ${module.consul_lb_aws.consul_lb_dns}

${module.root_tls_self_signed_ca.zREADME}${module.leaf_tls_self_signed_cert.zREADME}
README
}

output "consul_lb_sg_id" {
  value = "${module.consul_lb_aws.consul_lb_sg_id}"
}

output "consul_lb_dns" {
  value = "${module.consul_lb_aws.consul_lb_dns}"
}

output "consul_tg_http_8500_arn" {
  value = "${module.consul_lb_aws.consul_tg_http_8500_arn}"
}

output "consul_tg_https_8080_arn" {
  value = "${module.consul_lb_aws.consul_tg_https_8080_arn}"
}
