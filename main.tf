terraform {
  required_version = ">= 0.11.5"
}

provider "aws" {
  version = "~> 1.12"
}

provider "random" {
  version = "~> 1.1"
}

provider "tls" {
  version = "~> 1.1"
}

provider "null" {
  version = "~> 1.0"
}

resource "aws_security_group" "consul_lb" {
  count = "${var.create ? 1 : 0}"

  name_prefix = "${var.name}-consul-lb-"
  description = "Security group for consul ${var.name} LB"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.tags, map("Name", format("%s-consul-lb", var.name)))}"
}

resource "aws_security_group_rule" "consul_lb_http_80" {
  count = "${var.create ? 1 : 0}"

  security_group_id = "${aws_security_group.consul_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["${split(",", var.is_internal_lb ? join(",", var.cidr_blocks) : "0.0.0.0/0")}"]
}

resource "aws_security_group_rule" "consul_lb_https_443" {
  count = "${var.create && var.use_lb_cert ? 1 : 0}"

  security_group_id = "${aws_security_group.consul_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["${split(",", var.is_internal_lb ? join(",", var.cidr_blocks) : "0.0.0.0/0")}"]
}

resource "aws_security_group_rule" "consul_lb_tcp_8500" {
  count = "${var.create ? 1 : 0}"

  security_group_id = "${aws_security_group.consul_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8500
  to_port           = 8500
  cidr_blocks       = ["${split(",", var.is_internal_lb ? join(",", var.cidr_blocks) : "0.0.0.0/0")}"]
}

resource "aws_security_group_rule" "consul_lb_tcp_8080" {
  count = "${var.create ? 1 : 0}"

  security_group_id = "${aws_security_group.consul_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8080
  to_port           = 8080
  cidr_blocks       = ["${split(",", var.is_internal_lb ? join(",", var.cidr_blocks) : "0.0.0.0/0")}"]
}

resource "aws_security_group_rule" "outbound_tcp" {
  count = "${var.create ? 1 : 0}"

  security_group_id = "${aws_security_group.consul_lb.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "random_id" "consul_lb_access_logs" {
  count = "${var.create && !var.lb_bucket_override ? 1 : 0}"

  byte_length = 4
  prefix      = "${format("%s-consul-lb-access-logs-", var.name)}"
}

data "aws_elb_service_account" "consul_lb_access_logs" {
  count = "${var.create && !var.lb_bucket_override ? 1 : 0}"
}

resource "aws_s3_bucket" "consul_lb_access_logs" {
  count = "${var.create && !var.lb_bucket_override ? 1 : 0}"

  bucket = "${random_id.consul_lb_access_logs.hex}"
  acl    = "private"
  tags   = "${merge(var.tags, map("Name", format("%s-consul-lb-access-logs", var.name)))}"

  force_destroy = true

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LBAccessLogs",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${random_id.consul_lb_access_logs.hex}${var.lb_bucket_prefix != "" ? format("//", var.lb_bucket_prefix) : ""}/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.consul_lb_access_logs.arn}"
        ]
      }
    }
  ]
}
POLICY
}

resource "random_id" "consul_lb" {
  count = "${var.create ? 1 : 0}"

  byte_length = 4
  prefix      = "consul-lb-"
}

resource "aws_lb" "consul" {
  count = "${var.create ? 1 : 0}"

  name            = "${random_id.consul_lb.hex}"
  internal        = "${var.is_internal_lb ? true : false}"
  subnets         = ["${var.subnet_ids}"]
  security_groups = ["${aws_security_group.consul_lb.id}"]
  tags            = "${merge(var.tags, map("Name", format("%s-consul-lb", var.name)))}"

  access_logs {
    bucket  = "${var.lb_bucket_override ? var.lb_bucket : element(concat(aws_s3_bucket.consul_lb_access_logs.*.id, list("")), 0)}"
    prefix  = "${var.lb_bucket_prefix}"
    enabled = "${var.lb_logs_enabled}"
  }
}

resource "random_id" "consul_http_8500" {
  count = "${var.create ? 1 : 0}"

  byte_length = 4
  prefix      = "consul-http-8500-"
}

resource "aws_lb_target_group" "consul_http_8500" {
  count = "${var.create ? 1 : 0}"

  name     = "${random_id.consul_http_8500.hex}"
  vpc_id   = "${var.vpc_id}"
  port     = 8500
  protocol = "HTTP"
  tags     = "${merge(var.tags, map("Name", format("%s-consul-http-8500", var.name)))}"

  health_check {
    interval = 15
    timeout  = 5
    protocol = "HTTP"
    port     = "traffic-port"
    path     = "/v1/status/leader"
    matcher  = "200"

    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "consul_80" {
  count = "${var.create ? 1 : 0}"

  load_balancer_arn = "${aws_lb.consul.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.consul_http_8500.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "consul_8500" {
  count = "${var.create ? 1 : 0}"

  load_balancer_arn = "${aws_lb.consul.arn}"
  port              = "8500"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.consul_http_8500.arn}"
    type             = "forward"
  }
}

resource "aws_iam_server_certificate" "consul" {
  count = "${var.create && var.use_lb_cert ? 1 : 0}"

  name              = "${random_id.consul_lb.hex}"
  certificate_body  = "${var.lb_cert}"
  private_key       = "${var.lb_private_key}"
  certificate_chain = "${var.lb_cert_chain}"
  path              = "/${var.name}-${random_id.consul_lb.hex}/"
}

resource "random_id" "consul_https_8080" {
  count = "${var.create && var.use_lb_cert ? 1 : 0}"

  byte_length = 4
  prefix      = "consul-https-8080-"
}

resource "aws_lb_target_group" "consul_https_8080" {
  count = "${var.create && var.use_lb_cert ? 1 : 0}"

  name     = "${random_id.consul_https_8080.hex}"
  vpc_id   = "${var.vpc_id}"
  port     = 8080
  protocol = "HTTPS"
  tags     = "${merge(var.tags, map("Name", format("%s-consul-https-8080", var.name)))}"

  health_check {
    interval = 15
    timeout  = 5
    protocol = "HTTPS"
    port     = "traffic-port"
    path     = "/v1/status/leader"
    matcher  = "200"

    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "consul_443" {
  count = "${var.create && var.use_lb_cert ? 1 : 0}"

  load_balancer_arn = "${aws_lb.consul.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "${var.lb_ssl_policy}"
  certificate_arn   = "${aws_iam_server_certificate.consul.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.consul_https_8080.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "consul_8080" {
  count = "${var.create && var.use_lb_cert ? 1 : 0}"

  load_balancer_arn = "${aws_lb.consul.arn}"
  port              = "8080"
  protocol          = "HTTPS"
  ssl_policy        = "${var.lb_ssl_policy}"
  certificate_arn   = "${aws_iam_server_certificate.consul.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.consul_https_8080.arn}"
    type             = "forward"
  }
}
