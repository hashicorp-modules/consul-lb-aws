output "consul_app_lb_sg_id" {
  value = "${element(concat(aws_security_group.consul_app_lb.*.id, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_lb_arn" {
  value = "${element(concat(aws_lb.consul.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_app_lb_dns" {
  value = "${element(concat(aws_lb.consul_application_lb.*.dns_name, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_network_lb_dns" {
  value = "${element(concat(aws_lb.consul_network_lb.*.dns_name, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_tg_tcp_22_arn" {
  value = "${element(concat(aws_lb_target_group.consul_tcp_22.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_tg_tcp_8500_arn" {
  value = "${element(concat(aws_lb_target_group.consul_tcp_8500.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_tg_http_8500_arn" {
  value = "${element(concat(aws_lb_target_group.consul_http_8500.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_tg_tcp_8080_arn" {
  value = "${element(concat(aws_lb_target_group.consul_tcp_8080.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_tg_https_8080_arn" {
  value = "${element(concat(aws_lb_target_group.consul_https_8080.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_tg_http_3030_arn" {
  value = "${element(concat(aws_lb_target_group.consul_http_3030.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_tg_https_3030_arn" {
  value = "${element(concat(aws_lb_target_group.consul_https_3030.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}
