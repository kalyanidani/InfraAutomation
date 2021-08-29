resource "aws_vpc" "this" {
    cidr_block = var.cidr_block

    instance_tenancy = "default"

    enable_dns_support = true
    







}