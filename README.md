# AWS Consul Load Balancer Terraform Module

Provisions resources for a Consul application load balancer in AWS.

Checkout [examples](./examples) for fully functioning examples.

### Environment Variables

- `AWS_DEFAULT_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Input Variables

- `create`: [Optional] Create Module, defaults to true.
- `name`: [Optional] Name for resources, defaults to "consul-aws".
- `vpc_id`: [Required] VPC ID to provision LB in.
- `cidr_blocks`: [Optional] CIDR blocks to provision LB across.
- `subnet_ids`: [Optional] Subnet ID(s) to provision LB across.
- `is_internal_lb`: [Optional] Is an internal load balancer, defaults to true.
- `use_lb_cert`: [Optional] Use certificate passed in for the LB IAM listener, "lb_cert" and "lb_private_key" must be passed in if true, defaults to false.
- `lb_cert`: [Optional] Certificate for LB IAM server certificate.
- `lb_private_key`: [Optional] Private key for LB IAM server certificate.
- `lb_cert_chain`: [Optional] Certificate chain for LB IAM server certificate.
- `lb_ssl_policy`: [Optional] SSL policy for LB, defaults to "ELBSecurityPolicy-2016-08".
- `lb_bucket`: [Optional] S3 bucket override for LB access logs, `lb_bucket_override` be set to true if overriding.
- `lb_bucket_override`: [Optional] Override the default S3 bucket created for access logs, defaults to false, `lb_bucket` _must_ be set if true.
- `lb_bucket_prefix`: [Optional] S3 bucket prefix for LB access logs.
- `lb_logs_enabled`: [Optional] S3 bucket LB access logs enabled, defaults to true.
- `tags`: [Optional] Optional list of tag maps to set on resources, defaults to empty list.

## Outputs

- `consul_lb_sg_id`: Consul load balancer security group ID.
- `consul_tg_http_8500_arn`: Consul load balancer HTTP 8500 target group.
- `consul_tg_https_8080_arn`: Consul load balancer HTTPS 8080 target group.
- `consul_lb_dns`: Consul load balancer DNS name.

## Module Dependencies

_None_

## Authors

HashiCorp Solutions Engineering Team.

## License

Mozilla Public License Version 2.0. See LICENSE for full details.
